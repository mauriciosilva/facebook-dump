User =
  ->
    console.log 'user created'
    FB.api '/me', {fields: 'id,name,picture'}, (response) ->
      console.dir response

fb_logged_in_state = ->
  new User
  $('#fb-auth')
    .unbind()
    .text('logout')
    .bind 'click', ->
      FB.logout (response) ->
        $('div.badge').remove()
        $.log 'logged out'

fb_logged_out_state = ->
  $('#fb-auth')
    .unbind()
    .text('login')
    .bind 'click', ->
      FB.login (response) ->
        if response.session then location.reload true

fb_status_change = (response) ->
  if response.session
    $.publish 'fb_logged_in_state'
  else
    $.publish 'fb_logged_out_state'


FB.getLoginStatus (response)-> $.publish 'fb_status_change', response
FB.Event.subscribe 'auth.statusChange', (response)-> $.publish 'fb_status_change', response


$(document).ready ->
  $.subscribe 'fb_status_change', fb_status_change
  $.subscribe 'fb_logged_in_state', fb_logged_in_state
  $.subscribe 'fb_logged_out_state', fb_logged_out_state
