download = (filename, href) ->
  element = document.createElement('a')
  element.setAttribute 'href', href
  element.setAttribute 'download', filename
  element.style.display = 'none'
  document.body.appendChild element
  element.click()
  document.body.removeChild element

downloadText = (filename, text) ->
  href = 'data:text/plain;charset=utf-8,' + encodeURIComponent(text)
  download(filename, href)

replaceMyserial = (serial) ->
  $('.myserial').text(serial)

getAsText = (readFile) ->
  reader = new FileReader
  reader.readAsText readFile, 'UTF-8'
  reader.onload = loaded
  reader.onerror = errorHandled

loaded = (evt) ->
  fileString = evt.target.result
  $.ajax
    url: "/api/v1/certificates",
    type: 'post'
    data: { csr: fileString },
    success: (resp) ->
      createNotification('success', 'Sertificate was created successfully')
      downloadText("#{resp.serial}.crt", resp.certificate)
      replaceMyserial(resp.serial)

    error:   (resp) ->
      error = resp?.responseJSON?.errors[0]
      error ||=  'Undefined error occured on upload'
      createNotification('danger', error)

errorHandled = (evt) ->
  console.log evt
  createNotification('danger', 'Undefined error occured')

uploader = btn = null

window.uploadFiles = ->
  file = uploader[0].files[0]
  return unless file
  return createNotification('danger', 'File is too big') if file.size > 20000
  getAsText(file)

$(document).on "turbolinks:load", ->
  uploader = $('#csr_uploader')
  btn = $('#csr_button')
  btn.click ->
    uploader.click()
    uploader.change ->
      uploader.off()
      do window.uploadFiles

