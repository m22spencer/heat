package ;

import TestAll.TestUtils.*;

class TestCompletion extends TestCase {
  public function testNoCompletionPoint() {
    dir ("Project/Completion");
    assertProcessError( 1,
                        ~/^\[\]/,
                        complete ("TestCompletionAndDoc.hx", 102, true));
  }
  
  public function testCompletionAndDoc() {
    dir ("Project/Completion");
    assertProcessError( 0,
                        ~/^\[{"name":"cpl","type":"Void \-> Unknown<0>","description":" Some documentation "/,
                             complete ("TestCompletionAndDoc.hx", 106, true));
  }
      
  //TODO: point vs byte handling
  //TODO: Mixed line ending files.
}
