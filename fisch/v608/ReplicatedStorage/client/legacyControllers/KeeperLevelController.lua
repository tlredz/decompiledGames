local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Net = require(ReplicatedStorage.packages.Net)
local Level = require(ReplicatedStorage.shared.modules.SharedKeeperEnchant.Level)
local GeneralUIModule = require(ReplicatedStorage.shared.modules.GeneralUIModule)
local v = {
	ImageLabel = "ImageTransparency",
	TextLabel = "TextTransparency",
	Frame = "BackgroundTransparency",
	UIStroke = "Transparency"
}
local color = Color3.fromRGB(140, 120, 255)
local color2 = Color3.fromRGB(170, 140, 255)
local color3 = Color3.fromRGB(200, 180, 255)
local color4 = Color3.fromRGB(120, 90, 220)
local color5 = Color3.fromRGB(180, 160, 255)
local localPlayer = Players.LocalPlayer
local safezone = localPlayer.PlayerGui:WaitForChild("hud"):WaitForChild("safezone")
local ui = ReplicatedStorage.resources.ui.level.ui
local remoteEvent = Net:RemoteEvent("KeeperLevel/LevelUp")
local remoteEvent2 = Net:RemoteEvent("KeeperLevel/Progress")

local function getBarProgress()
	local level = Level.GetLevel(localPlayer)
	local XP = Level.GetXP(localPlayer)
	local xPForNextLevel = Level.GetXPForNextLevel(level)
	local xPForLevel = Level.GetXPForLevel(level)

	if not xPForNextLevel then
		return 1
	end

	local v2 = xPForNextLevel - xPForLevel

	if v2 <= 0 then
		return 1
	end

	return (math.clamp((XP - xPForLevel) / v2, 0, 1))
end

local function applyKeeperColors(clone)
	local bar = clone:FindFirstChild("bar")
	local fill = bar and bar:FindFirstChild("fill")

	if fill then
		fill.BackgroundColor3 = color4
	end

	local title = clone:FindFirstChild("title")

	if title then
		title.TextColor3 = color3
	end

	local xp = clone:FindFirstChild("xp")

	if xp then
		xp.TextColor3 = color2
	end

	local lvlup = clone:FindFirstChild("lvlup")

	if lvlup then
		lvlup.TextColor3 = color5
	end

	local shine = clone:FindFirstChild("shine")

	if shine then
		shine.ImageColor3 = color2
	end

	local shine2 = clone:FindFirstChild("shine2")

	if shine2 then
		shine2.ImageColor3 = color
	end
end

local KeeperLevelController = {}

function KeeperLevelController:LevelUp(p, p2, p3)
	local keeper_lvlup = safezone:FindFirstChild("keeper_lvlup")

	if keeper_lvlup then
		keeper_lvlup:Destroy()
	end

	local keeper_xpup = safezone:FindFirstChild("keeper_xpup")

	if keeper_xpup then
		keeper_xpup:Destroy()
	end

	local clone = ui:Clone()
	clone.Visible = true
	clone.lvlup.Visible = false
	clone.reward.Visible = false
	clone.Name = "keeper_lvlup"
	applyKeeperColors(clone)
	local xPForLevel = Level.GetXPForLevel(p)
	local v2 = Level.GetXPForLevel(p + 1) - xPForLevel
	local v3 = not (v2 > 0) and 0 or math.clamp((p3 - Level.XP_PER_LEVEL * p2) / v2, 0, 1)
	clone.bar.fill.Size = UDim2.fromScale(v3, 1)
	TweenService:Create(clone.bar.fill, TweenInfo.new(0.7, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
		Size = UDim2.new(1, 0, 1, 0)
	}):Play()
	TweenService:Create(clone.fish, TweenInfo.new(4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
		Rotation = 17
	}):Play()
	clone.Parent = safezone

	for _, descendant in clone:GetDescendants() do
		local v4 = v[descendant.ClassName]

		if v4 then
			TweenService:Create(
				descendant,
				TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 4),
				{
					[v4] = 1
				}
			):Play()
		end
	end

	clone.title.Text = tostring(p)
	clone.xp.Visible = false
	task.wait(0.7)
	GeneralUIModule:FadedBorder(color2, 0.7, 5)
	clone.title.Rotation = -15
	clone.title.Size += UDim2.new(0, 20, 0, 20)
	clone.title.TextColor3 = color
	TweenService:Create(clone.title, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(1, 0, 0.59, 0),
		Rotation = 0,
		TextColor3 = color3
	}):Play()
	clone.bar.fill.Size = UDim2.new(0, 0, 1, 0)
	local tip = clone.bar.fill:FindFirstChild("tip")

	if tip then
		TweenService:Create(tip, TweenInfo.new(1.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 0, 1, 0)
		}):Play()
	end

	TweenService:Create(clone.bar.fill, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.fromScale(getBarProgress(), 1)
	}):Play()

	if Level.MAX_LEVEL <= p2 then
		clone.title.Text = "MAX!"
	else
		clone.title.Text = tostring(p2)
	end

	clone.lvlup.Visible = true
	clone.lvlup.Text = "Keeper Level Up!"
	clone.xp.Visible = false
	clone.reward.Visible = false
	task.delay(5, clone.Destroy, clone)
end

function KeeperLevelController:Progress(p, p2, p3)
	if safezone:FindFirstChild("keeper_lvlup") then
		return
	end

	local keeper_xpup = safezone:FindFirstChild("keeper_xpup")

	if keeper_xpup then
		keeper_xpup:Destroy()
	end

	local clone = ui:Clone()
	clone.Visible = true
	clone.lvlup.Visible = false
	clone.reward.Visible = false
	clone.Name = "keeper_xpup"
	applyKeeperColors(clone)

	if Level.MAX_LEVEL <= p3 then
		clone.title.Text = "MAX!"
	else
		clone.title.Text = tostring(p3)
	end

	clone.xp.Text = `+{p} keeper xp`
	clone.xp.TextColor3 = color2
	local v2 = p2 - p
	local xPForLevel = Level.GetXPForLevel(p3)
	local xPForNextLevel = Level.GetXPForNextLevel(p3)
	local v3 = 0
	local v4 = 1

	if xPForNextLevel then
		local v5 = xPForNextLevel - xPForLevel

		if v5 > 0 then
			v3 = math.clamp((v2 - xPForLevel) / v5, 0, 1)
			v4 = math.clamp((p2 - xPForLevel) / v5, 0, 1)
		end
	end

	clone.bar.fill.Size = UDim2.fromScale(v3, 1)
	TweenService:Create(clone.bar.fill, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.fromScale(v4, 1)
	}):Play()
	local tip = clone.bar.fill:FindFirstChild("tip")

	if tip then
		TweenService:Create(tip, TweenInfo.new(2.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 0, 1, 0)
		}):Play()
	end

	TweenService:Create(clone.fish, TweenInfo.new(4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
		Rotation = 17
	}):Play()
	clone.Parent = safezone

	for _, descendant in clone:GetDescendants() do
		local v5 = v[descendant.ClassName]

		if v5 then
			TweenService:Create(
				descendant,
				TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 4),
				{
					[v5] = 1
				}
			):Play()
		end
	end

	task.delay(5, clone.Destroy, clone)
end

function KeeperLevelController:Start()
	remoteEvent.OnClientEvent:Connect(function(...)
		self:LevelUp(...)
	end)
	remoteEvent2.OnClientEvent:Connect(function(...)
		self:Progress(...)
	end)
end

return KeeperLevelController