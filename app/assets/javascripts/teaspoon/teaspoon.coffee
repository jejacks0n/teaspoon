class TeaspoonInterface

  constructor: ->
    @files = document.querySelectorAll("#teaspoon-suite-list .file a")
    @input = document.querySelector("#teaspoon-filter-input")
    @input.value = ""
    @input.onkeyup = @filter


  filter: =>
    for file in @files
      if LiquidMetal.score(file.innerHTML, @input.value) > 0
        file.parentNode.style.display = "block"
      else
        file.parentNode.style.display = "none"


window.onload = -> new TeaspoonInterface()

`
/*!
 * LiquidMetal
 * Copyright (c) 2009, Ryan McGeary (ryanonjavascript -[at]- mcgeary [*dot*] org)
 */
var LiquidMetal=function(){var l=0.0;var m=1.0;var n=0.8;var o=0.9;var p=0.85;return{score:function(a,b){if(b.length==0)
return n;if(b.length>a.length)return l;var c=this.buildScoreArray(a,b);var d=0.0;for(var i=0;i<c.length;i++){d+=c[i]}
return(d/c.length)},buildScoreArray:function(a,b){var d=new Array(a.length);var e=a.toLowerCase();
var f=b.toLowerCase().split("");var g=-1;var h=false;for(var i=0;i<f.length;i++){var c=f[i];var j=e.indexOf(c,g+1);
if(j<0)return fillArray(d,l);if(j==0)h=true;if(isNewWord(a,j)){d[j-1]=1;fillArray(d,p,g+1,j-1)}else if(isUpperCase(a,j))
{fillArray(d,p,g+1,j)}else{fillArray(d,l,g+1,j)}d[j]=m;g=j}var k=h?o:n;fillArray(d,k,g+1);return d}};
function isUpperCase(a,b){var c=a.charAt(b);return("A"<=c&&c<="Z")}function isNewWord(a,b){var c=a.charAt(b-1);
return(c==" "||c=="\t")}function fillArray(a,b,c,d){c=Math.max(c||0,0);d=Math.min(d||a.length,a.length);
for(var i=c;i<d;i++){a[i]=b}return a}}();
`
