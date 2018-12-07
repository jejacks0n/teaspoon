fixture.preload("fixture.html", "fixture.json") # make the actual requests for the files

describe "Using fixtures in Jasmine 2", ->

  fixture.set("<h2>Another Title</h2>") # create some markup manually (will be in a beforeEach)
  fixtures = fixture.load("fixture.html", "fixture.json", true)

  describe 'within the context of a describe', ->

    it "loads fixtures", ->
      expect($("h1", fixture.el).text()).toBe("Title") # using fixture.el as a jquery scope
      expect($("h2", fixture.el).text()).toBe("Another Title")

      # available as a return value and appended to fixture.el
      expect(fixtures[0].innerHTML).toEqual(fixture.el.innerHTML)

      # the json for json fixtures is returned, and available in fixture.json
      expect(fixtures[1]).toEqual(fixture.json[0])

  describe 'within the context of an it', ->

    it "loads fixtures", ->
      expect($("h1", fixture.el).text()).toBe("Title") # using fixture.el as a jquery scope
      expect($("h2", fixture.el).text()).toBe("Another Title")
