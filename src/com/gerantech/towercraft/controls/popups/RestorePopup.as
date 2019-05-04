package com.gerantech.towercraft.controls.popups
{
	import com.gerantech.towercraft.controls.texts.CustomTextInput;
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	import com.gerantech.towercraft.events.LoadingEvent;
	import com.gerantech.towercraft.models.vo.UserData;
	
	import flash.geom.Rectangle;
	import flash.text.ReturnKeyLabel;
	import flash.text.SoftKeyboardType;
	
	import starling.events.Event;

	public class RestorePopup extends ConfirmPopup
	{
		private var uernameInput:CustomTextInput;
		private var passwordInput:CustomTextInput;
		private var errorDisplay:RTLLabel;
		
		public function RestorePopup()
		{
			super(loc("popup_restore_title"), loc("popup_restore_title"), null);
		}
		
		override protected function initialize():void
		{
			super.initialize();
			transitionIn.destinationBound = transitionIn.sourceBound = new Rectangle(stage.stageWidth*0.10, stage.stageHeight*0.3, stage.stageWidth*0.8, stage.stageHeight*0.4);
			transitionOut.destinationBound = transitionOut.sourceBound = new Rectangle(stage.stageWidth*0.10, stage.stageHeight*0.3, stage.stageWidth*0.8, stage.stageHeight*0.4);
			
			uernameInput = new CustomTextInput(SoftKeyboardType.NUMBER, ReturnKeyLabel.DEFAULT);
			uernameInput.restrict = "0-9";
			uernameInput.prompt = "id";
			container.addChild(uernameInput);
			
			passwordInput = new CustomTextInput(SoftKeyboardType.DEFAULT, ReturnKeyLabel.DEFAULT);
			passwordInput.prompt = "pass";
			container.addChild(passwordInput);
			
			errorDisplay = new RTLLabel("", 0xFF0000, null, null, true, null, 0.8);
			container.addChild(errorDisplay);

			rejustLayoutByTransitionData();
		}
		
		protected override function acceptButton_triggeredHandler(event:Event):void
		{
			
			if ( uernameInput.text.length == 0 || passwordInput.text.length == 0)
			{
				errorDisplay.text = loc( "popup_select_inputs_size" );
				return;
			}
			UserData.instance.id = int(uernameInput.text);
			UserData.instance.password = passwordInput.text;
			UserData.instance.save();
			appModel.loadingManager.dispatchEvent(new LoadingEvent(LoadingEvent.FORCE_RELOAD));
			close();
		}
	}
}