/*******************************************************************************************************************
Created By    :    Sumit(Appirio)
Date          :    5/11/2011
Reason        :    This class is schedulable class for business Org Turolla
********************************************************************************************************************/
global class WeeklyDOWReportTurolla implements Schedulable
{
   global void execute(SchedulableContext SC) 
   {
      WeeklyDOWReportRunner.RunReportAndSendMailAndAttachment('Turolla');
   }
}