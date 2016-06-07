global class ScheduleBatchRetryMechanism implements Schedulable{
    global void execute(SchedulableContext sc){
        database.executeBatch(new BatchRetryMechanism(), 1);
    }
}