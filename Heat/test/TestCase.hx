package ;

class TestCase extends haxe.unit.TestCase {
   function assertCleanExit(proc, ?c:haxe.PosInfos) {
    currentTest.done = true;
    if (!(proc.exitCode == 0)) {
      currentTest.success = false;
      currentTest.error = 'Process did not clean exit. Exited with exitCode[${proc.exitCode}] and [${proc.stderr}]';
      currentTest.posInfos = c;
      throw currentTest;
    }
  }

  function assertProcessError(ec:Int, outputMatch:EReg, proc, ?c:haxe.PosInfos) {
    currentTest.done = true;
    if (!(ec == proc.exitCode
          && outputMatch.match(proc.stderr))) {
      currentTest.success = false;
      currentTest.error = 'Process did not match expected error. Exited with exitCode[${proc.exitCode}] and error: ${proc.stderr} and stdout: ${proc.stdout}';
      currentTest.posInfos = c;
      throw currentTest;
    }
  }
}