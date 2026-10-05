local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local RunService = game:GetService("RunService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("StarterGui")
local Players = game:GetService("Players")
local playerGui = Players.LocalPlayer.PlayerGui
local v = nil
local v2 = require3(ReplicatedStorage2.Packages.Net)
local v3 = require3(ReplicatedStorage2.Packages.Replion)
require3(ReplicatedStorage2.Packages.Signal)
require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v4 = require3(ReplicatedStorage2.Common.Utils.Utilities.ValueConvertor)
require3(ReplicatedStorage2.ServerInfo)
require3(ReplicatedStorage2.Shared.Easter.EggHunt)
local v5 = require3(ReplicatedStorage2.Controllers.Easter.EasterPageController)
local v6 = require3(ReplicatedStorage2.Shared.Easter.EasterEvent)
local iterationTime = v6.AdminEvent.IterationTime
local season = v6.AdminEvent.Season
local eggsRequired = v6.AdminEvent.EggsRequired
local startTime = v6.AdminEvent.StartTime
local endTime = v6.AdminEvent.EndTime
local _ = v6.AdminEvent.StockPerIteration
local reward = v6.AdminEvent.Reward

-- equivalent calls inferred from this helper; original call sites unknown
local function GetTimeElapsed()
	return DateTime.now().UnixTimestamp - startTime
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getCurrentIteration()
	return GetTimeElapsed() // iterationTime
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getLimitedKey(currentIteration: number)
	return (`{season}_{currentIteration}`)
end

v2:RemoteFunction("ClaimUGCItem")
v2:RemoteEvent("UGCStockUpdated")
v2:RemoteFunction("ClaimEasterMilestone")
local adminEvent = playerGui:WaitForChild("EasterEvent"):WaitForChild("Overview"):WaitForChild("Views"):WaitForChild("AdminEvent")
local EasterEggAdminEventController = {}

function EasterEggAdminEventController.Init(_)
	v5:RegisterPage("AdminEvent", adminEvent)
end

function EasterEggAdminEventController.Start(_)
	v = v3.Client:WaitReplion("Data")
	adminEvent.TopRewardFrame.Frame.Fade.TopRewardLabel.Text = reward.DisplayName
	adminEvent.TopRewardFrame.Frame.Vector.Scroll.Vector1.Image = reward.Icon
	local clones = {}

	for i = 1, eggsRequired do
		local clone = adminEvent.InfoFrame.Frame.Item2.Frame.UIGridLayout.Egg:Clone()
		clone.Name = `Egg{i}`
		clone.Parent = adminEvent.InfoFrame.Frame.Item2.Frame
		clones[i] = clone
	end

	local v7 = 0
	task.defer(function()
		local v8 = v3.Client:WaitReplion("LimitedStockItems")

		if not v8 then
			return
		end

		local connection = nil
		local connection2 = nil
		local connection3 = nil

		while true do
			local unixTimestamp = DateTime.now().UnixTimestamp

			if unixTimestamp < startTime then
				task.wait(startTime - unixTimestamp)
			end

			if endTime < unixTimestamp then
				break
			end

			local currentIteration = getCurrentIteration() -- equivalent call inferred; original call site unknown
			local limitedKey = getLimitedKey(currentIteration) -- equivalent call inferred; original call site unknown

			if v7 ~= currentIteration then
				v7 = currentIteration

				if connection then
					connection:Disconnect()
				end

				if connection2 then
					connection2:Disconnect()
				end

				if connection3 then
					connection3:Disconnect()
				end

				local v9 = limitedKey

				local function update()
					local v10 = v:Get({
						"EasterAdminEvent",
						"Seasons",
						season,
						"Eggs",
						v9
					}) or 0

					for i = 1, eggsRequired do
						local v11 = i <= v10
						local v12 = clones[i]
						local imageColor

						if v11 then
							imageColor = Color3.new(1, 1, 1)
						else
							imageColor = Color3.fromRGB(134, 134, 134)
						end

						v12.ImageColor3 = imageColor
						clones[i].ImageTransparency = v11 and 0 or 0.58
					end

					local v11 = v:Get({
						"EasterAdminEvent",
						"Seasons",
						season,
						"Purchased",
						v9
					}) or false
					adminEvent.BuyButton.Visible = not v11 and eggsRequired <= v10
				end

				connection = v:OnChange({
					"EasterAdminEvent",
					"Seasons",
					season,
					"Eggs"
				}, update)
				connection2 = v:OnChange({
					"EasterAdminEvent",
					"Seasons",
					season,
					"Purchased",
					limitedKey
				}, update)
				update()
				local v10 = limitedKey

				local function updateStock()
					local v11 = v8:Get({ "Stock", v10 }) or 0
					local v12 = v8:Get({ "InitialStock", v10 }) or 10
					adminEvent.TopRewardFrame.Frame.Fade.Remaining.Text = `{v11}/{v12} Remaining`
					adminEvent.Locked.Visible = v11 <= 0
				end

				local currentIteration2 = getCurrentIteration() -- equivalent call inferred; original call site unknown
				connection3 = v8:OnChange({ "Stock", (`{season}_{currentIteration2}`) }, updateStock)
				updateStock()
			end

			task.wait(2)
		end
	end)
	RunService.Heartbeat:Connect(function()
		local timeElapsed = GetTimeElapsed() -- equivalent call inferred; original call site unknown
		local v9 = (timeElapsed // v6.AdminEvent.IterationTime + 1) * v6.AdminEvent.IterationTime - timeElapsed
		adminEvent.Locked.Timer.Text = `Come back in: {v4:FormatTimeWithDaysFull(v9)}`
	end)
	adminEvent.BuyButton.Activated:Connect(function()
		v2:Invoke("BuyEasterAdminEvent")
	end)
end

return EasterEggAdminEventController