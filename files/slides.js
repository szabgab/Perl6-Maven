
// source: http://www.geekpedia.com/tutorial138_Get-key-press-event-using-JavaScript.html
document.onkeyup = KeyCheck; 
function KeyCheck(e) {
   var KeyID = (window.event) ? event.keyCode : e.keyCode;
//alert(KeyID);

   switch(KeyID) {
      //case 16:
      //document.Form1.KeyName.value = "Shift";
      //break; 
      //case 17:
      //document.Form1.KeyName.value = "Ctrl";
      //break;
      //case 18:
      //document.Form1.KeyName.value = "Alt";
      //break;

      case 72:
		// h
		// hide/show .remark classes
		//alert(72);
		toggle_remarks();
	  break;

      case 19:
      //"Pause";
      break;

      case 37:
      //('Arrow Left');
	  go_prev()
      break;

      case 38:
      //"Arrow Up";
      break;

      case 39:
      //"Arrow Right";
      	go_next();
      break;
	  case 32:
		// Space
		go_next();
      break;

	  case 33:
	  // PageUp
		 go_prev();
	  break;
	  case 34:
		go_next();
	  // PageDown
	  break;

	  
	  // 27 (ESC), 116 (F5) alternating when clicking the lower left button on R400
	  case 27:
	  //alert("ESC");
	  // ESC
	  break
	  case 116:
	  //alert("F5");
	  // F5
	  break;
	  
	  // 66 (b) when clicking the lower right on R400
      case 66:
	  alert("b");
      break	  
      case 40:
      //"Arrow Down";
      break;
	  
	  //default:
	  //alert(KeyID);
	  
   }
   
}

function go_next() {
	if (next_page) {
		document.location.href = next_page + ".html";
	} else {
		alert('Sorry, there are no further pages');
	}
}

function go_prev() {
	if (previous_page) {
		document.location.href = previous_page + ".html";
	} else {
		alert('Sorry, there is no previous page.');
	}
}

// http://forums.devshed.com/javascript-development-115/javascript-get-all-elements-of-class-abc-24349.html
// getElementsByClassName() for IE
//
function toggle_remarks(t) {
	var nl = document.getElementsByClassName('remark');
	for (var i = 0; i < nl.length; i++) {
		if (t == 1 || nl[i].style.display == 'none') {
			nl[i].style.display =  "block";
		} else {
			nl[i].style.display =  "none";
		}
	}
}

$(document).ready(function()
    {
	$(".programlisting").addClass("sh_perl");
        var startingStyle = $.cookie('css') ? $.cookie('css') : 'http://st.pimg.net/tucs/css/sh_none.min.css';
        $.fn.styleSwitch(startingStyle);
        $("#styleswitch").val(startingStyle);
        sh_highlightDocument();
        $("#styleswitch").bind(($.browser.msie ? "click" : "change"), function() {
            $.fn.styleSwitch($(this).val());
        });
		
	toggle_remarks(0);
});

