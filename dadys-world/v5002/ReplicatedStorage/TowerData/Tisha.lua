local Tisha = {
	Name = "Tisha",
	Icon = "rbxassetid://18151696449",
	VoteIcon = "rbxassetid://18151696174",
	Health = 3,
	WalkSpeed = 17.5,
	RunSpeed = 27.5,
	DecodeSpeed = 0.85,
	SkillCheckChance = 25,
	SkillCheckValue = 2.5,
	Stealth = 10,
	Stamina = 125,
	BoundarySize = 200,
	DecodeRank = 2,
	SpeedRank = 4,
	StaminaRank = 2,
	StealthRank = 3,
	SkillCheckRank = 4,
	Ability1Name = "Tidy Up!",
	Ability1Type = "Active",
	Ability1Description = "This Toon can create a pulse that increases the movement speed of Toons around her by 25% for 5 seconds. Has a cooldown of 50."
}
local Debris = game:GetService("Debris")
game:GetService("TweenService")
game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game.ReplicatedStorage:FindFirstChild("editData")

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

function Tisha.HurtAnimation(instance)
	local config = instance:WaitForChild("Config")
	setFaceTexture(instance, config.HurtTexture.Texture)
	task.wait(2)

	if instance.Parent ~= nil then
		setFaceTexture(instance, config.NormalTexture.Texture)
	end
end

Tisha.ActiveAbility = true
Tisha.AbilityIcon = "rbxassetid://18154848607"
Tisha.AbilityCooldown = 50
Tisha.AbilityDuration = 5
Tisha.AbilityRange = 30
Tisha.CustomAbilitySound = script.Sound

function Tisha.ClientAbility(_, _) end

function Tisha.UseActiveAbility(_, instance, p)
	instance:WaitForChild("Config")
	local ability1 = instance:WaitForChild("Abilities"):WaitForChild("Ability1")
	local cooldown = ability1:WaitForChild("Cooldown")
	local currentCooldown = ability1:WaitForChild("CurrentCooldown")
	local stats = instance:WaitForChild("Stats")
	stats:WaitForChild("WalkSpeed")
	stats:WaitForChild("RunSpeed")
	instance:WaitForChild("Humanoid")
	instance:WaitForChild("HumanoidRootPart")

	if currentCooldown.Value > 0 then
		return {
			Outcome = false,
			Reason = "That Ability is on Cooldown!"
		}
	end

	if workspace.Info.FloorActive.Value ~= true then
		return {
			Outcome = false,
			Reason = "Can't use that Ability in the Elevator!"
		}
	end

	currentCooldown.Value = cooldown.Value
	task.spawn(function()
		game.ReplicatedStorage.Events.AnimateTower:FireAllClients(instance, "Ability")

		if instance and instance.Parent ~= nil then
			local tishaPoof = ReplicatedStorage.Parts.RenderModules.TishaPoof
			ReplicatedStorage.Events.RenderObject:FireAllClients(tishaPoof, { instance })
		end
	end)
	local StatModifierManager = require(ReplicatedStorage.Modules.Data.StatModifierManager)

	for _, child in pairs(workspace.InGamePlayers:GetChildren()) do
		local v2 = child
		local success, result = pcall(function()
			if v2 ~= instance then
				local humanoidRootPart = v2:WaitForChild("HumanoidRootPart")

				if (p.Position - humanoidRootPart.Position).Magnitude <= Tisha.AbilityRange then
					local v3 = StatModifierManager.ApplySpeedModifiers(v2, 1.25, "TishaTidyUp", {
						category = "ability",
						antiCheat = true
					})
					task.delay(Tisha.AbilityDuration, function()
						if v3 then
							StatModifierManager.RemoveSpeedModifiers(v2, v3)
						end
					end)
					local attachment = Instance.new("Attachment")
					attachment.Name = "BuffParticle"
					attachment.Parent = humanoidRootPart
					local clone = game.ReplicatedStorage.Parts.BuffParticles.Speed.BuffParticle:Clone()
					clone.Parent = attachment
					clone.Enabled = true
					local clone2 = game.ReplicatedStorage.Parts.BuffParticles.Speed.Glow:Clone()
					clone2.Parent = attachment
					clone2.Enabled = true
					Debris:AddItem(clone, Tisha.AbilityDuration + 1)
					Debris:AddItem(clone2, Tisha.AbilityDuration + 1)
					Debris:AddItem(attachment, Tisha.AbilityDuration + 1)
					task.delay(Tisha.AbilityDuration, function()
						if instance and instance.Parent ~= nil and attachment then
							clone.Enabled = false
							clone2.Enabled = false
						end
					end)
				end
			end
		end)

		if not success then
			warn(result)
		end
	end

	task.spawn(function()
		local lastTime = os.clock()

		while instance do
			currentCooldown.Value -= 0.1

			if currentCooldown.Value <= 0 then
				currentCooldown.Value = 0
				break
			else
				local v3 = 0.1 - (os.clock() - lastTime) % 0.1
				task.wait(v3)
			end
		end
	end)
	return {
		Outcome = true,
		Reason = "Can't use that item at full Stamina!"
	}
end

return Tisha