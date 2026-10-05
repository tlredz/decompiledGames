local Looey = {}
Looey.Name = "Looey"
Looey.Icon = "rbxassetid://79162966797011"
Looey.VoteIcon = "rbxassetid://89617984285170"
Looey.Health = 3
Looey.MainCharacter = false
Looey.WalkSpeed = 15
Looey.RunSpeed = 25
Looey.DecodeSpeed = 1
Looey.SkillCheckChance = 25
Looey.SkillCheckValue = 2.5
Looey.Stealth = 5
Looey.Stamina = 150
Looey.BoundarySize = 200
Looey.BoundarySize2 = 150
Looey.DecodeRank = 3
Looey.SpeedRank = 3
Looey.StaminaRank = 3
Looey.StealthRank = 2
Looey.SkillCheckRank = 4
Looey.Ability1Name = "Heart of Helium"
Looey.Ability1Type = "Passive"
Looey.Ability1Description = "Each time Looey loses a heart, he gains a star in speed, up to a max of 5 stars at his last heart. The lower his health, the faster he floats around, like a balloon on a breeze."
Looey.Cost = 250
Looey.Requirement1 = { "Coin", 250 }
Looey.MasterySkin = "VintageLooey"

function Looey.HurtAnimation(instance)
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

function Looey.SpecialSetup(instance)
	local Players = game:GetService("Players")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local LooeyAbility = require(ReplicatedStorage.CharacterModules.LooeyAbility)
	local editData = ReplicatedStorage:FindFirstChild("editData")
	local playerFromCharacter = Players:GetPlayerFromCharacter(instance)
	local v = LooeyAbility.Init(instance)
	instance:WaitForChild("Humanoid").HealthChanged:Connect(function(currentHealth)
		local v2 = currentHealth - v.currentHealth
		v.currentHealth = currentHealth

		if v2 < 0 then
			v = LooeyAbility.OnDamaged(instance, v, v2)
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
		end
	end)
end

return Looey