local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local Checker = require(ReplicatedStorage.CAM.Global.Checker)
local InCombat = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.InCombat)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local MuzanSettings = require(ReplicatedStorage.CAM.Global.MuzanSettings)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local Worlds = require(ReplicatedStorage.CAM.Worlds)
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local ReputationHandler = require(ServerStorage.SAM.Services.ReputationHandler)
local Movement = require(ServerStorage.SAM.AntiCheat.Movement)
local BiwaBellServer = {}
local v = {}
local Players = game:GetService("Players")
Players.PlayerRemoving:Connect(function(player)
	local v2 = v[player]

	if v2 ~= nil and v2.SequenceThread ~= nil and not v2.SequenceCommitted then
		task.cancel(v2.SequenceThread)
	end

	v[player] = nil
end)

local function stateFor(p)
	local v2 = v[p]

	if v2 == nil then
		v2 = {}
		v[p] = v2
	end

	return v2
end

local v2 = MuzanSettings.LairRingLength - MuzanSettings.LairFallLead + MuzanSettings.LairFallDelay
local v3 = v2 + MuzanSettings.LairTeleportAtFall
local v4 = v2 + MuzanSettings.LairFallLength
local v5 = v4 + MuzanSettings.LairRiseLength

-- equivalent calls inferred from this helper; original call sites unknown
local function fireDoorEffect(instance, p: string)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	EffectsEvent.ToAllInRange(humanoidRootPart, "BiwaDoorEffects", instance, p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cancelSequence(_, state)
	if state.SequenceCommitted or state.SequenceThread == nil then
		return
	end

	task.cancel(state.SequenceThread)
	state.SequenceThread = nil

	if state.SequencePause ~= nil then
		state.SequencePause:Destroy()
		state.SequencePause = nil
	end
end

local function worldAllows()
	local v6 = Worlds.ById[game.PlaceId]
	return v6 ~= nil and v6.BiwaBellEnabled == true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function onFloor(p)
	return workspace:Raycast(p.Position, createVector(0, -25, 0), RaycastHelper.Ground) ~= nil
end

function BiwaBellServer.check(instance, _, _, _: string)
	local v6 = Worlds.ById[game.PlaceId]
	local v7

	if v6 == nil then
		v7 = false
	else
		v7 = v6.BiwaBellEnabled == true
	end

	if v7 then
		return instance:GetAttribute(MuzanSettings.LairAttribute) == true or not InCombat.biasedCheck(instance)
	end

	return false
end

function BiwaBellServer.MouseDown(instance, instance2, _, p: string)
	local v6 = v[instance]

	if v6 == nil then
		v6 = {}
		v[instance] = v6
	end

	local v7 = Worlds.ById[game.PlaceId]
	local v8

	if v7 == nil then
		v8 = false
	else
		v8 = v7.BiwaBellEnabled == true
	end

	if not (v8 and Checker.check(instance, nil, "BiwaBell")) then
		return
	end

	local data = Utility.GetData(instance)

	if not (data ~= nil and Utility.HeldItem(data, p) ~= nil and v6.SequenceThread == nil) then
		return
	end

	if v6.LastRing ~= nil and os.clock() - v6.LastRing < 1 then
		return
	end

	v6.LastRing = os.clock()
	local getvaluesfolder = Utility.getvaluesfolder(instance2)

	if getvaluesfolder == nil then
		return
	end

	local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	local v9 = instance:GetAttribute(MuzanSettings.LairAttribute) ~= true

	if v9 then
		local v10 = ReputationHandler.Get(instance)

		if v10 == nil or MuzanSettings.LairEntryReputation <= v10 then
			SignalEvent.ToClient(instance, "NpcNotify", {
				Icon = BunchaIcons.MuzanIcon,
				Text = `You are not evil enough. Return below {MuzanSettings.LairEntryReputation}.`,
				Duration = 4
			})
			return
		end

		if Quests.GetPlayerQuestState(instance, MuzanSettings.LairBlockedQuest) == "Doing" then
			SignalEvent.ToClient(instance, "NpcNotify", {
				Icon = BunchaIcons.MuzanIcon,
				Text = "Finish your errand with the doctor first.",
				Duration = 4
			})
			return
		end

		if InCombat.biasedCheck(instance) then
			SignalEvent.ToClient(instance, "Notify", {
				Text = `Can't enter the lair while in combat ({Utility.formatTime(InCombat.biasedTimeLeft(instance))} left)`,
				Type = "Denied"
			})
			return
		end
	end

	v6.SequencePause = Utility.AddValue(getvaluesfolder, "pause_gameplay", v5 + 0.5)
	fireDoorEffect(instance2, "Ring") -- equivalent call inferred; original call site unknown
	v6.SequenceThread = task.spawn(function()
		task.wait(v2 - 0.1)
		fireDoorEffect(instance2, "JumpIn") -- equivalent call inferred; original call site unknown
		task.wait(0.2)
		v6.SequenceCommitted = true
		task.wait(v3 - v2)
		local humanoid = instance2:FindFirstChildOfClass("Humanoid")

		if instance2.Parent ~= nil and humanoid ~= nil and humanoid.Health > 0 and Utility.HeldItem(data, p) ~= nil then
			local lairArrival

			if v9 then
				if onFloor(humanoidRootPart) then
					if v9 then
						ReputationHandler.Add(instance, MuzanSettings.LairEntryCost)
						SignalEvent.ToClient(instance, "Notify", {
							Text = `The lair takes its toll. {MuzanSettings.LairEntryCost} evil reputation spent.`,
							Type = "Warn",
							Duration = 6
						})
						instance:SetAttribute(MuzanSettings.LairReturnAttribute, humanoidRootPart.CFrame)
					end

					instance:SetAttribute(MuzanSettings.LairAttribute, v9)

					if v9 then
						lairArrival = MuzanSettings.LairArrival
					else
						lairArrival = instance:GetAttribute(MuzanSettings.LairReturnAttribute)
					end

					if typeof(lairArrival) == "CFrame" then
						Movement.Expect(instance, lairArrival.Position)
					end
				end
			else
				if v9 then
					ReputationHandler.Add(instance, MuzanSettings.LairEntryCost)
					SignalEvent.ToClient(instance, "Notify", {
						Text = `The lair takes its toll. {MuzanSettings.LairEntryCost} evil reputation spent.`,
						Type = "Warn",
						Duration = 6
					})
					instance:SetAttribute(MuzanSettings.LairReturnAttribute, humanoidRootPart.CFrame)
				end

				instance:SetAttribute(MuzanSettings.LairAttribute, v9)

				if v9 then
					lairArrival = MuzanSettings.LairArrival
				else
					lairArrival = instance:GetAttribute(MuzanSettings.LairReturnAttribute)
				end

				if typeof(lairArrival) == "CFrame" then
					Movement.Expect(instance, lairArrival.Position)
				end
			end
		end

		task.wait(v4 - v3)
		fireDoorEffect(instance2, "JumpOut") -- equivalent call inferred; original call site unknown
		task.wait(v5 - v4)

		if instance:GetAttribute(MuzanSettings.LairAttribute) ~= true then
			instance:SetAttribute(MuzanSettings.LairReturnAttribute, nil)
		end

		if v6.SequencePause ~= nil then
			v6.SequencePause:Destroy()
			v6.SequencePause = nil
		end

		v6.SequenceThread = nil
		v6.SequenceCommitted = nil
		v6.LastRing = os.clock()
	end)

	if v9 then
		local lastTime = os.clock()
		task.spawn(function()
			while v6.SequenceThread ~= nil and not v6.SequenceCommitted and os.clock() - lastTime < v2 - 0.3 do
				if InCombat.biasedCheck(instance) then
					local v10 = v6

					if not v10.SequenceCommitted and v10.SequenceThread ~= nil then
						task.cancel(v10.SequenceThread)
						v10.SequenceThread = nil

						if v10.SequencePause ~= nil then
							v10.SequencePause:Destroy()
							v10.SequencePause = nil
						end
					end

					SignalEvent.ToClient(instance, "ForceEquip", 0)
					break
				else
					task.wait(0.2)
				end
			end
		end)
	end
end

function BiwaBellServer.UnEquipped(p, _, _, _: string)
	local v6 = v[p]

	if v6 == nil then
		v6 = {}
		v[p] = v6
	end

	cancelSequence(nil, v6) -- equivalent call inferred; original call site unknown
end

return BiwaBellServer