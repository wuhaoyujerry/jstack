# One module whose docstring has a typo: the fix has a check that can be written now, is one unit, and has no reach and no risk.
cat > client.py <<'P'
"""Fetch client.

Callers recieve the body as bytes.
"""
import urllib.request


def fetch(url):
    return urllib.request.urlopen(url).read()
P
git add -A && git_q commit -qm init
