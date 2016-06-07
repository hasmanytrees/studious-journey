/******************************************************************************************************
Class Name         : EnableDocumentsController
Description        : This is a controller class for EnableDocuments Page. This is used to enable 
                     Documents tab for community users.
Created By         : Danish Ahmed
Created On         : 09-Sep-2015 
******************************************************************************************************/

public class EnableDocumentsController{

    public EnableDocumentsController(){
    
    }
    
    /**
    * Method name  : showDocuments
    * Description  : This method will redirect the user to Documents.
    * Return Type  : PageReference
    * Parameter    : void
    **/
    public PageReference showDocuments(){
        pagereference pg = new pagereference ( '/'+Constants.DOCUMENTS_PREFIX+'/o') ; 
        pg.setRedirect(true);
        return pg;            
    }
}