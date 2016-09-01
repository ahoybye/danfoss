global class PublishOnEffectiveDateSchedulable implements Schedulable
{
   global void execute(SchedulableContext sc) 
   {
      PublishOnEffectiveDateBatchable b = new PublishOnEffectiveDateBatchable(); 
      database.executebatch(b);
   }
}