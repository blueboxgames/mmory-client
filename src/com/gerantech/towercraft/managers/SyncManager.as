package com.gerantech.towercraft.managers
{
    import com.gerantech.towercraft.models.AppModel;
    import com.gerantech.towercraft.utils.LoadAndSaver;
    import com.gerantech.towercraft.utils.LoadUtil;

    import flash.filesystem.File;
    import flash.net.SharedObject;

    import starling.events.Event;
    import starling.events.EventDispatcher;

    public class SyncManager extends EventDispatcher
    {
        private static const DEBUG:Boolean = true;
        
        private static var _instance:SyncManager;
        
        public static function get instance():SyncManager
        {
            if( _instance == null )
                _instance = new SyncManager();
            return _instance;
        }

        private var loadTool:LoadUtil;

        public function SyncManager()
        {
            super();
            this.loadTool = new LoadUtil();
        }

        // ---- Core Functions ----
        /**
         * Given an object of name and data will load them.
         */
        public function sync(data:Object):void
        {
            var loader:Vector.<LoadAndSaver> = new Vector.<LoadAndSaver>;
            for (var name:String in data )
            {
                if( isLatest(name, data[name].md5 ) )
                {
                    if( DEBUG )
                        trace(name + " | md5: " + data[name].md5 + " size: " + getFileSize(name));
                }
                else
                {
                    if( DEBUG )
                        trace(name + " queued for load.");
                    this.pushToLoader(name, data, loader);
                }
            }

            if( loader.length == 0 )
            {
                if( DEBUG )
                    trace("Sync complete.");
                this.dispatchEventWith(Event.COMPLETE);
                return;
            }

            this.loadTool.addEventListener(Event.ADDED, this.item_completeHandler);
            this.loadTool.addEventListener(Event.COMPLETE, this.sync_completeHandler);
            this.loadTool.loadAll(loader);
        }
        // ---- Event Listeners ----
        /**
         * Saves asset hash in user data.
         */
        private function item_completeHandler(e:*):void
        {
            var filename:String = LoadUtil.itemNameFromPath(e.data.target.localPath);
            this.setAssetLocalHash(filename, e.data.target.md5);
        }
        /**
         * Disposes event listeners and dispatches complete event.
         */
        private function sync_completeHandler(e:*):void
        {
            if( DEBUG )
                trace("Sync complete.");
            this.dispatchEventWith(Event.COMPLETE);
            this.dispose();
        }
        // ---- Utility Function ----
        /**
         * A utility function which checks if given asset name checks it's
         * cached md5 returns true if it's hash match else will return false.
         */
        private function isLatest(name:String, md5:String):Boolean
        {
            var hash:String = getAssetLocalHash(name);
            if( getAssetLocalHash(name) == md5 )
            {
                return true;
            }
            return false;
        }
        /**
         * Given an assetName returns it's hash, returns null if not available.
         */
        private function getAssetLocalHash(assetName:String):String
        {
            var so:SharedObject = SharedObject.getLocal(AppModel.instance.descriptor.server + "-user-assets");
            return so.data[assetName] as String;
        }
        /**
         * Checks hash correctness and save it with asset name in user data.
         */
        private function setAssetLocalHash(assetName:String, assetHash:String):Boolean
        {
            if( assetHash != null && assetHash.length == 32 )
            {
                var so:SharedObject = SharedObject.getLocal(AppModel.instance.descriptor.server + "-user-assets");
                so.data[assetName] = assetHash;
                so.flush(100000);
                return true;
            }
            return false;
        }
        /**
         * Get a new loader for given asset name.
         */
        private function getLoader(name:String, data:Object):LoadAndSaver
        {
            var path:String = getFilePath(name);
            var address:String = data[name]["url"];
            var md5:String = data[name]["md5"];
            return new LoadAndSaver(path, "http://127.0.0.1:8080" + address, md5, true);
        }
        /**
         * Pushes loader into loadingPool.
         */
        private function pushToLoader(name:String, data:Object, loadPool:Vector.<LoadAndSaver>):void
        {
            loadPool.push(getLoader(name, data));
        }
        /**
         * Given name returns it's path.
         */
        private function getFilePath(name:String):String
        {
            return File.applicationStorageDirectory.resolvePath(name).nativePath;
        }
        /**
         * Given name returns it's file size.
         */
        private function getFileSize(name:String):Number
        {
            return File.applicationStorageDirectory.resolvePath(name).size;
        }
        /**
         * Dispose function.
         */
        public function dispose():void
        {
            this.loadTool.removeEventListener(Event.ADDED, this.item_completeHandler);
            this.loadTool.removeEventListener(Event.COMPLETE, this.sync_completeHandler);
            this.loadTool = null;
        }
    }
}