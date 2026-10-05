local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Net = require(ReplicatedStorage.packages.Net)
local Level = require(ReplicatedStorage.shared.modules.SharedKeeperEnchant.Level)
local SharedIdolFavor = require(ReplicatedStorage.shared.modules.SharedIdolFavor)
require(ReplicatedStorage.shared.utils.FischUtils)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local playerDataReplicator = DataController.PlayerDataReplicator
local localPlayer = Players.LocalPlayer
local parent = script.Parent
local lvl = parent.Parent.lvl
local uIStroke = parent:FindFirstChildWhichIsA("UIStroke")
local remoteEvent = Net:RemoteEvent("KeeperLevel/LevelUp")
local remoteEvent2 = Net:RemoteEvent("KeeperLevel/Progress")
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- equivalent calls inferred from this helper; original call sites unknown
local function updateText()
	parent.Text = `Keeper Level: {Level.GetLevel(localPlayer)}`
end

local function updateNormalLevelVisibility()
	local v = not (Level.IsInKeeperZone(localPlayer) or SharedIdolFavor.IsInSkycrestZone(localPlayer))
	TweenService:Create(lvl, tweenInfo, {
		TextTransparency = v and 0 or 1
	}):Play()
	TweenService:Create(lvl.UIStroke, tweenInfo, {
		Transparency = v and 0.3 or 1
	}):Play()
end

local function updateVisibility()
	if Level.IsInKeeperZone(localPlayer) then
		TweenService:Create(parent, tweenInfo, {
			TextTransparency = 0,
			TextStrokeTransparency = 0.5
		}):Play()

		if uIStroke then
			TweenService:Create(uIStroke, tweenInfo, {
				Transparency = 0.3
			}):Play()
		end
	else
		TweenService:Create(parent, tweenInfo2, {
			TextTransparency = 1,
			TextStrokeTransparency = 1
		}):Play()

		if uIStroke then
			TweenService:Create(uIStroke, tweenInfo2, {
				Transparency = 1
			}):Play()
		end
	end

	updateNormalLevelVisibility()
end

parent.TextTransparency = 1
parent.TextStrokeTransparency = 1

if uIStroke then
	uIStroke.Transparency = 1
end

parent.Text = `Keeper Level: {Level.GetLevel(localPlayer)}`
remoteEvent.OnClientEvent:Connect(function(_, _, _)
	updateText() -- equivalent call inferred; original call site unknown
end)
remoteEvent2.OnClientEvent:Connect(function(_, _, _)
	updateText() -- equivalent call inferred; original call site unknown
end)
playerDataReplicator:Observe({ "StatuesSecret", "Keeper", "Level" }, updateText)

local function setupZoneListener()
	local character = localPlayer.Character

	if not character then
		return
	end

	local zone = character:WaitForChild("zone", 10)

	if not zone then
		return
	end

	zone.Changed:Connect(function()
		updateVisibility()
	end)
	updateVisibility()
end

setupZoneListener()
localPlayer.CharacterAdded:Connect(function()
	task.wait(1)
	updateText() -- equivalent call inferred; original call site unknown
	setupZoneListener()
end)