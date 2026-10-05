/*
    SimpleTests - Testing Framework Prototype for the Ring Programming Language
*/

# ============================================================
# Constants / Globals
# ============================================================

RINGTEST_VERSION     = "1.0.0"

TEST_PASS            = 1
TEST_FAIL            = 2
TEST_SKIP            = 3
TEST_ERROR           = 4
TEST_EXPECTED_FAIL   = 5

C_RESET   = char(27) + "[0m"
C_RED     = char(27) + "[31m"
C_GREEN   = char(27) + "[32m"
C_YELLOW  = char(27) + "[33m"
C_BLUE    = char(27) + "[34m"
C_MAGENTA = char(27) + "[35m"
C_CYAN    = char(27) + "[36m"
C_WHITE   = char(27) + "[37m"
C_BOLD    = char(27) + "[1m"
C_DIM     = char(27) + "[2m"

SYM_PASS  = C_GREEN  + "+" + C_RESET
SYM_FAIL  = C_RED    + "x" + C_RESET
SYM_SKIP  = C_YELLOW + "o" + C_RESET
SYM_ERROR = C_RED    + "!" + C_RESET
SYM_BENCH = C_CYAN   + "T" + C_RESET

