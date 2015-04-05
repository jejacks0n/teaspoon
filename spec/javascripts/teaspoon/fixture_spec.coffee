describe "Teaspoon.fixture", ->

  beforeEach ->
    fixture.cache = {}
    fixture.cleanup()
    @mockXhr =
      readyState: 4
      status: 200
      responseText: "_content_"
      getResponseHeader: -> "_type_"
      open: ->
      send: ->
    @xhrSpy = spyOn(@mockXhr, 'open')
    @xhrSpy
    try spyOn(window, 'XMLHttpRequest').andReturn(@mockXhr)
    catch e
      spyOn(window, 'ActiveXObject').andReturn(@mockXhr)


  describe "@load", ->

    it "loads all of the files requested", ->
      fixture.load("fixture.html", "fixture.json")
      expect(@xhrSpy).toHaveBeenCalledWith("GET", "#{Teaspoon.root}/fixtures/fixture.html", false)
      expect(@xhrSpy).toHaveBeenCalledWith("GET", "#{Teaspoon.root}/fixtures/fixture.json", false)

    it "caches the type/contents of those files", ->
      fixture.load("fixture.html")
      @mockXhr.onreadystatechange()
      expect(fixture.cache["fixture.html"]).toEqual(type: "_type_", content: "_content_")

    it "throws an exception if unable to load a file", ->
      fixture.load("foo.html")
      @mockXhr.status = 500
      expect(=> @mockXhr.onreadystatechange()).toThrow("Unable to load fixture \"foo.html\".")

    it "adds the contents of files to a fixture element", ->
      fixture.load("fixture.html")
      @mockXhr.onreadystatechange()
      expect(document.getElementById("teaspoon-fixtures").tagName).toBe("DIV")
      expect(document.getElementById("teaspoon-fixtures").innerHTML).toBe("_content_")
      expect(document.getElementById("teaspoon-fixtures")).toBe(fixture.el)

    it "allows appending file contents to the fixture element", ->
      fixture.load("fixture.html1")
      @mockXhr.onreadystatechange()
      expect(document.getElementById("teaspoon-fixtures").tagName).toBe("DIV")
      expect(document.getElementById("teaspoon-fixtures").innerHTML).toBe("_content_")
      fixture.load("fixture.html2", true)
      @mockXhr.onreadystatechange()
      expect(document.getElementById("teaspoon-fixtures").innerHTML).toBe("_content__content_")
      fixture.load("fixture.html3", false)
      @mockXhr.onreadystatechange()
      expect(document.getElementById("teaspoon-fixtures").innerHTML).toBe("_content_")

    it "handles JSON fixtures", ->
      @mockXhr.responseText = '{"foo": "bar"}'
      @mockXhr.getResponseHeader = -> "application/json; encoding-blah"
      fixture.load("fixture.json")
      @mockXhr.onreadystatechange()
      expect(fixture.json.length).toBe(1)
      expect(fixture.json[0]).toEqual(foo: "bar")


  describe "@set", ->

    it "adds all the contents passed to a fixture element", ->
      fixture.set("_content1_", "_content2_")
      expect(document.getElementById("teaspoon-fixtures").tagName).toBe("DIV")
      expect(document.getElementById("teaspoon-fixtures").innerHTML).toBe("_content1__content2_")

    it "allows appending contents to the fixture element", ->
      fixture.set("_content1_")
      expect(document.getElementById("teaspoon-fixtures").tagName).toBe("DIV")
      expect(document.getElementById("teaspoon-fixtures").innerHTML).toBe("_content1_")
      fixture.set("_content2_", true)
      expect(document.getElementById("teaspoon-fixtures").innerHTML).toBe("_content1__content2_")
      fixture.set("_content3_", false)
      expect(document.getElementById("teaspoon-fixtures").innerHTML).toBe("_content3_")


  describe "@preload", ->

    it "loads all of the files requested", ->
      fixture.preload("fixture.html", "fixture.json")
      expect(@xhrSpy).toHaveBeenCalledWith("GET", "#{Teaspoon.root}/fixtures/fixture.html", false)
      expect(@xhrSpy).toHaveBeenCalledWith("GET", "#{Teaspoon.root}/fixtures/fixture.json", false)
    expect(document.getElementById("teaspoon-fixtures")).toBe(null)

    it "caches the type/contents of those files", ->
      fixture.preload("fixture.html")
      @mockXhr.onreadystatechange()
      expect(fixture.cache["fixture.html"]).toEqual(type: "_type_", content: "_content_")
