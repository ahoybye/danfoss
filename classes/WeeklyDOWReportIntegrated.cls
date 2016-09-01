/*******************************************************************************************************************
Created By    :    Sumit(Appirio)
Date          :    5/11/2011
Reason        :    This class is schedulable class for business Org Integrated
********************************************************************************************************************/
global class WeeklyDOWReportIntegrated implements Schedulable
{
   global void execute(SchedulableContext SC) 
   {
      WeeklyDOWReportRunner.RunReportAndSendMailAndAttachment('Integrated');
   }
}