package com.gerantech.towercraft.managers.net.sfs
{
public class SFSCommands
{
public static const BATTLE_START:String = "battleStart";
public static const BATTLE_CANCEL:String = "battleCancel";
public static const BATTLE_LEAVE:String = "battleLeave";
public static const BATTLE_END:String = "battleEnd";
public static const BATTLE_SEND_STICKER:String = "ss";
public static const BATTLE_NEW_ROUND:String = "battleNewRound";
public static const BATTLE_SUMMON_UNIT:String = "s";
public static const BATTLE_HIT:String = "h";

public static const RANK:String = "rank";
public static const PROFILE:String = "profile";

public static const CARD_UPGRADE:String = "cardUpgrade";
public static const CARD_NEW:String = "cardNew";
public static const EXCHANGE:String = "exchange";
public static const SELECT_NAME:String = "selectName";
public static const VERIFY_PURCHASE:String = "verify";
public static const OAUTH:String = "oauth";
public static const REGISTER_PUSH:String = "registerPush";
public static const RESTORE:String = "restore";
public static const CHANGE_DECK:String = "changeDeck";
public static const PREFS:String = "prefs";

public static const ISSUE_REPORT:String = "issueReport";
public static const ISSUE_GET:String = "issueGet";
public static const ISSUE_TRACK:String = "issueTrack";
public static const BAN:String = "ban";
public static const BANNED_DATA_GET:String = "bannedDataGet";
public static const OFFENDER_DATA_GET:String = "offenderDataGet";
public static const INFRACTIONS_GET:String = "infractionsGet";
public static const INFRACTIONS_DELETE:String = "infractionsDelete";
public static const SEARCH_IN_CHATS:String = "searchInChats";

public static const LOBBY_CREATE:String = "lobbyCreate";
public static const LOBBY_DATA:String = "lobbyData";
public static const LOBBY_INFO:String = "lobbyInfo";
public static const LOBBY_JOIN:String = "lobbyJoin";
public static const LOBBY_LEAVE:String = "lobbyLeave";
public static const LOBBY_MODERATION:String = "lobbyModeration";
public static const LOBBY_EDIT:String = "lobbyEdit";
public static const LOBBY_REPORT:String = "lobbyReport";
public static const LOBBY_PUBLIC:String = "lobbyPublic";
public static const LOBBY_PUBLIC_MESSAGE:String = "m";
public static const LOBBY_REMOVE:String = "lobbyRemove";

public static const BUDDY_ADD:String = "buddyAdd";
public static const BUDDY_REMOVE:String = "buddyRemove";
public static const BUDDY_BATTLE:String = "buddyBattle";

public static const INBOX_GET_THREADS:String = "inboxGetThreads";
public static const INBOX_GET_RELATIONS:String = "inboxGetRelations";
public static const INBOX_OPEN:String = "inboxOpen";
public static const INBOX_CONFIRM:String = "inboxConfirm";
public static const INBOX_BROADCAST:String = "inboxBroadcast";

public static const CHALLENGE_JOIN:String = "challengeJoin";
public static const CHALLENGE_UPDATE:String = "challengeUpdate";
public static const CHALLENGE_GET_ALL:String = "challengeGetAll";
public static const CHALLENGE_COLLECT:String = "challengeCollect";

public static const QUEST_INIT:String = "questInit";
public static const QUEST_REWARD_COLLECT:String = "questRewardCollect";


public static function getDeadline(command:String):int
{
	switch( command )
	{
		case BATTLE_START:
            return 14000;
		case BATTLE_CANCEL:
		case BATTLE_LEAVE:
		case BATTLE_SUMMON_UNIT:
		case BATTLE_SEND_STICKER:
		case INBOX_OPEN:
		case INBOX_CONFIRM:
		case INBOX_BROADCAST:
		case ISSUE_GET:
		case ISSUE_REPORT:
		case ISSUE_TRACK:
		case LOBBY_LEAVE:
		case LOBBY_EDIT:
		case REGISTER_PUSH:
		case VERIFY_PURCHASE:
		case BUDDY_BATTLE:
		case CARD_NEW:
			return -1;
	}
	return 3000;
}

public static function getCanceled(command:String):String
{
	switch( command )
	{
		case BATTLE_CANCEL: return BATTLE_START;
	}
	return null;
}
}
}