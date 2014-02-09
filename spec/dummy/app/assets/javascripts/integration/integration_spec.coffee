#= require integration/integration
#= require integration/spec_helper

describe "Integration tests", ->

  it "tests", ->
    console.log("testing console output")
    expect(true).toBe(true)

  it "handles multiple specs", ->
    expect(true).toBe(true)

  it "allows failing specs", ->
    expect(true).toBe(false)

  it "allows erroring specs", ->
    foo()

  describe "nesting", ->

    it "is allowed", ->
      expect(true).toBe(true)

  describe "pending", ->

    it "is allowed"

  describe "fixtures", ->

    it "loads files", ->
      fixture.load("fixture.html")
      expect(fixture.el.innerHTML).toContain("Lorem ipsum dolor")
