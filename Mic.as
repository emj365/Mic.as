package {

  import flash.media.Microphone;
  import flash.utils.ByteArray;
  import flash.events.DataEvent;
  import flash.events.SampleDataEvent;
  import flash.events.EventDispatcher;
  import flash.events.ActivityEvent;
  import flash.events.StatusEvent;
  import flash.events.Event;

  [Event(name='activity', type='flash.events.ActivityEvent')]
  [Event(name='complete', type='flash.events.Event')]
  [Event(name='log', type='flash.events.DataEvent')]

  public class Mic extends EventDispatcher {

    public var buffer:ByteArray;

    private var mic:Microphone;
    private var sampleRate:Number;

    private var activityEvent:ActivityEvent = new ActivityEvent(ActivityEvent.ACTIVITY);
    private var completeEvent:Event = new Event(Event.COMPLETE);
    private var logEvent:DataEvent = new DataEvent(DataEvent.DATA);

    public function Mic(sampleRate:Number = 44100):void {
      this.sampleRate = sampleRate;
      if(!mic){
        setupMicrophone();
      }
      buffer = new ByteArray();
    }

    public function start():void {
      // To avoid microphone error (PepperFlashPlayer.plugin: 0x2A052 is not valid resource ID.)
      mic.removeEventListener(SampleDataEvent.SAMPLE_DATA, recordSampleDataHandler);
      mic.addEventListener(SampleDataEvent.SAMPLE_DATA, recordSampleDataHandler);
    }

    public function stop():void {
      mic.removeEventListener(SampleDataEvent.SAMPLE_DATA, recordSampleDataHandler);
      buffer.position = 0;
      dispatchEvent(completeEvent);
    }

    private function setupMicrophone():void {
      mic = Microphone.getMicrophone();
      mic.codec = "Nellymoser";
      mic.setSilenceLevel(0);
      mic.rate = sampleRate;
      mic.gain = 100;

      mic.addEventListener(StatusEvent.STATUS, function statusHandler(event:StatusEvent):void {
        if (event.code == "Microphone.Muted") {
          activityEvent.activating = false;
        }
        if (event.code == "Microphone.Unmuted") {
          activityEvent.activating = true;
        }
        dispatchEvent(activityEvent);
      });
    }

    protected function recordSampleDataHandler(event:SampleDataEvent):void {
      while (event.data.bytesAvailable) {
        var sample:Number = event.data.readFloat();
        buffer.writeFloat(sample);
      }
    }

    private function log(...args):void {
      logEvent.data = args.join("");
      dispatchEvent(logEvent);
    }

  }

}
