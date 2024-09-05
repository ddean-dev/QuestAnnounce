QuestAnnounce = CreateFrame("Frame")

local QUEST_ACCEPTED = "QUEST_ACCEPTED"
local QUEST_TURNED_IN = "QUEST_TURNED_IN"

function QuestAnnounce:OnEvent(event, questID)
	local quest = GetQuestLink(questID)

	local waypoint, mapID, position
	mapID = C_Map.GetBestMapForUnit("player")
	if mapID and C_Map.CanSetUserWaypointOnMap(mapID) then
		position = C_Map.GetPlayerMapPosition(mapID, "player")
	end
	if mapID and position then
		waypoint = "\124cffffff00\124Hworldmap:"
			.. tostring(mapID)
			.. ":"
			.. tostring(position.x * 10000)
			.. ":"
			.. tostring(position.y * 10000)
			.. "\124h[\124A:Waypoint-MapPin-ChatIcon:13:13:0:0\124a Map Pin]\124h\124r"
	end

	-- Build message
	local text
	if event == QUEST_ACCEPTED then
		text = "Accepted "
	elseif event == QUEST_TURNED_IN then
		text = "Turned in "
	end
	text = text .. quest
	if waypoint then
		text = text .. " at " .. waypoint
	end

	if IsInGroup() then
		SendChatMessage(text, "PARTY")
	else
		print(text)
	end
end

QuestAnnounce:RegisterEvent(QUEST_ACCEPTED)
QuestAnnounce:RegisterEvent(QUEST_TURNED_IN)
QuestAnnounce:SetScript("OnEvent", QuestAnnounce.OnEvent)
