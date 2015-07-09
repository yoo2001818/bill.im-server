function statusChangeCallback(response) {
  console.log('statusChangeCallback');
  console.log(response);
  if (response.status === 'connected') {
    // Logged into your app and Facebook.
    testAPI(response);
  } else if (response.status === 'not_authorized') {
    // The person is logged into Facebook, but not your app.
    document.getElementById('status').innerHTML = 'Please log ' +
      'into this app.';
  } else {
    // The person is not logged into Facebook, so we're not sure if
    // they are logged into this app or not.
    document.getElementById('status').innerHTML = 'Please log ' +
      'into Facebook.';
  }
}

var apikey;
var user;
var groups;

function checkLoginState() {
  FB.getLoginStatus(function(response) {
    statusChangeCallback(response);
  });
}

window.fbAsyncInit = function() {
  FB.init({
    appId      : '655708987896404',
    cookie     : true,
    xfbml      : true,
    version    : 'v2.2' 
  });

  FB.getLoginStatus(function(response) {
    statusChangeCallback(response);
  });

};

// Load the SDK asynchronously
(function(d, s, id) {
  var js, fjs = d.getElementsByTagName(s)[0];
  if (d.getElementById(id)) return;
  js = d.createElement(s); js.id = id;
  js.src = "//connect.facebook.net/en_US/sdk.js";
  fjs.parentNode.insertBefore(js, fjs);
}(document, 'script', 'facebook-jssdk'));

function testAPI(response) {
  document.getElementById('fblogin').style.display = 'none';
  document.getElementById('status').innerHTML = 'Obtaining API key';
  $.post('/api/auth/facebook/token/', {
    access_token: response.authResponse.accessToken
  }, function(data) {
    console.log(data);
    apikey = data.token;
    user = data.user;
    groups = data.user.groups;
    console.log(apikey);
    document.getElementById('status').innerHTML = 'Hello, '+data.user.name;
    updateGroups();
  });
}

function updateGroups() {
  $('#grouplist').html(groups.map(function(group) {
    return '<li>'+group.id+'# '+group.name+'-'+(group.description||'')+
    ' <a href="#" onclick="partGroup('+group.id+')">나가기</a>'+
    ' <a href="#" onclick="inspectGroup('+group.id+')">찾아보기</a></li>';
  }).join(''));
}

function updateAllGroups(groupList) {
  $('#groupalllist').html(groupList.map(function(group) {
    return '<li>'+group.id+'# '+group.name+'-'+(group.description||'')+
    ' <a href="#" onclick="joinGroup('+group.id+')">가입</a></li>';
  }).join(''));
}

function partGroup(id) {
  console.log(id);
  $.post('/api/group/self/part', {
    id: id,
    apikey: apikey
  }, function(data) {
    console.log(data);
    if(data.code == 200) {
      groups = data.groups;
      updateGroups();
    } else {
      alert(data);
    }
  });
}

function fetchGroupAll() {
  $.post('/api/group/list', {
  }, function(data) {
    console.log(data);
    updateAllGroups(data.groups);
  });
  return false;
}

function fetchGroup(name) {
  $.post('/api/group/search', {
    name: name
  }, function(data) {
    console.log(data);
    updateAllGroups(data.groups);
  });
  return false;
}

function createGroup(name, description) {
  $.post('/api/group/self/create', {
    name: name,
    description: description,
    apikey: apikey
  }, function(data) {
    groups = data.groups;
    updateGroups();
  });
  return false;
}

function joinGroup(id) {
  $.post('/api/group/self/join', {
    id: id,
    apikey: apikey
  }, function(data) {
    groups = data.groups;
    updateGroups();
  });
  return false;
}

function inspectGroup(id) {
  $.post('/api/group/info', {
    id: id,
    apikey: apikey
  }, function(data) {
    $('#groupuserlist').html(data.group.users.map(function(user) {
      return '<li>'+user.id+'# '+user.name+'</li>';
    }).join(''));
  });
}
