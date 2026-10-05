/*
	SimpleTests - Testing Framework Prototype for the Ring Programming Language
*/

class TestSuite

	cName           = "Default Suite"
	aTests          = []
	aGroups         = []
	aResults        = []

	cBeforeAll      = ""
	cAfterAll       = ""
	cBeforeEach     = ""
	cAfterEach      = ""

	aTags           = []
	aFilterTags     = []
	lSkipAll        = false
	cSkipReason     = ""

	nTotalTests     = 0
	nPassCount      = 0
	nFailCount      = 0
	nSkipCount      = 0
	nErrorCount     = 0
	nXfailCount     = 0
	nTotalDuration  = 0

	cOutputFormat   = "text"
	lVerbose        = true
	lColorEnabled   = true

	# ---- Configuration ----

	func init cSuiteName
		cName = cSuiteName
		return self

	func setVerbose lFlag
		lVerbose = lFlag

	func setColor lFlag
		lColorEnabled = lFlag

	func setOutputFormat cFormat
		cOutputFormat = lower(cFormat)

	func setFilterTags aTagList
		aFilterTags = aTagList

	func skipAllTests cReason
		lSkipAll   = true
		cSkipReason = cReason

	# ---- Hooks ----

	func beforeAll cFunc
		cBeforeAll = cFunc

	func afterAll cFunc
		cAfterAll = cFunc

	func beforeEach cFunc
		cBeforeEach = cFunc

	func afterEach cFunc
		cAfterEach = cFunc

	# ---- Adding Tests ----

	func addTest cName, cFunc
		aTest = [:name = cName, :func = cFunc, :tags = [],
				 :skip = false, :skipMsg = "", :xfail = false,
				 :timeout = 0, :params = []]
		add(aTests, aTest)

	func addTestWithTags cName, cFunc, aTagList
		addTest(cName, cFunc)
		aTests[len(aTests)][:tags] = aTagList

	func addSkippedTest cName, cReason
		aTest = [:name = cName, :func = "", :tags = [],
				 :skip = true, :skipMsg = cReason, :xfail = false,
				 :timeout = 0, :params = []]
		add(aTests, aTest)

	func addExpectedFailure cName, cFunc, cReason
		addTest(cName, cFunc)
		aTests[len(aTests)][:xfail] = true
		aTests[len(aTests)][:skipMsg] = cReason

	func addParameterizedTest cName, cFunc, aParamSets
		for aParams in aParamSets
			cLabel = cName + " [" + ringtest_list2str(aParams) + "]"
			aTest = [:name = cLabel, :func = cFunc, :tags = [],
					 :skip = false, :skipMsg = "", :xfail = false,
					 :timeout = 0, :params = aParams]
			add(aTests, aTest)
		next

	# ---- Test Groups ----

	func addGroup cGroupName, aGroupTests
		aGroup = [:name = cGroupName, :tests = aGroupTests]
		add(aGroups, aGroup)

	# ---- Run ----

	func run
		nStart = clock()

		printHeader()

		if cBeforeAll != ""
			try
				call cBeforeAll()
			catch
				? C_RED + "  beforeAll hook failed: " + cCatchError + C_RESET
			done
		ok

		nTests = len(aTests)
		for i = 1 to nTests
			runSingleTest(aTests[i], "")
		next

		nGroups = len(aGroups)
		for nG = 1 to nGroups
			aGroup = aGroups[nG]
			cGName = aGroup[:name]
			if lVerbose
				? ""
				? C_BOLD + C_CYAN + "  +-- Group: " + cGName + C_RESET
			ok
			aGTests = aGroup[:tests]
			nGTests = len(aGTests)
			for nT = 1 to nGTests
				runSingleTest(aGTests[nT], cGName)
			next
			if lVerbose
				? C_CYAN + "  +---------------" + C_RESET
			ok
		next

		if cAfterAll != ""
			try
				call cAfterAll()
			catch
				? C_RED + "  afterAll hook failed: " + cCatchError + C_RESET
			done
		ok

		nTotalDuration = (clock() - nStart) / clockspersecond()

		printSummary()

		if cOutputFormat = "json"
			printJSONReport()
		ok
		if cOutputFormat = "tap"
			printTAPReport()
		ok

	# ---- Internal: Run a single test ----

	func runSingleTest aTest, cGroup
		nTotalTests++

		oResult = new TestResult(aTest[:name])
		oResult.cSuiteName = cName
		oResult.cGroupName = cGroup

		if lSkipAll
			oResult.setSkip(cSkipReason)
			add(aResults, oResult)
			nSkipCount++
			printResult(oResult, cGroup)
			return
		ok

		if aTest[:skip]
			oResult.setSkip(aTest[:skipMsg])
			add(aResults, oResult)
			nSkipCount++
			printResult(oResult, cGroup)
			return
		ok

		if len(aFilterTags) > 0
			lMatch = false
			for cTag in aFilterTags
				aTestTags = aTest[:tags]
				for cTestTag in aTestTags
					if lower(cTag) = lower(cTestTag)
						lMatch = true
					ok
				next
			next
			if !lMatch
				oResult.setSkip("filtered out by tags")
				add(aResults, oResult)
				nSkipCount++
				if lVerbose
					printResult(oResult, cGroup)
				ok
				return
			ok
		ok

		if cBeforeEach != ""
			try
				call cBeforeEach()
			catch
				oResult.setError("beforeEach failed: " + cCatchError)
				add(aResults, oResult)
				nErrorCount++
				printResult(oResult, cGroup)
				return
			done
		ok

		nTestStart = clock()
		cFuncName  = aTest[:func]
		aTestParams = aTest[:params]
		lIsXfail   = aTest[:xfail]
		cXfailMsg  = aTest[:skipMsg]

		try
			if len(aTestParams) > 0
				call cFuncName(aTestParams)
			else
				call cFuncName()
			ok

			if lIsXfail
				oResult.setFail("Expected failure but test passed: " + cXfailMsg)
				nFailCount++
			else
				oResult.setPass()
				nPassCount++
			ok
		catch
			if lIsXfail
				oResult.setExpectedFail(cXfailMsg + " (" + cCatchError + ")")
				nXfailCount++
				nPassCount++
			else
				oResult.setFail(cCatchError)
				nFailCount++
			ok
		done
		oResult.nDuration = (clock() - nTestStart) / clockspersecond()

		if cAfterEach != ""
			try
				call cAfterEach()
			catch
				? C_YELLOW + "  afterEach hook failed: " + cCatchError + C_RESET
			done
		ok

		add(aResults, oResult)
		printResult(oResult, cGroup)

	# ---- Output Helpers ----

	func printHeader
		? ""
		? C_BOLD + C_MAGENTA + "  ==============================================" + C_RESET
		? C_BOLD + C_MAGENTA + "   RingTest v" + RINGTEST_VERSION + C_RESET
		? C_BOLD + C_MAGENTA + "   Suite: " + cName + C_RESET
		? C_BOLD + C_MAGENTA + "  ==============================================" + C_RESET
		? ""

	func printResult oResult, cGroup
		if !lVerbose return ok

		cIndent = "    "
		if cGroup != ""
			cIndent = "  |   "
		ok

		cTime = ""
		if oResult.nDuration > 0
			cTime = C_DIM + " (" + ringtest_formatDuration(oResult.nDuration) + ")" + C_RESET
		ok

		cLine = cIndent + oResult.statusSymbol() + " " + oResult.cName + cTime

		if oResult.nStatus = TEST_FAIL or oResult.nStatus = TEST_ERROR
			cLine += nl + cIndent + "  " + C_RED + oResult.cMessage + C_RESET
		elseif oResult.nStatus = TEST_SKIP
			cLine += C_DIM + " -- " + oResult.cMessage + C_RESET
		elseif oResult.nStatus = TEST_EXPECTED_FAIL
			cLine += C_DIM + " (expected)" + C_RESET
		ok

		? cLine

	func printSummary
		? ""
		? C_BOLD + "  ==============================================" + C_RESET
		? C_BOLD + "  Results: " + cName + C_RESET
		? C_BOLD + "  ----------------------------------------------" + C_RESET

		cPassLine = C_GREEN + "  Passed:  " + nPassCount
		if nXfailCount > 0
			cPassLine += " (includes " + nXfailCount + " expected failures)"
		ok
		? cPassLine + C_RESET

		if nFailCount > 0
			? C_RED + "  Failed:  " + nFailCount + C_RESET
		else
			? C_DIM + "  Failed:  0" + C_RESET
		ok

		if nErrorCount > 0
			? C_RED + "  Errors:  " + nErrorCount + C_RESET
		else
			? C_DIM + "  Errors:  0" + C_RESET
		ok

		if nSkipCount > 0
			? C_YELLOW + "  Skipped: " + nSkipCount + C_RESET
		else
			? C_DIM + "  Skipped: 0" + C_RESET
		ok

		? C_DIM + "  Total:   " + nTotalTests + C_RESET
		? C_DIM + "  Time:    " + ringtest_formatDuration(nTotalDuration) + C_RESET
		? C_BOLD + "  ==============================================" + C_RESET

		if nFailCount = 0 and nErrorCount = 0
			? ""
			? C_BOLD + C_GREEN + "  * All tests passed! *" + C_RESET
		else
			? ""
			? C_BOLD + C_RED + "  x Some tests failed." + C_RESET
			? ""
			? C_BOLD + C_RED + "  Failed tests:" + C_RESET
			for oRes in aResults
				if oRes.nStatus = TEST_FAIL or oRes.nStatus = TEST_ERROR
					? C_RED + "    - " + oRes.cName + ": " + oRes.cMessage + C_RESET
				ok
			next
		ok
		? ""

	# ---- JSON Report ----

	func printJSONReport
		cJSON = '{' + nl
		cJSON += '  "framework": "RingTest",' + nl
		cJSON += '  "version": "' + RINGTEST_VERSION + '",' + nl
		cJSON += '  "suite": "' + cName + '",' + nl
		cJSON += '  "total": ' + nTotalTests + ',' + nl
		cJSON += '  "passed": ' + nPassCount + ',' + nl
		cJSON += '  "failed": ' + nFailCount + ',' + nl
		cJSON += '  "errors": ' + nErrorCount + ',' + nl
		cJSON += '  "skipped": ' + nSkipCount + ',' + nl
		cJSON += '  "duration": ' + nTotalDuration + ',' + nl
		cJSON += '  "tests": [' + nl
		nResults = len(aResults)
		for i = 1 to nResults
			oRes = aResults[i]
			cJSON += '    {' + nl
			cJSON += '      "name": "' + ringtest_escapeJSON(oRes.cName) + '",' + nl
			cJSON += '      "status": "' + oRes.statusText() + '",' + nl
			cJSON += '      "duration": ' + oRes.nDuration + ',' + nl
			cJSON += '      "message": "' + ringtest_escapeJSON(oRes.cMessage) + '"' + nl
			if i < nResults
				cJSON += '    },' + nl
			else
				cJSON += '    }' + nl
			ok
		next
		cJSON += '  ]' + nl
		cJSON += '}'
		? C_DIM + "  --- JSON Report ---" + C_RESET
		? cJSON

	# ---- TAP Report ----

	func printTAPReport
		? "TAP version 13"
		? "1.." + nTotalTests
		nIdx = 0
		for oRes in aResults
			nIdx++
			if oRes.nStatus = TEST_PASS
				? "ok " + nIdx + " - " + oRes.cName
			elseif oRes.nStatus = TEST_FAIL
				? "not ok " + nIdx + " - " + oRes.cName
				? "  ---"
				? "  message: " + oRes.cMessage
				? "  ..."
			elseif oRes.nStatus = TEST_SKIP
				? "ok " + nIdx + " - " + oRes.cName + " # SKIP " + oRes.cMessage
			elseif oRes.nStatus = TEST_ERROR
				? "not ok " + nIdx + " - " + oRes.cName + " # ERROR"
				? "  ---"
				? "  message: " + oRes.cMessage
				? "  ..."
			elseif oRes.nStatus = TEST_EXPECTED_FAIL
				? "ok " + nIdx + " - " + oRes.cName + " # TODO expected failure"
			ok
		next

