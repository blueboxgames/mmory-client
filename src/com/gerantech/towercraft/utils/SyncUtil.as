package com.gerantech.towercraft.utils
{
    import com.gerantech.towercraft.models.AppModel;
    import com.gerantech.towercraft.utils.LoadAndSaver;
    import com.smartfoxserver.v2.entities.data.ISFSObject;

    import flash.filesystem.File;
    import flash.net.SharedObject;

    import starling.events.Event;
    import starling.events.EventDispatcher;

    public class SyncUtil extends EventDispatcher
    {
        private static const DEBUG:Boolean = true;
        private var content:Vector.<LoadAndSaver>;
        private var checksumData:ISFSObject;
        public function SyncUtil()
        {
            super();
            this.checksumData = AppModel.instance.loadingManager.serverData.getSFSObject("checksum");
        }

        // ---- Core Functions ----
        /**
         * Given an object of name and data will load them.
         */
        public function sync(data:Array):void
        {
            var loader:Vector.<LoadAndSaver> = new Vector.<LoadAndSaver>;
            
            for each(var name:String in data )
            {
                var x:ISFSObject = checksumData;
                if( isLatest(name, this.checksumData.getSFSObject(name).getUtfString("md5") ) )
                {
                    if( DEBUG )
                        trace(name + " | md5: " + checksumData.getSFSObject(name).getUtfString("md5") + " size: " + getFileSize(name));
                }
                else
                {
                    if( DEBUG )
                        trace(name + " queued for load.");
                    this.pushToLoader(name, loader);
                }
            }

            if( loader.length == 0 )
            {
                if( DEBUG )
                    trace("Sync complete.");
                this.dispatchEventWith(Event.COMPLETE);
                return;
            }

            this.loadAll(loader);
        }
        private function load(item:LoadAndSaver):void
        {
            item.addEventListener(Event.COMPLETE, item_completeHandler);
            item.start();
        }

        private function loadAll(content:Vector.<LoadAndSaver>):void
        {
            this.content = content;
            for each(var item:LoadAndSaver in this.content)
                load(item);
        }
        // ---- Event Listeners ----
        /**
         * Saves asset hash in user data.
         */
        private function item_completeHandler(e:*):void
        {
            var filename:String = this.itemNameFromPath(e.target.localPath);
            this.setAssetLocalHash(filename, e.target.md5);
            if( this.allExist() )
            {
                if( DEBUG )
                    trace("Sync complete.");
                this.dispatchEventWith(Event.COMPLETE);
            }
        }
        // ---- Utility Function ----
        /**
         * Finds a filename from it's path
         */
        private function itemNameFromPath(path:String):String
        {
            var relativePath:String = "";
            relativePath = path.split(File.applicationStorageDirectory.nativePath)[1].substring(1);
            relativePath = relativePath.replace(/\\/g, "/");
            return relativePath;
        }
        /**
         * Checks for all content exist in filesystem, their integrity has been checked
         * by LoadAndSaver.
         */
        protected function allExist():Boolean
        {
            for each(var item:LoadAndSaver in this.content)
            {
                if ( !File.applicationStorageDirectory.resolvePath(item.localPath).exists )
                    return false;
                if ( item.loading )
                    return false;
            }
            return true;
        }
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
        private function getLoader(name:String):LoadAndSaver
        {
            var path:String = getFilePath(name);
            var address:String = this.checksumData.getSFSObject(name).getUtfString("url");
            var md5:String = this.checksumData.getSFSObject(name).getUtfString("md5");
            return new LoadAndSaver(path, address, md5, true);
        }
        /**
         * Pushes loader into loadingPool.
         */
        private function pushToLoader(name:String, loadPool:Vector.<LoadAndSaver>):void
        {
            loadPool.push(getLoader(name));
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
    }
}