extends Node
class_name SimpleHTMLRenderer

## Simple HTML Renderer
## Renders basic HTML content as text on an image for fallback rendering

const DEFAULT_WIDTH = 1920
const DEFAULT_HEIGHT = 1080
const PADDING = 40
const LINE_HEIGHT = 24
const FONT_SIZE = 16

signal render_complete(texture: ImageTexture)

func render_html(html: String, width: int = DEFAULT_WIDTH, height: int = DEFAULT_HEIGHT) -> void:
	# Extract text content from HTML
	var text_content = _extract_text_from_html(html)

	# Create a viewport to render text
	var viewport = SubViewport.new()
	viewport.size = Vector2i(width, height)
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	viewport.transparent_bg = false

	add_child(viewport)

	# Create a control to hold the rendered content
	var container = Control.new()
	container.set_anchors_preset(Control.PRESET_FULL_RECT)
	viewport.add_child(container)

	# Add background
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(1, 1, 1, 1)  # White background
	container.add_child(bg)

	# Create scroll container for content
	var scroll = ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.set_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, PADDING)
	container.add_child(scroll)

	# Add text label
	var label = RichTextLabel.new()
	label.bbcode_enabled = true
	label.fit_content = true
	label.scroll_active = false
	label.custom_minimum_size = Vector2(width - PADDING * 2, 0)
	label.add_theme_font_size_override("normal_font_size", FONT_SIZE)
	label.add_theme_color_override("default_color", Color(0.1, 0.1, 0.1, 1))

	# Format the text with basic HTML-like formatting
	var formatted_text = _format_text_for_display(text_content)
	label.text = formatted_text

	scroll.add_child(label)

	# Wait for rendering and capture
	await get_tree().process_frame
	await get_tree().process_frame

	# Get the rendered image
	var img = viewport.get_texture().get_image()
	var texture = ImageTexture.create_from_image(img)

	# Clean up
	viewport.queue_free()

	render_complete.emit(texture)

func _extract_text_from_html(html: String) -> String:
	var text = html

	# Remove script and style tags with their content
	var script_regex = RegEx.new()
	script_regex.compile("<script[^>]*>.*?</script>")
	text = script_regex.sub(text, "", true)

	var style_regex = RegEx.new()
	style_regex.compile("<style[^>]*>.*?</style>")
	text = style_regex.sub(text, "", true)

	# Extract title
	var title_regex = RegEx.new()
	title_regex.compile("<title[^>]*>(.*?)</title>")
	var title_match = title_regex.search(text)
	var title = ""
	if title_match:
		title = title_match.get_string(1)

	# Replace heading tags with markers
	var h1_regex = RegEx.new()
	h1_regex.compile("<h1[^>]*>(.*?)</h1>")
	text = h1_regex.sub(text, "[H1]$1[/H1]", true)

	var h2_regex = RegEx.new()
	h2_regex.compile("<h2[^>]*>(.*?)</h2>")
	text = h2_regex.sub(text, "[H2]$1[/H2]", true)

	var h3_regex = RegEx.new()
	h3_regex.compile("<h3[^>]*>(.*?)</h3>")
	text = h3_regex.sub(text, "[H3]$1[/H3]", true)

	# Replace paragraph and br tags
	var p_regex = RegEx.new()
	p_regex.compile("<p[^>]*>")
	text = p_regex.sub(text, "\n\n", true)

	var br_regex = RegEx.new()
	br_regex.compile("<br[^>]*>")
	text = br_regex.sub(text, "\n", true)

	# Replace link tags
	var link_regex = RegEx.new()
	link_regex.compile("<a[^>]*href=['\"]([^'\"]*)['\"][^>]*>(.*?)</a>")
	text = link_regex.sub(text, "[LINK]$2 ($1)[/LINK]", true)

	# Remove all remaining HTML tags
	var tag_regex = RegEx.new()
	tag_regex.compile("<[^>]+>")
	text = tag_regex.sub(text, "", true)

	# Decode common HTML entities
	text = text.replace("&nbsp;", " ")
	text = text.replace("&lt;", "<")
	text = text.replace("&gt;", ">")
	text = text.replace("&amp;", "&")
	text = text.replace("&quot;", "\"")
	text = text.replace("&#39;", "'")
	text = text.replace("&copy;", "©")
	text = text.replace("&reg;", "®")
	text = text.replace("&trade;", "™")

	# Clean up whitespace
	var whitespace_regex = RegEx.new()
	whitespace_regex.compile("[ \\t]+")
	text = whitespace_regex.sub(text, " ", true)

	# Clean up multiple newlines
	var newline_regex = RegEx.new()
	newline_regex.compile("\\n{3,}")
	text = newline_regex.sub(text, "\n\n", true)

	# Add title at the top if found
	if not title.is_empty():
		text = "[TITLE]" + title + "[/TITLE]\n\n" + text

	return text.strip_edges()

func _format_text_for_display(text: String) -> String:
	# Convert our markers to BBCode for RichTextLabel
	var formatted = text

	# Format title
	formatted = formatted.replace("[TITLE]", "[font_size=32][b]")
	formatted = formatted.replace("[/TITLE]", "[/b][/font_size]")

	# Format headings
	formatted = formatted.replace("[H1]", "[font_size=28][b]")
	formatted = formatted.replace("[/H1]", "[/b][/font_size]")

	formatted = formatted.replace("[H2]", "[font_size=24][b]")
	formatted = formatted.replace("[/H2]", "[/b][/font_size]")

	formatted = formatted.replace("[H3]", "[font_size=20][b]")
	formatted = formatted.replace("[/H3]", "[/b][/font_size]")

	# Format links
	formatted = formatted.replace("[LINK]", "[color=#0066cc][u]")
	formatted = formatted.replace("[/LINK]", "[/u][/color]")

	return formatted
