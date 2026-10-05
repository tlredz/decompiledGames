local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local batServer = require(ReplicatedStorage.Shared.Flags.GameplayBalance).BatServer
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local AntiCheatService = require(ServerScriptService.Controllers.AntiCheatService)
local Audio = require(ReplicatedStorage2.Shared.Audio)
local Config = require(script.Parent.Config)
local BatDamagable = require(ServerScriptService.Library.Tools.Internal.BatDamagable)
require(script.Parent.Types.Interface)
local Constants = require(ReplicatedStorage2.Shared.Globals.Constants)
local GameplayToolGuard = require(ServerScriptService.Library.Tools.Internal.GameplayToolGuard)
require(ReplicatedStorage2.Data.Gears)
local ToolHolders = require(ReplicatedStorage2.Shared.Util.ToolHolders)
local fromTool = ToolHolders.FromTool
local Log = require(ReplicatedStorage2.Packages.Log)
local Player = require(ReplicatedStorage2.Shared.Player)
local Ragdoll = require(ReplicatedStorage2.Shared.Modules.Ragdoll)
local Remotes = require(ReplicatedStorage2.Shared.Remotes)
local SlapShared = require(ServerScriptService.Library.Tools.Internal.SlapShared)
require(ReplicatedStorage2.Shared.Types.Tools)
local Trove = require(ReplicatedStorage2.Packages.Trove)
local t = require(ReplicatedStorage2.Packages.t)
local BatController = {}
BatController.__index = BatController
BatController.__class = "BatServerController"
local v = {
	0,
	2,
	4,
	7,
	9,
	12
}
local v2 = Log.new()
local random = Random.new()

function BatController.new(tool, data)
	t.strict(t.instanceIsA("Tool"))(tool)
	assert(typeof(data) == "table", "Bat controller data must be a table")
	assert(typeof(data.Duration) == "number", "Bat controller duration must be a number")
	assert(typeof(data.Force) == "number", "Bat controller force must be a number")
	assert(typeof(data.RangeBonus) == "number", "Bat controller range bonus must be a number")
	local handle = tool.Handle
	assert(handle:IsA("BasePart"), "Bat.Handle must be a BasePart")
	local object = setmetatable({}, BatController)
	object._tool = tool
	object._handle = handle
	object._range = Config.Range + data.RangeBonus
	object._slapProfile = table.freeze({
		Duration = data.Duration,
		Force = data.Force,
		BrainrotDamage = 0,
		MaxBrainrotTargets = 0
	})
	object._cooldownLockedUntil = 0
	object._nextDebugLogAt = 0
	object._processing = false
	object._idleTrack = nil
	object._trove = Trove.new()
	object:_init()
	return object
end

function BatController:_setCooldownAttributes(cooldownDuration: number)
	local _tool = self._tool
	local v3 = workspace:GetServerTimeNow() + cooldownDuration
	_tool:SetAttribute("CooldownDuration", cooldownDuration)
	_tool:SetAttribute("CooldownEndTime", v3)
	_tool:SetAttribute("CooldownActive", true)
	task.delay(cooldownDuration, function()
		if _tool.Parent and _tool:GetAttribute("CooldownEndTime") == v3 then
			_tool:SetAttribute("CooldownActive", false)
			_tool:SetAttribute("CooldownDuration", 0)
			_tool:SetAttribute("CooldownEndTime", 0)
			self._cooldownLockedUntil = 0
		end
	end)
end

function BatController:_playIdle(p2)
	if self._idleTrack then
		return
	end

	local humanoid = Player.FindHumanoid(p2)
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	local idleAnim = self._tool:FindFirstChild("IdleAnim")

	if animator and idleAnim then
	end
end

function BatController:_stopIdle()
	local _idleTrack = self._idleTrack

	if not _idleTrack then
		return
	end

	self._idleTrack = nil
	_idleTrack:Stop()
	_idleTrack:Destroy()
end

function BatController:_playHitAnimation(p2)
	local humanoid = Player.FindHumanoid(p2)
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	local hitAnim = self._tool:FindFirstChild("HitAnim")

	if not (animator and hitAnim) then
		return
	end

	local track = animator:LoadAnimation(hitAnim)
	track.Priority = Enum.AnimationPriority.Action
	track:Play()
end

function BatController:_applyPlayerHit(instance, vector2: Vector3)
	local character = Player.FindCharacter(instance)
	local part = Player.FindRootPart(instance)

	if not (character and part and part:IsA("BasePart") and character:GetAttribute("IsTrapped") ~= true) then
		return
	end

	if not GameplayToolGuard.IsPlayerInGameplayArea(instance) then
		return
	end

	GameplayToolGuard.DropHeldEggFromPlayerHit(instance)
	local impulse, v3 = SlapShared.ComputeImpulse(part, vector2, self._slapProfile)
	instance:SetAttribute("RagdollEndTime", workspace:GetServerTimeNow() + v3)
	Ragdoll.TimedRagdollAsync(character, v3, impulse)
end

function BatController:_canLogDebugTrace(p2: number)
	if not Constants.IS_STUDIO or p2 < self._nextDebugLogAt then
		return false
	end

	self._nextDebugLogAt = p2 + 0.1
	return true
end

function BatController:_logDecisionTrace(object2, traceId: string, serverTime: number, instance, target, data, decision: string, explanation: string, action: string)
	if not self:_canLogDebugTrace(serverTime) then
		return
	end

	if data and data.Target then
		target = data.Target
	end

	local part

	if target then
		part = Player.FindRootPart(target)
	end

	if not (part and part:IsA("BasePart")) then
		part = nil
	end

	local humanoid = Player.FindHumanoid(object2)
	local v3 = not instance and createVector(0, 0, 0) or instance.AssemblyLinearVelocity
	local v4 = not part and createVector(0, 0, 0) or part.AssemblyLinearVelocity
	local maximumRange = (self._range + Config.HitTolerance) * Config.GetHitboxScalar()
	local currentDistance

	if data then
		currentDistance = data.CurrentDistance
	else
		currentDistance = not (instance and part) and -1 or (part.Position - instance.Position).Magnitude
	end

	local v6 = v2:AtInfo()
	local v8 = {
		Stage = "SERVER_DECISION",
		TraceId = traceId,
		Decision = decision,
		Explanation = explanation,
		Action = action,
		Accepted = action == "HIT_ACTION_DISPATCHED",
		ServerTime = serverTime,
		AttackerName = object2.Name,
		AttackerUserId = object2.UserId,
		TargetName = not target and "None" or target.Name,
		TargetUserId = not target and 0 or target.UserId,
		MaximumRange = maximumRange,
		ServerCurrentDistance = currentDistance,
		ServerHistoricalDistance = not data and -1 or data.HistoricalDistance,
		TargetViewAgeSeconds = not data and -1 or data.TargetViewAge,
		HistoricalTimestamp = not data and -1 or data.HistoricalTimestamp,
		HistoricalSampleIntervalSeconds = not data and -1 or data.HistoricalSampleInterval,
		NetworkPingSeconds = object2:GetNetworkPing(),
		CooldownRemainingSeconds = math.max(0, self._cooldownLockedUntil - serverTime),
		CooldownToApplySeconds = action ~= "HIT_ACTION_DISPATCHED" and action ~= "MISS_COOLDOWN_APPLIED" and 0 or batServer.PLAYER_COOLDOWN,
		AttackerServerPosition = not instance and createVector(0, 0, 0) or instance.Position,
		TargetCurrentServerPosition = 0,
		TargetHistoricalServerPosition = 0,
		AttackerWalkSpeed = 0,
		AttackerHorizontalSpeed = 0,
		TargetHorizontalSpeed = 0,
		TargetServerStationary = 0
	}
	local targetCurrentServerPosition

	if data then
		targetCurrentServerPosition = data.TargetServerPosition
	else
		targetCurrentServerPosition = not part and createVector(0, 0, 0) or part.Position
	end

	v8.TargetCurrentServerPosition = targetCurrentServerPosition
	v8.TargetHistoricalServerPosition = not data and createVector(0, 0, 0) or data.TargetHistoricalServerPosition
	v8.AttackerWalkSpeed = not humanoid and -1 or humanoid.WalkSpeed
	v8.AttackerHorizontalSpeed = Vector3.new(v3.X, 0, v3.Z).Magnitude
	v8.TargetHorizontalSpeed = Vector3.new(v4.X, 0, v4.Z).Magnitude
	v8.TargetServerStationary = part ~= nil and Vector3.new(v4.X, 0, v4.Z).Magnitude <= 1
	v6:Log("Bat hit validation trace", v8)
end

function BatController:_resolveValidTarget(instance, target, p2, p3: number)
	local v3 = {
		Target = target,
		Delta = nil,
		Decision = "CLIENT_NO_TARGET",
		Explanation = "The client did not nominate a player inside its rendered selection range.",
		CurrentDistance = -1,
		HistoricalDistance = -1,
		TargetViewAge = -1,
		HistoricalTimestamp = -1,
		HistoricalSampleInterval = -1,
		TargetServerPosition = createVector(0, 0, 0),
		TargetHistoricalServerPosition = createVector(0, 0, 0)
	}

	if target == nil then
		return v3
	end

	if target == instance then
		v3.Decision = "SELF_TARGET_REJECTED"
		v3.Explanation = "The nominated target was the attacker."
		return v3
	elseif target.Parent == Players then
		if instance:GetAttribute("InBossArena") or target:GetAttribute("InBossArena") or instance:GetAttribute("InScrambleArena") or target:GetAttribute("InScrambleArena") then
			v3.Decision = "BOSS_ARENA_PVP_DISABLED"
			v3.Explanation = "Players inside the boss arena cannot hit or be hit by bats."
			return v3
		elseif workspace:GetAttribute("PvPDisabled") == true then
			v3.Decision = "EVENT_PVP_DISABLED"
			v3.Explanation = "A running event has turned player hits off."
			return v3
		else
			local character = Player.FindCharacter(target)
			local part = Player.FindRootPart(target)
			local humanoid = Player.FindHumanoid(target)

			if character and part and part:IsA("BasePart") and humanoid then
				v3.TargetServerPosition = part.Position

				if humanoid.Health <= 0 then
					v3.Decision = "TARGET_DEAD"
					v3.Explanation = "The nominated target was dead when the server handled the swing."
					return v3
				elseif Ragdoll.IsRagdolled(character) then
					v3.Decision = "TARGET_ALREADY_RAGDOLLED"
					v3.Explanation = "The nominated target was already ragdolled and is not eligible for another Bat hit."
					return v3
				elseif GameplayToolGuard.IsPlayerInGameplayArea(target) then
					local delta = part.Position - p2.Position
					local v5 = (self._range + Config.HitTolerance) * Config.GetHitboxScalar()
					v3.CurrentDistance = delta.Magnitude

					if v3.CurrentDistance <= v5 then
						v3.Target = target
						v3.Delta = delta
						v3.Decision = "CURRENT_RANGE_ACCEPTED"
						v3.Explanation = "The server currently sees the target inside MaximumRange; history compensation was not needed."
						return v3
					else
						local targetViewAge = math.clamp(
							instance:GetNetworkPing() + Config.TargetViewSamplePadding,
							Config.TargetViewSamplePadding,
							Config.MaximumTargetViewAge
						)
						local historicalTimestamp = p3 - targetViewAge
						v3.TargetViewAge = targetViewAge
						v3.HistoricalTimestamp = historicalTimestamp
						local historicalPosition = AntiCheatService.GetHistoricalPosition(target, historicalTimestamp)

						if historicalPosition == nil then
							v3.Decision = "HISTORY_UNAVAILABLE"
							v3.Explanation = "Current distance exceeded MaximumRange and the server could not reconstruct the target at HistoricalTimestamp."
						else
							v3.HistoricalSampleInterval = historicalPosition.SampleInterval
							v3.TargetHistoricalServerPosition = historicalPosition.Position
							v3.HistoricalDistance = (historicalPosition.Position - p2.Position).Magnitude

							if v5 < v3.HistoricalDistance then
								v3.Decision = "CURRENT_AND_HISTORY_OUT_OF_RANGE"
								v3.Explanation = "Both ServerCurrentDistance and ServerHistoricalDistance exceeded MaximumRange."
							else
								v3.Target = target
								v3.Delta = delta
								v3.Decision = "HISTORICAL_RANGE_ACCEPTED"
								v3.Explanation = "Current distance exceeded MaximumRange, but server-owned history proves the target was inside range in the estimated client view."
							end
						end

						return v3
					end
				else
					v3.Decision = "TARGET_IN_SAFE_ZONE"
					v3.Explanation = "The nominated target was in the safe zone and is not eligible for a Bat hit."
					return v3
				end
			else
				v3.Decision = "TARGET_CHARACTER_UNAVAILABLE"
				v3.Explanation = "The server could not resolve the nominated target's live character, root, or Humanoid."
				return v3
			end
		end
	else
		v3.Decision = "TARGET_NOT_IN_SERVER"
		v3.Explanation = "The nominated player was no longer in this server."
		return v3
	end
end

function BatController:_playSwingNote()
	local swingNote = self._handle:FindFirstChild("SwingNote")

	if not (swingNote and swingNote:IsA("Sound")) then
		return
	end

	local v3 = v[random:NextInteger(1, #v)]
	Audio.Play(swingNote, self._handle, {
		MaxDistance = swingNote.RollOffMaxDistance,
		PlaybackSpeed = swingNote.PlaybackSpeed * 2 ^ (v3 / 12)
	})
end

function BatController:_beginActivation(p)
	local character = Player.FindCharacter(p)

	if not character then
		return nil, "ATTACKER_CHARACTER_UNAVAILABLE", "The server could not resolve the attacker's character."
	end

	local humanoid = Player.FindHumanoid(p)

	if not humanoid or humanoid.Health <= 0 then
		return nil, "ATTACKER_DEAD", "The server rejected the swing because the attacker was dead."
	end

	if Ragdoll.IsRagdolled(character) then
		return nil, "ATTACKER_RAGDOLLED", "The server rejected the swing because the attacker was ragdolled."
	end

	if not GameplayToolGuard.CanActivate(p) then
		return nil, "GAMEPLAY_GUARD_REJECTED", "The gameplay tool guard rejected the swing before target validation."
	end

	self:_playHitAnimation(p)
	self:_playSwingNote()
	local part = Player.FindRootPart(p)

	if part and part:IsA("BasePart") then
		return part, "ACTIVATION_ACCEPTED", "The swing passed attacker and gameplay activation guards."
	end

	return nil, "ATTACKER_ROOT_UNAVAILABLE", "The server could not resolve the attacker's HumanoidRootPart."
end

function BatController:_finishMiss()
	local slash = self._handle:FindFirstChild("Slash")

	if slash then
		slash:Play()
	end

	return batServer.PLAYER_COOLDOWN
end

function BatController:_applyHits(_, list)
	if #list == 0 then
		return self:_finishMiss()
	end

	local hit = self._handle:FindFirstChild("Hit")

	if hit then
		hit:Play()
	end

	for _, v3 in ipairs(list) do
		self:_applyPlayerHit(v3.target, v3.delta)
	end

	return batServer.PLAYER_COOLDOWN
end

function BatController:_activate(p, p2, p3: number, p4: string)
	local _beginActivation, v3, v4 = self:_beginActivation(p)

	if not _beginActivation then
		self:_logDecisionTrace(p, p4, p3, nil, p2, nil, v3, v4, "NO_ACTION")
		return nil
	end

	local _resolveValidTarget = self:_resolveValidTarget(p, p2, _beginActivation, p3)
	local target = _resolveValidTarget.Target
	local delta = _resolveValidTarget.Delta
	local hitWithinRange = BatDamagable.HitWithinRange(p, _beginActivation.Position, self._range)

	if target and delta then
		local _applyHits = self:_applyHits(_beginActivation, {
			{
				target = target,
				delta = delta
			}
		})
		self:_logDecisionTrace(
			p,
			p4,
			p3,
			_beginActivation,
			p2,
			_resolveValidTarget,
			_resolveValidTarget.Decision,
			_resolveValidTarget.Explanation,
			"HIT_ACTION_DISPATCHED"
		)
		return _applyHits
	elseif hitWithinRange > 0 then
		local hit = self._handle:FindFirstChild("Hit")

		if hit then
			hit:Play()
		end

		self:_logDecisionTrace(
			p,
			p4,
			p3,
			_beginActivation,
			p2,
			_resolveValidTarget,
			"DAMAGABLE_HIT",
			`The swing landed on {hitWithinRange} BatDamagable hitbox(es).`,
			"DAMAGABLE_HIT_DISPATCHED"
		)
		return batServer.PLAYER_COOLDOWN
	else
		local _finishMiss = self:_finishMiss()
		self:_logDecisionTrace(
			p,
			p4,
			p3,
			_beginActivation,
			p2,
			_resolveValidTarget,
			_resolveValidTarget.Decision,
			_resolveValidTarget.Explanation,
			"MISS_COOLDOWN_APPLIED"
		)
		return _finishMiss
	end
end

function BatController:_canProcessRequest(p)
	local character = Player.FindCharacter(p)

	if not character then
		return false, "REQUEST_CHARACTER_UNAVAILABLE", "The request arrived without a live attacker character."
	end

	if self._tool.Parent ~= character or fromTool(self._tool) ~= p then
		return
			false,
			"REQUEST_TOOL_NOT_EQUIPPED",
			"The server rejected the request because this Bat was not equipped and owned by the attacker."
	end

	if Ragdoll.IsRagdolled(character) then
		return
			false,
			"REQUEST_ATTACKER_RAGDOLLED",
			"The server rejected the request because the attacker was ragdolled."
	end

	if self._processing then
		return false, "REQUEST_ALREADY_PROCESSING", "The previous Bat request is still being processed."
	end

	if workspace:GetServerTimeNow() < self._cooldownLockedUntil then
		return false, "REQUEST_COOLDOWN_ACTIVE", "The request arrived before the server Bat cooldown ended."
	end

	return true, "REQUEST_ACCEPTED", "The request passed equip, ownership, ragdoll, processing, and cooldown guards."
end

function BatController:_runActivation(p, callback)
	local _canProcessRequest, v3, v4 = self:_canProcessRequest(p)

	if not _canProcessRequest then
		return false, v3, v4
	end

	self._processing = true
	local v5 = callback(self, p)
	self._processing = false

	if v5 then
		self._cooldownLockedUntil = workspace:GetServerTimeNow() + v5
		self:_setCooldownAttributes(v5)
	end

	return true, "REQUEST_PROCESSED", "The server completed the Bat activation callback."
end

function BatController:_handleActivation(p, p2, p3: string)
	t.strict(t.instanceIsA("Player"))(p)
	t.strict(t.optional(t.instanceIsA("Player")))(p2)
	t.strict(t.string)(p3)
	local serverTimeNow = workspace:GetServerTimeNow()
	local _runActivation, v3, v4 = self:_runActivation(p, function(object2, p4)
		return object2:_activate(p4, p2, serverTimeNow, p3)
	end)

	if not _runActivation then
		self:_logDecisionTrace(p, p3, serverTimeNow, Player.FindRootPart(p), p2, nil, v3, v4, "NO_ACTION")
	end
end

function BatController:Destroy()
	self:_stopIdle()
	self._trove:Destroy()
	v2:AtDebug():Log("Bat server controller destroyed")
end

function BatController:_init()
	local _tool = self._tool
	_tool:SetAttribute("CooldownEndTime", 0)
	_tool:SetAttribute("CooldownDuration", 0)
	_tool:SetAttribute("CooldownActive", false)
	_tool:SetAttribute("IsBat", true)
	self._trove:Connect(Remotes.BatSwing.Trigger.OnServerEvent, function(p, p2, p3: string)
		self:_handleActivation(p, p2, p3)
	end)
	self._trove:Connect(_tool.Equipped, function()
		local v3 = fromTool(_tool)

		if v3 then
			self:_playIdle(v3)
		end
	end)
	self._trove:Connect(_tool.Unequipped, function()
		self:_stopIdle()
	end)
	self._trove:Connect(_tool.Destroying, function()
		self:Destroy()
	end)
end

return BatController