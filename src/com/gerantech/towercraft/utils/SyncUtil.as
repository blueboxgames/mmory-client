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

            for ( var name:String in assets )
            {
                assets[name].exists = false;
                var md5Check:MD5Check = new MD5Check();
                md5Check.addEventListener(Event.COMPLETE, md5Check_completeHandler);
                md5Check.getHash(name, assets[name].md5);
            }
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
                this.assets[md5Check.name].exists = true;
                AppModel.instance.assets.enqueue(File.applicationStorageDirectory.resolvePath(md5Check.name).nativePath);
                this.checkAllFiles();
                return;
            }
            
            // Get a new loader for given asset name.
            var path:String = File.applicationStorageDirectory.resolvePath(md5Check.name).nativePath;
            var address:String = this.assets[md5Check.name].url;
            var loader:FileLoader = new FileLoader(md5Check.name, path, address, md5Check.hash);
            loader.addEventListener(IOErrorEvent.IO_ERROR, loader_ioErrorHandler);
            loader.addEventListener(Event.COMPLETE, loader_completeHandler);
            loader.start();
        }

        private function loader_completeHandler(event:*):void
        {
            var loader:FileLoader = event.currentTarget as FileLoader;
            loader.closeLoader()
            AppModel.instance.assets.enqueue(File.applicationStorageDirectory.resolvePath(loader.name).nativePath);
            this.assets[loader.name].exists = true;
            this.checkAllFiles();
        }

        private function loader_ioErrorHandler(e:*):void
        {
            this.dispatchEventWith(Event.IO_ERROR);
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
    public var name:String;
    public function FileLoader(name:String, localPath:String, webPath:String, md5:String = null)
    {
        super(localPath, webPath, md5, true);
        this.name = name;
    }
}

import com.gerantech.extensions.NativeAbilities;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.utils.LoadAndSaver;

import flash.desktop.NativeProcess;
import flash.desktop.NativeProcessStartupInfo;
import flash.events.ProgressEvent;
import flash.filesystem.File;

import starling.events.Event;
import starling.events.EventDispatcher;

class MD5Check extends EventDispatcher
{
    public var name:String;
    public var hash:String;
    public function MD5Check(){ super(); }
    public function getHash(name:String, hash:String):void
    {
        this.name = name;
        this.hash = hash;
        var file:File = File.applicationStorageDirectory.resolvePath(name);
        if( !file.exists )
        {
            dispatchEventWith(Event.COMPLETE, false, false);
            return;
        }
        if( AppModel.instance.platform == AppModel.PLATFORM_ANDROID )
        {
            dispatchEventWith(Event.COMPLETE, false, this.hash == NativeAbilities.instance.getMD5(file.nativePath));
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
        dispatchEventWith(Event.COMPLETE, false, this.hash == process.standardOutput.readUTFBytes(process.standardOutput.bytesAvailable));
        process.exit();
    }
}