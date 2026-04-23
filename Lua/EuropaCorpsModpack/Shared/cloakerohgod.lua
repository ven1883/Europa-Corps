ActiveStealthItemList = {}         -- keyless list of activated stealth items
StealthItemSubLists = {}           -- table of stealth items, using the ID of stealth items as key and the value is a keyless list of items it controls invis for
StealthItemSublistLookupTable = {} -- key: affected item id, value: controller id. mostly exists to make checks faster

local allNonAnySlots = { -- this is kind of icky but it works reliably
	InvSlotType.Bag,
	InvSlotType.Card,
	InvSlotType.Head,
	InvSlotType.Headset,
	InvSlotType.HealthInterface,
	InvSlotType.InnerClothes,
	InvSlotType.LeftHand,
	InvSlotType.OuterClothes,
	InvSlotType.RightHand }

local lualessOpacity = 10

local function isInHandSlot(item)
	local parentInventory = item.parentInventory

	if (not parentInventory) or (not LuaUserData.IsTargetType(item.ParentInventory, "Barotrauma.CharacterInventory")) then return end

	return parentInventory.IsInLimbSlot(item, InvSlotType.LeftHand) or parentInventory.IsInLimbSlot(item, InvSlotType.RightHand)
end

local function networkSpriteAlpha (item, alpha)
	
	if (SERVER) then
		Timer.NextFrame(function ()
			item.SpriteColor = Color(item.SpriteColor.R, item.SpriteColor.G, item.SpriteColor.B, alpha)
 			Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(item.SerializableProperties[Identifier("SpriteColor")], item))
		end)
	end
end

local function addItemToStealthSubList(itemToAdd, stealthItemID, nest)
	--print(" add called with args " .. tostring(item) .. ", " .. tostring(stealthItemID) .. " and " .. tostring(nest))
	StealthItemSublistLookupTable[itemToAdd.ID] = stealthItemID
	StealthItemSubLists[stealthItemID][itemToAdd.ID] = itemToAdd
	networkSpriteAlpha(itemToAdd, lualessOpacity)

	if (nest == true) and (itemToAdd.OwnInventory ~= nil) then
		for containedItem in itemToAdd.OwnInventory.AllItems do
			StealthItemSublistLookupTable[containedItem.ID] = stealthItemID
			StealthItemSubLists[stealthItemID][containedItem.ID] = containedItem
			networkSpriteAlpha(containedItem, lualessOpacity)
		end
	end
end

local function removeItemFromStealthSubList(item, nest)
	--print("remove called with args " .. tostring(item) .. " and " .. tostring(nest))
	local stealthItemID = StealthItemSublistLookupTable[item.ID]
	if (stealthItemID == nil) then return end

	StealthItemSubLists[stealthItemID][item.ID] = nil
	StealthItemSublistLookupTable[item.ID] = nil
	item.SpriteColor = Color(item.SpriteColor.R, item.SpriteColor.R, item.SpriteColor.R, 255)
	networkSpriteAlpha(item, 255)

	if (nest == true) and (item.OwnInventory ~= nil) then
		for containedItem in item.OwnInventory.AllItems do
			if StealthItemSublistLookupTable[containedItem.ID] ~= nil then
				StealthItemSubLists[stealthItemID][containedItem.ID] = nil
				StealthItemSublistLookupTable[containedItem.ID] = nil
				containedItem.SpriteColor = Color(containedItem.SpriteColor.R, containedItem.SpriteColor.R, containedItem.SpriteColor.R, 255)
				networkSpriteAlpha(containedItem, 255)
			end
		end
	end
end

--this function assumes we are contained by a character and equipped in any slot besides an 'any' slot
local function activateStealthItem(item)
	local character = item.ParentInventory.Owner

	StealthItemSubLists[item.ID] = {}
	ActiveStealthItemList[item.ID] = item
	networkSpriteAlpha(item, lualessOpacity)

	for slot in allNonAnySlots do
		local itemInSlot = character.Inventory.GetItemInLimbSlot(slot)

		if (itemInSlot ~= item) and (itemInSlot ~= nil) then
			addItemToStealthSubList(itemInSlot, item.ID, (slot == InvSlotType.LeftHand) or (slot == InvSlotType.RightHand))
		end
	end
end

local function deactivateStealthItem(item)
	ActiveStealthItemList[item.ID] = nil
	item.SpriteColor = Color(item.SpriteColor.R, item.SpriteColor.G, item.SpriteColor.B, 255)
	networkSpriteAlpha(item, 255)
	for subListItem in StealthItemSubLists[item.ID] do
		removeItemFromStealthSubList(subListItem)
	end
	StealthItemSubLists[item.ID] = nil
end

function RefreshStealthItems()
	ActiveStealthItemList = {}         -- keyless list of activated stealth items
	StealthItemSubLists = {}           -- table of stealth items, using the ID of stealth items as key and the value is a keyless list of items it controls invis for
	StealthItemSublistLookupTable = {}
	for item in Item.ItemList do
		if item.HasTag("stealthitem") and (item.ParentInventory ~= nil) and LuaUserData.IsTargetType(item.ParentInventory, "Barotrauma.CharacterInventory") and item.ParentInventory.Owner.HasEquippedItem(item) then
			activateStealthItem(item)
		end
	end
end

Hook.Add("item.created", "addStealthItemToList", function(item)
	if item.HasTag("stealthitem") then
		StealthItemSubLists[item.ID] = {}
	end
end)

Hook.Add("item.removed", "removeStealthItemFromList", function(item)
	removeItemFromStealthSubList(item)
	if item.HasTag("stealthitem") and ActiveStealthItemList[item] ~= nil then
		deactivateStealthItem(item)
	end
end)

Hook.Add("think", "updateStealthSpriteAlpha", function()
	if (ActiveStealthItemList == nil) or SERVER then return end -- there's no reason to do anything if none of these items are active

	for item in ActiveStealthItemList do
		local colorAlpha = 255
		local character = nil
		
		if item.ParentInventory then
			character = item.ParentInventory.Owner
		else
			deactivateStealthItem(item) return
		end

		if character.isDead then
			deactivateStealthItem(item)
			return
		end

		local affliction = character.CharacterHealth.GetAffliction("concealed")
		local concealedAmount = affliction and affliction.Strength or 0 -- get the amount of the affliction

		colorAlpha = 255 * (1 - concealedAmount) + 10 * concealedAmount --this is a linear interpolation equation. or at least, I think it is?
		if colorAlpha > 255 then colorAlpha = 255 end

		item.SpriteColor = Color(item.SpriteColor.R, item.SpriteColor.G, item.SpriteColor.B, colorAlpha)

		for subListItem in StealthItemSubLists[item.ID] do
			subListItem.SpriteColor = Color(subListItem.SpriteColor.R, subListItem.SpriteColor.G, subListItem.SpriteColor.B, colorAlpha)
		end
	end
end)

Hook.Add("item.drop", "makeDroppedItemsVisible", function(item, character)
	Timer.NextFrame(function ()
		if item.ParentInventory == null then
			removeItemFromStealthSubList(item, true)
			if item.HasTag("stealthitem") and ActiveStealthItemList[item.ID] then
				deactivateStealthItem(item)
			end
		end
	end)
end)

Hook.Add("InventoryPutItem", "addInsertedItemsToStealthSubList", function(Inventory, item, characterUser, index, removeItemBool)
	Timer.NextFrame(function () -- literally everything is so much easier if we do it the frame after
	
		if item.HasTag("stealthitem") then

			local isEquipped = LuaUserData.IsTargetType(item.ParentInventory, "Barotrauma.CharacterInventory") and item.ParentInventory.Owner.HasEquippedItem(item)

			if (not ActiveStealthItemList[item.ID]) and isEquipped then
				activateStealthItem(item)
			elseif ActiveStealthItemList[item.ID] and (not isEquipped) then
				deactivateStealthItem(item)
			end

			return
		end
	
		if (item.ParentInventory == nil) then
			--print("1")
			removeItemFromStealthSubList(item, true)
			return
		end
			
		if StealthItemSublistLookupTable[item.ParentInventory.Owner.ID] and (not StealthItemSublistLookupTable[item.ID]) then
			-- this could be condensed into one if statement but it would be extremely long and annoying
			if isInHandSlot(item.ParentInventory.Owner) then
				--print("2")
				addItemToStealthSubList(item, StealthItemSublistLookupTable[item.ParentInventory.Owner.ID], false)
				return
			end
		end

		if LuaUserData.IsTargetType(item.ParentInventory, "Barotrauma.CharacterInventory") and item.ParentInventory.Owner.HasEquippedItem(item) then
			local equippedStealthItem = item.ParentInventory.FindEquippedItemByTag("stealthitem")
			if equippedStealthItem then
				--print("3 " .. tostring(equippedStealthItem))
				addItemToStealthSubList(item, equippedStealthItem.ID, isInHandSlot(item))
				return
			end
		end

		--print("4")
		removeItemFromStealthSubList(item, true)

	end)
end)

Hook.Add("item.Use", "makeShootersVisible", function(item, itemUser, targetLimb)
	if (item.GetComponentString("RangedWeapon") ~= nil or item.GetComponentString("MeleeWeapon") ~= nil) and (item.Equipper ~= nil) and (item.Equipper.CharacterHealth.GetAffliction("concealed") ~= nil) then
		local affliction = item.Equipper.CharacterHealth.GetAffliction("concealed")
		if affliction.Strength ~= nil then
			affliction.Strength = 0
		end
	end
end)

Hook.Add("roundEnd", "wipeStealthData", function()
	ActiveStealthItemList = {}         
	StealthItemSubLists = {}
	StealthItemSublistLookupTable = {} 
end)

RefreshStealthItems()
