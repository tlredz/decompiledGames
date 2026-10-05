game:GetService("LocalizationService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Network = require(ReplicatedStorage.Modules.Network)
local Monetization = require(ReplicatedStorage.Modules.Monetization)
local localPlayer = Players.LocalPlayer
local parent = script.Parent
local restore = localPlayer.PlayerGui:WaitForChild("Neighbors").DailyRewards.Restore
local label = localPlayer.PlayerGui.Neighbors.DailyRewards.Restore.Label
local id = Monetization:GetProductInfo("RestoreStreak").Id
local v = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function formatSeconds(timeLeft: number)
	local v2 = math.floor(timeLeft / 3600)
	local v3 = math.floor(timeLeft % 3600 / 60)
	local v4 = timeLeft % 60
	return (string.format("%02d:%02d:%02d", v2, v3, v4))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getTimeLeft()
	if v then
		return v.TimeEnd - os.time()
	end

	return 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getRestorableStreak()
	if v then
		return v.Streak
	end

	return 0
end

RunService.RenderStepped:Connect(function()
	local timeLeft = getTimeLeft() -- equivalent call inferred; original call site unknown
	local restorableStreak = getRestorableStreak() -- equivalent call inferred; original call site unknown
	restore.Visible = timeLeft > 0

	if timeLeft < 0 then
		return
	end

	label.Text = ("Restore %*d Streak: (%*)"):format(restorableStreak, formatSeconds(timeLeft))
	local content = parent.Buttons.Restore.Content
	content.Text = ("Restore %*d Streak (%*) (25)"):format(restorableStreak, formatSeconds(timeLeft))
end)
parent.Buttons.Restore.MouseButton1Click:Connect(function()
	if getTimeLeft() <= 0 then
		return
	end

	Monetization:PromptPurchase("RestoreStreak")
end)
parent.Buttons.Close.MouseButton1Click:Once(function()
	parent.Visible = false
end)
restore.MouseButton1Click:Connect(function()
	if getTimeLeft() <= 0 then
		return
	end

	Monetization:PromptPurchase("RestoreStreak")
end)
MarketplaceService.PromptProductPurchaseFinished:Connect(function(p, p2, p3)
	if not p3 then
		return
	end

	if p2 == id and p == localPlayer.UserId then
		parent.Visible = false
	end
end)
Network:listen("RestoreStroke/Update", function(p)
	v = p

	if not p then
		parent.Visible = false
		return
	end

	parent.Streak.Text = `Streak: {p.Streak} Days`

	if v.ShowPrompt then
		parent.Visible = true
	end
end)