public class TriggerContextUtility {

    private static boolean firstRunBefore = true;

    public static boolean isFirstRunBefore() {
        return firstRunBefore ;
    }

    public static void setFirstRunFalseBefore(){
        firstRunBefore = false;
    }
    
    
    private static boolean firstRunAfter = true;

    public static boolean isFirstRunAfter() {
        return firstRunAfter;
    }

    public static void setFirstRunFalseAfter(){
        firstRunAfter = false;
    }
    
    private static boolean firstRun = true;

    public static boolean isFirstRun() {
        return firstRun;
    }

    public static void setFirstRunFalse(){
        firstRun = false;
    }
}