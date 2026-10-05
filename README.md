# SimpleTests - Testing Framework Prototype for the Ring programming language

---

## Table of Contents

- [Install](#install)
- [Features](#features)
- [Quick Start](#quick-start)
- [Suite Configuration](#suite-configuration)
- [Advanced Features](#advanced-features)
  - [Tags & Filtering](#tags--filtering)
  - [Parameterized Tests](#parameterized-tests)
  - [Skipped & Expected Failures](#skipped--expected-failures)
  - [Test Groups](#test-groups)
  - [Mock Objects](#mock-objects)
  - [Benchmarking](#benchmarking)
- [Output Formats](#output-formats)
- [Assertion Reference](#assertion-reference)
  - [Equality](#equality)
  - [Boolean](#boolean)
  - [Null & Type](#null--type)
  - [Numeric](#numeric)
  - [String](#string)
  - [List](#list)
  - [Exceptions](#exceptions)
  - [Custom](#custom)
- [License](#license)

---

## Install


	ringpm install simpletests from ringpackages

---

## Features

- **25+ Assertions** — Equality, boolean, numeric, string, list, type, exception, custom
- **Test Suites** — Named suites with grouping support
- **Hooks** — `beforeAll`, `afterAll`, `beforeEach`, `afterEach` lifecycle hooks
- **Parameterized Tests** — Data-driven tests with automatic labeling
- **Tags & Filtering** — Tag tests and run only matching subsets
- **Skip & Expected Failure** — Mark tests as skipped or expected-to-fail (xfail)
- **Mock Objects** — Configurable return values, call tracking, and spying
- **Benchmarking** — Measure performance, compare approaches, ops/sec reporting
- **Rich Output** — Colored terminal output with pass/fail symbols
- **Multiple Formats** — Text (default), JSON, and TAP (Test Anything Protocol) reports

---

## Quick Start

```ring
load "simpletests.ring"

new TestSuite("My Suite") {
    addTest("Math works", "testMath")
    run()
}

func testMath

    new Assert {
        assertEqual(2 + 2, 4)
        assertTrue(10 > 5)
        assertContains("Hello Ring", "Ring")
    }
```

---

## Suite Configuration

```ring
suite = new TestSuite("My Suite")

# Hooks
suite.beforeAll("globalSetup")
suite.afterAll("globalTeardown")
suite.beforeEach("testSetup")
suite.afterEach("testTeardown")

# Settings
suite.setVerbose(true)
suite.setOutputFormat("text")   # "text", "json", or "tap"
```

---

## Advanced Features

### Tags & Filtering

```ring
suite.addTestWithTags("API test", "testAPI", [:api, :network])
suite.setFilterTags([:api])   # Only run :api tests
suite.run()
```

### Parameterized Tests

```ring
# Statements
suite.addParameterizedTest("Multiply", "testMultiply", [
    [2, 3, 6], [0, 100, 0], [-1, 5, -5]
])
suite.run()

# Functions
func testMultiply aParams
    assert = new Assert
    assert.assertEqual(aParams[1] * aParams[2], aParams[3])
```

### Skipped & Expected Failures

```ring
suite.addSkippedTest("SSL Tests", "OpenSSL not installed")
suite.addExpectedFailure("Issue #99", "testBroken", "Known regression")
```

### Test Groups

```ring
aGroup = []
add(aGroup, [:name = "Insert", :func = "testInsert",
    :tags = [], :skip = false, :skipMsg = "",
    :xfail = false, :timeout = 0, :params = []])
suite.addGroup("Database Tests", aGroup)
```

### Mock Objects

```ring
mock = new Mock("PaymentGateway")
mock.setReturn(true)
mock.setReturn(false)

result1 = mock.invoke()             # returns true
result2 = mock.invokeWithArgs(["USD", 99.99])  # returns false

assert = new Assert
assert.assertTrue(mock.wasCalled())
assert.assertTrue(mock.wasCalledTimes(2))
mock.resetMock()
```

### Benchmarking

```ring
bench = new Benchmark
bench.measure("Sort items", "testSort", 1000)
bench.compare("Approach A", "funcA", "Approach B", "funcB", 5000)
```

---

## Output Formats

**Text** (default): Colored terminal output with symbols and summary.

**JSON**: `suite.setOutputFormat("json")` — Structured test results.

**TAP**: `suite.setOutputFormat("tap")` — Test Anything Protocol for CI/CD.

---

## Assertion Reference

### Equality
- `assertEqual(actual, expected)` — Values are equal
- `assertNotEqual(actual, notExpected)` — Values differ
- `assertStrictEqual(actual, expected)` — Equal value AND type

### Boolean
- `assertTrue(value)` — Value is truthy
- `assertFalse(value)` — Value is falsy

### Null & Type
- `assertNull(value)` — Value is NULL
- `assertNotNull(value)` — Value is not NULL
- `assertType(value, typeName)` — Type matches (e.g., "STRING")
- `assertIsString(value)`, `assertIsNumber(value)`, `assertIsList(value)`

### Numeric
- `assertGreaterThan(a, b)`, `assertGreaterOrEqual(a, b)`
- `assertLessThan(a, b)`, `assertLessOrEqual(a, b)`
- `assertBetween(val, min, max)` — min <= val <= max
- `assertApproxEqual(a, b, tolerance)` — |a - b| <= tolerance

### String
- `assertContains(str, substr)`, `assertNotContains(str, substr)`
- `assertStartsWith(str, prefix)`, `assertEndsWith(str, suffix)`
- `assertStringLength(str, n)`, `assertMatch(str, pattern)`
- `assertEmpty(value)`, `assertNotEmpty(value)`

### List
- `assertListEqual(a, b)` — Same elements in order
- `assertListContains(list, val)`, `assertListNotContains(list, val)`
- `assertListLength(list, n)`, `assertListSorted(list)`

### Exceptions
- `assertRaises(funcName)` — Function raises an exception
- `assertRaisesContaining(func, msg)` — Exception contains text
- `assertNoError(funcName)` — No exception thrown

### Custom
- `fail(message)` — Unconditional failure
- `assertWithMessage(condition, msg)` — Assert with custom message

---

## License

The project uses the MIT License.
