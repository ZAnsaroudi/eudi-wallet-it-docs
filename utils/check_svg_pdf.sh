#!/bin/bash

# Usa la directory corrente come root del progetto
ROOT="$(pwd)"
DOCS="$ROOT/docs"

found_count=0
not_found_count=0

while IFS=$'\t' read -r fileline ref; do
  file="${fileline%%:*}"
  line="${fileline##*:}"
  rst="$(basename "$file")"
  name="$(basename "$ref")"

  found=0
  for lang in it en; do
    for kind in svg pdf; do
      full_try="$DOCS/$lang/$kind/$name"
      if [ -e "$full_try" ]; then
        found=1
        full="$full_try"
        break 2
      fi
    done
  done

  if [ "$found" -eq 0 ]; then
    rel="${file#$DOCS/}"
    lang="${rel%%/*}"
    ext="${name##*.}"
    full="$DOCS/$lang/images/$ext/$name"
    if [ -e "$full" ]; then
      ((found_count++))
    else
      printf 'NOT-FOUND: %s:%s -> %s\n' "$rst" "$line" "$full"
      ((not_found_count++))
    fi
  else
    ((found_count++))
  fi
done < <(
  grep -R --include='*.rst' -nH -E '\.(svg|pdf)' "$DOCS" \
    | grep -vi 'http' \
    | awk -F: '
      {
        file=$1; line=$2; text="";
        for (i=3; i<=NF; i++) { if (i>3) text=text ":"; text=text $i }
        while (match(text, /[[:graph:]]+\.(svg|pdf)/)) {
          ref=substr(text, RSTART, RLENGTH);
          print file ":" line "\t" ref;
          text=substr(text, RSTART+RLENGTH);
        }
      }
    '
)

printf '\nConteggio:\n'
printf '  Trovati: %d\n' "$found_count"
printf '  Non trovati: %d\n' "$not_found_count"

if [ "$not_found_count" -gt 0 ]; then
  exit 1
fi

exit 0

