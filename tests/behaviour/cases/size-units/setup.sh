# One module with a private helper and its test: room for several small units that change no public name and no caller.
mkdir -p tests
printf 'def _clean(s):\n    return s.strip()\n\ndef parse(line):\n    return [_clean(p) for p in line.split(",")]\n' > lineparse.py
printf 'from lineparse import _clean\n\ndef test_clean():\n    assert _clean(" a ") == "a"\n' > tests/test_lineparse.py
printf '__pycache__/\n.pytest_cache/\n' >> .git/info/exclude
git add -A && git_q commit -qm init
