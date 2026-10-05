local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Net = require(ReplicatedStorage.packages.Net)
local level = require(ReplicatedStorage.shared.modules.character.level)
local GeneralUIModule = require(ReplicatedStorage.shared.modules.GeneralUIModule)
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local v = {
	ImageLabel = "ImageTransparency",
	TextLabel = "TextTransparency",
	Frame = "BackgroundTransparency",
	UIStroke = "Transparency"
}
local localPlayer = Players.LocalPlayer
local stats = legacyLocalPlayerData.fetch():WaitForChild("Stats")
local realLevel = stats:WaitForChild("realLevel")
local safezone = localPlayer.PlayerGui:WaitForChild("hud"):WaitForChild("safezone")
local ui = ReplicatedStorage.resources.ui.level.ui
local remoteEvent = Net:RemoteEvent("Level/LevelUp")
local remoteEvent2 = Net:RemoteEvent("Level/Progress")

-- equivalent calls inferred from this helper; original call sites unknown
local function getXpPerLevelMultiplier(value: number)
	if value <= 1000 then
		return 190
	end

	return 2 ^ (math.floor((value - 1001) / 500) + 1) * 190
end

local LevelUpController = {}

function LevelUpController:LevelUp(p, text)
	local clone = ui:Clone()
	clone.Visible = true
	clone.lvlup.Visible = false
	clone.reward.Visible = false
	clone.Name = "lvlup"
	local xpPerLevelMultiplier = getXpPerLevelMultiplier(realLevel.Value) -- equivalent call inferred; original call site unknown
	clone.bar.fill.Size = UDim2.fromScale(p / (realLevel.Value * xpPerLevelMultiplier), 1)
	TweenService:Create(clone.bar.fill, TweenInfo.new(0.7, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
		Size = UDim2.new(1, 0, 1, 0)
	}):Play()
	TweenService:Create(clone.fish, TweenInfo.new(4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
		Rotation = 17
	}):Play()
	clone.Parent = safezone

	for _, descendant in clone:GetDescendants() do
		local v2 = v[descendant.ClassName]

		if v2 then
			TweenService:Create(
				descendant,
				TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 4),
				{
					[v2] = 1
				}
			):Play()
		end
	end

	clone.title.Text = text
	clone.xp.Visible = false
	task.wait(0.7)
	GeneralUIModule:FadedBorder(Color3.fromRGB(242, 255, 97), 0.7, 5)
	clone.title.Rotation = -15
	clone.title.Size += UDim2.new(0, 20, 0, 20)
	clone.title.TextColor3 = Color3.fromRGB(175, 206, 255)
	TweenService:Create(clone.title, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(1, 0, 0.59, 0),
		Rotation = 0,
		TextColor3 = Color3.fromRGB(255, 229, 151)
	}):Play()
	clone.bar.fill.Size = UDim2.new(0, 0, 1, 0)
	TweenService:Create(clone.bar.fill.tip, TweenInfo.new(1.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 0, 1, 0)
	}):Play()
	local xpPerLevelMultiplier2 = getXpPerLevelMultiplier(realLevel.Value) -- equivalent call inferred; original call site unknown
	TweenService:Create(clone.bar.fill, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(stats.xp.Value / (realLevel.Value * xpPerLevelMultiplier2), 0, 1, 0)
	}):Play()

	if realLevel.Value >= level.Max then
		clone.title.Text = "MAX!"
	else
		clone.title.Text = realLevel.Value
	end

	clone.lvlup.Visible = true
	clone.xp.Visible = false

	for k, levelReward in level.LevelRewards do
		if not (levelReward.Text and text < k and k <= realLevel.Value) then
			continue
		end

		clone.reward.Text = `[{levelReward.Text}]`
		clone.reward.Visible = true
	end

	task.delay(5, clone.Destroy, clone)
end

function LevelUpController:Progress(p, p2)
	local lvlup = safezone:FindFirstChild("lvlup")

	if lvlup then
		lvlup:FindFirstChild("Label")
	end

	if lvlup and (lvlup:IsA("TextLabel") or lvlup:IsA("TextButton")) and lvlup.TextTransparency == 0 then
		return
	end

	local xpup = safezone:FindFirstChild("xpup")

	if xpup then
		xpup:Destroy()
	end

	local clone = ui:Clone()
	clone.Visible = true
	clone.lvlup.Visible = false
	clone.reward.Visible = false
	clone.Name = "xpup"

	if realLevel.Value >= level.Max then
		clone.title.Text = "MAX!"
	else
		clone.title.Text = realLevel.Value
	end

	clone.xp.Text = `+{p}xp`
	local xpPerLevelMultiplier = getXpPerLevelMultiplier(realLevel.Value) -- equivalent call inferred; original call site unknown
	clone.bar.fill.Size = UDim2.new(math.clamp(p2 / (realLevel.Value * xpPerLevelMultiplier), 0, 1), 0, 1, 0)
	TweenService:Create(clone.bar.fill, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.fromScale(math.clamp(stats.xp.Value / (stats.level.Value * xpPerLevelMultiplier), 0, 1), 1)
	}):Play()
	TweenService:Create(clone.bar.fill.tip, TweenInfo.new(2.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 0, 1, 0)
	}):Play()
	TweenService:Create(clone.fish, TweenInfo.new(4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
		Rotation = 17
	}):Play()
	clone.Parent = safezone

	for _, descendant in clone:GetDescendants() do
		local v2 = v[descendant.ClassName]

		if v2 then
			TweenService:Create(
				descendant,
				TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 4),
				{
					[v2] = 1
				}
			):Play()
		end
	end

	task.delay(5, clone.Destroy, clone)
end

function LevelUpController:Start()
	remoteEvent.OnClientEvent:Connect(function(...)
		self:LevelUp(...)
	end)
	remoteEvent2.OnClientEvent:Connect(function(...)
		self:Progress(...)
	end)
end

return LevelUpController