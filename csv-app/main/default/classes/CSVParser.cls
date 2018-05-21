/**
 * Parser is a utility class that contains constants and properties
 * designed to assist in the parsing of Strings and other forms of data.
 *
 * Credit: http://frombelvideres4thfloor.blogspot.com.es/2010/10/ietf-rfc-4180-compliant-csv-reader-for.html
 *
 * @author      Eduard Yavorovenko
 * @version     1.0.dev, 21-May-2018
 */
public class CSVParser {
    /**
     * Comma String as defined by IETF RFC 4180.
     */
    public static final String COMMA =
            String.fromCharArray(new List<Integer> { 44 });

    /**
     * Carriage return String as defined by Salesforce documentation.
     */
    public static final String CR = '\r';
    
    /**
     * Double-quote String as defined by Salesforce documentation.
     */
    public static final String DQUOTE = '\"';
    
    /**
     * Line feed String as defined by Salesforce documentation.
     */
    public static final String LF = '\n';
    
    /**
     * Carriage return String followed by a line feed String.
     */
    public static final String CRLF = CR + LF;
    
    /**
     * Line feed String followed by a carriage return String.
     */
    public static final String LFCR = LF + CR;
  
    /**
     * Escaped double-quotes per IETF RFC 4180.
     */
    public static final String DQUOTEDQUOTE = DQUOTE + DQUOTE;
}