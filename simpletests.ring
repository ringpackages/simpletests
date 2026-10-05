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


# ============================================================
# FUNCTIONS
# ============================================================

func ringtest_list2str aList
    cResult = ""
    for i = 1 to len(aList)
        if isString(aList[i])
            cResult += '"' + aList[i] + '"'
        elseif isNumber(aList[i])
            cResult += "" + aList[i]
        else
            cResult += "?"
        ok
        if i < len(aList)
            cResult += ", "
        ok
    next
    return cResult

func ringtest_str value
    if isString(value) return '"' + value + '"' ok
    if isNumber(value) return "" + value ok
    if isList(value) return ringtest_list2str(value) ok
    if isNULL(value) return "NULL" ok
    return "(unknown)"

func ringtest_fabs n
    if n < 0 return -n ok
    return n

func ringtest_padRight cStr, nLen
    cResult = cStr
    while len(cResult) < nLen
        cResult += " "
    end
    return cResult

func ringtest_escapeJSON cStr
    cStr = substr(cStr, '"', '\"')
    cStr = substr(cStr, nl, '\n')
    return cStr

func ringtest_formatDuration nSecs
    if nSecs < 0.001
        return "" + (nSecs * 1000000) + "us"
    elseif nSecs < 1
        return "" + (nSecs * 1000) + "ms"
    else
        return "" + nSecs + "s"
    ok

func ringtest_formatBenchTime nSecs
    if nSecs < 0.000001
        return "" + ringtest_round(nSecs * 1000000000, 2) + "ns"
    elseif nSecs < 0.001
        return "" + ringtest_round(nSecs * 1000000, 2) + "us"
    elseif nSecs < 1
        return "" + ringtest_round(nSecs * 1000, 2) + "ms"
    else
        return "" + ringtest_round(nSecs, 4) + "s"
    ok

func ringtest_round nVal, nDecimals
    nMult = 1
    for i = 1 to nDecimals
        nMult *= 10
    next
    return floor(nVal * nMult + 0.5) / nMult


# ============================================================
# CLASS: TestResult
# ============================================================

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


# ============================================================
# CLASS: TestSuite
# ============================================================

class TestSuite

    name           = "Default Suite"
    tests          = []
    groups         = []
    results        = []

    cBeforeAll     = ""
    cAfterAll      = ""
    cBeforeEach    = ""
    cAfterEach     = ""

    tags           = []
    filterTags     = []
    lSkipAll       = false
    skipReason     = ""

    totalTests     = 0
    passCount      = 0
    failCount      = 0
    skipCount      = 0
    errorCount     = 0
    xfailCount     = 0
    totalDuration  = 0

    outputFormat   = "text"
    lVerbose       = true
    lColorEnabled  = true

    # ---- Configuration ----

    func init cName
        name = cName

    func setVerbose lFlag
        lVerbose = lFlag

    func setColor lFlag
        lColorEnabled = lFlag

    func setOutputFormat cFormat
        outputFormat = lower(cFormat)

    func setFilterTags aTags
        filterTags = aTags

    func skipAllTests cReason
        lSkipAll   = true
        skipReason = cReason

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
        add(tests, aTest)

    func addTestWithTags cName, cFunc, aTags
        addTest(cName, cFunc)
        tests[len(tests)][:tags] = aTags

    func addSkippedTest cName, cReason
        aTest = [:name = cName, :func = "", :tags = [],
                 :skip = true, :skipMsg = cReason, :xfail = false,
                 :timeout = 0, :params = []]
        add(tests, aTest)

    func addExpectedFailure cName, cFunc, cReason
        addTest(cName, cFunc)
        tests[len(tests)][:xfail] = true
        tests[len(tests)][:skipMsg] = cReason

    func addParameterizedTest cName, cFunc, aParamSets
        for aParams in aParamSets
            cLabel = cName + " [" + ringtest_list2str(aParams) + "]"
            aTest = [:name = cLabel, :func = cFunc, :tags = [],
                     :skip = false, :skipMsg = "", :xfail = false,
                     :timeout = 0, :params = aParams]
            add(tests, aTest)
        next

    # ---- Test Groups ----

    func addGroup cGroupName, aGroupTests
        aGroup = [:name = cGroupName, :tests = aGroupTests]
        add(groups, aGroup)

    # ---- Run ----

    func run
        nStart = clock()

        printHeader()

        if cBeforeAll != ""
            try
                call cBeforeAll()
            catch
                see C_RED + "  beforeAll hook failed: " + cCatchError + C_RESET + nl
            done
        ok

        for i = 1 to len(tests)
            runSingleTest(tests[i], "")
        next

        for nG = 1 to len(groups)
            aGroup = groups[nG]
            cGName = aGroup[:name]
            if lVerbose
                see nl
                see C_BOLD + C_CYAN + "  +-- Group: " + cGName + C_RESET + nl
            ok
            aGTests = aGroup[:tests]
            for nT = 1 to len(aGTests)
                runSingleTest(aGTests[nT], cGName)
            next
            if lVerbose
                see C_CYAN + "  +---------------" + C_RESET + nl
            ok
        next

        if cAfterAll != ""
            try
                call cAfterAll()
            catch
                see C_RED + "  afterAll hook failed: " + cCatchError + C_RESET + nl
            done
        ok

        totalDuration = (clock() - nStart) / clockspersecond()

        printSummary()

        if outputFormat = "json"
            printJSONReport()
        ok
        if outputFormat = "tap"
            printTAPReport()
        ok

    # ---- Internal: Run a single test ----

    func runSingleTest aTest, cGroup
        totalTests++

        oResult = new TestResult(aTest[:name])
        oResult.suiteName = name
        oResult.groupName = cGroup

        if lSkipAll
            oResult.setSkip(skipReason)
            add(results, oResult)
            skipCount++
            printResult(oResult, cGroup)
            return
        ok

        if aTest[:skip]
            oResult.setSkip(aTest[:skipMsg])
            add(results, oResult)
            skipCount++
            printResult(oResult, cGroup)
            return
        ok

        if len(filterTags) > 0
            lMatch = false
            for cTag in filterTags
                aTestTags = aTest[:tags]
                for cTestTag in aTestTags
                    if lower(cTag) = lower(cTestTag)
                        lMatch = true
                    ok
                next
            next
            if !lMatch
                oResult.setSkip("filtered out by tags")
                add(results, oResult)
                skipCount++
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
                add(results, oResult)
                errorCount++
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
                failCount++
            else
                oResult.setPass()
                passCount++
            ok
        catch
            if lIsXfail
                oResult.setExpectedFail(cXfailMsg + " (" + cCatchError + ")")
                xfailCount++
                passCount++
            else
                oResult.setFail(cCatchError)
                failCount++
            ok
        done
        oResult.duration = (clock() - nTestStart) / clockspersecond()

        if cAfterEach != ""
            try
                call cAfterEach()
            catch
                see C_YELLOW + "  afterEach hook failed: " + cCatchError + C_RESET + nl
            done
        ok

        add(results, oResult)
        printResult(oResult, cGroup)

    # ---- Output Helpers ----

    func printHeader
        see nl
        see C_BOLD + C_MAGENTA + "  ==============================================" + C_RESET + nl
        see C_BOLD + C_MAGENTA + "   RingTest v" + RINGTEST_VERSION + C_RESET + nl
        see C_BOLD + C_MAGENTA + "   Suite: " + name + C_RESET + nl
        see C_BOLD + C_MAGENTA + "  ==============================================" + C_RESET + nl
        see nl

    func printResult oResult, cGroup
        if !lVerbose return ok

        cIndent = "    "
        if cGroup != ""
            cIndent = "  |   "
        ok

        cTime = ""
        if oResult.duration > 0
            cTime = C_DIM + " (" + ringtest_formatDuration(oResult.duration) + ")" + C_RESET
        ok

        cLine = cIndent + oResult.statusSymbol() + " " + oResult.name + cTime

        if oResult.status = TEST_FAIL or oResult.status = TEST_ERROR
            cLine += nl + cIndent + "  " + C_RED + oResult.message + C_RESET
        elseif oResult.status = TEST_SKIP
            cLine += C_DIM + " -- " + oResult.message + C_RESET
        elseif oResult.status = TEST_EXPECTED_FAIL
            cLine += C_DIM + " (expected)" + C_RESET
        ok

        see cLine + nl

    func printSummary
        see nl
        see C_BOLD + "  ==============================================" + C_RESET + nl
        see C_BOLD + "  Results: " + name + C_RESET + nl
        see C_BOLD + "  ----------------------------------------------" + C_RESET + nl

        cPassLine = C_GREEN + "  Passed:  " + passCount
        if xfailCount > 0
            cPassLine += " (includes " + xfailCount + " expected failures)"
        ok
        see cPassLine + C_RESET + nl

        if failCount > 0
            see C_RED + "  Failed:  " + failCount + C_RESET + nl
        else
            see C_DIM + "  Failed:  0" + C_RESET + nl
        ok

        if errorCount > 0
            see C_RED + "  Errors:  " + errorCount + C_RESET + nl
        else
            see C_DIM + "  Errors:  0" + C_RESET + nl
        ok

        if skipCount > 0
            see C_YELLOW + "  Skipped: " + skipCount + C_RESET + nl
        else
            see C_DIM + "  Skipped: 0" + C_RESET + nl
        ok

        see C_DIM + "  Total:   " + totalTests + C_RESET + nl
        see C_DIM + "  Time:    " + ringtest_formatDuration(totalDuration) + C_RESET + nl
        see C_BOLD + "  ==============================================" + C_RESET + nl

        if failCount = 0 and errorCount = 0
            see nl
            see C_BOLD + C_GREEN + "  * All tests passed! *" + C_RESET + nl
        else
            see nl
            see C_BOLD + C_RED + "  x Some tests failed." + C_RESET + nl
            see nl
            see C_BOLD + C_RED + "  Failed tests:" + C_RESET + nl
            for oRes in results
                if oRes.status = TEST_FAIL or oRes.status = TEST_ERROR
                    see C_RED + "    - " + oRes.name + ": " + oRes.message + C_RESET + nl
                ok
            next
        ok
        see nl

    # ---- JSON Report ----

    func printJSONReport
        cJSON = '{' + nl
        cJSON += '  "framework": "RingTest",' + nl
        cJSON += '  "version": "' + RINGTEST_VERSION + '",' + nl
        cJSON += '  "suite": "' + name + '",' + nl
        cJSON += '  "total": ' + totalTests + ',' + nl
        cJSON += '  "passed": ' + passCount + ',' + nl
        cJSON += '  "failed": ' + failCount + ',' + nl
        cJSON += '  "errors": ' + errorCount + ',' + nl
        cJSON += '  "skipped": ' + skipCount + ',' + nl
        cJSON += '  "duration": ' + totalDuration + ',' + nl
        cJSON += '  "tests": [' + nl
        for i = 1 to len(results)
            oRes = results[i]
            cJSON += '    {' + nl
            cJSON += '      "name": "' + ringtest_escapeJSON(oRes.name) + '",' + nl
            cJSON += '      "status": "' + oRes.statusText() + '",' + nl
            cJSON += '      "duration": ' + oRes.duration + ',' + nl
            cJSON += '      "message": "' + ringtest_escapeJSON(oRes.message) + '"' + nl
            if i < len(results)
                cJSON += '    },' + nl
            else
                cJSON += '    }' + nl
            ok
        next
        cJSON += '  ]' + nl
        cJSON += '}'
        see C_DIM + "  --- JSON Report ---" + C_RESET + nl
        see cJSON + nl

    # ---- TAP Report ----

    func printTAPReport
        see "TAP version 13" + nl
        see "1.." + totalTests + nl
        nIdx = 0
        for oRes in results
            nIdx++
            if oRes.status = TEST_PASS
                see "ok " + nIdx + " - " + oRes.name + nl
            elseif oRes.status = TEST_FAIL
                see "not ok " + nIdx + " - " + oRes.name + nl
                see "  ---" + nl
                see "  message: " + oRes.message + nl
                see "  ..." + nl
            elseif oRes.status = TEST_SKIP
                see "ok " + nIdx + " - " + oRes.name + " # SKIP " + oRes.message + nl
            elseif oRes.status = TEST_ERROR
                see "not ok " + nIdx + " - " + oRes.name + " # ERROR" + nl
                see "  ---" + nl
                see "  message: " + oRes.message + nl
                see "  ..." + nl
            elseif oRes.status = TEST_EXPECTED_FAIL
                see "ok " + nIdx + " - " + oRes.name + " # TODO expected failure" + nl
            ok
        next


# ============================================================
# CLASS: Assert
# ============================================================

class Assert

    func assertEqual actual, expected
        if actual != expected
            raise("[assertEqual] Expected: " + ringtest_str(expected) +
                " | Got: " + ringtest_str(actual))
        ok

    func assertNotEqual actual, notExpected
        if actual = notExpected
            raise("[assertNotEqual] Expected values to differ, but both are: " +
                ringtest_str(actual))
        ok

    func assertStrictEqual actual, expected
        if actual != expected or type(actual) != type(expected)
            raise("[assertStrictEqual] Expected: " + ringtest_str(expected) +
                " (" + type(expected) + ") | Got: " + ringtest_str(actual) +
                " (" + type(actual) + ")")
        ok

    func assertTrue value
        if !value
            raise("[assertTrue] Expected TRUE but got: " + ringtest_str(value))
        ok

    func assertFalse value
        if value
            raise("[assertFalse] Expected FALSE but got: " + ringtest_str(value))
        ok

    func assertNull value
        if !isNULL(value)
            raise("[assertNull] Expected NULL but got: " + ringtest_str(value))
        ok

    func assertNotNull value
        if isNULL(value)
            raise("[assertNotNull] Expected non-NULL value")
        ok

    func assertType value, cExpectedType
        if type(value) != cExpectedType
            raise("[assertType] Expected type: " + cExpectedType +
                " | Got: " + type(value))
        ok

    func assertIsString value
        assertType(value, "STRING")

    func assertIsNumber value
        assertType(value, "NUMBER")

    func assertIsList value
        assertType(value, "LIST")

    func assertGreaterThan actual, threshold
        if actual <= threshold
            raise("[assertGreaterThan] " + ringtest_str(actual) +
                " is not greater than " + ringtest_str(threshold))
        ok

    func assertGreaterOrEqual actual, threshold
        if actual < threshold
            raise("[assertGreaterOrEqual] " + ringtest_str(actual) +
                " is not >= " + ringtest_str(threshold))
        ok

    func assertLessThan actual, threshold
        if actual >= threshold
            raise("[assertLessThan] " + ringtest_str(actual) +
                " is not less than " + ringtest_str(threshold))
        ok

    func assertLessOrEqual actual, threshold
        if actual > threshold
            raise("[assertLessOrEqual] " + ringtest_str(actual) +
                " is not <= " + ringtest_str(threshold))
        ok

    func assertBetween value, nMin, nMax
        if value < nMin or value > nMax
            raise("[assertBetween] " + ringtest_str(value) +
                " is not between " + ringtest_str(nMin) +
                " and " + ringtest_str(nMax))
        ok

    func assertApproxEqual actual, expected, nTolerance
        if ringtest_fabs(actual - expected) > nTolerance
            raise("[assertApproxEqual] " + ringtest_str(actual) +
                " is not within " + ringtest_str(nTolerance) +
                " of " + ringtest_str(expected))
        ok

    func assertContains cHaystack, cNeedle
        if substr(cHaystack, cNeedle) = 0
            raise("[assertContains] String does not contain: '" + cNeedle + "'")
        ok

    func assertNotContains cHaystack, cNeedle
        if substr(cHaystack, cNeedle) > 0
            raise("[assertNotContains] String unexpectedly contains: '" + cNeedle + "'")
        ok

    func assertStartsWith cStr, cPrefix
        if left(cStr, len(cPrefix)) != cPrefix
            raise("[assertStartsWith] '" + cStr +
                "' does not start with '" + cPrefix + "'")
        ok

    func assertEndsWith cStr, cSuffix
        if right(cStr, len(cSuffix)) != cSuffix
            raise("[assertEndsWith] '" + cStr +
                "' does not end with '" + cSuffix + "'")
        ok

    func assertStringLength cStr, nExpected
        if len(cStr) != nExpected
            raise("[assertStringLength] Expected length " + nExpected +
                " but got " + len(cStr))
        ok

    func assertEmpty value
        if isString(value)
            if len(value) > 0
                raise("[assertEmpty] String is not empty (length: " + len(value) + ")")
            ok
        elseif isList(value)
            if len(value) > 0
                raise("[assertEmpty] List is not empty (length: " + len(value) + ")")
            ok
        else
            raise("[assertEmpty] Value is neither string nor list")
        ok

    func assertNotEmpty value
        if isString(value)
            if len(value) = 0
                raise("[assertNotEmpty] String is empty")
            ok
        elseif isList(value)
            if len(value) = 0
                raise("[assertNotEmpty] List is empty")
            ok
        else
            raise("[assertNotEmpty] Value is neither string nor list")
        ok

    func assertMatch cStr, cPattern
        if substr(cStr, cPattern) = 0
            raise("[assertMatch] '" + cStr +
                "' does not match pattern '" + cPattern + "'")
        ok

    func assertListEqual aActual, aExpected
        if len(aActual) != len(aExpected)
            raise("[assertListEqual] List lengths differ: " +
                len(aActual) + " vs " + len(aExpected))
        ok
        for i = 1 to len(aActual)
            if aActual[i] != aExpected[i]
                raise("[assertListEqual] Mismatch at index " + i +
                    ": " + ringtest_str(aActual[i]) +
                    " vs " + ringtest_str(aExpected[i]))
            ok
        next

    func assertListContains aList, value
        if find(aList, value) = 0
            raise("[assertListContains] List does not contain: " +
                ringtest_str(value))
        ok

    func assertListNotContains aList, value
        if find(aList, value) > 0
            raise("[assertListNotContains] List unexpectedly contains: " +
                ringtest_str(value))
        ok

    func assertListLength aList, nExpected
        if len(aList) != nExpected
            raise("[assertListLength] Expected list length " + nExpected +
                " but got " + len(aList))
        ok

    func assertListSorted aList
        for i = 1 to len(aList) - 1
            if aList[i] > aList[i+1]
                raise("[assertListSorted] List not sorted at index " + i +
                    ": " + ringtest_str(aList[i]) +
                    " > " + ringtest_str(aList[i+1]))
            ok
        next

    func assertRaises cFunc
        lRaised = false
        try
            call cFunc()
        catch
            lRaised = true
        done
        if !lRaised
            raise("[assertRaises] Expected an exception but none was raised")
        ok

    func assertRaisesContaining cFunc, cMessage
        lRaised = false
        cActual = ""
        try
            call cFunc()
        catch
            lRaised = true
            cActual = cCatchError
        done
        if !lRaised
            raise("[assertRaisesContaining] Expected an exception but none was raised")
        ok
        if substr(cActual, cMessage) = 0
            raise("[assertRaisesContaining] Exception message '" + cActual +
                "' doesn't contain '" + cMessage + "'")
        ok

    func assertNoError cFunc
        try
            call cFunc()
        catch
            raise("[assertNoError] Unexpected exception: " + cCatchError)
        done

    func fail cMessage
        raise("[fail] " + cMessage)

    func assertWithMessage lCondition, cMessage
        if !lCondition
            raise("[assertWithMessage] " + cMessage)
        ok


# ============================================================
# CLASS: Benchmark
# ============================================================

class Benchmark

    results = []

    func measure cName, cFunc, nIterations
        if nIterations < 1 nIterations = 1 ok

        nStart = clock()
        for i = 1 to nIterations
            call cFunc()
        next
        nEnd = clock()

        nTotal   = (nEnd - nStart) / clockspersecond()
        nPerIter = nTotal / nIterations

        aResult = [:name = cName, :iterations = nIterations,
                   :totalTime = nTotal, :avgTime = nPerIter,
                   :opsPerSec = 1 / nPerIter]
        add(results, aResult)

        see SYM_BENCH + " " + C_CYAN + cName + C_RESET +
            C_DIM + " -- " + nIterations + " iterations" + C_RESET + nl
        see "      Total: " + ringtest_formatBenchTime(nTotal) +
            " | Avg: " + ringtest_formatBenchTime(nPerIter) +
            " | " + floor(1/nPerIter) + " ops/sec" + nl

        return aResult

    func compare cName1, cFunc1, cName2, cFunc2, nIterations
        see nl + C_BOLD + C_CYAN + "  Benchmark Comparison" + C_RESET + nl
        see C_CYAN + "  ----------------------------" + C_RESET + nl

        r1 = measure(cName1, cFunc1, nIterations)
        r2 = measure(cName2, cFunc2, nIterations)

        see nl
        if r1[:avgTime] < r2[:avgTime]
            nFactor = r2[:avgTime] / r1[:avgTime]
            see C_GREEN + "  -> " + cName1 + " is " +
                ringtest_round(nFactor, 2) + "x faster" + C_RESET + nl
        else
            nFactor = r1[:avgTime] / r2[:avgTime]
            see C_GREEN + "  -> " + cName2 + " is " +
                ringtest_round(nFactor, 2) + "x faster" + C_RESET + nl
        ok
        see nl


# ============================================================
# CLASS: Mock
# ============================================================

class Mock

    calls      = []
    returnVals = []
    callCount  = 0
    name       = "mock"

    func init cName
        name = cName

    func setReturn value
        add(returnVals, value)

    func invoke
        callCount++
        aCall = [:callNum = callCount, :timestamp = clock()]
        add(calls, aCall)
        if len(returnVals) >= callCount
            return returnVals[callCount]
        elseif len(returnVals) > 0
            return returnVals[len(returnVals)]
        ok
        return NULL

    func invokeWithArgs aArgs
        callCount++
        aCall = [:callNum = callCount, :args = aArgs, :timestamp = clock()]
        add(calls, aCall)
        if len(returnVals) >= callCount
            return returnVals[callCount]
        elseif len(returnVals) > 0
            return returnVals[len(returnVals)]
        ok
        return NULL

    func wasCalled
        return callCount > 0

    func wasCalledTimes nTimes
        return callCount = nTimes

    func getCallCount
        return callCount

    func getCall nIndex
        if nIndex > 0 and nIndex <= len(calls)
            return calls[nIndex]
        ok
        return NULL

    func getLastCall
        if len(calls) > 0
            return calls[len(calls)]
        ok
        return NULL

    func resetMock
        calls     = []
        callCount = 0
