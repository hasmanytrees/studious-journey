/************************************************************************
*Class Name         : GenericAttendanceTrackingExtension
*Description        : This is VisualForce extension class which redirects to either CDSP Attendance form or CSP Attendance form  
					  based on Class type of Yearly Class.
*Created By         : Himanshu Raichandani 
*Created On         : 03/07/2015
********************************************************************************/
public with sharing class GenericAttendanceTrackingExtension {
	
	private Monthly_Class_Schedule__c oMonthly;

	/**
	 * Method name  : GenericAttendanceTrackingExtension
	 * Description  : GenericAttendanceTrackingExtension Constructor
	 * Return Type  : NA
	 * Parameter    : ApexPages.StandardController
	 **/
	public GenericAttendanceTrackingExtension(ApexPages.StandardController controller){
		oMonthly = (Monthly_Class_Schedule__c)controller.getrecord();
	}
	
	/**
	 * Method name  : redirectToActualPage
	 * Description  : Based on Class type of yearly, this method redirects Tutor to CDSP or CSP Attendance form.
	 * Return Type  : PageReference
	 * Parameter    : void
	 **/
	public PageReference redirectToActualPage(){
		
		PageReference oPageRef = null;
		if(oMonthly.Class_Type__c.equals(Label.Home_Visits)){
			oPageRef = new PageReference(Constants.CSP_BENEF_ATTN_PAGE_URL+oMonthly.Id);
		}else{
			oPageRef = new PageReference(Constants.CDSP_BENEF_ATTN_PAGE_URL+oMonthly.Id); 
		}
        oPageRef.setRedirect(true);
        return oPageRef; 
	}
}