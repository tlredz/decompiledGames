local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local AreaEggCycle = require(ReplicatedStorage.Shared.Util.AreaEggCycle)
local AreaEggResetCycle = require(ReplicatedStorage.Data.AreaEggResetCycle)
local EggState = require(ReplicatedStorage.Client.EggState)
local Time = require(ReplicatedStorage.Shared.Utils.Time)
local elapsed = Time.Elapsed
local GUI = require(ReplicatedStorage.Client.GUI)
local Hud = require(ReplicatedStorage.Client.Hud)
local Player = require(ReplicatedStorage.Shared.Player)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Sakura = require(ReplicatedStorage.Data.Sakura)
local SakuraBloomPolicy = require(ReplicatedStorage.Client.Modules.SakuraBloomPolicy)
local Save = require(ReplicatedStorage.Shared.Save)
local color = Color3.fromRGB(255, 64, 64)
return {
	Start = function()
		local screenGui = GUI.TutorialInstructions()
		assert(screenGui:IsA("ScreenGui"), "TutorialInstructions must be a ScreenGui")
		local every = Hud.Every("NightTimer")
		local nightTimerValue = Hud.Get("NightTimerValue")
		local nightTimerIcon = Hud.Get("NightTimerIcon")
		local v = Hud.Find("NightTimerValue", "Treadmill")
		local v2 = Hud.Find("NightTimerIcon", "Treadmill")
		local image = nightTimerIcon.Image
		local v3 = v2 == nil and "" or v2.Image
		local textColor3 = nightTimerValue.TextColor3
		local v4 = -1
		local v5 = false
		local periodIndexAt = AreaEggCycle.PeriodIndexAt(Workspace:GetServerTimeNow())
		local v6 = false
		local v7 = false
		local enabled = screenGui.Enabled
		local isRunning = AreaEggCycle.IsRunning()
		local isCarrying = false
		local v8 = false
		local enabled2 = screenGui.Enabled
		local localPlayer = Players.LocalPlayer
		local bounds = Workspace:WaitForChild("World"):WaitForChild("Areas"):WaitForChild("CherryBlossom"):WaitForChild("Bounds")
		assert(bounds:IsA("BasePart"), "CherryBlossom.Bounds must be a BasePart")

		local function getBlinkColor(p: number, flag: boolean, color2: Color3)
			if flag or not (AreaEggCycle.IsInFinalBlink(p) and AreaEggCycle.IsBlinkOnRedFrame(p)) then
				return color2
			end

			return color
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setNightTimerVisible(visible: boolean)
			for _, v9 in every do
				v9.Visible = visible
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setTimer(text: string, textColor: Color3)
			setNightTimerVisible(true) -- equivalent call inferred; original call site unknown
			nightTimerValue.Text = text
			nightTimerValue.TextColor3 = textColor

			if v ~= nil then
				v.Text = text
				v.TextColor3 = textColor
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setNormalTimer(p: number, isNightPhase: boolean, text: string)
			local v9 = textColor3

			if not isNightPhase and AreaEggCycle.IsInFinalBlink(p) and AreaEggCycle.IsBlinkOnRedFrame(p) then
				v9 = color
			end

			setTimer(text, v9) -- equivalent call inferred; original call site unknown
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setEndingSoonTimer(p: number, isNightPhase: boolean, text: string)
			local v9 = color

			if not isNightPhase and AreaEggCycle.IsInFinalBlink(p) and AreaEggCycle.IsBlinkOnRedFrame(p) then
				v9 = color
			end

			setTimer(text, v9) -- equivalent call inferred; original call site unknown
		end

		local function isInsideCherryBlossom()
			local primaryPart = Player.FindPrimaryPart(localPlayer)

			if primaryPart == nil then
				return false
			end

			local pointToObjectSpace = bounds.CFrame:PointToObjectSpace(primaryPart.Position)
			return math.abs(pointToObjectSpace.X) <= bounds.Size.X / 2 and math.abs(pointToObjectSpace.Z) <= bounds.Size.Z / 2
		end

		local function isBloomUnlocked()
			local isLoaded = Save.IsLoaded()
			local v9

			if isLoaded then
				v9 = Save.Peek()
			end

			return SakuraBloomPolicy.HasBloomUnlocked(isLoaded, v9)
		end

		local function refreshTimer(flag: boolean?)
			local isRunning2 = AreaEggCycle.IsRunning()

			if isRunning2 ~= isRunning then
				isRunning = isRunning2
				flag = true
			end

			if isRunning2 then
				local serverTimeNow = Workspace:GetServerTimeNow()
				local activePeriodIndexAt = AreaEggCycle.ActivePeriodIndexAt(serverTimeNow)
				local isNightPhase = AreaEggCycle.IsNightPhase(serverTimeNow)
				local v9 = math.ceil((AreaEggCycle.SecondsUntilPhaseEnd(serverTimeNow)))
				local attribute = Workspace:GetAttribute(Sakura.Bloom.EndsAtAttribute)
				local isLoaded = Save.IsLoaded()
				local v10

				if isLoaded then
					v10 = Save.Peek()
				end

				local hasBloomUnlocked = SakuraBloomPolicy.HasBloomUnlocked(isLoaded, v10)

				if hasBloomUnlocked then
					if typeof(attribute) == "number" and serverTimeNow < attribute then
						hasBloomUnlocked = isInsideCherryBlossom()
					else
						hasBloomUnlocked = false
					end
				end

				local v11

				if hasBloomUnlocked then
					v11 = math.ceil(attribute - serverTimeNow)
				else
					v11 = v9
				end

				if not flag and v11 == v4 and hasBloomUnlocked == v5 and activePeriodIndexAt == periodIndexAt and isCarrying == v6 and v8 == v7 and enabled2 == enabled then
					return
				end

				v4 = v11
				v5 = hasBloomUnlocked
				periodIndexAt = activePeriodIndexAt
				v6 = isCarrying
				v7 = v8
				enabled = enabled2
				local sunIcon

				if isNightPhase then
					sunIcon = AreaEggResetCycle.SunIcon
				else
					sunIcon = Workspace:GetAttribute("NightIconOverride") or AreaEggResetCycle.MoonIcon
				end

				local v12 = "in " .. elapsed(v9)

				if hasBloomUnlocked then
					v12 = "ends in " .. elapsed(v11)
					sunIcon = "rbxassetid://71612969542341"
				end

				local v13 = nightTimerIcon
				local image2

				if sunIcon == "" then
					image2 = image
				else
					image2 = sunIcon
				end

				v13.Image = image2

				if v2 ~= nil then
					local v15 = v2

					if sunIcon == "" then
						if v3 == "" then
							sunIcon = image
						else
							sunIcon = v3
						end
					end

					v15.Image = sunIcon
				end

				if hasBloomUnlocked or isNightPhase or not AreaEggCycle.IsCloseToReset(v9) or isCarrying or v8 or enabled2 then
					setNormalTimer(v9, isNightPhase, v12) -- equivalent call inferred; original call site unknown
				else
					setEndingSoonTimer(v9, isNightPhase, v12) -- equivalent call inferred; original call site unknown
				end
			else
				setNightTimerVisible(false) -- equivalent call inferred; original call site unknown
			end
		end

		refreshTimer()
		EggState.CarryChanged:Connect(function(p)
			isCarrying = p.IsCarrying
			refreshTimer(true)
		end)
		Remotes.Treadmill.AssignedBeltShifted.OnClientEvent:Connect(function(p: string?)
			v8 = p ~= nil
			refreshTimer(true)
		end)
		screenGui:GetPropertyChangedSignal("Enabled"):Connect(function()
			enabled2 = screenGui.Enabled
			refreshTimer(true)
		end)
		Save.WatchFields("Sakura", function()
			refreshTimer(true)
		end)
		RunService.Heartbeat:Connect(function(_: number)
			refreshTimer()
		end)
	end
}