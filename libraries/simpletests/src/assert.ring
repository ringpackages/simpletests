/*
	SimpleTests - Testing Framework Prototype for the Ring Programming Language
*/

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
