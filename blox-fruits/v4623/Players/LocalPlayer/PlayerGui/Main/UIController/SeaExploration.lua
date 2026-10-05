local clone = script.Frame:Clone()
local clone2 = script.DangerText:Clone()
local clone3 = script.DangerLevel:Clone()
require(game.ReplicatedStorage.BuildInfo)
local IrisLog = require(game.ReplicatedStorage.Util.IrisLog)
local seaExploration = IrisLog.new("Sea Exploration", 2, {
	Hidden = true,
	Category = "World"
})
local Realm = require(game.ReplicatedStorage.Util.Realm)
clone.Visible = false
clone2.Visible = false
clone3.Visible = false
local dangerLevel = game.Players.LocalPlayer:GetAttribute("DangerLevel") or 0
local GetDangerLevel = require(game.ReplicatedStorage:WaitForChild("Util"):WaitForChild("GetDangerLevel"))
local dangerInfo = GetDangerLevel(dangerLevel)
local frozen = table.freeze({
	{
		Text = "None",
		Color = Color3.fromHex("#888888")
	},
	{
		Text = "Low",
		Color = Color3.fromHex("#22ff00")
	},
	{
		Text = "Medium",
		Color = Color3.fromHex("#ffff00")
	},
	{
		Text = "High",
		Color = Color3.fromHex("#ff8c00")
	},
	{
		Text = "Extreme",
		Color = Color3.fromHex("#ff0000")
	},
	{
		Text = "Crazy",
		Color = Color3.fromHex("#e100ff")
	},
	{
		Text = "????",
		Color = Color3.fromHex("#8c00ff")
	}
})
local SeaExploration = {
	frame = clone,
	enabledChanged = 0,
	dangerRaw = 0,
	dangerInfo = 0,
	dangerDisplay = 0,
	IsEnabled = 0
}
local Signal = require(game.ReplicatedStorage.Modules.Util.Signal)
SeaExploration.enabledChanged = Signal.new()
SeaExploration.dangerRaw = dangerLevel
SeaExploration.dangerInfo = dangerInfo
SeaExploration.dangerDisplay = frozen[1]

function SeaExploration:IsEnabled()
	return self.dangerRaw > 1
end

local v2 = false
seaExploration:AppendToTab("Actions", seaExploration:Button("Force Enable danger display", function()
	v2 = true
end))
local frame = nil
local v3 = nil

function updateDanger()
	if Realm.getIfCurrentRealmHasTagAsync("IsSecondSea") and not v2 then
		SeaExploration.dangerRaw = 0
	end

	if not frame then
		frame = script.Parent.Parent:WaitForChild("Compass"):WaitForChild("Frame")
		clone.Parent = frame
		clone2.Parent = frame
		clone3.Parent = frame
		clone.Parent.ClipsDescendants = false
		clone.Parent.Parent.ClipsDescendants = false
	end

	local GetDangerLevel2 = require(game.ReplicatedStorage:WaitForChild("Util"):WaitForChild("GetDangerLevel"))
	local dangerInfo2 = GetDangerLevel2(SeaExploration.dangerRaw)
	local level = dangerInfo2.level
	local percent = dangerInfo2.percent
	local dangerDisplay = frozen[level]
	local color = dangerDisplay.Color
	clone3.TextLabel.Text = level - 1
	clone3.TextLabel.Shadow.Text = level - 1
	clone3.TextLabel.Shadow.TextColor3 = color
	clone3.Symbol.Shadow.TextColor3 = color
	clone2.Text = frozen[level].Text
	clone2.Shadow.Text = frozen[level].Text
	clone2.Shadow.TextColor3 = color
	clone2.Visible = SeaExploration:IsEnabled()
	clone3.Visible = SeaExploration:IsEnabled()
	clone.Visible = SeaExploration:IsEnabled()
	clone.BottomLeft.ImageLabel.ImageColor3 = color
	clone.Right.ImageLabel.ImageColor3 = color
	clone.TopLeft.ImageLabel.ImageColor3 = color
	local v6 = (level - 1) * 316 / 6 - 30 - 1.5 + 51.333333333333336 * percent

	if level < 2 then
		v6 += 1.5
	end

	local v7 = v6 + 30

	if percent == 0 then
		v7 -= 1
	end

	clone.TopLeft.ImageLabel.UIGradient.Rotation = math.min(v7, 180) + 150
	clone.Right.ImageLabel.UIGradient.Rotation = math.clamp(v7 - 30, 0, 180)
	clone.BottomLeft.ImageLabel.UIGradient.Rotation = math.clamp(v7 - 210, 0, 180)
	SeaExploration.dangerInfo = dangerInfo2
	SeaExploration.dangerDisplay = dangerDisplay

	if v3 ~= SeaExploration:IsEnabled() then
		SeaExploration.enabledChanged:Fire()
	end

	v3 = SeaExploration:IsEnabled()
end

local numberValue = Instance.new("NumberValue")
numberValue.Changed:Connect(function()
	SeaExploration.dangerRaw = numberValue.Value
	updateDanger()
end)
game.Players.LocalPlayer:GetAttributeChangedSignal("DangerLevel"):Connect(function()
	local TweenService = game:GetService("TweenService")
	TweenService:Create(numberValue, TweenInfo.new(0.5), {
		Value = game.Players.LocalPlayer:GetAttribute("DangerLevel") or 0
	}):Play()
end)
numberValue.Value = SeaExploration.dangerRaw
task.spawn(updateDanger)
return SeaExploration