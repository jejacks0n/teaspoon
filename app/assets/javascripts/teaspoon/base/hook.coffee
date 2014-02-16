Teaspoon.hook = (name, options = {}) ->

  xhr = null

  xhrRequest = (url, options, callback) ->
    if window.XMLHttpRequest # Mozilla, Safari, ...
      xhr = new XMLHttpRequest()
    else if window.ActiveXObject # IE
      try xhr = new ActiveXObject("Msxml2.XMLHTTP")
      catch e
        try xhr = new ActiveXObject("Microsoft.XMLHTTP")
        catch e
    throw("Unable to make Ajax Request") unless xhr

    xhr.onreadystatechange = callback
    xhr.open(options['method'] || "GET", "#{Teaspoon.root}/#{url}", false)
    xhr.send(options['payload'])

  xhrRequest "#{Teaspoon.suites.active}/#{name}", options, ->
    return unless xhr.readyState == 4
    throw("Unable to call hook \"#{url}\".") unless xhr.status == 200
