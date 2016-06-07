/************************************************************************
Class Name         : FilterListHandler
Deascriotion       : It is the main master class for storing details for filter input in InputFieldList_Example class
Created By         : Subhojit 
Created On         : 12/26/2013 
********************************************************************************
Modification History:

*******************************************************************************************************/
public class FilterListHandler {
	public String sObjectType {
		get;
		set;
	}
	public String sObjectName {
		get;
		set;
	}
	public List<selectOption> lstFields {
			get;
			set;
		} //It contains all the field list to show on filter
	public List<selectOption> lstOperators {
			get;
			set;
		} //It contains all the Operator list to show on filter
	public Map<String, String> mapValueType {
			get;
			set;
		} //It contains the mapping of field whether auto quote needs to be added example valueTypeMap.put('Gender','Quote Need')
	public List<String> lstSelectedField {
			get;
			set;
		} // It contains all selected field input
	public List<String> lstSelectedOperator {
			get;
			set;
		} // It contains all selected operator input
	public List<String> lstSelectedTextValue {
			get;
			set;
		} // It contains all text input
	public String sKeyWordSearch {
		get;
		set;
	} //this field is for text field search
	public Integer iMaxResultSize {
		get;
		set;
	}
	public boolean bCommaMultiple {
		get;
		set;
	} //It is for search limit
	public FilterListCompController oCompControllerRef {
		get;
		set;
	}

	/**
	 * Method name  : FilterListHandler
	 * Description  : Constructor of the class
	 * Return Type  : NA
	 * Parameter    : void
	 **/
	public FilterListHandler() {
		lstSelectedField = new List<String>();
		lstSelectedOperator = new List<String>();
		lstSelectedTextValue = new List<String>();
		lstFields = new List<selectOption>();
		lstOperators = new List<selectOption>();
		mapValueType = new Map<String, String>();
		iMaxResultSize = 0;
	}

	/**
	 * Method name  : resetSelectedValue
	 * Description  : Below function is used to clear all list with previous value
	 * Return Type  : void
	 * Parameter    : void
	 **/
	public void resetSelectedValue() {
		lstSelectedField.clear();
		lstSelectedOperator.clear();
		lstSelectedTextValue.clear();
	}
}