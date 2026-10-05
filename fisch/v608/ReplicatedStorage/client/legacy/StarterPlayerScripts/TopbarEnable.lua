local Players = game:GetService("Players")
game:GetService("SocialService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local cinematic = require(ReplicatedStorage.client.modules.cinematic)
local FurnitureController = require(ReplicatedStorage.client.legacyControllers.FurnitureController)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local Icon = require(ReplicatedStorage.shared.modules.Icon)

local function waitForElement(instance, childName, value)
	local child = instance:FindFirstChild(childName)
	local lastTime = tick()

	while not child do
		if (value or 10) < tick() - lastTime then
			return nil
		end

		child = instance:FindFirstChild(childName)
		task.wait()
	end

	return child
end

Icon.new():setImage(137345992835004):setName("Emote"):setRight():oneClick():autoDeselect(true).toggled:Connect(function()
	ReplicatedStorage.events.toggleemotewheel:Fire()
end)
Icon.new():setImage(74708921736745):setName("Quick Access"):setRight():oneClick():autoDeselect(false).selected:Connect(function()
	local QuickAccessController = require(ReplicatedStorage.client.legacyControllers.QuickAccessController)
	QuickAccessController:Toggle()
end)
local enabled = true

local function ToggleUI()
	local v2 = waitForElement(playerGui, "hud")
	local v3 = waitForElement(playerGui, "backpack")
	local v4 = waitForElement(v2, "deviceinset")
	local v5 = waitForElement(playerGui, "CurrentServerBoosts")

	if not (v2 and v4) then
		return
	end

	playerGui:SetAttribute("UiEnabled", enabled)
	v2.Enabled = enabled
	v4.Enabled = enabled
	v3.Enabled = enabled
	v5.Enabled = enabled
	local speedomiter = playerGui:FindFirstChild("speedomiter")

	if speedomiter then
		speedomiter.Enabled = enabled
	end

	cinematic.set(not enabled)
end

local autoDeselect = Icon.new():setImage(18972069477):setName("Camera"):setRight():autoDeselect(false)
autoDeselect.toggled:Connect(function()
	if playerGui:FindFirstChild("reel") or playerGui:FindFirstChild("stab") or playerGui:FindFirstChild("harpoonMinigame") then
		return
	end

	enabled = not enabled

	if enabled == true then
		autoDeselect:setImage(18972061304)
	else
		autoDeselect:setImage(18972069477)
	end

	ToggleUI()
end)
FurnitureController.EditModeChanged:Connect(function(flag: boolean)
	autoDeselect:setEnabled(not flag)

	if flag and not enabled then
		enabled = true
		autoDeselect:setImage(18972061304)
		ToggleUI()
	end
end)
localPlayer.CharacterAdded:Connect(function()
	task.wait(1)
	ToggleUI()
end)
playerGui.ChildRemoved:Connect(function(child)
	if child.Name == "reel" or child.Name == "stab" or child.Name == "harpoonMinigame" then
		ToggleUI()
	end
end)
workspace:GetAttributeChangedSignal("ClientCutsceneRunning"):Connect(function()
	if not workspace:GetAttribute("ClientCutsceneRunning") then
		ToggleUI()
	end
end)
ToggleUI()

local function observeQuestVisibility()
	local v2 = waitForElement(playerGui, "hud")

	if not v2 then
		return
	end

	if waitForElement(v2, "deviceinset") then
	end
end

local v2 = waitForElement(playerGui, "hud")

if v2 then
	waitForElement(v2, "deviceinset")
end