local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = 1
return {
	nok = true,
	KenDodge = function(character, player)
		if character:IsA("Player") then
			character = character.Character
		end

		character.Services.KenHaki.Value = character.Services.KenHaki.Value - 1
		local playerFromCharacter = game.Players:GetPlayerFromCharacter(character)

		if playerFromCharacter then
			local maxDodge = _G.GetMaxDodge(playerFromCharacter)
			_G.DodgeLeftShow(character, "Dodge", {
				DodgeCount = character.Services.KenHaki.Value,
				MaxCount = maxDodge
			})

			if playerFromCharacter and player and player:IsA("Player") then
				if _G.CheckSetting(playerFromCharacter, "Setting_DodgeText") then
					ReplicatedStorage.Chest.Remotes.Events.TextAlert:FireClient(
						playerFromCharacter,
						"Target Dodge Left To Target",
						{
							DodgeCount = character.Services.KenHaki.Value,
							Enemy = player,
							MaxCount = maxDodge
						}
					)
				end

				if _G.CheckSetting(player, "Setting_DodgeText") then
					ReplicatedStorage.Chest.Remotes.Events.TextAlert:FireClient(player, "Target Dodge Left To Player", {
						DodgeCount = character.Services.KenHaki.Value,
						Enemy = playerFromCharacter,
						MaxCount = maxDodge
					})
				end
			elseif playerFromCharacter and not player and _G.CheckSetting(playerFromCharacter, "Setting_DodgeText") then
				ReplicatedStorage.Chest.Remotes.Events.TextAlert:FireClient(playerFromCharacter, "Target Dodge Enemy", {
					DodgeCount = character.Services.KenHaki.Value,
					MaxCount = maxDodge
				})
			end
		elseif character.Services.KenHaki:GetAttribute("MaxDodge") then
			local maxDodge = character.Services.KenHaki:GetAttribute("MaxDodge")
			_G.DodgeLeftShow(character, "Dodge", {
				DodgeCount = character.Services.KenHaki.Value,
				MaxCount = maxDodge
			})

			if _G.CheckSetting(player, "Setting_DodgeText") then
				ReplicatedStorage.Chest.Remotes.Events.TextAlert:FireClient(player, "Target Dodge Left To Player", {
					DodgeCount = character.Services.KenHaki.Value,
					Enemy = character,
					MaxCount = maxDodge
				})
			end
		end

		_G.StopAnimationServer(character.Humanoid, {
			Dodge1 = true,
			Dodge2 = true,
			Dodge3 = true,
			Dodge4 = true,
			Dodge5 = true
		})
		_G.PU.PlayOneShotAnim({
			Animator = character.Humanoid,
			Animation = ReplicatedStorage.Chest.Animation.DodgeAnimation["Dodge" .. v],
			Speed = 1.5
		})
		v += 1

		if v > 5 then
			v = 1
		end
	end
}