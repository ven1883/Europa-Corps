
if CLIENT then return end

local spectatorflavortext_pt1 = "A pager message sent by "
local spectatorflavortext_pt2 = " echoes through the void... "

local livingflavortext_pt1 = "Your pager buzzes as "
local livingflavortext_pt2 = "'s orders are recieved: "

local pageridentifier = "pager"

Hook.Add("chatMessage", "pagermsg", function (message, sender)
  local pagerrecipientcount = 0
  if Game.RoundStarted == false or sender.Character == nil or string.sub(message,0,1) == "." then return end
  if sender.Character.Inventory.GetItemInLimbSlot(InvSlotType.LeftHand) ~= nil then
    if tostring(sender.Character.Inventory.GetItemInLimbSlot(InvSlotType.LeftHand).Prefab.Identifier) == pageridentifier then

      local spectatorflavortext = spectatorflavortext_pt1 .. tostring(sender.Character.Name) .. spectatorflavortext_pt2
      local livingflavortext = livingflavortext_pt1 .. tostring(sender.Character.Name) .. livingflavortext_pt2

      for i,client in pairs(Client.ClientList) do
        if client.TeamID ~= nil and client.character ~= nil then
          if sender.Character.TeamID == client.Character.TeamID then
            Game.SendDirectChatMessage(nil, livingflavortext .. "\"" .. message .. "\"", nil, ChatMessageType.ServerMessageBoxInGame, client)
            pagerrecipientcount = pagerrecipientcount + 1
          end
        else
          Game.SendDirectChatMessage(nil, spectatorflavortext .. "\"" .. message .. "\"", nil, ChatMessageType.ServerMessageBoxInGame, client)
          pagerrecipientcount = pagerrecipientcount + 1
        end
      end
      Game.Log(sender.Name .. " sent pager message \"" .. message .. "\" to " .. pagerrecipientcount .. " recipients on team ID " .. sender.Character.TeamID, ServerLogMessageType.ItemInteraction)
    end
  end
end)