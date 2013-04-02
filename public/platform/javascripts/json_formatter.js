/*************************************************************************
# Copyright (c) 2013 Michael Berkovich
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*************************************************************************/

var JSONFormatter = function(json, element, opts) {
  this.json = json;
  this.parentElement = this.element(element);
  this.opts = opts || {};
  this.object_keys = [];

  this.container = document.createElement('div');
  if (this.opts['hide_border']) {
    this.container.style.padding = '0px';
    this.container.style.border = '0px';
  } else {
    this.container.style.border = '1px solid #ccc';
    this.container.style.borderRadius = '10px';
    this.container.style.padding = '10px';
  }

  this.container.style.fontFamily = 'Verdana';
  this.container.style.fontSize = '10px';
  this.container.style.margin = '5px';
  this.displayFormatted();

  if (!this.opts['hide_toolbar']) {
    this.buttons = this.createButtons();
    this.parentElement.appendChild(this.buttons);
  }
  this.parentElement.appendChild(this.container);
}

JSONFormatter.prototype = {
  createButtons: function() {
    var buttons = document.createElement('div');
    buttons.style.float = 'right';
    buttons.style.display = 'inline-block';
    buttons.style.padding = '10px';
    buttons.style.marginLeft = '10px';
    buttons.style.marginRight = '10px';
    buttons.style.backgroundColor = '#eee';
    buttons.style.border = '1px solid #ccc';
    buttons.style.borderRadius = '10px';

    var link = document.createElement('div');
    link.appendChild(this.createImage('page_white_code.png'));
    link.style.paddingBottom = '5px';
    link.style.color = '#0e84b5';
    link.style.cursor = 'pointer';
    link.onclick = function () {
      this.displayFormatted();
    }.bind(this);
    buttons.appendChild(link);

    link = document.createElement('div');
    link.appendChild(this.createImage('page_white_text.png'));
    link.style.paddingBottom = '5px';
    link.style.cursor = 'pointer';
    link.style.color = '#0e84b5';
    link.onclick = function () {
      this.displayRaw();
    }.bind(this);
    buttons.appendChild(link);

    link = document.createElement('div');
    link.appendChild(this.createImage('delete.png'));
    link.style.paddingBottom = '5px';
    link.style.textAlign = 'center';
    link.style.color = '#0e84b5';
    link.style.cursor = 'pointer';
    link.onclick = function () {
      this.collapseAll();
    }.bind(this);
    buttons.appendChild(link);

    link = document.createElement('div');
    link.appendChild(this.createImage('add.png'));
    link.style.paddingBottom = '5px';
    link.style.textAlign = 'center';
    link.style.color = '#0e84b5';
    link.style.cursor = 'pointer';
    link.onclick = function () {
      this.expandAll();
    }.bind(this);
    buttons.appendChild(link);
    return buttons;
  },

  rawData: function() {
    return JSON.stringify(this.json);
  },

  displayRaw: function() {
    this.removeAllChildren(this.container);
    this.container.innerHTML = this.rawData();
  },

  displayFormatted: function() {
    this.removeAllChildren(this.container);
    this.lineCounter = 1; 

    var line = document.createElement('div');
    line.style.borderBottom = '1px solid #eee';
    line.appendChild(this.createSpacer(1));
    line.appendChild(this.formatObject(this.json, 2));
    this.container.appendChild(line);
  },

  element:function(element_id) {
    if (typeof element_id == 'string') return document.getElementById(element_id);
    return element_id;
  },

  removeAllChildren:function(element_id) {
    while (this.element(element_id).hasChildNodes()) {
        this.element(element_id).removeChild(this.element(element_id).lastChild);
    }    
  },

  createImage: function(name) {
    var base_url = this.opts["base_url"] || "/images/components/json_formatter/";
    var img = document.createElement('img');
    img.src = base_url + name;
    return img;
  },

  S4:function() {
    return (((1+Math.random())*0x10000)|0).toString(16).substring(1);
  },

  guid:function() {
    return (this.S4()+this.S4()+"-"+this.S4()+"-"+this.S4()+"-"+this.S4()+"-"+this.S4()+this.S4()+this.S4());
  },

  show: function(obj_key) {
    this.element("no_object_" + obj_key).style.display = 'none';
    this.element("object_" + obj_key).style.display = 'inline';
  },

  hide: function(obj_key) {
    this.element("object_" + obj_key).style.display = 'none';
    this.element("no_object_" + obj_key).style.display = 'inline';
  },  

  toggle: function(obj_key) {
    if (this.element("object_" + obj_key).style.display == 'none') 
      this.show(obj_key);
    else
      this.hide(obj_key);
  },

  expandAll: function() {
    for (var i=0; i<this.object_keys.length; i++) {
      this.show(this.object_keys[i]["key"]);
    }
  },

  collapseAll: function() {
    for (var i=0; i<this.object_keys.length; i++) {
      if (this.object_keys[i]["level"] < 3) continue;
      this.hide(this.object_keys[i]["key"]);
    }
  },

  formatObject: function(obj, level) {
    var container = document.createElement('span');
    if (obj == null)  {
      container.appendChild(this.createParen("{"));
      container.appendChild(this.createBreak());
      container.appendChild(this.createParen("}"));
      return container;
    }

    var obj_key = this.guid();  
    this.object_keys.push({"key": obj_key, "level": level});

    var line = this.createLine();

    var collapsed = document.createElement('span');
    collapsed.id = 'no_object_' + obj_key;
    collapsed.style.display = 'none';
    collapsed.appendChild(this.createExpander(obj_key));
    collapsed.appendChild(this.createParen("{...}"));
    if (level>2) {
      collapsed.appendChild(this.createComma());
    }
    container.appendChild(collapsed);

    var expanded = document.createElement('span');
    expanded.id = 'object_' + obj_key;
    expanded.appendChild(this.createCollapser(obj_key));
    expanded.appendChild(this.createParen("{"));
    expanded.appendChild(this.createBreak());
    container.appendChild(expanded);    

    var keys = Object.keys(obj).sort();
    
    for (var i=0; i<keys.length; i++) {
      key = keys[i];
      var line = this.createLine();
      line.appendChild(this.createSpacer(level));

      if (this.isObject(obj[key])) {
        line.appendChild(this.createName(key));

        if (this.isArray(obj[key])) {
          line.appendChild(this.formatArray(obj[key], level + 1));
        } else {
          line.appendChild(this.formatObject(obj[key], level + 1));
        }

      } else {
        line.appendChild(this.formatProperty(key, obj[key]));
        line.appendChild(this.createComma());
      }
      // expanded.appendChild(this.createBreak());
      expanded.appendChild(line);
    }

    var line = this.createLine();
    line.appendChild(this.createSpacer(level-1));
    line.appendChild(this.createParen("}"));
    if (level>2) {
      line.appendChild(this.createComma());
    }
    expanded.appendChild(line);
    return container;
  },

  formatArray: function(arr, level) {
    var container = document.createElement('span');

    var obj_key = this.guid();  
    this.object_keys.push({"key": obj_key, "level": level});

    var collapsed = document.createElement('span');
    collapsed.id = 'no_object_' + obj_key;
    collapsed.style.display = 'none';
    collapsed.appendChild(this.createExpander(obj_key));
    collapsed.appendChild(this.createParen("[...]"));
    if (level>2) {
      collapsed.appendChild(this.createComma());
    }
    container.appendChild(collapsed);

    var expanded = document.createElement('span');
    expanded.id = 'object_' + obj_key;
    container.appendChild(expanded);    
    expanded.appendChild(this.createCollapser(obj_key));
    expanded.appendChild(this.createParen("["));
    expanded.appendChild(this.createBreak());

    for (var i=0; i<arr.length; i++) {
      var line = this.createLine();
      line.appendChild(this.createSpacer(level));

      if (this.isObject(arr[i])) {

        if (this.isArray(arr[i])) {
          line.appendChild(this.formatArray(arr[i], level + 1));
        } else {
          line.appendChild(this.formatObject(arr[i], level + 1));
        }

      } else {
        line.appendChild(this.formatProperty(null, arr[i]));
        line.appendChild(this.createComma());
      }
      // expanded.appendChild(this.createBreak());
      expanded.appendChild(line);
    }  

    var line = this.createLine();
    line.appendChild(this.createSpacer(level-1));
    line.appendChild(this.createParen("]"));
    line.appendChild(this.createComma());
    expanded.appendChild(line);

    // expanded.appendChild(this.createSpacer(level-1));
    // expanded.appendChild(this.createParen("]"));
    return container;
  },

  createLine: function() {
    var line = document.createElement('div');
    line.style.borderTop = '1px solid #F7F7F7';
    if (this.opts["mouseover"]) {
      line.onmouseover = function(evt) {
        this.style.backgroundColor = "#F7F7F7";
        evt.stopPropagation();
      }
      line.onmouseout = function(evt) {
        this.style.backgroundColor = "#fff";
        evt.stopPropagation();
      }
    }
    return line;
  },

  createCollapser: function(obj_key) {
    var expander = document.createElement('span');
    expander.id = 'expander_' + obj_key;
    expander.className = 'expander';
    expander.style.cursor = 'pointer';
    expander.style.paddingRight = '5px';
    expander.onclick = function () {
      this.toggle(obj_key);
    }.bind(this);
    expander.appendChild(this.createImage('minus_node.png'));
    return expander;
  },

  createExpander: function(obj_key) {
    var expander = document.createElement('span');
    expander.id = 'expander_' + obj_key;
    expander.className = 'expander';
    expander.style.cursor = 'pointer';
    expander.style.paddingRight = '5px';
    expander.onclick = function () {
      this.toggle(obj_key);
    }.bind(this);
    expander.appendChild(this.createImage('plus_node.png'));
    return expander;
  },

  createLineNumber: function(num) {
    var line_id = this.parentElement.id + "-" + num;
    var container = document.createElement('a');
    container.name = line_id;

    var lineNumber = document.createElement('div');
    lineNumber.innerHTML = num;
    lineNumber.style.display = 'inline-block';
    lineNumber.style.cursor = 'pointer';
    lineNumber.style.fontSize = '10px';
    lineNumber.style.width = '10px';
    lineNumber.style.textAlign = 'right';
    lineNumber.style.color = '#ccc';
    
    lineNumber.onclick = function () {
      var currentLocation = window.location + "";
      currentLocation = currentLocation.substring(0, currentLocation.indexOf("#"));
      window.location = currentLocation + "#" + line_id;
    }.bind(this);

    container.appendChild(lineNumber);
    return container;
  },

  createBreak: function() {
    return document.createElement('br');
  },

  createParen: function(ch) {
    var paren = document.createElement('span');
    paren.style.color = "#888";
    paren.innerHTML = ch;
    return paren;
  },

  createComma: function() {
    var comma = document.createElement('span');
    comma.innerHTML = ',';
    return comma;
  },

  createSpacer: function(level) {
    var container = document.createElement('span');
    container.appendChild(this.createLineNumber(this.lineCounter ++));

    var spacer = document.createElement('div');
    spacer.style.display = 'inline-block';
    spacer.style.width = (level * 20) + 'px'; 
    spacer.innerHTML = " ";
    container.appendChild(spacer);

    return container;
  },

  createName: function(key) {
    var name = document.createElement('span');
    name.style.paddingRight = '3px';
    // name.style.fontWeight = 'bold';
    name.style.color = '#888';
    name.innerHTML = key + (this.opts["separator"] || ":");
    return name;
  },

  isArray: function(obj) {
    return !(obj.constructor.toString().indexOf("Array") == -1);
  },

  isObject: function(obj) {
    return (typeof obj == 'object');
  },

  isBoolean: function(obj) {
    return (typeof obj == 'boolean');
  },

  isString: function(obj) {
    return (typeof obj == 'string');
  },

  isURL: function(str) {
    str = "" + str;
    return (str.indexOf("http://") != -1) || (str.indexOf("https://") != -1);
  },

  formatProperty: function(key, value) {
    var container = document.createElement('span');

    var val = document.createElement('span');
    if (this.isURL(value)) {
      val.appendChild(this.createParen('"'));
      var v = document.createElement('a');
      v.style.color = '#0e84b5';
      v.style.textDecoration = 'none';
      v.target = '_new';
      v.href = value;
      v.innerHTML = value;
      val.appendChild(v);
      val.appendChild(this.createParen('"'));
    } else if (this.isString(value)) {
      val.appendChild(this.createParen('"'));
      var v = document.createElement('span');
      v.innerHTML = value;
      v.style.color = '#007020';
      val.appendChild(v);
      val.appendChild(this.createParen('"'));
    } else if (this.isBoolean(value)) {
      val.innerHTML = value;
      val.style.color = 'blue';
    } else {
      val.innerHTML = value;
      val.style.color = 'red';
    }
  
    container.appendChild(val);
    if (key == null)
      return container;
    
    container.appendChild(this.createName(key));
    container.appendChild(val);

    return container;
  }
}