window.createNotification = (type, text)->
  notif = $("<div class='notification is-#{type}'></div>")
                 .text(text)
                 .append("<button class='delete'></button>")

  notif.find('button').click ->
    notif.fadeOut 'slow', ->
      notif.remove()

  setTimeout (->
    notif.off().fadeOut 'slow', ->
      notif.remove()
  ), 2000

  $('#notifications').prepend(notif)
