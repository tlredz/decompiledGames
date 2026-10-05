local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local AreaEggCycle = require(ReplicatedStorage.Shared.Util.AreaEggCycle)
local AreaEggResetCycle = require(ReplicatedStorage.Data.AreaEggResetCycle)
require(ReplicatedStorage.Shared.Types.AreaEggResetCycle)
local Audio = require(ReplicatedStorage.Shared.Audio)
local SystemChat = require(ReplicatedStorage.Client.SystemChat)
local EggState = require(ReplicatedStorage.Client.EggState)
local GUI = require(ReplicatedStorage.Client.GUI)
local Log = require(ReplicatedStorage.Packages.Log)
local Notifications = require(ReplicatedStorage.Client.Notifications)
local Preload = require(ReplicatedStorage.Shared.Utils.Preload)
local warmSounds = Preload.WarmSounds
local AreaEggResetWall = require(ReplicatedStorage.Client.AreaEggResetWall)
local tweenInfo = TweenInfo.new(0.55, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
local teleportFadeSeconds = AreaEggResetCycle.TeleportFadeSeconds
local teleportFadeHoldSeconds = AreaEggResetCycle.TeleportFadeHoldSeconds
local tweenInfo2 = TweenInfo.new(teleportFadeSeconds, Enum.EasingStyle.Linear)
local tweenInfo3 = TweenInfo.new(AreaEggResetCycle.SleepIconFadeSeconds, Enum.EasingStyle.Quad)
local tweenInfo4 = TweenInfo.new(AreaEggResetCycle.NightIconFadeOutSeconds, Enum.EasingStyle.Quad)
local v = Log.new()
return {
	Start = function()
		local fadeFrame = GUI.FadeFrame()
		local v2 = GUI.ResetStartTimer()
		local textLabel = v2.Frame.TextLabel
		local nightTimer = v2.Frame.NightTimer
		local uIStroke = nightTimer.UIStroke
		local sleepIcon = v2.Frame.SleepIcon
		local v3 = GUI.ResetStartTimerLabelScale()
		local count = 0
		local v4 = nil
		local count2 = 0
		local v5 = nil
		local v6 = nil
		local v7 = nil
		local v8 = nil
		local dayStartsAt = nil
		local dayStartsAt2 = -1e999
		local periodIndex = -1
		v2.Adornee = AreaEggResetWall.ResolveWallPart()
		task.spawn(warmSounds, 117751546358455, 136029417452204)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function stopActiveTween()
			if v4 ~= nil then
				v4:Cancel()
				v4 = nil
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function stopActiveFadeTween()
			if v5 ~= nil then
				v5:Cancel()
				v5 = nil
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function stopActiveNightVisualTweens()
			if v6 ~= nil then
				v6:Cancel()
				v6 = nil
			end

			if v7 ~= nil then
				v7:Cancel()
				v7 = nil
			end

			if v8 ~= nil then
				v8:Cancel()
				v8 = nil
			end
		end

		local function tweenFadeFrame(p: number, backgroundTransparency: number)
			stopActiveFadeTween() -- equivalent call inferred; original call site unknown
			local tween = TweenService:Create(fadeFrame, tweenInfo2, {
				BackgroundTransparency = backgroundTransparency
			})
			v5 = tween
			tween:Play()
			tween.Completed:Wait()

			if p ~= count2 then
				return false
			end

			v5 = nil
			return true
		end

		local function runTeleportFade(p: number)
			if not tweenFadeFrame(p, 0) then
				return
			end

			task.wait(teleportFadeHoldSeconds)

			if p ~= count2 then
				return
			end

			tweenFadeFrame(p, 1)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setCountdownVisible(visible: boolean)
			textLabel.Visible = visible
		end

		local function tweenNightVisuals(p: number, p2: number)
			stopActiveNightVisualTweens() -- equivalent call inferred; original call site unknown
			local v9

			if p2 == 1 then
				v9 = tweenInfo4
			else
				v9 = tweenInfo3
			end

			local tween = TweenService:Create(sleepIcon, v9, {
				ImageTransparency = p2
			})
			local tween2 = TweenService:Create(nightTimer, v9, {
				TextTransparency = p2
			})
			local tween3 = TweenService:Create(uIStroke, v9, {
				Transparency = p2
			})
			v6 = tween
			v7 = tween2
			v8 = tween3
			tween:Play()
			tween2:Play()
			tween3:Play()
			tween.Completed:Wait()

			if p ~= count then
				return false
			end

			v6 = nil
			v7 = nil
			v8 = nil
			return true
		end

		local function animateCount(i: number)
			stopActiveTween() -- equivalent call inferred; original call site unknown
			textLabel.Text = tostring(i)
			v3.Scale = 1.3
			local tween = TweenService:Create(v3, tweenInfo, {
				Scale = 1
			})
			v4 = tween
			tween:Play()
		end

		local function announceRareSpawns(rareSpawns)
			for _, v9 in ipairs(rareSpawns) do
				SystemChat.Post({
					Text = v9.Message
				})
				Notifications.Toast.Show({
					Lane = "Banner",
					Text = v9.Message,
					Color = Color3.new(1, 1, 1),
					Seconds = 4,
					Sound = v9.SoundId
				})
			end

			EggState.RarityPresented:Fire(rareSpawns)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function handleRareSpawnReveal(p)
			if p.PeriodIndex <= periodIndex then
				return
			end

			periodIndex = p.PeriodIndex
			announceRareSpawns(p.RareSpawns)
		end

		local requestJoinRareSpawnPresentations

		requestJoinRareSpawnPresentations = function(p: number)
			local rarityShows, v9 = EggState.FetchRarityShows()

			if rarityShows then
				if v9 ~= nil then
					handleRareSpawnReveal(v9) -- equivalent call inferred; original call site unknown
				end
			elseif p >= 30 then
				v:AtError():Log("Area egg rare spawn join presentation request exhausted profile-readiness retries")
			else
				task.delay(1, function()
					requestJoinRareSpawnPresentations(p + 1)
				end)
			end
		end

		local function runCountdown(p: number, p2)
			AreaEggResetWall.ArmReveal()
			v2.Enabled = true
			setCountdownVisible(false) -- equivalent call inferred; original call site unknown
			task.spawn(AreaEggResetWall.RaiseWall)
			nightTimer.Text = `{math.max(math.ceil(p2.DayStartsAt - Workspace:GetServerTimeNow()), 1)}s`

			if not tweenNightVisuals(p, 0) then
				return
			end

			while true do
				local serverTimeNow = Workspace:GetServerTimeNow()
				local v9 = p2.DayStartsAt - serverTimeNow

				if v9 <= 0 then
					break
				end

				local v10 = math.ceil(v9)
				nightTimer.Text = `{v10}s`
				local v11 = p2.DayStartsAt - (v10 - 1)
				task.wait((math.max(v11 - serverTimeNow, 0.05)))

				if p ~= count then
					return
				end
			end

			if not tweenNightVisuals(p, 1) then
				return
			end

			local v9 = p2.DayStartsAt + AreaEggResetCycle.WallCountdownDelayAfterDayStartsSeconds
			task.wait((math.max(v9 - Workspace:GetServerTimeNow(), 0)))

			if p ~= count then
				return
			end

			Notifications.Toast.Show({
				Lane = "Banner",
				Text = "ALL EGG RESET!",
				Seconds = 3.5
			})
			local wallPart = AreaEggResetWall.ResolveWallPart()
			local v10 = wallPart.Position + wallPart.CFrame.LookVector * (wallPart.Size.Z / 2)

			for i = AreaEggResetCycle.WallCountdownSeconds, 1, -1 do
				if p ~= count then
					return
				end

				Audio.Play(117751546358455, v10, {
					Volume = 2,
					MaxDistance = 220
				})
				animateCount(i)

				if i == AreaEggResetCycle.WallCountdownSeconds then
					setCountdownVisible(true) -- equivalent call inferred; original call site unknown
				end

				task.wait(1)
			end

			if p == count then
				stopActiveTween() -- equivalent call inferred; original call site unknown
				v3.Scale = 1
				Audio.Play(136029417452204, v10, {
					Volume = 1.5,
					MaxDistance = 220
				})
				setCountdownVisible(false) -- equivalent call inferred; original call site unknown
				AreaEggResetWall.DropWall()

				if p ~= count then
					return
				end

				v2.Enabled = false
				dayStartsAt2 = p2.DayStartsAt
				dayStartsAt = nil
			end
		end

		local function startSequence(p)
			if p.DayStartsAt <= dayStartsAt2 then
				return
			end

			local v9 = dayStartsAt

			if v9 ~= nil and p.DayStartsAt < v9 or p.DayStartsAt == v9 then
				return
			end

			dayStartsAt = p.DayStartsAt
			count += 1
			local v10 = count
			task.spawn(runCountdown, v10, p)
		end

		v:AtDebug():Log("Reset start timer controller initialized")
		v2.Enabled = false
		setCountdownVisible(false) -- equivalent call inferred; original call site unknown
		sleepIcon.ImageTransparency = 1
		nightTimer.TextTransparency = 1
		uIStroke.Transparency = 1
		AreaEggResetWall.ClearWall()
		EggState.ResetFade:Connect(function()
			count2 += 1
			local v9 = count2
			task.spawn(runTeleportFade, v9)
		end)
		EggState.ResetCountdown:Connect(startSequence)
		EggState.RarityRevealed:Connect(handleRareSpawnReveal)
		task.spawn(requestJoinRareSpawnPresentations, 1)
		Workspace:GetAttributeChangedSignal("NightIconOverride"):Connect(function()
			sleepIcon.Image = Workspace:GetAttribute("NightIconOverride") or "rbxassetid://123238464128459"
		end)
		sleepIcon.Image = Workspace:GetAttribute("NightIconOverride") or "rbxassetid://123238464128459"

		if AreaEggCycle.IsNightPhase(Workspace:GetServerTimeNow()) then
			local v9 = {
				DayStartsAt = AreaEggCycle.NextResetTime(Workspace:GetServerTimeNow())
			}

			if not (v9.DayStartsAt <= dayStartsAt2) then
				local v10 = dayStartsAt

				if (v10 == nil or not (v9.DayStartsAt < v10)) and v9.DayStartsAt ~= v10 then
					dayStartsAt = v9.DayStartsAt
					count += 1
					local v11 = count
					task.spawn(runCountdown, v11, v9)
				end
			end
		end
	end
}