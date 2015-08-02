class Teaspoon.Fixture

  @cache: {}
  @el: null
  @$el: null # will only be defined if window.$ is defined.
  @json: []

  # Public API

  @preload: (urls...) -> preload(url) for url in urls


  @load: (urls..., append = false) ->
    unless typeof(append) == "boolean"
      urls.push(append)
      append = false
    load(url, append || index > 0) for url, index in urls


  @set: (htmls..., append = false) ->
    unless typeof(append) == "boolean"
      htmls.push(append)
      append = false
    set(html, append || index > 0) for html, index in htmls


  @cleanup: -> cleanup()


  # behaves like load, and is only provided as a convenience
  constructor: -> window.fixture.load.apply(window, arguments)


  # Private

  xhr = null

  preload = (url) =>
    load(url, false, true)


  load = (url, append, preload = false) =>
    return loadComplete(url, cached.type, cached.content, append, preload) if cached = window.fixture.cache[url]
    value = null
    xhrRequest url, ->
      return unless xhr.readyState == 4
      throw("Unable to load fixture \"#{url}\".") unless xhr.status == 200
      value = loadComplete(url, xhr.getResponseHeader("content-type"), xhr.responseText, append, preload)
    return value


  loadComplete = (url, type, content, append, preload) =>
    window.fixture.cache[url] = {type: type, content: content}
    return @json[@json.push(JSON.parse(content)) - 1] if type.match(/application\/json;/)
    return content if preload
    if append then addContent(content) else putContent(content)
    return window.fixture.el


  set = (content, append) ->
    if append then addContent(content) else putContent(content)


  putContent = (content) =>
    cleanup()
    addContent(content)


  addContent = (content) =>
    create() unless window.fixture.el

    if jQueryAvailable()
      parsed = $($.parseHTML(content, document, true))
      window.fixture.el.appendChild(parsed[i]) for i in [0...parsed.length]
    else
      window.fixture.el.innerHTML += content


  create = =>
    window.fixture.el = document.createElement("div")
    window.fixture.$el = $(window.fixture.el) if jQueryAvailable()
    window.fixture.el.id = "teaspoon-fixtures"
    document.body?.appendChild(window.fixture.el)


  cleanup = =>
    window.fixture.el ||= document.getElementById("teaspoon-fixtures")
    window.fixture.el?.parentNode?.removeChild(window.fixture.el)
    window.fixture.el = null


  xhrRequest = (url, callback) ->
    if window.XMLHttpRequest # Mozilla, Safari, ...
      xhr = new XMLHttpRequest()
    else if window.ActiveXObject # IE
      try xhr = new ActiveXObject("Msxml2.XMLHTTP")
      catch e
        try xhr = new ActiveXObject("Microsoft.XMLHTTP")
        catch e
    throw("Unable to make Ajax Request") unless xhr

    xhr.onreadystatechange = callback
    xhr.open("GET", "#{Teaspoon.root}/fixtures/#{url}", false)
    xhr.send()


  jQueryAvailable = ->
    typeof(window.$) == 'function'
