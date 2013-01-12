fixture.preload("fixture.html", "fixture.json") # make the actual requests for the files
describe "Using fixtures", ->

  fixture.set("<h2>Another Title</h2>") # create some markup manually (will be in a beforeEach)

  beforeEach ->
    @fixtures = fixture.load("fixture.html", "fixture.json", true) # append these fixtures

  it "loads fixtures", ->
    expect(document.getElementById("fixture_view").tagName).to.be("DIV")
    expect(@fixtures[0]).to.be(fixture.el) # the element is available as a return value and through fixture.el
    expect(@fixtures[1]).to.eql(fixture.json[0]) # the json for json fixtures is returned, and available in fixture.json
