local serverMessagePrefix = "SERVER DESCRIPTION \n==================\n"
local serverMessageAddition = "\n \n The command \".desc\" can be used to view the server description at any time."

Hook.Add("client.connected", "joinpopup", function (ConnectedClient)
  local text = serverMessagePrefix .. Game.ServerSettings.ServerMessageText .. serverMessageAddition
  local client = ConnectedClient

  Game.SendDirectChatMessage(nil, text, nil, ChatMessageType.ServerMessageBox, client, nil)
end)


Hook.Add("chatMessage", "showdesccommand", function (message, client)
  if message ~= ".desc" then return end

  local text = serverMessagePrefix .. Game.ServerSettings.ServerMessageText .. serverMessageAddition

  Game.SendDirectChatMessage(nil, "Opening server desciption...", nil, ChatMessageType.Error, client, nil)
  Game.SendDirectChatMessage(nil, text, nil, ChatMessageType.ServerMessageBox, client, nil)

  return true -- returning true allows us to hide the message
end)

Hook.Add("loaded", "addgmtbullshit", function ()
  if GMT ~= nil and Game.IsMultiplayer then -- gmt only works in multiplayer. this doesnt cause issues in non-multiplayer besides a harmless error, but said error is ANNOYING.
    GMT.AddChatCommand("desc","Shows the server's current description.",function (client, args)
    end)
  end
end)
