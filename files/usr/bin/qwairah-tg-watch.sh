#!/bin/sh
CONF="/etc/qwairah_tg.conf"
STATE_DIR="/tmp/qwairah_mon"
PID_FILE="$STATE_DIR/watch.pid"
STATE_FILE="$STATE_DIR/net_state"
FAIL_FILE="$STATE_DIR/fail_cnt"
mkdir -p "$STATE_DIR"

if [ -f "$PID_FILE" ]; then
  OLD_PID=$(cat "$PID_FILE" 2>/dev/null)
  if [ -n "$OLD_PID" ] && [ "$OLD_PID" != "$$" ] && [ -d "/proc/$OLD_PID" ]; then
    exit 0
  fi
fi
echo "$$" > "$PID_FILE"
[ ! -f "$STATE_FILE" ] && echo "up" > "$STATE_FILE"
echo "0" > "$FAIL_FILE"

while true; do
  sleep 30
  [ -f "$CONF" ] && . "$CONF"
  [ -z "$BOT_TOKEN" ] || [ -z "$CHAT_ID" ] && continue

  if ping -c 2 -W 2 1.1.1.3 >/dev/null 2>&1; then
    echo "0" > "$FAIL_FILE"
    CUR_STATE=$(cat "$STATE_FILE" 2>/dev/null || echo "up")
    if [ "$CUR_STATE" = "down" ]; then
      echo "up" > "$STATE_FILE"
      /usr/bin/qwairah-tg-notify.sh recovered >/dev/null 2>&1
    fi
  else
    FAILS=$(cat "$FAIL_FILE" 2>/dev/null || echo 0)
    case "$FAILS" in ''|*[!0-9]*) FAILS=0 ;; esac
    FAILS=$((FAILS + 1))
    echo "$FAILS" > "$FAIL_FILE"
    CUR_STATE=$(cat "$STATE_FILE" 2>/dev/null || echo "up")
    if [ "$FAILS" -ge 3 ] && [ "$CUR_STATE" != "down" ]; then
      echo "down" > "$STATE_FILE"
      /usr/bin/qwairah-tg-notify.sh net_down "فحص بنج الانترنت 1.1.1.3 (3 محاولات متتالية)" >/dev/null 2>&1
    fi
  fi
done
