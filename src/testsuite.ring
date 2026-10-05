/*
    SimpleTests - Testing Framework Prototype for the Ring Programming Language
*/

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
        return self

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

