package com.gerantech.towercraft.utils
{
    import com.adobe.crypto.MD5;
    import com.gerantech.towercraft.utils.LoadAndSaver;

    import flash.filesystem.File;
    import flash.utils.ByteArray;

    import starling.events.Event;
    import starling.events.EventDispatcher;
    import flash.events.IOErrorEvent;

    public class LoadUtil extends EventDispatcher
    {
        private var checksums:Object;
        private var content:Vector.<LoadAndSaver>;
        public function LoadUtil(content:Vector.<LoadAndSaver>)
        {
            this.content = content;
        }

        /**
         * Loads one file, used by load all and fault system to load a file.
         */
        private function load(item:LoadAndSaver):void
        {
            item.addEventListener(IOErrorEvent.IO_ERROR, item_ioErrorHandler);
            item.addEventListener(Event.COMPLETE, item_completeHandler);
            item.start();
        }

        /**
         * Loads the whole list of given array to it.
         */
        public function loadAll():void
        {
            for each(var item:LoadAndSaver in this.content)
                load(item);
        }

        // ---- Event Handlers ----
        /**
         * Will dispatch COMPLETE when the whole list of files is loaded.
         */
        protected function item_completeHandler(e:*):void
        {
            if( allExist() )
            {
                for each(var item:LoadAndSaver in this.content)
                {
                    if(item.gtStreamer != null)
                        item.gtStreamer.close();
                }
                dispatchEventWith(Event.COMPLETE);
            }
        }

        /**
         * Redownload a file if it fail.
         */
        protected function item_ioErrorHandler(e:*):void
        {
            var item:LoadAndSaver = e.target as LoadAndSaver;
            load(item);
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

        /**
         * Checks for all content exist in filesystem, their integrity has been checked
         * by LoadAndSaver.
         */
        protected function allExist():Boolean
        {
            for each(var item:LoadAndSaver in this.content)
            {
                if ( !File.applicationStorageDirectory.resolvePath(item.localPath).exists )
                    return false
            }
            return true;
        }
    }
}