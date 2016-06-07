/******************************************************************************************************
Class Name         : Constants
Deascription       : This is single Class for all String constants
Created By         : Himanshu Raichandani 
Created On         : 13/02/2015 
******************************************************************************************************/
public class Constants {

    /*Account Record Type API Names*/
    public static final String CSP_BENEFICIARY_RT_API_NAME = 'CSP_Beneficiary';
    public static final String CDSP_BENEFICIARY_RT_API_NAME = 'CDSP_Beneficiary';
    public static final String ICP_RT_API_NAME = 'ICP';
    public static final String FIELD_OFFICE_RT_API_NAME = 'Field_Office';
    public static final String GLOBAL_PARTNER_RT_API_NAME = 'Global_Partner';
    public static final String SUPPORTER_PERSON_RT_API_NAME = 'Supporter_Person';
    
    public static final String Small_Gift_Thank_You_Letter = 'Small Gift Thank You Letter';
    public static final String Large_Gift_Thank_You_Letter = 'Large Gift Thank You Letter';
    public static final String Other_Than_Gift_Letter = 'Other than gift letter';

    /*BLE Record Type API Names*/
    public static final String BLE_TRANSITION_RT_API_NAME = 'Transition';
    public static final String BLE_TRANSFER_RT_API_NAME = 'Transfer';
    public static final String BLE_PLANNED_EXIT_RT_API_NAME = 'Planned_Exit';
    public static final String BLE_UNPLANNED_EXIT_RT_API_NAME = 'Unplanned_Exit';
    public static final String BLE_PLANNED_EXIT_READONLY_RT_API_NAME = 'Planned_Exit_Read_Only';
    public static final String BLE_UNPLANNED_EXIT_READONLY_RT_API_NAME = 'Unplanned_Exit_Read_Only';
    public static final String BLE_REINSTATEMENT_RETURN_RT_API_NAME = 'Reinstatement_Return';
    public static final String BLE_REGISTRATION_RT_API_NAME = 'Registration';
    public static final String BLE_CRGVR_DEATH_RT_API_NAME = 'Caregiver_Death';
    
    /*Content Record Type API Names*/
    public static final String CONTENT_ICP_RT_API_NAME = 'ICP';
    public static final String CONTENT_COMMUNICATION_RT_API_NAME = 'Communication';
    public static final String CONTENT_AP_RT_API_NAME = 'Activity_Plan';
    public static final String CONTENT_BENEFICIARY_RT_API_NAME = 'Beneficiary';
    public static final String CONTENT_BENEF_ASSESMNT_RT_API_NAME = 'Beneficiary_Assessment';
    public static final String CONTENT_BLE_RT_API_NAME = 'Beneficiary_Lifecycle_Event';
    public static final String CONTENT_CASE_RT_API_NAME = 'Case';
    public static final String CONTENT_FO_RT_API_NAME = 'Field_Office';
    public static final String CONTENT_ICP_LEAD_RT_API_NAME = 'ICP_Lead';
    public static final String CONTENT_DISASTER_RT_API_NAME = 'Disaster';
    public static final String CONTENT_MI_RT_API_NAME = 'Medical_Incidents';
    
    /*PM Hierarchy Record Type API Names*/
    public static final String PM_HIERARCHY_CLUSTER_RT_API_NAME = 'Cluster';

    /*Other Record Type API Names*/
    public static final String OPERATIONAL_PLAN_RT_API_NAME = 'Operational_Plan';
    public static final String SETUP_PLAN_RT_API_NAME = 'Set_Up_Plan';
    public static final String ICP_ADDRESS_RT_API_NAME = 'ICP_Address';
    public static final String SUSPENSION_RT_API_NAME = 'Suspension';
    public static final String CDPR_BA_RT_API_NAME = 'CDPR';
    public static final String ICP_LEAD_RT_API_NAME = 'ICP_Lead';
    public static final String CONTACT_GLOB_PART_RT_API_NAME = 'Global_Partners';
    public static final String ICP_MINI_PROFILE_OBJ_NAME = 'ICP_Mini_Profile__c';
    public static final String TRANSITION_ICP_LIFECYCLE_EVENTS_RT_API_NAME =
        'Transition';
    public static final String REACTIVATION_ICP_LIFECYCLE_EVENTS_RT_API_NAME = 
        'Reactivation';
    public static final String CDPR_FO_ADMIN_RT_API_NAME = 'CDPR';
    public static final String CDPR_INDICATORS_GLOBAL_DATA_RT_API_NAME =
        'CDPR_Indicators';
    public static final String BA_Health_Assessment_RT_API_NAME =
        'Health_Assessment';
    public static final String BA_CDPR_RT_API_NAME = 'CDPR';
    public static final String BA_Development_Plan_RT_API_NAME =
        'Development_Plan';
    public static final String BA_Growth_Monitoring_RT_API_NAME =
        'Growth_Monitoring';
    public static final String BENEFICIARY_ASSOCIATION_RT_API_NAME =
        'Beneficiary_CIV_Needs';
    public static final String ACTIVITY_PLAN_OPERATIONAL_RT_API_NAME =
        'Operational_Plan';
    public static final String GLOBAL_DATA_GLOBAL_FREQUENCIES_RT_API_NAME =
        'Global_Frequencies';
    public static final String GLOBAL_DATA_GLOBAL_MALNUTRITION_DATA_RT_API_NAME ='Malnutrition_Data';
    public static final String GLOBAL_DATA_COMM_KIT_DATA_RT_API_NAME =
        'Communication_Kit';
    public static final String GLOBAL_DATA_RANKING_DATA_RT_API_NAME =
        'Ranking_Data';
    public static final String GLOBAL_DATA_NEEDS_DATA_RT_API_NAME = 'Needs_Data';
    public static final String GLOBAL_DATA_CDPR_INDICATORS_RT_API_NAME =
        'CDPR_Indicators';
    public static final String MEDICALINCIDENTS_IMMUNIZATION_RT_API_NAME =
        'Immunization';
    public static final String MEDICALINCIDENTS_ILLNESS_RT_API_NAME = 'Illness';
    public static final String MEDICALINCIDENTS_INJURY_RT_API_NAME = 'Injury';
    public static final String FO_ADMINISTRATION_NEEDS_ADMIN_RT_API_NAME =
        'Needs_Adminstration';
    public static final String ERRORLOG_INTEGRATION =
        'Integration';
    public static final String ERRORLOG_GENERAL =
        'General';  
    public static final String RESPONSE_NOT_YET_GENERATED = 
    'Response Not Yet Generated';
    public static final String INTERNAL_SERVER_ERROR =
        'Internal Server Error'; 
    public static final String ACTIVITY_PLAN_FW_RT_API_NAME = 
        'Facilitation_Workplan';
    public static final String TASK_RT_API_NAME = 
        'Task'; 
    public static final String TASK_GN_RT_API_NAME = 
        'Task'; 
    public static final String GENERAL_CONTACT_RT_API_NAME = 
        'General_Contacts';
    public static final String COMMUNICATION_KIT_S2B_RT = 'S2B';
    public static final String COMMUNICATION_KIT_B2S_RT = 'B2S';
    public static final String COMMUNICATION_TO_COMPASS = 'Compass';
    public static final String COMMUNICATION_TO_US      = 'US';
    /*Integration related Labels like Process, Field Groups, Integration string constants, Error messages etc.*/
    public static final String EXTERNAL_SYSTEM_CONNECTION_ERROR = 
        'Can\'t Download Image due to Connection Error';
    public static final String CREATE_BENEFICIARY_PROCESS_NAME =
        'CreateBeneficiaryProcess';
    public static final String CREATE_BENEFICIARY_FIELD_GROUP =
        'CreateBeneficiaryFieldGroup';
    public static final String EXIT_BLE_RESPONSE_FIELD_GROUP =
        'ExitBLEResponseFieldGroup';
    public static final String BENEFICIARY_RESPONSE_FIELD_GROUP =
        'BeneficiaryResponseFieldGroup';
    public static final String HM_WITH_BEN_RESPONSE_FIELD_GROUP =
        'HouseholdMemWithBenefResponseFieldGroup';
    public static final String BEN_HM_DATA_RESPONSE_PROCESS_NAME =
        'BenefAndHMDataResponseProcess';
    public static final String EXIT_BLE_DATA_RESPONSE_PROCESS_NAME =
        'ExitBLEDataResponseProcess';
    public static final String UPDATE_BENEF_STATUS_PROCESS_NAME =
        'UpdateBenefStatusDataRequestProcess';
    public static final String FETCH_BENEF_INFO_REQUEST_PROCESS =
        'FetchBenefInfoRequestProcess';
    public static final String FETCH_BENEF_STATUS_REQUEST_PROCESS =
        'FetchBenefStatusRequestProcess';
    public static final String FETCH_BENEF_STATUS_RESPONSE_PROCESS =
        'FetchBenefStatusResponseProcess';
    public static final String FETCH_BENEF_STATUS_RESPONSE_FIELD_GROUP =
        'FetchBenefStatusResponseFieldGroup';
    public static final String BULK_IMAGE_RESPONSE_PROCESS_NAME =
        'BulkImageResponseProcess';
    public static final String CONTENT_LINK_REQUEST_GROUP_NAME =
        'ContentLinkRequestGroup';
    public static final String CONTENT_LINK_REQUEST_PROCESS_NAME =
        'ContentLinkRequestProcess';
    public static final String CLOUDINARY_ID_REQUEST_PROCESS_NAME =
        'CloudinaryIdRequestProcess';
    public static final String SUPPORTER_MINI_PROFILE_REQ_PROC_NAME =
        'SupporterMiniProfileRequestProcess';
    public static final String BULK_IMAGE_LOAD_FAIL_HTML_RESPONSE =
        '{"response": {"status": "Failure", "message": "No Beneficiary corresponding to ChildKey found"}}';
    public static final String CONTENT_INSERTION_FAILED_HTML_RESPONSE =
        'Content insertion failed';
    public static final String BENEFICIARY_RECORD_STATUS_IS_DRAFT =
    'Beneficiary Record Status is Draft';
    public static final String CSP_BENEFICIARY_RT_LABEL = 'Survival Beneficiary';
    public static final String CDSP_BENEFICIARY_RT_LABEL = 'Sponsorship Beneficiary';
    public static final String CONTENT_LIST_TOKEN = 'ContentList';
    public static final String CONTENT_LINK_TOKEN = 'ContentLink';
    public static final String ICP_ID_VALIDATION =
        'No matching ICP record found with ICP ID:';
    public static final String LOCAL_BENEFICIARY_ID_VALIDATION =
        'No Local Beneficiary received. Please ensure to send Local Beneficiary Id with the beneficiary';
    public static final String BENEFICIARY_INACTIVE_VALIDATION =
        'Beneficiary Update failed as Beneficiary is in Inactive status';
    public static final String UNDER_APPROVAL_PROCESS_VALIDATION =
        'Beneficiary Update failed as Beneficiary is under Field Office Approval process';
    public static final String UNDER_APPROVAL_PROCESS_VALIDATION_FB =
        'Fetching Beneficiary Information failed as Beneficiary is under Field Office Approval process';
    public static final String FEED_ITEM_TYPE = 'ContentPost';
    public static final String BENEFECIARY_CREATE_UPDATE_EXCEPTION =
        'Exception in createBenefAndHM: ';
    public static final String CONTENT_MISSING_ID_RESPONSE =
        '{"response": {"status": "Failure", "message": "Missing ID"}}';
    public static final String CONTENT_MISSING_ATTACHMENT_ID_RESPONSE =
        '{"response": {"status": "Failure", "message": "Missing AttachmentID"}}';
    public static final String CONTENT_MISSING_JSON_INPUT_RESPONSE =
        '{"response": {"status": "Failure", "message": "Missing JSON Input"}}';
    public static final String CONTENT_FAILURE_RESPONSE =
        '{"response": {"status": "Failure", "message": "';
   public static final String CONTENT_FAILURE_RESPONSE_OTHER_FORMATE =
        '{"Responses": [{"status": "Failure"';
    public static final String CONTENT_NO_ATTACHMENT_FOUND_RESPONSE =
        '{"response": {"status": "Failure", "message": "No Attachment Found"}}';
    public static final String CONTENT_UPLOAD_SUCCESS_RESPONSE =
        '{"response": {"status": "Success", "message": "Content Link Updated Content Id - ';
    public static final String CLOUDINARY_UPLOAD_SUCCESS_RESPONSE =
        '{"response": {"status": "Success", "message": "Cloudinary Id Updated Content Id - ';
    public static final String CONTENT_NO_CONTENT_FOUND_RESPONSE =
        '{"response": {"status": "Failure", "message": "No Content Found for Update"}}';
    public static final String SFDC_ERROR_RESPONSE =
        '{"response": {"status": "Failure", "message": "Internal Server Error"}}';
    public static final String SFDC_BAD_REQUEST_RESPONSE =
        '{"response": {"status": "Failure", "message": "Bad Request"}}';    
    public static final String PHOTO_BENEFICIARY_FULL_BODY = 'Photo - Beneficiary Full Body';
    public static final String BENEFICIARY_RECORD_DOESNT_EXISTS = 'Beneficiary Record doesn\'t exists'; 
    public static final String NO_PERCEPTIVE_URI_PRESENT = 'Perceptive URI not found for this content record';
    public static final String COMM_KIT_FIELD_GROUP = 'SBCCommunicationDetails_Res_FG';
    public static final String COMM_KIT_PROCESS_NAME = 'SBCCommunicationDetails_Res_PN';
    public static final String CREATE_GIFT_RESPONSES_REQ_PN = 'CreateGiftResponses_Req_PN';
    public static final String SBCCOMMUNICATIONDETAILS_REQ_PN = 'SBCCommunicationDetails_Req_PN';
    public static final String SBCCOMMUNICATIONDETAILS_REQ_FG = 'SBCCommunicationDetails_Req_FG';
    public static final String COMMUNICATIONUPDATES_REQ_PN = 'CommunicationUpdates_Req_PN';
    public static final String COMMUNICATIONUPDATES_RES_PN = 'CommunicationUpdates_Res_PN';
    public static final String COMMUNICATIONUPDATES_RES_FG = 'CommunicationUpdates_Res_FG';
    public static final String COMMUNICATION_RESPONSES_PN = 'Responses_PN';
    public static final String COMMUNICATION_RESPONSES_FG = 'Responses_FG';
    public static final String COMMUNICATION_DELETION_RES_FG = 'CommunicationDeletion_Res_FG';
    public static final String COMMUNICATION_DELETION_RES_PN = 'CommunicationDeletion_Res_PN';
    public static final String COMMITMENT_UPDATES_REQ_PN = 'CommitmentUpdates_Req_PN';
    public static final String COMMITMENT_UPDATES_REQ_FG = 'CommitmentUpdates_Req_FG';
    public static final String USA_ESB_URL_FOR_BENEF_UPDATES = 'UsaURLForBenefUpdates';
    public static final String SEND_BENEF_INFO_TO_US_PROCESS = 'SendBenefInfoToUSProcess';
    public static final String SEND_BENEF_INFO_TO_US_FIELD_GROUP = 'SendBenefInfoToUSFieldGroup';
    public static final String SEND_BENEF_INFO_TO_AM_RES_FIELD_GROUP = 'SendBenefBLEInfoToAM_Res_FG';
    public static final String SEND_BENEF_INFO_TO_AM_RES_PROCESS = 'SendBenefBLEInfoToAM_Res_PN';
    public static final String SEND_BENEF_INFO_TO_AM_REQ_FIELD_GROUP = 'SendBenefInfoToAM_Req_FG';
    public static final String SEND_BENEF_INFO_TO_AM_REQ_PROCESS = 'SendBenefInfoToAM_Req_PN';
    public static final String SEND_BLE_INFO_TO_AM_REQ_FIELD_GROUP = 'SendBLEInfoToAM_Req_FG';
    public static final String SEND_BLE_INFO_TO_AM_REQ_PROCESS = 'SendBLEInfoToAM_Req_PN';
    public static final String AM_ESB_URL_FOR_ICP_UPDATES = 'AMURLForICPUpdates';
    public static final String AM_ESB_URL_FOR_BENEF_UPDATES = 'AMURLForBenefUpdates';
    
    /*Rest Header Constants*/
    public static final String CONTENT_TYPE = 'Content-Type';
    public static final String APPLICATION_JSON = 'application/json';
    public static final String APPLICATION_OCTET_STREAM_CONTENT_TYPE =
        'application/octet-stream;type=unknown';
    public static final String IMAGE_JPEG_CONTENT_TYPE = 'image/jpeg';
    public static final String POST_METHOD = 'POST';
    public static final String PUT_METHOD = 'PUT';
    public static final String APPLICATION_X_WWW_FORM_URLENCODED =
        'application/x-www-form-urlencoded';
    public static final String HOST_HEADER = 'Host';
    public static final String CONTENT_LENGTH = 'Content-Length';
    public static final String CONTENT_LENGTH_46 = '46';
    public static final String CONNECTION = 'Connection';
    public static final String KEEP_ALIVE = 'keep-alive';
    public static final String BASIC_AUTHHEADER = 'BASIC ';
    public static final String AUTHORIZATION_HEADER = 'Authorization';
    
    public static final String BODY_GRANT_TYPE =
        'grant_type=client_credentials&scope=read+write';

    /*Supporter Profile Response Tokens*/
    public static final String SUPPORTER_PROFILE_MAIN_TOKEN =
        '{"SupporterProfile": [';
    public static final String SUPPORTER_PROFILE_ID_TOKEN = '{"ID": "';
    public static final String SUPPORTER_PROFILE_GLOBAL_ID_TOKEN =
        '", "GlobalID": "';
    public static final String SUPPORTER_PROFILE_END_BRACKET_TOKEN = '"}';
    public static final String SUPPORTER_PROFILE_MAIN_END_BRACKET_TOKEN = ']}';
    public static final String SUPPORTER_PROFILE_DOUBLE_END_BRACKET_TOKEN = '"}}';
    public static final String SUPPORTER_PROFILE_TOKEN ='SupporterProfile';

    /*BLE Exit Type*/
    public static final String BLE_PLANNED_EXIT_TYPE = 'Planned';

    /*Miscellaneous Constants*/
    public static final String EMPTY_STRING = '';
    public static final String FALSE_LOWER_CASE = 'false';
    public static final String TRUE_LOWER_CASE = 'true';
    public static final String SPACE_STRING = ' ';
    public static final String SFDC_CI = 'SFDC CI';
    public static final String NA = 'NA';
    public static final String OK = 'OK';
    public static final String GP = 'GP';
    public static final String Found = 'Found';
    public static final String Deleted = 'Deleted';
    public static final String EDIT_ACCESS_LEVEL = 'Edit';
    public static final String ACCESS_LEVEL = 'AccessLevel';
    public static final String RECORD_TYPE = 'RecordType';
    public static final String CUSTOM_DATATYPE_ID = '__c';
    public static final String QUOTE_NEED = 'Quote Need';
    public static final String NULL_CONSTANT = '(?i)Null';
    public static final String IMAGE = 'image';
    public static final String PDF = 'pdf';
    public static final String GUEST_USER = 'GUEST';
    public static final String EMAIL_START = 'Email:';
    public static final String REGISTRATION_WITH_COMPASSION =
        'Registration with Compassion';
    public static final String DEVELOPER_NAME = 'DeveloperName';
    public static final String SCHEDULE_BATCH_CASE_ARCHIVE =
        'ScheduleBatchCaseArchive';
    public static final String BOTH = 'Both';
    public static final String ACC_ID = 'accId';
    public static final String ACCOUNT_BENEFICIARY1 = 'Account-Beneficiary1';
    public static final String COLON_STRING = ' : ';
    public static final String USER_AGENT = 'USER-AGENT';
    public static final String CHROME_BROWSER = 'Chrome';
    public static final String COMM_UPDATE_1 = 'Comm Update 1';
    public static final String COMM_UPDATE = 'Comm Update ';
    public static final String DISASTER = 'disaster';
    public static final String Seventh_Task_Sub = 'Complete Startup Training';
    public static final String LASTNAME= 'LastName';
    public static final String NULL_STR= 'Null';
    public static final String NULL_WITH_WILDCHAR= 'Nulla123'; 
    
    /*Beneficiary Assessment Constants*/
    public static final String CDPR_BEN_ASSESS_NAME_PREFIX = 'CDPR - ';
    public static final String PHYSICAL_OUTCOME_AREA = 'Physical';
    public static final String SPIRITUAL_OUTCOME_AREA = 'Spiritual';
    public static final String COGNITIVE_OUTCOME_AREA = 'Cognitive';
    public static final String SOCIO_EMOTIONAL_OUTCOME_AREA = 'Socio-Emotional';

    /*Local Beneficiary related Constants*/
    public static final String OOO = '000';
    public static final String OO = '00';
    public static final String O = '0';

    /*Tokens used in Maps for internal maps*/
    public static final String CSP_TOKEN = 'CSP';
    public static final String CDSP_TOKEN = 'CDSP';
    public static final String CDSP_HOME_BASED_TOKEN = 'CDSPHB';
    public static final String WFA_TOKEN = 'WFA';
    public static final String WFH_TOKEN = 'WFH';
    public static final String BMI_TOKEN = 'BMI';
    public static final String HFA_TOKEN = 'HFA';

    /*Status Picklist Values*/
    public static final String ACTIVE = System.Label.Active;
    public static final String HIGH = System.Label.High;
    public static final String MEDIUM = System.Label.Medium;
    public static final String LOW = System.Label.Low;
    public static final String SUSPENDED = System.Label.Suspended_Status;
    public static final String CLOSED = System.Label.Closed_Status;
    public static final String INACTIVE = System.Label.Inactive_Status;
    public static final String COMPLETED = System.Label.Completed_Status;
    public static final String CRITICAL = System.Label.Critical;
    public static final String QUALIFIED = System.Label.Qualified;
    public static final String CONVERTED = System.Label.Converted;
    public static final String APPROVED = System.Label.Approved;
    public static final String ICP_STATUS_TRANSITIONED = 'Transitioned';
    public static final String BENEFICIARY_UNSPONSORED = 'Unsponsored';
    public static final String BENEFICIARY_SPONSORED = 'Sponsored';
    public static final String ICP_STATUS_PHASED_OUT = 'Phase Out';

    /*Other Picklist Values*/
    public static final String CSP_TO_CDSP_HOME = System.Label.CSP_To_CDSP_Home;
    public static final String CSP_TO_CDSP_CENTER = System.Label.CSP_to_CDSP_Center_Transition_Value;
    public static final String CDSP_HOME_TO_CDSP_CENTER = System.Label.CDSP_Home_To_CDSP_Center;
    public static final String CSP = System.Label.CSP;
    public static final String CDSP = System.Label.CDSP;
    public static final String HOME_BASED = System.Label.Home_Based_CDSP_Type;
    public static final String CENTER_BASED = System.Label.Center_Based_CDSP_Type;
    public static final String DRAFT = System.Label.Draft_Status;
    public static final String ICP_NEED = System.Label.ICP_Need;
    public static final String BENEFICIARY_NEED = System.Label.Beneficiary_Need;
    public static final String BENEFICIARY_ASSOCIATION = System.Label.Beneficiary_Association;
    public static final String ICP_ASSOCIATION = System.Label.ICP_Association;
    public static final String MILESTONE = System.Label.Milestone;
    public static final String MOTHER = System.Label.Mother_Role;
    public static final String OPEN = 'Open';
    public static final String PLANNED_EXIT = 'Planned Exit';
    public static final String UNPLANNED_EXIT = 'Unplanned Exit';
    public static final String BENEFICIARY_HEALTHY = 'Beneficiary Healthy';
    public static final String DISASTER_100_250 = '100-250';
    public static final String DISASTER_25_49 = '25-49';
    public static final String DISASTER_50_99 = '50-99';
    public static final String DISASTER_250 = '250+';
    public static final String DISASTER_0 = '0';
    public static final String DISASTER_1_10 = '1-10';
    public static final String DISASTER_11_24 = '11-24';
    public static final String NON_OPERATIONAL_DESTROYED = 'Non-Operational / Destroyed';
    public static final String MINOR = 'Minor';
    public static final String SIGNIFICANT = 'Significant';
    public static final String DISASTER_RED = 'Red';
    public static final String DISASTER_ORANGE = 'Orange';
    public static final String DISASTER_YELLOW = 'Yellow';
    public static final String DISASTER_GREEN = 'Green';
    public static final String DISASTER_BLUE = 'Blue';
    public static final String YES = 'Yes';
    public static final String NONE_VALUE = 'None';
    public static final String UNKNOWN = 'Unknown';
    public static final String MISSING = 'Missing';
    public static final String No = 'No';
    public static final String CENTER_BASED_CLASS = 'Center-Based Class';
    public static final String GROUP_ACTIVITIES = 'Group Activities';
    public static final String PARTNERSHIP_MATURITY_LEVEL = '2-Developing Partnership';

    /*String Constants used for CDPR Assessment Controller URL Parameters*/
    public static final String CF_STRING = 'CF';
    public static final String LOOKUP_ID_STRING = '_lkid';
    public static final String HOST = 'Host';
    public static final String CDPR_URL_TOKEN_1 = '/e?RecordType=';
    public static final String CDPR_URL_TOKEN_2 = '&nooverride=1&CF';
    public static final String CDPR_URL_TOKEN_3 = '/e?nooverride=1';
    
    public static final String CommSubPage_1S11 = '1S11';
    public static final String CommSubPage_2S01 = '2S01';
    public static final String CommSubPage_3S01 = '3S01';
    public static final String CommSubPage_4S01 = '4S01';
    public static final String CommSubPage_5S01 = '5S01';
    public static final String CommSubPage_6S01 = '6S01';
    public static final String CommSubPage_7S11 = '7S11';
    public static final String CommSubPage_8S01 = '8S01';

    /*Constants for URL*/
    public static final String RETURL = 'retURL';
    public static final String BACKSLASH = '/';
    public static final String AMPERSAND = '&';
    public static final String COMMA = ',';
    public static final String HTTPS = 'https://';
    public static final String IS_EQUAL_TO = '=';
    public static final String NO_OVERRIDE_1 = '?nooverride=1';
    public static final String CLOSE_BUTTON_REDIRECT = '/home/home.jsp';
    public static final String START_URL = 'startURL';
    public static final String ICPPORTAL = 'ICPPortal';
    public static final String ICPPORTALREtURL= '%2FICPPortal%2F';
    public static final String DOCUMENTS_PREFIX = '015';
    

    /*JSON Handler Constants*/
    public static final String DUMMY_NODE = 'DummyNode';
    public static final String NULL_STRING = 'null';
    public static final String NULL_IN_DOUBLE_QUOTES_STRING = '"null"';
    public static final String TEXT_DATATYPE = 'TEXT';
    public static final String INTEGER_DATATYPE = 'Integer';
    public static final String DOUBLE_DATATYPE = 'Double';
    public static final String DATE_DATATYPE = 'Date';
    public static final String DATETIME_DATATYPE = 'Datetime';
    public static final String BOOLEAN_DATATYPE = 'Boolean';
    public static final String FALSE_STRING = 'FALSE';
    public static final String DOUBLE_QUOTES = '"';
    public static final String UTC_FORMAT = 'UTC Format';

    /* Object and Field API Name */
    public static final String RANKING_ADMINISTRATION_API_NAME =
        'Ranking_Administration__c';
    public static final String FIELD_OFFICE_API_NAME = 'Field_Office__c';
    public static final String ACCOUNT_API_NAME = 'Account';
    public static final String BEN_API_NAME = 'Beneficiary';
    public static final String LEAD_API_NAME = 'Lead';
    public static final String AGE_IN_MONTHS_API_NAME = 'Age_In_Months__c';
    public static final String AGE_API_Name = 'Age__c';
    public static final String Beneficiary_Lifecycle_Event_API_Name =
        'Beneficiary_Lifecycle_Event__c';
    public static final String AGE_TRANSITION_API_NAME = 'Age Transition';
    public static final String MEDICAL_INCIDENTS_API_NAME = 'Medical_Incidents__c';
    public static final String ICP_IMPACT_CREATED_DATE_API_NAME = 'ICP_Impact_Created_Date_Range';
    public static final String ICP_IMPACT_MODIFIED_DATE_API_NAME = 'ICP_Impact_Modified_Date_Range';
    public static final String BEN_IMPACT_CREATED_DATE_API_NAME = 'Beneficiary_Impact_Created_Date_Range';
    public static final String BEN_IMPACT_MODIFIED_DATE_API_NAME = 'Beneficiary_Impact_Modified_Date_Range';
    
    /*Encoding & URL Related Constants*/
    public static final String ENGLISH_US_LOCALE = 'en_US';
    public static final String UTF_8_ENCODING = 'UTF-8';
    public static final String AMERICA_LA_TIMEZONE = 'America/Los_Angeles';
    public static final String GLOBAL_PARTNER_EMAIL_SUFFIX = System.Label.Global_Partner_Username_Suffix;
    public static final String ENCODING = 'enc';
    public static final String EXPORT_TEXT = 'export';
    public static final String EXPORT_EXCEL = 'xls';
    public static final String EXPORT_XF = 'xf';
    public static final String EXPORT_1 = '1';
    public static final String REPORT_PV_0 = 'pv0';
    public static final String REPORT_PV_1 = 'pv1';
    public static final String REPORT_PV_2 = 'pv2';
    public static final String REPORT_PV_3 = 'pv3';
    public static final String REPORT_PV_4 = 'pv4';

    /* Constants for text fields which may needs to be moved to Label*/
    public static final String MEASURE = 'Measure ';

    /*GETICPProfileDetails constants*/
    public static final String ICPPROFILEDATAREQUESTPROCESS =
        'ICPProfileDataRequestProcess';
    public static final String ERROR_PARSING_INPUT_DATA =
        'Error parsing input data: ';
    public static final String SELECT_CONSTANT = 'SELECT ';
    public static final String VAR_Select = 'Select';
    public static final String All_CONSTANT = 'All';
    public static final String Both_CONSTANT = 'Both';
    public static final String ID = 'Id';
    public static final String ICP_PROFILE_RESPONSE_FIELD_GROUP =
        'ICPProfileResponseFieldGroup';
    public static final String FROM_ACCOUNT_WHERE_ID_IN_SETICPID =
        ' FROM Account WHERE Id IN :setICPId';
    public static final String NO_DETAILS_FOUND = 'No details found';
    public static final String ICP_PROFILE_DATA_RESPONSE_PROCESS =
        'ICPProfileDataResponseProcess';
    public static final String Communication_Kit = 'Communication Kit';
    public static final String Comm_Status = 'Printed and sent to ICP';

    /*BeneficiaryAssessmentHandler Constants*/
    public static final String CDPR_FREQUENCY_NAME = 'CDPR_Frequency_Name';
    public static final String DEVELOPMENT_PLAN_FREQUENCY_NAME =
        'Development_Plan_Frequency_Name';
    public static final String GROWTH_MONITORING_FREQUENCY_NAME =
        'Growth_Monitoring_Frequency_Name';
    public static final String HEALTH_ASSESSMENT_FREQUENCY_NAME =
        'Health_Assessment_Frequency_Name';
    public static final String HEALTH_ASSESSMENT_FREQUENCY_TWO_YEARS =
        'Health_Assessment_Frequency_Two_Years';

    /*Mass Update Account Variable Names*/
    public static final String CIV_ID = 'civId';
    public static final String ACC_TYPE = 'accType';
    public static final String CIV_NAME = 'civName';
    public static final String BEN_TOKEN = 'Ben';
    public static final String ICP_TOKEN = 'ICP';
    
    /*Search Functionality related Constants*/
    public static final String MULTISELECT = 'multiselect';
    public static final String ICP_LEAD = 'ICP Lead';
    public static final String FIELD_OFFICE = 'Field Office';
    public static final String CLUSTER = 'Cluster';
    public static final String TERRITORY = 'Territory';
    public static final String NONE = '--None--';
    public static final String NEW_SPONSOR_LETTER = 'New Sponsor Letter';
    public static final String RELATIONSHIP_LETTER = 'Reciprocal/Scheduled/Small Gift/Large Gift Letters';
    public static final String FINAL_LETTER = 'Final Letter';
    public static final String MASTER = 'Master';
    
    public static final String PMAT_New = 'NEW';
    public static final String PMAT_Edit = 'EDIT';
    public static final String PMAT_View = 'VIEW';
    
    public static final String ICP_Admin = 'ICP Full Access';
    public static final String Comp_Label = 'Compassion';
    public static final String PMAT_Status_Init = 'Initiated';
    public static final String ICP_Label = 'ICP';
    public static final String Child_ICP = 'Child-ICP';
    public static final String Child_CI = 'Child-CI';
    public static final String GIFTS_CORRESPONDENCE_ITEMS_NEW = 'New';
    
    public static final String COMMUNICATION_KIT_STATUS_READYTOBEPRINTED = 'Ready to be printed';
    public static final String COMMUNICATION_KIT_STATUS_LETTER_MARKED_FOR_REWORK = 'Marked for rework';
    public static final String COMMUNICATION_KIT_STATUS_RECEIVEDINTHESYSTEM = 'Received in the system';
    public static final String COMMUNICATION_KIT_STATUS_GLOBALPARTNERTRANSLATIONALQUEUE = 'Global Partner translation queue';
    public static final String COMMUNICATION_KIT_STATUS_PUBLISHEDTOGP = 'Published to Global Partner';
    public static final String COMMUNICATION_KIT_STATUS_QUALITY_CHECK_QUEUE = 'Field Office quality check queue';
    //public static final String COMMUNICATION_KIT_STATUS_GLOBAL_PARTNER_TRANSLATION_QUEUE = 'Global Partner translation queue';
    public static final String COMMUNICATION_KIT_STATUS_COMPOSITION_PROCESS = 'Composition process';
    public static final String COMMUNICATION_KIT_STATUS_FIELD_OFFICE_TRANSLATION_QUEUE = 'Field Office translation queue';
    public static final String COMMUNICATION_KIT_STATUS_TRANSLATION_QUALITY_CHECK_COMP = 'Translation and quality check complete';
    public static final String COMMUNICATION_KIT_STATUS_QUALITY_CHECK_UNSUCCESSFUL = 'Quality check unsuccessful';
    
    public static final String COMMITMENT_STATUS_ACTIVE = 'Active';
    public static final String COMMITMENT_STATUS_INACTIVE = 'Inactive';
    public static final String COMMITMENT_TYPE_CORRESPONDENT = 'Correspondent';
    public static final String COMMITMENT_TYPE_SPONSORSHIP = 'Sponsor';
    public static final String COMMITMENT_TYPE_ENCOURAGER = 'Encourager';
    public static final String COMMITMENT_CORRESPONDENCE_LANGUAGE = 'English';
    
    /* Planned Exit Batch class variables*/
    public static final String CORRESPONDENCE_ITEM_TYPE = 'Final Letter';
    public static final String CORRESPONDENCE_ITEM_STATUS = 'New';
    public static final String CORRESPONDENCE_ITEM_TYPE_RECIPROCAL_LETTER = 'Reciprocal Letter';
    public static final String CORRESPONDENCE_ITEM_TYPE_SCHEDULED_LETTER = 'Scheduled Letter';
    public static final String COMMUNICATION_TYPE_BENEFICIARY_INITIATED = 'Beneficiary Initiated Letter';
    
    /*Class and Activity Related Constants*/
    public static final String Jan = 'January';
    public static final String Feb = 'February';
    public static final String Mar = 'March';
    public static final String Apr = 'April';
    public static final String May = 'May';
    public static final String Jun = 'June';
    public static final String Jul = 'July';
    public static final String Aug = 'August';
    public static final String Sep = 'September';
    public static final String Oct = 'October';
    public static final String Nov = 'November';
    public static final String Dec = 'December';
    public static final String DEC_ACRONYM = 'Dec';
    public static final String ACTIVITY_ATTN_PAGE_URL = '/apex/ActivityAttendancePage?id=';
    public static final String ACTIVITY_ATTN_PRINT_PAGE_URL = '/apex/ActivityAttendancePrintForm?id=';
    public static final String CSP_BENEF_ATTN_PAGE_URL = '/apex/CSPBenefAttendanceTrackingPage?id=';
    public static final String CDSP_BENEF_ATTN_PAGE_URL = '/apex/CDSPBenefAttendanceTrackingPage?id=';
    public static final String SEARCH_ACTIVITY = 'Search-Activity';
    public static final String CLASS_MONTH_NAME_URL_PARAM = 'monthName';
    public static final String CLASS_BENEF_ID_URL_PARAM = 'sBenefId';

    public static final String PMAT_Developing_Partnership = 'Developing Partnership Stage';
    public static final String PMAT_Established_Partnership = 'Established Partnership Stage';
    public static final String PMAT_Mature_Partnership = 'Mature Partnership Stage';

    public static final String ICP_Maturity_Developing = '2-Developing Partnership';
    public static final String ICP_Maturity_Established = '3-Established Partnership';
    public static final String ICP_Maturity_Mature = '4-Mature Partnership';
    
        
    public static final String PMAT_Initiated = 'Initiated';
    public static final String PMAT_Discussion = 'Ready for Discussion';
    public static final String PMAT_Complete = 'Complete';
    
    public static final String PMAT_Low_Value = 'Low';
    public static final String PMAT_High_Value = 'High';
    
    public static final String Ben_Search_S2B = 'Supporter Letters';
    public static final String Ben_Search_B2S = 'Beneficiary Letters';
    
    
    /* SBC Integration related constants*/
    public static final String TRUE_WITHOUT_QUOTES = 'true';
    public static final String TRUE_WITH_QUOTES = '"true"';
    public static final String FALSE_WITHOUT_QUOTES = 'false';
    public static final String FALSE_WITH_QUOTES = '"false"';
    public static final String SBC_TYPE_NAME = '"SBCTypes":';
    public static final String SBC_CORRESPONDENCE_DELIVERY_PREFERENCE_NAME = '"SBC_CorrespondenceDeliveryPreference_Name":';
    public static final String METHOD_NAME_REQSBCCOMMUNICATIONDETAILS = 'reqSBCCommunicationDetails';
    public static final String METHOD_NAME_SENDCOMMUNICATIONDETAILS= 'sendSBCCommunicationDetails';
    public static final String METHOD_NAME_FORCALLOUT = 'methodForCallout';
    public static final String METHOD_NAME_REQCOMMUNICATIONUPDATES = 'reqCommunicationUpdates';
    public static final String METHOD_NAME_SENDCOMMUNICATIONUPDATES = 'sendCommunicationUpdates';
    public static final String CLASS_NAME_COMMUNICATIONUPDATES = 'CommunicationUpdates';
    public static final String CLASS_NAME_SBCCOMMUNICATIONDETAILS = 'SBCCommunicationDetails';
    public static final String CLASS_NAME_COMMUNICATIONKITSEND = 'CommunicationKitSend';
    public static final String METHOD_NAME_CREATEGIFTRESPONSES = 'createGiftResponsesJSON';
    public static final String CLASS_NAME_CREATEGIFTRESPONSES = 'CreateGiftResponses';
    public static final String METHOD_NAME_REQCOMMITMENTUPDATES = 'reqCommitmentUpdates';
    public static final String CLASS_COMMUNICATION_KIT_HANDLER = 'CommunicationKitHandler';
    public static final String COMMUNICATION_KIT_API_NAME = 'Communication_Kit__c';
   
    public static final String CODE_VARIABLE_LOCAL_BENEFICIARY_ID = 'Local Beneficiary Id';
    public static final String CODE_VARIABLE_GLOBAL_BENEFICIARY_ID = 'Global Beneficiary Id';
    public static final String CODE_VARIBALE_LEGACY_BENEFICIARY_ID = 'Legacy Beneficiary Id';
    public static final String CODE_VARIABLE_LEGACY_SUPPORTER_ID = 'Legacy Supporter Id';
    public static final String CODE_VARIABLE_GLOBAL_SUPPORTER_ID = 'Global Supporter Id';
     public static final String CODE_VARIABLE_OLD_LOCAL_BENEFICIARY_ID = 'Old Local Beneficiary Id';
    
    public static final String SOURCE_SYSTEM_PERCEPTIVE = 'PERCEPTIVE';
    public static final String SOURCE_SYSTEM_SDL = 'SDL';
    public static final String SOURCE_SYSTEM_SFDC_CI = 'SFDC-CI';
    public static final String SOURCE_SYSTEM_SFDC_USA = 'SFDC-USA';
    public static final String SOURCE_SYSTEM_XMPIE = 'XMPIE';
    public static final String DEST_SYSTEM_XMPIE = 'XMPIE_FOPrint';
    public static final String SOURCE_SYSTEM_XMPieSmallCase = 'XMPie';
    public static final String ADD_FONT = ',"FontSize_Size":10,"Font_Name":"Comic Sans",';
    public static final String ErrorString_1 = 'cannot be null/blank ';
    public static final String ErrorString_2_SOURCE_SYSTEM = 'Source System ';
    public static final String ErrorString_3_STATUS = 'Status ';
    public static final String ErrorString_4_TEMPLATE_ID = 'Template Id ';
    public static final String ErrorString_5_GP_KIT_ID = 'GP Kit Id ';
    public static final String ErrorString_6_TRANSACTION_ID = 'Transaction Id ';
    public static final String ErrorString_7_ORIGINAL_LETTER_URL = 'Original Letter URL ';
    public static final String ErrorString_8_INVALID = 'Invalid ';
    public static final String ErrorString_9_COMMUNICATION_KIT_ID = 'Communication Kit Id ';
    public static final String ErrorString_10_COMMUNICATION_DIRECTION = 'Communication Direction ';
    public static final String ErrorString_11_LEGACY_BENEFICIARY_ID = 'Legacy Beneficiary Id ';
    public static final String ErrorString_12_GLOBAL_BENEFICIARY_ID = 'Global Beneficiary Id ';
    public static final String ErrorString_13_LOCAL_BENEFICIARY_ID = 'Local Beneficiary Id ';
    public static final String ErrorString_14 = ' does not belong to same record ';
    public static final String ErrorString_15_COMMA = ', ';
    public static final String ErrorString_16_SPACE = ' ';
    public static final String ErrorString_17_AND = ' and ';
    public static final String ErrorString_18_ALL = 'all ';
    public static final String ErrorString_19_HYPHEN = '- ';
    public static final String ErrorString_20_LEGACY_SUPPORTER_ID = 'Legacy Supporter Id ';
    public static final String ErrorString_21_GLOBAL_SUPPORTER_ID = 'Global Supporter Id ';
    public static final String ErrorString_22_EXPECTED_RELATIONSHIP_TYPE = 'Expected Relationship Type is ';
    public static final String ErrorString_23_INCORRECT_RELATIONSHIP_TYPE = 'Incorrect Relationship Type sent. ';
    public static final String ErrorString_24_ORIGINAL_TEXT = 'Original Text ';
    public static final String ErrorString_25_FALIURE_TO_SEND_INFO = 'Failure in sending Communication info to US for following Communications: ';
    public static final String ErrorString_26_GIFT_AMOUNT = 'Gift Amount ';
    public static final String ErrorString_27_START_DATE = 'Start Date ';
    public static final String ErrorString_28_ALREADY_HAVE_COMMITMENT = 'Beneficiary already have an active commitment with relationship type - ';
    public static final String ErrorString_29_ENGLISH_TRANSLATED_TEXT = 'English Translated Text ';
    public static final String ErrorString_30_TRANSLATED_TEXT = 'Translated Text ';
    public static final String ErrorString_31_ACTIVE_COMMITMENT = 'There seem to be no active Commitments between the Beneficiary and Supporter sent ';
    public static final String ErrorString_32_NULL_FINALTXT = 'Final Translated Text is empty.';
    public static final String ErrorString_33_NULL_ENGTXT = 'Translated Text (English) is empty.';
    public static final String ErrorString_33_NULL_FINAL_ENG = 'Both Translated Text (English) and Final Translated Text are empty.';
    public static final String B2S = 'Beneficiary To Supporter';
    public static final String S2B = 'Supporter To Beneficiary';
    public static final String FALIURE = 'Failure';
    public static final String OUTBOUND = 'Outbound';
    public static final String INBOUND = 'Inbound';
    public static final String MASHERY_ERR_IN_BENEF_US_INTEG = 'Failure in getting token from ESB. Cannot send Beneficiary updates to US for following Beneficiaries:';
    public static final String MASHERY_ERR_IN_BENEF_AM_INTEG = 'Failure in getting token from ESB. Cannot send Beneficiary updates to AM for following Beneficiaries:';
    public static final String ERR_IN_BENEF_US_INTEG = 'Failure in sending Beneficiary updates to US for following Beneficiaries: ';
    public static final String ERR_IN_BENEF_AM_INTEG = 'Failure in sending Beneficiary updates to AM for following Beneficiaries: ';
    public static final String MASHERY_ERR_IN_ICP_AM_INTEG = 'Failure in getting token from ESB. Cannot send ICP updates to AM for following ICPs:';
    public static final String ERR_IN_ICP_AM_INTEG = 'Failure in sending ICP updates to AM for following ICPs: ';
    public static final String STACK_TRACE = 'Stack Trace: ';

    public static final String AgeGroupOption1_Value = '0-2';
    public static final String AgeGroupOption1_Label = '0-2';
    public static final String AgeGroupOption2_Value = '3-5,6-8';
    public static final String AgeGroupOption2_Label = '3-8';
    public static final String AgeGroupOption3_Value = '9-11,12-14,15-18,19+';
    public static final String AgeGroupOption3_Label = '9+';

    public static final String Print_Option_Template = 'Template with Header';
    public static final String Print_Option_Header = 'Header only';
    
    /* Partner Community Related Constants*/
     public static final String POWERPARTNER = 'PowerPartner';
     public static final String MANUAL = 'Manual';
     public static final String APEX_BASED_SHARING = 'Apex_Based_Sharing__c';
     public static final String CONT_ATTACH_OBJ_API_NAME = 'Content_Attachment__c';
     public static final String PARTNER_COMMUNITY = 'Partner Community';
     public static final String CONTENT_OBJ_API_NAME = 'Content__c';
     public static final String HOUSEHOLD_OBJ_API_NAME = 'Household__c';
     public static final String ADDRESS_OBJ_API_NAME = 'Address__c';
     public static final String ACCOUNT_OBJ_API_NAME = 'Account';
     public static final String ACTIVITY_PLAN_OBJ_API_NAME = 'Activity_Plan__c';
     public static final String YEALY_CLASS_OBJ_API_NAME = 'Yearly_Class_Schedule__c';
     public static final String ACCOUNTSHARE_API_NAME = 'AccountShare';
     public static final String HOUSEHOLD_SHARE_API_NAME = 'Household__Share';
     public static final String CONTENT_SHARE_API_NAME = 'Content__Share';
     public static final String ACTIVITY_PLAN_SHARE_API_NAME = 'Activity_Plan__Share';
     public static final String ADDRESS_SHARE_API_NAME = 'Address__Share';
     public static final String YEARLY_CLASS_SHARE_API_NAME = 'Yearly_Class_Schedule__Share';
     public static final String READ_ACCESS = 'Read';
     public static final String EDIT_ACCESS = 'Edit';
     public static final String ICP_FULL_ACCESS_PROFILE = 'ICP Full Access';
     public static final String ICP_READ_ONLY_PROFILE = 'ICP Read Only';
     public static final String ICP_PROGRAM_IMPLEMENTER_PROFILE = 'ICP Program Implementer';
     public static final String ALL_PARTNER_COMMUNITY = ' All Partner Community';
     public static final String ALL_PARTNER_COMMUNITY_USERS = '%All Partner Community%';
     public static final String PORTAL_ACCOUNT_BENEFICIARY = 'Portal-Account-Beneficiary';
     public static final String PORTAL_ACCOUNT_ICP = 'Portal-Account-ICP';
     public static final String ERROR_LOG_INSERT_MESSAGE1 = 'Exception occurred during ';
     public static final String ERROR_LOG_INSERT_MESSAGE2 = ' insert for User : ';
     public static final String ERROR_LOG_INSERT_MESSAGE3 = ' . Error Message : ';
     public static final String ERROR_LOG_DELETE_MESSAGE1 = ' delete for User : ';
     public static final String PREFIX_CUSTOM_OBJ_API_NAME = '__c';
     public static final String SHARE = 'Share';
     public static final String PARENTID = 'ParentId';
     public static final String USERORGROUPID = 'UserOrGroupId';
     public static final String ACCESSLEVEL = 'AccessLevel';
     public static final String ROWCAUSE = 'RowCause';
     public static final String STRING_ID = 'Id';
     public static final String OPPORTUNITYACCESSLEVEL = 'OpportunityAccessLevel';
     public static final String MY_RECORD = 'My Record';
     public static final String NOOVERRIDE = '?nooverride=1';
     public static final String ICP_READ_ONLY_PAGE = '/apex/ICPReadOnlyPage?id=';
     public static final String PMAT_PRINT_PAGE = '/apex/PMATFormNewPrint?id=';
     
    /*Web To Lead related constants*/
     public static final String NO_CLUSTER = 'No Cluster - ';
     public static final String LANG = 'lang';
     public static final String FO = 'FO';
     public static final String ENG_LANG_CODE = 'en_US';
     public static final String CREATE_LEAD_SUCCESS_URL = '/apex/CreateLeadSuccess';
     public static final String STRING_FALSE = 'false';
     public static final String PATTERN_TO_MATCH = '^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$';
     
     public static final string LetterDownload = 'LetterDownload';
     public static final string LetterUpload = 'LetterUpload'; 
     public static final string LetterType_Original = 'Original';
     public static final string LetterType_Final = 'Final';
     public static final string HTTPMethod_Get = 'GET';
     public static final string HTTPMethod_AuthHeader_Bearer = 'Bearer';
     public static final string HTTPMethod_AuthHeader_Authorization = 'Authorization';
     public static final string LetterDownload_MimeType = 'image/jpeg';
     public static final string LetterUpload_ContentType = 'image/tiff';
     public static final string LetterUpload_CreatedStatus = 'Created';
     public static final string LetterType_OriginalImage = 'Original Letter Image';
     public static final string LetterType_FinalImage = 'Final Letter Image';
     public static final string contentId = 'contentId';
      public static final string TYPE = 'type';
      
     public static final string BACKSLASHNULL = '\"null\"';
      public static final string URLAND = 'and';
     

     
     public static final string Download_tiff = '.tiff';     
     public static final string Download_tif = '.tif';
     public static final string Download_doc = 'document/';
     public static final string Download_FolderId = '{!FolderId}';
     public static final string Download_Page = '/page';
     public static final string Download_Images = 'images/';
     public static final string Download_DocumentId = '{!DocumentId}';
     public static final string Download_Page1 = 'page/';
     public static final string Commitment_Updates_SuccesRes = '{"response": {"status": "Success"}}';
     public static final string Commitment_Updates_LineNo = 'Line Number: ';
     public static final string Commitment_Updates_Exec = ' Exception: ';
     public static final string CommKit_TemplateId = '-A-6S11-1';
     public static final string PrintPortal_inClausifyString1 = '(\'\'{0}\'\')';
     public static final string PrintPortal_inClausifyString2 = '\',\'';
     public static final string PrintPortal_CurrMonth = 'MMMMMM';
     public static final string PrintPortal_ASC = 'ASC';
     public static final string PrintPortal_DESC = 'ASC';
     
     public static final string SBC_No_Questions= 'No Questions';
     public static final string SBC_Commitment_LegBenId = '", "LegacyBeneficiaryId" :"';
     public static final string SBC_Commitment_LegSupId = '","LegacySupporterId" : "';
     public static final string SBC_Commitment_GlobalBenId = '", "GlobalBeneficiaryId" :"';
     public static final string SBC_Commitment_GlobalSupId = '","GlobalSupporterId" : "';
     
     public static final String SPECIAL_TRUE_WITHOUT_QUOTES = ':true';
     public static final String SPECIAL_TRUE_WITH_QUOTES = ':"true"';
     public static final String SPECIAL_SPACE_TRUE_WITHOUT_QUOTES = ': true';
     public static final String SPECIAL_SPACE_TRUE_WITH_QUOTES = ': "true"';
    
     public static final String SPECIAL_FALSE_WITHOUT_QUOTES = ':false';
     public static final String SPECIAL_FALSE_WITH_QUOTES = ':"false"';
     public static final String SPECIAL_SPACE_FALSE_WITHOUT_QUOTES = ': false';
     public static final String SPECIAL_SPACE_FALSE_WITH_QUOTES = ': "false"';
     
     
     public static final String XCIM_HEADER = 'x-cim-GPId';
     public static final String IntName_SBC = 'SBCIntegration';
     public static final String IntName_BeneMinProfile = 'SendBenefInfoToUS';
     public static final String Retry_Completed = 'Retry Completed - Success';
     public static final String Retry_Error = ' Error: ';
     public static final String Retry_Number = 'Retry # ';
     public static final String Retry_NewLine = '\n';
     public static final String Retry_EmailTemplate = 'Create_Case_In_Servicenow';
     public static final String Retry_Failed = 'Retry Completed - Failure';
     
     public static final String PrintPortalBatch_URL = 'SBCCommunicationDetails_XMPIE_FOPrint';
     
}