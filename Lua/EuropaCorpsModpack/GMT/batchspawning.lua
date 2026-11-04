local batchPresets = require('EuropaCorps.config_batchspawns') -- load the config file if it isn't loaded already

PublicCharacters = {} -- a list of characters spectators are allowed to control

GMT.AddCommand(
	"spawnbatch", -- identifier?
	"Spawns a specified group of characters", -- description?
	true, -- cheat?
	nil, -- function?
	{ -- arg names and descriptions?
	{name="id",desc="Identifier of the batch to spawn"},
	{name="team",desc="Team ID to spawn characters on",optional=true},
	{name="spread",desc="How far apart horizontally to spawn each character in the batch (in metres)",optional=true},
	{name="ghostcontrol",desc="Should spectators be allowed to control spawned characters? AI will be enabled if this false. WARNING: Basic husks do not work with ghost control."},optional=true},
	getValidArgs, -- valid args
	usage-- i have no idea
	)



GMT.AssignClientCommand("spawnbatch",
	function(client,cursor,args)

		local batch_ID = args[1] ~= nil and args[1] or "no_batch_entered" 
		local cursorPos = cursor
		local team_ID = args[2] ~= nil and tonumber(args[2]) or CharacterTeamType.Team2
		local ghostControl = false
		local spawnSpread = tonumber(args[3]) ~= nil and tonumber(args[3]) * 100 or 250

		if args[4] ~= nil then
			ghostControl = string.lower(args[4]) == "true" and true or false
		end

		local spawnPos = cursorPos
		local spawnOffset = Vector2(0,0)

		if batchPresets[batch_ID] then

			if #batchPresets[batch_ID] > 1 then
				spawnPos.X = cursorPos.X - (0.5 * spawnSpread) -- start at the left (unless it's negative (why would anyone do that????))
				spawnOffset = spawnSpread ~= 0 and Vector2(spawnSpread / #batchPresets[batch_ID],0) or Vector2(0,0) -- don't divide by 0 or we get infinity so default to 0 if spawnspread is 0
			end

			for batchCharacter in batchPresets[batch_ID] do

				local info = nil

				if batchCharacter[2] ~= nil then
					info = CharacterInfo(batchCharacter[1])
					print(batchCharacter[2])
					info.Job = Job(JobPrefab.Get(batchCharacter[2]), false)
				end

				local character = nil
				character = Character.Create(batchCharacter[1], spawnPos, 0, info, nil, ghostControl, not ghostControl) -- there is ZERO!!! error handling so everything explodes if the speciesname is bad
				character.TeamID = team_ID

				if info ~= nil then
					character.GiveJobItems(false) 
				end

				if ghostControl == true then
					MakeCharacterPublic(character)
				end
				
				--print("spawned a " .. batchCharacter[1] .. " with AI set to " .. tostring(not ghostControl))
				--print(spawnPos)
				--print(spawnOffset)

				spawnPos = Vector2.Add(spawnPos, spawnOffset) -- march onwards towards our final destination (final spawnPos)
				
			end
		else
			local chatMessage = ChatMessage.Create(nil,"Spawn batch \"" .. batch_ID .. "\" not found!", ChatMessageType.Console, nil, nil)
       		chatMessage.Color = Color(255, 0, 0, 255)
			Game.SendDirectChatMessage(chatMessage, client)
		end

	end)

GMT.AssignServerCommand("spawnbatch",function(args)
    GMT.NewConsoleMessage("GMTools: "..GMT.Lang("Error_bad_console"),Color(255,0,0,255))
end)



GMT.AddCommand(
	"listbatches", -- identifier?
	"Lists all available character batches.", -- description?
	true, -- cheat?
	nil, -- function?
	nil, -- arg names and descriptions?
	nil, -- valid args?
	usage	-- i have no idea
	)

GMT.AssignSharedCommand("listbatches",function (args, interface)


	for batch,list in pairs(batchPresets) do
		interface.showMessage(batch,Color(255,0,255,255))
		local constructedString = ""
		for batchComponent in batchPresets[batch] do
			constructedString = batchComponent[2] ~= nil and constructedString .. tostring(JobPrefab.Get(batchComponent[2]).Name) .. " (" .. batchComponent[1] .. ")" .." / " or constructedString .. batchComponent[1] .. " / "
		end
		constructedString = string.sub(constructedString,1,#constructedString-2) -- peel the slashes off the end so it's prettier
		interface.showMessage(constructedString,Color(155,155,155,255))
	end
end)