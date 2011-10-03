// initialize the library with the API key
var app_id = $('#fb_app_id').val();

// load templates

var load_templates = function(cb) {
  $.get('/tmpls.html', function(templates) {
    $('body').append(templates);
  });
};

var page_init_handler = function() {
  FB.getLoginStatus(handleSessionResponse);
  load_templates();
//  load_projects();
};

var logged_in_handler = function() {
	console.log('logged in')
  get_user_profile();
  $('#login').attr('disabled', 'true');
};

// no user, clear display
var logged_out_handler = function () {
  $('#user-info').hide('fast').empty();
  $('.loaded-remotely').empty(); 
  $('#login').removeAttr('disabled');
  $('.admin-control').hide();
};

var get_user_profile = function() {
  FB.api({
    method: 'fql.query',
    query: 'SELECT name, pic_square FROM profile WHERE id=' + FB.getUserID
  },
  function(response) {
    update_profile_box(response);
  });
};

var update_profile_box = function(response) {
  try{
    $('#userTemplate').tmpl(response).appendTo('#user-info');
  }catch(err){
  }
  $('#user-info').show('fast');
};

// fetch the status on load

// handle a session response from any of the auth related calls
function handleSessionResponse(response) {
  // if we dont have a session, just hide the user info
  if (!response.authResponse) {
    $('body').trigger('logged-out');
    return;
  }
//  get_user_profile();
  $('body').trigger('logged_in');
  
}

var bind_fb_projects = function(response) {
  $('#FBProjectsTemplate').tmpl(response[1].body).appendTo('#projects');
  get_project_details(); 
};

var bind_template = function(response,tmpl,target) {
  $(tmpl).tmpl(response).appendTo(target);
};

var get_statuses = function() {
  $('[rel=status-link]').bind('click',function(ev){
    ev.stopPropagation();
    ev.preventDefault();
    var id = $(this).attr('data-rel');
/*
    FB.api("/"+id+"/statuses", function(response){
      $('.right').html('');
      $('#FBStatusTemplate').tmpl(response).appendTo('.right');
    });
*/
    FB.api("/"+id+"/posts", function(response){
      $('.right').html('');
      $('#FBStatusTemplate').tmpl(response).appendTo('.right');
    });
  });
};
  
var load_projects = function(target) {
  container = target || $('#projects');
  if($('#projects', 'body').length==0){ return;}
  $.get("/accounts", function(response) {
    var outer = JSON.parse(response)[1];
    var inner = JSON.parse(outer.body);
    for(var key in inner) {
      $('#FBProjectTemplate1').tmpl(inner[key]).appendTo(container);
    }
    var $container = $('#projects');
      $container.isotope({
      itemSelector: '.elements'
    });
    project_details_init(); 
  });
};

/*
var load_projects = function() {
  FB.api("/me/accounts",bind_fb_projects); 
};
*/

var fetch_project_details = function(id, target) {
  FB.api("/"+id,function(response) {
    $('#FBProjectTemplate1').tmpl(response).appendTo($(target));
  });
  FB.api("/"+id+"/feed", {limit:20},function(response){
    $(target).first('.project-status-container').html('');
    $('#FBStatusTemplate').tmpl(response).appendTo($(target).first('.project-status-container'));
  });
};

var get_project_details = function() {
    $('[rel=detail-link]').bind('click',function(ev){
      ev.stopPropagation();
      ev.preventDefault();
      var id = $(this).attr('data-rel');
      FB.api("/"+id,function(response) {
        $('.mid').html('');
        $('#FBProjectTemplate').tmpl(response).appendTo('.mid');
        get_statuses();
      });
    });
};

$().ready(function(){

  $('body')
    .bind('logged_in', logged_in_handler)
    .bind('logged-out', logged_out_handler)
    .bind('page_init', page_init_handler);

  $('#login').bind('click',function() {
    FB.login(handleSessionResponse, {scope: 'read_stream, publish_stream,read_insights, manage_pages, offline_access'});
  });

  $('#logout').bind('click', function(e) {
    $('div.global-tab li:not(li:first)').remove()
    FB.logout(handleSessionResponse);
  });

  $('body').trigger('page_init');
});  
