public with sharing class TRecGLAccountsScheduler implements Schedulable {

    public static String schedule = '0 24 20 ? * *'; // Every day at 8:24pm

    public static final String JOB_NAME = 'GL Account Name Updater';

    public static String run() {
        TRecGLAccountsScheduler sched = new TRecGLAccountsScheduler();
        return System.schedule(JOB_NAME, schedule, sched);
    }

    public void execute(SchedulableContext context) {
        // Activate trigger bypass for the journal entry object
        TRecTriggerBypass ttb = new TRecTriggerBypass();
        ttb.addObject('TREX1__Journal_Entry__c');
        ttb.bypassAll(JOB_NAME);

        // Execute batch
        TRecGLAccountsJEBatch batch = new TRecGLAccountsJEBatch();
        Id batchId = Database.executeBatch(batch, 200);

        // Disable Traction Rec trigger bypass for the sobject type
        ttb.disableAllBypasses();
    }
    
}