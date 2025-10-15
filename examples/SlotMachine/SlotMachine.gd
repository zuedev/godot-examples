extends Control

@onready var reel1 = $MarginContainer/VBoxContainer/ReelsContainer/Reel1
@onready var reel2 = $MarginContainer/VBoxContainer/ReelsContainer/Reel2
@onready var reel3 = $MarginContainer/VBoxContainer/ReelsContainer/Reel3
@onready var spin_button = $MarginContainer/VBoxContainer/SpinButton
@onready var result_label = $MarginContainer/VBoxContainer/ResultLabel

var reels: Array[Node] = []
var is_spinning: bool = false

func _ready():
	reels = [reel1, reel2, reel3]
	spin_button.pressed.connect(_on_spin_button_pressed)
	result_label.text = "Press SPIN to play!"

func _on_spin_button_pressed():
	if is_spinning:
		return
	
	is_spinning = true
	spin_button.disabled = true
	result_label.text = "Spinning..."
	result_label.modulate = Color.WHITE
	
	# Start all reels spinning
	for reel in reels:
		reel.start_spin()
	
	# Stop each reel with a delay
	await get_tree().create_timer(1.0).timeout
	reel1.stop_spin()
	
	await get_tree().create_timer(0.5).timeout
	reel2.stop_spin()
	
	await get_tree().create_timer(0.5).timeout
	reel3.stop_spin()
	
	# Wait for last reel to finish
	await get_tree().create_timer(0.5).timeout
	
	check_result()
	is_spinning = false
	spin_button.disabled = false

func check_result():
	var symbol1 = reel1.get_current_symbol()
	var symbol2 = reel2.get_current_symbol()
	var symbol3 = reel3.get_current_symbol()
	
	if symbol1 == symbol2 and symbol2 == symbol3:
		result_label.text = "🎉 WINNER! 🎉\n" + symbol1 + " " + symbol2 + " " + symbol3
		result_label.modulate = Color.GOLD
	else:
		result_label.text = "Try Again!\n" + symbol1 + " " + symbol2 + " " + symbol3
		result_label.modulate = Color.WHITE
