/*
	SimpleTests - Testing Framework Prototype for the Ring Programming Language
*/

class Benchmark

	aResults = []

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
		add(aResults, aResult)

		? SYM_BENCH + " " + C_CYAN + cName + C_RESET +
			C_DIM + " -- " + nIterations + " iterations" + C_RESET 
		? "      Total: " + ringtest_formatBenchTime(nTotal) +
			" | Avg: " + ringtest_formatBenchTime(nPerIter) +
			" | " + floor(1/nPerIter) + " ops/sec" 

		return aResult

	func compare cName1, cFunc1, cName2, cFunc2, nIterations
		? nl + C_BOLD + C_CYAN + "  Benchmark Comparison" + C_RESET
		? C_CYAN + "  ----------------------------" + C_RESET

		r1 = measure(cName1, cFunc1, nIterations)
		r2 = measure(cName2, cFunc2, nIterations)

		? ""
		if r1[:avgTime] < r2[:avgTime]
			nFactor = r2[:avgTime] / r1[:avgTime]
			? C_GREEN + "  -> " + cName1 + " is " +
				ringtest_round(nFactor, 2) + "x faster" + C_RESET
		else
			nFactor = r1[:avgTime] / r2[:avgTime]
			? C_GREEN + "  -> " + cName2 + " is " +
				ringtest_round(nFactor, 2) + "x faster" + C_RESET
		ok
		? ""

