local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
workspace:SetAttribute("HasVisibilityHandler", true)
local localPlayer = Players.LocalPlayer
local menuDestination = localPlayer:FindFirstChild("MenuDestination")
local Camera_Traffic_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Camera_Traffic_Handler)
local visibility = game.ReplicatedStorage.CAM.Client.Components.Layout.Visibility
local child = game.ReplicatedStorage.Player_Service.Values:WaitForChild(localPlayer.Name)
local Sets = require(script.Sets)
local SettingsKeys = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.SettingsKeys)
local typeof2 = typeof

function updateVisibility()
	task.wait()
	local v = {}

	if Camera_Traffic_Handler.Equipped_Hirearchy ~= "" and Camera_Traffic_Handler.Equipped_Hirearchy then
		v[Camera_Traffic_Handler.Equipped_Hirearchy] = true
	end

	if menuDestination == nil or menuDestination.Value == "" then
		v.MenuClosed = true
	else
		v.MenuOpened = true
		v[menuDestination.Value] = true
	end

	if visibility.Dialogue.Value == true then
		v.Dialogue = true
	end

	if child:FindFirstChild("CameralessCutscene") then
		v.CameralessCutscene = true
	end

	if localPlayer:GetAttribute("MapOpened") == true then
		v.MapOpened = true
	end

	if localPlayer:GetAttribute("LoadingScreen") == true then
		v.LoadingScreen = true
	end

	local character = localPlayer.Character

	if character ~= nil and character:GetAttribute("InMuzanLair") == true then
		v.MuzanLair = true
	end

	if workspace:GetAttribute("MinigameState") == "Victory" or localPlayer:GetAttribute("Spectating") == true then
		v.MinigameVictory = true
	end

	if localPlayer:GetAttribute("TrialEnding") == true then
		v.TrialEnding = true
	end

	if localPlayer:GetAttribute(SettingsKeys.BossUIAttribute) == true then
		v[SettingsKeys.BossUIAttribute] = true
	end

	if localPlayer:GetAttribute("FishingBite") == true then
		v.FishingBite = true
	end

	if localPlayer:GetAttribute("Guided") == true then
		v.Guided = true
	end

	if child:FindFirstChild("Training") then
		local promptsEnabled = child.Training:GetAttribute("PromptsEnabled")

		if promptsEnabled == nil or promptsEnabled == true then
			v.Training = true
		else
			v.Training = "Prompts"
		end
	end

	for k, set in Sets do
		local name = k.Name or k
		local v2 = true

		for _, v4 in set do
			local v5 = v[v4]

			if not (v5 == true or v5 ~= nil and v5 ~= name) then
				continue
			end

			v2 = false
			break
		end

		if typeof2(k) == "string" then
			local v4

			if k == "PlayerList" then
				v4 = UserInputService.PreferredInput == Enum.PreferredInput.Touch
			else
				v4 = false
			end

			if Enum.CoreGuiType[k] ~= nil and (v2 or not v4) then
				game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType[k], v2)
			end
		else
			k.Value = v2
		end
	end
end

updateVisibility()
local v = {
	Training = true,
	CameralessCutscene = true
}
child.ChildAdded:Connect(function(child2)
	if v[child2.Name] then
		updateVisibility()
	end
end)
child.ChildRemoved:Connect(function(child2)
	if v[child2.Name] then
		updateVisibility()
	end
end)
visibility.Dialogue.Changed:Connect(updateVisibility)

-- equivalent calls inferred from this helper; original call sites unknown
local function hookCharacter(character)
	character:GetAttributeChangedSignal("InMuzanLair"):Connect(updateVisibility)
	updateVisibility()
end

if localPlayer.Character ~= nil then
	hookCharacter(localPlayer.Character) -- equivalent call inferred; original call site unknown
end

localPlayer.CharacterAdded:Connect(hookCharacter)
localPlayer:GetAttributeChangedSignal("LoadingScreen"):Connect(updateVisibility)
localPlayer:GetAttributeChangedSignal("MapOpened"):Connect(updateVisibility)
localPlayer:GetAttributeChangedSignal("FishingBite"):Connect(updateVisibility)
localPlayer:GetAttributeChangedSignal("Guided"):Connect(updateVisibility)
localPlayer:GetAttributeChangedSignal(SettingsKeys.BossUIAttribute):Connect(updateVisibility)
localPlayer:GetAttributeChangedSignal("TrialEnding"):Connect(updateVisibility)
workspace:GetAttributeChangedSignal("MinigameState"):Connect(updateVisibility)
localPlayer:GetAttributeChangedSignal("Spectating"):Connect(updateVisibility)
task.spawn(function()
	if menuDestination == nil then
		menuDestination = localPlayer:WaitForChild("MenuDestination", 99)

		if menuDestination == nil then
			return
		else
			updateVisibility()
		end
	end

	menuDestination.Changed:Connect(updateVisibility)
end)
game.ReplicatedStorage.CAM.Client.Controllers.Camera_Traffic_Handler:FindFirstChild("Updated").Event:Connect(updateVisibility)