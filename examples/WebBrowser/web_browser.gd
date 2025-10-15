extends Control

# References to UI elements
@onready var url_input: LineEdit = $VBoxContainer/TopBar/URLInput
@onready var status_label: Label = $VBoxContainer/WebView/StatusLabel
@onready var browser_display: TextureRect = $VBoxContainer/WebView/BrowserDisplay
@onready var back_button: Button = $VBoxContainer/TopBar/BackButton
@onready var forward_button: Button = $VBoxContainer/TopBar/ForwardButton
@onready var refresh_button: Button = $VBoxContainer/TopBar/RefreshButton

# Browser renderer instance
var browser_renderer: BrowserRenderer

# History for back/forward navigation
var history: Array[String] = []
var history_index: int = -1
var current_url: String = ""

func _ready() -> void:
	# Initialize browser renderer
	browser_renderer = BrowserRenderer.new()
	add_child(browser_renderer)

	# Connect signals
	browser_renderer.page_loaded.connect(_on_page_loaded)
	browser_renderer.page_loading.connect(_on_page_loading)
	browser_renderer.page_failed.connect(_on_page_failed)
	browser_renderer.texture_updated.connect(_on_texture_updated)

	update_navigation_buttons()
	status_label.text = """Ready to load a website.

In-Game Rendering Active!
This example uses:
- CEF (Chromium Embedded Framework) if available
- Fallback text rendering for HTML content

Click a preset button or enter a URL to view it in-game!"""

func _on_go_button_pressed() -> void:
	var url = url_input.text.strip_edges()
	if url.is_empty():
		status_label.text = "Please enter a URL"
		return

	load_url(url)

func _on_url_input_text_submitted(new_text: String) -> void:
	load_url(new_text.strip_edges())

func _on_google_button_pressed() -> void:
	url_input.text = "https://www.google.com"
	load_url("https://www.google.com")

func _on_github_button_pressed() -> void:
	url_input.text = "https://github.com"
	load_url("https://github.com")

func _on_godot_button_pressed() -> void:
	url_input.text = "https://docs.godotengine.org"
	load_url("https://docs.godotengine.org")

func _on_back_button_pressed() -> void:
	if history_index > 0:
		history_index -= 1
		var url = history[history_index]
		url_input.text = url
		load_url(url, false)
	elif browser_renderer:
		browser_renderer.go_back()

func _on_forward_button_pressed() -> void:
	if history_index < history.size() - 1:
		history_index += 1
		var url = history[history_index]
		url_input.text = url
		load_url(url, false)
	elif browser_renderer:
		browser_renderer.go_forward()

func _on_refresh_button_pressed() -> void:
	if not current_url.is_empty():
		load_url(current_url, false)
	elif browser_renderer:
		browser_renderer.reload()

func load_url(url: String, add_to_history: bool = true) -> void:
	# Ensure URL has a protocol
	if not url.begins_with("http://") and not url.begins_with("https://"):
		url = "https://" + url

	current_url = url
	url_input.text = url

	# Add to history
	if add_to_history:
		# Remove any forward history if we're not at the end
		if history_index < history.size() - 1:
			history.resize(history_index + 1)
		history.append(url)
		history_index = history.size() - 1

	update_navigation_buttons()

	# Hide status label while loading
	status_label.hide()

	# Load URL using browser renderer
	if browser_renderer:
		browser_renderer.load_url(url)

# Browser renderer signal handlers
func _on_page_loading(url: String, progress: float) -> void:
	status_label.show()
	status_label.text = "Loading: " + url + "\nProgress: " + str(int(progress * 100)) + "%"

func _on_page_loaded(url: String) -> void:
	status_label.hide()
	print("Page loaded: " + url)

func _on_page_failed(url: String, error: String) -> void:
	status_label.show()
	status_label.text = "Failed to load: " + url + "\n\nError: " + error

func _on_texture_updated(texture: ImageTexture) -> void:
	if browser_display and texture:
		browser_display.texture = texture
		status_label.hide()

func update_navigation_buttons() -> void:
	back_button.disabled = history_index <= 0
	forward_button.disabled = history_index >= history.size() - 1
	refresh_button.disabled = current_url.is_empty()
