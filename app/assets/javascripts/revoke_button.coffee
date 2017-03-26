$(document).on "turbolinks:load", ->
  $('[data-revoke-button]').each ->
    button = $(this)
    url = button.data('revoke-button')
    button.click (e)->
      button.addClass('is-loading')
      $.ajax
        url: url,
        type: 'post'
        success: (resp) ->
          button.removeClass('is-loading')
                .addClass('is-disabled')
                .text('Revoked')
        error:   (resp) ->
          console.log resp
          notification =
            $('<div class="notification is-danger"></div>')
            .text('Undefined error occured')
          $('main.container').prepend(notification)

