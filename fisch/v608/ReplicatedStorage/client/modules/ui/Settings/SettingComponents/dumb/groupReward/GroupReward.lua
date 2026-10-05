local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local parent = script.Parent
local claim = parent:WaitForChild("Claim")
local events = ReplicatedStorage:WaitForChild("events")
local anno_localthought = events:WaitForChild("anno_localthought")
local claimGroupReward = events:WaitForChild("claimGroupReward")
local packages = ReplicatedStorage:WaitForChild("packages")
local Promise = require(packages:WaitForChild("Promise"))
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local groupRewards = legacyLocalPlayerData.fetch():WaitForChild("Stats"):WaitForChild("groupRewards")
local promisify = Promise.promisify(function(object, p)
	return object:IsInGroup(p)
end)

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function lerpRotation(p, p2, p3)
	return p + (p2 - p) * p3
end

local function animateChest(text)
	local clone = script:WaitForChild("Frame"):Clone()
	clone.TextLabel.Text = text
	clone.Parent = parent:FindFirstAncestorOfClass("ScreenGui")
	local imageLabel = clone.ImageLabel
	local position = imageLabel.Position
	local uDim = UDim2.new(0, 0, 0, -35)

	for i = 0, 1, 0.02 do
		local value = TweenService:GetValue(i, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		imageLabel.Position = position:Lerp(position + uDim, value)
		imageLabel.Rotation = 0 + 720 * value
		task.wait(0.01)
	end

	imageLabel.Rotation = 0
	task.spawn(function()
		for i = 0, 1, 0.02 do
			local value = TweenService:GetValue(i, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
			imageLabel.Position = (position + uDim):Lerp(position, value)
			imageLabel.Rotation = -(720 + -720 * value)
			task.wait(0.013333333333333334)
		end

		imageLabel.Rotation = 0
	end)

	for i = 0, 1, 0.02 do
		local v = 0 + 1 * TweenService:GetValue(i, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		imageLabel.ImageTransparency = v
		clone.TextLabel.TextTransparency = v
		clone.TextLabel.UIStroke.Transparency = v
		task.wait(0.008333333333333333)
	end
end

claim.MouseButton1Click:Connect(function()
	local v, v2 = promisify(localPlayer, 7381705):await()

	if not (v and v2) then
		anno_localthought:Fire("<font color = '#ff0000'>You have not joined the group</font>")
		return
	end

	if groupRewards.Value then
		anno_localthought:Fire("<font color = '#ff0000'>Reward already collected!</font>")
		return
	end

	claimGroupReward:FireServer()
	animateChest("<font color = '#78ffb7'>SUCCESS YOU HAVE RECEIVED <font color=\"rgb(255,253,228)\">5000 C$</font></font>")
end)

if groupRewards.Value then
	parent:Destroy()
end

groupRewards:GetPropertyChangedSignal("Value"):Connect(function()
	if groupRewards.Value then
		parent:Destroy()
	end
end)