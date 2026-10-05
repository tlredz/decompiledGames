local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
game:GetService("TweenService")
local Players = game:GetService("Players")
require3(ReplicatedStorage2.Packages.Net)
local v = require3(ReplicatedStorage2.Common.Utils)
local v2 = require3(ReplicatedStorage2.Packages.Trove)
local v3 = require3(ReplicatedStorage2.Packages.Replion)
local v4 = require3(ReplicatedStorage2.Packages.Observers)
local v5 = require3(ReplicatedStorage2.Shared.BossPortalData)
local v6 = require3(ReplicatedStorage2.ClientGameModules.FFlagClient)
local v7 = require3(ReplicatedStorage2.ServerInfo)
local v8 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v9 = nil
local v10 = nil
local folder = Instance.new("Folder")
folder.Name = "LobbyPortalStorage"
folder.Parent = ReplicatedStorage2
local LobbyPortalController = {}

function LobbyPortalController:WatchBossPortal(flag: boolean)
	local spawn = workspace:WaitForChild("Spawn")
	return v4.observeTag("BossPortal", function(instance)
		local maid = v2.new()

		if not instance:HasTag("HideSummerGamesEvent") then
			local function updateVisibility()
				if (RunService:IsStudio() or not v6:GetKey("PhoenixBossTestingDisabled")) and v6:GetKey((`{v5.Name}BossEnabled`)) and workspace:GetServerTimeNow() < (v6:GetKey((`{v5.Name}BossEndTime`)) or 0) and flag and (v10:Get("TotalStats.Wins") or 0) >= 1 and not (v7.isLTMServer() or v7.isBossFightServer()) then
					instance.Parent = spawn
				else
					instance.Parent = folder
				end
			end

			maid:Add(v6.DataUpdatedEvent:Connect(updateVisibility))
			maid:Add(v10:OnChange("TotalStats.Wins", updateVisibility))
			task.spawn(updateVisibility)
		end

		local playersText = instance.SurfaceGui.Content:WaitForChild("PlayersText")
		local timerLabel = instance.SurfaceGui.Content:WaitForChild("TimerLabel")

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateMinimumCount()
			local bossPortalPlayerList = v9:Get("BossPortalPlayerList")

			if bossPortalPlayerList then
				if #bossPortalPlayerList >= 1 then
					playersText.Text = `{#bossPortalPlayerList}/16 Players`
				else
					playersText.Text = `{v5.MinPlayersNeeded} Player{v5.MinPlayersNeeded > 1 and "s" or ""} Minimum`
				end
			end
		end

		local v11 = nil
		local v12 = false

		local function updatePortalState()
			local bossPortalState = v9:Get("BossPortalState")
			local bossPortalPlayerList = v9:Get("BossPortalPlayerList")
			local v13 = bossPortalPlayerList and table.find(bossPortalPlayerList, Players.LocalPlayer) ~= nil

			if v13 and not v8:IsOpen("NinjagoSelectPhaseAdventure") and not v12 and bossPortalState ~= "Closed" then
				v12 = true
				v8:Open("NinjagoSelectPhaseAdventure", true)
			elseif not v13 or bossPortalState == "Closed" then
				v12 = false
				v8:Close("NinjagoSelectPhaseAdventure")
			end

			if bossPortalState == "Open" then
				updateMinimumCount() -- equivalent call inferred; original call site unknown

				if v11 ~= "Open" then
					v11 = "Open"
					instance.Misc.Boundary4.Transparency = 0
					instance.Misc.Effects.Decal.Transparency = 0.9
				end
			elseif bossPortalState == "Closed" or bossPortalState == "Failed" or bossPortalState == "Teleporting" then
				if bossPortalState == "Teleporting" then
					playersText.Text = "Teleporting..."
				elseif bossPortalState == "Failed" then
					playersText.Text = "Failed to Start"
				else
					updateMinimumCount() -- equivalent call inferred; original call site unknown
				end

				if v11 ~= "Closed" then
					v11 = "Closed"
					instance.Misc.Boundary4.Transparency = 1
					instance.Misc.Effects.Decal.Transparency = 1
				end
			elseif bossPortalState == "Countdown" then
				v11 = "Countdown"
				playersText.Text = ""
				instance.Misc.Boundary4.Transparency = 1
				instance.Misc.Effects.Decal.Transparency = 1
			end
		end

		local function updateTimer()
			local bossPortalTimeLeft = v9:Get("BossPortalTimeLeft") or 0
			local bossPortalQueueTick = v9:Get("BossPortalQueueTick") or 0
			local bossPortalCountdownTime = v9:Get("BossPortalCountdownTime") or 0
			local serverTimeNow = workspace:GetServerTimeNow()

			if v11 == "Countdown" then
				local v13 = math.max(0, bossPortalCountdownTime - serverTimeNow)
				timerLabel.Text = `BOSS FIGHT\n{not (v13 > 0) and "COMING SOON" or v.ValueConvertor:FormatTimeWithDaysFull(v13)}`
			elseif serverTimeNow - bossPortalQueueTick < v5.QueueTime then
				timerLabel.Text = `QUEUE NOW\n{v.ValueConvertor:FormatTime(v5.QueueTime - (serverTimeNow - bossPortalQueueTick))}`
			else
				timerLabel.Text = `EVENT IN\n{v.ValueConvertor:FormatTime(bossPortalTimeLeft)}`
			end
		end

		maid:Add(v9:OnChange("BossPortalState", updatePortalState))
		maid:Add(v9:OnChange("BossPortalPlayerList", updatePortalState))
		maid:Add(v9:OnChange("BossPortalQueueTick", updateTimer))
		maid:Add(v9:OnChange("BossPortalTimeLeft", updateTimer))
		maid:Add(v9:OnChange("BossPortalCountdownTime", updateTimer))
		maid:Add(v.Thread.Every(1, updateTimer))
		task.spawn(updatePortalState)
		task.spawn(updateTimer)
		return function()
			maid:Destroy()
		end
	end, { spawn, folder })
end

function LobbyPortalController:WatchLTMCrate(p: string, p2: string, _: boolean)
	local spawn = workspace:WaitForChild("Spawn")
	return v4.observeTag(p, function(p3)
		local maid = v2.new()

		local function updateVisibility()
			if v6:GetKey(p2) and v9:Get("LTMCrateEnabled") then
				p3.Parent = spawn
			else
				p3.Parent = folder
			end
		end

		maid:Add(v6.DataUpdatedEvent:Connect(updateVisibility))
		maid:Add(v9:OnChange("LTMCrateEnabled", updateVisibility))
		task.spawn(updateVisibility)
		return function()
			maid:Destroy()
		end
	end, { spawn, folder })
end

function LobbyPortalController:Start()
	v6:WaitForData()
	v9 = v3.Client:WaitReplion("LobbyPortals")
	v10 = v3.Client:WaitReplion("Data")
	local v11 = nil

	local function updateBossPortal()
		if v11 then
			v11()
			v11 = nil
		end

		v11 = self:WatchBossPortal(v9:Get("BossPortalEnabled") and true or false)
	end

	v9:OnChange("BossPortalEnabled", updateBossPortal)
	task.spawn(updateBossPortal)
	local v12 = nil

	local function updateLTMCrate()
		local lTMCrateKey = v9:Get("LTMCrateKey")
		local lTMCrateFFlag = v9:Get("LTMCrateFFlag")

		if v12 then
			v12()
			v12 = nil
		end

		if lTMCrateKey and lTMCrateFFlag then
			v12 = self:WatchLTMCrate(lTMCrateKey, lTMCrateFFlag)
		end
	end

	v9:OnChange("LTMCrateKey", updateLTMCrate)
	v9:OnChange("LTMCrateFFlag", updateLTMCrate)
	v9:OnChange("LTMCrateEnabled", updateLTMCrate)
	task.spawn(updateLTMCrate)
end

return LobbyPortalController