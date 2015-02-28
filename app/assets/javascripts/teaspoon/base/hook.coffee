Teaspoon.hook = (name, payload = {}) ->

  xhr = null

  xhrRequest = (url, payload, callback) ->
    if window.XMLHttpRequest # Mozilla, Safari, ...
      xhr = new XMLHttpRequest()
    else if window.ActiveXObject # IE
      try xhr = new ActiveXObject("Msxml2.XMLHTTP")
      catch e
        try xhr = new ActiveXObject("Microsoft.XMLHTTP")
        catch e
    throw("Unable to make Ajax Request") unless xhr

    xhr.onreadystatechange = callback
    xhr.open("POST", "#{Teaspoon.root}/#{url}", false)
    xhr.setRequestHeader("Content-Type", "application/json")
    xhr.send(JSON.stringify(args: payload))

  xhrRequest "#{Teaspoon.suites.active}/#{name}", payload, ->
    return unless xhr.readyState == 4
    throw("Unable to call hook \"#{url}\".") unless xhr.status == 200
