class Teabag.View

  constructor: ->
    @build()


  build: (className) ->
    @el = @createEl("li", className)


  appendTo: (el) ->
    el.appendChild(@el)


  append: (el) ->
    @el.appendChild(el)


  createEl: (type, className = "") ->
    el = document.createElement(type)
    el.className = className
    el


  findEl: (id) ->
    @elements ||= []
    @elements[id] ||= document.getElementById("teabag-#{id}")


  setText: (id, value) ->
    el = @findEl(id)
    el.innerText = value


  setHtml: (id, value) ->
    el = @findEl(id)
    el.innerHTML = value


  setClass: (id, value) ->
    el = @findEl(id)
    el.className = value
