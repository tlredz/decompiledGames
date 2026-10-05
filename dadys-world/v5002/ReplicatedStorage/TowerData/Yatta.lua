local Yatta = {}
Yatta.Name = "Yatta"
Yatta.Icon = "rbxassetid://138352430225674"
Yatta.VoteIcon = "rbxassetid://85228004131837"
Yatta.Health = 3
Yatta.MainCharacter = false
Yatta.WalkSpeed = 17.5
Yatta.RunSpeed = 27.5
Yatta.DecodeSpeed = 1.5
Yatta.SkillCheckChance = 25
Yatta.SkillCheckValue = 2
Yatta.Stealth = 5
Yatta.Stamina = 100
Yatta.BoundarySize = 150
Yatta.DecodeRank = 5
Yatta.SpeedRank = 4
Yatta.StaminaRank = 1
Yatta.StealthRank = 2
Yatta.SkillCheckRank = 3
Yatta.Ability1Name = "Piñata Party"
Yatta.Ability1Type = "Passive"
Yatta.Ability1Description = "This Toon drops 2 random candy items after completing a machine, and 4 random candy items when injured."
Yatta.Cost = 2000
Yatta.Requirement1 = { "Coin", 2000 }
Yatta.Requirement2 = { "ToonsOwned", 15 }
Yatta.Requirement3 = { "Research", 50, "YattaMonster" }
Yatta.MasterySkin = "VintageYatta"

function Yatta.HurtAnimation(instance)
	local config = instance:WaitForChild("Config")
	instance.Head.TextureID = config.HurtTexture.Texture

	if instance.Head:FindFirstChild("Head") then
		instance.Head.Head.TextureID = config.HurtTexture.Texture
	end

	task.wait(2)

	if instance.Parent ~= nil then
		instance.Head.TextureID = config.NormalTexture.Texture

		if instance.Head:FindFirstChild("Head") then
			instance.Head.Head.TextureID = config.NormalTexture.Texture
		end
	end
end

function Yatta.SpecialSetup(instance)
	local Players = game:GetService("Players")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local YattaAbility = require(ReplicatedStorage.CharacterModules.YattaAbility)
	local editData = ReplicatedStorage:FindFirstChild("editData")
	local playerFromCharacter = Players:GetPlayerFromCharacter(instance)
	local v = YattaAbility.Init(instance)
	instance:WaitForChild("Humanoid").HealthChanged:Connect(function(currentHealth)
		local v2 = currentHealth - v.currentHealth
		v.currentHealth = currentHealth

		if v2 < 0 then
			v = YattaAbility.OnDamaged(instance, v, v2)

			if instance:FindFirstChild("Audio") then
				instance.Audio:WaitForChild("Pop").Value:Play()
			end

			task.spawn(function()
				local success, result = pcall(function()
					if editData then
						editData:Invoke(playerFromCharacter, function(p)
							if p then
								local v3 = false

								for _, v5 in pairs(p.Data.Mastery) do
									if v5.Name ~= instance.Config.ModuleName.Value then
										continue
									end

									v3 = v5
									break
								end

								if v3 then
									for _, v5 in pairs(v3.RequirementList) do
										if v5.Name == "PassiveAbilityActivate" then
											v5.Current = math.min(v5.Current + 1, v5.Amount)
										end
									end
								end
							end
						end)
					end
				end)

				if not success then
					warn("[Mastery] Error updating data:", result)
				end
			end)
		elseif v2 > 0 and instance:FindFirstChild("Audio") then
			instance.Audio:WaitForChild("Grow").Value:Play()
		end
	end)
end

function Yatta.GeneratorAbility(character)
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Players = game:GetService("Players")
	local YattaAbility = require(ReplicatedStorage.CharacterModules.YattaAbility)
	Players:GetPlayerFromCharacter(character)
	YattaAbility.OnGeneratorComplete(character)
	return true
end

return Yatta