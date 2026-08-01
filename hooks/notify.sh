#!/bin/sh
# Cursor "stop" hook — sound + toast when the agent finishes.
# https://cursor.com/docs/agent/hooks

if [ "$(uname)" = "Darwin" ]; then
  afplay /System/Library/Sounds/Glass.aiff >/dev/null 2>&1 &

  # Custom toast (bottom-right), no Notification Center
  osascript -l JavaScript "$(dirname "$0")/toast.js" "Agent finished" 2>>/tmp/cursor-toast.err &

elif command -v notify-send >/dev/null 2>&1; then
  notify-send "Cursor" "Agent finished" >/dev/null 2>&1

  if command -v paplay >/dev/null 2>&1 && [ -f /usr/share/sounds/freedesktop/stereo/complete.oga ]; then
    paplay /usr/share/sounds/freedesktop/stereo/complete.oga >/dev/null 2>&1 &
  elif command -v aplay >/dev/null 2>&1 && [ -f /usr/share/sounds/alsa/Front_Center.wav ]; then
    aplay /usr/share/sounds/alsa/Front_Center.wav >/dev/null 2>&1 &
  fi
fi

exit 0
