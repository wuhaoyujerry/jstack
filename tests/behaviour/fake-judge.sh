# For setup.sh: replace the worker stub with an orca that accepts every call and keeps the spec the judge was started with
# in $W/spec-at-start. A later prompt then gives the judge's report as the user's message.
cat > "$W/bin/orca" <<S
#!/bin/sh
echo "\$*" >> "$ORCA_LOG"
prev=
for a in "\$@"; do
  case "\$a" in --spec-file=*) cp "\${a#--spec-file=}" "$W/spec-at-start" 2>/dev/null ;; esac
  [ "\$prev" = --spec-file ] && cp "\$a" "$W/spec-at-start" 2>/dev/null
  prev="\$a"
done
echo '{"ok":true,"result":{"handle":"term_test","terminal":{"handle":"term_test"}}}'
S
chmod +x "$W/bin/orca"
