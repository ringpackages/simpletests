/*
	Demonstrates all features of the SimpleTests framework.
*/

load "simpletests.ring"

# --- Build the Test Suite ---

suite = new TestSuite("SimpleTests Demo Suite")

suite.beforeAll("mySuiteSetup")
suite.afterAll("mySuiteTeardown")
suite.beforeEach("mySetup")
suite.afterEach("myTeardown")

# Individual tests
suite.addTest("Basic Equality",        "testBasicEquality")
suite.addTest("Strict Equality",       "testStrictEquality")
suite.addTest("Boolean Assertions",    "testBooleans")
suite.addTest("Null Checks",           "testNullChecks")
suite.addTest("Type Checks",           "testTypeChecks")
suite.addTest("Numeric Comparisons",   "testNumericComparisons")
suite.addTest("String Assertions",     "testStringAssertions")
suite.addTest("List Assertions",       "testListAssertions")
suite.addTest("Exception Handling",    "testExceptionHandling")
suite.addTest("Custom Messages",       "testCustomMessages")

# Tagged test
suite.addTestWithTags("Tagged Test - Strings", "testStringAssertions", [:strings, :core])

# Skipped test
suite.addSkippedTest("Database Integration", "Database not available in test environment")

# Expected failure
suite.addExpectedFailure("Known Bug #42", "testIntentionalFail", "Tracked in issue #42")

# Parameterized tests (data-driven)
suite.addParameterizedTest("Addition", "testAddition", [
	[1, 2, 3],
	[0, 0, 0],
	[10, -5, 5],
	[100, 200, 300]
])

# Grouped tests
aGroupMath = []
add(aGroupMath, [:name = "Numeric Comparisons (group)", :func = "testNumericComparisons",
	:tags = [], :skip = false, :skipMsg = "", :xfail = false, :timeout = 0, :params = []])
add(aGroupMath, [:name = "Approximate Equality", :func = "testNumericComparisons",
	:tags = [], :skip = false, :skipMsg = "", :xfail = false, :timeout = 0, :params = []])
suite.addGroup("Math Operations", aGroupMath)

aGroupStr = []
add(aGroupStr, [:name = "String Basics", :func = "testStringAssertions",
	:tags = [], :skip = false, :skipMsg = "", :xfail = false, :timeout = 0, :params = []])
add(aGroupStr, [:name = "String Edge Cases", :func = "testStringAssertions",
	:tags = [], :skip = false, :skipMsg = "", :xfail = false, :timeout = 0, :params = []])
suite.addGroup("String Operations", aGroupStr)

# --- Run the Suite ---

suite.run()

# --- Benchmark Demo ---

? nl + C_BOLD + C_MAGENTA + "  === Benchmark Demo ===" + C_RESET + nl

bench = new Benchmark
bench.measure("String Concatenation", "benchConcat", 10000)
bench.measure("List Append",          "benchListAppend", 10000)

? ""

bench.compare(
	"String +",    "benchConcat",
	"List Append", "benchListAppend",
	5000
)

# --- Mock Demo ---

? nl + C_BOLD + C_MAGENTA + "  === Mock Object Demo ===" + C_RESET + nl

mockDb = new Mock("DatabaseService")
mockDb.setReturn(true)
mockDb.setReturn(false)

oAssert = new Assert

result1 = mockDb.invoke()
result2 = mockDb.invoke()

oAssert.assertTrue(mockDb.wasCalled())
oAssert.assertTrue(mockDb.wasCalledTimes(2))
oAssert.assertEqual(result1, true)
oAssert.assertEqual(result2, false)

? C_GREEN + "  + Mock assertions passed" + C_RESET
? C_DIM + "    Mock '" + mockDb.cName + "' was called " + mockDb.getCallCount() + " times" + C_RESET + nl

# --- Test Functions ---

func testBasicEquality
	assert = new Assert
	assert.assertEqual(1 + 1, 2)
	assert.assertEqual("hello", "hello")
	assert.assertNotEqual(1, 2)
	assert.assertNotEqual("foo", "bar")

func testStrictEquality
	assert = new Assert
	assert.assertStrictEqual(42, 42)
	assert.assertStrictEqual("ring", "ring")

func testBooleans
	assert = new Assert
	assert.assertTrue(10 > 5)
	assert.assertFalse(3 > 7)
	assert.assertTrue(len("hello") = 5)

func testNullChecks
	assert = new Assert
	x = "test"
	assert.assertNotNull(x)
	assert.assertNotNull(42)
	assert.assertNotNull("text")

func testTypeChecks
	assert = new Assert
	assert.assertIsString("hello")
	assert.assertIsNumber(3.14)
	assert.assertIsList([1, 2, 3])
	assert.assertType("test", "STRING")

func testNumericComparisons
	assert = new Assert
	assert.assertGreaterThan(10, 5)
	assert.assertGreaterOrEqual(5, 5)
	assert.assertLessThan(3, 7)
	assert.assertLessOrEqual(7, 7)
	assert.assertBetween(5, 1, 10)
	assert.assertApproxEqual(3.14159, 3.14, 0.01)

func testStringAssertions
	assert = new Assert
	assert.assertContains("Ring Programming Language", "Ring")
	assert.assertNotContains("Hello World", "Goodbye")
	assert.assertStartsWith("RingTest", "Ring")
	assert.assertEndsWith("ringtest.ring", ".ring")
	assert.assertStringLength("ABCDE", 5)
	assert.assertEmpty("")
	assert.assertNotEmpty("content")

func testListAssertions
	assert = new Assert
	assert.assertListEqual([1, 2, 3], [1, 2, 3])
	assert.assertListContains([10, 20, 30], 20)
	assert.assertListNotContains([1, 2, 3], 4)
	assert.assertListLength(["a", "b", "c"], 3)
	assert.assertListSorted([1, 2, 3, 4, 5])

func testExceptionHandling
	assert = new Assert
	assert.assertRaises("funcThatThrows")
	assert.assertRaisesContaining("funcThatThrows", "intentional")
	assert.assertNoError("funcThatSucceeds")

func testCustomMessages
	assert = new Assert
	nAge = 25
	assert.assertWithMessage(nAge >= 18,
		"Age should be at least 18, got: " + nAge)

func testIntentionalFail
	assert = new Assert
	assert.assertEqual(1, 2)

func testAddition aParams
	assert = new Assert
	nA = aParams[1]
	nB = aParams[2]
	nExpected = aParams[3]
	assert.assertEqual(nA + nB, nExpected)

func funcThatThrows
	raise("intentional error for testing")

func funcThatSucceeds
	x = 1 + 1

# --- Hook Functions ---

func mySetup
	# Called before each test

func myTeardown
	# Called after each test

func mySuiteSetup
	? C_DIM + "  [Suite initialized]" + C_RESET

func mySuiteTeardown
	? C_DIM + "  [Suite complete]" + C_RESET

# --- Benchmark Functions ---

func benchConcat
	s = ""
	for i = 1 to 10
		s += "x"
	next

func benchListAppend
	a = []
	for i = 1 to 10
		add(a, "x")
	next
