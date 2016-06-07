/******************************************************************************************************
Class Name         : DemoAutoComplete
Deascription       : This class is used for Generic Search functionality.
Created By         : Vishal Katyare 
Created On         : 05-Oct-2014 
******************************************************************************************************
Modification History:

*******************************************************************************************************/
public with sharing class DemoAutoComplete {
	public String sAccName {
		get;
		set;
	}
	public Id accId {
		get;
		set;
	}
	public String sAccountType {
		get;
		set;
	}
	public String sObjName {
		get;
		set;
	}

	/**
	 * Method name  : DemoAutoComplete
	 * Description  : This is the constructor for the class DemoAutoComplete
	 * Return Type  : NA
	 * Parameter    : void
	 **/

	public DemoAutoComplete() {

		}
		/**
		 * Method name  : refresh
		 * Description  : This method is used for refreshing the VF page
		 * Return Type  : PageReference
		 * Parameter    : void
		 **/

	public PageReference refresh() {
			return null;
		}
		/**
		 * Method name  : getAccounts
		 * Description  : This method is used for searching an object with keywords as Name and Record Type
		 * Return Type  : list<sObject>
		 * Parameter    : String, String, String
		 **/
		@ReadOnly
		@RemoteAction
	public static list<sObject> getAccounts(String sObjName, string sName,
		string sObjectType) {
			System.debug('In DAC');
		list<sObject> lstAcc = new list<sObject>();
		sObjName = sObjName.escapeCsv();
		sObjName = sObjName.escapeHtml4();
		if(sName != '') {
			String query = 'select name from ' + sObjName + ' where Name like \'%' +
				String.escapeSingleQuotes(sName) + '%\' AND recordType.Name like \'%' +
				sObjectType + '%\'';
			try{
				lstAcc = database.query(query);
			}catch(System.QueryException oQe){
				ErrorLogUtility.logGeneralError(oQe, 'DemoAutoComplete', 
					'getAccounts', 'SFDC CI');
			}
		}
		return lstAcc;
	}
}