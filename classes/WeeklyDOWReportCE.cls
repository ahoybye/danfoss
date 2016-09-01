/*******************************************************************************************************************
Created By    :    Allan Hoybye
Date          :    18/11/2014
Reason        :    This class is schedulable class for business Org Climate and Energy
********************************************************************************************************************/
global class WeeklyDOWReportCE implements Schedulable
{
   global void execute(SchedulableContext SC) 
   {
      WeeklyDOWReportRunner.RunReportAndSendMailAndAttachment('Climate and Energy');
   }
}