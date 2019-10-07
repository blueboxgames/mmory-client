package com.gerantech.towercraft.utils
{
    import com.gerantech.towercraft.utils.LoadAndSaver;

    import flash.events.IOErrorEvent;
    import flash.filesystem.File;

    import starling.events.Event;
    import starling.events.EventDispatcher;

    public class LoadUtil extends EventDispatcher
    {
        private var content:Vector.<LoadAndSaver>;
        public function LoadUtil(){}
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
        public function loadAll(content:Vector.<LoadAndSaver>):void
        {
            this.content = content;
            for each(var item:LoadAndSaver in this.content)
                load(item);
        }

        // ---- Event Handlers ----
        /**
         * Will dispatch COMPLETE when the whole list of files is loaded.
         */
        protected function item_completeHandler(e:*):void
        {
            dispatchEventWith(Event.ADDED, false, e);
            if( allExist() )
            {
                this.content = null;
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
        public static function itemNameFromPath(path:String):String
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
    }
}