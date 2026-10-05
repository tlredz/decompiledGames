local AirHorn = {
	Name = "Air Horn",
	PointCost = 55,
	DandyStoreItem = true,
	FloorItem = true,
	Rarity = "Rare",
	Icon = "rbxassetid://18537864423",
	Description = "Use this item to decrease Stealth drastically and alert any Twisteds nearby to your location for 10 seconds.",
	ItemDuration = 10
}
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StatModifierManager = require(ReplicatedStorage.Modules.Data.StatModifierManager)
local Audio = require(ReplicatedStorage.SharedUtils.Audio)

function AirHorn.UseItem(instance, p)
	local stats = instance:WaitForChild("Stats")
	stats:WaitForChild("CurrentStamina")
	stats:WaitForChild("Stamina")
	instance:WaitForChild("Humanoid")
	stats:WaitForChild("Stealth")
	stats:WaitForChild("StealthModifier")
	local v = { instance, AirHorn.ItemDuration }
	local airHornRage = ReplicatedStorage.Parts.RenderModules.AirHornRage
	ReplicatedStorage.Events.RenderObject:FireAllClients(airHornRage, v)

	if instance:FindFirstChild("HumanoidRootPart") then
		local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
		Audio:Play("Sounds.Items.AirHorn.UseSound", {
			Parent = humanoidRootPart
		})
		task.spawn(function()
			local attachment = Instance.new("Attachment")
			attachment.Name = "BuffParticle"
			attachment.Parent = humanoidRootPart
			local clone = script.BuffParticle:Clone()
			clone.Parent = attachment
			clone.Enabled = true
			Debris:AddItem(clone, AirHorn.ItemDuration + 1)
			Debris:AddItem(attachment, AirHorn.ItemDuration + 1)
			task.delay(AirHorn.ItemDuration, function()
				if instance and instance.Parent ~= nil and attachment then
					clone.Enabled = false
				end
			end)
		end)
	end

	ReplicatedStorage.Events.MachineEvent:Fire(instance)
	local v3 = StatModifierManager.ApplyAdditiveStealthModifier(instance, -50, "AirHorn")
	local BuffIndicator = require(ReplicatedStorage.Modules.Gameplay.BuffIndicator)
	BuffIndicator.raise(instance, "ItemAirHorn", AirHorn.ItemDuration)
	task.delay(AirHorn.ItemDuration, function()
		if instance and instance.Parent ~= nil then
			StatModifierManager.RemoveAdditiveStealthModifier(instance, v3)
		end
	end)
	p.Value = "None"
	local child = workspace.Info.PlayerStats:FindFirstChild(instance.Name)

	if child then
		local survivalPoints = child:WaitForChild("SurvivalPoints")
		survivalPoints.Value += 5
	end

	return {
		Outcome = true,
		Reason = "Can't use that item at full Stamina!"
	}
end

return AirHorn