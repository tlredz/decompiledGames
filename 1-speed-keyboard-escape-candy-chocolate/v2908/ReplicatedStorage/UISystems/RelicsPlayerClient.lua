local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local relicsXYZ = ReplicatedStorage:WaitForChild("RelicsXYZ")
local module = require(relicsXYZ)
local RelicsPlayer = require((relicsXYZ:WaitForChild("RelicsPlayer")))
local boombox = module.Boombox
local RelicsPlayerClient = {}
local v = nil

function RelicsPlayerClient.Get()
	return v
end

function RelicsPlayerClient.OpenEquipWheel()
	RelicsPlayerClient.Init()

	if v then
		v:SetEquipWheelOpen(true)
	end
end

function RelicsPlayerClient.OpenBoomboxWindow()
	RelicsPlayerClient.Init()

	if v then
		v:SetWindowState("Full")
	end
end

function RelicsPlayerClient.OpenEmoteWheelAndBoombox()
	RelicsPlayerClient.Init()

	if v then
		v:SetEquipWheelOpen(true)
		v:SetWindowState("Full")
	end
end

function RelicsPlayerClient.ToggleEquipWheel()
	if not v then
		return
	end

	local equipWheelOpen = v:GetEquipWheelOpen()
	v:SetEquipWheelOpen(not equipWheelOpen)
end

function RelicsPlayerClient.ToggleWindowState()
	if not v then
		return
	end

	if v:GetWindowState() == "Hidden" then
		v:SetWindowState("Full")
		return
	end

	v:SetWindowState("Hidden")
	v:SetPlaying(false)
end

local function onBoomboxOwnershipChanged() end

function RelicsPlayerClient.Init()
	if v then
		return v
	end

	local localPlayer = Players.LocalPlayer
	local playerGui = localPlayer:WaitForChild("PlayerGui")
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "RelicsPlayerGUI"
	screenGui.ResetOnSpawn = false
	screenGui.Enabled = true
	screenGui.IgnoreGuiInset = false
	screenGui.SafeAreaCompatibility = Enum.SafeAreaCompatibility.FullscreenExtension
	screenGui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
	screenGui.DisplayOrder = 100
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui
	v = RelicsPlayer.new(screenGui)
	v:SetWindowState("Hidden")
	v:SetPlaying(false)
	v:SetEnabled(true)
	v:SetPlaying(false)
	task.spawn(function()
		if boombox.PlayerOwnsBoomboxAsync(localPlayer) then
			return
		end

		boombox.GetBoomboxOwnershipChangedSignal(localPlayer):Once(onBoomboxOwnershipChanged)
	end)
	return v
end

return RelicsPlayerClient