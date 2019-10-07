package com.gerantech.towercraft.utils
{
    import com.smartfoxserver.v2.entities.data.ISFSObject;

    import flash.events.IOErrorEvent;
    import flash.filesystem.File;
    import flash.utils.Dictionary;

    import starling.events.Event;
    import starling.events.EventDispatcher;

    public class SyncUtil extends EventDispatcher
    {
        private static const DEBUG:Boolean = true;
        private var checkedFiles:Dictionary;
        private var checksumData:ISFSObject;
        public function sync(checksumData:ISFSObject, data:Array):void
        {
            this.checksumData = checksumData;
            checkedFiles = new Dictionary();
            for each(var name:String in data )
                checkedFiles[name]= false;
            
            for each(name in data )
            {
                var md5Check:MD5Check = new MD5Check();
                md5Check.addEventListener(Event.COMPLETE, md5Check_completeHandler);
                md5Check.getHash(name, checksumData.getSFSObject(name).getUtfString("md5"));
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
                checkedFiles[md5Check.name] = true;
                checkAllFiles();
                return;
            }
            
            // Get a new loader for given asset name.
            var path:String = File.applicationStorageDirectory.resolvePath(md5Check.name).nativePath;
            var address:String = this.checksumData.getSFSObject(md5Check.name).getUtfString("url");
            var loader:FileLoader = new FileLoader(md5Check.name, path, address, md5Check.hash);
            loader.addEventListener(IOErrorEvent.IO_ERROR, loader_ioErrorHandler);
            loader.addEventListener(Event.COMPLETE, loader_completeHandler);
            loader.start();
        }

        private function loader_completeHandler(event:*):void
        {
            var loader:FileLoader = event.currentTarget as FileLoader;
            checkedFiles[loader.name] = true;
            checkAllFiles();
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
            for (var key:String in this.checkedFiles )
                if( !this.checkedFiles[key] )
                    return;

            dispatchEventWith(Event.COMPLETE);
        }
    }
}

import com.gerantech.towercraft.utils.LoadAndSaver;
class FileLoader extends LoadAndSaver
{
    public var name:String;
    public function FileLoader(name:String, localPath:String, webPath:String, md5:String = null)
    {
        this.name = name;
        super(localPath, webPath, md5, true);
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
    public function MD5Check(){}
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
            var _hash:String = NativeAbilities.instance.getMD5(file.nativePath);
            dispatchEventWith(Event.COMPLETE, false, hash == _hash);
            return 
        }
            
        var nativeProcessStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
        var exe:File = File.applicationDirectory.resolvePath("MD5.exe");
        nativeProcessStartupInfo.executable = exe;

        var processArgs:Vector.<String> = new Vector.<String>();
        processArgs[0] = "-src";
        processArgs[1] = file.nativePath;
        nativeProcessStartupInfo.arguments = processArgs;

        var process:NativeProcess = new NativeProcess();
        process.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, process_DataHandler);
        // now = getTimer();
        process.start(nativeProcessStartupInfo);
    }

    private function process_DataHandler(event:ProgressEvent):void
    {
        var process:NativeProcess = event.currentTarget as NativeProcess;
        var equalprocess:Boolean = process.standardOutput.readUTFBytes(process.standardOutput.bytesAvailable) == this.hash;
        dispatchEventWith(Event.COMPLETE, false, equalprocess);
    }
}