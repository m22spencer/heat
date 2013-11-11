package ;

import TestAll.TestUtils.*;

class TestCompletion extends TestCase {
  public function testNoCompletionPoint() {
    dir ("Project/Completion");
    assertProcessError( 1,
                        ~/^\[\]/,
                        complete ("TestCompletionAndDocLF.hx", 102, true));
  }
  
  static var docRegex = ~/^\[{"name":"cpl","type":"Void \-> Unknown<0>","description":" Some documentation "/;
  public function testCompletionAndDocLF_Char() {
    dir ("Project/Completion");
    assertProcessError( 0,
                        docRegex,
                        complete ("TestCompletionAndDocLF.hx", 106, true));
  }

  public function testCompletionAndDocCRLF_Char() {
    dir ("Project/Completion");
    assertProcessError( 0,
                        docRegex,
                        complete ("TestCompletionAndDocCRLF.hx", 106, true));
  }

  public function testCompletionAndDocMixed_Char() {
    dir ("Project/Completion");
    assertProcessError( 0,
                        docRegex,
                        complete ("TestCompletionAndDocMixed.hx", 106, true));
  }

  public function testCompletionAndDocLF_Byte() {
    dir ("Project/Completion");
    assertProcessError( 0,
                        docRegex,
                        complete ("TestCompletionAndDocLF.hx", 106, false));
  }

  public function testCompletionAndDocCRLF_Byte() {
    dir ("Project/Completion");
    assertProcessError( 0,
                        docRegex,
                        complete ("TestCompletionAndDocCRLF.hx", 111, false));
  }

  public function testCompletionAndDocMixed_Byte() {
    dir ("Project/Completion");
    assertProcessError( 0,
                        docRegex,
                        complete ("TestCompletionAndDocMixed.hx", 108, false));
  }
      
  //TODO: point vs byte handling
  //TODO: Mixed line ending files.
}
