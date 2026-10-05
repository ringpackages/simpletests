/*
	SimpleTests - Testing Framework Prototype for the Ring Programming Language
*/

class TestResult

	name         = ""
	status       = TEST_PASS
	message      = ""
	duration     = 0
	suiteName    = ""
	groupName    = ""
	tags         = []

	func init cName
		name = cName
		return self

	func setPass
		status = TEST_PASS

	func setFail cMsg
		status  = TEST_FAIL
		message = cMsg

	func setSkip cMsg
		status  = TEST_SKIP
		message = cMsg

	func setError cMsg
		status  = TEST_ERROR
		message = cMsg

	func setExpectedFail cMsg
		status  = TEST_EXPECTED_FAIL
		message = cMsg

	func isPassed
		if status = TEST_PASS or status = TEST_EXPECTED_FAIL
			return true
		ok
		return false

	func statusSymbol
		if status = TEST_PASS return SYM_PASS ok
		if status = TEST_FAIL return SYM_FAIL ok
		if status = TEST_SKIP return SYM_SKIP ok
		if status = TEST_ERROR return SYM_ERROR ok
		if status = TEST_EXPECTED_FAIL return C_YELLOW + "+" + C_RESET ok
		return "?"

	func statusText
		if status = TEST_PASS return "PASS" ok
		if status = TEST_FAIL return "FAIL" ok
		if status = TEST_SKIP return "SKIP" ok
		if status = TEST_ERROR return "ERROR" ok
		if status = TEST_EXPECTED_FAIL return "XFAIL" ok
		return "UNKNOWN"
