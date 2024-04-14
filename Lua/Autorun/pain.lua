Hook.Add("character.applyDamage", "Human.ApplyAttackPain", function (characterHealth, attackResult, hitLimb)

  local character = characterHealth.Character

  if character.SpeciesName ~= "human" then return end
  
  local limb = character.AnimController.GetLimb(LimbType.Torso)
  local painPrefab = AfflictionPrefab.Prefabs["internaldamage"]
  local totalattackpain = 0
  local globalpainmult = 1 -- Every pain type multiplied by this. Makes it so we can kee
  local painmult = {
    gunshotwound = 1.0 ,
    burn = 1.0 ,
    acidburn = 1.0 ,
    bitewounds = 1.0 ,
    lacerations = 0.75 ,
    organdamage = 0.05 , -- this is extremely low because it has an exponent. DoT will be virtually painless, but if it's inflicted instantly you're gonna have a really bad day.
    blunttrauma = 1.5 , -- sources of this damage are almost always less-lethal
    explosiondamage = 0.75 -- dealt in big bursts anyway
  }

  local painexponent = {
    organdamage = 2
  }

  for affliction in attackResult.Afflictions do
    if painmult[tostring(affliction.identifier)] ~= nil then
      totalattackpain = totalattackpain + (affliction.Strength * painmult[tostring(affliction.identifier)] * globalpainmult)

      if painexponent[tostring(affliction.identifier)] ~= nil then
        totalattackpain = totalattackpain ^ painexponent[tostring(affliction.identifier)]
      end
    end
  end

  characterHealth.ApplyAffliction(limb, painPrefab.Instantiate(totalattackpain))
  
end)