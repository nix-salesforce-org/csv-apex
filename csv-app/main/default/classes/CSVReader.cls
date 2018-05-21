/**
 * CSVReader contains methods used for reading a CSV file and returning
 * the contained values through iterable Map<String,String>.
 *
 * Credit: http://frombelvideres4thfloor.blogspot.com.es/2010/10/ietf-rfc-4180-compliant-csv-reader-for.html
 *
 * @author      Eduard Yavorovenko
 * @version     1.0.dev, 21-May-2018
 */
public class CSVReader implements Iterator<Map<String,String>>, Iterable<Map<String,String>> {
    
    public class CSVReaderException extends Exception {}
    
    /**
     * A csv file
     */
    @TestVisible
    private String file = null;
    
    /**
     * Header row that contains Column name 
     * and its corresponding number in the file 
     */
    @TestVisible
    private Map<String,Integer> header = null;
    
    public CSVReader( Blob file ) {
        if ( file == null ) {
            throw new CSVReaderException( 'File cannot be null' );
        }
        this.file = readBlobFile( file ) + CSVParser.CRLF;
        this.header = fetchHeader();
    }

    private String readBlobFile( Blob file ) {
        String result = file.toString();

        return result;
    }
    
    /**
     * This method gets header from the csv file.
     * It assumes that the first row in the file is always the header row.
     * It should be called once per object creation.
     */
    private Map<String,Integer> fetchHeader() {
        Map<String,Integer> header = new Map<String,Integer>();
        if ( !isFileEmpty() ) {
            List<String> row = readNextRow();
            Integer index = 0;
            for ( String value : row ) {
                String fieldName =  value;
                Integer fieldIndex = index;
                header.put( fieldName, fieldIndex );
                index++;
            }
        }
        
        return header;
    }
    
    /**
     * This method determines whether the csv file contains data.
     */
    private Boolean isFileEmpty() {
        return (file.length() == 0) || (file.length() == CSVParser.CRLF.length());
    }
    
    public Map<String,Integer> getHeader() {
        return header;
    }

    public Iterator<Map<String,String>> Iterator() {
      return this;   
   }

    public Boolean hasNext() {
        return !isFileEmpty();
    }
    
    public Map<String,String> next() {
        List<String> row = new List<String>();
        // Skip blank lines
        while ( row.isEmpty() && hasNext() ) {
            row = readNextRow();
        }
        
        Map<String,String> rowWithHeader = new Map<String,String>();
        for ( String key : header.keySet() ) {
            String fieldName =  key;
            String fieldValue = safeGet( row, header.get( key ) );
            rowWithHeader.put( fieldName, fieldValue );
        }
        
        return rowWithHeader;
    }
    
    private String safeGet( List<String> lst, Integer index ) {
        String result;
        if ( index < lst.size() ) {
            result = lst.get( index );
        } else {
            result = '';
        }
        
        return result;
    }
    
    private List<String> readNextRow() {
        if ( isFileEmpty() ) {
            throw new CSVReaderException( 'The file is empty. Cannot read any data.' );
        }
        
        List<String> row = new List<String>();
        Boolean hasData = true;
        while ( hasData ) {
            CSVValue csvValue = readValue( file );
            row.add( csvValue.value );
            
            if ( (csvValue.delimiter == CSVParser.CRLF) || (csvValue.biteSize() == file.length()) ) {
                hasData = false;
            }

            file = file.substring( csvValue.biteSize() );
        }
        
        return row;
    }
    
    /**
     * Returns the first String value read from a String representation of
     * data contained in an IETF RFC 4180-compliant CSV file.
     *
     * The data is assumed to be terminated with a CRLF.
     *
     * @param  data the textual CSV data in one long string
     * @return      the first CSV value read from <code>data</code>.
     *              null is returned if no value is discerned.
     */
    @TestVisible
    private static CSVValue readValue( String data ) {
        System.assert( data.endsWith( CSVParser.CRLF ) );
        
        CSVValue csvValue = new CSVValue();
        
        if ( data.startsWith( CSVParser.DQUOTE ) ) {
            csvValue.enclosed = true;
          
            Integer searchIndex = 1;      // starting index to search
            Integer dquoteIndex = -1;     // index of DQUOTE
            Integer dquotesIndex = -1;    // index of DQUOTEDQUOTE
                            
            Boolean closerFound = false;
            
            while ( !closerFound ) {
                dquoteIndex = data.indexOf( CSVParser.DQUOTE, searchIndex );
                
                dquotesIndex = data.indexOf( CSVParser.DQUOTEDQUOTE, searchIndex);
                
                System.assert( dquoteIndex != -1 );
                
                if ( dquoteIndex == dquotesIndex ) {
                    searchIndex = dquotesIndex + CSVParser.DQUOTEDQUOTE.length();
                }
                else {
                    closerFound = true;
                }
            }
            
            csvValue.value = data.substring( CSVParser.DQUOTE.length(), dquoteIndex )
                            .replaceAll( CSVParser.DQUOTEDQUOTE, CSVParser.DQUOTE );
            
            Integer commaIndex = data.indexOf( CSVParser.COMMA, dquoteIndex );
            Integer crlfIndex = data.indexOf( CSVParser.CRLF, dquoteIndex );
            
            if ( commaIndex != -1 && commaIndex < crlfIndex ) {
                csvValue.delimiter = CSVParser.COMMA;
            }
            else {
                csvValue.delimiter = CSVParser.CRLF;
            }
        }
        else {
            csvValue.enclosed = false;
          
            Integer commaIndex = data.indexOf( CSVParser.COMMA );
            Integer crlfIndex = data.indexOf( CSVParser.CRLF );
            
            if ( commaIndex != -1 && commaIndex < crlfIndex ) {
                csvValue.value = data.substring( 0, commaIndex );
                csvValue.delimiter = CSVParser.COMMA;
            }
            else {
                csvValue.value = data.substring( 0, crlfIndex );
                csvValue.delimiter = CSVParser.CRLF;
            }
        }
        
        return csvValue;
    }
    
    /**
     * CSVValue is a class structure containing information about a CSV
     * value that was read from a CSV file, including such information as
     * whether the value was encapsulated in double-quotes.
     */
    @TestVisible
    private class CSVValue {
        /**
         * The field value that was read from the CSV file.
         */
        public String value;
        
        /**
         * Whether the value was surrounded by double-quotes.
         */
        public Boolean enclosed;
        
        /**
         * The comma or CRLF delimiter that identified the end of the CSV value.
         */
        public String delimiter;
        
        /**
         * Default constructor, setting all members to null.
         */
        public CSVValue() {
            this(null, null, null);
        }
        
        /**
         * Constructor.
         *
         * @param value     the field value
         * @param enclosed  whether the value was surrounded by double-quotes
         * @param delimiter the delimiter that identified the end
         *                  of the CSV value
         */
        public CSVValue(String value, Boolean enclosed, String delimiter) {
            this.value = value;
            this.enclosed = enclosed;
            this.delimiter = delimiter;
        }
        
        /**
         * Returns the number of characters to remove from the data
         * String which produced the CSVValue in order to reach the next
         * value in the data String.
         */
        public Integer biteSize() {
          Integer biteSize = value.replaceAll( CSVParser.DQUOTE, CSVParser.DQUOTEDQUOTE ).length() + delimiter.length();
          
          if (enclosed) {
            biteSize += CSVParser.DQUOTE.length() * 2;
          }
          
          return biteSize;
        }
        
    }
    
}