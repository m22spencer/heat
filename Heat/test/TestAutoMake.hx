package ;

import TestAll.TestUtils.*;

class TestAutoMake extends TestCase {

  public function testRootSyntaxCheck() {
    dir ("Project/AutoMake");
    assertCleanExit (check ("RootSyntaxCheck.hx"));
  }

  public function testRootSyntaxCheckError() {
    dir ("Project/AutoMake");
    assertProcessError( 1,
                        ~/[^\n]*?RootSyntaxCheckError\.hx:2: characters 2-5 : Unexpected sta/,
                        check ("RootSyntaxCheckError.hx"));
  }

  public function testRootRemapping() {
    dir ("Project/AutoMake");
    assertCleanExit (check ("RootSyntaxCheckError.hx", [{key: "RootSyntaxCheckError.hx", val: "RootSyntaxCheck.hx"}]));
  }

  public function testCorrectOriginFolderBesideSource() {
    dir ("Project/AutoMake/a/pack");
    assertCleanExit (check ("CorrectOriginFolder.hx"));
  }

  public function testCorrectOriginFolderFromRoot() {
    dir ("Project/AutoMake");
    assertCleanExit (check ("a/pack/CorrectOriginFolder.hx"));
  }
}