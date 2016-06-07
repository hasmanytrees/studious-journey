/******************************************************************************************************
Class Name         : BatchCaseArchive
Description        : This class is used for archiving all the case on regular intervals defined in the
                     corresponding Scheduler job.
Created By         : Rahul Agarwal
Created On         : 04-Dec-2014 
******************************************************************************************************
Modification History:

*******************************************************************************************************/

global class BatchCaseArchive implements Database.batchable<SObject> {
	global Integer iArchiveLimit;
	global Date dtToday;

	/**
	 * Method name  : start
	 * Description  : This method queries all the cases modified Case Archive Days from today
	 * Return Type  : Database.Querylocator
	 * Parameter    : Database.BatchableContext
	 **/
	public Database.Querylocator start(Database.BatchableContext bc) {
		iArchiveLimit = Integer.ValueOf(Label.Case_Archive_Days);
		dtToday = system.today();
		dtToday = dtToday - iArchiveLimit;
		String query =
			'Select Id, Case_Archived__c from Case where LastModifiedDate <=: dtToday';
		Database.Querylocator oQueryLocator = null;
		try {
			oQueryLocator = Database.getQueryLocator(query);
		} catch(QueryException oQEx) {
			ErrorLogUtility.logGeneralError(oQEx, 'BatchCaseArchive', 'start',
				'SFDC CI');
			return null;
		}
		return oQueryLocator;
	}

	/**
	 * Method name  : execute
	 * Description  : This method updates all the cases and sets the Case Archived flag to true
	 * Return Type  : void
	 * Parameter    : Database.BatchableContext
	 **/
	public void execute(Database.BatchableContext BC, List<sObject> scope) {
		list<Case> lstAllCases = new list<Case>();
		lstAllCases = (list<Case> ) Scope;
		for(Case oCase: lstAllCases)
			oCase.Case_Archived__c = true;
		List<Database.SaveResult> lstUpdateResults =
			Database.update(lstAllCases, false);
		ErrorLogUtility.logDMLError(lstUpdateResults, lstAllCases,
			'Case', 'BatchCaseArchive', 'execute', 'SFDC CI', false);
	}

	/**
	 * Method name  : finish
	 * Description  : This method schedules the next job for archiving the future cases
	 * Return Type  : void
	 * Parameter    : Database.BatchableContext
	 **/
	public void finish(Database.BatchableContext BC) {
		DateTime dtmSysTime = system.today() + 1;
		String sChronExp = Constants.EMPTY_STRING + 0 + Constants.SPACE_STRING + 0 +
			Constants.SPACE_STRING + 21 + Constants.SPACE_STRING + (system.today() + 1)
			.day() + Constants.SPACE_STRING + (system.today() + 1)
			.month() + ' ? ' + (system.today() + 1)
			.year();

		//Create an instance of the scheduler class
		ScheduleBatchCaseArchive objAssignedToSchedule = new ScheduleBatchCaseArchive();

		//Schedule the instance created above
		try {
			System.schedule(Constants.SCHEDULE_BATCH_CASE_ARCHIVE + (system.now() + 1)
				.getTime(), sChronExp, objAssignedToSchedule);
		} catch(Exception oEx) {
			ErrorLogUtility.logGeneralError(oEx, 'BatchCaseArchive', 'finish',
				'SFDC CI');
		}
	}

}