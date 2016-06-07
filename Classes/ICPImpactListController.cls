/******************************************************************************************************
Class Name         : ICPImpactListController
Description        : This is VisualForce controller for the Page ICPImpactList, which displays the list
                     of ICP Impacts added and modified for a specific duration of time for the
                     associated Master Disaster record.
Created By         : Sudipta Nayak
Created On         : 17-Jul-2015
******************************************************************************************************
Modification History:

*******************************************************************************************************/

public with sharing class ICPImpactListController { 

    public ImpactListComponentController oImpactListComponentController {
        get;
        set;
    }
    public List<ICP_Impact__c> lstICPImpactsCreated {
        get;
        set;
    }
    public List<ICP_Impact__c> lstICPImpactsUpdated {
        get;
        set;
    }
    public ApexPages.StandardSetController setICPCreated {
        get;
        set;
    }
    public ApexPages.StandardSetController setICPModified {
        get;
        set;
    }
    public Boolean bIsCreateListEmpty {
        get;
        set;
    }
    public Boolean bIsUpdateListEmpty {
        get;
        set;
    }
    public Communication_Update__c oComRecUpdate {
        get;
        set;
    }
    Public string sURLForInsert {
        get;
        set;
    }
    Public string sURLForUpdate {
        get;
        set;
    }
    Pagereference exportLink;
    Report oReport;
    
    /**
     * Method name  : ICPImpactListController
     * Description  : This is the constructor method of ICPImpactListController class.
     * Return Type  : NA
     * Parameter    : void
     **/
    public ICPImpactListController() {
        System.debug('ICPImpactListController entry');
        oComRecUpdate = new Communication_Update__c();
        bIsCreateListEmpty = bIsUpdateListEmpty = false;
        queryICPImpacts();
        
        if(lstICPImpactsCreated.isEmpty())
            bIsCreateListEmpty = true;
        if(lstICPImpactsUpdated.isEmpty())
            bIsUpdateListEmpty = true;
        sURLForInsert = exportData(Constants.ICP_IMPACT_CREATED_DATE_API_NAME, true);
        sURLForUpdate = exportData(Constants.ICP_IMPACT_MODIFIED_DATE_API_NAME, false);
        oImpactListComponentController = new ImpactListComponentController();
        System.debug('ICPImpactListController exit');
    }
    
    /**
     * Method name  : queryICPImpacts
     * Description  : This method queries the Beneficiary Impact List to be displayed.
     * Return Type  : void
     * Parameter    : void
     **/
    public void queryICPImpacts() {
        id recID = ApexPages.currentPage()
            .getParameters()
            .get(Constants.ID);
        System.debug('recID'+recID);
        oComRecUpdate = [Select id, Disaster_Name__r.Name,
                Communication_Updates_From__c, Communication_Updates_To__c from Communication_Update__c where id = :
                recID
        ];
        DateTime dttmFromDate = oComRecUpdate.Communication_Updates_From__c.addSeconds(-(
            oComRecUpdate.Communication_Updates_From__c.second()));
        DateTime dttmToDate = oComRecUpdate.Communication_Updates_To__c.addSeconds(-(
            oComRecUpdate.Communication_Updates_To__c.second()));
        
        lstICPImpactsCreated = [Select Name, ICP_Name__c,
                ICP_Name__r.Name, ICP_Name__r.ICP_ID__c, ICP_Disaster_Status__c,
                Disaster_Impact_On_ICP_Program__c,
                Disaster_Impact_To_ICP_Infrastructure__c,
                ICP_Disaster_Impact_Description__c from ICP_Impact__c where Disaster_Name__c = :
                oComRecUpdate.Disaster_Name__c AND(CreatedDate <= : dttmToDate AND CreatedDate>=
                    : dttmFromDate)
            ];
        System.debug('lstICPImpactsCreated'+lstICPImpactsCreated);
        setICPCreated = new ApexPages.StandardSetController(lstICPImpactsCreated);
        System.debug('setICPCreated'+setICPCreated);
        List<sObject> lstAllICPRecords = setICPCreated.getRecords();
        setICPCreated.setPageSize(10);
        lstICPImpactsUpdated = [Select Name,
                ICP_Name__c, ICP_Name__r.Name, ICP_Name__r.ICP_ID__c,
                ICP_Disaster_Status__c, Disaster_Impact_On_ICP_Program__c,
                Disaster_Impact_To_ICP_Infrastructure__c,
                ICP_Disaster_Impact_Description__c from ICP_Impact__c where Disaster_Name__c = :
                oComRecUpdate.Disaster_Name__c AND ID NOT IN: lstICPImpactsCreated AND(
                    LastModifiedDate <= : dttmToDate AND LastModifiedDate>=
                    : dttmFromDate)
            ];
        System.debug('lstICPImpactsUpdated'+lstICPImpactsUpdated);
        setICPModified = new ApexPages.StandardSetController(lstICPImpactsUpdated);
        System.debug('setICPModified'+setICPModified);        
        setICPModified.setPageSize(10);
    }
    
    /**
     * Method name  : exportData
     * Description  : This method sets implements the export functionality
     * Return Type  : void
     * Parameter    : String, Boolean, Communication_Update__c
     **/
    public String exportData(String sReportName, Boolean bIsCreated) {
        
        System.debug('sReportName '+sReportName);
        
        oReport = [SELECT DeveloperName, Id FROM Report WHERE DeveloperName =: sReportName];
        exportLink = new Pagereference(Constants.BACKSLASH + oReport.Id);
        exportLink.getParameters()
            .put(Constants.REPORT_PV_0, oComRecUpdate.Disaster_Name__r.Name);
        exportLink.getParameters()
            .put(Constants.REPORT_PV_1, oComRecUpdate.Communication_Updates_From__c.Month() +
                 Constants.BACKSLASH +
                 oComRecUpdate.Communication_Updates_From__c.Day() + Constants.BACKSLASH +
                 oComRecUpdate.Communication_Updates_From__c
                 .Year() + ' ' +oComRecUpdate.Communication_Updates_From__c.format('hh:mm a'));
        exportLink.getParameters()
            .put(Constants.REPORT_PV_2, oComRecUpdate.Communication_Updates_To__c.Month() +
                 Constants.BACKSLASH +
                 oComRecUpdate.Communication_Updates_To__c.Day() + Constants.BACKSLASH +
                 oComRecUpdate.Communication_Updates_To__c
                 .Year() + ' ' +oComRecUpdate.Communication_Updates_To__c.format('hh:mm a'));
        if(!bIsCreated ) {
             exportLink.getParameters()
            .put(Constants.REPORT_PV_3, oComRecUpdate.Communication_Updates_From__c.Month() +
                 Constants.BACKSLASH +
                 oComRecUpdate.Communication_Updates_From__c.Day() + Constants.BACKSLASH +
                 oComRecUpdate.Communication_Updates_From__c
                 .Year() + ' ' +oComRecUpdate.Communication_Updates_From__c.format('hh:mm a'));
        exportLink.getParameters()
            .put(Constants.REPORT_PV_4, oComRecUpdate.Communication_Updates_To__c.Month() +
                 Constants.BACKSLASH +
                 oComRecUpdate.Communication_Updates_To__c.Day() + Constants.BACKSLASH +
                 oComRecUpdate.Communication_Updates_To__c
                 .Year() + ' ' +oComRecUpdate.Communication_Updates_To__c.format('hh:mm a'));
        }
        exportLink.getParameters()
            .put(Constants.EXPORT_TEXT, Constants.EXPORT_1);
        exportLink.getParameters()
            .put(Constants.ENCODING, Constants.UTF_8_ENCODING);
        exportLink.getParameters()
            .put(Constants.EXPORT_XF, Constants.EXPORT_EXCEL);
        String sURLForExport = exportLink.getUrl();
        System.debug('sURLForExport:'+sURLForExport);
        return sURLForExport;
    }    
}