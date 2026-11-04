local parallax_originalpos = {}
local parallax_bg_items = {}

Hook.Add("roundStart", "CreateParallaxData", function() -- not the BEST way of doing this, only works at roundstart etc, but it works so whatever 
  for key, localItem in ipairs(Item.ItemList) do
    
    if localItem.HasTag("parallax") then -- this is not a lightly given tag - parallaxes are performance heavy and should be used scarcely.
      if parallax_bg_items[localItem] == nil then
        table.insert(parallax_bg_items, localItem) 
        if parallax_originalpos[tostring(localItem.ID)] == nil then
          parallax_originalpos[tostring(localItem.ID)] = localItem.Position / 100
        end
      end
    end
  end
end)

Hook.Add("think", "UpdateParallax", function()
  if Game.RoundStarted ~= true then return end
  for key, localItem in ipairs(parallax_bg_items) do
  
    if Character.Controlled ~= nil then
      
      local controlledcharpos = Vector2.Divide(Character.Controlled.Position, 100) -- only coder jesus knows why this needs to be divided by 100
      local parallax_targetpos = Vector2.Lerp(controlledcharpos, parallax_originalpos[tostring(localItem.ID)], 0.8)
    
      localItem.SetTransform(parallax_targetpos, localItem.Rotation)
    else
      localItem.SetTransform(parallax_originalpos[tostring(localItem.ID)] / 100, localItem.Rotation)
      localItem.UpdateTransform()
    end
  end
end)

Hook.Add("roundEnd", "resetParallaxData", function()
  parallax_originalpos = nil
  parallax_originalpos = {}
  parallax_bg_items = nil
  parallax_bg_items = {}
end)

--[[ --I don't know how to make this work so let's just hope nobody removes parallax items
Hook.Add("item.removed", "wipeParallaxEntry", function(item)
  if parallax_originalpos[tostring(item.ID)] ~= nil then
    parallax_originalpos[tostring(item.ID)] = nil
  end 
  if parallax_bg_items[item] ~= nil then
    table.remove(parallax_bg_items, item) = nil
  end 
end)
]]