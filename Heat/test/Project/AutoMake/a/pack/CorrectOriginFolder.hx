package a.pack;

class CorrectOriginFolder {
  static function main() {
    loadResource();
  }

  macro static function loadResource() {
    sys.io.File.getContent('AutoMakeResource.bin');
    return macro null;
  }
}