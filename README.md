# discourse-horizon-custom-colors

A Discourse theme component for Horizon that lets users customize their interface
colors by pasting a string of hex values, similar to Slack's theme feature.

## Features

- User-specific colors (each user has their own)
- Simple hex string input (e.g., `#f8f8f2 #282a36 #bd93f9 #282a36 #f8f8f2 #f1fa8c`)
- Live preview swatches
- Colors apply immediately and persist across sessions
- Optimized for Horizon theme with unified header/sidebar/content backgrounds

## Color Order

1. Primary (text color)
2. Secondary (background - used for header, sidebar, and content)
3. Tertiary (accent color for links, buttons)
4. (unused - kept for compatibility)
5. (unused - kept for compatibility)
6. Highlight (selection highlight color)

Note: This component uses a unified background approach like Horizon, so positions
4 and 5 are ignored. The secondary color is used for header, sidebar, and main
content backgrounds.

## Installation

1. Go to Admin > Customize > Themes
2. Click "Install" and enter the GitHub URL
3. Add the component to your active Horizon theme

## Required Setup

For user custom fields to work, add `custom_color_string` to the site setting:

1. Go to Admin > Settings
2. Search for `public user custom fields`
3. Add `custom_color_string` to the list

## Usage

1. Users go to Preferences > Interface
2. Find "Horizon Custom Colors" section
3. Paste hex colors separated by spaces
4. Click Save

## Example Color Strings

Dracula:
```
#f8f8f2 #282a36 #bd93f9 #282a36 #f8f8f2 #f1fa8c
```

Nord:
```
#eceff4 #2e3440 #88c0d0 #2e3440 #eceff4 #ebcb8b
```

Catppuccin Mocha:
```
#cdd6f4 #1e1e2e #cba6f7 #1e1e2e #cdd6f4 #f9e2af
```

Tokyo Night:
```
#c0caf5 #1a1b26 #7aa2f7 #1a1b26 #c0caf5 #e0af68
```

Solarized Dark:
```
#839496 #002b36 #268bd2 #002b36 #839496 #b58900
```

Gruvbox Dark:
```
#ebdbb2 #282828 #458588 #282828 #ebdbb2 #d79921
```
