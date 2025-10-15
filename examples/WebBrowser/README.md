# Web Browser Example for Godot 4

This example demonstrates **in-game web browser rendering** in Godot 4, displaying live websites like Google, GitHub, and more directly within your game.

## Overview

This example provides a working in-game web browser with multiple rendering approaches:

1. **CEF Integration** - Full Chromium browser rendering (when CEF GDExtension is installed)
2. **Fallback HTML Renderer** - Text-based rendering for basic HTML content viewing
3. **Browser UI** - Complete browser interface with navigation, history, and URL input

## Features

- **In-Game Website Rendering** - View websites directly in your game window
- **Full Browser UI** - URL input, back/forward/refresh buttons
- **Quick-Access Buttons** - One-click access to Google, GitHub, Godot Docs
- **History Management** - Full browsing history with back/forward navigation
- **Automatic Fallback** - Uses CEF if available, falls back to text rendering otherwise
- **Real-Time Content** - Fetches and displays live web content

## How It Works

The example uses a modular architecture with three main components:

### 1. BrowserRenderer (browser_renderer.gd)
Handles the core rendering logic and automatically selects the best available method:

```gdscript
# Checks for CEF availability
if Engine.has_singleton("CEF"):
    # Use CEF for full browser rendering
else:
    # Use fallback HTML text renderer
```

### 2. SimpleHTMLRenderer (simple_html_renderer.gd)
Provides fallback rendering when CEF is not available:

- Fetches HTML content via HTTPRequest
- Parses HTML structure (headings, links, paragraphs)
- Renders text content using SubViewport and RichTextLabel
- Converts to texture for in-game display

### 3. Main Browser UI (web_browser.gd)
Provides the user interface and navigation:

```gdscript
# Initialize renderer
browser_renderer = BrowserRenderer.new()

# Load URL
browser_renderer.load_url("https://www.google.com")

# Receive rendered texture
func _on_texture_updated(texture: ImageTexture):
    browser_display.texture = texture
```

## Usage

### Basic Usage (Fallback Renderer)

1. Open the project in Godot 4.6+
2. Run the main scene (F5)
3. Click a preset button or enter a URL
4. The website content will render in-game using the fallback text renderer

The fallback renderer works out of the box and displays:
- Page titles and headings with proper formatting
- Text content with paragraph structure
- Links with URLs
- Real-time fetched content from live websites

### Advanced Usage (CEF for Full Rendering)

For full browser capabilities with HTML/CSS/JavaScript, install a CEF plugin:

#### Option 1: GDViews.CEFViewport
```
1. Download from: https://github.com/Delsin-Yu/GDViews.CEFViewport
2. Follow installation instructions
3. Restart Godot
4. The example will automatically detect and use CEF
```

#### Option 2: gdcef
```
1. Download from: https://github.com/Lecrapouille/gdcef
2. Install the GDExtension
3. Configure in your project
4. The example will automatically switch to CEF rendering
```

When CEF is detected, you get:
- Full HTML5/CSS3 rendering
- JavaScript execution
- Interactive web pages
- Video and audio playback
- WebGL support

## Controls

- **URL Input Field**: Type any URL and press Enter or click "Go"
- **Back/Forward Buttons**: Navigate through browsing history
- **Refresh Button**: Reload the current page
- **Preset Buttons**: Quick access to Google, GitHub, Godot Docs

## Requirements

- **Godot 4.6** or later
- **Internet connection** for fetching web content
- **Optional**: CEF GDExtension for full browser rendering

## Architecture

### File Structure
```
WebBrowser/
├── main.tscn                    # Main scene with UI layout
├── web_browser.gd               # Main controller script
├── browser_renderer.gd          # Browser rendering manager
├── simple_html_renderer.gd      # Fallback HTML text renderer
├── project.godot                # Project configuration
└── README.md                    # This file
```

### Key Classes

**BrowserRenderer**: Manages rendering backend selection
- Auto-detects CEF availability
- Routes to appropriate renderer
- Emits signals for page events

**SimpleHTMLRenderer**: Fallback text-based renderer
- Parses HTML structure
- Extracts text content with formatting
- Renders to texture using SubViewport

**WebBrowser**: Main UI controller
- Handles user input
- Manages navigation history
- Updates display with rendered content

## Current Limitations

### Fallback Renderer
- Text-only rendering (no images, CSS, or JavaScript)
- Limited HTML tag support (headings, paragraphs, links)
- Some websites may block requests due to CORS
- No interactive elements

### CEF Renderer (when installed)
- Requires external plugin installation
- Larger memory footprint
- Desktop platforms only (Windows, macOS, Linux)
- Requires additional setup

## Extending This Example

Ideas for enhancement:

1. **Add Image Support** - Download and display images from HTML
2. **Implement Bookmarks** - Save and organize favorite sites
3. **Download Manager** - Handle file downloads
4. **Custom Protocol Handlers** - Support game:// or custom URLs
5. **Cookie Management** - Persist session data
6. **Form Input** - Enable interaction with web forms
7. **Tab System** - Multiple browser tabs
8. **Search Engine Integration** - Quick search from URL bar

## License

This example is part of the godot-examples repository and is available under the same license as the repository.
