local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local ServerNpcUtil = require(SAM.Services.ServerNpcUtil)
local Checker = require(CAM.Global.Checker)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local Utility = require(CAM.Global.Utility)
local DebrisModule = require(CAM.DebrisModule)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local Config = require(script.Parent.Config)
local DemonSlayerSummonServer = {
	Id = {}
}

local function acquireTarget(character, humanoidRootPart, vector2: Vector3?)
	if vector2 == nil then
		return nil
	end

	local _, _, _, v = RaycastHelper.MaximizeRayServer(
		character,
		humanoidRootPart.Position,
		vector2,
		Config.TARGET_RANGE,
		true,
		Config.SPHERECAST_RADIUS,
		Config.DOWNCAST
	)

	if v == nil or v == character or Checker.check_victim(script, character, v) == nil then
		return nil
	end

	local humanoidRootPart2 = v:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart2 == nil or ((humanoidRootPart2.Position - humanoidRootPart.Position) * createVector(1, 0, 1)).Magnitude > Config.TARGET_RANGE then
		return nil
	end

	return v
end

local function playClip(instance, childName: string)
	local child = script:FindFirstChild(childName)
	local humanoid = instance:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

	if child == nil or animator == nil then
		return
	end

	local track = animator:LoadAnimation(child)
	track:Play()
	DebrisModule:AddItem(track, track.Length > 0 and track.Length or 3)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playArrival(instance)
	playClip(instance, "SummonAnimation")
end

function DemonSlayerSummonServer.Hold(_, _: Vector3?, _) end

function DemonSlayerSummonServer.UnHold(player, vector2: Vector3?, _)
	local character = player.Character

	if character == nil then
		return false
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return false
	end

	local targetModel = acquireTarget(character, humanoidRootPart, vector2)
	local getvaluesfolder = Utility.getvaluesfolder(character)
	Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.LOCK)
	local v2 = DemonSlayerSummonServer.Id[player.UserId]
	task.wait(Config.WHISTLE_AT)

	if v2 ~= DemonSlayerSummonServer.Id[player.UserId] or humanoidRootPart.Parent == nil then
		return false
	end

	EffectsEvent.ToAllInRange(humanoidRootPart, "DemonSlayerSummonVFX", character, "Whistle")

	if targetModel == nil then
		return false
	end

	task.wait(Config.FIRST_ARRIVAL_AT)

	if v2 ~= DemonSlayerSummonServer.Id[player.UserId] or humanoidRootPart.Parent == nil or targetModel.Parent == nil then
		return false
	end

	local cFrame = humanoidRootPart.CFrame

	for i = 1, math.min(Config.SUMMON_COUNT, #Config.SPAWN_OFFSETS) do
		if v2 ~= DemonSlayerSummonServer.Id[player.UserId] then
			return false
		end

		local v3 = i
		ServerNpcUtil.SpawnTempNpc(Config.SUMMON_CONFIG, {
			Position = (cFrame * Config.SPAWN_OFFSETS[i]).Position,
			TargetModel = targetModel,
			LockTarget = true,
			Owner = character,
			OnRig = function(instance)
				if v2 ~= DemonSlayerSummonServer.Id[player.UserId] then
					return
				end

				local humanoid = instance:FindFirstChildOfClass("Humanoid")

				if humanoid ~= nil then
					humanoid.MaxHealth = Config.SUMMON_HEALTH
					humanoid.Health = Config.SUMMON_HEALTH
				end

				instance:SetAttribute(Checker.MobVsMobAttribute, true)
				local getvaluesfolder2 = Utility.getvaluesfolder(instance)

				if getvaluesfolder2 ~= nil then
					Utility.AddValue(getvaluesfolder2, "pause_gameplay", Config.ARRIVAL_FREEZE)
					Utility.AddValue(getvaluesfolder2, "iframe", Config.ARRIVAL_FREEZE)
				end

				local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart2 ~= nil then
					Utility.lock(
						humanoidRootPart2,
						humanoidRootPart2.CFrame,
						Config.ARRIVAL_FREEZE,
						(`{Config.LOCK_PART_NAME}_{player.UserId}_{v3}`)
					)
				end

				playArrival(instance) -- equivalent call inferred; original call site unknown
				EffectsEvent.ToAllInRange(humanoidRootPart, "DemonSlayerSummonVFX", character, "Arrive", instance)
				task.delay(Config.SUMMON_LIFETIME, function()
					local humanoid2 = instance.Parent ~= nil and instance:FindFirstChildOfClass("Humanoid") or nil

					if humanoid2 == nil or humanoid2.Health <= 0 then
						return
					end

					instance:SetAttribute("CleanupKill", true)
					humanoid2.Health = 0
				end)
			end
		})
		task.wait(Config.ARRIVAL_STAGGER)
	end

	return false
end

function DemonSlayerSummonServer.Cancel(player, _, _)
	local character = player and player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
end

return DemonSlayerSummonServer