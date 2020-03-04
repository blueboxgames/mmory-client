package com.gerantech.towercraft.controls.popups
{
    import com.gerantech.extensions.NativeAbilities;
    import com.gerantech.mmory.core.constants.MessageTypes;
    import com.gerantech.mmory.core.constants.SFSCommands;
    import com.gerantech.towercraft.controls.texts.CustomTextInput;
    import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
    import com.gerantech.towercraft.models.AppModel;
    import com.gerantech.towercraft.themes.MainTheme;
    import com.gerantech.towercraft.utils.Utils;
    import com.smartfoxserver.v2.core.SFSEvent;
    import com.smartfoxserver.v2.entities.data.SFSObject;

    import feathers.controls.Button;
    import feathers.layout.AnchorLayoutData;

    import flash.geom.Rectangle;
    import flash.text.ReturnKeyLabel;
    import flash.text.SoftKeyboardType;

    import starling.events.Event;

    public class InvitationEnterCodePopup extends SimpleHeaderPopup
    {
        private var inputDisplay:CustomTextInput;
        private var submitButton:Button;
        
        public function InvitationEnterCodePopup() { super(); }
        override protected function initialize():void
        {
            title = loc("popup_invitation_ask");

            super.initialize();
            var _p:int = 100;
            var _h:int = 560;
            var pad:int = 20;
            closeWithKeyboard = closeOnOverlay = false;

            inputDisplay = new CustomTextInput(SoftKeyboardType.DEFAULT, ReturnKeyLabel.GO);
            inputDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, -20);
            inputDisplay.prompt = loc("popup_invitation_code");
            inputDisplay.restrict = "A-Za-z0-9"
            inputDisplay.setSize(500, 110);
            addChild(inputDisplay);
            
            submitButton = new Button();
            submitButton.width = 420;
            submitButton.height = 120;
            submitButton.label = loc("popup_invitation_send");
            submitButton.styleName = MainTheme.STYLE_BUTTON_SMALL_HILIGHT;
            submitButton.layoutData = new AnchorLayoutData(NaN, NaN, 50, NaN, 0);
            submitButton.addEventListener(Event.TRIGGERED, submitButton_triggeredHandler);
            addChild(submitButton);
            
            transitionIn.sourceBound = new Rectangle(_p,	stageHeight* 0.5 - _h * 0.4,	stageWidth - _p * 2,	_h * 0.8);
            transitionIn.destinationBound = new Rectangle(_p,	stageHeight* 0.5 - _h * 0.5,	stageWidth - _p * 2,	_h * 1.0);
            rejustLayoutByTransitionData();
        }

        protected function submitButton_triggeredHandler(event:Event):void
        {
            if( this.inputDisplay.text.length == 0 )
            {
                appModel.navigator.addLog(loc("popup_invitation_-4"));
                return;
            }
            
            var sfs:SFSObject = new SFSObject();
            sfs.putText("ic", this.inputDisplay.text);
            sfs.putText("udid", appModel.platform == AppModel.PLATFORM_ANDROID ? NativeAbilities.instance.deviceInfo.id : Utils.getPCUniqueCode());
            SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_responseHandler);
            SFSConnection.instance.sendExtensionRequest(SFSCommands.BUDDY_ADD, sfs);
            function sfsConnection_responseHandler(event:SFSEvent):void
            {
                if (event.params.cmd != SFSCommands.BUDDY_ADD)
                    return;
                SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_responseHandler);
                var params:SFSObject = event.params.params as SFSObject;
                if( params.getInt("response") != MessageTypes.RESPONSE_SUCCEED )
                {
                    appModel.navigator.addLog(loc("popup_invitation_" + params.getInt("response"),  [params.getText("inviter")]));
                    return;
                }
                appModel.navigator.addPopup(new InvitationResultPopup(params))
                if( params.containsKey("rewardType") )
                {
					player.resources.increase(params.getInt("rewardType"), params.getInt("rewardCount") );
                    var rec:Rectangle = submitButton.getBounds(stage);
					appModel.navigator.dispatchEventWith("achieveResource", false, [rec.x + rec.width * 0.5, rec.y, params.getInt("rewardType"), params.getInt("rewardCount")]);
                }
                dispatchEventWith(Event.COMPLETE);
                close();
            }
        }

        override public function dispose():void
        {
            this.submitButton.removeEventListener(Event.TRIGGERED, this.submitButton_triggeredHandler);
            super.dispose();
        }
    }
}