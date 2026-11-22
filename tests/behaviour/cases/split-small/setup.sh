# The split fixture with another second part: the rename of one private function whose test exists, which would be a trivial dish.
export SLUG=sync-rename ASK='make the nightly sync survive network errors and rename the total formatter'
export GOAL2='The report code names its total formatter clearly.'
export DECISIONS2='- Report: the private function `_fmt` in `report.py` becomes `_format_total`; no behaviour changes.'
export CHECK2='- `python -m pytest tests/test_report.py` passes, and `grep -c _fmt report.py` prints 0.'
. "$(dirname "$0")/../../fixtures/split.sh"
