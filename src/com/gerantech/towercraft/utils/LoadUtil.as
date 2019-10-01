package com.gerantech.towercraft.utils
{
    import com.adobe.crypto.MD5;
    import com.gerantech.towercraft.utils.LoadAndSaver;

    import flash.filesystem.File;
    import flash.utils.ByteArray;

    import starling.events.Event;
    import starling.events.EventDispatcher;

    /**
     * 
     */
    public class LoadUtil extends EventDispatcher
    {
        private var checksums:Object;
        private var content:Vector.<LoadAndSaver>;
        public function LoadUtil(content:Vector.<LoadAndSaver>, checksums:Object)
        {
            this.checksums = checksums;
            this.content = content;
        }

        private function load(item:LoadAndSaver):void
        {
            item.addEventListener(Event.COMPLETE, item_completeHandler);
            item.start();
        }

        public function loadAll():void
        {
            for (var item:LoadAndSaver in this.content)
            {
                item.addEventListener(Event.COMPLETE, item_completeHandler);
                item.start();
            }
        }

        // ---- Event Handlers ----
        protected function item_completeHandler(e:*):void
        {
            var item:LoadAndSaver = e.target as LoadAndSaver;
            if ( !md5check( item.byteArray, checksums[itemNameFromPath(item.localPath)] ) )
            {
                load(item);
                return;
            }

            if( allExist() )
                dispatchEventWith(Event.COMPLETE);
        }

        // ---- Util functions ----
        /**
         * Finds a filename from it's path
         */
        protected function itemNameFromPath(path:String):String
        {
            var relativePath:String = "";
            relativePath = path.split(File.applicationStorageDirectory.resolvePath("ext").nativePath)[1];
            relativePath = relativePath.replace(/\\/g, "/");
            relativePath = relativePath.replace(/\/[0-9]+/, "");
            return relativePath;
        }

        protected function allExist():Boolean
        {
            for each(var item:LoadAndSaver in this.content)
            {
                if ( !File.applicationStorageDirectory.resolvePath(item.localPath).exists )
                    return false
            }
            return true;
        }

        protected function md5check(m1:ByteArray, m2:String):Boolean
        {
            return (MD5.hashBinary(m1) == m2)
        }
    }
}