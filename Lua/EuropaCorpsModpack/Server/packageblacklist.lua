Hook.Add("client.packages", "client.checkblacklistedpackages", function (client, packages)
  local forbiddenmods = {
    2817020588
  }

  local packagelistlog = "Client " .. tostring(client.Name) .. "joined with the following packages: "

  for packagechecked in packages do

    for i=1, #forbiddenmods do

      if tostring(forbiddenmods[i]) == tostring(packagechecked.Id) then
        Game.Log(client.Name .. " has been kicked due to having the following blacklisted package enabled: " .. packagechecked.Name, ServerLogMessageType.ConsoleUsage)
        client.Kick("Blacklisted package enabled: " .. packagechecked.Name)
      end

    end

	if packagechecked.Id ~= nil then
		packagelistlog = packagelistlog .. packagechecked.Name .. "(" .. packagechecked.Id .. "), "
	else
		packagelistlog = packagelistlog .. packagechecked.Name .. ", "
	end

  end

  Game.Log(packagelistlog, ServerLogMessageType.ConsoleUsage)

end)