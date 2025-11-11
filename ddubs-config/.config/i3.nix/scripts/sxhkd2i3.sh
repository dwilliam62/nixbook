#!/usr/bin/env bash
set -euo pipefail

# sxhkd2i3: Convert sxhkd keybindings to i3 bindsym lines
# Usage: sxhkd2i3.sh <sxhkdrc> <output_i3_binds>
# Notes:
# - Lines beginning with '#' are treated as comments (ignored for binds)
# - A non-indented line defines the key combo; the following indented line defines the command
# - Modifiers mapping: super->$mod, shift->Shift, control->Control, alt->Mod1
# - If the command starts with 'i3-msg ', it is converted to a direct i3 command without exec
# - Otherwise, the command is wrapped as: exec --no-startup-id <cmd>

SRC=${1:?"src sxhkdrc required"}
DST=${2:?"destination binds file required"}

mkdir -p "$(dirname "$DST")"

awk '
  function tr_key(s) {
    gsub(/super/ , "$mod", s)
    gsub(/Super/ , "$mod", s)
    gsub(/shift/ , "Shift", s)
    gsub(/Shift/ , "Shift", s)
    gsub(/control/ , "Control", s)
    gsub(/Control/ , "Control", s)
    gsub(/alt/ , "Mod1", s)
    gsub(/Alt/ , "Mod1", s)
    # collapse spaces around pluses: " + " -> "+"
    gsub(/[[:space:]]*\+[[:space:]]*/, "+", s)
    # collapse multiple spaces elsewhere
    gsub(/[[:space:]]+/, " ", s)
    return s
  }
  BEGIN { key="" }
  /^[[:space:]]*#/ { next }
  /^[[:space:]]*$/ { next }
  # key line: not starting with whitespace
  /^[^ \t]/ { key=$0; next }
  # command line: indented
  /^[ \t]/ && key != "" {
    cmd=$0
    sub(/^[ \t]+/, "", cmd)
    outkey=tr_key(key)
    if (cmd ~ /^i3-msg[ ]+/) {
      sub(/^i3-msg[ ]+/, "", cmd)
      print "bindsym ", outkey, " ", cmd
    } else {
      print "bindsym ", outkey, " exec --no-startup-id ", cmd
    }
    key=""
    next
  }
' "$SRC" > "$DST"

# Basic validation: ensure file contains bindsym lines
if ! grep -q "^bindsym " "$DST"; then
  echo "Warning: no binds generated from $SRC" >&2
fi
