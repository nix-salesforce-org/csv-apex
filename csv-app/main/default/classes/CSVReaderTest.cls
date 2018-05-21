/**
 * Integration and unit tests for the CSVReader class
 *
 * @author      Eduard Yavorovenko
 * @version     1.0.dev, 21-May-2018
 */
@isTest
public class CSVReaderTest {
    
    private static final String CR = '\r';
    private static final String LF = '\n';
    private static final String NEW_LINE_CRLF = CR + LF;
    private static final Map<String,Integer> FILE_HEADER_MAP = new Map<String,Integer>{
                                                                   'First Name' => 0,
                                                                   'Last Name' => 1,
                                                                   'Email' => 2,
                                                                   'Phone' => 3,
                                                                   'City' => 4
                                                                };
    private static final Map<String,String> FILE_ROW_1_MAP = new Map<String,String>{
                                                                    'First Name' => 'lead',
                                                                    'Last Name' => 'test1',
                                                                    'Email' => 'test1@test.com',
                                                                    'Phone' => '000-000-0000',
                                                                    'City' => 'Los Angeles'
                                                                };
    private static final String FILE_HEADER = 'First Name,Last Name,Email,Phone,City';
    private static final String FILE_ROW_1 = 'lead,test1,test1@test.com,000-000-0000,Los Angeles';
    private static final String FILE_ROW_2 = 'lead,test1,test1@test.com,000-000-0000,Los Angeles';
    private static final String FILE_ROW_3 = 'lead,test1,test1@test.com,000-000-0000,Los Angeles';
    private final static String FILE_BODY = FILE_ROW_1 + NEW_LINE_CRLF +
                                            FILE_ROW_2 + NEW_LINE_CRLF +
                                            FILE_ROW_3 + NEW_LINE_CRLF;
    private final static String FILE_STRING = FILE_HEADER + NEW_LINE_CRLF + FILE_BODY;                                         
	private final static Blob FILE_BLOB = Blob.valueOf( FILE_STRING );

    @isTest
    public static void testEmptyFileThrowsError() {
        // WHEN
        Test.startTest();
        CSVReader reader;
        Exception err;
        try {
            reader = new CSVReader( null );
        } catch ( Exception e ) {
            err = e;
        }
        Test.stopTest();

        // THEN
        System.assert( reader == null );
        System.assert( err instanceof CSVReader.CSVReaderException );
    }


    @isTest
    public static void testReaderCreatedSuccessfully() {
        // WHEN
        Test.startTest();
        CSVReader reader = new CSVReader( FILE_BLOB );
		Test.stopTest();
        
        // THEN
        System.assertEquals( FILE_BODY + NEW_LINE_CRLF, reader.file );
        System.assertEquals( FILE_HEADER_MAP, reader.header );
    }
    

    @isTest
    public static void testHeaderCorrect() {
        // GIVEN
        CSVReader reader = new CSVReader( FILE_BLOB );

        // WHEN
        Test.startTest();
        Map<String,Integer> header = reader.getHeader();
        Test.stopTest();

        // THEN
        System.assertEquals( FILE_HEADER_MAP, header );
    }

    @isTest
    public static void testNextDataRowCorrect() {
        // GIVEN
        CSVReader reader = new CSVReader( FILE_BLOB );

        // WHEN
        Test.startTest();
        Map<String,String> row1 = reader.next();
        Test.stopTest();

        // THEN
        System.assertEquals( FILE_ROW_1_MAP, row1 );
    }

    @isTest
    public static void testHasNext() {
        // GIVEN
        CSVReader reader = new CSVReader( FILE_BLOB );

        // WHEN
        Test.startTest();
        Map<String,String> row1 = reader.next();
        Test.stopTest();

        // THEN
        System.assert( reader.hasNext() == true );
    }

    @isTest
    public static void testHasNextExhausted() {
        // GIVEN
        CSVReader reader = new CSVReader( FILE_BLOB );

        // WHEN
        Test.startTest();
        Map<String,String> row1 = reader.next();
        Map<String,String> row2 = reader.next();
        Map<String,String> row3 = reader.next();
        Test.stopTest();

        // THEN
        System.assert( reader.hasNext() == false );
    }

    @isTest
    public static void testReadValueDoubleQuotted() {
        // GIVEN
        String data = '"te,st1","lead"' + NEW_LINE_CRLF;
        // WHEN
        Test.startTest();
        CSVReader.CSVValue value = CSVReader.readValue( data );
        Test.stopTest();

        // THEN
        System.assert( value.value == 'te,st1' );
    }

    @isTest
    public static void testReadValueNotQuotted() {
        // GIVEN
        String data = 'lead,e,st1' + NEW_LINE_CRLF;
        // WHEN
        Test.startTest();
        CSVReader.CSVValue value = CSVReader.readValue( data );
        Test.stopTest();

        // THEN
        System.assert( value.value == 'lead' );
    }
}