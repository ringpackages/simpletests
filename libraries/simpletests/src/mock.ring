/*
	SimpleTests - Testing Framework Prototype for the Ring Programming Language
*/

class Mock

	aCalls      = []
	aReturnVals = []
	nCallCount  = 0
	cName       = "mock"

	func init cMockName
		cName = cMockName
		return self

	func setReturn value
		add(aReturnVals, value)

	func invoke
		nCallCount++
		aCall = [:callNum = nCallCount, :timestamp = clock()]
		add(aCalls, aCall)
		if len(aReturnVals) >= nCallCount
			return aReturnVals[nCallCount]
		elseif len(aReturnVals) > 0
			return aReturnVals[len(aReturnVals)]
		ok
		return NULL

	func invokeWithArgs aArgs
		nCallCount++
		aCall = [:callNum = nCallCount, :args = aArgs, :timestamp = clock()]
		add(aCalls, aCall)
		if len(aReturnVals) >= nCallCount
			return aReturnVals[nCallCount]
		elseif len(aReturnVals) > 0
			return aReturnVals[len(aReturnVals)]
		ok
		return NULL

	func wasCalled
		return nCallCount > 0

	func wasCalledTimes nTimes
		return nCallCount = nTimes

	func getCallCount
		return nCallCount

	func getCall nIndex
		if nIndex > 0 and nIndex <= len(aCalls)
			return aCalls[nIndex]
		ok
		return NULL

	func getLastCall
		if len(aCalls) > 0
			return aCalls[len(aCalls)]
		ok
		return NULL

	func resetMock
		aCalls     = []
		nCallCount = 0
