
PublicCharacters = {} -- a list of characters spectators are allowed to control

NextPublicCharacterAlert = 0
PublicCharacterAlertCooldown = 10

function MakeCharacterPublic(character)
	table.insert(PublicCharacters,character) -- it's as shrimple as that (the rest of the code in this function is just niceness for spectators and admins)

    --Game.Log(tostring(character.DisplayName) .. " Has been made public and can now be controlled by any spectator.", ServerLogMessageType.Spawning)
    if Timer.GetTime() < NextPublicCharacterAlert or Game.RoundStarted ~= true then return end --dont really need to do anything if we're still on cooldown

	local chatMsg = ChatMessage.Create("GM-Tools",GMT.FormattedText("There are characters available for control; use the '.control' chat-command to control a random available character.",{{name="color",value="#a67dcf"}}), ChatMessageType.Dead, nil, nil)

	for client in Client.ClientList do

		if client.Character then
			if client.Character.IsDead == true then
				Game.SendDirectChatMessage(chatMsg, client) -- yell at spectators
			end
		else
			Game.SendDirectChatMessage(chatMsg, client)
		end

	end

	NextPublicCharacterAlert = Timer.GetTime() + PublicCharacterAlertCooldown -- block all alerts for the next minute

end


------------

Hook.Add("roundStart", "resetPublicCharacters", function()
	PublicCharacters = nil
	PublicCharacters = {}
	NextPublicCharacterAlert = 0
end)

GMT.AddChatCommand("control","Control a character that admins have marked for spectators to control",
	function (client, args)
	    if GMT.Player.ProcessCooldown(client,3) or Game.RoundStarted ~= true then return end

		if client.Character then
			if client.Character.IsDead ~= true then
				local chatMsg = ChatMessage.Create("GM-Tools",GMT.FormattedText("You cannot use this command while you are alive!",{{name="color",value="#ff8589"}}), ChatMessageType.Error, nil, nil)
				Game.SendDirectChatMessage(chatMsg, client)

				return
			end
		end

		local characterToControl = nil
		
		while characterToControl == nil and #PublicCharacters > 0 do
			if PublicCharacters[1].IsDead ~= true and Util.FindClientCharacter(PublicCharacters[1]) == nil then -- start from 1 so that the oldest public character is picked first
				characterToControl = PublicCharacters[1]
				table.remove(PublicCharacters,1) -- if the character is alive, mark them for control and remove the value so we don't clash
			else
				table.remove(PublicCharacters,1) -- if the character has died since being made public, clean out the value but don't mark them for control
			end
		end

		if characterToControl ~= nil then
			client.SpectateOnly = false -- if you dont set this to false they'll be treated like a disconnected player, stunning and eventually killing them
			client.SetClientCharacter(characterToControl)
			local chatMsg = ChatMessage.Create("GM-Tools", "Successfully controlled " .. characterToControl.DisplayName .. "!", ChatMessageType.Server, nil, nil)
			Game.SendDirectChatMessage(chatMsg, client)
		else
			local chatMsg = ChatMessage.Create("GM-Tools",GMT.FormattedText("There are no living characters you are permitted to control!",{{name="color",value="#ff8589"}}), ChatMessageType.Error, nil, nil)
			Game.SendDirectChatMessage(chatMsg, client)
		end

	end)

GMT.AddCommand(
	"publicisechars", -- identifier?
	"Marks characters near the cursor for spectators to freely control.", -- description?
	true, -- cheat?
	nil, -- function?
	{ -- arg names and descriptions?
	{name="range",desc="Range (decimetres)"},optional=true},
	nil, -- valid args?
	usage	-- i have no idea
	)

GMT.AssignClientCommand("publicisechars",
	function(client,cursor,args)
		local position = cursor
		
		local range = tonumber(args[1]) ~= nil and tonumber(args[1]) * 10 or 250  -- default 250

		local publicisedCount = 0

		for key, value in pairs(Character.CharacterList) do
			local distance = Vector2.Distance(position, value.WorldPosition)
			if distance < range then
				MakeCharacterPublic(value)
				publicisedCount = publicisedCount + 1
			end	
		end
		
		if publicisedCount > 0 then
			local chatMsg = ChatMessage.Create("GM-Tools", "Made " .. publicisedCount .. " characters public", ChatMessageType.Console, nil, nil)
			Game.SendDirectChatMessage(chatMsg, client)
		end
	end)

GMT.AssignServerCommand("publicisechars",function(args)
    GMT.NewConsoleMessage("GMTools: "..GMT.Lang("Error_bad_console"),Color(255,0,0,255))
end)