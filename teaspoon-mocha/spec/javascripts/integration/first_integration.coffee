#= require integration/spec_helper

describe "Integration tests", ->

  it "allows failing specs", ->
    expect(true).to.eql(false)

  it "allows erroring specs", ->
    foo()

  describe "with nested describes", ->

    it "allows passing specs", ->
      console.log("it can log to the console")
      expect(true).to.eql(true)

    xit "allows pending specs using xit", ->
      expect(true).to.eql(false)

    it "allows pending specs using no function"
