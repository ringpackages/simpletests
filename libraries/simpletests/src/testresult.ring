/*
	SimpleTests - Testing Framework Prototype for the Ring Programming Language
*/

class TestResult

	cName         = ""
	nStatus       = TEST_PASS
	cMessage      = ""
	nDuration     = 0
	cSuiteName    = ""
	cGroupName    = ""
	aTags         = []

	func init cTestName
		cName = cTestName
		return self

	func setPass
		nStatus = TEST_PASS

	func setFail cMsg
		nStatus  = TEST_FAIL
		cMessage = cMsg

	func setSkip cMsg
		nStatus  = TEST_SKIP
		cMessage = cMsg

	func setError cMsg
		nStatus  = TEST_ERROR
		cMessage = cMsg

	func setExpectedFail cMsg
		nStatus  = TEST_EXPECTED_FAIL
		cMessage = cMsg

	func isPassed
		if nStatus = TEST_PASS or nStatus = TEST_EXPECTED_FAIL
			return true
		ok
		return false

	func statusSymbol
		if nStatus = TEST_PASS return SYM_PASS ok
		if nStatus = TEST_FAIL return SYM_FAIL ok
		if nStatus = TEST_SKIP return SYM_SKIP ok
		if nStatus = TEST_ERROR return SYM_ERROR ok
		if nStatus = TEST_EXPECTED_FAIL return C_YELLOW + "+" + C_RESET ok
		return "?"

	func statusText
		if nStatus = TEST_PASS return "PASS" ok
		if nStatus = TEST_FAIL return "FAIL" ok
		if nStatus = TEST_SKIP return "SKIP" ok
		if nStatus = TEST_ERROR return "ERROR" ok
		if nStatus = TEST_EXPECTED_FAIL return "XFAIL" ok
		return "UNKNOWN"
