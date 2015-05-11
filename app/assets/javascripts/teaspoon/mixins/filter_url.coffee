Teaspoon.Mixins.FilterUrl =
  filterUrl: (grep) ->
    params = []
    params.push("grep=#{encodeURIComponent(grep)}")
    params.push("file=#{Teaspoon.params.file}") if Teaspoon.params.file
    "?#{params.join("&")}"
