local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Net = require(ReplicatedStorage.packages.Net)
local Trove = require(game.ReplicatedStorage.packages.Trove)
require(ReplicatedStorage.shared.modules.library)
local bait = require(ReplicatedStorage.shared.modules.library.bait)
local rarities = require(ReplicatedStorage.shared.modules.library.rarities)
local HudController = require(ReplicatedStorage.client.legacyControllers.HudController)
local orderedRarityNames = rarities.OrderedRarityNames
local _ = Players.LocalPlayer.Character.HumanoidRootPart
local remoteEvent = Net:RemoteEvent("Bait/Minigame")
local parent = script.Parent
local _ = parent:WaitForChild("playerbar").BackgroundColor3
local bar = parent:WaitForChild("progress"):WaitForChild("bar")
local _ = bar.BackgroundColor3
local parent2 = parent.Parent
local rarity = bait[script.bait.Value or "Spider"].Rarity
local v = nil

for k, orderedRarityName in orderedRarityNames do
	if orderedRarityName ~= rarity then
		continue
	end

	v = k
	break
end

local maid = Trove.new()
local flag = false
local v3 = 5 * v
local v4 = 20
local backpackGui = HudController:GetBackpackGui()

local function reset(p)
	print((`reset called (failed: {p and "true" or "false"})`))
	maid:Clean()
end

local function validateInput(inputObject)
	return inputObject:IsA("InputObject") and (inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.KeyCode == Enum.KeyCode.Space or inputObject.UserInputType == Enum.UserInputType.Touch or inputObject.KeyCode == Enum.KeyCode.ButtonA)
end

backpackGui.Enabled = false
maid:Add(function()
	backpackGui.Enabled = true
end)
maid:AttachToInstance(parent2)
maid:Add(RunService.PostSimulation:Connect(function(dt)
	if flag then
		return
	end

	bar.Size = UDim2.fromScale(v4 / 100, bar.Size.Y.Scale)

	if not flag then
		if v4 <= 0 then
			flag = true
			remoteEvent:FireServer(false)
			print("reset called (failed: true)")
			maid:Clean()
			return
		elseif v4 >= 100 then
			flag = true
			remoteEvent:FireServer(true)
			print("reset called (failed: false)")
			maid:Clean()
			return
		end
	end

	v4 = math.max(0, v4 - dt * v3)
end))
maid:Add(UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed and input.KeyCode ~= Enum.KeyCode.ButtonA or not validateInput(input) or flag then
		return
	end

	v4 = math.min(100, v4 + 5)
end))