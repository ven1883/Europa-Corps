if CLIENT then return end

local updateDelay = 1
local updateTimer = 0

Hook.Add("think", "muteDeadChat", function()

    if Timer.GetTime() < updateTimer then return end

	updateTimer = Timer.GetTime() + updateDelay

	for key,value in Client.ClientList do
		-- print(tostring(key) .. " " .. tostring(value))
		if key.Character == nil or key.Character.IsDead ~= false then
			key.Muted = true
		else
			key.Muted = false
		end

		if Game.RoundStarted ~= true then key.Muted = false end
    end

  end)