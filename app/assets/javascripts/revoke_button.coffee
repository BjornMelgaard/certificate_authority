$(document).on "turbolinks:load", ->
  $('[data-revoke-button]').each ->
    makeRevokable($(this))

window.makeRevokable = (button) ->
  serial = button.data('revoke-button')
  button.click (e)->
    button.addClass('is-loading')
    $.ajax
      url: "/api/v1/certificates/#{serial}/revoke",
      type: 'post'
      success: (resp) ->
        button.removeClass('is-loading')
              .addClass('is-disabled')
              .text('Revoked')
      error:   (resp) ->
        console.log resp
        createNotification('danger', 'Undefined error occured on revoke')
