local Toodles = {
	Name = "Toodles",
	Icon = "rbxassetid://17504379605",
	VoteIcon = "rbxassetid://17504383620",
	Health = 3,
	MainCharacter = false,
	WalkSpeed = 15,
	RunSpeed = 25,
	DecodeSpeed = 0.85,
	SkillCheckChance = 25,
	SkillCheckValue = 2,
	Stealth = 15,
	Stamina = 150,
	BoundarySize = 150,
	DecodeRank = 2,
	SpeedRank = 3,
	StaminaRank = 3,
	StealthRank = 4,
	SkillCheckRank = 3,
	Ability1Name = "Beginner's Luck",
	Ability1Type = "Active",
	Ability1Description = "This Toon can roll for a 15% boost to a random Stat that lasts for 10 seconds. Has a cooldown of 25.",
	Cost = 500,
	Requirement1 = { "Coin", 500 },
	Requirement2 = { "SurviveFloor", 15 }
}
local Debris = game:GetService("Debris")
game:GetService("TweenService")
game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game.ReplicatedStorage:FindFirstChild("editData")
Toodles.ActiveAbility = true
Toodles.AbilityIcon = "rbxassetid://17701641674"
Toodles.AbilityCooldown = 25
Toodles.CustomAbilitySound = script.Sound
Toodles.AbilityDuration = 10

function Toodles.HurtAnimation(instance)
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

function Toodles.UseActiveAbility(_, instance, _)
	local ability1 = instance:WaitForChild("Abilities"):WaitForChild("Ability1")
	local cooldown = ability1:WaitForChild("Cooldown")
	local currentCooldown = ability1:WaitForChild("CurrentCooldown")
	local decoding = instance:WaitForChild("Decoding")

	if currentCooldown.Value > 0 then
		return {
			Outcome = false,
			Reason = "That Ability is on Cooldown!"
		}
	end

	if not (workspace.CurrentRoom:FindFirstChildOfClass("Model") and workspace.Info.FloorActive.Value == true) then
		return {
			Outcome = false,
			Reason = "Can't use that Ability in the Elevator!"
		}
	end

	currentCooldown.Value = cooldown.Value
	task.spawn(function()
		game.ReplicatedStorage.Events.AnimateTower:FireAllClients(instance, "Ability")
		local model = workspace.CurrentRoom:FindFirstChildOfClass("Model")
		print("[Toodles] Room found:", model ~= nil)
		local v = decoding.Value == nil and {
			"Speed",
			"Stamina",
			"Speed",
			"Stamina",
			"SkillCheck",
			"DecodeSpeed",
			"Stealth",
			"Stealth"
		} or {
			"Speed",
			"Stamina",
			"SkillCheck",
			"DecodeSpeed",
			"SkillCheck",
			"DecodeSpeed",
			"Stealth"
		}
		local v2 = v[math.random(1, #v)]
		print("[Toodles] Random stat selected:", v2)

		if model then
			local StatModifierManager = require(ReplicatedStorage.Modules.Data.StatModifierManager)
			local stats = instance:FindFirstChild("Stats")
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
			local v3

			if v2 == "Speed" then
				v3 = StatModifierManager.ApplySpeedModifiers(instance, 1.15, "ToodlesLuck", {
					category = "ability",
					antiCheat = true
				})
				task.delay(Toodles.AbilityDuration, function()
					if v3 then
						StatModifierManager.RemoveSpeedModifiers(instance, v3)
					end
				end)
			elseif v2 == "Stamina" then
				local currentStamina = stats and stats:FindFirstChild("CurrentStamina")
				v3 = StatModifierManager.ApplyModifier(instance, "StaminaModifier", 1.15, "ToodlesLuck", {
					category = "ability"
				})

				if currentStamina then
					currentStamina.Value *= 1.15
				end

				task.delay(Toodles.AbilityDuration, function()
					if v3 then
						StatModifierManager.RemoveModifier(instance, "StaminaModifier", v3)
					end

					if currentStamina then
						currentStamina.Value /= 1.15
					end
				end)
			elseif v2 == "SkillCheck" then
				local v4 = StatModifierManager.ApplyAdditiveSkillCheckChance(instance, 15, "ToodlesLuck")
				local v5 = StatModifierManager.ApplyModifier(instance, "BoundarySize", 1.15, "ToodlesLuck", {
					category = "ability"
				})
				task.delay(Toodles.AbilityDuration, function()
					if v4 then
						StatModifierManager.RemoveAdditiveSkillCheckChance(instance, v4)
					end

					if v5 then
						StatModifierManager.RemoveModifier(instance, "BoundarySize", v5)
					end
				end)
			elseif v2 == "DecodeSpeed" then
				v3 = StatModifierManager.ApplyModifier(instance, "DecodeSpeedModifier", 1.15, "ToodlesLuck", {
					category = "ability"
				})
				task.delay(Toodles.AbilityDuration, function()
					if v3 then
						StatModifierManager.RemoveModifier(instance, "DecodeSpeedModifier", v3)
					end
				end)
			elseif v2 == "Stealth" then
				v3 = StatModifierManager.ApplyModifier(instance, "StealthModifier", 1.15, "ToodlesLuck", {
					category = "ability"
				})
				task.delay(Toodles.AbilityDuration, function()
					if v3 then
						StatModifierManager.RemoveModifier(instance, "StealthModifier", v3)
					end
				end)
			end

			if humanoidRootPart then
				local attachment = Instance.new("Attachment")
				attachment.Name = "BuffParticle"
				attachment.Parent = humanoidRootPart
				local clone = ReplicatedStorage.Parts.BuffParticles[v2].BuffParticle:Clone()
				clone.Parent = attachment
				clone.Enabled = true
				local clone2 = ReplicatedStorage.Parts.BuffParticles[v2].Glow:Clone()
				clone2.Parent = attachment
				clone2.Enabled = true
				Debris:AddItem(clone, Toodles.AbilityDuration + 1)
				Debris:AddItem(clone2, Toodles.AbilityDuration + 1)
				Debris:AddItem(attachment, Toodles.AbilityDuration + 1)
				task.delay(Toodles.AbilityDuration, function()
					if instance and instance.Parent ~= nil and attachment then
						clone.Enabled = false
						clone2.Enabled = false
					end
				end)
			end
		end
	end)
	task.spawn(function()
		local lastTime = os.clock()

		while instance do
			currentCooldown.Value -= 0.1

			if currentCooldown.Value <= 0 then
				currentCooldown.Value = 0
				break
			else
				local v2 = 0.1 - (os.clock() - lastTime) % 0.1
				task.wait(v2)
			end
		end
	end)
	return {
		Outcome = true,
		Reason = "Can't use that item at full Stamina!"
	}
end

return Toodles