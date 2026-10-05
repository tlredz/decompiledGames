local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local AdminBoosts = require(ReplicatedStorage.Shared.Util.AdminBoosts)
require(ReplicatedStorage.Shared.Types.AreaEggs)
local BossMasteryFlags = require(ReplicatedStorage.Shared.Flags.BossMasteryFlags)
local EggState = require(ReplicatedStorage.Client.EggState)
local Time = require(ReplicatedStorage.Shared.Utils.Time)
local elapsed = Time.Elapsed
local Hud = require(ReplicatedStorage.Client.Hud)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Save = require(ReplicatedStorage.Shared.Save)
local Preferences = require(ReplicatedStorage.Shared.Preferences)
local SpeedGainPopup = require(ReplicatedStorage.Client.UI.VFX.SpeedGainPopup)
local SpeedPowerProjection = require(ReplicatedStorage.Client.SpeedPowerProjection)
local Trails = require(ReplicatedStorage.Data.Trails)
local TreadmillCharacterPresentationController = require(script.Parent.Parent.Game.Plots.TreadmillCharacterPresentationController)
local Visibility = require(script.Visibility)
local TreadmillUtil = require(ReplicatedStorage.Shared.Util.TreadmillUtil)
local TreadmillVideoController = require(ReplicatedStorage.Shared.TreadmillVideoController)
local TreadmillVideoGate = require(ReplicatedStorage.Client.TreadmillVideoGate)
require(ReplicatedStorage.Shared.TreadmillVideoController.Types.Interface)
local Treadmills = require(ReplicatedStorage.Data.Treadmills)
return {
	Start = function()
		local speedValue = Hud.Get("SpeedValue")
		local v = Hud.Find("SpeedValue", "Treadmill")
		local v2 = Hud.Find("SpeedMultiShine", "Treadmill")
		local textColor3 = speedValue.TextColor3
		local v3 = Hud.Find("TemporarySpeedBoost")
		local currentBoost

		if v3 == nil then
			currentBoost = nil
		else
			currentBoost = v3:FindFirstChild("CurrentBoost")
		end

		local v4 = false
		local v5 = nil
		local count = 0
		local count2 = 0
		local v6 = nil
		local speedMultiplier = 1

		-- equivalent calls inferred from this helper; original call sites unknown
		local function visibleSpeedLabel()
			if v5 == nil or v == nil then
				return speedValue
			end

			return v
		end

		local function updateSpeedPower()
			local v7 = Save.Await()

			if not v7 then
				return
			end

			local projected = SpeedPowerProjection.ReadProjected()
			local v8 = TreadmillUtil.ResolveEffectiveSpeedPower(projected, speedMultiplier) * AdminBoosts.ReadMultiplier(AdminBoosts.SPEED)
			local formatSpeedPower = TreadmillUtil.FormatSpeedPower((math.floor(v8)))
			local speedBoostSpeedStepMultiplier = TreadmillUtil.ResolveSpeedBoostSpeedStepMultiplier(v7)
			local speedNumberColor = textColor3
			local equippedTrail = v7.EquippedTrail

			if equippedTrail ~= nil and Trails.TrailNameExists(equippedTrail) and v7.TrailInventory[equippedTrail] then
				local v9 = Trails.Directory[equippedTrail]
				speedNumberColor = v9.SpeedNumberColor or v9.Rarity.Color
			end

			if v5 ~= nil and TreadmillUtil.DEFAULT_SPEED_STEP_MULTIPLIER < speedBoostSpeedStepMultiplier then
				formatSpeedPower ..= ` <font color="#00FF00">({TreadmillUtil.FormatSpeedMultiplierValue(speedBoostSpeedStepMultiplier)})</font>`
			end

			speedValue.Text = formatSpeedPower
			speedValue.TextColor3 = speedNumberColor

			if v ~= nil then
				v.Text = formatSpeedPower
				v.TextColor3 = speedNumberColor
			end
		end

		local function updateTemporarySpeedBoostDisplay()
			local v7 = Save.Await()
			local temporarySpeedBoostRemainingSeconds = TreadmillUtil.ResolveTemporarySpeedBoostRemainingSeconds(
				v7,
				Workspace:GetServerTimeNow()
			)

			if v3 == nil or currentBoost == nil then
				return temporarySpeedBoostRemainingSeconds > 0
			end

			if temporarySpeedBoostRemainingSeconds <= 0 then
				v3.Visible = false
				return false
			end

			v3.Visible = true
			currentBoost.Text = `X{BossMasteryFlags.TreadmillBoostMultiplier:Get()} Treadmill Boost ({elapsed(temporarySpeedBoostRemainingSeconds)})`
			return true
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function startTemporarySpeedBoostCountdown()
			count2 += 1
			local v7 = count2

			if not updateTemporarySpeedBoostDisplay() then
				return
			end

			task.spawn(function()
				while v7 == count2 do
					task.wait(1)

					if updateTemporarySpeedBoostDisplay() then
						updateSpeedPower()
					else
						updateSpeedPower()
						break
					end
				end
			end)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function stopActiveTreadmillVisualSimulation()
			local v7 = v6

			if v7 ~= nil then
				SpeedPowerProjection.CloseSession(v7.Token)
			end

			count += 1
			v6 = nil
		end

		local function applyTreadmillVideoSetting(p)
			local v7 = v5

			if v7 == nil or Preferences.IsOn("DisableVideos") or TreadmillVideoGate.IsVideoPlayerDisabled() then
				TreadmillVideoController.Stop()
				return
			end

			if p ~= nil then
				TreadmillVideoController.Start(v7, p)
				return
			end

			local v8 = Save.Await()
			assert(v8 ~= nil, "Save data must be loaded before enabling treadmill videos")
			TreadmillVideoController.Start(v7, v8.TreadmillMediaFeedState)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function resolveCurrentSpeedPowerPerStep(speedMultiplier2: number, nextSpeedAwardAt: number)
			return TreadmillUtil.ResolveSpeedPowerPerStep(Save.Await(), speedMultiplier2, nextSpeedAwardAt)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function flushPendingScreenSpeedGain(state)
			if state.PendingScreenSpeedPowerDelta <= 0 then
				return
			end

			local pendingScreenSpeedPowerDelta = state.PendingScreenSpeedPowerDelta
			local play = SpeedGainPopup.Play
			local v7 = visibleSpeedLabel() -- equivalent call inferred; original call site unknown
			play(v7, pendingScreenSpeedPowerDelta, nil, function()
				SpeedPowerProjection.CreditRevealedGain(state.Token, pendingScreenSpeedPowerDelta)
			end)
			state.PendingScreenSpeedPowerDelta = 0
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function resetNextScreenPopupAt(state, p: number)
			state.NextScreenPopupAt = p + TreadmillUtil.TREADMILL_SPEED_GAIN_INTERVAL
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function handleTransparentModeSpeedGainPulse(state, currentSpeedPowerPerStep: number, serverTimeNow: number)
			state.PendingScreenSpeedPowerDelta += currentSpeedPowerPerStep

			if state.NextScreenPopupAt <= serverTimeNow then
				flushPendingScreenSpeedGain(state) -- equivalent call inferred; original call site unknown
				resetNextScreenPopupAt(state, serverTimeNow) -- equivalent call inferred; original call site unknown
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function handleVisibleModeSpeedGainPulse(state, currentSpeedPowerPerStep: number, serverTimeNow: number)
			state.PendingScreenSpeedPowerDelta = 0
			resetNextScreenPopupAt(state, serverTimeNow) -- equivalent call inferred; original call site unknown
			local playWalk = SpeedGainPopup.PlayWalk
			local v7 = visibleSpeedLabel() -- equivalent call inferred; original call site unknown
			playWalk(v7, currentSpeedPowerPerStep, state.RarityColor, function()
				SpeedPowerProjection.CreditRevealedGain(state.Token, currentSpeedPowerPerStep)
			end)
		end

		local function handleServerSpeedGain(p: number, p2: string)
			if p2 == "Treadmill" and v6 ~= nil then
				return
			end

			if p2 == "Instant" and v6 ~= nil then
				local v7 = v6
				v7.SimulatedSpeedPower += p
				assert(
					SpeedPowerProjection.CreditRevealedGain(v7.Token, p),
					"Instant Speed Power gain must target the active treadmill projection"
				)
				local play = SpeedGainPopup.Play
				local v8 = visibleSpeedLabel() -- equivalent call inferred; original call site unknown
				play(v8, p, nil, updateSpeedPower)
			else
				updateSpeedPower()

				if p2 == "Walk" then
					local playWalk = SpeedGainPopup.PlayWalk
					local v7 = visibleSpeedLabel() -- equivalent call inferred; original call site unknown
					playWalk(v7, p, nil, updateSpeedPower)
				else
					local play = SpeedGainPopup.Play
					local v7 = visibleSpeedLabel() -- equivalent call inferred; original call site unknown
					play(v7, p, nil, updateSpeedPower)
				end
			end
		end

		local function startActiveTreadmillVisualSimulation(speedMultiplier2: number, value2: number, color: Color3)
			stopActiveTreadmillVisualSimulation() -- equivalent call inferred; original call site unknown
			local serverTimeNow = Workspace:GetServerTimeNow()
			local v7 = Save.Await()
			assert(v7 ~= nil, "Save data must be loaded before starting treadmill simulation")
			local token = count
			v6 = {
				NextScreenPopupAt = serverTimeNow + TreadmillUtil.TREADMILL_SPEED_GAIN_INTERVAL,
				NextSpeedAwardAt = value2,
				PendingScreenSpeedPowerDelta = 0,
				RarityColor = color,
				SimulatedSpeedPower = TreadmillUtil.NormalizeSpeedPower(v7.SpeedPower),
				SpeedMultiplier = speedMultiplier2,
				Token = token
			}
			SpeedPowerProjection.OpenSession(token)
			task.spawn(function()
				while true do
					local v9 = v6

					if v9 == nil or v9.Token ~= token then
						break
					end

					local serverTimeNow2 = Workspace:GetServerTimeNow()
					local v10 = math.max(v9.NextSpeedAwardAt - serverTimeNow2, 0)

					if v10 > 0 then
						task.wait(v10)
					end

					local v11 = v6

					if v11 == nil or v11.Token ~= token then
						break
					end

					while true do
						local serverTimeNow3 = Workspace:GetServerTimeNow()

						if serverTimeNow3 < v11.NextSpeedAwardAt then
							break
						end

						local nextSpeedAwardAt = v11.NextSpeedAwardAt
						local currentSpeedPowerPerStep = resolveCurrentSpeedPowerPerStep(
							v11.SpeedMultiplier,
							nextSpeedAwardAt
						) -- equivalent call inferred; original call site unknown
						v11.SimulatedSpeedPower += currentSpeedPowerPerStep

						if TreadmillCharacterPresentationController.IsLocalCharacterFullyTransparent() then
							handleTransparentModeSpeedGainPulse(v11, currentSpeedPowerPerStep, serverTimeNow3) -- equivalent call inferred; original call site unknown
						else
							handleVisibleModeSpeedGainPulse(v11, currentSpeedPowerPerStep, serverTimeNow3) -- equivalent call inferred; original call site unknown
						end

						v11 = v6

						if v11 == nil or v11.Token ~= token then
							return
						end

						local speedPowerToProgressionWalkSpeed = TreadmillUtil.SpeedPowerToProgressionWalkSpeed(v11.SimulatedSpeedPower)
						v11.NextSpeedAwardAt = nextSpeedAwardAt + TreadmillUtil.ResolveWalkSpeedPowerAwardInterval(speedPowerToProgressionWalkSpeed)
					end
				end
			end)
		end

		EggState.CarryChanged:Connect(function(p)
			speedMultiplier = p.SpeedMultiplier
			updateSpeedPower()
		end)
		Save.Await()
		SpeedGainPopup.HideSource()
		TreadmillVideoController.Stop()
		TreadmillCharacterPresentationController.StopCameraTransparency()
		updateSpeedPower()
		count2 += 1
		local v7 = count2

		if updateTemporarySpeedBoostDisplay() then
			task.spawn(function()
				while v7 == count2 do
					task.wait(1)

					if updateTemporarySpeedBoostDisplay() then
						updateSpeedPower()
					else
						updateSpeedPower()
						break
					end
				end
			end)
		end

		if v2 ~= nil then
			RunService.RenderStepped:Connect(function(dt: number)
				v2.Rotation = (v2.Rotation + dt * 20) % 360
			end)
		end

		SpeedPowerProjection.Changed:Connect(updateSpeedPower)
		Save.WatchFields("SpeedBoostTierIndex", updateSpeedPower)
		Save.WatchFields({ "EquippedTrail", "TrailInventory" }, updateSpeedPower)
		AdminBoosts.Observe(AdminBoosts.SPEED):Connect(updateSpeedPower)
		BossMasteryFlags.TreadmillBoostMultiplier.Changed:Connect(function()
			updateSpeedPower()
			updateTemporarySpeedBoostDisplay()
		end)
		Save.WatchFields("TemporarySpeedBoostRemainingSeconds", function()
			updateSpeedPower()
			startTemporarySpeedBoostCountdown() -- equivalent call inferred; original call site unknown
		end)
		Save.WatchFields("TemporarySpeedBoostActiveStartedAt", function()
			updateSpeedPower()
			startTemporarySpeedBoostCountdown() -- equivalent call inferred; original call site unknown
		end)
		Remotes.Treadmill.SpeedGained.OnClientEvent:Connect(handleServerSpeedGain)
		local isOn = Preferences.IsOn("DisableVideos")
		Preferences.Observe("DisableVideos", function(flag: boolean)
			if flag == isOn then
				return
			end

			isOn = flag
			local v8 = v5

			if v8 == nil or Preferences.IsOn("DisableVideos") or TreadmillVideoGate.IsVideoPlayerDisabled() then
				TreadmillVideoController.Stop()
				return
			end

			local v9 = Save.Await()
			assert(v9 ~= nil, "Save data must be loaded before enabling treadmill videos")
			TreadmillVideoController.Start(v8, v9.TreadmillMediaFeedState)
		end)
		TreadmillVideoGate.Changed:Connect(function()
			local v8 = v5

			if v8 == nil or Preferences.IsOn("DisableVideos") or TreadmillVideoGate.IsVideoPlayerDisabled() then
				TreadmillVideoController.Stop()
				return
			end

			local v9 = Save.Await()
			assert(v9 ~= nil, "Save data must be loaded before enabling treadmill videos")
			TreadmillVideoController.Start(v8, v9.TreadmillMediaFeedState)
		end)
		Remotes.Treadmill.AssignedBeltShifted.OnClientEvent:Connect(function(p: string?, speedMultiplier2: number?, value2: number?, p2)
			v5 = p
			v4 = false

			if p == nil then
				stopActiveTreadmillVisualSimulation() -- equivalent call inferred; original call site unknown
				updateSpeedPower()
				TreadmillVideoController.Stop()
				TreadmillCharacterPresentationController.StopCameraTransparency()
				Visibility.Apply(false)
			else
				assert(typeof(speedMultiplier2) == "number", "Active treadmill speed multiplier must be a number")
				assert(typeof(value2) == "number", "Active treadmill next award time must be a number")
				assert(typeof(p2) == "table", "Active treadmill media feed state must be a table")
				local treadmillNameExists, v8 = Treadmills.TreadmillNameExists(p)
				assert(treadmillNameExists, v8 or `Treadmill "{p}" does not exist`)
				local color = Treadmills.Directory[p].Rarity.Color
				updateSpeedPower()
				Visibility.Apply(true)
				startActiveTreadmillVisualSimulation(speedMultiplier2, value2, color)
				TreadmillCharacterPresentationController.StartCameraTransparency(p)
				applyTreadmillVideoSetting(p2)
			end
		end)
		UserInputService.JumpRequest:Connect(function()
			if v5 == nil or v4 then
				return
			end

			v4 = true

			if Remotes.Treadmill.AskDoff:InvokeServer() ~= true then
				v4 = false
			end
		end)
	end
}