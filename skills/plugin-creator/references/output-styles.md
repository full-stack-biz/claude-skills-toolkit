# Output Styles in Plugins

Output styles allow your plugin to customize how Claude Code displays output. Define styling for command output, notifications, and other UI elements.

## When to Add Output Styles

Add output styles to your plugin when:

- **Customizing command output** - Format results from slash commands
- **Styling notifications** - Customize visual presentation of plugin messages
- **Branding output** - Apply consistent styling across your plugin
- **Improving readability** - Highlight important information in output

## Plugin Structure with Output Styles

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json
├── styles/
│   ├── command-output.css
│   ├── notifications.css
│   └── tables.css
└── commands/
    └── analyze.md
```

## Configuration in plugin.json

Define output style paths in `plugin.json`:

```json
{
  "name": "my-plugin",
  "description": "Plugin with custom output styles",
  "outputStyles": ["./styles/command-output.css", "./styles/notifications.css"]
}
```

Or use a single directory:

```json
{
  "outputStyles": "./styles/"
}
```

## Output Style Files

Create CSS files in your `styles/` directory. Output styles support:

- **Standard CSS properties** - colors, fonts, spacing, borders
- **Claude Code variables** - predefined theme colors and sizes
- **Responsive design** - styles adapt to different pane sizes

Example `styles/command-output.css`:

```css
.plugin-result {
  background-color: var(--claude-bg-secondary);
  border-left: 4px solid var(--claude-accent);
  padding: 12px 16px;
  border-radius: 4px;
  font-family: var(--claude-font-mono);
}

.plugin-result-success {
  color: var(--claude-success);
}

.plugin-result-error {
  color: var(--claude-error);
}

.plugin-result-table {
  width: 100%;
  border-collapse: collapse;
}

.plugin-result-table td {
  padding: 8px;
  border-bottom: 1px solid var(--claude-border);
}
```

## CSS Variables Available

Claude Code provides standard variables for styling:

- **Colors**
  - `--claude-accent` - Primary accent color
  - `--claude-success` - Success indicator color
  - `--claude-error` - Error indicator color
  - `--claude-warning` - Warning indicator color
  - `--claude-bg-primary` - Primary background
  - `--claude-bg-secondary` - Secondary background
  - `--claude-text-primary` - Primary text
  - `--claude-text-secondary` - Secondary text
  - `--claude-border` - Border color

- **Typography**
  - `--claude-font-sans` - Sans-serif font family
  - `--claude-font-mono` - Monospace font family
  - `--claude-font-size-base` - Base font size
  - `--claude-font-size-sm` - Small font size
  - `--claude-font-size-lg` - Large font size

- **Spacing**
  - `--claude-spacing-xs` - Extra small spacing
  - `--claude-spacing-sm` - Small spacing
  - `--claude-spacing-md` - Medium spacing
  - `--claude-spacing-lg` - Large spacing

## Best Practices

1. **Use CSS variables** - Always prefer theme variables over hardcoded colors
2. **Maintain contrast** - Ensure text is readable on both light and dark themes
3. **Responsive design** - Test output across different pane widths
4. **Minimal CSS** - Keep stylesheets lightweight (keep under 50KB total)
5. **Avoid !important** - Let users customize styles in their settings

## Testing Output Styles

Test locally with `--plugin-dir`:

```bash
claude --plugin-dir /path/to/my-plugin
```

Run your plugin commands and verify:
- Output displays with correct styling
- Colors adapt to light/dark theme
- Styles are responsive (resize the pane)
- No performance degradation

## Publishing with Output Styles

Document custom styling in your README:

```markdown
## Styling

This plugin includes custom output styles:

- **Success output** - Green accent with checkmark
- **Error output** - Red accent with alert icon
- **Data tables** - Formatted with alternating row colors
- **Code blocks** - Monospace font with syntax highlighting

Styles automatically adapt to light and dark themes.
```

## Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| Styles not applied | Wrong path in `outputStyles` | Verify path is relative to plugin root, starts with `./` |
| Colors look wrong | Using hardcoded colors | Use CSS variables instead (`var(--claude-accent)`) |
| Text hard to read | Insufficient contrast | Test with light and dark themes, increase contrast |
| Performance issue | Large CSS files | Optimize CSS, keep under 50KB total |
| Styles not updating | CSS caching | Clear Claude Code cache or restart |

## See Also

- [Plugin Manifest Reference](plugin-json-schema.md) - Complete plugin.json schema
- [Claude Code UI Components](about:/docs/en/plugins) - Using Claude Code UI elements in plugins
