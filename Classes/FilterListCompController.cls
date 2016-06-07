/******************************************************************************
Class Name         : FilterListCompController
Deascriotion       : It is the component controller which is reused in all the
                     VisualForce Search pages where 'filter by' functionality
                     has to be implemented
Created By         : Subhojit 
Created On         : 26-Dec-2013 
********************************************************************************
Modification History:

********************************************************************************/
public class FilterListCompController {

    public String sObjectName {
        get;
        set;
    }
    public String sPageBlockTitle {
        get;
        set;
    } // User inout for value for pageblockSection of filter input
    public String sSelectedFirstParam; //selected value for Field
    public String sSelectedSecondParam; //selected value for lstOperators
    public String sSelectedThirdParam; //Inout value for text value field
    public Integer iMaxSize {
        get;
        set;
    } //Max size of filter list (inout by user)
    public Integer iMinSize {
        get;
        set;
    } // Min size of Filter List
    public List<Integer> lstCounter {
            get;
            set;
        } // lstCounter is used to display list in repeat in vf
    private Integer iDefaultSize; //user input for default no of the filter row
    public boolean bDisplayMaxResultSize {
        get;
        set;
    } //user inout to display max result
    boolean bInternalVar; //Internal variable for setting logic
    public String sLogicString {
        get;
        set;
    }
    Integer iIndex = 0;
    public String sLinkName {
        get;
        set;
    }
    public boolean bShowlink {
        get;
        set;
    }
    public Id accountId {
        get;
        set;
    }
    public String sQuery {
        get;
        set;
    }
    public String sObjName {
        get;
        set;
    }
    Integer iCheckVar = 0; //It alays contains the last row of te filter table 
    public FilterListHandler oFilterListHandler;
    public Integer iLastRow {
        set;
        get {
            return lstCounter.size() - 1;
        }
    }

    /**
     * Method name  : FilterListComp_Controller_1
     * Description  : Class Constructor
     * Return Type  : NA
     * Parameter    : void
     **/
    public FilterListCompController() {
        oFilterListHandler = new FilterListHandler();
        lstCounter = new List<Integer>();
        bInternalVar = true;
        setLstOperators();
        bShowlink = true;
        iMaxSize = 5;
        iMinSize = 3;
        sLinkName = System.Label.More_Filter_Link;
    }
    
    /**
    * Method name  : setSelectedFirstParam
    * Description  : This function used to take the first selected parameter
                     for filtering and store in the list
    * Return Type  : void
    * Parameter    : String
    **/
    public void setSSelectedFirstParam(String sSelectedVal) {
        oFilterListHandler.lstSelectedField.add(sSelectedVal);
    }

    /**
    * Method name  : setSelectedSecondParam
    * Description  : This function used to take the second selected parameter
                     for filtering and store in the list
    * Return Type  : void
    * Parameter    : String
    **/
    public void setSSelectedSecondParam(String sSelectedVal) {
        oFilterListHandler.lstSelectedOperator.add(Constants.SPACE_STRING +
            sSelectedVal + Constants.SPACE_STRING);
    }

    /**
    * Method name  : setSelectedThirdParam
    * Description  : This function used to take the third selected parameter
                     for filtering and store in the list
    * Return Type  : void
    * Parameter    : String
    **/
    public void setSSelectedThirdParam(String sSelectedVal) {
        oFilterListHandler.lstSelectedTextValue.add(sSelectedVal);
    }

    /**
    * Method name  : getSelectedThirdParam
    * Description  : This function used to return the third selected parameter
                     for filtering and store in the list
    * Return Type  : void
    * Parameter    : void
    **/
    public String getSSelectedThirdParam() {
        return sSelectedThirdParam;
    }

    /**
    * Method name  : getSelectedFirstParam
    * Description  : This function used to return the first selected parameter
                     for filtering and store in the list
    * Return Type  : void
    * Parameter    : void
    **/
    public String getSSelectedFirstParam() {
        return sSelectedFirstParam;
    }

    /**
    * Method name  : getSelectedSecondParam
    * Description  : This function used to return the second selected parameter
                     for filtering and store in the list
    * Return Type  : void
    * Parameter    : void
    **/
    public String getSSelectedSecondParam() {
        return sSelectedSecondParam;
    }

    /**
    * Method name  : getiDefaultSize
    * Description  : This function used to return the lstCounter value 
                     in list based on the default size
    * Return Type  : Integer
    * Parameter    : void
    **/
    public Integer getIDefaultSize() {
        return iDefaultSize;
    }

    /**
    * Method name  : setFilterListHandler
    * Description  : This function is used to take the value for filter list
                     and to also set values for operator list.
    * Return Type  : void
    * Parameter    : FilterListHandler
    **/
    public void setOFilterListHandler(FilterListHandler oVal) {
        oFilterListHandler = oVal;
        oFilterListHandler.oCompControllerRef = this;
        oFilterListHandler.lstOperators.clear();
        setLstOperators();
    }

    /**
     * Method name  : getFilterListHandler
     * Description  : This function is used to return the value for filter list
     * Return Type  : FilterListHandler
     * Parameter    : void
     **/
    public FilterListHandler getOFilterListHandler() {
        return oFilterListHandler;
    }

    /**
     * Method name  : setiDefaultSize
     * Description  : This function sets the lstCounter value in list based on the default size
     * Return Type  : void
     * Parameter    : Integer
     **/
    public void setIDefaultSize(Integer iLim) {
        if(bInternalVar == true) {
            for(Integer i = 0; i<iLim; i++) {
                lstCounter.add(i);
            }
            bInternalVar = false;
            iDefaultSize = iLim;
            if(iDefaultSize == 1) {
                sLinkName = System.Label.More_Filter_Link;
            }
        }
    }

    /**
     * Method name  : formatInput
     * Description  : This private function is used for setting the sQuery string with proper formating
     * Return Type  : void
     * Parameter    : void
     **/
    private void formatInput() {
        for(Integer i = 0; i<oFilterListHandler.lstSelectedField.size(); i++) {
            try {
                if(oFilterListHandler.mapValueType.get(oFilterListHandler.lstSelectedField[
                        i]) == Constants.QUOTE_NEED) { // Used to add quote for string values                    
                    if(oFilterListHandler.lstSelectedOperator[i] == ' like ') { // use to add % for like operator 
                        oFilterListHandler.lstSelectedTextValue[i] = ' \'%' + oFilterListHandler
                            .lstSelectedTextValue[i] + '%\'';
                    } else {
                        oFilterListHandler.lstSelectedTextValue[i] = ' \'' + oFilterListHandler.lstSelectedTextValue[
                            i] + '\'';
                    }
                } else if(oFilterListHandler.mapValueType.get(oFilterListHandler.lstSelectedField[
                        i]) == 'multiselect') {
                    if(oFilterListHandler.lstSelectedOperator[i] == ' like ') {
                        oFilterListHandler.lstSelectedOperator[i] = ' includes ';
                        oFilterListHandler.lstSelectedTextValue[i] = ' (\'' + oFilterListHandler
                            .lstSelectedTextValue[i].replaceAll(Constants.COMMA, ';') + '\')';
                    } else {
                        oFilterListHandler.lstSelectedTextValue[i] = ' \'' + oFilterListHandler.lstSelectedTextValue[
                            i] + '\'';
                    }
                }
            } catch(Exception oExp) {
                    ErrorLogUtility.logGeneralError(oExp, 'FilterListCompController',
                'formatInput', 'SFDC CI');
            }
        }
    }

    /**
     * Method name  : increaseCounter
     * Description  : This function is used for adding the number of filters
     * Return Type  : void
     * Parameter    : void
     **/
    public void increaseCounter() {
        iIndex = 0;
        lstCounter.clear();
        bInternalVar = true;
        setiDefaultSize(iDefaultSize + 1);
        iLastRow = iDefaultSize - 1;
    }

    /**
     * Method name  : removeCounter
     * Description  : This function is used for decreasing the number of filters
     * Return Type  : void
     * Parameter    : void
     **/
    public void removeCounter() {
        iIndex = 0;
        lstCounter.clear();
        bInternalVar = true;
        setiDefaultSize(iDefaultSize - 1);
        iLastRow = iDefaultSize - 1;
    }

    /**
    * Method name  : removeCounter
    * Description  : This function sets the default input for operator. The user can override
                     or add new values from their calling class
    * Return Type  : void
    * Parameter    : void
    **/
    public void setLstOperators() {
        oFilterListHandler.lstOperators.add(new selectOption('-None-', System.Label.Search_Ben_Controller_None));
        oFilterListHandler.lstOperators.add(new selectOption('=', System.Label.equals));
        oFilterListHandler.lstOperators.add(new selectOption('like', System.Label.contains));
        oFilterListHandler.lstOperators.add(new selectOption('>', System.Label.greater_than));
        oFilterListHandler.lstOperators.add(new selectOption(' <', System.Label.less_than));
        oFilterListHandler.lstOperators.add(new selectOption(' !=', System.Label.Not_Equals));

    }

    /**
     * Method name  : removeCounter
     * Description  : This function is used to create sQuery string from the selected values
     * Return Type  : void
     * Parameter    : void
     **/
    public void formQuery() {
        formatInput();
        sQuery = '';
        for(Integer i = 0; i<oFilterListHandler.lstSelectedField.size(); i++) {
            if(((oFilterListHandler.lstSelectedField[i] != '-None-') && (
                    oFilterListHandler.lstSelectedOperator[i] != ' -None- '))) {
                if((oFilterListHandler.lstSelectedField[i] != '') && (oFilterListHandler.lstSelectedOperator[
                        i] != '')) {
                    if((oFilterListHandler.bCommaMultiple == false)) {
                        sQuery += ' ' + oFilterListHandler.lstSelectedField[i] +
                            oFilterListHandler.lstSelectedOperator[i] + oFilterListHandler.lstSelectedTextValue[
                                i] + ' ' + 'AND' + ' ';
                    } else {
                        if((oFilterListHandler.lstSelectedTextValue[i].contains(',')) && (
                                oFilterListHandler.mapValueType.get(oFilterListHandler.lstSelectedField[
                                    i]) == Constants.QUOTE_NEED)) {
                            List<String> allValues = new List<String>();
                            String tempVal = oFilterListHandler.lstSelectedTextValue[i];
                            do {
                                String strVal = tempVal.subStringBefore(',');
                                allValues.add(strVal);
                                tempVal = tempVal.subStringAfter(',');
                            } while (tempVal.contains(','));
                            allValues.add(tempVal);
                            sQuery = formQueryBasedOnOperator(i,oFilterListHandler,sQuery,allValues);
                            sQuery += ' ) AND ';
                        } else {
                            sQuery += ' ' + oFilterListHandler.lstSelectedField[i] +
                                oFilterListHandler.lstSelectedOperator[i] + oFilterListHandler.lstSelectedTextValue[
                                    i] + ' ' + 'AND' + ' ';
                        }
                    }
                }
            }
        }
        /********* resetting all selected values**************/
        oFilterListHandler.lstSelectedTextValue.clear();
        oFilterListHandler.lstSelectedOperator.clear();
        oFilterListHandler.lstSelectedField.clear();
    }
    
    /**
    * Method name  : formQueryBasedOnOperator
    * Description  : This method is to maintain lstCounter values
                     for filter links
    * Return Type  : void
    * Parameter    : void
    **/
    private string formQueryBasedOnOperator(Integer i,FilterListHandler oFilterListHandler,String sQuery,List<String> allValues) {
        for(Integer j = 0; j<allValues.size(); j++) {
            if(oFilterListHandler.lstSelectedOperator[i] == ' like ') {
                if((j == 0) || (j == allValues.size() - 1)) {
                    if(j == 0) {
                        sQuery += ' ((' + oFilterListHandler.lstSelectedField[i] +
                            oFilterListHandler.lstSelectedOperator[i] + allValues[j] + '%\' ' +
                            'OR' + ' ';
                    }
                    if(j == allValues.size() - 1) {
                        sQuery += ' ' + oFilterListHandler.lstSelectedField[i] +
                            oFilterListHandler.lstSelectedOperator[i] + '\'%' + allValues[j] +
                            ') ';
                    }
                } else {
                    sQuery += ' ' + oFilterListHandler.lstSelectedField[i] +
                        oFilterListHandler.lstSelectedOperator[i] + '\'%' + allValues[j] +
                        '%\' ' + 'OR' + ' ';
                } 
            } else {
                if((j == 0) || (j == allValues.size() - 1)) {
                    if(j == 0) {
                        sQuery += ' ((' + oFilterListHandler.lstSelectedField[i] +
                            oFilterListHandler.lstSelectedOperator[i] + allValues[j] + '\' OR';
                    }
                    if(j == allValues.size() - 1) {
                        sQuery += ' ' + oFilterListHandler.lstSelectedField[i] +
                            oFilterListHandler.lstSelectedOperator[i] + '\'' + allValues[j] +
                            ')';
                        //sQuery+=' '+'OR'+' ';   
                    }
                } else {
                    sQuery += ' ' + oFilterListHandler.lstSelectedField[i] +
                        oFilterListHandler.lstSelectedOperator[i] + '\'' +
                        oFilterListHandler.lstSelectedTextValue[i] + '\' ' + 'OR' + ' ';
                }
            }
        } 
        return sQuery;
    }
    /**
    * Method name  : oneLinkCounter
    * Description  : This method is to maintain lstCounter values
                     for filter links
    * Return Type  : void
    * Parameter    : void
    **/
    public void oneLinkCounter() {
        if(sLinkName == System.Label.Fewer_Filter_Link) {
            if(iCheckVar == 0) {
                iCheckVar = iDefaultSize;
            }
            iDefaultSize = iCheckVar + 1;
            removeCounter();
            sLinkName = System.Label.More_Filter_Link;
        } else {
            if(iCheckVar == 0) {
                iCheckVar = iDefaultSize;
            }
            iDefaultSize = 6;
            increaseCounter();
            sLinkName = System.Label.Fewer_Filter_Link;
        }
    }
}