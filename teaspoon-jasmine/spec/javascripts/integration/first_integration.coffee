#= require integration/spec_helper

describe "Integration tests", ->

  it "allows failing specs", ->
    expect(true).toBe(false)

  it "allows erroring specs", ->
    foo()

  describe "with nested describes", ->

    it "allows passing specs", ->
      console.log("it can log to the console")
      expect(true).toBe(true)

    xit "allows pending specs using xit", ->
      expect(true).toBe(false)

    it "allows pending specs by passing no function"
