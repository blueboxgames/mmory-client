package com.gerantech.towercraft.controls.screens
{
  import com.gerantech.mmory.core.battle.BattleField;
  import com.gerantech.mmory.core.battle.bullets.Bullet;
  import com.gerantech.mmory.core.battle.units.Unit;
  import com.gerantech.mmory.core.constants.PrefsTypes;
  import com.gerantech.mmory.core.constants.ResourceType;
  import com.gerantech.mmory.core.constants.SFSCommands;
  import com.gerantech.mmory.core.socials.Challenge;
  import com.gerantech.mmory.core.utils.maps.IntIntMap;
  import com.gerantech.towercraft.controls.BattleHUD;
  import com.gerantech.towercraft.controls.overlays.BattleStartOverlay;
  import com.gerantech.towercraft.controls.overlays.BattleWaitingOverlay;
  import com.gerantech.towercraft.controls.overlays.EndBattleOverlay;
  import com.gerantech.towercraft.controls.overlays.EndOperationOverlay;
  import com.gerantech.towercraft.controls.overlays.EndOverlay;
  import com.gerantech.towercraft.controls.popups.UnderMaintenancePopup;
  import com.gerantech.towercraft.events.GameEvent;
  import com.gerantech.towercraft.managers.SoundManager;
  import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
  import com.gerantech.towercraft.models.tutorials.TutorialData;
  import com.gerantech.towercraft.models.tutorials.TutorialTask;
  import com.gerantech.towercraft.models.vo.BattleData;
  import com.gerantech.towercraft.models.vo.UserData;
  import com.gerantech.towercraft.themes.MainTheme;
  import com.gerantech.towercraft.views.BattleFieldView;
  import com.smartfoxserver.v2.core.SFSEvent;
  import com.smartfoxserver.v2.entities.data.ISFSArray;
  import com.smartfoxserver.v2.entities.data.ISFSObject;
  import com.smartfoxserver.v2.entities.data.SFSObject;

  import feathers.layout.AnchorLayout;
  import feathers.layout.AnchorLayoutData;

  import flash.utils.setTimeout;

  import ir.metrix.sdk.Metrix;

  import starling.animation.Transitions;
  import starling.core.Starling;
  import starling.display.Image;
  import starling.events.Event;

  public class BattleScreen extends BaseCustomScreen
  {
    static public var INDEX:int;
    static public var FRIENDLY_MODE:int;
    static public var SPECTATED_USER:int;
    static public var IN_BATTLE:Boolean;
    static public var DEBUG_MODE:Boolean;
    static public var WAITING:BattleWaitingOverlay;

    public var hud:BattleHUD;
    private var touchEnable:Boolean;
    private var battleData:BattleData;

    public function BattleScreen()
    {
      SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_extensionResponseHandler);

      appModel.battleFieldView = new BattleFieldView();
      appModel.battleFieldView.addEventListener(Event.OPEN,	battleFieldView_openHandler);
      appModel.battleFieldView.init();
      addChild(appModel.battleFieldView);

      backgroundSkin = new Image(appModel.theme.quadSkin);
      Image(backgroundSkin).scale9Grid = MainTheme.QUAD_SCALE9_GRID;
      Image(backgroundSkin).color = 0xCCB3A3;
    }

    protected function battleFieldView_openHandler(e:Event):void
    {
      appModel.battleFieldView.removeEventListener(Event.OPEN, battleFieldView_openHandler);
      layout = new AnchorLayout();

      var params:SFSObject = new SFSObject();
      params.putInt("index", INDEX);
      params.putInt("friendlyMode", FRIENDLY_MODE);
      if( SPECTATED_USER > -1 )
        params.putInt("spectatedUser", SPECTATED_USER);
      if( DEBUG_MODE )
        params.putBool("debugMode", true);

      SFSConnection.instance.addEventListener(SFSEvent.CONNECTION_LOST,	sfsConnection_connectionLostHandler);
      if( FRIENDLY_MODE == 0 )
        SFSConnection.instance.sendExtensionRequest(SFSCommands.BATTLE_JOIN, params);
    }

    protected function sfsConnection_connectionLostHandler(event:SFSEvent):void
    {
      removeConnectionListeners();
    }
    
    /**
     * Listens for incoming commands from server
     */
    protected function sfsConnection_extensionResponseHandler(event:SFSEvent):void
    {
      // Retrive data from response event
      var data:SFSObject = event.params.params as SFSObject;
      
      // Handle battle start command
      if( event.params.cmd == SFSCommands.BATTLE_JOIN )
      {
        if( data.containsKey("response") )
        {
          showErrorPopup(data);
          return;
        }

        // Setup room battle data
        this.battleData = new BattleData(data);
        this.joinBattle();
        WAITING.cancelable = false;
        return;
      }

      // Don't run any commands if battleData is not set.
      if( battleData == null )
        return;

      if( event.params.cmd == SFSCommands.BATTLE_START )
      {
        battleData.start(data.getFloat("startAt"), data.getFloat("now"));
        appModel.battleFieldView.addEventListener(Event.COMPLETE, battleFieldView_completeHandler);
        appModel.battleFieldView.start(data.getSFSArray("units"));
        return;
      }

      // Don't run any commands if battle not started.
      if( battleData.battleField == null || battleData.battleField.state < BattleField.STATE_2_STARTED )
        return;

      switch(event.params.cmd)
      {
      case SFSCommands.BATTLE_START:
        break;

      case SFSCommands.BATTLE_UNIT_CHANGE:
        appModel.battleFieldView.updateUnits(data);
        break;

      case SFSCommands.BATTLE_END:
        endBattle(data);
        break;

      case SFSCommands.BATTLE_SEND_STICKER:
        hud.showBubble(data.getInt("t"), false);
        break;

      case SFSCommands.BATTLE_SUMMON:
        if( data.containsKey("now") )
        {
          this.battleField.forceUpdate(data.getDouble("now") - this.battleField.now);
          break;
        }
        appModel.battleFieldView.summonUnits(data.getDouble("time"), data.getSFSArray("units"));
        break;

      case SFSCommands.BATTLE_NEW_ROUND:
        if( battleField.field.mode == Challenge.MODE_1_TOUCHDOWN && Math.max(data.getInt("0"), data.getInt("1")) < 3 )
          appModel.battleFieldView.requestKillPioneers(data.getInt("winner"));
        if( hud != null )
          hud.updateScores(data.getInt("round"), data.getInt("winner"), data.getInt(battleField.side + ""), data.getInt(battleField.side == 0 ? "1" : "0"), data.getInt("unitId"));
        break;

      case SFSCommands.BATTLE_ELIXIR_UPDATE:
        if( data.containsKey(battleField.side.toString()) )
          battleField.elixirUpdater.updateAt(battleField.side, data.getInt(battleField.side.toString()));
        else
          battleField.elixirUpdater.updateAt(1 - battleField.side, data.getInt(String(1 - battleField.side)));
        break;

      }
    }

    private function showErrorPopup(data:SFSObject):void
    {
      if( !WAITING.ready )
      {
        WAITING.addEventListener(Event.READY, waitingOverlay_readyHandler);
        function waitingOverlay_readyHandler():void {
          showErrorPopup(data);
        }
        return;
      }
      if( data.containsKey("umt") )
        appModel.navigator.addPopup(new UnderMaintenancePopup(data.getInt("umt"), false));
      else if( data.containsKey("response") )
        appModel.navigator.addLog(loc("error_" + data.getInt("response")));
      WAITING.disappear();
      dispatchEventWith(Event.COMPLETE);
    }

    // -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_- Start Battle _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
    private function joinBattle():void
    {
      if( this.battleData == null )
        return;
      // Starts battle if it's map is not null
      if( appModel.battleFieldView.mapBuilder == null )
        return;

      IN_BATTLE = true;
      tutorials.addEventListener(GameEvent.TUTORIAL_TASKS_STARTED, tutorials_tasksStartHandler);
      if( !WAITING.ready )
      {
        WAITING.addEventListener(Event.READY, waitingOverlay_readyHandler);
        function waitingOverlay_readyHandler():void
        {
          WAITING.removeEventListener(Event.READY, waitingOverlay_readyHandler);
          joinBattle();
        }
        return;
      }

      appModel.battleFieldView.addEventListener(Event.READY, battleFieldView_readyHandler);
      appModel.battleFieldView.load(this.battleData);
    }

    protected function battleFieldView_readyHandler(event:Event):void
    {
      appModel.battleFieldView.removeEventListener(Event.READY, battleFieldView_readyHandler);
      appModel.battleFieldView.responseSender.start();
    }

    protected function battleFieldView_completeHandler(event:Event):void
    {
      appModel.battleFieldView.removeEventListener(Event.COMPLETE, battleFieldView_completeHandler);
      WAITING.disappear();
      WAITING.addEventListener(Event.CLOSE, waitingOverlay_closeHandler);
      function waitingOverlay_closeHandler(e:Event):void
      {
        tutorials.removeAll();
        WAITING.removeEventListener(Event.CLOSE, waitingOverlay_closeHandler);
        Starling.juggler.tween(appModel.battleFieldView, 1, {delay:1, y:appModel.battleFieldView.y + 50, scale:1, transition:Transitions.EASE_IN_OUT, onComplete:showTutorials});
        if( !player.inTutorial() )
          hud.addChildAt(new BattleStartOverlay(battleData.battleField.field.isOperation() ? battleData.battleField.field.mode : -1, battleData ), 0);
      }

      // show battle HUD
      hud = new BattleHUD();
      hud.addEventListener(Event.CLOSE, backButtonHandler);
      hud.layoutData = new AnchorLayoutData(0, 0, 0, 0);
      addChild(hud);

      resetAll(battleData.sfsData);
      appModel.loadingManager.serverData.removeElement("joinedBattle");

      // play battle theme -_-_-_
      appModel.sounds.stopAll();
      appModel.sounds.addAndPlay("battle-0", null, SoundManager.CATE_THEME, SoundManager.SINGLE_BYPASS_THIS, 8);
    }

    /**
     * @private MARK: deletion
     */
    private function tutorials_tasksStartHandler(e:Event) : void
    {
      /*clearSources(sourcePlaces);
      sourcePlaces = null;*/
    }

    private function showTutorials() : void
    {
      if( appModel.battleFieldView.battleData.userType != 0 )
        return;

      if( player.getTutorStep() < 81 )
        UserData.instance.prefs.setInt(PrefsTypes.TUTOR, appModel.battleFieldView.battleData.getBattleStep() + 1);

      if( player.get_battleswins() > appModel.maxTutorBattles - 1 )
      {
        readyBattle();
        return;
      }

      // create tutorial steps
      var tutorialData:TutorialData = new TutorialData(battleField.field.mode + "_start");
      tutorialData.data = "start";
      tutorialData.addTask(new TutorialTask(TutorialTask.TYPE_MESSAGE, "tutor_" + battleField.field.mode + "_" + player.get_battleswins() + "_start", null, 500, 1500));
      tutorials.addEventListener(GameEvent.TUTORIAL_TASKS_FINISH, tutorials_tasksFinishHandler);
      tutorials.show(tutorialData);
    }

    private function readyBattle() : void
    {
      if( player.get_battleswins() < appModel.maxTutorBattles - 1 )
        appModel.battleFieldView.mapBuilder.showtutorHint(battleField.field, player.get_battleswins());

      touchEnable = true;
      hud.showDeck();
    }

    // -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_- End Battle _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
    private function endBattle(data:SFSObject, skipCelebration:Boolean = false):void
    {
      IN_BATTLE = false;
      var inTutorial:Boolean = player.get_battleswins() < appModel.maxTutorBattles + 1;
      battleField.state = BattleField.STATE_4_ENDED;
      Starling.juggler.tween(appModel.battleFieldView, 5, {delay:0.7, scale:0.95, transition:Transitions.EASE_OUT});

      tutorials.removeAll();

      var rewards:ISFSArray = data.getSFSArray("outcomes");
      var playerIndex:int = -1
      for(var i:int = 0; i < rewards.size(); i++)
      {
        if( rewards.getSFSObject(i).getInt("id") == player.id )
        {
          playerIndex = i;
          break;
        }
      }

      for each(var b:Bullet in battleField.bullets )
        b.dispose();

      // kill all units of loser except hero units.
      var loserSide:int = -1;
      if( rewards.getSFSObject(0).getInt("score") > rewards.getSFSObject(1).getInt("score") )
        loserSide = 1;
      else if( rewards.getSFSObject(0).getInt("score") < rewards.getSFSObject(1).getInt("score") )
        loserSide = 0;
      if( loserSide > -1 )
      {
        for each(var u:Unit in battleData.battleField.units)
           if( !u.disposed() && u.side == loserSide && (u.card.speed > 0 || player.get_battlesCount() < appModel.maxTutorBattles) )
            u.hit(100);
      }

      touchEnable = false;
      appModel.sounds.stopAll();
      hud.stopTimers();

      // reduce player resources
      if( playerIndex > -1 )
      {
        var outcomes:IntIntMap = new IntIntMap();
        var item:ISFSObject = rewards.getSFSObject(playerIndex);
        var bookKey:String = null;
        var _keys:Array = item.getKeys();
        for( i = 0; i < _keys.length; i++)
        {
          var key:int = int(_keys[i]);
          if( ResourceType.isBook(key) )
            bookKey = _keys[i];
          else if ( key > 0 )
          {
            if( key == ResourceType.R17_STARS )
              exchanger.collectStars(item.getInt(_keys[i]), timeManager.now);
            outcomes.set(key, item.getInt(_keys[i]));
          }
        }
        if( bookKey != null )
          outcomes.set(int(bookKey), item.getInt(bookKey));
      }

      // reserved prefs data
      if( player.get_battleswins() < 10 && rewards.getSFSObject(0).getInt("score") > 0 )
        UserData.instance.prefs.setInt(PrefsTypes.TUTOR, appModel.battleFieldView.battleData.getBattleStep() + 7);

      var challengUnlockAt:int;
      for( var c:int = 1; c < 4; c++ )
      {
        if( player.getTutorStep() > 200 + c * 10 )
          continue;
        challengUnlockAt = Challenge.getUnlockAt(game, c);
        if( challengUnlockAt > player.get_point() )
          break;
      }
      var wins_before_battle:int = player.get_battleswins();
      if( battleField.friendlyMode == 0 )
        player.addResources(outcomes);
      if( player.get_battleswins() > wins_before_battle )
        if( Metrix.instance.isSupported && (player.get_battleswins() == 10 || player.get_battleswins() == 20) )
          Metrix.instance.sendEvent(Metrix.instance.newEvent(player.get_battleswins() == 10 ? "ifrcs" : "cxftv"));

      // check new challenge unlocked
      if( challengUnlockAt > 0 && challengUnlockAt < player.get_point() )
        UserData.instance.prefs.setInt(PrefsTypes.TUTOR, 200 + c * 10);

      var endOverlay:EndOverlay;
      if( battleField.field.isOperation() )
        endOverlay = new EndOperationOverlay(appModel.battleFieldView.battleData, playerIndex, rewards, inTutorial);
      else
        endOverlay = new EndBattleOverlay(appModel.battleFieldView.battleData, playerIndex, rewards, inTutorial);
      endOverlay.addEventListener(Event.CLOSE, endOverlay_closeHandler);
      setTimeout(hud.end, 2000, endOverlay);// delay for noobs
    }

    private function endOverlay_closeHandler(event:Event):void
    {
      var endOverlay:EndOverlay = event.currentTarget as EndOverlay;
      endOverlay.removeEventListener(Event.CLOSE, endOverlay_closeHandler);

      if( endOverlay.playerIndex == -1 )
      {
        dispatchEventWith(Event.COMPLETE);
        return;
      }

      appModel.battleFieldView.responseSender.leave();

      if( player.get_battleswins() > 5 && endOverlay.score == 3 && player.get_arena(0) > 0 ) // !sfsConnection.mySelf.isSpectator &&
        appModel.navigator.showOffer();
      dispatchEventWith(Event.COMPLETE);
    }

    private function tutorials_tasksFinishHandler(event:Event):void
    {
      tutorials.removeEventListener(GameEvent.TUTORIAL_TASKS_FINISH, tutorials_tasksFinishHandler);
      var tutorial:TutorialData = event.data as TutorialData;
      if( tutorial.data == "start" )
      {
        readyBattle();
        return;
      }

      if( tutorial.name == "tutor_battle_celebration" )
      {
        endBattle(tutorial.data as SFSObject, true);
        return;
      }

      if( player.get_battleswins() == 2 )
      {
        UserData.instance.prefs.setInt(PrefsTypes.TUTOR, PrefsTypes.T_011_SLOT_FOCUS);
        appModel.navigator.popToRootScreen();
        return;
      }
      dispatchEventWith(Event.COMPLETE);
    }

    private function resetAll(data:ISFSObject):void
    {
      if( !data.containsKey("buildings") )
        return;
      /*var bSize:int = data.getSFSArray("buildings").size();
      for( var i:int=0; i < bSize; i++ )
      {
        var b:ISFSObject = data.getSFSArray("buildings").getSFSObject(i);
        appModel.battleFieldView.places[b.getInt("i")].replaceBuilding(b.getInt("t"), b.getInt("l"), b.getInt("tt"), b.getInt("p"));
      }*/
    }

    override protected function backButtonFunction():void
    {
      if( appModel.battleFieldView.battleData.userType == 1 )
      {
        appModel.battleFieldView.responseSender.leave();
        dispatchEventWith(Event.COMPLETE);
        return;
      }

    /*	if( player.inTutorial() )
        return;

      if( battleField.startAt + battleField.field.times.get(0) > timeManager.now )
        return;
      var confirm:ConfirmPopup = new ConfirmPopup(loc("leave_battle_confirm_message"));
      confirm.acceptStyle = MainTheme.STYLE_BUTTON_SMALL_DANGER;
      confirm.addEventListener(Event.SELECT, confirm_selectsHandler);
      appModel.navigator.addPopup(confirm);
      function confirm_selectsHandler(event:Event):void
      {
        confirm.removeEventListener(Event.SELECT, confirm_selectsHandler);
        appModel.battleFieldView.responseSender.leave();
      }*/
    }
    private function get battleField() : BattleField
    {
      return appModel.battleFieldView.battleData.battleField;
    }


    override public function dispose():void
    {
      removeConnectionListeners();
      appModel.sounds.stopAll();
      setTimeout(appModel.sounds.play, 2000, "main-theme", NaN, 100, 0, SoundManager.SINGLE_BYPASS_THIS);
      removeChild(appModel.battleFieldView, true);
      super.dispose();
    }

    private function removeConnectionListeners():void
    {
      if( tutorials != null )
        tutorials.removeEventListener(GameEvent.TUTORIAL_TASKS_STARTED, tutorials_tasksStartHandler);
      SFSConnection.instance.removeEventListener(SFSEvent.CONNECTION_LOST,	sfsConnection_connectionLostHandler);
      SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_extensionResponseHandler);
    }
  }
}