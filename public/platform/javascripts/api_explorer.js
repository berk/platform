var field_count = 0;
var api_base_url = "/api";
var oauth_base_url = "";
var api_explorer_app_id = "";
var api_history = [];
var api_history_index = -1;
var api_result_json = "";
var api_result_object_keys = [];
var api_response_formatter;

function initApiExplorer(app_id, site_url, api_url, api_history_string) {
	api_explorer_app_id = app_id;
	oauth_base_url = site_url;
  api_base_url = api_url;
  // api_history = JSON.parse(api_history_string);
  updateHistoryButtons();
} 
  
function hidePopups() {
  Platform.Effects.hide("api_clipboard");
  Platform.Effects.hide("api_history"); 
  Platform.Effects.hide("api_options"); 
} 

/************************************************************************************
** Access Token Functions
************************************************************************************/
function getAccessToken() {
  var width = 600;
  var height = 600;
  var top = (parseInt(window.innerHeight)-height)/2;
  var left = (parseInt(window.innerWidth)-width)/2;
	var land_url = oauth_base_url + "/platform/developer/api_explorer/oauth_lander";
	if (land_url.indexOf("http") == -1) {
		land_url = "http://" + land_url;
	}

	var app_id = Platform.element("app_id").value;
	
	var oauth_url = '/platform/oauth/authorize?client_id=' + app_id + '&response_type=token&display=mobile&redirect_url=' + escape(land_url)
  var win = window.open(oauth_url, 'oauthx_auth', 'width=' + width +',height=' + height + ',top=' + top  + ',left=' + left);
} 

function updateAccessToken(token) {
	Platform.element("access_token").value = token;
}

/************************************************************************************
** Clipboard Functions
************************************************************************************/
function copyToClipboard(trigger) {
  Platform.Effects.hide("api_history");
  Platform.Effects.hide("api_options"); 

  var options = Platform.element("api_clipboard");
  
  if (options.style.display == "none") {
    var trigger_position = Platform.Utils.cumulativeOffset(trigger);
    var container_position = {
      left: trigger_position[0] + trigger.offsetWidth - 25 + 'px',
      top: trigger_position[1] + trigger.offsetHeight + 10 + 'px'
    }
    options.style.left = container_position.left;
    options.style.top = container_position.top;
    Platform.Effects.show("api_clipboard");
  } else {
    Platform.Effects.hide("api_clipboard");
  }
  
  if (api_response_formatter) {
    Platform.element("api_clipboard_text").value = api_response_formatter.rawData();
  } else {
    Platform.element("api_clipboard_text").value = "";
  }

  Platform.element("api_clipboard_text").focus();
  Platform.element("api_clipboard_text").select();
} 

function copyUrlToClipboard(trigger) {
  Platform.Effects.hide("api_history");
  Platform.Effects.hide("api_options"); 

  var options = Platform.element("api_clipboard");
  
  if (options.style.display == "none") {
    var trigger_position = Platform.Utils.cumulativeOffset(trigger);
    var container_position = {
      left: trigger_position[0] + trigger.offsetWidth - 25 + 'px',
      top: trigger_position[1] + trigger.offsetHeight + 10 + 'px'
    }
    options.style.left = container_position.left;
    options.style.top = container_position.top;
    Platform.Effects.show("api_clipboard");
  } else {
    Platform.Effects.hide("api_clipboard");
  }
  
  var params = generateRequestParams();
  var link_location = "" + window.location;
  link_location = link_location.split("?")[0];
  link_location = link_location + "?path=" + Platform.value("api_path") + "&method=" + Platform.value("request_method") + "&api_version=" + Platform.value("api_version");
  
  for (key in params) {
    if (key == "") continue;
    link_location = link_location + "&" + escape(encodeURI(key)) + "=" + escape(encodeURI(params[key]));
  }
  
  Platform.element("api_clipboard_text").value = link_location;
  Platform.element("api_clipboard_text").focus();
  Platform.element("api_clipboard_text").select();
} 


function toggleApiOptions(trigger) {
  Platform.Effects.hide("api_clipboard");
  Platform.Effects.hide("api_history"); 

  var options = Platform.element("api_options");
  
  if (options.style.display == "none") {
    Platform.element("api_options_container").innerHTML = "<img src='/platform/images/loading.gif' style='width:16px;vertical-align:middle;'>&nbsp;  Loading...";
		
    var trigger_position = Platform.Utils.cumulativeOffset(trigger);
    var container_position = {
      left: trigger_position[0] + trigger.offsetWidth - 765 + 'px',
      top: trigger_position[1] + trigger.offsetHeight + 10 + 'px'
    }
    options.style.left = container_position.left;
    options.style.top = container_position.top;
    Platform.Effects.show("api_options");
		
    Platform.Utils.update("api_options_container", "/platform/developer/api_explorer/options", {
      parameters: {api_version:Platform.value("api_version")}
    });
		
  } else {
    Platform.Effects.hide("api_options");
  }
}

function switchApiVersion() {
  var options = Platform.element("api_options");
	
  if (options.style.display != "none") {
    Platform.element("api_options_container").innerHTML = "<img src='/platform/images/loading.gif' style='width:16px;vertical-align:middle;'>&nbsp;  Loading...";
		
  	Platform.Utils.update("api_options_container", "/platform/developer/api_explorer/options", {
  		parameters: {
  			api_version: Platform.value("api_version")
  		}
  	});
  }
}

/************************************************************************************
** API History Functions
************************************************************************************/
function clearApiHistory() {
  api_history = [];
  api_history_index = api_history.length;
  hidePopups();
  updateHistoryButtons();
}

function callHistoricApi(index) {
  api_history_index = index;
  var apic = api_history[api_history_index];
  updateApi(apic.path, apic.method, apic.params);
  submitRequest();
  
  updateHistoryButtons();
}

function makePreviousCall() {
  if (api_history.length == 0 || api_history_index == 0) return;
  api_history_index--;
  callHistoricApi(api_history_index);
} 

function makeNextCall() {
  if (api_history_index>=api_history.length) return;
  api_history_index++;
  callHistoricApi(api_history_index);
} 

function updateHistoryButtons() {
  if (api_history.length == 0) {
    Platform.element("history_previous").className = "button super gray small";
    Platform.element("history_next").className = "button super gray small";
    return;
  }  

  if (api_history_index == api_history.length-1) {
    Platform.element("history_next").className = "button super gray small";
  } else {
    Platform.element("history_next").className = "button super blue small";
  }
  
  if (api_history_index == 0) {
    Platform.element("history_previous").className = "button super gray small";
  } else {
    Platform.element("history_previous").className = "button super blue small";
  }
}

function toggleApiHistory(trigger) {
  Platform.Effects.hide("api_clipboard");
  Platform.Effects.hide("api_options"); 
  
  var options = Platform.element("api_history");
  Platform.element("api_history_container").innerHTML = "<img src='/platform/images/loading.gif' style='width:16px;vertical-align:middle;'>&nbsp;  Loading...";
  
  if (options.style.display == "none") {
    var trigger_position = Platform.Utils.cumulativeOffset(trigger);
    var container_position = {
      left: trigger_position[0] + trigger.offsetWidth - 765 + 'px',
      top: trigger_position[1] + trigger.offsetHeight + 10 + 'px'
    }
    options.style.left = container_position.left;
    options.style.top = container_position.top;
    Platform.Effects.show("api_history");

    if (api_history.length == 0) {
      Platform.element("api_history_container").innerHTML = "API history is empty.";
      return;
    }

    var html = [];
    html.push("<table>");
    for(var i=0; i<api_history.length; i++) {
      var call = api_history[i];
      html.push("<tr style='border-bottom:1px solid #ccc; cursor:pointer;' onClick='callHistoricApi(" + i + ")'><td style='padding:2px;'>" + call.method + " /" + call.path + "</td></tr>");
    }
    html.push("</table>");

    Platform.element("api_history_container").innerHTML = html.join("");

    // Platform.Utils.update("api_history_container", "/platform/developer/api_explorer/history", {
    //   parameters: {api_history_index:api_history_index}
    // });
    
  } else {
    Platform.Effects.hide("api_history");
  }
}

function saveCallToHistory(path, method, params) {
  if (api_history_index != -1) {
    updateHistoryButtons();
    return;
  }
   
  if (api_history.length > 0) {
    var last_call = api_history[api_history.length-1];
    if (last_call.path == path && last_call.method == method && Platform.Utils.equal(last_call.params, params))
      return;
  }
  
  api_history.push({
    path: path,
    method: method,
    params: params
  });
  
  // setCookie("api_history", JSON.stringify(api_history));
  
  api_history_index = api_history.length-1;
  
  updateHistoryButtons();
}

function setCookie( name, value, expires, path, domain, secure ) {
  var today = new Date();
  today.setTime( today.getTime() );

  if (expires) {
    expires = expires * 1000 * 60 * 60 * 24;
  }
  var expires_date = new Date( today.getTime() + (expires) );

  document.cookie = name + "=" +escape( value ) +
    ( ( expires ) ? ";expires=" + expires_date.toGMTString() : "" ) +
    ( ( path ) ? ";path=" + path : "" ) +
    ( ( domain ) ? ";domain=" + domain : "" ) +
    ( ( secure ) ? ";secure" : "" );
}


/************************************************************************************
** API Form Functions
************************************************************************************/
function updateStatus(msg) {
  Platform.element("status").innerHTML = msg;
} 

function logInfo(msg) {
  updateStatus("<span class='info'>" + msg + "</span>");
} 
  
function logError(msg) {
  updateStatus("<span class='error'>" + msg + "</span>");
} 

function switchRequestMethod() {
//  if (Platform.value("request_method") == "GET") {
//    Platform.Effects.hide("post_params");
//  } else {
//    Platform.Effects.show("post_params");
//  }
} 

function addPostField(name, value) {
  var fields = Platform.element("post_fields");
  var field = document.createElement("div");
  field.id="field" + field_count;
  field.className="field";
  
  var field_name_container = document.createElement("span");
  field_name_container.className="field_name_container";

  var field_name = document.createElement("input");
  field_name.type="text";
  field_name.className="field_name";
  field_name.id="field_name" + field_count;
  field_name.label="name";
  field_name.value = name;
  field_name_container.appendChild(field_name);
  field.appendChild(field_name_container);

  var field_value = document.createElement("input");
  field_value.type="text";
  field_value.className="field_value";
  field_value.id="field_value" + field_count;
  field_value.value = value;
  field_value.label="value";
  field.appendChild(field_value);

  var field_action = document.createElement("a");
  field_action.setAttribute("onclick", "removePostField(" + field_count + "); return false;");
  field_action.innerHTML="<span>X</span>";
  field_action.className="field_action";
  field_action.id="field_action" + field_count;
  field_action.href="#";
  field.appendChild(field_action);
  
  fields.appendChild(field);
  field_count++;
  
  Platform.Effects.show("post_params");
  Platform.Effects.show('remove_all_params_link');
}

function removeAllPostFields() {
  var fields = Platform.element("post_fields");
  fields.innerHTML = "";
  field_count = 0;

  Platform.Effects.hide('remove_all_params_link');
}
  
function removePostField(field_index) {
  var fields = Platform.element("post_fields");
  var field = Platform.element("field" + field_index);
  fields.removeChild(field);
  
  field_index ++;
  var next_field = Platform.element("field" + field_index);
  while (next_field) {
    next_field.id="field" + (field_index-1);
    var field_name = Platform.element("field_name" + field_index);
    field_name.id="field_name" + (field_index-1);
    var field_value = Platform.element("field_value" + field_index);
    field_value.id="field_value" + (field_index-1);
    var field_action = Platform.element("field_action" + field_index);
    field_action.id="field_action" + (field_index-1);
    field_action.setAttribute("onclick", "removePostField(" + (field_index-1) + "); return false;");
    field_index ++; 
    next_field = Platform.element("field" + field_index);
  } 
  
  field_count--;
  
  if (field_count == 0) {
    Platform.Effects.hide('remove_all_params_link');
  }
}

/************************************************************************************
** API Call Functions
************************************************************************************/
function generateRequestParams() {
  var params = {};
  var field_index = 0;
  
  var field = Platform.element("field" + field_index);
  while (field) {
    var field_name = Platform.value("field_name" + field_index);
    var field_value = Platform.value("field_value" + field_index);
    params[field_name] = field_value;
    
    field_index ++;
    field = Platform.element("field" + field_index);
  } 
  
  return params;
}

function submitRequest() {
  hidePopups();

  logInfo("Executing request...");
  Platform.element("response_data").innerHTML = "<img src='/platform/images/loading.gif' style='width:16px;vertical-align:middle;'>&nbsp;  Loading...";
  
  var params = generateRequestParams();
  // add access token
	if (Platform.element("access_token") && Platform.value("access_token") != "") {
  	params['access_token'] = Platform.value("access_token");
  }
	
	// add version
	params['api_version'] = Platform.value('api_version');
	
  saveCallToHistory(Platform.value("api_path"), Platform.value("request_method"), params);

	var path =  Platform.value("api_path");
	var method = Platform.value("request_method");
	if (method == 'GET') {
		var path_params = [];
		for (key in params) {
      if (key == "") continue;
      path_params.push(encodeURI(key) + "=" + encodeURI(params[key]));
    }
		path += (path.indexOf("?") == -1) ? "?" : "&";
		path += path_params.join("&");
	}
	
  var t0 = new Date();

  Platform.Utils.ajax(api_base_url + "/" + path, {
     method: method,
     parameters: params,
     onSuccess: function(response) {
        var t1 = new Date();
        logInfo("Request took " + (t1.getTime() - t0.getTime()) + " milliseconds");
        formatResponse(response.responseText);
     },   
     onFailure: function(response) {
        logError("API call failed with status: " +  response.status);
        formatResponse(response.responseText);
     }  
  });
}

function updateApi(path, method, params) {
  hidePopups();

  if (path.indexOf(api_base_url) != -1) {
    var parts = path.split(api_base_url);
    path = parts[parts.length-1];
    path = path.replace(/^\//, "");
  }

  logInfo("");
  Platform.element("response_data").innerHTML = "";
  Platform.element("api_path").value = path;
  Platform.element("request_method").value = method;
  switchRequestMethod();
  removeAllPostFields();
  for (key in params) {
		if (key == 'api_version') continue;
    addPostField(key, params[key]);
  }
	
	if (params['api_version']) {
    Platform.element('api_version').value = params['api_version']; 		
	}
}

function callApi(path, method, params) {
  api_history_index = -1;
  updateApi(path, method, params);
  submitRequest();
}

function formatResponse(response_text) {
  var response = response_text;
  
  if (typeof response_text == 'string') {
    try {
      response = eval("[" + response_text + "]")[0];
    } catch (err) {
      Platform.element("response_data").innerText = response_text;
      return;
    }
  }
  
  if (typeof response == 'object') {
    Platform.element("response_data").innerHTML = "";
    api_response_formatter = new JSONFormatter(response, "response_data", {'hide_toolbar': true, 'hide_border': true});    
  } else {
    api_response_formatter = null;
    Platform.element("response_data").innerHTML = "Invalid response: " + response_text;
  }
}

function expandAllResponseObjects() {
  if (!api_response_formatter) return;
  api_response_formatter.expandAll();
}

function collapseAllResponseObjects() {
  if (!api_response_formatter) return;
  api_response_formatter.collapseAll();
}