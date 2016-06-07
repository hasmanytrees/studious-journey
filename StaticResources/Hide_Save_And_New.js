if (document.getElementById("swj_SiteWideJavascript") != null) {  
    if (document.getElementById("swj_SiteWideJavascript").parentNode.parentNode.className.indexOf("htmlAreaComponentModule") != -1)   
      document.getElementById("swj_SiteWideJavascript").parentNode.parentNode.style.display = 'none';   
  }
</script>

<script>
  window.onload = function(){    
    //This ensures that your javascript loads after your form elements are rendered
    setFocusOnLoad();    
    if (typeof(startSessionTimer)!='undefined') { startSessionTimer(); };    
    if (typeof(ActivityReminder)!='undefined') { ActivityReminder.initialize([], false, false);};    
    if ((window.sfdcPage) && (sfdcPage.executeOnloadQueue)){sfdcPage.executeOnloadQueue();}; 
    Cookies.prototype.DeleteCookie('setupopen');    
    
    //Replace this section with whatever you need to hide/replace/modify on the standard Salesforce screen
    var x=document.getElementsByName("save_new"); //Here's where you hide your button
    for(var i=0; i<x.length; i++) { 
      x[i].style.visibility="hidden";    
      x[i].style.display="none";
    }
  }