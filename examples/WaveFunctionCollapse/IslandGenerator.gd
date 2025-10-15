extends Node
class_name IslandGenerator

enum TileType { DEEP_WATER, WATER, SAND, GRASS, FOREST, MOUNTAIN }

const TILE_COLORS = {
	TileType.DEEP_WATER: Color(0.1, 0.3, 0.6),
	TileType.WATER: Color(0.2, 0.5, 0.8),
	TileType.SAND: Color(0.95, 0.9, 0.7),
	TileType.GRASS: Color(0.4, 0.7, 0.3),
	TileType.FOREST: Color(0.2, 0.5, 0.2),
	TileType.MOUNTAIN: Color(0.5, 0.5, 0.5)
}

# WFC adjacency rules - what tiles can be next to each other
const ADJACENCY_RULES = {
	TileType.DEEP_WATER: [TileType.DEEP_WATER, TileType.WATER],
	TileType.WATER: [TileType.WATER, TileType.DEEP_WATER, TileType.SAND],
	TileType.SAND: [TileType.SAND, TileType.WATER, TileType.GRASS],
	TileType.GRASS: [TileType.GRASS, TileType.SAND, TileType.FOREST],
	TileType.FOREST: [TileType.FOREST, TileType.GRASS, TileType.MOUNTAIN],
	TileType.MOUNTAIN: [TileType.MOUNTAIN, TileType.FOREST]
}

var grid_width: int
var grid_height: int
var cells: Array = []  # Array of possible tile arrays for each cell
var noise: FastNoiseLite

func _init(width: int, height: int):
	grid_width = width
	grid_height = height
	setup_noise()
	reset_grid()

func setup_noise():
	noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.frequency = 0.05
	noise.fractal_octaves = 4
	noise.fractal_gain = 0.5

func reset_grid():
	cells.clear()
	noise.seed = randi()
	initialize_wfc()

func initialize_wfc():
	# Initialize all cells with all possibilities (superposition)
	for y in range(grid_height):
		var row = []
		for x in range(grid_width):
			# Start with all tile types as possibilities
			row.append(TileType.values())
		cells.append(row)

func is_valid_position(x: int, y: int) -> bool:
	return x >= 0 and x < grid_width and y >= 0 and y < grid_height

func get_entropy(x: int, y: int) -> int:
	if not is_valid_position(x, y):
		return -1
	return cells[y][x].size()

func is_collapsed(x: int, y: int) -> bool:
	return get_entropy(x, y) == 1

func get_tile(x: int, y: int) -> int:
	if is_valid_position(x, y) and cells[y][x].size() > 0:
		return cells[y][x][0]
	return -1

func find_lowest_entropy_cell() -> Vector2i:
	var min_entropy = 999
	var candidates = []
	
	for y in range(grid_height):
		for x in range(grid_width):
			var entropy = get_entropy(x, y)
			if entropy > 1:
				if entropy < min_entropy:
					min_entropy = entropy
					candidates = [Vector2i(x, y)]
				elif entropy == min_entropy:
					candidates.append(Vector2i(x, y))
	
	if candidates.is_empty():
		return Vector2i(-1, -1)
	
	return candidates[randi() % candidates.size()]

func collapse_cell(x: int, y: int) -> bool:
	if not is_valid_position(x, y) or is_collapsed(x, y):
		return false
	
	var possibilities = cells[y][x]
	if possibilities.is_empty():
		return false
	
	# Use noise and distance to weight tile selection for island shape
	var center_x = grid_width / 2.0
	var center_y = grid_height / 2.0
	var dx = x - center_x
	var dy = y - center_y
	var dist = sqrt(dx * dx + dy * dy)
	var max_dist = sqrt(center_x * center_x + center_y * center_y)
	var dist_factor = dist / max_dist
	
	var noise_value = noise.get_noise_2d(x, y)
	var height = noise_value - (dist_factor * 1.5) + 0.3
	
	# Weight possibilities based on height
	var weighted_tiles = []
	for tile in possibilities:
		var weight = get_tile_weight_for_height(tile, height)
		if weight > 0:
			for i in range(int(weight * 10)):
				weighted_tiles.append(tile)
	
	if weighted_tiles.is_empty():
		weighted_tiles = possibilities
	
	var chosen_tile = weighted_tiles[randi() % weighted_tiles.size()]
	cells[y][x] = [chosen_tile]
	return true

func get_tile_weight_for_height(tile: int, height: float) -> float:
	# Return weight based on how suitable the tile is for this height
	match tile:
		TileType.DEEP_WATER:
			return max(0, 1.0 - (height + 0.3) * 5)
		TileType.WATER:
			return max(0, 1.0 - abs(height + 0.1) * 5)
		TileType.SAND:
			return max(0, 1.0 - abs(height) * 5)
		TileType.GRASS:
			return max(0, 1.0 - abs(height - 0.15) * 3)
		TileType.FOREST:
			return max(0, 1.0 - abs(height - 0.4) * 3)
		TileType.MOUNTAIN:
			return max(0, (height - 0.5) * 5)
	return 0.5

func propagate_constraints(x: int, y: int):
	var stack = [Vector2i(x, y)]
	var visited = {}
	
	while not stack.is_empty():
		var pos = stack.pop_back()
		var px = pos.x
		var py = pos.y
		
		var key = Vector2i(px, py)
		if key in visited:
			continue
		visited[key] = true
		
		if not is_valid_position(px, py):
			continue
		
		var neighbors = [
			Vector2i(px + 1, py),
			Vector2i(px - 1, py),
			Vector2i(px, py + 1),
			Vector2i(px, py - 1)
		]
		
		for neighbor in neighbors:
			var nx = neighbor.x
			var ny = neighbor.y
			
			if not is_valid_position(nx, ny) or is_collapsed(nx, ny):
				continue
			
			var old_possibilities = cells[ny][nx].duplicate()
			var valid_adjacent_tiles = {}
			
			# Get all valid tiles from current cell's adjacency rules
			for current_tile in cells[py][px]:
				for allowed_tile in ADJACENCY_RULES[current_tile]:
					valid_adjacent_tiles[allowed_tile] = true
			
			# Filter neighbor's possibilities
			var new_possibilities = []
			for tile in old_possibilities:
				if tile in valid_adjacent_tiles:
					new_possibilities.append(tile)
			
			if new_possibilities.size() < old_possibilities.size() and not new_possibilities.is_empty():
				cells[ny][nx] = new_possibilities
				stack.append(neighbor)

func wfc_step() -> Vector2i:
	var cell = find_lowest_entropy_cell()
	
	if cell.x == -1:
		return Vector2i(-1, -1)
	
	if collapse_cell(cell.x, cell.y):
		propagate_constraints(cell.x, cell.y)
		return cell
	
	return Vector2i(-1, -1)

func is_complete() -> bool:
	for y in range(grid_height):
		for x in range(grid_width):
			if not is_collapsed(x, y):
				return false
	return true

func generate_full():
	# Run WFC until complete
	var max_iterations = grid_width * grid_height * 2
	var iterations = 0
	
	while not is_complete() and iterations < max_iterations:
		var result = wfc_step()
		if result.x == -1:
			break
		iterations += 1
	
	return is_complete()
