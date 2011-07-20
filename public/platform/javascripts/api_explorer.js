var field_count = 0;
var base_api_url = "";
var api_history = {};
var api_history_index = -1;
var api_result_json = "";
var api_result_object_keys = [];

function initApiExplorer(base_url, api_history_string) {
  base_api_url = base_url;
  api_history = JSON.parse(api_history_string);
  updateHistoryButtons();
} 
  
function hidePopups() {
  Platform.Effects.hide("api_clipboard");
  Platform.Effects.hide("api_history"); 
  Platform.Effects.hide("api_options"); 
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
  
  Platform.element("api_clipboard_text").value = api_result_json;
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
  link_location = link_location + "?path=" + Platform.value("api_path") + "&method=" + Platform.value("request_method");
  
  for (key in params) {
    if (key == "") continue;
    link_location = link_location + "&" + escape(encodeURI(key)) + "=" + escape(encodeURI(params[key]));
  }
  
  Platform.element("api_clipboard_text").value = link_location;
  Platform.element("api_clipboard_text").focus();
  Platform.element("api_clipboard_text").select();
} 

/************************************************************************************
** API History Functions
************************************************************************************/
function clearApiHistory() {
  setCookie("api_history", "[]");
  setCookie("api_history_index", "-1");
  api_history = [];
  api_history_index = -1;
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
  
  if (api_history_index == -1) {
    callHistoricApi(api_history.length - 1);
    return;
  }

  callHistoricApi(api_history_index - 1);
} 

function makeNextCall() {
  if (api_history.length == 0 || api_history_index == -1) return;
  if (api_history_index == api_history.length-1) return;

  callHistoricApi(api_history_index + 1);
} 

function updateHistoryButtons() {
  if (api_history_index == -1) {
    Platform.element("history_next").className = "button super gray small";
    if (api_history.length == 0) {
      Platform.element("history_previous").className = "button super gray small";
    } else {
      Platform.element("history_previous").className = "button super blue small";
    }
    return;
  }
  
  if (api_history_index < api_history.length-1) {
    Platform.element("history_next").className = "button super blue small";
  } else {
    Platform.element("history_next").className = "button super gray small";
  }
  
  if (api_history_index > 0 && api_history.length > 1) {
    Platform.element("history_previous").className = "button super blue small";
  } else {
    Platform.element("history_previous").className = "button super gray small";
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
    
    Platform.Utils.update("api_history_container", "/platform/developer/api_explorer/history", {
      parameters: {api_history_index:api_history_index}
    });
    
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
  
  setCookie("api_history", JSON.stringify(api_history));
  
  if (api_history_index == -1 || api_history_index == (api_history.length-2))
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
  if (Platform.value("request_method") == "GET") {
    Platform.Effects.hide("post_params");
  } else {
    Platform.Effects.show("post_params");
  }
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
  
  saveCallToHistory(Platform.value("api_path"), Platform.value("request_method"), params);
  
  var t0 = new Date();
  Platform.Utils.ajax("http://" + base_api_url + Platform.value("api_path"), {
     method: Platform.value("request_method"),
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
  
  if (path.indexOf(base_api_url) != -1) {
    var parts = path.split(base_api_url);
    path = parts[parts.length-1];
  }

  logInfo("");
  Platform.element("response_data").innerHTML = "";
  Platform.element("api_path").value = path;
  Platform.element("request_method").value = method;
  switchRequestMethod();
  removeAllPostFields();
  for (key in params) {
    addPostField(key, params[key]);
  }
}

function callApi(path, method, params) {
  api_history_index = -1;
  updateApi(path, method, params);
  submitRequest();
}

/************************************************************************************
** Format Response Functions
************************************************************************************/
function S4() {
   return (((1+Math.random())*0x10000)|0).toString(16).substring(1);
}

function guid() {
   return (S4()+S4()+"-"+S4()+"-"+S4()+"-"+S4()+"-"+S4()+S4()+S4());
}

function showObject(obj_key, flag) {
  if (flag) {
    Platform.Effects.hide("no_object_" + obj_key);
    Platform.Effects.show("object_" + obj_key);
    Platform.element("expander_" + obj_key).innerHTML = "<img src='/platform/images/minus_node.png'>";
  } else {
    Platform.Effects.hide("object_" + obj_key);
    Platform.Effects.show("no_object_" + obj_key);
    Platform.element("expander_" + obj_key).innerHTML = "<img src='/platform/images/plus_node.png'>";
  } 
}

function toggleObject(obj_key) {
  showObject(obj_key, (Platform.element("object_" + obj_key).style.display == 'none'));
}

function expandAllResultObjects(flag) {
  for (var i=0; i<api_result_object_keys.length; i++) {
    showObject(api_result_object_keys[i], flag);
  }
}

function formatResponse(response_text) {
  api_result_json = response_text;
  api_result_object_keys = [];
  
  var response = response_text;
  
  if (typeof response_text == 'string') {
    try {
      response = eval("[" + response_text + "]")[0];
    } 
    catch (err) {
      Platform.element("response_data").innerText = response_text;
      return;
    }
  }
  
  if (typeof response == 'object') {
    Platform.element("response_data").innerHTML = formatObject(response, 1);
  } else {
    Platform.element("response_data").innerHTML = "Invalid response: " + response_text;
  }
}

function formatObject(obj, level) {
  if (obj == null) return "{<br>}";

  var html = [];
  var obj_key = guid();  
  html.push("<span class='expander' id='expander_" + obj_key + "' onClick=\"toggleObject('" + obj_key + "')\"><img src='/platform/images/minus_node.png'></span> <span style='display:none' id='no_object_" + obj_key + "'>{...}</span> <span id='object_" + obj_key + "'>{");
  api_result_object_keys.push(obj_key);

  var keys = Object.keys(obj).sort();
  
  for (var i=0; i<keys.length; i++) {
    key = keys[i];
    if (isObject(obj[key])) {
      if (isArray(obj[key])) {
        html.push(createSpacer(level) + "<span class='obj_key'>" + key + ":</span>" + formatArray(obj[key], level + 1) + ",");
      } else {
        html.push(createSpacer(level) + "<span class='obj_key'>" + key + ":</span>" + formatObject(obj[key], level + 1) + ",");
      }
    } else {
      html.push(createSpacer(level) + formatProperty(key, obj[key]) + ",");
    }
  }
  html.push(createSpacer(level-1) + "}</span>");
  return html.join("<br>");
}

function formatArray(arr, level) {
  var html = [];

  var obj_key = guid();  
  html.push("<span class='expander' id='expander_" + obj_key + "' onClick=\"toggleObject('" + obj_key + "')\"><img src='/platform/images/minus_node.png'></span> <span style='display:none' id='no_object_" + obj_key + "'>[...]</span> <span id='object_" + obj_key + "'>[");
  api_result_object_keys.push(obj_key);

  for (var i=0; i<arr.length; i++) {
    if (isObject(arr[i])) {
      if (isArray(arr[i])) {
         html.push(createSpacer(level) + formatArray(arr[i], level + 1) + ","); 
      } else {
         html.push(createSpacer(level) + formatObject(arr[i], level + 1) + ",");  
      }     
    } else {
      html.push(createSpacer(level) + formatProperty(null, arr[i]) + ",");
    }
  }  
  html.push(createSpacer(level-1) + "]</span>");
  return html.join("<br>");
}

function createSpacer(level) {
  return "<img src='/platform/images/pixel.gif' style='height:1px;width:" + (level * 20) + "px;'>";
}

function isArray(obj) {
  return !(obj.constructor.toString().indexOf("Array") == -1);
}

function isObject(obj) {
  return (typeof obj == 'object');
}

function isString(obj) {
  return (typeof obj == 'string');
}

function isURL(str) {
  str = "" + str;
  return (str.indexOf("http://") != -1) || (str.indexOf("https://") != -1);
}

function isApiCall(str) {
  str = "" + str;
  return (str.indexOf(base_api_url) != -1);
}

function formatProperty(key, value) {
  var cls = "obj_value_" + (typeof value);
  var value_span = "";
  
  if (isURL(value)) {
    if (isApiCall(value)) {
      value = "<a target='_new' class='api_url' href='#' onclick=\"callApi('" + value + "', 'GET', {}); return false;\">" + value + "</a>";
    } else {
      value = "<a target='_new' href='" + value + "'>" + value + "</a>";
    }
  }
  
  if (isString(value)) 
    value_span = "<span class='" + cls + "'>\"" + value + "\"</span>";
  else
    value_span = "<span class='" + cls + "'>" + value + "</span>";
     
  if (key == null)
    return value_span;
    
  return "<span class='obj_key'>" + key + ":</span>" + value_span;
}

function hideApiOptions() {
  Platform.Effects.hide("api_options");
}

function toggleApiOptions(trigger) {
  Platform.Effects.hide("api_clipboard");
  Platform.Effects.hide("api_history"); 

  var options = Platform.element("api_options");
  
  if (options.style.display == "none") {
    var trigger_position = Platform.Utils.cumulativeOffset(trigger);
    var container_position = {
      left: trigger_position[0] + trigger.offsetWidth - 765 + 'px',
      top: trigger_position[1] + trigger.offsetHeight + 10 + 'px'
    }
    options.style.left = container_position.left;
    options.style.top = container_position.top;
    Platform.Effects.show("api_options");
  } else {
    Platform.Effects.hide("api_options");
  }
}