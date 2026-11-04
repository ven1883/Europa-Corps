Hook.Add("remotetrigger.onUse", "remotetrigger.onUse", function(effect, deltaTime, item, targets, worldPosition)

  local trigger_user_name = tostring(item.ParentInventory.Owner.name)
  
  local trigger_component = item.GetComponentString("WifiComponent")
  local trigger_channel = trigger_component.Channel
  local trigger_count = 0
  --print("trigger channel : ",trigger_channel)


	for i,target in pairs(Item.ItemList) do

		if target.prefab.identifier == "remotedetonator" then
    		local target_component = target.GetComponentString("WifiComponent")
			local target_channel = target_component.Channel
		
			if target_channel == trigger_channel then
				target.Use(1,nil,nil,nil,nil)
			
    	    	if target.OwnInventory.IsFull(False) == true then
    	    		trigger_count = trigger_count + 1
    	    	end
    		end
		end
	end
	if (not CLIENT) then
		Game.Log(trigger_user_name .. " used a " .. item.name .. ", activating " .. trigger_count .. " remote detonators", ServerLogMessageType.Attack)
	end
end)	