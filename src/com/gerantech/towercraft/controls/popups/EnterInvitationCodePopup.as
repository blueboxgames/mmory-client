package com.gerantech.towercraft.controls.popups
{
    import com.gerantech.extensions.NativeAbilities;
    import com.gerantech.mmory.core.constants.MessageTypes;
    import com.gerantech.towercraft.controls.texts.ShadowLabel;
    import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
    import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
    import com.gerantech.towercraft.models.AppModel;
    import com.gerantech.towercraft.themes.MainTheme;
    import com.gerantech.towercraft.utils.Utils;
    import com.smartfoxserver.v2.core.SFSEvent;
    import com.smartfoxserver.v2.entities.data.ISFSObject;
    import com.smartfoxserver.v2.entities.data.SFSObject;

    import feathers.controls.Button;
    import feathers.controls.TextInput;
    import feathers.layout.AnchorLayoutData;

    import flash.geom.Rectangle;

    import starling.display.Image;
    import starling.events.Event;

    public class EnterInvitationCodePopup extends SimplePopup
    {
        private var inputDisplay:TextInput;
        private var closeButton:Button;
        
        public function EnterInvitationCodePopup() { super(); }
        override protected function initialize():void
        {
            super.initialize();
            var _p:int = 100;
            var _h:int = 560;
            var pad:int = 20;
            closeWithKeyboard = closeOnOverlay = false;

            var titleDisplay:ShadowLabel = new ShadowLabel(loc("invitation_enter_ask"), 1, 0);
            titleDisplay.layoutData = new AnchorLayoutData(70, NaN, NaN, NaN, 0);
            addChild(titleDisplay);
            
            inputDisplay = new TextInput();
            inputDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, -20);
            inputDisplay.setSize(500, 110);
            addChild(inputDisplay);
            
            var submitButton:Button = new Button();
            submitButton.layoutData = new AnchorLayoutData(NaN, NaN, 50, NaN, 0);
            submitButton.styleName = MainTheme.STYLE_BUTTON_SMALL_HILIGHT;
            submitButton.label = loc("invitation_send");
            submitButton.width = 420;
            submitButton.height = 120;
            addChild(submitButton);
            
            submitButton.addEventListener(Event.TRIGGERED, addRequestButton_triggeredHandler);

            // -=-=-=-=-=-=-=-=-=-=-=-=-=-[Close Button]-=-=-=-=-=-=-=-=-=-=-=-=-=-
            this.closeButton = new Button();
            this.closeButton.styleName = MainTheme.STYLE_BUTTON_SMALL_DANGER;;
            this.closeButton.defaultIcon = new Image(appModel.assets.getTexture("theme/icon-cross"));
            this.closeButton.addEventListener(Event.TRIGGERED, this.closeButton_triggeredHandler);
            this.closeButton.layoutData = new AnchorLayoutData(15, 15);
            this.closeButton.width = 70;
            this.closeButton.height = 70;
            this.addChild(closeButton);

            transitionIn.sourceBound = new Rectangle(_p,	stageHeight* 0.5 - _h * 0.4,	stageWidth - _p * 2,	_h * 0.8);
            transitionIn.destinationBound = new Rectangle(_p,	stageHeight* 0.5 - _h * 0.5,	stageWidth - _p * 2,	_h * 1.0);
            rejustLayoutByTransitionData();
        }

        protected function closeButton_triggeredHandler(event:Event):void
        {
            dispatchEventWith(Event.COMPLETE);
            close();
        }

        protected function addRequestButton_triggeredHandler(e:Event):void
        {
            if( this.inputDisplay.text.length == 0 )
            {
                appModel.navigator.addLog(loc("popup_invitation_-1"));
                return;
            }
            
            var sfs:SFSObject = new SFSObject();
            sfs.putText("invitationCode", this.inputDisplay.text);
            sfs.putText("udid", appModel.platform == AppModel.PLATFORM_ANDROID ? NativeAbilities.instance.deviceInfo.id : Utils.getPCUniqueCode());
            SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_responseHandler);
            SFSConnection.instance.sendExtensionRequest(SFSCommands.BUDDY_ADD, sfs);
            function sfsConnection_responseHandler(event:SFSEvent):void
            {
                var params:ISFSObject = event.params.params;
                if( params.getInt("response") == MessageTypes.RESPONSE_NOT_ALLOWED )
                {
                    appModel.navigator.addLog(loc("popup_invitation_" + params.getInt("response")));
                    return;
                }
                if (event.params.cmd != SFSCommands.BUDDY_ADD)
                    return SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_responseHandler);
                if( params.containsKey("rewardType") )
					player.resources.increase(params.getInt("rewardType"), params.getInt("rewardCount") );
                dispatchEventWith(Event.COMPLETE);
                close();
            }
        }

        override public function dispose():void
        {
            this.closeButton.removeEventListener(Event.TRIGGERED, this.closeButton_triggeredHandler);
            super.dispose();
        }
    }
}