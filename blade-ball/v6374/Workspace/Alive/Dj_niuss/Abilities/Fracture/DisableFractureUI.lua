game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local ability = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Hotbar"):WaitForChild("Ability")
local counts = ability:WaitForChild("ready"):WaitForChild("counts")
local durationOld = ability:WaitForChild("DurationOld")
local ancestryChangedConnection = nil
local currentlyEquippedAbilityChangedConnection = nil
ancestryChangedConnection = script.AncestryChanged:Connect(function()
	if not script:IsDescendantOf(game) then
		ancestryChangedConnection:Disconnect()
		currentlyEquippedAbilityChangedConnection:Disconnect()
		durationOld.Visible = false
		counts.Visible = false
	end
end)
currentlyEquippedAbilityChangedConnection = localPlayer:GetAttributeChangedSignal("CurrentlyEquippedAbility"):Connect(function()
	if localPlayer:GetAttribute("CurrentlyEquippedAbility") ~= "Fracture" then
		durationOld.Visible = false
		counts.Visible = false
	end
end)
return {}