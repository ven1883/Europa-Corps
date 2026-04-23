local sharedFiles = {
	--'ExpOps.Shared.Helpers',
	'EuropaCorpsModpack.Shared.cloakerohgod',
	'EuropaCorpsModpack.Shared.disablecharactercollision',
	'EuropaCorpsModpack.Shared.remotedet_activate'
}

local serverFiles = {
	'EuropaCorpsModpack.Server.fuck-motds',
	'EuropaCorpsModpack.Server.ilovequickhacks',
	'EuropaCorpsModpack.Server.packageblacklist',
	'EuropaCorpsModpack.Server.pager',
	'EuropaCorpsModpack.Server.stamina',
	'EuropaCorpsModpack.Server.pain',
	'EuropaCorpsModpack.Server.stoptalkingwithoutvocalcords'
}

local clientFiles = {
	'EuropaCorpsModpack.Client.simpleformatting',
	'EuropaCorpsModpack.Client.parallax'
}

local gmtFiles = {
	'EuropaCorpsModpack.GMT.publiccontrol',
	'EuropaCorpsModpack.GMT.batchspawning',
	'EuropaCorpsModpack.GMT.respawnasjob'
}

print("==================")
print("|| Europa Corps Files ||")
print("==================")

for file in sharedFiles do
	require(file)
		print("Loaded Shared File: " .. file)
end

if SERVER then
	print("--- Serverside Files ---")
	for file in serverFiles do
		require(file)
		print("Loaded Server File: " .. file)
	end
	Hook.Add("gmtools.loaded","loadGMTaddons",function()
	print("--- GMT Extension Files ---")
	Timer.Wait(function()
		for file in gmtFiles do
			require(file)
		print("Europa Corps | Loaded GMT Extension:  " .. file)
		end
	end,1500)
end)
end

if CLIENT then
	print("--- Clientside Files ---")
	for file in clientFiles do
		require(file)
		print("Loaded Client File: " .. file)
	end
end


print("==================")
