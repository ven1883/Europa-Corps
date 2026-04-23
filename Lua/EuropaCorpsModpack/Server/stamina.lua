local function LoseStamina(character)

    if not character.IsHuman then return end

    local characterhealth = character.CharacterHealth

    -- don't deplete stamina if the player can't run
    if not character.AllowInput or not character.CanRun then return end

    -- sometimes i am stupid
    if
        not character.IsKeyDown(InputType.Run)
        or (character.IsKeyDown(InputType.Run)
        and not (
            character.IsKeyDown(InputType.Right)
            or character.IsKeyDown(InputType.Left)
            or character.IsKeyDown(InputType.Up)
            or character.IsKeyDown(InputType.Down)
            )
        )
    then
        return
    end

    local stamina = characterhealth.GetAffliction('stamina')
    if stamina.Strength > 20 then
        stamina.Strength = stamina.Strength - 20
    end

    Networking.CreateEntityEvent(character, Character.CharacterStatusEventData.__new(true))
end

local countdown = 60

if SERVER then
    Hook.Add("think", "EC.ServerStaminaUpdate", function()
        if Game.RoundStarted then
                if countdown > 0 then
                    countdown = countdown - 1
                    return
                end
                countdown = 60

            for client in Client.ClientList do
                LoseStamina(client.Character)
            end
        end
    end)
end

if CLIENT then
    Hook.Add("think", "EC.SingleplayerStaminaUpdate", function()
        if Game.RoundStarted and not Game.Paused then
                if countdown > 0 then
                    countdown = countdown - 1
                    return
                end
                countdown = 60

            LoseStamina(Character.Controlled)
        end
    end)
end