/******************************************************************************************************
Class Name         : AccountSearchController_Test
Description        : This class contains unit tests for validating the behavior of Apex class: 
                     AccountSearchController
Created By         : Jeevan D
Created On         : 16-Mar-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/
@IsTest(SeeAllData=false) 
private class AccountSearchController_Test 
{
    static testMethod void verifyAccountSearchController() 
    {
        List<sObject> lstCustomSearchingSettingData = Test.loadData(Custom_Search_Setting__c.sObjectType, 'CustomSearchingSettingData'); 
        Test.Starttest() ; 
            AccountSearchController oAccSearchCon = new AccountSearchController () ;   
            System.Assert( oAccSearchCon != NULL  ) ; 
            System.Assert( oAccSearchCon.close () != NULL ) ; 
            System.Assert( oAccSearchCon.getMyOptions () != NULL ) ; 
            System.Assert( oAccSearchCon.getRecordTypeListAccount () != NULL ) ;
            System.Assert( oAccSearchCon.getRecordTypeListLead () != NULL ) ;
            System.Assert( oAccSearchCon.getRecordTypeList () != NULL ) ;
            System.Assert( oAccSearchCon.getObjectList () != NULL ) ; 
            oAccSearchCon.search() ;   
        Test.StopTest() ; 
    }
    
    static testMethod void icpAccountSearchController() 
    {
        List<sObject> lstCustomSearchingSettingData = Test.loadData(Custom_Search_Setting__c.sObjectType, 'CustomSearchingSettingData'); 
        Test.Starttest() ; 
            AccountSearchController oAccSearchCon = new AccountSearchController () ;
        	FilterListCompController oFilterCriteria = new FilterListCompController();
        	System.Assert( oAccSearchCon != NULL  ) ; 
        	list<String> selectOption = new list<String>();
        	selectOption.add(Constants.AGE_API_Name);
        	list<String> selectOperator = new list<String>();
        	selectOperator.add('equals');
        	list<String> selectTextValue = new list<String>();
        	selectTextValue.add('3');
            oAccSearchCon.oFilterListHandler.lstSelectedField = selectOption;
            oAccSearchCon.oFilterListHandler.lstSelectedOperator = selectOperator;
   	        oAccSearchCon.oFilterListHandler.lstSelectedTextValue = selectTextValue;
            oAccSearchCon.oFilterListHandler.oCompControllerRef = oFilterCriteria;
        	oAccSearchCon.sObjectName = Constants.ACCOUNT_API_NAME;
            oAccSearchCon.sObjectType = Constants.ICP_RT_API_NAME;
            oAccSearchCon.search() ;   
        Test.StopTest() ; 
    }
    
    static testMethod void leadAccountSearchController() 
    {
        List<sObject> lstCustomSearchingSettingData = Test.loadData(Custom_Search_Setting__c.sObjectType, 'CustomSearchingSettingData'); 
        Test.Starttest() ; 
            AccountSearchController oAccSearchCon = new AccountSearchController () ;
        	System.Assert( oAccSearchCon != NULL  ) ; 
        	oAccSearchCon.sObjectName = Constants.LEAD_API_NAME;
        	oAccSearchCon.sObjectType = Constants.ICP_RT_API_NAME;
            oAccSearchCon.search() ;
        Test.StopTest() ; 
    }
}