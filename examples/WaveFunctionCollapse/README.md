# Island Generator Example

A procedural island generation system for Godot 4 using the Wave Function Collapse (WFC) algorithm with noise-weighted tile selection.

## What is Wave Function Collapse?

Wave Function Collapse is a constraint-solving algorithm inspired by quantum mechanics that generates coherent patterns by:

1. **Superposition**: Starting with all cells in a state of "superposition" (all tile types are possible)
2. **Entropy Measurement**: Calculating which cells have the fewest possibilities (lowest entropy)
3. **Observation/Collapse**: Selecting and "collapsing" the lowest-entropy cell to a single state
4. **Constraint Propagation**: Updating neighboring cells based on adjacency rules
5. **Iteration**: Repeating until all cells are resolved

This creates locally consistent patterns that emerge into globally coherent structures.

## How This Implementation Uses WFC

### Core WFC Elements

**Adjacency Rules**: Define which terrain types can be neighbors
```gdscript
DEEP_WATER → [DEEP_WATER, WATER]
WATER → [WATER, DEEP_WATER, SAND]
SAND → [SAND, WATER, GRASS]
GRASS → [GRASS, SAND, FOREST]
FOREST → [FOREST, GRASS, MOUNTAIN]
MOUNTAIN → [MOUNTAIN, FOREST]
```

This creates natural terrain transitions: ocean → shallow water → beach → grassland → forest → mountain peaks.

**Weighted Collapse**: Instead of pure random selection, this implementation uses:
- **Perlin/Simplex Noise**: Provides organic height variation
- **Radial Distance**: Creates island shapes (water at edges, land in center)
- **Weighted Selection**: Tiles are chosen based on fitness for the calculated "height" value

This hybrid approach combines WFC's constraint solving with procedural generation's predictability.

**Constraint Propagation**: When a cell collapses to a tile type, it immediately reduces the possibilities of neighboring cells based on adjacency rules. This propagates across the grid, ensuring no invalid tile combinations exist.

### Algorithm Flow

1. Initialize all cells with all 6 tile possibilities
2. Calculate noise-based height map for weighting
3. Find cell with lowest entropy (fewest possibilities)
4. Collapse it using weighted random selection
5. Propagate constraints to neighbors
6. Repeat until complete

## Benefits of WFC

✅ **Guaranteed Local Coherence**: Adjacency rules ensure terrain types always make logical sense next to each other

✅ **No Post-Processing Needed**: Unlike pure noise generation, WFC produces clean results without smoothing passes

✅ **Emergent Complexity**: Simple rules create complex, realistic patterns

✅ **Deterministic Constraints**: While randomized, the output always respects defined rules

✅ **Flexible and Extensible**: Easy to add new tile types or modify adjacency rules

✅ **Visually Appealing**: Natural-looking terrain without artifacts or impossible transitions

## Downsides and Limitations

❌ **Performance**: WFC is slower than direct noise-based generation
   - O(n²) or worse complexity due to constraint propagation
   - Larger grids (60×45) can take noticeable time
   - Not suitable for real-time generation during gameplay

❌ **Contradiction Risk**: Poor adjacency rules can cause unsolvable states
   - If a cell's possibilities reduce to zero, generation fails
   - Requires careful rule design to avoid dead ends

❌ **Less Predictable**: Harder to guarantee specific large-scale features
   - Pure noise can ensure "islands" with radial falloff
   - WFC may create unexpected patterns despite weighting

❌ **Memory Overhead**: Storing possibilities for each cell uses more memory
   - Each uncollapsed cell holds an array of potential tiles
   - Grows with grid size and number of tile types

## Things to Consider When Using WFC

### Rule Design
- **Keep adjacency rules symmetric**: If A can be next to B, B should be next to A
- **Avoid impossible constraints**: Ensure every tile type has valid neighbors
- **Test with small grids first**: Find contradictions before scaling up

### Performance Optimization
- **Limit grid size**: Keep under 50×50 for interactive applications
- **Cache calculations**: Store entropy values instead of recalculating
- **Early termination**: Set maximum iteration limits to prevent infinite loops
- **Background generation**: Generate in separate thread or over multiple frames

### Hybrid Approaches
This implementation uses WFC + noise weighting, which:
- Provides WFC's coherence with noise's predictability
- Creates islands reliably while maintaining local correctness
- Balances control and emergence

### When to Use WFC
- **Turn-based strategy maps**: Generation time isn't critical
- **Procedural level design**: Need guaranteed valid layouts
- **Texture synthesis**: Creating coherent patterns from examples
- **Small to medium grids**: Under 3000 cells

### When NOT to Use WFC
- **Real-time terrain generation**: Too slow for on-demand creation
- **Huge worlds**: Use noise/heightmaps instead, WFC for details
- **Simple patterns**: Overkill if basic noise suffices
- **Performance-critical code**: The algorithm is inherently expensive

## Interactive Features

- **Adjustable Grid Size**: Change width (10-60) and height (10-45) with sliders
- **Random Generation**: Each generation creates a unique island with new noise seed
- **Scrollable View**: Navigate large islands with built-in scroll container
- **Real-time Feedback**: Status updates show WFC progress

## Implementation Details

### Files
- **IslandGenerator.gd**: Core WFC algorithm with weighted collapse
- **WaveFunctionCollapse.gd**: UI controller and rendering manager
- **wave_function_collapse.tscn**: Main scene with controls and grid

### Key Functions
- `initialize_wfc()`: Sets up superposition state
- `find_lowest_entropy_cell()`: Selects next cell to collapse
- `collapse_cell()`: Weighted tile selection using noise
- `propagate_constraints()`: Updates neighbors based on adjacency rules
- `generate_full()`: Runs complete WFC loop

## Further Reading

- Original WFC by Maxim Gumin: https://github.com/mxgmn/WaveFunctionCollapse
- WFC Explained: https://robertheaton.com/2018/12/17/wavefunction-collapse-algorithm/
- Constraint Satisfaction Problems in AI
- Procedural Content Generation techniques

## Potential Enhancements

- **Backtracking**: Handle contradictions by reverting previous choices
- **Multi-threading**: Parallelize constraint propagation
- **Progressive rendering**: Show generation in real-time step-by-step
- **Rule learning**: Generate adjacency rules from example maps
- **3D islands**: Extend to volumetric terrain generation
- **Biome blending**: Smooth transitions between distinct regions
