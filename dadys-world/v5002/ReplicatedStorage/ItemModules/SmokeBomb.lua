local SmokeBomb = {
	Name = "Smoke Bomb",
	PointCost = 150,
	DandyStoreItem = true,
	FloorItem = true,
	Rarity = "UltraRare",
	Icon = "rbxassetid://17727273649",
	Description = "Use this item when being chased by a Twisted to make it lose interest. Effect lasts 3 seconds.",
	ItemDuration = 3
}
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Modules.Audio.SoundUtils)
local Audio = require(ReplicatedStorage.SharedUtils.Audio)

function SmokeBomb.UseItem(parent, p)
	local stats = parent:WaitForChild("Stats")
	stats:WaitForChild("CurrentStamina")
	stats:WaitForChild("Stamina")
	parent:WaitForChild("Humanoid")

	if parent:FindFirstChild("NoTarget") then
		parent:WaitForChild("NoTarget"):Destroy()
	end

	local boolValue = Instance.new("BoolValue")
	boolValue.Name = "NoTarget"
	boolValue.Parent = parent
	local BuffIndicator = require(ReplicatedStorage.Modules.Gameplay.BuffIndicator)
	BuffIndicator.raise(parent, "ItemSmokeBomb", SmokeBomb.ItemDuration)
	local v = { parent, SmokeBomb.ItemDuration }
	local smokeBomb = ReplicatedStorage.Parts.RenderModules.SmokeBomb
	ReplicatedStorage.Events.RenderObject:FireAllClients(smokeBomb, v)
	Debris:AddItem(boolValue, SmokeBomb.ItemDuration)

	if parent:FindFirstChild("HumanoidRootPart") then
		Audio:Play("Sounds.Items.SmokeBomb.UseSound", {
			Parent = parent:WaitForChild("HumanoidRootPart")
		})
	end

	p.Value = "None"
	local child = workspace.Info.PlayerStats:FindFirstChild(parent.Name)

	if child then
		local survivalPoints = child:WaitForChild("SurvivalPoints")
		survivalPoints.Value += 10
	end

	return {
		Outcome = true,
		Reason = "Can't use that item at full Stamina!"
	}
end

return SmokeBomb