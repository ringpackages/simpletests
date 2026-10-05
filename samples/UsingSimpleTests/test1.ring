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