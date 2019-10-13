package com.gerantech.towercraft.utils
{
    import com.gerantech.towercraft.events.LoadingEvent;
    import com.gerantech.towercraft.models.AppModel;

    import flash.filesystem.File;
    import flash.filesystem.FileStream;
    import flash.utils.ByteArray;
    import flash.utils.setTimeout;

    import starling.events.Event;
    import starling.events.EventDispatcher;

    public class SyncUtil extends EventDispatcher
    {
        // private static const DEBUG:Boolean = true;
        private var assets:Object;
        private var saveQueue:Array;
        private var assetsDir:File;
        private var numAssets:int;
        public function sync(assets:Object):void
        {
            this.assets = assets;
            assetsDir = File.applicationStorageDirectory.resolvePath("assets");
            if( assetsDir.exists )
            {
                var md5Check:MD5Check = new MD5Check();
                md5Check.addEventListener(Event.COMPLETE, md5Check_completeHandler);
                md5Check.getHash(assetsDir);
            }
            else
            {
                assetsDir.createDirectory();
                loadAll();
            }
        }

        private function md5Check_completeHandler(event:Event):void
        {
            loadAll(event.data);
        }
        
        private function loadAll(md5s:* = null):void
        {
            if( md5s == null )
                md5s = new Object();
            saveQueue = new Array();
            var numSyncFiles:int = 0;
            numAssets = 0;
            for ( var name:String in this.assets )
            {
                numAssets ++;
                if( this.assets[name].exists )
                    continue;
                
                numSyncFiles ++;
                this.assets[name].hash = md5s[name];
                if( this.assets[name].hash == this.assets[name].md5 )
                {
                    setTimeout(finalize, 1, name);
                    continue;
                }
                this.assets[name].name = name;
                this.assets[name].exists = false;
                var loader:FileLoader = new FileLoader(this.assets[name]);
                loader.addEventListener(Event.COMPLETE, loader_completeHandler);
            }
            if( numSyncFiles == 0 )
                this.dispatchEventWith(Event.COMPLETE);
        }

        private function loader_completeHandler(event:*):void
        {
            var byteArray:ByteArray = new ByteArray();
            var loader:FileLoader = event.currentTarget as FileLoader;
            loader.removeEventListener(Event.COMPLETE, loader_completeHandler);
		    loader.readBytes(byteArray);
            loader.close();
           
            var saveData:* = new Object();
            saveData.bytes = byteArray;
            saveData.name = loader.asset.name;
            saveQueue.push(saveData);
            if( saveQueue.length == 1 )
                save();
        }
        
        private function save():void
        {
            var saveData:Object = saveQueue.shift();
            var saver:FileStream = new FileStream();
            saver.open(File.applicationStorageDirectory.resolvePath("assets/" + saveData.name), "write");
            saver.writeBytes(saveData.bytes);
            saver.close();
            
            // trace(saver.name + " saved. " + saveQueue.length);
            finalize(saveData.name)
            if( saveQueue.length > 0 )
                save();
        }

        private function finalize(name:String):void
        {
            AppModel.instance.assets.enqueue("app-storage:/assets/" + name);
            this.assets[name].exists = true;
            this.checkAllFiles();
        }

        /**
         * Checks for all content exist in filesystem, their integrity has been checked
         * by LoadAndSaver.
         */
        private function checkAllFiles():void
        {
            var i:int = 0;
            for( var name:String in this.assets )
            {
                i ++;
                if( !this.assets[name].exists )
                {
                	AppModel.instance.loadingManager.dispatchEvent(new LoadingEvent(LoadingEvent.PROGRESS, i / numAssets));
                    return;
                }
            }
            AppModel.instance.loadingManager.dispatchEvent(new LoadingEvent(LoadingEvent.PROGRESS, 1));
            AppModel.instance.assets.loadQueue(loadQueue_completeHandler);
        }

        private function loadQueue_completeHandler(e:*):void
        {
            this.dispatchEventWith(Event.COMPLETE);
        }
    }
}

class FileLoader extends URLStream
{
    public var asset:Object;
    private var reloadCount:int = 0;
    public function FileLoader(asset:Object)
    {
        super();
        this.asset = asset;
        this.addEventListener(IOErrorEvent.IO_ERROR, this.stream_ioerrorHandler);
        this.load(new URLRequest(asset.url + "?r=" + Math.random()));
    }
    private function stream_ioerrorHandler(event:IOErrorEvent):void
    {
        this.reloadCount += 1;
        if( reloadCount < 3 )
            this.load(new URLRequest(asset.url));
        else
            SFSConnection.instance.dispatchEvent(new SFSEvent(SFSEvent.CONNECTION_LOST, { reason: "network "+ event.type + " " + event.text }));
    }
}


import com.gerantech.extensions.NativeAbilities;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.AppModel;
import com.smartfoxserver.v2.core.SFSEvent;

import flash.desktop.NativeProcess;
import flash.desktop.NativeProcessStartupInfo;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.filesystem.File;
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
            this.dispatchEventWith(Event.COMPLETE, false, null);
            return;
        }
        if( AppModel.instance.platform == AppModel.PLATFORM_ANDROID )
        {
            this.md5 = NativeAbilities.instance.getMD5(file.nativePath);
            this.parse();
            return 
        }
        
        var nativeProcessStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
        nativeProcessStartupInfo.executable = new File("c:/md5.exe");
        nativeProcessStartupInfo.arguments = new <String>["-src", file.nativePath];

        var process:NativeProcess = new NativeProcess();
        process.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, this.process_DataHandler);
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
        process.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, this.process_DataHandler);
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
        this.dispatchEventWith(Event.COMPLETE, false, this.md5s);
    }
}