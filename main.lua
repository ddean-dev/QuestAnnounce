QuestAnnounce = CreateFrame("Frame")

local PREFIX = "QuestAnnounce"
local QUEST_ACCEPTED = "QUEST_ACCEPTED"
local QUEST_TURNED_IN = "QUEST_TURNED_IN"
local QUEST_REMOVED = "QUEST_REMOVED"
local CHAT_MSG_ADDON = "CHAT_MSG_ADDON"
local QUEST_DATA_LOAD_RESULT = "QUEST_DATA_LOAD_RESULT"

function QuestAnnounce:OnEvent(event, arg1, arg2, arg3, arg4)
	if event == CHAT_MSG_ADDON then
		QuestAnnounce:OnCommReceived(arg1, arg2, arg3, arg4)
	elseif event == QUEST_ACCEPTED or event == QUEST_TURNED_IN or event == QUEST_REMOVED then
		QuestAnnounce:OnQuest(event, arg1)
	end
end

function QuestAnnounce:OnQuest(event, questID)
	-- Ignore world quests
	if C_QuestLog.IsWorldQuest(questID) then
		return
	end

	-- Get waypoint
	local waypoint, mapID, position
	if event ~= QUEST_REMOVED then
		mapID = C_Map.GetBestMapForUnit("player")
		if mapID and C_Map.CanSetUserWaypointOnMap(mapID) then
			position = C_Map.GetPlayerMapPosition(mapID, "player")
		end
		if mapID and position then
			waypoint = QuestAnnounce:WaypointLink(mapID, position.x, position.y)
		end
	end

	-- Get quest
	local quest = GetQuestLink(questID)
	if not quest then
		local info = C_QuestLog.GetInfo(questID)
		if info then
			quest = QuestAnnounce:QuestLink(questID, info.title, info.level)
		end
	end
	if not quest then
		QuestEventListener:AddCallback(questID, function()
			local title = C_QuestLog.GetTitleForQuestID(questID)
			quest = QuestAnnounce:QuestLink(questID, title)
			QuestAnnounce:SendMessage(quest, event, waypoint)
		end)
		C_QuestLog.RequestLoadQuestByID(questID)
		return
	end
	QuestAnnounce:SendMessage(quest, event, waypoint)
end

function QuestAnnounce:QuestLink(questId, questName, questLevel)
	return string.format("|cffffff00|Hquest:%s:%s|h[%s]|h|r", questId, questLevel or 80, questName)
end

function QuestAnnounce:WaypointLink(mapID, x, y)
	if not mapID or not C_Map.CanSetUserWaypointOnMap(mapID) then
		return nil
	end
	return string.format(
		"|cffffff00|Hworldmap:%d:%d:%d|h[|A:Waypoint-MapPin-ChatIcon:13:13:0:0|aMap Pin]|h|r",
		mapID,
		x * 10000,
		y * 10000
	)
end

function QuestAnnounce:SendMessage(quest, event, waypoint)
	local text = ""

	if event == QUEST_ACCEPTED then
		text = " accepted: "
	elseif event == QUEST_TURNED_IN then
		text = " turned in: "
	elseif event == QUEST_REMOVED then
		text = " abandoned: "
	end

	if quest then
		text = text .. quest
	else
		text = text .. "[Unknown Quest]"
	end
	if waypoint then
		text = text .. " at " .. waypoint
	end
	-- Send Message
	print("You" .. text)
	ChatThrottleLib:SendAddonMessage("NORMAL", PREFIX, text, "PARTY")
end

function QuestAnnounce:OnCommReceived(prefix, text, channel, sender)
	if prefix == PREFIX and channel == "PARTY" then
		if not sender then
			sender = "You"
		end
		local name = string.split("-", sender, 2)
		print(name[1] .. text)
		return
	end
end

QuestAnnounce:RegisterEvent(QUEST_ACCEPTED)
QuestAnnounce:RegisterEvent(QUEST_TURNED_IN)
QuestAnnounce:RegisterEvent(QUEST_REMOVED)
QuestAnnounce:RegisterEvent(CHAT_MSG_ADDON)
QuestAnnounce:RegisterEvent(QUEST_DATA_LOAD_RESULT)
C_ChatInfo.RegisterAddonMessagePrefix(PREFIX)
QuestAnnounce:SetScript("OnEvent", QuestAnnounce.OnEvent)
