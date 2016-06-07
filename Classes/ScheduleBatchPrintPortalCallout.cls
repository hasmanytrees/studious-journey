global class ScheduleBatchPrintPortalCallout implements Schedulable{
    global void execute(SchedulableContext sc){
        BatchPrintPortalCallout oBPPC = new BatchPrintPortalCallout();
        database.executebatch(oBPPC,20);
        system.abortJob(sc.getTriggerId()); 
    }
}