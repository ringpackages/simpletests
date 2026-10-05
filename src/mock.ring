/*
    SimpleTests - Testing Framework Prototype for the Ring Programming Language
*/

class Mock

    calls      = []
    returnVals = []
    callCount  = 0
    name       = "mock"

    func init cName
        name = cName
        return self

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
