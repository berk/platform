/****************************************************************************
  Copyright (c) 2011 Michael Berkovich, Ian McDaniel, Geni Inc

  Permission is hereby granted, free of charge, to any person obtaining
  a copy of this software and associated documentation files (the
  "Software"), to deal in the Software without restriction, including
  without limitation the rights to use, copy, modify, merge, publish,
  distribute, sublicense, and/or sell copies of the Software, and to
  permit persons to whom the Software is furnished to do so, subject to
  the following conditions:

  The above copyright notice and this permission notice shall be
  included in all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
****************************************************************************/

/****************************************************************************
**** Platform Generic Helper Functions
****************************************************************************/

document.createElement('platform');

var Platform = Platform || {
  element:function(element_id) {
    if (typeof element_id == 'string') return document.getElementById(element_id);
    return element_id;
  },
  value:function(element_id) {
    return Platform.element(element_id).value;
  }
};

/****************************************************************************
**** Platform Effects Helper Functions - Can be overloaded by JS frameworks
****************************************************************************/

Platform.Effects = {
  toggle: function(element_id) {
    if (Platform.element(element_id).style.display == "none")
      Platform.element(element_id).show();
    else
      Platform.element(element_id).hide();
  },
  hide: function(element_id) {
    Platform.element(element_id).style.display = "none";
  },
  show: function(element_id) {
    var style = (Platform.element(element_id).tagName == "SPAN") ? "inline" : "block";
    Platform.element(element_id).style.display = style;
  },
  blindUp: function(element_id) {
    Platform.Effects.hide(element_id);
  },
  blindDown: function(element_id) {
    Platform.Effects.show(element_id);
  },
  appear: function(element_id) {
    Platform.Effects.show(element_id);
  },
  fade: function(element_id) {
    Platform.Effects.hide(element_id);
  },
  submit: function(element_id) {
    Platform.element(element_id).submit();
  },
  focus: function(element_id) {
    Platform.element(element_id).focus();
  },
  scrollTo: function(element_id) {
    var theElement = Platform.element(element_id);
    var selectedPosX = 0;
    var selectedPosY = 0;
    while(theElement != null){
      selectedPosX += theElement.offsetLeft;
      selectedPosY += theElement.offsetTop;
      theElement = theElement.offsetParent;
    }
    window.scrollTo(selectedPosX,selectedPosY);
  }
}

/****************************************************************************
**** Platform Lightbox
****************************************************************************/

Platform.Lightbox = function() {
  this.container                = document.createElement('div');
  this.container.className      = 'platform_lightbox';
  this.container.id             = 'platform_lightbox';
  this.container.style.display  = "none";

  this.overlay                  = document.createElement('div');
  this.overlay.className        = 'platform_lightbox_overlay';
  this.overlay.id               = 'platform_lightbox_overlay';
  this.overlay.style.display    = "none";

  document.body.appendChild(this.container);
  document.body.appendChild(this.overlay);
}


Platform.Lightbox.prototype = {

  hide: function() {
    this.container.style.display = "none";
    this.overlay.style.display = "none";
    Platform.Utils.showFlash();
  },

  show: function(url, opts) {
    var self = this;
    Platform.Utils.hideFlash();

    this.container.innerHTML = "<div style='font-size:18px;text-align:left;padding:10px;'><img src='/platform/images/spinner.gif' style='vertical-align:middle'>Loading...</div>";

    var overlay_height  = window.innerHeight < screen.availHeight ? screen.availHeight : window.innerHeight;
    var overlay_width   = window.innerWidth  < screen.availWidth  ? screen.availWidth  : window.innerWidth;

    this.overlay.style.position = "fixed";
    this.overlay.style.top      = "0px";
    this.overlay.style.left     = "0px";
    this.overlay.style.dispaly  = "inline";
    this.overlay.style.width    = overlay_width + 'px';
    this.overlay.style.height   = overlay_height + 'px';
    this.overlay.style.display  = "block";

    opts = opts || {}
    opts["width"]   = opts["width"] || (overlay_width / 2);
    opts["height"]  = opts["height"] || (overlay_height / 2);
    opts["left"]    = (overlay_width - opts["width"])/2;
    opts["top"]     = (overlay_height - opts["height"])/2 - 100;

    this.container.style.position   = "fixed";
    this.container.style.top        = opts["top"] + 'px';
    this.container.style.left       = opts["left"] + 'px';
    this.container.style.width      = opts["width"] + 'px';
    this.container.style.height     = opts["height"] + 'px';
    this.container.style.display    = "block";

    Platform.Utils.update('platform_lightbox', url, {
      evalScripts: true
    });
  }
}

/****************************************************************************
**** Platform Utils
****************************************************************************/

Platform.Utils = {

  hideFlash: function() {
		// alert("Hiding");
    var embeds = document.getElementsByTagName('embed');
    for(i = 0; i < embeds.length; i++) {
        embeds[i].style.visibility = 'hidden';
    } 
	},

  showFlash: function() {
    // alert("Showing");
    var embeds = document.getElementsByTagName('embed');
    for(i = 0; i < embeds.length; i++) {
        embeds[i].style.visibility = 'visible';
    } 
  },

  isOpera: function() {
    return /Opera/.test(navigator.userAgent);
  },

  addEvent: function(elm, evType, fn, useCapture) {
    useCapture = useCapture || false;
    if (elm.addEventListener) {
      elm.addEventListener(evType, fn, useCapture);
      return true;
    } else if (elm.attachEvent) {
      var r = elm.attachEvent('on' + evType, fn);
      return r;
    } else {
      elm['on' + evType] = fn;
    }
  },

  toQueryParams: function (obj) {
    if (typeof obj == 'undefined' || obj == null) return "";
    if (typeof obj == 'string') return obj;

    var qs = [];
    for(p in obj) {
        qs.push(p + "=" + encodeURIComponent(obj[p]))
    }
    return qs.join("&")
  },

  serializeForm: function(form) {
    var els = Platform.element(form).elements;
    var form_obj = {}
    for(i=0; i < els.length; i++) {
      if (els[i].type == 'checkbox' && !els[i].checked) continue;
      form_obj[els[i].name] = els[i].value;
    }
    return form_obj;
  },

  replaceAll: function(label, key, value) {
    while (label.indexOf(key) != -1) {
      label = label.replace(key, value);
    }
    return label;
  },

  getRequest: function() {
    var factories = [
      function() { return new ActiveXObject("Msxml2.XMLHTTP"); },
      function() { return new XMLHttpRequest(); },
      function() { return new ActiveXObject("Microsoft.XMLHTTP"); }
    ];
    for(var i = 0; i < factories.length; i++) {
      try {
        var request = factories[i]();
        if (request != null)  return request;
      } catch(e) {continue;}
    }
  },

  ajax: function(url, options) {
    options = options || {};
    options.parameters = Platform.Utils.toQueryParams(options.parameters);
    options.method = options.method || 'get';

    var self=this;
    if (options.method == 'get' && options.parameters != '') {
      url = url + (url.indexOf('?') == -1 ? '?' : '&') + options.parameters;
    }

    var request = this.getRequest();

    request.onreadystatechange = function() {
      if(request.readyState == 4) {
        if (request.status == 200) {
          if(options.onSuccess) options.onSuccess(request);
          if(options.onComplete) options.onComplete(request);
          if(options.evalScripts) self.evalScripts(request.responseText);
        } else {
          if(options.onFailure) options.onFailure(request)
          if(options.onComplete) options.onComplete(request)
        }
      }
    }

    request.open(options.method, url, true);
    request.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
    request.setRequestHeader('Accept', 'text/javascript, text/html, application/xml, text/xml, */*');
    request.send(options.parameters);
  },

  update: function(element_id, url, options) {
    options.onSuccess = function(response) {
        Platform.element(element_id).innerHTML = response.responseText;
    };
    Platform.Utils.ajax(url, options);
  },

  evalScripts: function(html){
    var script_re = '<script[^>]*>([\\S\\s]*?)<\/script>';
    var matchAll = new RegExp(script_re, 'img');
    var matchOne = new RegExp(script_re, 'im');
    var matches = html.match(matchAll) || [];
    for(var i=0,l=matches.length;i<l;i++){
      var script = (matches[i].match(matchOne) || ['', ''])[1];
      // console.info(script)
      // alert(script);
      eval(script);
    }
  },

  hasClassName:function(el, cls){
    var exp = new RegExp("(^|\\s)"+cls+"($|\\s)");
    return (el.className && exp.test(el.className))?true:false;
  },

  findElement: function (e,selector,el) {
    var event = e || window.event;
    var target = el || event.target || event.srcElement;
    if(target == document.body) return null;
    var condition = (selector.match(/^\./)) ? this.hasClassName(target,selector.replace(/^\./,'')) : (target.tagName.toLowerCase() == selector.toLowerCase());
    if(condition) {
      return target;
    } else {
      return this.findElement(e,selector,target.parentNode);
    }
  },

  cumulativeOffset: function(element) {
    var valueT = 0, valueL = 0;
    do {
      valueT += element.offsetTop  || 0;
      valueL += element.offsetLeft || 0;
      element = element.offsetParent;
    } while (element);
    return [valueL, valueT];
  },

  wrapText: function (obj_id, beginTag, endTag) {
    var obj = document.getElementById(obj_id);

    if (typeof obj.selectionStart == 'number') {
        // Mozilla, Opera, and other browsers
        var start = obj.selectionStart;
        var end   = obj.selectionEnd;
        obj.value = obj.value.substring(0, start) + beginTag + obj.value.substring(start, end) + endTag + obj.value.substring(end, obj.value.length);

    } else if(document.selection) {
        // Internet Explorer
        obj.focus();
        var range = document.selection.createRange();
        if(range.parentElement() != obj)
          return false;

        if(typeof range.text == 'string')
          document.selection.createRange().text = beginTag + range.text + endTag;
    } else
        obj.value += beginTag + " " + endTag;

    return true;
  },

  insertAtCaret: function (areaId, text) {
    var txtarea = document.getElementById(areaId);
    var scrollPos = txtarea.scrollTop;
    var strPos = 0;
    var br = ((txtarea.selectionStart || txtarea.selectionStart == '0') ? "ff" : (document.selection ? "ie" : false ) );

    if (br == "ie") {
      txtarea.focus();
      var range = document.selection.createRange();
      range.moveStart ('character', -txtarea.value.length);
      strPos = range.text.length;
    } else if (br == "ff")
      strPos = txtarea.selectionStart;

    var front = (txtarea.value).substring(0, strPos);
    var back = (txtarea.value).substring(strPos, txtarea.value.length);
    txtarea.value=front+text+back;

    strPos = strPos + text.length;
    if (br == "ie") {
      txtarea.focus();
      var range = document.selection.createRange();
      range.moveStart ('character', -txtarea.value.length);
      range.moveStart ('character', strPos);
      range.moveEnd ('character', 0); range.select();
    }  else if (br == "ff") {
      txtarea.selectionStart = strPos;
      txtarea.selectionEnd = strPos;
      txtarea.focus();
    }
    txtarea.scrollTop = scrollPos;
  },

  toggleKeyboards: function() {
    if(!VKI_attach) return;
    if (!this.keyboardMode) {
      this.keyboardMode = true;

      var elements = document.getElementsByTagName("input");
      for(i=0; i<elements.length; i++) {
        if (elements[i].type == "text") VKI_attach(elements[i]);
      }
      elements = document.getElementsByTagName("textarea");
      for(i=0; i<elements.length; i++) {
        VKI_attach(elements[i]);
      }
    } else {
      window.location.reload();
    }
  },

  displayShortcuts: function() {
    if (platformLightbox)
      platformLightbox.show('/platform/help/lb_shortcuts', {width:400, height:480});
  },

  displayCredits: function() {
    if (platformLightbox)
      platformLightbox.show('/platform/help/lb_credits', {width:420, height:250});
  }

}

/****************************************************************************
**** Platform Initialization
****************************************************************************/

var platformLightbox = null;

function initializePlatform() {
  var setup = function() {
    platformLightbox              = new Platform.Lightbox();

    Platform.Utils.addEvent(document, "keyup", function(event) {
      if (event.keyCode == 27) { // Capture Esc key
        platformLightbox.hide();
      }
    });
  }

  Platform.Utils.addEvent(window, 'load', setup);
}
