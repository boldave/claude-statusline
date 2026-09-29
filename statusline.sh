#!/bin/bash
# AI Statusline — PAI-inspired for Claude Code
# Requires: jq, git, bash
#
# Color themes:
#   monokai (default), dracula, nord, gruvbox, solarized, catppuccin,
#   tokyo-night, one-dark, rose-pine, cyberpunk
#
# Change theme:
#   echo "dracula" > ~/.claude/statusline_theme
# or temporarily:
#   CC_THEME=nord claude
#
# Header templates:
#   rghtON (default), box, neon, cyberpunk, retro, minimal
#
# Change template:
#   echo "box" > ~/.claude/statusline_template
# or temporarily:
#   CC_TEMPLATE=neon claude

INPUT=$(cat)

# ── Parse JSON ──────────────────────────────────────────────────────────────
MODEL=$(echo "$INPUT" | jq -r '.model.display_name // "Unknown"')
VERSION=$(echo "$INPUT" | jq -r '.version // "?"')
CWD=$(echo "$INPUT" | jq -r '.workspace.current_dir // "."')
PCT=$(echo "$INPUT" | jq -r '.context_window.used_percentage // 0' | awk '{printf "%d", $1}')
COST=$(echo "$INPUT" | jq -r '.cost.total_cost_usd // 0')
DUR_MS=$(echo "$INPUT" | jq -r '.cost.total_duration_ms // 0')
API_MS=$(echo "$INPUT" | jq -r '.cost.total_api_duration_ms // 0')
L_ADD=$(echo "$INPUT" | jq -r '.cost.total_lines_added // 0')
L_REM=$(echo "$INPUT" | jq -r '.cost.total_lines_removed // 0')
VIM_MODE=$(echo "$INPUT" | jq -r '.vim.mode // ""')
EFFORT=$(echo "$INPUT" | jq -r '.effort.level // ""')

# ── Usage limits (5h / 7d / spend) ───────────────────────────────────────────
RL_5H=$(echo "$INPUT" | jq -r '.rate_limits.five_hour.used_percentage // empty')
RL_5H_RESET=$(echo "$INPUT" | jq -r '.rate_limits.five_hour.resets_at // empty')
RL_7D=$(echo "$INPUT" | jq -r '.rate_limits.seven_day.used_percentage // empty')
RL_7D_RESET=$(echo "$INPUT" | jq -r '.rate_limits.seven_day.resets_at // empty')
RL_SPEND=$(echo "$INPUT" | jq -r '.rate_limits.spend_limit.used_percentage // empty')
RL_SPEND_RESET=$(echo "$INPUT" | jq -r '.rate_limits.spend_limit.resets_at // empty')

# ── Theme selection ───────────────────────────────────────────────────────────
THEME_FILE="$HOME/.claude/statusline_theme"
THEME="${CC_THEME:-}"
[ -z "$THEME" ] && [ -f "$THEME_FILE" ] && THEME=$(cat "$THEME_FILE" | tr -d '[:space:]')
[ -z "$THEME" ] && THEME="monokai"

# ── Template selection ────────────────────────────────────────────────────────
TMPL_FILE="$HOME/.claude/statusline_template"
TMPL="${CC_TEMPLATE:-}"
[ -z "$TMPL" ] && [ -f "$TMPL_FILE" ] && TMPL=$(cat "$TMPL_FILE" | tr -d '[:space:]')
[ -z "$TMPL" ] && TMPL="rghtON"

R='\033[0m'
BD='\033[1m'

case "$THEME" in
  dracula)
    # https://draculatheme.com/contribute
    PINK='\033[38;2;255;121;198m'    # #ff79c6  header
    YELLOW='\033[38;2;241;250;140m'  # #f1fa8c  czas
    GREEN='\033[38;2;80;250;123m'    # #50fa7b  katalog / sync
    CYAN='\033[38;2;139;233;253m'    # #8be9fd  branch
    ORANGE='\033[38;2;255;184;108m'  # #ffb86c  koszt
    RED='\033[38;2;255;85;85m'       # #ff5555  błędy
    PURPLE='\033[38;2;189;147;249m'  # #bd93f9  vim mode
    DIM='\033[38;2;98;114;164m'      # #6272a4  separatory
    ;;
  nord)
    # https://www.nordtheme.com/docs/colors-and-palettes
    PINK='\033[38;2;180;142;173m'    # #b48ead  header
    YELLOW='\033[38;2;235;203;139m'  # #ebcb8b  czas
    GREEN='\033[38;2;163;190;140m'   # #a3be8c  katalog / sync
    CYAN='\033[38;2;136;192;208m'    # #88c0d0  branch
    ORANGE='\033[38;2;208;135;112m'  # #d08770  koszt
    RED='\033[38;2;191;97;106m'      # #bf616a  błędy
    PURPLE='\033[38;2;180;142;173m'  # #b48ead  vim mode
    DIM='\033[38;2;76;86;106m'       # #4c566a  separatory
    ;;
  gruvbox)
    # https://github.com/morhetz/gruvbox
    PINK='\033[38;2;251;73;52m'      # #fb4934  header
    YELLOW='\033[38;2;250;189;47m'   # #fabd2f  czas
    GREEN='\033[38;2;184;187;38m'    # #b8bb26  katalog / sync
    CYAN='\033[38;2;142;192;124m'    # #8ec07c  branch
    ORANGE='\033[38;2;254;128;25m'   # #fe8019  koszt
    RED='\033[38;2;251;73;52m'       # #fb4934  błędy
    PURPLE='\033[38;2;211;134;155m'  # #d3869b  vim mode
    DIM='\033[38;2;146;131;116m'     # #928374  separatory
    ;;
  solarized)
    # https://ethanschoonover.com/solarized/
    PINK='\033[38;2;211;54;130m'     # #d33682  header
    YELLOW='\033[38;2;181;137;0m'    # #b58900  czas
    GREEN='\033[38;2;133;153;0m'     # #859900  katalog / sync
    CYAN='\033[38;2;42;161;152m'     # #2aa198  branch
    ORANGE='\033[38;2;203;75;22m'    # #cb4b16  koszt
    RED='\033[38;2;220;50;47m'       # #dc322f  błędy
    PURPLE='\033[38;2;108;113;196m'  # #6c71c4  vim mode
    DIM='\033[38;2;88;110;117m'      # #586e75  separatory
    ;;
  catppuccin)
    # https://github.com/catppuccin/catppuccin (Mocha)
    PINK='\033[38;2;203;166;247m'    # #cba6f7  mauve — header
    YELLOW='\033[38;2;249;226;175m'  # #f9e2af  yellow
    GREEN='\033[38;2;166;227;161m'   # #a6e3a1  green
    CYAN='\033[38;2;137;220;235m'    # #89dceb  sky
    ORANGE='\033[38;2;250;179;135m'  # #fab387  peach
    RED='\033[38;2;243;139;168m'     # #f38ba8  red
    PURPLE='\033[38;2;180;190;254m'  # #b4befe  lavender
    DIM='\033[38;2;108;112;134m'     # #6c7086  overlay
    ;;
  tokyo-night)
    # https://github.com/enkia/tokyo-night-vscode-theme
    PINK='\033[38;2;187;154;247m'    # #bb9af7  header
    YELLOW='\033[38;2;224;175;104m'  # #e0af68  yellow
    GREEN='\033[38;2;158;206;106m'   # #9ece6a  green
    CYAN='\033[38;2;125;207;255m'    # #7dcfff  cyan
    ORANGE='\033[38;2;255;158;100m'  # #ff9e64  orange
    RED='\033[38;2;247;118;142m'     # #f7768e  red
    PURPLE='\033[38;2;187;154;247m'  # #bb9af7  purple
    DIM='\033[38;2;86;95;137m'       # #565f89  dim
    ;;
  one-dark)
    # https://github.com/atom/atom (One Dark)
    PINK='\033[38;2;198;120;221m'    # #c678dd  header
    YELLOW='\033[38;2;229;192;123m'  # #e5c07b  yellow
    GREEN='\033[38;2;152;195;121m'   # #98c379  green
    CYAN='\033[38;2;86;182;194m'     # #56b6c2  cyan
    ORANGE='\033[38;2;209;154;102m'  # #d19a66  orange
    RED='\033[38;2;224;108;117m'     # #e06c75  red
    PURPLE='\033[38;2;198;120;221m'  # #c678dd  purple
    DIM='\033[38;2;92;99;112m'       # #5c6370  dim
    ;;
  rose-pine)
    # https://rosepinetheme.com (Main)
    PINK='\033[38;2;235;188;186m'    # #ebbcba  rose — header
    YELLOW='\033[38;2;246;193;119m'  # #f6c177  gold
    GREEN='\033[38;2;156;207;216m'   # #9ccfd8  foam
    CYAN='\033[38;2;156;207;216m'    # #9ccfd8  foam
    ORANGE='\033[38;2;246;193;119m'  # #f6c177  gold
    RED='\033[38;2;235;111;146m'     # #eb6f92  love
    PURPLE='\033[38;2;196;167;231m'  # #c4a7e7  iris
    DIM='\033[38;2;110;106;134m'     # #6e6a86  muted
    ;;
  cyberpunk)
    # Neon cyberpunk palette
    PINK='\033[38;2;255;0;124m'      # #ff007c  hot pink — header
    YELLOW='\033[38;2;243;249;157m'  # #f3f99d  neon yellow
    GREEN='\033[38;2;90;247;142m'    # #5af78e  neon green
    CYAN='\033[38;2;87;199;255m'     # #57c7ff  neon blue
    ORANGE='\033[38;2;255;108;193m'  # #ff6cc1  pink-orange
    RED='\033[38;2;255;92;87m'       # #ff5c57  neon red
    PURPLE='\033[38;2;157;101;255m'  # #9d65ff  electric purple
    DIM='\033[38;2;104;104;104m'     # #686868  dim
    ;;
  monokai|*)
    # Monokai Pro (domyślny)
    PINK='\033[38;2;255;97;136m'     # #ff6188  header
    YELLOW='\033[38;2;255;216;102m'  # #ffd866  czas
    GREEN='\033[38;2;169;220;118m'   # #a9dc76  katalog / sync
    CYAN='\033[38;2;120;220;232m'    # #78dce8  branch
    ORANGE='\033[38;2;252;152;103m'  # #fc9867  koszt
    RED='\033[38;2;255;85;85m'       # #ff5555  błędy
    PURPLE='\033[38;2;171;157;242m'  # #ab9df2  vim mode
    DIM='\033[38;2;117;113;94m'      # #75715e  separatory
    ;;
esac

BLUE='\033[38;2;97;175;239m'  # #6197ef  directory path

S="${DIM}│${R}"  # separator

# ── rghtON: per-letter color + shimmer animation ──────────────────────────────
build_rghtON() {
  local text="rghtON"
  local ms; ms=$(date +%3N)
  local shimmer_pos=$(( (ms / 150) % 6 ))

  # Cyberpunk neon colors, one per letter
  local c0='\033[38;2;255;0;124m'    # r — hot pink
  local c1='\033[38;2;90;247;142m'   # g — neon green
  local c2='\033[38;2;87;199;255m'   # h — neon blue
  local c3='\033[38;2;243;249;157m'  # t — neon yellow
  local c4='\033[38;2;157;101;255m'  # O — electric purple
  local c5='\033[38;2;255;108;193m'  # N — pink-orange
  local shimmer='\033[38;2;255;255;255m\033[1m'  # bright white bold flash

  local colors=("$c0" "$c1" "$c2" "$c3" "$c4" "$c5")
  local result=""
  local i
  for i in 0 1 2 3 4 5; do
    local char="${text:$i:1}"
    if [ "$i" -eq "$shimmer_pos" ]; then
      result="${result}${shimmer}${char}${R}"
    else
      result="${result}${colors[$i]}${char}${R}"
    fi
  done
  echo -n "$result"
}

# ── Vim mode indicator ───────────────────────────────────────────────────────
VIM=""
case "$VIM_MODE" in
  NORMAL) VIM=" ${PURPLE}[NRM]${R}" ;;
  INSERT) VIM=" ${CYAN}[INS]${R}" ;;
esac

# ── Effort level indicator ───────────────────────────────────────────────────
EFFORT_LABEL=""
[ -n "$EFFORT" ] && EFFORT_LABEL=" ${DIM}(${ORANGE}${EFFORT}${DIM})${R}"

# ── Context bar (48 chars) ───────────────────────────────────────────────────
BAR_W=48
FILL=$(( PCT * BAR_W / 100 ))
[ "$FILL" -gt "$BAR_W" ] && FILL=$BAR_W
EMPTY=$(( BAR_W - FILL ))

if   [ "$PCT" -ge 90 ]; then BC="$RED"
elif [ "$PCT" -ge 70 ]; then BC="$ORANGE"
elif [ "$PCT" -ge 50 ]; then BC="$YELLOW"
else                         BC="$GREEN"; fi

BAR=""
i=0; while [ $i -lt $FILL ];  do BAR="${BAR}▰"; i=$((i+1)); done
i=0; while [ $i -lt $EMPTY ]; do BAR="${BAR}▱"; i=$((i+1)); done

# ── Git info (cached 5s for performance) ────────────────────────────────────
GIT_CACHE="/tmp/cc_statusline_git_$(echo -n "$CWD" | cksum | cut -d' ' -f1)"
STALE=1
if [ -f "$GIT_CACHE" ]; then
  CACHE_AGE=$(( $(date +%s) - $(stat -c %Y "$GIT_CACHE" 2>/dev/null || echo 0) ))
  [ "$CACHE_AGE" -le 5 ] && STALE=0
fi

if [ "$STALE" = "1" ]; then
  if git -C "$CWD" rev-parse --git-dir >/dev/null 2>&1; then
    BR=$(git -C "$CWD" branch --show-current 2>/dev/null)
    MOD=$(git -C "$CWD" diff --numstat 2>/dev/null | wc -l | tr -d ' ')
    STG=$(git -C "$CWD" diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
    AHD=$(git -C "$CWD" rev-list @{u}..HEAD 2>/dev/null | wc -l | tr -d ' ')
    BHD=$(git -C "$CWD" rev-list HEAD..@{u} 2>/dev/null | wc -l | tr -d ' ')
    CMT_AGE=$(git -C "$CWD" log -1 --format="%ar" 2>/dev/null | sed 's/ ago//')
    printf "git|%s|%s|%s|%s|%s|%s\n" \
      "$BR" "$MOD" "$STG" "${AHD:-0}" "${BHD:-0}" "$CMT_AGE" > "$GIT_CACHE"
  else
    echo "no" > "$GIT_CACHE"
  fi
fi

GIT_BRANCH_SUFFIX=""
if [ -f "$GIT_CACHE" ] && [ "$(head -c 1 "$GIT_CACHE")" = "g" ]; then
  IFS='|' read -r _ BR MOD STG AHD BHD CMT_AGE < "$GIT_CACHE"
  DIRTY=""
  [ "${MOD:-0}" -gt 0 ] || [ "${STG:-0}" -gt 0 ] && DIRTY="${YELLOW}*${R}"
  GIT_BRANCH_SUFFIX="  ${DIM}${S}${R}  ${CYAN} ${BR}${R}${DIRTY}"
fi

# ── Timing & cost ────────────────────────────────────────────────────────────
MINS=$(( DUR_MS / 60000 ))
SECS=$(( (DUR_MS % 60000) / 1000 ))
AMINS=$(( API_MS / 60000 ))
ASECS=$(( (API_MS % 60000) / 1000 ))
COST_FMT=$(awk "BEGIN{printf \"%.4f\", $COST}" 2>/dev/null || echo "0.0000")

# ── Print status lines ───────────────────────────────────────────────────────

# Header template
case "$TMPL" in
  smootH)
    echo -e "${DIM}__///${R}${BD}${PINK}AI STATUSLINE CC${R} ${DIM}v${VERSION}${R} ${DIM}______________________________________${R} ${YELLOW}${MODEL}${R}${EFFORT_LABEL}${VIM}"
    ;;
  rghtON|*)
    RGHTON=$(build_rghtON)
    echo -e "\033[38;2;255;85;85m/\033[38;2;255;152;103m/\033[38;2;255;216;102m/\033[38;2;169;220;118m/\033[38;2;120;220;232m/\033[38;2;171;157;242m/${R} ${BD}${RED}CC·${VERSION}·${RGHTON}·STATUSLINE${R} ${DIM}____________________________________${R} ${YELLOW}${MODEL}${R}${EFFORT_LABEL}${VIM}"
    ;;
esac

# Line 2: Directory (+ git branch, if inside a repo)
DISPLAY_PATH="${CWD/#$HOME/\~}"
echo -e "  ${DIM}📂${R} ${BLUE}${DISPLAY_PATH}${R}${GIT_BRANCH_SUFFIX}"

# Line 3: Context bar
echo -e "  📊 ${BD}${DIM}CONTEXT:${R} ${BC}${BAR}${R} ${BD}${BC}${PCT}%${R}"

# ── Line 6: Usage limits (5h / 7d / spend) ──────────────────────────────────
# Timezone for reset times: $TZ env, else ~/.claude/statusline_timezone, else Europe/Warsaw
TZ_FILE="$HOME/.claude/statusline_timezone"
DISPLAY_TZ="${TZ:-}"
[ -z "$DISPLAY_TZ" ] && [ -f "$TZ_FILE" ] && DISPLAY_TZ=$(cat "$TZ_FILE" | tr -d '[:space:]')
[ -z "$DISPLAY_TZ" ] && DISPLAY_TZ="Europe/Warsaw"

fmt_reset_time() {
  local ts="$1"
  [ -z "$ts" ] && return
  TZ="$DISPLAY_TZ" date -d "@$ts" "+%H:%M" 2>/dev/null
}

fmt_reset_daytime() {
  local ts="$1"
  [ -z "$ts" ] && return
  TZ="$DISPLAY_TZ" date -d "@$ts" "+%a %H:%M" 2>/dev/null
}

pct_color() {
  local p="$1"
  local pi; pi=$(awk "BEGIN{printf \"%d\", $p}")
  if   [ "$pi" -ge 90 ]; then echo "$RED"
  elif [ "$pi" -ge 70 ]; then echo "$ORANGE"
  elif [ "$pi" -ge 50 ]; then echo "$YELLOW"
  else                        echo "$GREEN"; fi
}

USAGE_PARTS=()

if [ -n "$RL_5H" ]; then
  C=$(pct_color "$RL_5H")
  RS=$(fmt_reset_time "$RL_5H_RESET")
  P=$(awk "BEGIN{printf \"%.0f\", $RL_5H}")
  USAGE_PARTS+=("${DIM}session(5h):${R}${C}${P}%${R}${DIM}(reset ${RS})${R}")
fi

if [ -n "$RL_7D" ]; then
  C=$(pct_color "$RL_7D")
  RS=$(fmt_reset_daytime "$RL_7D_RESET")
  P=$(awk "BEGIN{printf \"%.0f\", $RL_7D}")
  USAGE_PARTS+=("${DIM}weekly(7d):${R}${C}${P}%${R}${DIM}(reset ${RS})${R}")
fi

if [ -n "$RL_SPEND" ]; then
  C=$(pct_color "$RL_SPEND")
  RS=$(fmt_reset_daytime "$RL_SPEND_RESET")
  P=$(awk "BEGIN{printf \"%.0f\", $RL_SPEND}")
  USAGE_PARTS+=("${DIM}usage credit:${R}${C}${P}%${R}${DIM}(reset ${RS})${R}")
fi

if [ "${#USAGE_PARTS[@]}" -gt 0 ]; then
  LINE="  ${DIM}⏳ LIMITS:${R} "
  for idx in "${!USAGE_PARTS[@]}"; do
    [ "$idx" -gt 0 ] && LINE="${LINE} ${S} "
    LINE="${LINE}${USAGE_PARTS[$idx]}"
  done
  echo -e "$LINE"
fi

exit 0
