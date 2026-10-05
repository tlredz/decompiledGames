local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
local guiEvents = ReplicatedStorage:WaitForChild("OtherEvent"):WaitForChild("GuiEvents")
local NPCTalks = require(moduleScript:WaitForChild("NPCTalks"))

for _, proximityPrompt in ipairs(CollectionService:GetTagged("NPCPrompt")) do
	if not proximityPrompt:IsA("ProximityPrompt") then
		continue
	end

	local v = proximityPrompt
	proximityPrompt.Triggered:Connect(function(player)
		if v.Name == "Set_BedPoint" then
			NPCTalks.StartTalking(v.Name, {
				Interacter = player,
				NPCName = v.Parent.Parent.Name
			})
		elseif v.Name == "Spawn_Boat" then
			NPCTalks.StartTalking(v.Name, {
				Interacter = player
			})
		elseif v.Name == "Upgrade_Quest" then
			NPCTalks.StartTalking(v.Name, {
				Interacter = player
			})
		elseif v.Name == "Weapon_Seller" then
			NPCTalks.StartTalking(v.Name, {
				Interacter = player,
				NPCName = v.Parent.Parent.Name
			})
		elseif v.Name == "FightingStyle_Teacher" then
			NPCTalks.StartTalking(v.Name, {
				Interacter = player,
				NPCName = v.Parent.Parent.Name
			})
		elseif v.Name == "Reroll_Race" then
			NPCTalks.StartTalking(v.Name, {
				Interacter = player,
				NPCName = v.Parent.Parent.Name
			})
		elseif v.Name == "Ability_Teacher" then
			NPCTalks.StartTalking(v.Name, {
				Interacter = player,
				NPCName = v.Parent.Parent.Name
			})
		elseif v.Name == "Color_Storage" then
			guiEvents.GuiEvent:Fire({
				MenuName = "AuraColor",
				Action = "Open"
			})
		elseif v.Name == "Reroll_Color" then
			NPCTalks.StartTalking(v.Name, {
				Interacter = player,
				NPCName = v.Parent.Parent.Name
			})
		elseif v.Name == "Random_Power" then
			NPCTalks.StartTalking(v.Name, {
				Interacter = player,
				NPCName = v.Parent.Parent.Name
			})
		elseif v.Name == "Change_Team" then
			NPCTalks.StartTalking(v.Name, {
				Interacter = player,
				NPCName = v.Parent.Parent.Name
			})
		elseif v.Name == "Pvp_Boosts" then
			NPCTalks.StartTalking(v.Name, {
				Interacter = player,
				NPCName = v.Parent.Parent.Name
			})
		end
	end)
end