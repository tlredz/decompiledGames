local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Net = require(ReplicatedStorage.packages.Net)
local SharedIdolFavor = require(ReplicatedStorage.shared.modules.SharedIdolFavor)
local GeneralUIModule = require(ReplicatedStorage.shared.modules.GeneralUIModule)
local v = {
	ImageLabel = "ImageTransparency",
	TextLabel = "TextTransparency",
	Frame = "BackgroundTransparency",
	UIStroke = "Transparency"
}
local color = Color3.fromRGB(120, 220, 140)
local color2 = Color3.fromRGB(160, 255, 180)
local color3 = Color3.fromRGB(205, 255, 215)
local localPlayer = Players.LocalPlayer
local safezone = localPlayer.PlayerGui:WaitForChild("hud"):WaitForChild("safezone")
local idolui = ReplicatedStorage.resources.ui.level.idolui
local remoteEvent = Net:RemoteEvent("IdolFavor/LevelUp")
local remoteEvent2 = Net:RemoteEvent("IdolFavor/Progress")

-- equivalent calls inferred from this helper; original call sites unknown
local function getBarProgress()
	local level = SharedIdolFavor.GetLevel(localPlayer)
	local XP = SharedIdolFavor.GetXP(localPlayer)
	local xPForNextLevel = SharedIdolFavor.GetXPForNextLevel(level)

	if not xPForNextLevel or xPForNextLevel <= 0 then
		return 1
	end

	return (math.clamp(XP / xPForNextLevel, 0, 1))
end

local function fadeOut(folder)
	for _, descendant in folder:GetDescendants() do
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
end

local function clearSlot(...)
	for _, childName in { ... } do
		local child = safezone:FindFirstChild(childName)

		if child then
			child:Destroy()
		end
	end
end

local function waitForFishingLevelUp()
	local v2 = os.clock() + 7

	while safezone:FindFirstChild("lvlup") and os.clock() < v2 do
		task.wait(0.1)
	end
end

local IdolFavorController = {
	LevelUp = function(self, p, p2, p3, value)
		waitForFishingLevelUp()
		clearSlot("idol_lvlup", "idol_xpup", "xpup")
		local clone = idolui:Clone()
		clone.Visible = true
		clone.lvlup.Visible = false
		clone.reward.Visible = false
		clone.Name = "idol_lvlup"
		local childAddedConnection = safezone.ChildAdded:Connect(function(guiObject)
			if guiObject.Name == "xpup" and guiObject:IsA("GuiObject") then
				task.defer(function()
					guiObject.Visible = false
				end)
			end
		end)
		task.delay(5, childAddedConnection.Disconnect, childAddedConnection)
		local xPForLevel = SharedIdolFavor.GetXPForLevel(p + 1)
		local v2 = not (xPForLevel > 0) and 0 or math.clamp((p3 - (value or 0)) / xPForLevel, 0, 1)
		clone.bar.fill.Size = UDim2.fromScale(v2, 1)
		TweenService:Create(clone.bar.fill, TweenInfo.new(0.7, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			Size = UDim2.new(1, 0, 1, 0)
		}):Play()
		TweenService:Create(clone.fish, TweenInfo.new(4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
			Rotation = 17
		}):Play()
		clone.Parent = safezone
		fadeOut(clone)
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

		if SharedIdolFavor.MAX_LEVEL <= p2 then
			clone.title.Text = "MAX!"
		else
			clone.title.Text = tostring(p2)
		end

		clone.lvlup.Visible = true
		clone.xp.Visible = false
		clone.reward.Visible = false
		task.delay(5, clone.Destroy, clone)
	end
}

local function annotateFishingPopUp(p: number)
	local xpup = safezone:FindFirstChild("xpup")

	if not xpup then
		return false
	end

	local xp = xpup:FindFirstChild("xp")
	local reward = xpup:FindFirstChild("reward")

	if not xp or not reward or xp.TextTransparency > 0 then
		return false
	end

	reward.Text = `+{p} Idol Favor`
	reward.TextColor3 = color2
	reward.Visible = true
	return true
end

function IdolFavorController:Progress(p, p2, p3)
	task.wait(0.05)

	if safezone:FindFirstChild("idol_lvlup") or safezone:FindFirstChild("lvlup") or annotateFishingPopUp(p) then
		return
	end

	clearSlot("idol_xpup", "xpup")
	local clone = idolui:Clone()
	clone.Visible = true
	clone.lvlup.Visible = false
	clone.reward.Visible = false
	clone.Name = "idol_xpup"

	if SharedIdolFavor.MAX_LEVEL <= p3 then
		clone.title.Text = "MAX!"
	else
		clone.title.Text = tostring(p3)
	end

	clone.xp.Text = `+{p} Idol Favor`
	local v2 = p2 - p
	local xPForNextLevel = SharedIdolFavor.GetXPForNextLevel(p3)
	local v3, v4

	if xPForNextLevel and xPForNextLevel > 0 then
		v3 = math.clamp(v2 / xPForNextLevel, 0, 1)
		v4 = math.clamp(p2 / xPForNextLevel, 0, 1)
	else
		v3 = 0
		v4 = 1
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
	fadeOut(clone)
	task.delay(5, clone.Destroy, clone)
end

function IdolFavorController:Start()
	remoteEvent.OnClientEvent:Connect(function(...)
		self:LevelUp(...)
	end)
	remoteEvent2.OnClientEvent:Connect(function(...)
		self:Progress(...)
	end)
end

return IdolFavorController