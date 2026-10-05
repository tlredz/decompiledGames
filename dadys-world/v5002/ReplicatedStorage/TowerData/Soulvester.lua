local function setFaceTexture(instance, texture)
	instance:WaitForChild("Config")
	local blinkingParts = instance:FindFirstChild("BlinkingParts")
	local v = {}

	if blinkingParts and #blinkingParts:GetChildren() > 0 then
		for _, objectValue in ipairs(blinkingParts:GetChildren()) do
			if not objectValue:IsA("ObjectValue") then
				continue
			end

			table.insert(v, objectValue.Value)

			if objectValue.Value:FindFirstChildWhichIsA("MeshPart") then
				table.insert(v, objectValue.Value:FindFirstChildWhichIsA("MeshPart"))
			end
		end
	else
		local head = instance:FindFirstChild("Head")

		if not head then
			warn("No Head found in character and no BlinkingParts folder.")
			return
		end

		table.insert(v, head)

		if head:FindFirstChild("Head") then
			table.insert(v, head.Head)
		end
	end

	for _, part in ipairs(v) do
		if part:IsA("BasePart") then
			part.TextureID = texture
		end
	end
end

local Soulvester = {}
Soulvester.Name = "Soulvester"
Soulvester.Icon = "rbxassetid://77290390868770"
Soulvester.VoteIcon = "rbxassetid://75364947263421"
Soulvester.Health = 4
Soulvester.MainCharacter = false
Soulvester.WalkSpeed = 10
Soulvester.RunSpeed = 20
Soulvester.DecodeSpeed = 1.5
Soulvester.SkillCheckChance = 25
Soulvester.SkillCheckValue = 3
Soulvester.Stealth = 10
Soulvester.Stamina = 100
Soulvester.BoundarySize = 250
Soulvester.DecodeRank = 5
Soulvester.SpeedRank = 1
Soulvester.StaminaRank = 1
Soulvester.StealthRank = 3
Soulvester.SkillCheckRank = 5
Soulvester.LightToon = true
Soulvester.IchorLeakImmune = true
Soulvester.Ability1Name = "Knightly Armor"
Soulvester.Ability1Type = "Passive"
Soulvester.Ability1Description = "This Toon has an extra heart and is immune to damage from ranged attacks."
Soulvester.Cost = 250
Soulvester.Requirement1 = { "Coin", 250 }
Soulvester.MasterySkin = "VintageSoulvester"

function Soulvester.HurtAnimation(instance)
	local config = instance:FindFirstChild("Config")
	local hurtTexture = config and config:FindFirstChild("HurtTexture")
	local normalTexture = config and config:FindFirstChild("NormalTexture")

	if hurtTexture and normalTexture then
		setFaceTexture(instance, hurtTexture.Texture)
		task.wait(2)
		setFaceTexture(instance, normalTexture.Texture)
	end
end

function Soulvester.SpecialSetup(instance)
	instance:SetAttribute("IchorPuddleImmune", true)
	instance:SetAttribute("RangedAttackImmune", true)
end

return Soulvester