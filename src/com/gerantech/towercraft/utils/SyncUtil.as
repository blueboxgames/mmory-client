package com.gerantech.towercraft.utils
{
    import com.gerantech.towercraft.models.AppModel;

    import flash.events.IOErrorEvent;
    import flash.filesystem.File;

    import starling.events.Event;
    import starling.events.EventDispatcher;

    public class SyncUtil extends EventDispatcher
    {
        // private static const DEBUG:Boolean = true;
        private var assets:Object;
        public function sync(assets:Object):void
        {
            this.assets = assets;
            var assetsDir:File = File.applicationStorageDirectory.resolvePath("assets");
            if( !assetsDir.exists )
                assetsDir.createDirectory()

            var numSyncFiles:int = 0;
            for ( var name:String in assets )
            {
                if( this.assets[name].exists )
                    continue;
                assets[name].exists = false;
                var md5Check:MD5Check = new MD5Check();
                md5Check.addEventListener(Event.COMPLETE, md5Check_completeHandler);
                md5Check.getHash(name, assets[name].md5);
                numSyncFiles ++;
            }

            if( numSyncFiles == 0 )
                this.dispatchEventWith(Event.COMPLETE);
        }

        /**
         * A utility function which checks if given asset name checks it's
         * cached md5 returns true if it's hash match else will return false.
         */
        private function md5Check_completeHandler(event:Event):void
        {
            var md5Check:MD5Check = event.currentTarget as MD5Check;
            if( event.data )
            {
                finalizeLOading(md5Check.file);
                return;
            }
            
            // Get a new loader for given asset name.
            var loader:FileLoader = new FileLoader(md5Check.file, this.assets[md5Check.file.name].url, md5Check.hash);
            loader.addEventListener(IOErrorEvent.IO_ERROR, loader_ioErrorHandler);
            loader.addEventListener(Event.COMPLETE, loader_completeHandler);
            loader.start();
        }

        private function loader_completeHandler(event:*):void
        {
            var loader:FileLoader = event.currentTarget as FileLoader;
            loader.closeLoader();
            finalizeLOading(loader.file);
        }
        private function loader_ioErrorHandler(e:*):void
        {
            this.dispatchEventWith(Event.IO_ERROR);
        }

        private function finalizeLOading(file:File):void
        {
            trace(file.nativePath);
            AppModel.instance.assets.enqueue(file.nativePath);
            this.assets[file.name].exists = true;
            this.checkAllFiles();
        }

        /**
         * Checks for all content exist in filesystem, their integrity has been checked
         * by LoadAndSaver.
         */
        private function checkAllFiles():void
        {
            for ( var name:String in this.assets )
                if( !this.assets[name].exists )
                    return;
            
            AppModel.instance.assets.loadQueue(loadQueue_completeHandler);
        }

        private function loadQueue_completeHandler(e:*):void
        {
            this.dispatchEventWith(Event.COMPLETE);
        }
    }
}

import com.gerantech.towercraft.utils.LoadAndSaver;
class FileLoader extends LoadAndSaver
{
    public var file:File;
    public function FileLoader(file:File, webPath:String, md5:String = null)
    {
        super(file.nativePath, webPath, md5, true);
        this.file = file;
    }
}

import com.gerantech.towercraft.models.AppModel;

import flash.desktop.NativeProcess;
import flash.desktop.NativeProcessStartupInfo;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.filesystem.File;
import flash.filesystem.FileStream;
import flash.net.URLRequest;
import flash.net.URLStream;
import flash.utils.ByteArray;

import starling.events.Event;
import starling.events.EventDispatcher;

class MD5Check extends EventDispatcher
{
    private var md5:String = "";
    private var md5s:Object;
    public function MD5Check(){ super(); }
    public function getHash(file:File):void
    {
        if( !file.exists )
        {
            dispatchEventWith(Event.COMPLETE, false, null);
            return;
        }
        if( AppModel.instance.platform == AppModel.PLATFORM_ANDROID )
        {
            // dispatchEventWith(Event.COMPLETE, false, this.hash == NativeAbilities.instance.getMD5(file.nativePath));
            return 
        }
        
        var nativeProcessStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
        nativeProcessStartupInfo.executable = new File("c:/md5.exe");
        nativeProcessStartupInfo.arguments = new <String>["-src", file.nativePath];

        var process:NativeProcess = new NativeProcess();
        process.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, process_DataHandler);
        process.start(nativeProcessStartupInfo);
    }

    private function process_DataHandler(event:ProgressEvent):void
    {
        var process:NativeProcess = event.currentTarget as NativeProcess;
        this.md5 += process.standardOutput.readUTFBytes(process.standardOutput.bytesAvailable);
        if( this.md5.indexOf("&*^") < 0 )
            return;

        this.md5 = this.md5.substring(0, md5.length - 3);
        this.parse();
        process.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, process_DataHandler);
        process.exit(true);
    }

    private function parse():void
    {
        this.md5s = new Object();
        var array:Array = md5.split(",");
        var len:int = array.length;
        for(var i:int = 0; i < len; i++)
        {
            var h:Array = array[i].split(":");
            this.md5s[h[0]] = h[1];
        }

        dispatchEventWith(Event.COMPLETE, false, md5s);
    }
}