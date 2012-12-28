class Teabag.fixture

  @cache: {}
  @el: null
  @json: []

  # Public API
  #
  # preload(url[, url, ...])
  # load(url[, url, ...], append = false)
  # set(html[, html, ...], append = false)
  # cleanup()

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
  constructor: -> Teabag.fixture.load.apply(window, arguments)


  # Private

  xhr = null

  preload = (url) =>
    load(url, false, true)


  load = (url, append, preload = false) =>
    return loadComplete(url, cached.type, cached.content, append, preload) if cached = @cache[url]
    value = null
    xhrRequest url, ->
      return unless xhr.readyState == 4
      throw("Unable to load fixture \"#{url}\".") unless xhr.status == 200
      value = loadComplete(url, xhr.getResponseHeader("content-type"), xhr.responseText, append, preload)
    return value


  loadComplete = (url, type, content, append, preload) =>
    @cache[url] = {type: type, content: content}
    return @json[@json.push(JSON.parse(content)) - 1] if type.match(/application\/json;/)
    return content if preload
    if append then addContent(content) else putContent(content)


  set = (content, append) ->
    if append then addContent(content) else putContent(content)


  putContent = (content) =>
    cleanup()
    create()
    @el.innerHTML = content
    return @el


  addContent = (content) =>
    create() unless @el
    @el.innerHTML += content
    return @el


  create = =>
    @el = document.createElement("div")
    @el.id = "teabag-fixtures"
    document.body.appendChild(@el)


  cleanup = =>
    @el ||= document.getElementById("teabag-fixtures")
    @el?.parentNode?.removeChild(@el)


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
    xhr.open("GET", "#{Teabag.root}/fixtures/#{url}", false)
    xhr.send()
