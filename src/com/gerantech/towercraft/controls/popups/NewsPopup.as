package com.gerantech.towercraft.controls.popups
{
	import com.gerantech.towercraft.controls.buttons.CustomButton;
	
	import flash.geom.Rectangle;
	
	import feathers.controls.WebView;
	import feathers.layout.AnchorLayoutData;
	
	import starling.core.Starling;
	import starling.events.Event;

	public class NewsPopup extends MessagePopup
	{
		private var webView:WebView;
		private var closeButton:CustomButton;
		public function NewsPopup()
		{
			super(loc("popup_news_title"), loc("close_button"));
		}
		
		override protected function initialize():void
		{
			super.initialize();
			transitionOut.destinationBound = transitionIn.sourceBound = new Rectangle(stage.stageWidth*0.1, stage.stageHeight*0.1, stage.stageWidth*0.8, stage.stageHeight*0.8);
			transitionOut.sourceBound = transitionIn.destinationBound = new Rectangle(stage.stageWidth*0.02, stage.stageHeight*0.02, stage.stageWidth*0.96, stage.stageHeight*0.96);
			rejustLayoutByTransitionData();
			
			webView = new WebView();
			webView.layoutData = new AnchorLayoutData(padding*4, padding, padding*5, padding);
			webView.loadURL(loc("popup_news_url"));
			webView.addEventListener(Event.COMPLETE, webView_completeHandler);
		}
		
		private function closeButton_triggeredHandler(event:Event):void
		{
			closeButton.removeEventListener(Event.TRIGGERED, closeButton_triggeredHandler);
			close();
		}
		
		private function webView_completeHandler(event:Event):void
		{
			webView.removeEventListener(Event.COMPLETE, webView_completeHandler);
			webView.alpha = 0;
			addChild(webView);
			Starling.juggler.tween(webView, 0.8, {delay:0.5, alpha:1});
		}
	}
}