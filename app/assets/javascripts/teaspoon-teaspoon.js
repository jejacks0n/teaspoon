(function() {
  var TeaspoonInterface,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  TeaspoonInterface = (function() {
    function TeaspoonInterface() {
      this.filter = __bind(this.filter, this);
      this.files = $u("#teaspoon-suite-list .file a");
      this.input = $u("#teaspoon-filter-input")[0];
      this.input.value = "";
      this.input.onkeyup = this.filter;
    }

    TeaspoonInterface.prototype.filter = function() {
      var file, _i, _len, _ref, _results;
      _ref = this.files;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        file = _ref[_i];
        if (LiquidMetal.score(file.innerHTML, this.input.value) > 0) {
          _results.push(file.parentNode.style.display = "block");
        } else {
          _results.push(file.parentNode.style.display = "none");
        }
      }
      return _results;
    };

    return TeaspoonInterface;

  })();

  window.onload = function() {
    return new TeaspoonInterface();
  };

  
/*!
 * LiquidMetal
 * Copyright (c) 2009, Ryan McGeary (ryanonjavascript -[at]- mcgeary [*dot*] org)
 */
var LiquidMetal=function(){var l=0.0;var m=1.0;var n=0.8;var o=0.9;var p=0.85;return{score:function(a,b){if(b.length==0)return n;if(b.length>a.length)return l;var c=this.buildScoreArray(a,b);var d=0.0;for(var i=0;i<c.length;i++){d+=c[i]}return(d/c.length)},buildScoreArray:function(a,b){var d=new Array(a.length);var e=a.toLowerCase();var f=b.toLowerCase().split("");var g=-1;var h=false;for(var i=0;i<f.length;i++){var c=f[i];var j=e.indexOf(c,g+1);if(j<0)return fillArray(d,l);if(j==0)h=true;if(isNewWord(a,j)){d[j-1]=1;fillArray(d,p,g+1,j-1)}else if(isUpperCase(a,j)){fillArray(d,p,g+1,j)}else{fillArray(d,l,g+1,j)}d[j]=m;g=j}var k=h?o:n;fillArray(d,k,g+1);return d}};function isUpperCase(a,b){var c=a.charAt(b);return("A"<=c&&c<="Z")}function isNewWord(a,b){var c=a.charAt(b-1);return(c==" "||c=="\t")}function fillArray(a,b,c,d){c=Math.max(c||0,0);d=Math.min(d||a.length,a.length);for(var i=c;i<d;i++){a[i]=b}return a}}();

/*!
 * uSelector
 * author: Fabio Miranda Costa | github: fabiomcosta | twitter: @fabiomiranda | license: MIT-style license
 */
(function(h,i){var f,c,j,k,m={},e,l,q=/^\s+|\s+$/g,r=!!i.querySelectorAll,g=function(d,b,a){f=a||[];e=b||g.context;if(r)try{n(e.querySelectorAll(d));return f}catch(v){}l=e.ownerDocument||e;d=d.replace(q,"");for(c={};d=d.replace(/([#.:])?([^#.:]*)/,s););d=(b=c.id)&&c.tag||c.classes||c.pseudos||!b&&(c.classes||c.pseudos)?t:o;if(b){if(a=b=l.getElementById(b))if(!(a=l===e))a:{a=b;do if(a===e){a=true;break a}while(a=a.parentNode);a=false}a&&d([b])}else d(e.getElementsByTagName(c.tag||"*"));return f},u=function(d){if(c.tag){var b=d.nodeName.toUpperCase();if(c.tag=="*"){if(b<"@")return false}else if(b!=c.tag)return false}if(c.id&&d.getAttribute("id")!=c.id)return false;if(j=c.classes){var a=" "+d.className+" ";for(b=j.length;b--;)if(a.indexOf(" "+j[b]+" ")<0)return false}if(k=c.pseudos)for(b=k.length;b--;){a=m[k[b]];if(!(a&&a.call(g,d)))return false}return true},s=function(d,b,a){if(b)if(b=="#")c.id=a;else if(b==".")if(c.classes)c.classes.push(a);else c.classes=[a];else{if(b==":")if(c.pseudos)c.pseudos.push(a);else c.pseudos=[a]}else c.tag=a.toUpperCase();return""},p=Array.prototype.slice,n=function(d){f=p.call(d,0)},o=function(d){for(var b=0,a;a=d[b++];)f.push(a)};try{p.call(i.documentElement.childNodes,0)}catch(w){n=o}var t=function(d){for(var b=0,a;a=d[b++];)u(a)&&f.push(a)};g.pseudos=m;g.context=i;h.uSelector=g;h.$u||(h.$u=g)})(this,document);
;

}).call(this);
