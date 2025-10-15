extends Node
class_name BrowserRenderer

## Browser Renderer
## Handles rendering web content using available methods (CEF, WebView, or fallback)

signal page_loaded(url: String)
signal page_loading(url: String, progress: float)
signal page_failed(url: String, error: String)
signal texture_updated(texture: ImageTexture)

var current_url: String = ""
var render_texture: ImageTexture
var cef_browser = null  # Will hold CEF browser instance if available
var use_cef: bool = false

func _ready() -> void:
	# Try to initialize CEF if available
	_initialize_cef()

func _initialize_cef() -> void:
	# Check if CEF GDExtension is available
	# This would work with plugins like:
	# - https://github.com/Delsin-Yu/GDViews.CEFViewport
	# - https://github.com/Lecrapouille/gdcef

	if Engine.has_singleton("CEF"):
		var cef = Engine.get_singleton("CEF")
		if cef and cef.has_method("create_browser"):
			use_cef = true
			print("CEF browser available - using embedded rendering")
			_setup_cef_browser(cef)
			return

	print("CEF not available - using fallback rendering")
	use_cef = false

func _setup_cef_browser(cef) -> void:
	# Create a CEF browser instance
	# The exact API depends on the CEF plugin you're using
	# This is a generic implementation that would need to be adapted

	cef_browser = cef.create_browser(1920, 1080)

	if cef_browser:
		# Connect signals if available
		if cef_browser.has_signal("page_loaded"):
			cef_browser.page_loaded.connect(_on_cef_page_loaded)
		if cef_browser.has_signal("texture_updated"):
			cef_browser.texture_updated.connect(_on_cef_texture_updated)

func load_url(url: String) -> void:
	current_url = url
	page_loading.emit(url, 0.0)

	if use_cef and cef_browser:
		_load_url_cef(url)
	else:
		_load_url_fallback(url)

func _load_url_cef(url: String) -> void:
	# Load URL using CEF
	if cef_browser and cef_browser.has_method("load_url"):
		cef_browser.load_url(url)
	elif cef_browser and cef_browser.has_method("load"):
		cef_browser.load(url)

func _load_url_fallback(url: String) -> void:
	# Fallback: Fetch HTML and render as simple text
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_fallback_request_completed)

	var error = http.request(url)
	if error != OK:
		page_failed.emit(url, "HTTP request failed: " + str(error))

func _on_fallback_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if result == HTTPRequest.RESULT_SUCCESS and response_code == 200:
		var html = body.get_string_from_utf8()
		_render_html_as_image(html)
		page_loaded.emit(current_url)
	else:
		page_failed.emit(current_url, "Failed to load: " + str(response_code))

func _render_html_as_image(html: String) -> void:
	# Use SimpleHTMLRenderer for better rendering
	var renderer = SimpleHTMLRenderer.new()
	add_child(renderer)
	renderer.render_complete.connect(_on_html_rendered)
	renderer.render_html(html)

func _on_html_rendered(texture: ImageTexture) -> void:
	render_texture = texture
	texture_updated.emit(render_texture)

func _on_cef_page_loaded(url: String) -> void:
	page_loaded.emit(url)

func _on_cef_texture_updated(texture: ImageTexture) -> void:
	render_texture = texture
	texture_updated.emit(texture)

func get_texture() -> ImageTexture:
	return render_texture

func execute_javascript(script: String) -> void:
	if use_cef and cef_browser and cef_browser.has_method("execute_javascript"):
		cef_browser.execute_javascript(script)

func go_back() -> void:
	if use_cef and cef_browser and cef_browser.has_method("go_back"):
		cef_browser.go_back()

func go_forward() -> void:
	if use_cef and cef_browser and cef_browser.has_method("go_forward"):
		cef_browser.go_forward()

func reload() -> void:
	if current_url:
		load_url(current_url)

func cleanup() -> void:
	if cef_browser and cef_browser.has_method("close"):
		cef_browser.close()
	cef_browser = null
