local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Constants = require(ReplicatedStorage.Shared.Globals.Constants)
local Hud = require(ReplicatedStorage.Client.Hud)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Save = require(ReplicatedStorage.Shared.Save)
local color = Color3.fromRGB(0, 255, 0)
local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local localPlayer = Players.LocalPlayer
return {
	Start = function()
		local slowToggle = Hud.Get("SlowToggle")
		local slowToggleKnob = Hud.Get("SlowToggleKnob")
		local slowToggleHitbox = Hud.Get("SlowToggleHitbox")
		local backgroundColor3 = slowToggle.BackgroundColor3
		local Y = slowToggleKnob.Position.Y
		local v = false
		local BASE_WALK_SPEED = Constants.BASE_WALK_SPEED
		local v2 = nil
		local v3 = nil
		local walkSpeedChangedConnection = nil

		local function setToggleVisuals(flag: boolean)
			local v4 = slowToggle
			local backgroundColor

			if flag then
				backgroundColor = color
			else
				backgroundColor = backgroundColor3
			end

			v4.BackgroundColor3 = backgroundColor
			TweenService:Create(slowToggleKnob, tweenInfo, {
				Position = UDim2.new(flag and 0.615 or 0.05, 0, Y.Scale, Y.Offset)
			}):Play()
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function reconcileSlowToggleState(flag: boolean)
			v = flag
			setToggleVisuals(flag)
		end

		local function updateSlowToggleVisibility(p: number)
			local visible

			if v2 == nil then
				visible = v or p > 50
			else
				visible = false
			end

			slowToggle.Visible = visible
			return visible
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function resolveVisibleWalkSpeed()
			local v4 = v3

			if v4 == nil or v4.Parent == nil or not (v4.Health > 0) then
				return BASE_WALK_SPEED
			end

			return v4.WalkSpeed
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function refreshVisibilityFromCurrentWalkSpeed()
			local visibleWalkSpeed = resolveVisibleWalkSpeed() -- equivalent call inferred; original call site unknown
			slowToggle.Visible = v2 == nil and (v or visibleWalkSpeed > 50)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function applyServerSlowToggleState(flag: boolean, p: number)
			BASE_WALK_SPEED = p
			reconcileSlowToggleState(flag) -- equivalent call inferred; original call site unknown
			refreshVisibilityFromCurrentWalkSpeed() -- equivalent call inferred; original call site unknown
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function syncSlowToggleStateFromServer()
			local v4, v5 = Remotes.Treadmill.AskSlowToggle:InvokeServer()
			assert(typeof(v4) == "boolean", "Expected slow-toggle enabled state from server")
			assert(typeof(v5) == "number", "Expected slow-toggle restored walk speed from server")
			applyServerSlowToggleState(v4, v5) -- equivalent call inferred; original call site unknown
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setSlowToggleEnabled(flag: boolean)
			local v4, v5 = Remotes.Treadmill.AskSlowToggleSet:InvokeServer(flag)
			assert(typeof(v4) == "boolean", "Expected slow-toggle enabled state from server")
			assert(typeof(v5) == "number", "Expected slow-toggle restored walk speed from server")
			applyServerSlowToggleState(v4, v5) -- equivalent call inferred; original call site unknown
		end

		local function bindHumanoid(humanoid)
			if walkSpeedChangedConnection ~= nil then
				walkSpeedChangedConnection:Disconnect()
				walkSpeedChangedConnection = nil
			end

			v3 = humanoid
			walkSpeedChangedConnection = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
				refreshVisibilityFromCurrentWalkSpeed() -- equivalent call inferred; original call site unknown
			end)
			refreshVisibilityFromCurrentWalkSpeed() -- equivalent call inferred; original call site unknown
		end

		local function connectCharacter(instance)
			bindHumanoid(instance:WaitForChild("Humanoid"))
			syncSlowToggleStateFromServer() -- equivalent call inferred; original call site unknown
		end

		slowToggleHitbox.Activated:Connect(function()
			setSlowToggleEnabled(not v) -- equivalent call inferred; original call site unknown
		end)

		if Save.IsLoaded() then
			syncSlowToggleStateFromServer() -- equivalent call inferred; original call site unknown
		else
			Save.Loaded:Connect(syncSlowToggleStateFromServer)
		end

		Remotes.Treadmill.AssignedBeltShifted.OnClientEvent:Connect(function(p: string?)
			v2 = p
			refreshVisibilityFromCurrentWalkSpeed() -- equivalent call inferred; original call site unknown
		end)

		if localPlayer.Character ~= nil then
			bindHumanoid(localPlayer.Character:WaitForChild("Humanoid"))
			syncSlowToggleStateFromServer() -- equivalent call inferred; original call site unknown
		end

		localPlayer.CharacterAdded:Connect(connectCharacter)
	end
}