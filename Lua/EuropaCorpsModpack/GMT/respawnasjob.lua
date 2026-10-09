function RespawnClient (client, forcedJobIdentifier)

	if (client == nil) then return end
	
	if (forcedJobIdentifier ~= nil) then
		client.CharacterInfo.Job = Job(JobPrefab.Get(forcedJobIdentifier), false)
	end

	local spawnpoints = WayPoint.SelectCrewSpawnPoints({client.CharacterInfo}, Submarine.MainSub)
	local spawnpoint = spawnpoints[1]

	client.SpectateOnly = false

	--Character.Create(characterInfo, position, seed, id, isRemotePlayer, hasAi, ragdoll, spawnInitialItems)
	local spawneeCharacter = Character.Create(client.CharacterInfo, spawnpoint.Position, 0, nil, true)

	spawneeCharacter.AnimController.CurrentHull = Hull.FindHull(spawnpoint.Position, nil, false, false) -- updates the hull they're in so they don't die of pressure
	spawneeCharacter.GiveJobItems(false)
	spawneeCharacter.GiveIdCardTags(spawnpoint, true)
	
	client.SetClientCharacter(spawneeCharacter)

end

GMT.AddCommand(
	"respawnclient", -- identifier?
	"Respawn a client as their desired (or a selected) job on the appropriate spawnpoint with the correct ID tags.", -- description?
	true, -- cheat?
	nil, -- function?
	{ -- arg names and descriptions?
	{name="client",desc="Which client should be respawned?"},
	{name="forced_job", desc="Job to force upon the respawning client?", optional=true}},
	nil, -- valid args function
	"<client> <forced_job>"	-- i have no idea
	)

GMT.AssignSharedCommand("respawnclient",
	function(args,interface)
		if (not Game.RoundStarted) then
			interface.showMessage("This command cannot be used until the round has been started!",Color(255,0,0,255))
			return
		end
		RespawnClient(GMT.GetClientByString(args[1]), args[2])
	end)