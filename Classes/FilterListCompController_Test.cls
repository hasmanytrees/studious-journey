/******************************************************************************************************
Class Name         : FilterListCompController_Test
Description        : This class contains unit tests for validating the behavior of Apex class: 
                     FilterListCompController
Created By         : Shaik Manzoor
Created On         : 25-Mar-2015 
******************************************************************************************************
Modification History:

*******************************************************************************************************/
@IsTest(SeeAllData=false)
private class FilterListCompController_Test 
{
    static testMethod void verifyFilterListCompController_1() 
    {
        Test.StartTest();
        FilterListCompController oFilterListCompController1  = new FilterListCompController();
        
        oFilterListCompController1.setSSelectedFirstParam('Gender');
        oFilterListCompController1.setSSelectedSecondParam('like');
        oFilterListCompController1.setSSelectedThirdParam('Male');
        oFilterListCompController1.getSSelectedThirdParam();
        oFilterListCompController1.getSSelectedFirstParam();
        oFilterListCompController1.getSSelectedSecondParam();
        oFilterListCompController1.setSSelectedFirstParam('-None-');
        oFilterListCompController1.setSSelectedSecondParam('-None-');
        oFilterListCompController1.setSSelectedThirdParam('Male');
        oFilterListCompController1.setSSelectedFirstParam('Age');
        oFilterListCompController1.setSSelectedSecondParam('like');
        oFilterListCompController1.setSSelectedThirdParam('9');
        oFilterListCompController1.setSSelectedFirstParam('Gender');
        oFilterListCompController1.setSSelectedSecondParam('like');
        oFilterListCompController1.setSSelectedThirdParam('Male,Female');
        oFilterListCompController1.setSSelectedFirstParam('Gender');
        oFilterListCompController1.setSSelectedSecondParam('equals');
        oFilterListCompController1.setSSelectedThirdParam('Male,Female'); 
        oFilterListCompController1.oFilterListHandler.mapValueType.put('Gender','Quote Need');
        oFilterListCompController1.oFilterListHandler.mapValueType.put('Age','multiselect');       
        integer iLastRow = oFilterListCompController1.iLastRow;
        oFilterListCompController1.getIDefaultSize();
        oFilterListCompController1.setOFilterListHandler(oFilterListCompController1.oFilterListHandler);
        oFilterListCompController1.getOFilterListHandler();
        oFilterListCompController1.formQuery();
        oFilterListCompController1.oneLinkCounter();
        System.Assert ( oFilterListCompController1.lstCounter.Size() > 0 ) ;
        Test.StopTest();
    }
    
    static testMethod void verifyFilterListCompController_2() 
    {
        Test.StartTest();
        FilterListCompController oFilterListCompController  = new FilterListCompController();
        oFilterListCompController.sLinkName = System.Label.Fewer_Filter_Link;
        oFilterListCompController.formQuery();
        oFilterListCompController.setIDefaultSize(3);
        oFilterListCompController.oneLinkCounter();
        System.Assert( oFilterListCompController.getiDefaultSize() == 3 ) ; 
        Test.StopTest();
    }
       
}