Hook.Add("disableCharacterCollision", function(effect, deltaTime, item, targets, worldPosition, element)

	if item.body then
		local collision = bit32.bor(Physics.CollisionWall, Physics.CollisionLevel)
		
		collision = bit32.bor(collision, Physics.CollisionItem)
		collision = bit32.bor(collision, Physics.CollisionProjectile)
		collision = bit32.bor(collision, Physics.CollisionItemBlocking)
		collision = bit32.bor(collision, Physics.CollisionRepairableWall)
	
		item.body.CollidesWith = collision
	end
	
end)

	--"liberated" from item collision, by evil factory. do I know how this works? absolutely not. does it work? yes.
	--https://steamcommunity.com/sharedfiles/filedetails/?id=2929076321
