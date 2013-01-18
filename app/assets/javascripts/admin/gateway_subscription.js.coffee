jQuery ->
  $("body").on "click", ".alert .close", (event) ->
    event.preventDefault()
    $(@).closest(".alert").remove()

