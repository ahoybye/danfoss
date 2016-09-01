Public Class ProcessHTML{
public static string HtmlToText(string html){
   //replace all <BR> tags with \n to support new lines
   string result = html.replaceAll('<br/>', '\n');
   result = result.replaceAll('<br />', '\n');

   //all HTML/XML tags
   string HtmlPattern = '<.*?>';

   Matcher match =  Pattern.compile(HtmlPattern).matcher(result);

   //remove the tags and return string     
   return match.replaceAll('');
  } 
}