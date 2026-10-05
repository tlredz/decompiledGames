local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")
local Promise = require(ReplicatedStorage.Utilities.Promise)
local Orchestrator = require(ReplicatedStorage._FRAMEWORK.Libraries.Orchestrator)
require(ReplicatedStorage._FRAMEWORK.Libraries.Orchestrator.Types)
local CameraManager = require(ReplicatedStorage._FRAMEWORK.Features.ClientOnly.CameraManager)
local MusicManager = require(ReplicatedStorage._FRAMEWORK.Features.MusicManager)
local Preloader = require(ReplicatedStorage._FRAMEWORK.Features.Preloader)
local parentModule = require(script.Parent.Parent)
local BlackTransition = require(script.BlackTransition)
local FakeVoteCounters = require(script.FakeVoteCounters)
local Landscape = require(script.Landscape)
local Minigame = require(script.Minigame)
local MinigameReturnButton = require(script.MinigameReturnButton)
local Config = require(script.Config)
local Transition = require(script.Transition)
local AdminAbuseDoorConfig = require(ReplicatedStorage.Shared.AdminAbuseDoorConfig)
local t = require(ReplicatedStorage.Packages.t)
local literal = t.literal(Config.checkpointWinRequest)
local v = AdminAbuseDoorConfig.TransitionBlackIn + AdminAbuseDoorConfig.TransitionBlackHold + AdminAbuseDoorConfig.TransitionApproachSeconds + AdminAbuseDoorConfig.LobbyDoorOpenExtraDelaySec
local v2 = {
	IntroSequence = {
		startTime = 10
	},
	AdminAbuseSequence = {
		startTime = 0
	},
	EndingSequence = {
		startTime = 500.7
	}
}

function getLobbyDoor()
	local LobbyDoorServer = require(ServerScriptService.Server.LobbyDoorServer)
	return LobbyDoorServer
end

function getAdminAbuseTransition()
	local AdminAbuseTransition = require(Players.LocalPlayer.PlayerScripts.Client.AdminAbuseTransition)
	return AdminAbuseTransition
end

function loadMap()
	if not RunService:IsServer() then
		return Promise.new(function(callback, _)
			local v3 = CollectionService:GetTagged("FABADMINABUSE_V1_MAP")[1]

			if v3 then
				return callback(v3)
			end

			callback(CollectionService:GetInstanceAddedSignal("FABADMINABUSE_V1_MAP"):Wait())
		end)
	end

	local clone = ServerStorage.AdminAbuseMaps.FabAA:Clone()
	clone:PivotTo(Workspace.AdminAbuse.BossRoomRootPosition.CFrame)
	local keycaps = clone.Keycaps
	keycaps.Parent = Workspace.Keycaps
	clone.Name = "AdminAbuseMap"
	clone.Parent = Workspace.AdminAbuse.Map
	clone.Destroying:Connect(function()
		keycaps:Destroy()
	end)
	clone:AddTag("FABADMINABUSE_V1_MAP")
	return Promise.resolve(clone)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function preloadMapParticleEmitters(object)
	for _, v3 in object:QueryDescendants("ParticleEmitter") do
		Preloader.preload(v3)
	end
end

function setLobbyDoorOpen(flag: boolean, flag2: boolean?)
	if RunService:IsClient() then
		return
	end

	if flag then
		getLobbyDoor().open(flag2 or false)
	else
		getLobbyDoor().close(flag2 or false)
	end
end

parentModule.register(script.Name, {
	displayName = "Fab Boss Event",
	slot = "main",
	needsDuration = false,
	defaultDurationSeconds = 960,
	load = function(data)
		local v3 = nil
		local values = {}
		local v4 = nil
		local v5 = nil
		local v6 = nil
		local v7 = false
		local v8 = false
		local nowsByPlayer = {}
		local v9 = {}
		local BonusManager

		if RunService:IsServer() then
			BonusManager = require(ReplicatedStorage.BonusManager)
		else
			BonusManager = nil
		end

		local remotes

		if RunService:IsServer() then
			remotes = ReplicatedStorage:FindFirstChild("Remotes")
		end

		local showWin

		if remotes == nil then
			showWin = nil
		else
			showWin = remotes:FindFirstChild("ShowWin")
		end

		if showWin == nil or not showWin:IsA("RemoteEvent") then
			showWin = nil
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function restoreAnticheat()
			if RunService:IsServer() then
				ServerScriptService:SetAttribute("SecretShieldEnabled", true)
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function disableAnticheat()
			if RunService:IsServer() then
				ServerScriptService:SetAttribute("SecretShieldEnabled", false)
				data.janitor:Add(restoreAnticheat)
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function hideMinigameReturnButton()
			local v10 = v5

			if v10 ~= nil then
				v5 = nil
				v10.destroy()
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function registerMinigameReturnButton(p)
			v5 = p
			data.janitor:Add(function()
				if v5 == p then
					v5 = nil
				end

				p.destroy()
			end)
		end

		local returnLocalPlayerToLobby

		returnLocalPlayerToLobby = function()
			if RunService:IsClient() and v7 then
				Minigame.returnLocalPlayerToLobby()
				hideMinigameReturnButton() -- equivalent call inferred; original call site unknown
				task.defer(function()
					if v7 and v5 == nil then
						registerMinigameReturnButton(MinigameReturnButton.mount(
							Players.LocalPlayer.PlayerGui,
							returnLocalPlayerToLobby
						)) -- equivalent call inferred; original call site unknown
					end
				end)
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function showMinigameReturnButton()
			if RunService:IsClient() and v5 == nil then
				registerMinigameReturnButton(MinigameReturnButton.mount(
					Players.LocalPlayer.PlayerGui,
					returnLocalPlayerToLobby
				)) -- equivalent call inferred; original call site unknown
			end
		end

		local function finishEvent(p)
			restoreAnticheat() -- equivalent call inferred; original call site unknown

			if RunService:IsClient() then
				hideMinigameReturnButton() -- equivalent call inferred; original call site unknown
				Landscape.finish()
				FakeVoteCounters.finish()
				CameraManager.cutscene.stopCutscene()
			else
				MusicManager.stopAll()
			end

			Minigame.finish()

			for _, v10 in values do
				v10:stop(p)
			end

			Preloader.clearImagePreload()
			table.clear(values)
			setLobbyDoorOpen(false)
		end

		local function setSequenceEvents(object, name: string)
			print("Setting sequence for", name)
			object:onMarker("Transition", function(p)
				if not v4 then
					return
				end

				v4.setVisible(p == "1")
			end)
			object:onMarker("BlackTransition", function()
				if RunService:IsClient() then
					BlackTransition.mount(Players.LocalPlayer.PlayerGui).play()
				end
			end)
			object:onMarker("Minigame", function(p)
				v7 = p == "Start"

				if v7 then
					showMinigameReturnButton() -- equivalent call inferred; original call site unknown
				else
					hideMinigameReturnButton() -- equivalent call inferred; original call site unknown
					Minigame.finish()
				end
			end, {
				runOnCatchUp = true
			})
			object:onMarker("Counters", function(p)
				if RunService:IsClient() then
					if p == "Stop" or p == "0" then
						FakeVoteCounters.finish()
					else
						FakeVoteCounters.start()
					end
				end
			end, {
				runOnCatchUp = true
			})
			object:onMarker("Landscape", function(p)
				if RunService:IsClient() then
					if p == "1" or p == "On" or p == "Start" then
						Landscape.start()
					else
						Landscape.finish()
					end
				end
			end, {
				runOnCatchUp = true
			})
			object:onMarker("StopAll", function()
				if RunService:IsServer() and not v8 then
					v8 = true
					task.defer(function()
						parentModule.stopModuleLocally(data.name, "manual")
					end)
				end
			end, {
				runOnCatchUp = true
			})
		end

		return {
			onStart = function()
				disableAnticheat() -- equivalent call inferred; original call site unknown
				Minigame.init()

				if RunService:IsClient() then
					Landscape.finish()
					v6 = getAdminAbuseTransition()
					v6.cancel()
					v6.play(nil, {
						skip = data.isCatchUp,
						skipDoor = false
					})
					v4 = Transition.mount(Players.LocalPlayer.PlayerGui)
					data.janitor:Add(function()
						local v10 = v6

						if v10 then
							v10.cancel()
							v6 = nil
						end

						local v11 = v4

						if v11 then
							v11.destroy()
							v4 = nil
						end
					end)
				end

				loadMap():andThen(function(object)
					v3 = object

					if RunService:IsServer() then
						data.janitor:Add(object)
					else
						preloadMapParticleEmitters(object) -- equivalent call inferred; original call site unknown
					end

					if RunService:IsServer() then
						local v10 = math.max(0, v - data.elapsedSeconds)

						if v10 == 0 then
							setLobbyDoorOpen(true, true)
						else
							local v11 = Promise.delay(v10):andThen(function()
								setLobbyDoorOpen(true)
							end)
							data.janitor:Add(function()
								v11:cancel()
							end)
						end
					end

					for _, v10 in object:QueryDescendants(">Configuration") do
						values[v10.Name] = Orchestrator.load(v10)
						setSequenceEvents(values[v10.Name], v10.Name)
					end

					if RunService:IsServer() then
						object.Scriptables.Cutscenes.Intro.Dummy:PivotTo(CFrame.new(0, -100, 0))
						object.Scriptables.Cutscenes.Outro.Hacker:PivotTo(CFrame.new(0, -100, 0))
						object.Scriptables.Cutscenes.Outro.P1Hammer:PivotTo(CFrame.new(0, -100, 0))
						object.Scriptables.Cutscenes.Outro.P2Sword:PivotTo(CFrame.new(0, -100, 0))
						object.Scriptables.Cutscenes.Outro.P3Fists:PivotTo(CFrame.new(0, -100, 0))
						object.Scriptables.Cutscenes.Outro.Floor:PivotTo(CFrame.new(0, -100, 0))
						object.Scriptables.Cutscenes.Outro.Floor.Size = createVector(2, 2, 2)
					end
				end)
			end,
			onUpdate = function(p)
				if not v3 then
					return
				end

				if RunService:IsClient() then
					Landscape.update()
					FakeVoteCounters.update(p)
				end

				if v7 then
					Minigame.update(data, v3)
				end

				for k, v10 in values do
					local v11 = v2[k]

					if v11 then
						if not v10:isComplete() then
							local v12 = data.elapsedSeconds - v11.startTime

							if not (v12 < 0) and v12 >= 0 then
								if v10:getState() == "ready" then
									v10:start(v12)
								elseif v10:isPlaying() then
									v10:update(v12)
								end
							end
						end
					else
						warn((`Couldn't find sequence {k} in the sequenceRunTime config. Did you forget to define it?`))
					end
				end
			end,
			onClientEvent = function(player, p)
				if not (v7 and literal(p)) then
					return
				end

				local now = os.clock()
				local v10 = nowsByPlayer[player]

				if v10 ~= nil and now - v10 < Config.checkpointWinCooldownSeconds then
					return
				end

				nowsByPlayer[player] = now
				local DataManager = require(ServerScriptService.DataManager)
				local playerData = DataManager:GetPlayerData(player)

				if not playerData then
					return
				end

				local v11 = v9[player] or playerData.Wins
				v9[player] = v11
				local v12 = BonusManager
				local winsMultiplier = v12.GetWinsMultiplier(v12, player)
				local v13 = v11 * Config.checkpointWinRewardMult * winsMultiplier
				DataManager:IncrementStat(player, "Wins", v13, {
					source = "FabBossEvent:Checkpoint"
				})

				if showWin ~= nil then
					showWin:FireClient(player, v13)
				end
			end,
			onStop = function(p)
				finishEvent(p)
			end
		}
	end
})
return nil