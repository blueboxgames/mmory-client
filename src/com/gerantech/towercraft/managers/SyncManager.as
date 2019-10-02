package com.gerantech.towercraft.managers
{
    import com.gerantech.towercraft.utils.LoadAndSaver;
    import com.gerantech.towercraft.utils.LoadUtil;
    import com.smartfoxserver.v2.entities.data.ISFSObject;

    import flash.filesystem.File;
    import flash.net.FileReference;

    import starling.assets.AssetManager;
    import starling.events.Event;
    import flash.events.IOErrorEvent;
    import starling.events.EventDispatcher;

    public class SyncManager extends EventDispatcher
    {
        public static var SERVER_URL:String = null;
        
        private static var INITIAL_DIRECTORY:Number = 0;
        private static var TEMP_DIRECTORY:Number = 10;

        public var scriptData:String = "";
        public var serverLastModified:Number = 0;

        // Data recieved from server.
        private var filesMD5:Object;
        private var filesTime:Object;
        private var filesAddress:Object;
        private var loadedAssetCount:int = 0;

        private var initialFiles:Object;

        private var _serverAssetsHash:ISFSObject;
        public function get serverAssetsHash():ISFSObject
        {
            return _serverAssetsHash;
        }
        /**
         * On Server asset hash change it will redownload every asset changed
         * or download initial files if they do not exist.
         */
        public function set serverAssetsHash(value:ISFSObject):void
        {
            _serverAssetsHash = value;
            this.serverLastModified = value.getLong("lastMod");
            this.filesMD5 = value.getSFSObject("md5").toObject();
            this.filesTime = value.getSFSObject("time").toObject();
            this.filesAddress = value.getSFSObject("address").toObject();

            this.dispatchEventWith(Event.READY);
        }

        private function assetManager_redownloadReadyHandler(e:Event):void
        {
            File.applicationStorageDirectory.resolvePath("ext").getDirectoryListing()[0].moveTo(File.applicationStorageDirectory.resolvePath("ext/" + this.serverLastModified))
            this.dispatchEventWith(Event.COMPLETE);
        }

        private static var _instance:SyncManager;

        public function SyncManager()
        {
            this.addEventListener(Event.READY, syncManager_readyHandler);
            super();
        }

        public static function get instance():SyncManager
        {
            if(_instance == null)
                _instance = new SyncManager();
            return _instance;
        }

        // ---- Core functions ----
        /**
         * Syncs current assets available with server time.
         */
        private function syncAssets(mdCheck:Boolean = false):void
        {
            // Gets the last synchronization time which had happended with server.
            var lastSyncTime:Number = getLastSyncTime();

            // Find outdated files.
            var outDatedFiles:Array = outDatedExistingFilesOf(lastSyncTime);
            if(outDatedFiles.length == 0)
            {
                syncAssetsLoad_completeHandler(null)
                return;
            }
            // Start downloading outdated file.
            var outDatedFilesLoaders:Vector.<LoadAndSaver> = new Vector.<LoadAndSaver>;
            for each (var outDatedFile:String in outDatedFiles)
            {
                var path:String = File.applicationStorageDirectory.resolvePath("ext/" + lastSyncTime + outDatedFile).nativePath;
                var dataLoader:LoadAndSaver = new LoadAndSaver(path, SERVER_URL + ":8080/" + this.filesAddress[outDatedFile], "NOK", this.filesMD5[outDatedFile]);
                outDatedFilesLoaders.push(dataLoader);
            }
            var loadingTool:LoadUtil = new LoadUtil(outDatedFilesLoaders);
            loadingTool.addEventListener(Event.COMPLETE, syncAssetsLoad_completeHandler);
            loadingTool.loadAll();
        }

        private function loadInitialAssets():void
        {
            var initialFilesLoaders:Vector.<LoadAndSaver> = new Vector.<LoadAndSaver>;
            for (var file:String in this.filesAddress)
            {
                if(isInitial(this.filesAddress[file]))
                {
                    var path:String = File.applicationStorageDirectory.resolvePath("ext/" + INITIAL_DIRECTORY + file).nativePath;
                    var dataLoader:LoadAndSaver = new LoadAndSaver(path, SERVER_URL + ":8080/" + this.filesAddress[file], "NOK", this.filesMD5[file]);
                    initialFilesLoaders.push(dataLoader);
                }
            }
            var loadingTool:LoadUtil = new LoadUtil(initialFilesLoaders);
            loadingTool.addEventListener(Event.COMPLETE, initialDownloadCompleteHandler);
            loadingTool.loadAll();
        }

        // ---- Event Handlers ----
        /**
         * Initial assets are created in "ext/0" path, this directory should be moved
         * to latest version of server.
         */
        private function initialDownloadCompleteHandler(e:*):void
        {
            this.getAssetDirectoryReference(INITIAL_DIRECTORY).moveToAsync(this.getAssetDirectoryReference(this.serverLastModified));
        }
        
        /**
         * When assets are synced we will 
         */
        private function syncAssetsLoad_completeHandler(e:*):void
        {
            if( getLastSyncTime() < this.serverLastModified )
                this.getAssetDirectoryReference(getLastSyncTime()).moveToAsync(this.getAssetDirectoryReference(this.serverLastModified));
            this.dispatchEventWith(Event.COMPLETE);
        }

        /**
         * After server checksum has reached, asset manager can start working.
         */
        private function syncManager_readyHandler(e:*):void
        {
            this.removeEventListener(Event.READY, syncManager_readyHandler);
            if( !getAssetDirectoryReference().exists )
            {
                getAssetDirectoryReference(INITIAL_DIRECTORY).createDirectory();
                this.loadInitialAssets();
            }
            this.syncAssets();
        }

        // ---- Utility functions ----
        /**
         * Checks if file is initial file or not.
         */
        private function isInitial(item:String):Boolean
        {
            if(item == "ext/script-data.cs" || item.split("ext/inits").length == 2)
                return true;
            return false;
        }

        /**
         * This function walks assets directory "ext" for the directory
         * with maximum number returns the maximum number.
         */
        private function getLastSyncTime():Number
        {
            var lastSync:Number = -1;
            if( File.applicationStorageDirectory.resolvePath("ext").exists )
            {
                for( var count:Number in File.applicationStorageDirectory.resolvePath("ext").getDirectoryListing() )
                    lastSync = Math.max(lastSync, Number(File.applicationStorageDirectory.resolvePath("ext").getDirectoryListing()[count].name));
            }
            return lastSync;
        }

        /**
         * Find required files to download.
         */
        private function outDatedFilesOf(time:Number):Array
        {
            var outDatedFiles:Array = new Array();
            for( var file:String in this.filesTime )
            {
                if(Number(this.filesTime[file]) > time)
                    outDatedFiles.push(file);
            }
            return outDatedFiles;
        }

        private function outDatedExistingFilesOf(time:Number):Array
        {
            var outDatedFiles:Array = new Array();
            // If last synchronization time is higher or equal to server time
            // we are sync.
            if( time >= this.serverLastModified )
                return outDatedFiles;

            for each( var file:String in outDatedFilesOf(time) )
            {
                if( this.has(file, time) )
                    outDatedFiles.push(file);
            }
            return outDatedFiles;
        }

        /**
         * Checks a file existance.
         */
        private function has(file:String, time:Number=NaN):Boolean
        {
            time = (isNaN(time)) ? this.serverLastModified : time;
            if( File.applicationStorageDirectory.resolvePath("ext/" + time.toString() + file).exists )
                return true;
            return false;
        }

        /**
         * Get the directory reference by it's time.
         */
        private function getAssetDirectoryReference(time:Number=NaN):File
        {
            if(isNaN(time))
                return File.applicationStorageDirectory.resolvePath("ext/");
            return File.applicationStorageDirectory.resolvePath("ext/" + time.toString());
        }

        /**
         * Get the file reference by it's name and time.
         */
        private function getAssetFileReference(name:String, time:Number):File
        {
            return File.applicationStorageDirectory.resolvePath("ext/" + time.toString() + name);
        }
    }
}