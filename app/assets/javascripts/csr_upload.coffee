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

getAsText = (readFile) ->
  reader = new FileReader
  reader.readAsText readFile, 'UTF-8'
  reader.onload = loaded
  reader.onerror = errorHandled

replaceMyserial = (serial) ->
  $('.myserial').text(serial)

addToTable = (serial, common_name, created_at) ->
  field = "<tr>
            <td>#{serial}</td>
            <td>#{common_name}</td>
            <td>#{created_at}</td>
            <td><button class='button is-danger is-pulled-right' data-revoke-button='#{serial}'>Revoke</button></td>
          </tr>"
  makeRevokable($('#certificates').prepend(field).find('button.button:first'))

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
      addToTable(resp.serial, resp.common_name, resp.created_at)

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

