# mic.as

A Microphone Class of AS3

## Usage

```
private var mic:Mic;

protected function startRecording():void {
  mic = new Mic();
  mic.addEventListener(ActivityEvent.ACTIVITY, micActivity);
  mic.addEventListener(Event.COMPLETE, recordingComplete);
  mic.addEventListener(DataEvent.DATA, function(event:DataEvent):void {
    log(event.data);
  });
  mic.start();
}

private function recordingComplete(e:Event):void {
  log('recording complete');
  var sample:ByteArray = mic.buffer;
  log('sample legnth: ', sample.length);
}

private function micActivity(event:ActivityEvent):void {
  if (event.activating) {
    ExternalInterface.call("setCanRecording");
    log("Microphone can use");
  } else {
    log("Microphone can't use");
  }
}

private function log(...args):void {
  ExternalInterface.call("console.log", args.join(""));
}
```
