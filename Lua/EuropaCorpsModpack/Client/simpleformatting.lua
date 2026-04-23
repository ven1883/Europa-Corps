function ApplyRichFormatting (text)
	local textUnProcessed = text
	local textProcessed = ""
	local textFullyProcessed = false
	local iterations = 0
	local unclosedColorTag = false

	while (iterations < 25) do -- limited at 25 iterations as a safety measure
		iterations = iterations + 1

		local firstIndexFound, lastIndexFound, markerString = nil, nil, nil
		firstIndexFound, lastIndexFound, markerString = string.find(textUnProcessed,"%$([^%s]*)%s?")

		--print("first index found: " .. tostring(firstIndexFound))
		--print("last index found: " .. tostring(lastIndexFound))
		--print("marker string found: " .. tostring(markerString))

		if firstIndexFound == nil then
			break
		end

		textProcessed = textProcessed .. string.sub(textUnProcessed, 1, firstIndexFound - 1)
		
		if unclosedColorTag and (markerString ~= 'end') then
			textProcessed = textProcessed .. "‖color:end‖"
		end

		textProcessed = textProcessed .. "‖color:" .. markerString .."‖"
		textUnProcessed = string.sub(textUnProcessed, lastIndexFound + 1, nil)

		if markerString ~= 'end' then
			unclosedColorTag = true
		else
			unclosedColorTag = false
		end

	end

	if unclosedColorTag then
		textUnProcessed = textUnProcessed .. "‖color:end‖"
	end

	return textProcessed .. textUnProcessed
	
end

Hook.Patch("formatText",
	"Barotrauma.Networking.GameClient",
	"EnterChatMessage",
	nil,
	function(instance, ptable)
		ptable["message"] = ApplyRichFormatting(ptable["message"])
    return
end, Hook.HookMethodType.Before)

Hook.Patch("formatText",
	"Barotrauma.Networking.GameClient",
	"SendConsoleCommand",
	nil,
	function(instance, ptable)
		local modifiedCommand = ApplyRichFormatting(ptable["command"])	
		if modifiedCommand ~= ptable["command"] then
			print("The sent command has been modified by the simplified formatting system. '$' characters have been treated as color tags.")
			ptable["command"] = modifiedCommand
		end
    return
end, Hook.HookMethodType.Before)