package com.gerantech.towercraft.controls.popups
{
	import com.gerantech.towercraft.controls.switchers.Switcher;
	import com.gerantech.towercraft.controls.texts.CustomTextInput;
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
	import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
	import com.smartfoxserver.v2.core.SFSEvent;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	
	import flash.geom.Rectangle;
	import flash.text.ReturnKeyLabel;
	import flash.text.SoftKeyboardType;
	
	import starling.events.Event;

	public class BroadcastMessagePopup extends ConfirmPopup
	{
		private var messageInput:CustomTextInput;
		private var reseiversInput:CustomTextInput;
		private var dataInput:CustomTextInput;
		private var errorDisplay:RTLLabel;
		private var typeSwitcher:Switcher;
		private var isPushSwitcher:Switcher;
		private var receivers:String;
		
		public function BroadcastMessagePopup(receivers:String=null, data:Object=null)
		{
			super("Push Message", "Send");
			this.receivers = receivers;
			this.data = data;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			transitionOut.destinationBound = transitionIn.sourceBound = new Rectangle(stage.stageWidth*0.10, stage.stageHeight*0.20, stage.stageWidth*0.8, stage.stageHeight*0.6);
			transitionIn.destinationBound = transitionOut.sourceBound = new Rectangle(stage.stageWidth*0.10, stage.stageHeight*0.15, stage.stageWidth*0.8, stage.stageHeight*0.7);
			
			messageInput = new CustomTextInput(SoftKeyboardType.DEFAULT, ReturnKeyLabel.DEFAULT, 0, true);
			messageInput.prompt = "Insert Message";
			messageInput.height = 200;
			container.addChild(messageInput);
			
			dataInput = new CustomTextInput(SoftKeyboardType.DEFAULT, ReturnKeyLabel.DEFAULT);
			data == null ? (dataInput.prompt = "Insert data") : (dataInput.text = data+"");
			dataInput.height = 100;
			container.addChild(dataInput);
			
			reseiversInput = new CustomTextInput(SoftKeyboardType.DEFAULT, ReturnKeyLabel.DEFAULT);
			receivers == null ? reseiversInput.prompt = "Recievers" : reseiversInput.text = receivers;
			reseiversInput.height = 300;
			container.addChild(reseiversInput);
			
			typeSwitcher = new Switcher(0, 0, 50, 50);
			typeSwitcher.height = 80;
			container.addChild(typeSwitcher);
			
			isPushSwitcher = new Switcher(0, 0, 1, 1);
			isPushSwitcher.height = 80;
			container.addChild(isPushSwitcher);
			
			errorDisplay = new RTLLabel("", 0xFF0000, null, null, true, null, 0.8);
			container.addChild(errorDisplay);
			
			rejustLayoutByTransitionData();
		}
		
		protected override function acceptButton_triggeredHandler(event:Event):void
		{
			
			if ( messageInput.text.length == 0)
			{
				errorDisplay.text = "Message can not be emrty.";
				return;
			}
			if ( reseiversInput.text.length == 0)
			{
				errorDisplay.text = "Insert a receiver.";
				return;
			}
		
			// provide recievers int array
			var receivers:Array = reseiversInput.text.split(",");
			for (var i:int = 0; i < receivers.length; i++) 
				receivers[i] = int(receivers[i]);
			
			var sfs:SFSObject = SFSObject.newInstance();
			sfs.putUtfString("text", messageInput.text );
			sfs.putText("data", dataInput.text );
			sfs.putIntArray("receivers", receivers);
			sfs.putShort("type", typeSwitcher.value );
			sfs.putBool("isPush", isPushSwitcher.value==1 );
			SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsCOnnection_extensionResponseHandler);
			SFSConnection.instance.sendExtensionRequest(SFSCommands.INBOX_BROADCAST, sfs );
		}
		
		protected function sfsCOnnection_extensionResponseHandler(event:SFSEvent):void
		{
			if( event.params.cmd != SFSCommands.INBOX_BROADCAST )
				return;
			SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsCOnnection_extensionResponseHandler);
			errorDisplay.text = event.params.params.getInt("delivered") + " messages delivered.";
			dispatchEventWith(Event.SELECT, false, data);
		}
	}
}