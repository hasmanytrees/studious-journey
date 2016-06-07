/*****************************************************************************************
Name             : JSONHandlerMethods
Description      : This class is used as dynamic JSON Generator and also use in generating serialized String and de serialized list of sObject
*****************************************************************************************/

public class JSONHandlerMethods {
    /**
     * Method name  : deserialize
     * Description  : Use this method to deserialize incoming JSON String
     * Return Type  : List<sObject>
     * Parameter    : String,String
     **/
    public static List<sObject> deserialize(String sMsg, String sProcessNames) {
        List<JSON_Structure__c> lstJsonStructure = 
            new List<JSON_Structure__c>();
        try{
            lstJsonStructure = [select Id, Name,
                Array_Token_Name__c, is_Array__c, JSON_Process__c, 
                Field_Group__c,Object_API_Name__c, JSON_Process__r.Array_Token_Name__c, 
                JSON_Process__r.Is_initial_Array__c from JSON_Structure__c where 
                JSON_Process__r.Name = : sProcessNames
            ];
        }catch(System.QueryException oQe){
            ErrorLogUtility.logGeneralError(oQe, 'JSONHandlerMethods', 
                'deserialize', 'SFDC CI');
        }
        Integer iTotalNodes = lstJsonStructure.size();
        List<Object> lstDataArray = new List<Object>();
        Set<Id> setFieldGroupIds = new Set<Id>();
        Map<Id, Id> mapFieldGroup = new Map<Id, Id>();
        Map<Id, Map<Id, List<Field_Group_Element__c>>> mapFieldToken = new Map <
            Id, Map<Id, List<Field_Group_Element__c>>>();
        Map<Id, JSON_Structure__c> mapJsonStruc = new Map<Id, JSON_Structure__c>
            ();
        boolean bIsInitialArray = lstJsonStructure.get(0)
            .JSON_Process__r.Is_initial_Array__c;
        String sInitialArrayNode = (lstJsonStructure.get(0)
                .JSON_Process__r.Is_initial_Array__c) ? lstJsonStructure.get(0)
            .JSON_Process__r.Array_Token_Name__c : Constants.DUMMY_NODE;

        if(!bIsInitialArray)
            sMsg = '{"' + sInitialArrayNode + '":[' + sMsg + ']}';

        for(JSON_Structure__c oJsonStructure: lstJsonStructure) {
            setFieldGroupIds.add(oJsonStructure.Field_Group__c);
            mapJsonStruc.put(oJsonStructure.Id, oJsonStructure);
        }
        
        List<Field_Group__c> lstFieldGroup = 
            new List<Field_Group__c>();
        try{
            lstFieldGroup = [select Id, Name, Object_API_Name__c, (
                    select Id, Name, Date_Format__c, Field_API_Name__c, Field_Type__c,
                    Token_Name__c from Field_Group_Elements__r) from Field_Group__c where Id In:
                setFieldGroupIds
            ];
        }catch(System.QueryException oQe){
            ErrorLogUtility.logGeneralError(oQe, 'JSONHandlerMethods', 
                'deserialize', 'SFDC CI');
        }

        Integer iIndexVar = 0;
        Map<Id, List<Field_Group_Element__c>> mapFieldToken2 = new Map<Id,
            List<Field_Group_Element__c>>();

        for(Field_Group__c oFieldGroup: lstFieldGroup)
            mapFieldToken2.put(oFieldGroup.Id, oFieldGroup.Field_Group_Elements__r);

        for(JSON_Structure__c oJsonStructure: lstJsonStructure)
            mapFieldToken.put(oJsonStructure.Id, new Map<Id, List <
                Field_Group_Element__c>> {
                    oJsonStructure.Field_Group__c => mapFieldToken2.get(oJsonStructure.Field_Group__c)
                });
        system.debug('**********sMsg' + sMsg);
        Map<String, Object> mapDeserializedString = (Map<String, Object> ) 
        JSON.deserializeUntyped(sMsg);
        lstDataArray.addAll((List<Object> )(mapDeserializedString.get(
            sInitialArrayNode)));
        List<sObject> lstSObject = new List<sObject>();

        for(Object oVar: lstDataArray) {
            Map<String, Object> mapValue = (Map<String, Object> ) oVar;
            for(JSON_Structure__c oJsonStructureVar: lstJsonStructure) {
                sObject oSObject = Schema.getGlobalDescribe()
                    .get(mapJsonStruc.get(oJsonStructureVar.Id)
                        .Object_API_Name__c)
                    .newSObject();
                Integer iIndex = 0;
                List<sObject> lstNodeSObject = new List<SObject>();
                String sArrayToken = Constants.EMPTY_STRING;

                List<Object> lstNodeArray = new List<Object>();
                if(oJsonStructureVar.is_Array__c)
                    sArrayToken = oJsonStructureVar.Array_Token_Name__c;
                if(sArrayToken != Constants.EMPTY_STRING) {
                  if(null==mapValue.get(sArrayToken)){
                    throw new ApplicationException('JSON is missing following Array token : '+sArrayToken);
                  }
                    lstNodeArray.addAll((List<Object> )(mapValue.get(sArrayToken)));
                } else
                    lstNodeArray.add(oVar);
                Integer iArraySize = lstNodeArray.size();
                lstNodeSObject = new List<SObject>();

                for(Integer i = 0; i<iArraySize; i++)
                    lstNodeSObject.add(Schema.getGlobalDescribe()
                        .get(mapJsonStruc.get(oJsonStructureVar.Id)
                            .Object_API_Name__c)
                        .newSObject());

                for(Field_Group_Element__c oFieldGroupElement: mapFieldToken.get(
                        oJsonStructureVar.Id)
                    .get(oJsonStructureVar.Field_Group__c)) {
                    iIndex = 0;
          for(Object objVar2: lstNodeArray) {
                      String sNode = Constants.EMPTY_STRING;
                        String sNode1 = Constants.EMPTY_STRING;
                        String sNode2 = Constants.EMPTY_STRING;
                        Integer iNode = 0;
                        Double dbNode = 0.0;
                        Date dtNode;
                        Boolean bNode;

                        DateTime dtmNode;
                        Map<String, Object> mapValue2 = (Map<String, Object> )(objVar2);
            if(oFieldGroupElement.Field_Type__c.equalsIgnoreCase(Constants.TEXT_DATATYPE) &&
                            ((String.valueOf(mapValue2.get(oFieldGroupElement.Token_Name__c)) <>
                                null) && !(String.valueOf(mapValue2.get(oFieldGroupElement.Token_Name__c))
                                .equalsIgnoreCase(Constants.NULL_STRING)))) {
                            sNode = (String)(mapValue2.get(oFieldGroupElement.Token_Name__c));
                            
                            if(iArraySize> 1)
                                lstNodeSObject[iIndex++].put(oFieldGroupElement.Field_API_Name__c,
                                    sNode);
                            else
                                oSObject.put(oFieldGroupElement.Field_API_Name__c, sNode);
                        }

                        if(oFieldGroupElement.Field_Type__c.equalsIgnoreCase(Constants.INTEGER_DATATYPE)) {
                            System.debug('oFieldGroupElement.Token_Name__c'+oFieldGroupElement.Token_Name__c);
                            iNode = (Integer)(mapValue2.get(oFieldGroupElement.Token_Name__c));
                            System.debug('iNode'+iNode);
                            if(iArraySize> 1)
                                lstNodeSObject[iIndex++].put(oFieldGroupElement.Field_API_Name__c,
                                    iNode);
                            else
                                oSObject.put(oFieldGroupElement.Field_API_Name__c, iNode);
                        }

                        if(oFieldGroupElement.Field_Type__c.equalsIgnoreCase(Constants.DOUBLE_DATATYPE)) {
                            dbNode = (Double)(mapValue2.get(oFieldGroupElement.Token_Name__c));
                            if(iArraySize> 1)
                                lstNodeSObject[iIndex++].put(oFieldGroupElement.Field_API_Name__c,
                                    dbNode);
                            else
                                oSObject.put(oFieldGroupElement.Field_API_Name__c, dbNode);
                        }
                        
                        if(oFieldGroupElement.Field_Type__c.equalsIgnoreCase(Constants.DATE_DATATYPE) &&
                            ((String.valueOf(mapValue2.get(oFieldGroupElement.Token_Name__c)) <>
                                null) && !(String.valueOf(mapValue2.get(oFieldGroupElement.Token_Name__c))
                                .equalsIgnoreCase(Constants.NULL_STRING)))) {
                            if(String.valueOf(mapValue2.get(oFieldGroupElement.Token_Name__c))
                                .contains('00:')) {
                                String sTemp = String.valueOf(mapValue2.get(oFieldGroupElement.Token_Name__c));
                                dtNode = Date.valueOf((sTemp.substringBefore(' 00:')));
                            } else {
                                dtNode = (Constants.EMPTY_STRING.equals(String.valueOf(mapValue2.get(
                                    oFieldGroupElement.Token_Name__c)))) ? null : Date.valueOf(String.valueOf(
                                    (mapValue2.get(oFieldGroupElement.Token_Name__c))));
                            }

                            if(iArraySize> 1)
                                lstNodeSObject[iIndex++].put(oFieldGroupElement.Field_API_Name__c,
                                    dtNode);
                            else
                                oSObject.put(oFieldGroupElement.Field_API_Name__c, dtNode);
                        }
                        
                        if(oFieldGroupElement.Field_Type__c.equalsIgnoreCase(Constants.DATETIME_DATATYPE) &&
                            ((mapValue2.get(oFieldGroupElement.Token_Name__c) <> null) && !(
                            String.valueOf(mapValue2.get(oFieldGroupElement.Token_Name__c))
                                .equalsIgnoreCase(Constants.NULL_STRING)))) {
                            
                            String sTemp = String.valueOf(mapValue2.get(oFieldGroupElement.Token_Name__c));
                            
                            if(oFieldGroupElement.Date_Format__c == Constants.UTC_FORMAT){
                                //Date Sample: 2015-10-15T12:09:24Z
                                dtmNode = (Datetime)JSON.deserialize('"'+sTemp+'"',Datetime.class);
                            }
                            else{
								dtmNode = Datetime.valueOf((sTemp.substringBefore(' 00:')));                            
                            } 

                            if(iArraySize> 1)
                                lstNodeSObject[iIndex++].put(oFieldGroupElement.Field_API_Name__c,
                                    dtmNode);
                            else
                                oSObject.put(oFieldGroupElement.Field_API_Name__c, dtmNode);
                        }

                        //For Handling Boolean Data
                        if(oFieldGroupElement.Field_Type__c.equalsIgnoreCase(Constants.BOOLEAN_DATATYPE)) {
                            if(mapValue2.get(oFieldGroupElement.Token_Name__c) <> null) {
                                if(mapValue2.get(oFieldGroupElement.Token_Name__c) == Constants.FALSE_STRING) {
                                    bNode = false;
                                } else {
                                    bNode = true;
                                }
                            }
                            else
                                bNode = false;
                          if(iArraySize> 1)
                                lstNodeSObject[iIndex++].put(oFieldGroupElement.Field_API_Name__c,
                                    bNode);
                            else
                                oSObject.put(oFieldGroupElement.Field_API_Name__c, bNode);
                        }
                    }
                    
                }
                if(lstNodeSObject.size() == 1)
                    lstSObject.add(oSObject);
                else
                    lstSObject.addAll(lstNodeSObject);
            }
        }
        return lstSObject;
    }

    /**
     * Method name  : serialize
     * Description  : Use this method to serialize incoming object to JSON String
     * Return Type  : List<sObject>
     * Parameter    : String,String
     **/
    public static String serialize(Map<String, List<SObject>> mapData, String sProcessName) {
        List<JSON_Structure__c> lstJsonStructure = 
            new List<JSON_Structure__c>();
        try{
            lstJsonStructure = [select Id, Name,
                Array_Token_Name__c, is_Array__c, JSON_Process__c, Field_Group__c,
                Field_Group__r.Name, Object_API_Name__c, JSON_Process__r.Array_Token_Name__c,
                JSON_Process__r.Is_initial_Array__c from JSON_Structure__c where 
                JSON_Process__r.Name = : sProcessName
            ];
        }catch(System.QueryException oQe){
            ErrorLogUtility.logGeneralError(oQe, 'JSONHandlerMethods', 
                'serialize', 'SFDC CI');
        }
        Integer iTotalNodes = lstJsonStructure.size();
        
        List<Object> lstDataArray = new List<Object>();
        Set<Id> setFieldGroupIds = new Set<Id>();
        Map<Id, Id> mapFieldGroup = new Map<Id, Id>();
        Map<Id, Map<Id, List<Field_Group_Element__c>>> mapFieldToken = new Map <
            Id, Map<Id, List<Field_Group_Element__c>>>();
        Map<Id, JSON_Structure__c> mapJsonStruc = new Map<Id, JSON_Structure__c>
            ();

        for(JSON_Structure__c oJsonStructure: lstJsonStructure) {
            setFieldGroupIds.add(oJsonStructure.Field_Group__c);
            mapJsonStruc.put(oJsonStructure.Id, oJsonStructure);
        }
        List<Field_Group__c> lstFieldGroup = 
            new List<Field_Group__c>();
        try{
            lstFieldGroup = [select Id, Name, Object_API_Name__c, (
                    select Id, Name, Date_Format__c, Field_API_Name__c, Field_Type__c,
                    Token_Name__c from Field_Group_Elements__r order by JSON_Order__c) 
                    from Field_Group__c where Id In: setFieldGroupIds
            ];
        }catch(System.QueryException oQe){
            ErrorLogUtility.logGeneralError(oQe, 'JSONHandlerMethods', 
                'serialize', 'SFDC CI');
        }
        Integer iIndexVar = 0;
        Map<Id, List<Field_Group_Element__c>> mapFieldToken2 = new Map<Id,
            List<Field_Group_Element__c>>();

        for(Field_Group__c oFieldGroup: lstFieldGroup)
            mapFieldToken2.put(oFieldGroup.Id, oFieldGroup.Field_Group_Elements__r);
		for(JSON_Structure__c oJsonStructure: lstJsonStructure)
            mapFieldToken.put(oJsonStructure.Id, new Map<Id, List <
                Field_Group_Element__c>> {
                    oJsonStructure.Field_Group__c => mapFieldToken2.get(oJsonStructure.Field_Group__c)
                });
        boolean bIsInitialArray = false;
        String sInitialArrayToken = '';
        if(lstJsonStructure <> NULL && lstJsonStructure.size() > 0){
            bIsInitialArray = lstJsonStructure.get(0)
                .JSON_Process__r.Is_initial_Array__c;
            sInitialArrayToken = lstJsonStructure.get(0)
                .JSON_Process__r.Array_Token_Name__c;
        }
        JSONGenerator oJSONGenerator = JSON.createGenerator(true);
        String sJson = '{\n';
        Integer iIndex = 0;
        for(JSON_Structure__c oJsonStructureVar: lstJsonStructure) {
            if(iIndex == 0) {
                if(bIsInitialArray) {
                    sJson += Constants.DOUBLE_QUOTES + sInitialArrayToken + '" :';
                    sJson += '[\n';
                    sJson += '{\n';
                }
            }
            iIndex++;
            List<sObject> lstDataArraysObject = new List<sObject>();
            lstDataArraysObject = mapData.get(oJsonStructureVar.Field_Group__r.Name);

            if(oJsonStructureVar.is_Array__c && lstDataArraysObject.size()> 0) {
                sJson += Constants.DOUBLE_QUOTES + oJsonStructureVar.Array_Token_Name__c +
                    '" :';
                sJson += '[\n';
            }

            Integer iIndex2 = 0;
            String sNode;
            String sNode1;
            String sNode2;
            for(sObject oSObject: lstDataArraysObject) {
                if(oJsonStructureVar.is_Array__c) {
                    sJson += '{\n';
                }

                for(Field_Group_Element__c oFieldGroupElement: mapFieldToken.get(oJsonStructureVar.Id).get(oJsonStructureVar.Field_Group__c)) {
                  /****NEW CODE SNIPPET START****/
                  if(oFieldGroupElement.Field_API_Name__c <> null && oFieldGroupElement.Field_API_Name__c.contains('.')){
                    list<String> lstRelationshipObjects = new list<String>();
                    lstRelationshipObjects = oFieldGroupElement.Field_API_Name__c.split('\\.');
                    Sobject oTempSObject;
                    for(Integer i=0; i<(lstRelationshipObjects.size()-1); i++){
                      if(i==0 && oSObject <> null && oSObject.getSObject(lstRelationshipObjects[i]) <> null)
                        oTempSObject = oSObject.getSObject(lstRelationshipObjects[i]);
                      else if(oTempSObject <> null && null <> oTempSObject.getSObject(lstRelationshipObjects[i]))
                        oTempSObject = oTempSObject.getSObject(lstRelationshipObjects[i]);
                    }
                    //if(oTempSObject <> null){
                    if(oFieldGroupElement.Field_Type__c.equalsIgnoreCase(Constants.TEXT_DATATYPE)){
                        if(oTempSObject <> null && null<>oTempSObject.get(lstRelationshipObjects[lstRelationshipObjects.size()-1])){
                          sNode = (String)(oTempSObject.get(lstRelationshipObjects[lstRelationshipObjects.size()-1]));
                sNode1 = String.escapeSingleQuotes(sNode);
                        sNode2 = sNode1.replaceAll('\"','\\\\"');
                            sJson += Constants.DOUBLE_QUOTES + oFieldGroupElement.Token_Name__c +
                            '":"' + sNode2 +'",';
                        }else{
                          sJson += Constants.DOUBLE_QUOTES + oFieldGroupElement.Token_Name__c +
                            '":"",';
                        }
                      }
  
                      if(oTempSObject <> null && oFieldGroupElement.Field_Type__c.equalsIgnoreCase(Constants.INTEGER_DATATYPE))
                          sJson += Constants.DOUBLE_QUOTES + oFieldGroupElement.Token_Name__c +
                          '":"' + Integer.valueOf(oTempSObject.get(lstRelationshipObjects[lstRelationshipObjects.size()-1])) +
                          '",';
                      else if(oFieldGroupElement.Field_Type__c.equalsIgnoreCase(Constants.INTEGER_DATATYPE))
                        sJson += Constants.DOUBLE_QUOTES + oFieldGroupElement.Token_Name__c +
                            '":"",';
                     
  
                      if(oTempSObject <> null && oFieldGroupElement.Field_Type__c.equalsIgnoreCase(Constants.DOUBLE_DATATYPE))
                          sJson += Constants.DOUBLE_QUOTES + oFieldGroupElement.Token_Name__c +
                          '":"' + Double.valueOf(oTempSObject.get(lstRelationshipObjects[lstRelationshipObjects.size()-1])) +
                          '",';
                      else if(oFieldGroupElement.Field_Type__c.equalsIgnoreCase(Constants.DOUBLE_DATATYPE))
                        sJson += Constants.DOUBLE_QUOTES + oFieldGroupElement.Token_Name__c +
                            '":"",';
  
                      if(oTempSObject <> null && oFieldGroupElement.Field_Type__c.equalsIgnoreCase(Constants.DATE_DATATYPE)){
						  if(oFieldGroupElement.Date_Format__c==Constants.UTC_FORMAT){
						  	   if(null <> oTempSObject.get(lstRelationshipObjects[lstRelationshipObjects.size()-1])){
							  	   sJson += Constants.DOUBLE_QUOTES + oFieldGroupElement.Token_Name__c +
			                          '":"' + String.valueOf(oTempSObject.get(lstRelationshipObjects[lstRelationshipObjects.size()-1])).substringBefore(' ')
			                          + '",';
						  	   }else{
						  	   	   sJson+='"'+oFieldGroupElement.Token_Name__c+'":"",';
						  	   }
						  }else{
	                          sJson += Constants.DOUBLE_QUOTES + oFieldGroupElement.Token_Name__c +
		                          '":"' + Date.valueOf(oTempSObject.get(lstRelationshipObjects[lstRelationshipObjects.size()-1])) +
		                          '",';
						  }
                      }
                      else if(oFieldGroupElement.Field_Type__c.equalsIgnoreCase(Constants.DATE_DATATYPE))
                        sJson += Constants.DOUBLE_QUOTES + oFieldGroupElement.Token_Name__c +
                            '":"",';
  					  
  					  if(oTempSObject <> null && oFieldGroupElement.Field_Type__c.equalsIgnoreCase(Constants.DATETIME_DATATYPE)){
						  if(oFieldGroupElement.Date_Format__c==Constants.UTC_FORMAT){
						  		if(null <> oTempSObject.get(lstRelationshipObjects[lstRelationshipObjects.size()-1])){
								  	sJson += Constants.DOUBLE_QUOTES + oFieldGroupElement.Token_Name__c +
			                          '":"' + (String.valueOf(oTempSObject.get(lstRelationshipObjects[lstRelationshipObjects.size()-1]))).replace
			                            (' ','T') +'Z",';
						  		}else{
						  	   	   sJson+='"'+oFieldGroupElement.Token_Name__c+'":"",';
						  	   }
						  }else{
	                          sJson += Constants.DOUBLE_QUOTES + oFieldGroupElement.Token_Name__c +
	                          '":"' + Datetime.valueOf(oTempSObject.get(lstRelationshipObjects[lstRelationshipObjects.size()-1])) +
	                          '",';
						  }  					  
  					  }
                      else if(oFieldGroupElement.Field_Type__c.equalsIgnoreCase(Constants.DATETIME_DATATYPE)){
                        sJson += Constants.DOUBLE_QUOTES + oFieldGroupElement.Token_Name__c +
                            '":"",';
                  	  }
                      
                      if(oTempSObject <> null && oFieldGroupElement.Field_Type__c.equalsIgnoreCase(Constants.BOOLEAN_DATATYPE)) {
                          if(null == oTempSObject.get(lstRelationshipObjects[lstRelationshipObjects.size()-1])) {
                              sJson += Constants.DOUBLE_QUOTES + oFieldGroupElement.Token_Name__c +
                                  '":"",';
                          } else {
                              sJson += Constants.DOUBLE_QUOTES + oFieldGroupElement.Token_Name__c +
                                  '":"' + Boolean.valueOf(oTempSObject.get(lstRelationshipObjects[lstRelationshipObjects.size()-1])) +
                                  '",';
                          }
                      }
                      else if(oFieldGroupElement.Field_Type__c.equalsIgnoreCase(Constants.BOOLEAN_DATATYPE))
                        sJson += Constants.DOUBLE_QUOTES + oFieldGroupElement.Token_Name__c +
                            '":"",';
                    //}
                    
                  }
                  else{
                    /***NEW CODE SNIPPET ENDS****/
                    if(oFieldGroupElement.Field_Type__c.equalsIgnoreCase(Constants.TEXT_DATATYPE)){
                        if(null<>oSObject.get(oFieldGroupElement.Field_API_Name__c)){
                          sNode = (String)(oSObject.get(oFieldGroupElement.Field_API_Name__c));
                sNode1 = String.escapeSingleQuotes(sNode);
                        sNode2 = sNode1.replaceAll('\"','\\\\"');
                            sJson += Constants.DOUBLE_QUOTES + oFieldGroupElement.Token_Name__c +
                            '":"' + sNode2 +'",';
                        }else{
                          sJson += Constants.DOUBLE_QUOTES + oFieldGroupElement.Token_Name__c +
                            '":"",';
                        }
                      }
  
                      if(oFieldGroupElement.Field_Type__c.equalsIgnoreCase(Constants.INTEGER_DATATYPE))
                          sJson += Constants.DOUBLE_QUOTES + oFieldGroupElement.Token_Name__c +
                          '":"' + Integer.valueOf(oSObject.get(oFieldGroupElement.Field_API_Name__c)) +
                          '",';
  
                      if(oFieldGroupElement.Field_Type__c.equalsIgnoreCase(Constants.DOUBLE_DATATYPE))
                          sJson += Constants.DOUBLE_QUOTES + oFieldGroupElement.Token_Name__c +
                          '":"' + Double.valueOf(oSObject.get(oFieldGroupElement.Field_API_Name__c)) +
                          '",';
  
                      if(oFieldGroupElement.Field_Type__c.equalsIgnoreCase(Constants.DATE_DATATYPE)){
                      	if(oFieldGroupElement.Date_Format__c==Constants.UTC_FORMAT){
                      		  if(null <> oSObject.get(oFieldGroupElement.Field_API_Name__c)){
			                      sJson+='"'+oFieldGroupElement.Token_Name__c+'":"'
			                        +(String.valueOf(oSObject.get
			                        (oFieldGroupElement.Field_API_Name__c))).substringBefore(' ')+'",';
                      		  }else{
                      		  	  sJson+='"'+oFieldGroupElement.Token_Name__c+'":"",';
                      		  }
                          }else{
	                          sJson += Constants.DOUBLE_QUOTES + oFieldGroupElement.Token_Name__c +
	                          '":"' + Date.valueOf(oSObject.get(oFieldGroupElement.Field_API_Name__c)) +
	                          '",';
                          }
                      }
                          
  
                      if(oFieldGroupElement.Field_Type__c.equalsIgnoreCase(Constants.DATETIME_DATATYPE)){
                          if(oFieldGroupElement.Date_Format__c==Constants.UTC_FORMAT){
                          	  if(null <> oSObject.get(oFieldGroupElement.Field_API_Name__c)){
			                      sJson+='"'+oFieldGroupElement.Token_Name__c+'":"'
			                        +(String.valueOf(oSObject.get
			                        (oFieldGroupElement.Field_API_Name__c))).replace
			                        (' ','T')+'Z'+'",';
		                      }else{
                      		  	  sJson+='"'+oFieldGroupElement.Token_Name__c+'":"",';
                      		  }
                          }else{
	                          sJson += Constants.DOUBLE_QUOTES + oFieldGroupElement.Token_Name__c +
	                          '":"' + Datetime.valueOf(oSObject.get(oFieldGroupElement.Field_API_Name__c)) +
	                          '",';
                          }
                      }
  
                      if(oFieldGroupElement.Field_Type__c.equalsIgnoreCase(Constants.BOOLEAN_DATATYPE)) {
                          if(null == oSObject.get(oFieldGroupElement.Field_API_Name__c)) {
                              sJson += Constants.DOUBLE_QUOTES + oFieldGroupElement.Token_Name__c +
                                  '":"",';
                          } else {
                              sJson += Constants.DOUBLE_QUOTES + oFieldGroupElement.Token_Name__c +
                                  '":"' + Boolean.valueOf(oSObject.get(oFieldGroupElement.Field_API_Name__c)) +
                                  '",';
                          }
                      }
                  }
                    
                }

                if(oJsonStructureVar.is_Array__c) {
                    sJson = sJson.substringBeforeLast(Constants.COMMA);
                    sJson += '\n},';
                }
            }
            if(oJsonStructureVar.is_Array__c && lstDataArraysObject.size()> 0) {
                sJson = sJson.substringBeforeLast(Constants.COMMA);
                sJson += '\n],';
            }
        }
        sJson = sJson.substringBeforeLast(Constants.COMMA);
        sJson += '\n}';
        if(bIsInitialArray) {
            sJson += '\n]';
            sJson += '\n}';
        }
        System.debug('---jSon--'+sJson);
        String sStrTemp = sJson;
        sJson = Constants.EMPTY_STRING;
        sJson += sStrTemp;
        sStrTemp = Constants.EMPTY_STRING;
        List<String> lstObject = sJson.split('\n', sJson.length());
        for(String sLoopVar: lstObject) {
            sStrTemp += sLoopVar;
        }
        system.debug('************sStrTemp' + sStrTemp);
        return sStrTemp;
        
    }
}