class Teaspoon.Reporters.BaseView

  constructor: ->
    @elements = {}
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
    @elements ||= {}
    @elements[id] ||= document.getElementById("teaspoon-#{id}")


  setText: (id, value) ->
    el = @findEl(id)
    el.innerHTML = value


  setHtml: (id, value, add = false) ->
    el = @findEl(id)
    if add then el.innerHTML += value else el.innerHTML = value


  setClass: (id, value) ->
    el = @findEl(id)
    el.className = value


  htmlSafe: (str) ->
    el = document.createElement("div")
    el.appendChild(document.createTextNode(str))
    el.innerHTML
