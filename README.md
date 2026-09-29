# claude-statusline

A multi-line status line for [Claude Code](https://claude.com/claude-code), with
themes, a context-usage bar, git state and rate-limit tracking.

```
////// CC·2.0.1·rghtON·STATUSLINE ____________________ Opus 5 (high)
  📂 ~/dev/my-project  │   main*
  📊 CONTEXT: ▰▰▰▰▰▰▰▰▰▰▰▱▱▱▱▱▱▱▱▱▱▱▱▱▱▱▱▱▱▱▱▱▱▱▱▱▱▱▱▱▱▱▱▱ 23%
  ⏳ LIMITS: session(5h):41%(reset 18:30) │ weekly(7d):12%(reset Mon 09:00)
```

## What it shows

- **Model**, Claude Code version, effort level and vim mode
- **Working directory**, git branch, and a `*` marker when the tree is dirty
- **Context usage** as a 48-cell bar that shifts green → yellow → orange → red
- **Rate limits**: 5-hour session, 7-day window and spend limit, each with its
  reset time

## Requirements

`bash`, `jq`, `git`. A terminal with truecolor support.

## Install

```bash
git clone https://github.com/boldave/claude-statusline.git
chmod +x claude-statusline/statusline.sh
```

Then point Claude Code at it in `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "/absolute/path/to/statusline.sh"
  }
}
```

## Themes

`monokai` (default), `dracula`, `nord`, `gruvbox`, `solarized`, `catppuccin`,
`tokyo-night`, `one-dark`, `rose-pine`, `cyberpunk`.

```bash
echo "dracula" > ~/.claude/statusline_theme   # persistent
CC_THEME=nord claude                          # one-off
```

## Header templates

`rghtON` (default, animated) and `smootH`.

```bash
echo "smootH" > ~/.claude/statusline_template
CC_TEMPLATE=smootH claude
```

## Timezone

Reset times render in `Europe/Warsaw` unless told otherwise:

```bash
echo "America/New_York" > ~/.claude/statusline_timezone
```

`$TZ` takes precedence over that file.

## Notes

Git state is cached for 5 seconds in `/tmp`, so the status line stays responsive
in large repositories.

Inspired by PAI.
