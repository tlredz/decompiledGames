local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local AfkProtection = require(ReplicatedStorage.Shared.Types.AfkProtection)
local AfkTreadmillTest = require(ReplicatedStorage.Shared.Modules.AfkTreadmillTest)
local Constants = require(ReplicatedStorage.Shared.Globals.Constants)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local localPlayer = Players.LocalPlayer
local flag = false
return {
	Start = function()
		local function connectActivityInputs(callback)
			UserInputService.InputBegan:Connect(function()
				callback()
			end)
			UserInputService.InputChanged:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement then
					callback()
				elseif input.UserInputType == Enum.UserInputType.Touch then
					callback()
				elseif string.find(input.UserInputType.Name, "Gamepad") ~= nil then
					callback()
				end
			end)
		end

		local function startControlBehaviour()
			local v = false

			-- equivalent calls inferred from this helper; original call sites unknown
			local function reportAfkState(flag2: boolean)
				if v == flag2 then
					return
				end

				v = flag2
				Remotes.Telemetry.SubmitIdleState:FireServer(flag2)
			end

			local function reportActiveFromInput()
				if not v then
					return
				end

				reportAfkState(false) -- equivalent call inferred; original call site unknown
			end

			localPlayer.Idled:Connect(function(p: number)
				if p >= 60 and v ~= true then
					v = true
					Remotes.Telemetry.SubmitIdleState:FireServer(true)
				end

				if p > 1080 and not Constants.IS_STUDIO then
					pcall(function()
						Remotes.Telemetry.AskIdleHopFlush:InvokeServer()
					end)
					TeleportService:Teleport(game.PlaceId, localPlayer)
				end
			end)
			connectActivityInputs(reportActiveFromInput)
		end

		local function startVariantBehaviour()
			local TELEPORT_IDLE_THRESHOLD_SECONDS = AfkProtection.TELEPORT_IDLE_THRESHOLD_SECONDS
			local CLIENT_FALLBACK_IDLE_THRESHOLD_SECONDS = AfkProtection.CLIENT_FALLBACK_IDLE_THRESHOLD_SECONDS
			local IDLE_POLL_INTERVAL_SECONDS = AfkProtection.IDLE_POLL_INTERVAL_SECONDS
			local TELEPORT_REQUEST_RETRY_INTERVAL_SECONDS = AfkProtection.TELEPORT_REQUEST_RETRY_INTERVAL_SECONDS
			local TELEPORT_DATA_KEY = AfkProtection.TELEPORT_DATA_KEY
			local lastTime = os.clock()
			local v = 0
			local v2 = false
			local v3 = 0
			local v4 = false

			-- equivalent calls inferred from this helper; original call sites unknown
			local function resolveIdleSeconds()
				return (math.max(os.clock() - lastTime, v))
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function reportIdleState(flag2: boolean)
				if v2 == flag2 then
					return
				end

				v2 = flag2
				Remotes.Telemetry.SubmitIdleState:FireServer(flag2)
				Remotes.IdleRescue.SubmitIdleFlag:FireServer(flag2)
			end

			local function markActive()
				lastTime = os.clock()
				v = 0
				v3 = 0
				v4 = false
				reportIdleState(false) -- equivalent call inferred; original call site unknown
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function requestTeleport()
				local now = os.clock()

				if now < v3 then
					return
				end

				v3 = now + TELEPORT_REQUEST_RETRY_INTERVAL_SECONDS
				Remotes.IdleRescue.AskRescueHop:FireServer()
			end

			local function fallbackTeleport()
				if v4 or Constants.IS_STUDIO or Constants.IS_PRIVATE_SERVER then
					return
				end

				v4 = true
				pcall(function()
					Remotes.Telemetry.AskIdleHopFlush:InvokeServer()
				end)
				TeleportService:Teleport(game.PlaceId, localPlayer, {
					[TELEPORT_DATA_KEY] = true
				})
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function step()
				local idleSeconds = resolveIdleSeconds() -- equivalent call inferred; original call site unknown

				if idleSeconds < 60 then
					return
				end

				reportIdleState(true) -- equivalent call inferred; original call site unknown

				if TELEPORT_IDLE_THRESHOLD_SECONDS <= idleSeconds then
					requestTeleport() -- equivalent call inferred; original call site unknown
				end

				if CLIENT_FALLBACK_IDLE_THRESHOLD_SECONDS <= idleSeconds then
					fallbackTeleport()
				end
			end

			localPlayer.Idled:Connect(function(p: number)
				v = p
			end)
			connectActivityInputs(markActive)
			task.spawn(function()
				while true do
					task.wait(IDLE_POLL_INTERVAL_SECONDS)
					step() -- equivalent call inferred; original call site unknown
				end
			end)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function startBehaviourOnce(p: string)
			if flag then
				return
			end

			flag = true

			if p == AfkTreadmillTest.Groups.Variant then
				startVariantBehaviour()
			else
				startControlBehaviour()
			end
		end

		task.spawn(function()
			startBehaviourOnce(AfkTreadmillTest.GetGroupAsync(localPlayer)) -- equivalent call inferred; original call site unknown
		end)
		task.delay(30, function()
			startBehaviourOnce(AfkTreadmillTest.Groups.Control) -- equivalent call inferred; original call site unknown
		end)
	end
}