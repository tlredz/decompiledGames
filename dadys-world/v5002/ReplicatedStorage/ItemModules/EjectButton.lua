local EjectButton = {
	Name = "Eject Button",
	PointCost = 150,
	DandyStoreItem = true,
	FloorItem = true,
	Rarity = "UltraRare",
	Icon = "rbxassetid://17727492281",
	Description = "Use this item to increase Stealth, Walk and Run Speed by 25 for 3 seconds while also dispelling the Slow debuff.",
	ItemDuration = 3,
	IceDashSpeed = 65,
	IceDashDuration = 0.5
}
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StatModifierManager = require(ReplicatedStorage.Modules.Data.StatModifierManager)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local BuffIndicator = require(ReplicatedStorage2.Modules.Gameplay.BuffIndicator)
require(ReplicatedStorage.Modules.Audio.SoundUtils)
local Audio = require(ReplicatedStorage.SharedUtils.Audio)

function EjectButton.UseItem(instance, p)
	local stats = instance:WaitForChild("Stats")
	stats:WaitForChild("CurrentStamina")
	stats:WaitForChild("Stamina")
	instance:WaitForChild("Humanoid")
	stats:WaitForChild("Sprinting")
	stats:WaitForChild("SpeedModifier")
	stats:WaitForChild("RunSpeedModifier")
	stats:WaitForChild("Stealth")
	stats:WaitForChild("RunSpeed")
	stats:WaitForChild("WalkSpeed")
	local Players = game:GetService("Players")
	local playerFromCharacter = Players:GetPlayerFromCharacter(instance)
	local removeCharacterAntiExploitModule = game.ServerStorage:WaitForChild("Bindables"):WaitForChild("RemoveCharacterAntiExploitModule")

	if playerFromCharacter then
		removeCharacterAntiExploitModule:Fire(playerFromCharacter, true)
	end

	task.wait()
	local iceSkatingMode = instance:GetAttribute("IceSkatingMode") == true

	if instance:FindFirstChild("HumanoidRootPart") then
		local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
		Audio:Play("Sounds.Items.EjectButton.UseSound", {
			Parent = humanoidRootPart
		})

		if iceSkatingMode then
			task.spawn(function()
				if instance:FindFirstChild("Slow") then
					instance:WaitForChild("Slow"):Destroy()
				end

				local lookVector = humanoidRootPart.CFrame.LookVector
				local assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity
				humanoidRootPart.AssemblyLinearVelocity = Vector3.new(
					lookVector.X * EjectButton.IceDashSpeed,
					assemblyLinearVelocity.Y + 5,
					lookVector.Z * EjectButton.IceDashSpeed
				)
				local attachment = Instance.new("Attachment")
				attachment.Name = "IceDashParticle"
				attachment.Parent = humanoidRootPart
				local clone = game.ReplicatedStorage.Parts.BuffParticles.Speed.BuffParticle:Clone()
				clone.Parent = attachment
				clone.Enabled = true
				clone.Rate = 100
				local clone2 = game.ReplicatedStorage.Parts.BuffParticles.Speed.Glow:Clone()
				clone2.Parent = attachment
				clone2.Enabled = true
				local particleEmitter = Instance.new("ParticleEmitter")
				particleEmitter.Name = "IceDashTrail"
				particleEmitter.Parent = humanoidRootPart
				particleEmitter.Texture = "rbxasset://textures/particles/smoke_main.dds"
				particleEmitter.Rate = 80
				particleEmitter.Lifetime = NumberRange.new(0.3, 0.6)
				particleEmitter.Speed = NumberRange.new(5, 15)
				particleEmitter.SpreadAngle = Vector2.new(30, 30)
				particleEmitter.Color = ColorSequence.new(Color3.fromRGB(180, 220, 255))
				particleEmitter.Size = NumberSequence.new(0.5, 1.5)
				particleEmitter.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.3),
					NumberSequenceKeypoint.new(1, 1)
				})
				particleEmitter.LightEmission = 0.5
				particleEmitter.EmissionDirection = Enum.NormalId.Back
				particleEmitter.Enabled = true
				Debris:AddItem(clone, EjectButton.IceDashDuration + 0.5)
				Debris:AddItem(clone2, EjectButton.IceDashDuration + 0.5)
				Debris:AddItem(particleEmitter, EjectButton.IceDashDuration + 0.5)
				Debris:AddItem(attachment, EjectButton.IceDashDuration + 0.5)
				task.delay(EjectButton.IceDashDuration, function()
					if instance and instance.Parent ~= nil then
						clone.Enabled = false
						clone2.Enabled = false
						particleEmitter.Enabled = false
					end
				end)
				local v2 = StatModifierManager.ApplyAdditiveSpeedBoost(instance, 40, "EjectButtonIceDash", {
					antiCheat = true
				})
				local v3 = StatModifierManager.ApplyAdditiveStealthModifier(instance, 25, "EjectButtonIceDash")
				BuffIndicator.raise(instance, "ItemEjectButton", EjectButton.IceDashDuration)
				task.wait(EjectButton.IceDashDuration)
				StatModifierManager.RemoveAdditiveSpeedBoost(instance, v2)
				StatModifierManager.RemoveAdditiveStealthModifier(instance, v3)
			end)
		else
			task.spawn(function()
				if instance:FindFirstChild("Slow") then
					instance:WaitForChild("Slow"):Destroy()
				end

				local attachment = Instance.new("Attachment")
				attachment.Name = "BuffParticle"
				attachment.Parent = humanoidRootPart
				local clone = game.ReplicatedStorage.Parts.BuffParticles.Speed.BuffParticle:Clone()
				clone.Parent = attachment
				clone.Enabled = true
				local clone2 = game.ReplicatedStorage.Parts.BuffParticles.Speed.Glow:Clone()
				clone2.Parent = attachment
				clone2.Enabled = true
				Debris:AddItem(clone, EjectButton.ItemDuration + 1)
				Debris:AddItem(clone2, EjectButton.ItemDuration + 1)
				Debris:AddItem(attachment, EjectButton.ItemDuration + 1)
				task.delay(EjectButton.ItemDuration, function()
					if instance and instance.Parent ~= nil and attachment then
						clone.Enabled = false
						clone2.Enabled = false
					end
				end)
				local attachment2 = Instance.new("Attachment")
				attachment2.Name = "BuffParticle"
				attachment2.Parent = humanoidRootPart
				local clone3 = game.ReplicatedStorage.Parts.BuffParticles.Stealth.BuffParticle:Clone()
				clone3.Parent = attachment2
				clone3.Enabled = true
				local clone4 = game.ReplicatedStorage.Parts.BuffParticles.Stealth.Glow:Clone()
				clone4.Parent = attachment2
				clone4.Enabled = true
				Debris:AddItem(clone3, EjectButton.ItemDuration + 1)
				Debris:AddItem(clone4, EjectButton.ItemDuration + 1)
				Debris:AddItem(attachment2, EjectButton.ItemDuration + 1)
				task.delay(EjectButton.ItemDuration, function()
					if instance and instance.Parent ~= nil and attachment2 then
						clone3.Enabled = false
						clone4.Enabled = false
					end
				end)
			end)
			task.spawn(function()
				local v2 = StatModifierManager.ApplyAdditiveSpeedBoost(instance, 25, "EjectButton", {
					antiCheat = true
				})
				local v3 = StatModifierManager.ApplyAdditiveStealthModifier(instance, 25, "EjectButton")
				BuffIndicator.raise(instance, "ItemEjectButton", EjectButton.ItemDuration)
				task.wait(EjectButton.ItemDuration)
				StatModifierManager.RemoveAdditiveSpeedBoost(instance, v2)
				StatModifierManager.RemoveAdditiveStealthModifier(instance, v3)
			end)
		end
	end

	p.Value = "None"
	local child = workspace.Info.PlayerStats:FindFirstChild(instance.Name)

	if child then
		local survivalPoints = child:WaitForChild("SurvivalPoints")
		survivalPoints.Value += 10
	end

	return {
		Outcome = true,
		Reason = "Can't use that item at full Stamina!"
	}
end

return EjectButton