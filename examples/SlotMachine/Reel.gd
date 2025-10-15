extends PanelContainer

@onready var symbol_label = $MarginContainer/SymbolLabel

const SYMBOLS = ["🍒", "🍋", "🍊", "🍇", "💎", "⭐"]
var current_symbol_index: int = 0
var is_spinning: bool = false
var spin_timer: float = 0.0

func _ready():
	randomize()
	current_symbol_index = randi() % SYMBOLS.size()
	symbol_label.text = SYMBOLS[current_symbol_index]

func _process(delta):
	if is_spinning:
		spin_timer += delta
		if spin_timer >= 0.1: # Change symbol every 0.1 seconds
			spin_timer = 0.0
			current_symbol_index = randi() % SYMBOLS.size()
			symbol_label.text = SYMBOLS[current_symbol_index]

func start_spin():
	is_spinning = true
	spin_timer = 0.0

func stop_spin():
	is_spinning = false
	# Pick final random symbol
	current_symbol_index = randi() % SYMBOLS.size()
	symbol_label.text = SYMBOLS[current_symbol_index]

func get_current_symbol() -> String:
	return SYMBOLS[current_symbol_index]
