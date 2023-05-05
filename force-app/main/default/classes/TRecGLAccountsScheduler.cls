public with sharing class TRecGLAccountsScheduler implements Schedulable {

    public static String schedule = '0 58 21 ? * *'; // Every day at 9:58pm

    public static String run() {
        TRecGLAccountsScheduler sched = new TRecGLAccountsScheduler();
        return System.schedule('GL Account Name Updater', schedule, sched);
    }

    public void execute(SchedulableContext context) {
        TRecGLAccountsJEBatch batch = new TRecGLAccountsJEBatch();
        Id batchId = Database.executeBatch(batch, 200);
    }
    
}