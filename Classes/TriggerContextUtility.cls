/******************************************************************************************************
Class Name         : TriggerContextUtility
Description        : This class is a placeholder for static boolean variables to avoid recursive calls from triggers 
Created By         : Himanshu Raichandani
Created On         : 05-Feb-2015
******************************************************************************************************
Modification History:

*******************************************************************************************************/

public class TriggerContextUtility {

    public static boolean bFirstRun = true;
    public static boolean bBleFirstRun = true;
    public static boolean bIntegrationFirstRun = true;
    public static boolean bTransferBLEFirstRun = true;
    public static boolean bPrimaryCaregiverFirstRun = true;
    public static boolean bSndToUSIntegFirstRunCommit = true;
    public static boolean bBleTransferClosedFirstRun = true;
    public static boolean bSendToAMIntegFirstRun = true;
    public static boolean bSendICPBenefToAMIntegFirstRun = true;
    public static boolean bSendICPBenefTestToAMIntegFirstRun = true;
    public static boolean bUpdateActiveConnectUserCountFirstRun = true;
    public static boolean bInactivateUsers = true;
    public static boolean bSwitchOnAccountTrigger = true;
    public static boolean bSwitchOnCommunicationTrigger = true;
    
    
    public static boolean bFlagForTestDataBLEInsertion = true;
    public static boolean bRetryMechanism = true;
    public static Set<Id> setBenefIdsSentToAM = new Set<Id>();
    public static Set<Id> setBenefIdsSentToUS = new Set<Id>();
    public static boolean bFlagForActiveConnectUserCount = true; // KN: Defect fix to prevent validation rule from firing twice
    
    /**
     * Method name  : switchOffAccountTrigger
     * Description  : This method sets the boolean to false
     * Return Type  : void
     * Parameter    : void
     **/
    public static void switchOffAccountTrigger() {
        bSwitchOnAccountTrigger = false;
    }
    
    /**
     * Method name  : switchOffCommunicationTrigger
     * Description  : This method sets the boolean to false
     * Return Type  : void
     * Parameter    : void
     **/
    public static void switchOffCommunicationTrigger() {
        bSwitchOnCommunicationTrigger = false;
    }
    
    /**
     * Method name  : isFirstRun
     * Description  : This method returns true if the method concatenateICPIDLocalBeneficiaryNumber is run for the first time
     * Return Type  : boolean
     * Parameter    : void
     **/
    public static boolean isFirstRun() {
        return bFirstRun;
    }

    /**
     * Method name  : setFirstRunFalse
     * Description  : This method sets the boolean to false after the first run of concatenateICPIDLocalBeneficiaryNumber
     * Return Type  : void
     * Parameter    : void
     **/
    public static void setFirstRunFalse() {
        bFirstRun = false;
    }

    /**
     * Method name  : isBLEFirstRun
     * Description  : This method returns true if the ble method is run for the first time
     * Return Type  : boolean
     * Parameter    : void
     **/
    public static boolean isBLEFirstRun() {
        return bBleFirstRun;
    }

    /**
     * Method name  : setBLEFirstRunFalse
     * Description  : This method sets the boolean to false after the first run of ble method
     * Return Type  : void
     * Parameter    : void
     **/
    public static void setBLEFirstRunFalse() {
        bBleFirstRun = false;
    }

    /**
     * Method name  : setBLETransferClosedFirstRun
     * Description  : This method returns true if the ble Transfer Closed method is run for the first time
     * Return Type  : boolean
     * Parameter    : void
     **/
    public static boolean setBLETransferClosedFirstRun() {
        return bBleTransferClosedFirstRun;
    }

    /**
     * Method name  : setBLETransferClosedFirstRunFalse
     * Description  : This method sets the boolean to false after the first run of ble Transfer Closed method
     * Return Type  : void
     * Parameter    : void
     **/
    public static void setBLETransferClosedFirstRunFalse() {
        bBleTransferClosedFirstRun = false;
    }

    /**
     * Method name  : isIntegrationFirstRun
     * Description  : This method returns true if call to neuron for beneficiary information is for the first time
     * Return Type  : boolean
     * Parameter    : void
     **/
    public static boolean isIntegrationFirstRun() {
        return bIntegrationFirstRun;
    }

    /**
     * Method name  : setIntegrationFirstRunFalse
     * Description  : This method sets the boolean to false after the first call to neuron
     * Return Type  : void
     * Parameter    : void
     **/
    public static void setIntegrationFirstRunFalse() {
        bIntegrationFirstRun = false;
    }
    
    /**
     * Method name  : isTransferBLEFirstRun
     * Description  : This method returns true if the method concatenateICPIDLocalBeneficiaryNumber is run for the first time
                      for duplication check on BLE
     * Return Type  : boolean
     * Parameter    : void
     **/
    public static boolean isTransferBLEFirstRun() {
        return bTransferBLEFirstRun;
    }
    
    /**
     * Method name  : setTransferBLEFirstRunFalse
     * Description  : This method sets the boolean to false after the first run of concatenateICPIDLocalBeneficiaryNumber
                      for duplication check on BLE
     * Return Type  : void
     * Parameter    : void
     **/
    public static void setTransferBLEFirstRunFalse() {
        bTransferBLEFirstRun = false;
    }

    /**
     * Method name  : setPrimaryCaregiverFirstRunFalse
     * Description  : This method sets the boolean to false after the first run of updatePrimaryCaregiver method in AccountHandler
     * Return Type  : void
     * Parameter    : void
     **/
    public static void setPrimaryCaregiverFirstRunFalse() {
        bPrimaryCaregiverFirstRun = false;
    }
}