package com.gerantech.towercraft.utils
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.OutputProgressEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	
	public class GTStreamer
	{
		public var file:File;
		public var isMultiline:Boolean;
		private var fileStream:FileStream;
		private var isLoader:Boolean;
		private var _loader:Loader;
		public var bytes:ByteArray;
		
		private var onLoad:Function;
		private var onError:Function;
		private var onProgress:Function;
		
		public function GTStreamer(file:*, onLoad:Function, onError:Function=null, onProgress:Function=null, isLoader:Boolean=false, isRead:Boolean=true)
		{
			this.onLoad = onLoad;
			this.onError = onError;
			this.onProgress = onProgress;
			this.isLoader = isLoader;
			
			this.file = Boolean(file is File) ? file : new File(file);
			fileStream = new FileStream();
			if(isRead)// && this.file.exists
			{
				fileStream.addEventListener(Event.COMPLETE, completeHandler);
				fileStream.addEventListener(ProgressEvent.PROGRESS, progressHandler);
				fileStream.addEventListener(IOErrorEvent.IO_ERROR, ioReadErrorHandler);
				fileStream.openAsync(this.file, "read");
			}
		}
		private function ioReadErrorHandler(e:IOErrorEvent):void
		{
			removeListeners();
			if(onError!=null)
			{
				onError();
			}
			else
			{
				trace("GTStreamer :: '"+file.nativePath+"' not found.")
			}
		}
		private function progressHandler(e:ProgressEvent):void
		{
			if(onProgress!=null)onProgress(e.bytesLoaded/e.bytesTotal);
		}
		private function completeHandler(e:Event):void
		{
			removeListeners();
			bytes = new ByteArray();
			fileStream.readBytes(bytes, 0, fileStream.bytesAvailable);
			fileStream.close();
			
			if (isLoader)
			{
				_loader = new Loader();
				var loaderContext:LoaderContext = new LoaderContext();
				loaderContext.allowLoadBytesCodeExecution = true;
				_loader.loadBytes(bytes, loaderContext);
				_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderLoaded);
				_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loaderErrored);
				bytes.position= 0;
			}
			else
			{
				if(onLoad!=null)
					onLoad(this);
			}
		}
		private function loaderLoaded(e:Event):void
		{
			if(onLoad!=null)
				onLoad(this);
		}
		private function loaderErrored(e:IOErrorEvent):void
		{
			if(onError!=null)
			{
				onError();
			}
			else
			{
				trace("GTStreamer :: '"+file.nativePath+"' loader's not found.")
			}
		}
		
		public function get loader():Loader
		{
			return (_loader);
		}
		
		public function get utfBytes():String
		{
			var ret:String = bytes.toString();
			if(isMultiline)ret.replace(File.lineEnding, "\n")
			return (ret);
		}
		
		/*public function get bytes():ByteArray
		{
			var ret:ByteArray = new ByteArray();
			fileStream.readBytes(ret, 0, fileStream.bytesAvailable);
			//fileStream.close();
			return (ret);
		}*/
		
		public function save(data:*):void
		{
			//trace(file.nativePath)
			fileStream.addEventListener(OutputProgressEvent.OUTPUT_PROGRESS, outputProgressHandler);
			fileStream.openAsync(file, "write");//file.exists ? "update" : 
			data is String ? fileStream.writeUTFBytes(data):fileStream.writeBytes(data);
		}
		private function outputProgressHandler(e:OutputProgressEvent):void
		{
			if(onProgress!=null)onProgress();//trace(file.name, e.bytesPending/e.bytesTotal)
			if (e.bytesPending == 0)
			{
				if(fileStream)
				{
					fileStream.removeEventListener(OutputProgressEvent.OUTPUT_PROGRESS, outputProgressHandler);
					fileStream.close();
				}
				if(onLoad!=null)
					onLoad(this);
			}
		}
		
		public function close():void
		{
			if(fileStream!=null)
			{
				fileStream.close();
			}
			removeListeners();
			fileStream = null;
		}
		
		private function removeListeners():void
		{
			fileStream.removeEventListener(Event.COMPLETE, completeHandler);
			fileStream.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
			fileStream.removeEventListener(IOErrorEvent.IO_ERROR, ioReadErrorHandler);
		}
	}
}