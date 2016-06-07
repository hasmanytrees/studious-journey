/************************************************************************************************** 
Class Name   : EnableDocumentsController_Test
Created By   : Danish Ahmed
Created Date : 18-Nov-2015
Description  : This class contains unit tests for validating the behavior of 
               Apex class: EnableDocumentsController.
******************************************************************************************************
Modification History:

*******************************************************************************************************/

@IsTest(SeeAllData=false)
public class EnableDocumentsController_Test {
    static TestMethod void EnableDocumentsControllerMethod(){
        PageReference pageRef = Page.EnableDocuments;
        Test.setCurrentPage(pageRef);
        EnableDocumentsController oEnableDocumentsController =
            new EnableDocumentsController();
        PageReference oPageReference = oEnableDocumentsController.showDocuments();
        System.assertEquals('/'+Constants.DOCUMENTS_PREFIX+'/o',oPageReference.getUrl());
    }
}