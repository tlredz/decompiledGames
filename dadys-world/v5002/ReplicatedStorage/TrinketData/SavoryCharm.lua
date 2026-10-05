local SavoryCharm = {
	Name = "Savory Charm",
	Icon = "rbxassetid://18696575400",
	Rarity = "Common",
	Description = "Saves the user from a fatal attack, granting them invincibility for 10 seconds. Can only activate once. Does not save the user from Lethal attacks.",
	TrinketType = "Toggle",
	MonsterTrinket = true,
	Cost = 350
}
SavoryCharm.Requirement1 = { "Coin", SavoryCharm.Cost }
SavoryCharm.AbilityDuration = 10
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ActionEvent = require(ReplicatedStorage.SharedUtils.ActionEvent)
local Audio = require(ReplicatedStorage.SharedUtils.Audio)

function SavoryCharm.ApplyTrinket(instance, instance2)
	instance2:WaitForChild("Active")
	instance:WaitForChild("Trinkets")
	local stats = instance:WaitForChild("Stats")
	stats:WaitForChild("CurrentStamina")
	stats:WaitForChild("Stamina")
	stats:WaitForChild("StaminaModifier")
	instance:WaitForChild("Decoding")
	stats:WaitForChild("StaminaRegenModifier")
end

function SavoryCharm.SpecialEvent(parent)
	ActionEvent:Record(parent, "TriggerTrinket", SavoryCharm.Name)
	local humanoidRootPart = parent:WaitForChild("HumanoidRootPart")
	local boolValue = Instance.new("BoolValue")
	boolValue.Name = "Invincible"
	boolValue.Parent = parent
	boolValue.Value = true
	Debris:AddItem(boolValue, 10)
	task.spawn(function()
		if parent and parent.Parent ~= nil then
			local savoryCharm = ReplicatedStorage.Parts.RenderModules.SavoryCharm
			ReplicatedStorage.Events.RenderObject:FireAllClients(savoryCharm, { parent })
			Audio:Play("Sounds.Trinkets.SavoryCharm.AbilitySound", {
				Parent = humanoidRootPart
			})
			local attachment = Instance.new("Attachment")
			attachment.Name = "BuffParticle"
			attachment.Parent = humanoidRootPart
			local clone = ReplicatedStorage.Parts.RenderModules.SavoryCharm.BuffParticle:Clone()
			clone.Parent = attachment
			clone.Enabled = true
			Debris:AddItem(clone, SavoryCharm.AbilityDuration + 1)
			Debris:AddItem(attachment, SavoryCharm.AbilityDuration + 1)
			task.delay(SavoryCharm.AbilityDuration, function()
				if parent and parent.Parent ~= nil and attachment then
					clone.Enabled = false
				end
			end)
		end
	end)
end

function SavoryCharm.RemoveTrinket(instance)
	local trinkets = instance:WaitForChild("Trinkets")
	instance:WaitForChild("Stats"):WaitForChild("DecodeSpeed")
	local trinket1 = trinkets:FindFirstChild("Trinket1")
	local trinket2 = trinkets:FindFirstChild("Trinket2")

	if not (trinket1 and trinket2) then
		return "CantRemove"
	end

	if trinket1.Value == script.Name then
		trinket1.Value = "None"
		return "Slot1"
	end

	if trinket2.Value ~= script.Name then
		return "CantRemove"
	end

	trinket2.Value = "None"
	return "Slot2"
end

return SavoryCharm