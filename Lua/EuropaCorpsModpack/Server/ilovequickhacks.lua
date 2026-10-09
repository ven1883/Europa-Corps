if not SERVER then return end

Hook.Patch("Barotrauma.Networking.GameServer", "AssignBotJobs", function(instance, ptable) 
  ptable.PreventExecution = true
end, Hook.HookMethodType.Before)