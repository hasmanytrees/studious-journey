/******************************************************************************************************
Class Name         : BeneficiaryImpactListController
Description        : This is VisualForce controller for the Page BeneficiaryImpactList, which helps
                     display the list of Beneficiary Impacts added and modified for a specific duration
                     for the associated Master Disaster record.
Created By         : Sudipta Nayak
Created On         : 24-Jul-2015
******************************************************************************************************
Modification History:

*******************************************************************************************************/

public with sharing class BeneficiaryImpactListController {

    public ImpactListComponentController oImpactListComponentController {
        get;
        set;
    }
    public List<Beneficiary_Impact__c> lstBeneficiaryImpactsCreated {
        get;
        set;
    }
    public List<Beneficiary_Impact__c> lstBeneficiaryImpactsUpdated {
        get;
        set;
    }
    public ApexPages.StandardSetController setBeneficiaryCreated {
        get;
        set;
    }
    public ApexPages.StandardSetController setBeneficiaryModified {
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
     * Method name  : BeneficiaryImpactListController
     * Description  : This is the constructor method of BeneficiaryImpactListController class.
     * Return Type  : NA
     * Parameter    : void
     **/
    public BeneficiaryImpactListController() {
        System.debug('BeneficiaryImpactListController entry');
        oComRecUpdate = new Communication_Update__c();
        bIsCreateListEmpty = bIsUpdateListEmpty = false;
        queryBeneficiaryImpacts();
        
        if(lstBeneficiaryImpactsCreated.isEmpty())
            bIsCreateListEmpty = true;
        if(lstBeneficiaryImpactsUpdated.isEmpty())
            bIsUpdateListEmpty = true;
        sURLForInsert = exportData(Constants.BEN_IMPACT_CREATED_DATE_API_NAME, true);
        sURLForUpdate = exportData(Constants.BEN_IMPACT_MODIFIED_DATE_API_NAME, false);
        oImpactListComponentController = new ImpactListComponentController();
        System.debug('BeneficiaryImpactListController exit');
    }
    
    /**
     * Method name  : queryBeneficiaryImpacts
     * Description  : This method queries the Beneficiary Impact List to be displayed.
     * Return Type  : void
     * Parameter    : void
     **/
    public void queryBeneficiaryImpacts() {
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
        
        lstBeneficiaryImpactsCreated = [Select id,
                BEN_Name__c, BEN_Name__r.Name, Sponsor_Country__c, Sponsor_ID__c,
                Sponsor_Global_ID__c, Correspondent_Country__c, Correspondent_ID__c,
                Correspondent_Global_ID__c, Sponsorship_Status__c, BEN_Disaster_Status__c,
                BEN_Location__c, Local_Beneficiary_ID__c,
                BEN_Physical_Condition__c,BEN_Phy_Condition_Description__c, 
                Number_Caregivers_Died__c, Number_Of_Caregivers_Seriously_Injured__c,
                Number_Siblings_Died__c, Number_Of_Siblings_Seriously_Injured__c,
                House_Condition__c, Lost_Personal_Effects__c, Loss_Of_Livelihood__c 
                from Beneficiary_Impact__c where Disaster_Name__c =: oComRecUpdate.Disaster_Name__c
                 AND(CreatedDate <= : dttmToDate AND CreatedDate>= : dttmFromDate)
            ];
        System.debug('lstBeneficiaryImpactsCreated'+lstBeneficiaryImpactsCreated);       
        setBeneficiaryCreated = new ApexPages.StandardSetController(lstBeneficiaryImpactsCreated);
        System.debug('setBeneficiaryCreated'+setBeneficiaryCreated);
        List<sObject> lstAllBenRecords = setBeneficiaryCreated.getRecords();      
        setBeneficiaryCreated.setPageSize(10);       
        lstBeneficiaryImpactsUpdated = [Select id,
                BEN_Name__c, BEN_Name__r.Name, Sponsor_Country__c, Sponsor_ID__c,
                Sponsor_Global_ID__c, Correspondent_Country__c, Correspondent_ID__c,
                Correspondent_Global_ID__c, Sponsorship_Status__c, BEN_Disaster_Status__c,
                BEN_Location__c, Local_Beneficiary_ID__c,
               BEN_Physical_Condition__c,BEN_Phy_Condition_Description__c,
                Number_Caregivers_Died__c, Number_Of_Caregivers_Seriously_Injured__c,
                Number_Siblings_Died__c, Number_Of_Siblings_Seriously_Injured__c,
                House_Condition__c, Lost_Personal_Effects__c, Loss_Of_Livelihood__c 
                from Beneficiary_Impact__c where Disaster_Name__c = :
                oComRecUpdate.Disaster_Name__c AND ID NOT IN: lstBeneficiaryImpactsCreated AND(
                LastModifiedDate <= : dttmToDate AND LastModifiedDate>=: dttmFromDate)
            ];
        System.debug('lstBeneficiaryImpactsUpdated'+lstBeneficiaryImpactsUpdated);        
        setBeneficiaryModified = new ApexPages.StandardSetController(lstBeneficiaryImpactsUpdated);
        System.debug('setBeneficiaryModified'+setBeneficiaryModified);        
        setBeneficiaryModified.setPageSize(10);
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