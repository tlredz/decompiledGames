local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local batClient = require(ReplicatedStorage.Shared.Flags.GameplayBalance).BatClient
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Config = require(script.Parent.Config)
require(script.Parent.Types.Interface)
local Constants = require(ReplicatedStorage2.Shared.Globals.Constants)
local Cooldown = require(ReplicatedStorage2.Shared.Utils.Cooldown)
require(ReplicatedStorage2.Data.Gears)
local Log = require(ReplicatedStorage2.Packages.Log)
local Player = require(ReplicatedStorage2.Shared.Player)
local Ragdoll = require(ReplicatedStorage2.Shared.Modules.Ragdoll)
local Remotes = require(ReplicatedStorage2.Shared.Remotes)
local ToolGameplayGuard = require(ReplicatedStorage2.Client.ToolGameplayGuard)
local Trove = require(ReplicatedStorage2.Packages.Trove)
local t = require(ReplicatedStorage2.Packages.t)
local BatController = {}
BatController.__index = BatController
BatController.__class = "BatClientController"
local v = Config.MaximumTargetViewAge + 0.1
local tweenInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local color = Color3.fromRGB(255, 0, 0)
local color2 = Color3.fromRGB(107, 0, 0)
local v2 = Log.new()
local localPlayer = Players.LocalPlayer

function BatController.new(tool, data)
	t.strict(t.instanceIsA("Tool"))(tool)
	assert(typeof(data) == "table", "Bat controller data must be a table")
	assert(typeof(data.Duration) == "number", "Bat controller duration must be a number")
	assert(typeof(data.Force) == "number", "Bat controller force must be a number")
	assert(typeof(data.RangeBonus) == "number", "Bat controller range bonus must be a number")
	local self = setmetatable({}, BatController)
	self._tool = tool
	self._highlightAttackerHistory = {}
	self._targetRange = Config.Range + Config.HitTolerance + data.RangeBonus
	self._targetStates = {}
	self._isEquipped = false
	self._traceSequence = 0
	self._tryActivate = Cooldown(batClient.CLIENT_COOLDOWN)
	self._trove = Trove.new()
	self:_init()
	return self
end

function BatController:_cancelTween(p)
	local tween = p.Tween

	if tween then
		p.Tween = nil
		tween:Cancel()
	end
end

function BatController:_destroyHighlight(p)
	self:_cancelTween(p)
	local highlight = p.Highlight

	if highlight then
		highlight:Destroy()
	end

	p.Highlight = nil
	p.Character = nil
	p.Visible = false
end

function BatController:_showHighlight(player, p)
	if player.Character ~= p then
		self:_destroyHighlight(player)
	end

	if player.Visible then
		return
	end

	player.TransitionVersion += 1
	self:_cancelTween(player)
	local highlight = player.Highlight

	if not highlight then
		highlight = Instance.new("Highlight")
		highlight.Name = "BatTargetHighlight"
		highlight.Adornee = p
		highlight.DepthMode = Enum.HighlightDepthMode.Occluded
		highlight.FillColor = color
		highlight.OutlineColor = color2
		highlight.FillTransparency = 1
		highlight.OutlineTransparency = 1
		highlight.Parent = p
		player.Highlight = highlight
	end

	player.Character = p
	player.Visible = true
	local tween = TweenService:Create(assert(highlight, "Bat target Highlight must exist before fade-in"), tweenInfo, {
		FillTransparency = 0.5,
		OutlineTransparency = 0.15
	})
	player.Tween = tween
	tween:Play()
end

function BatController:_hideHighlight(p)
	if not p.Highlight then
		return
	end

	self:_destroyHighlight(p)
end

function BatController:_trackPlayer(p2)
	if p2 == localPlayer or self._targetStates[p2] then
		return
	end

	self._targetStates[p2] = {
		Character = nil,
		Highlight = nil,
		Tween = nil,
		TransitionVersion = 0,
		Visible = false
	}
end

function BatController:_untrackPlayer(p)
	local _targetState = self._targetStates[p]

	if not _targetState then
		return
	end

	self:_destroyHighlight(_targetState)
	self._targetStates[p] = nil
end

function BatController:_isTargetEligible(instance, p, p2: number)
	local character = Player.FindCharacter(instance)
	local part = Player.FindRootPart(instance)
	local humanoid = Player.FindHumanoid(instance)

	if not character or not part or not part:IsA("BasePart") or not humanoid or humanoid.Health <= 0 then
		return false, 1e999
	end

	if Ragdoll.IsRagdolled(character) or not ToolGameplayGuard.IsInsideArena(instance) then
		return false, 1e999
	end

	if localPlayer:GetAttribute("InBossArena") or instance:GetAttribute("InBossArena") or localPlayer:GetAttribute("InScrambleArena") or instance:GetAttribute("InScrambleArena") then
		return false, 1e999
	end

	if workspace:GetAttribute("PvPDisabled") == true then
		return false, 1e999
	end

	local magnitude = (part.Position - p.Position).Magnitude
	return magnitude <= p2, magnitude
end

function BatController:_recordHighlightAttackerSample(timestamp: number, vector2: Vector3)
	local _highlightAttackerHistory = self._highlightAttackerHistory
	_highlightAttackerHistory[#_highlightAttackerHistory + 1] = {
		Position = vector2,
		Timestamp = timestamp
	}
	local v3 = timestamp - v

	while #_highlightAttackerHistory > 2 and _highlightAttackerHistory[2].Timestamp < v3 do
		table.remove(_highlightAttackerHistory, 1)
	end
end

function BatController:_getHighlightAttackerPositionAt(p2: number)
	local _highlightAttackerHistory = self._highlightAttackerHistory
	local v3 = _highlightAttackerHistory[1]
	local v4 = _highlightAttackerHistory[#_highlightAttackerHistory]

	if not v3 or not v4 or p2 < v3.Timestamp or v4.Timestamp < p2 then
		return nil
	end

	for i = 2, #_highlightAttackerHistory do
		local v5 = _highlightAttackerHistory[i]

		if not (p2 <= v5.Timestamp) then
			continue
		end

		local v6 = _highlightAttackerHistory[i - 1]
		local v7 = v5.Timestamp - v6.Timestamp

		if v7 <= 0 then
			return v5.Position
		end

		local v8 = math.clamp((p2 - v6.Timestamp) / v7, 0, 1)
		return v6.Position:Lerp(v5.Position, v8)
	end

	return nil
end

function BatController:_predictServerAcceptsHighlightTarget(p, p2, p3: number)
	local v3 = self._targetRange * Config.GetHitboxScalar()

	if not self:_isTargetEligible(p, p2, v3) then
		return false
	end

	local part = Player.FindRootPart(p)

	if not (part and part:IsA("BasePart")) then
		return false
	end

	local networkPing = localPlayer:GetNetworkPing()
	local _getHighlightAttackerPositionAt = self:_getHighlightAttackerPositionAt(p3 - math.clamp(
		0.14 + networkPing,
		0.14,
		Config.MaximumTargetViewAge
	))

	if not _getHighlightAttackerPositionAt then
		return false
	end

	local v4 = math.clamp(
		networkPing + Config.TargetViewSamplePadding,
		Config.TargetViewSamplePadding,
		Config.MaximumTargetViewAge
	)
	local position = part.Position
	local v5 = position + part.AssemblyLinearVelocity * v4
	local magnitude = (position - _getHighlightAttackerPositionAt).Magnitude
	local magnitude2 = (v5 - _getHighlightAttackerPositionAt).Magnitude
	return magnitude <= v3 or magnitude2 <= v3
end

function BatController:_updateHighlights()
	local character = Player.FindCharacter(localPlayer)
	local part = Player.FindRootPart(localPlayer)
	local _isEquipped = self._isEquipped

	if _isEquipped then
		if character == nil or part == nil then
			_isEquipped = false
		else
			_isEquipped = part:IsA("BasePart") and not Ragdoll.IsRagdolled(character)
		end
	end

	local v3 = nil

	if _isEquipped then
		local serverTimeNow = workspace:GetServerTimeNow()
		self:_recordHighlightAttackerSample(serverTimeNow, part.Position)
		local _selectClosestTarget = self:_selectClosestTarget()

		if _selectClosestTarget and self:_predictServerAcceptsHighlightTarget(_selectClosestTarget, part, serverTimeNow) then
			v3 = _selectClosestTarget
		end
	else
		table.clear(self._highlightAttackerHistory)
	end

	for k, _targetState in self._targetStates do
		local v4

		if k == v3 then
			v4 = Player.FindCharacter(k)
		end

		if v4 then
			self:_showHighlight(_targetState, v4)
		else
			self:_hideHighlight(_targetState)
		end
	end
end

function BatController:_selectClosestTarget()
	local character = Player.FindCharacter(localPlayer)
	local part = Player.FindRootPart(localPlayer)

	if not character or not part or not part:IsA("BasePart") or Ragdoll.IsRagdolled(character) then
		return nil
	end

	local v3 = self._targetRange * Config.GetHitboxScalar()
	local v4 = 1e999
	local v5 = nil

	for k in self._targetStates do
		local _isTargetEligible, v6 = self:_isTargetEligible(k, part, v3)

		if not (_isTargetEligible and v6 < v4) then
			continue
		end

		v5 = k
		v4 = v6
	end

	return v5
end

function BatController:_logActivationTrace(traceId: string, p3, instance)
	if not Constants.IS_STUDIO then
		return
	end

	local humanoid = Player.FindHumanoid(localPlayer)
	local part

	if p3 then
		part = Player.FindRootPart(p3)
	end

	if not (part and part:IsA("BasePart")) then
		part = nil
	end

	local v3 = not part and createVector(0, 0, 0) or part.AssemblyLinearVelocity
	local assemblyLinearVelocity = instance.AssemblyLinearVelocity
	local clientVisibleDistance = not part and -1 or (part.Position - instance.Position).Magnitude
	local interpretation = p3 == nil and "CLIENT_NO_TARGET: your PC did not nominate an eligible player inside ClientSelectionRange at the swing moment." or part == nil and "CLIENT_TARGET_ROOT_MISSING: the nominated player's rendered root disappeared before the swing was sent." or "CLIENT_TARGET_NOMINATED: this is the player and distance your PC rendered at the swing moment."
	v2:AtInfo():Log("Bat hit validation trace", {
		Stage = "CLIENT_SWING",
		TraceId = traceId,
		Interpretation = interpretation,
		ClientServerTime = workspace:GetServerTimeNow(),
		AttackerName = localPlayer.Name,
		AttackerUserId = localPlayer.UserId,
		TargetName = not p3 and "None" or p3.Name,
		TargetUserId = not p3 and 0 or p3.UserId,
		TargetNominated = p3 ~= nil,
		ClientSelectionRange = self._targetRange * Config.GetHitboxScalar(),
		ClientVisibleDistance = clientVisibleDistance,
		AttackerPosition = instance.Position,
		TargetPosition = not part and createVector(0, 0, 0) or part.Position,
		AttackerWalkSpeed = not humanoid and -1 or humanoid.WalkSpeed,
		AttackerHorizontalSpeed = Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z).Magnitude,
		TargetHorizontalSpeed = Vector3.new(v3.X, 0, v3.Z).Magnitude,
		TargetAppearsStationary = part ~= nil and Vector3.new(v3.X, 0, v3.Z).Magnitude <= 1
	})
end

function BatController:_logLocalRejection(traceId: string, decision: string, explanation: string)
	if not Constants.IS_STUDIO then
		return
	end

	local part = Player.FindRootPart(localPlayer)
	local humanoid = Player.FindHumanoid(localPlayer)
	local v3 = not (part and part:IsA("BasePart")) and createVector(0, 0, 0) or part.AssemblyLinearVelocity
	v2:AtInfo():Log("Bat hit validation trace", {
		Stage = "CLIENT_LOCAL_REJECTED",
		TraceId = traceId,
		Decision = decision,
		Explanation = explanation,
		ClientServerTime = workspace:GetServerTimeNow(),
		AttackerName = localPlayer.Name,
		AttackerUserId = localPlayer.UserId,
		AttackerPosition = not (part and part:IsA("BasePart")) and createVector(0, 0, 0) or part.Position,
		AttackerWalkSpeed = not humanoid and -1 or humanoid.WalkSpeed,
		AttackerHorizontalSpeed = Vector3.new(v3.X, 0, v3.Z).Magnitude,
		ClientCooldownSeconds = batClient.CLIENT_COOLDOWN
	})
end

function BatController:_onActivated()
	self._traceSequence += 1
	local formatted = `{localPlayer.UserId}:{self._traceSequence}:{math.floor(workspace:GetServerTimeNow() * 1000)}`

	if not self._isEquipped then
		self:_logLocalRejection(
			formatted,
			"CLIENT_TOOL_NOT_EQUIPPED",
			"The Bat Activated signal fired while this client controller did not consider the tool equipped."
		)
	elseif not ToolGameplayGuard.AllowsLocalUse(self._tool) then
		self:_logLocalRejection(
			formatted,
			"CLIENT_GAMEPLAY_GUARD_REJECTED",
			"The local gameplay-area guard rejected the swing before any server request was sent."
		)
	elseif not self._tryActivate(function()
		local character = Player.FindCharacter(localPlayer)
		local part = Player.FindRootPart(localPlayer)
		local humanoid = Player.FindHumanoid(localPlayer)

		if not character or not part or not part:IsA("BasePart") or not humanoid or humanoid.Health <= 0 or Ragdoll.IsRagdolled(character) then
			self:_logLocalRejection(
				formatted,
				"CLIENT_CHARACTER_STATE_REJECTED",
				"The client had no usable character/root, was dead or was ragdolled when the debounced swing executed."
			)
			return
		end

		local _selectClosestTarget = self:_selectClosestTarget()
		self:_logActivationTrace(formatted, _selectClosestTarget, part)
		Remotes.BatSwing.Trigger:FireServer(_selectClosestTarget, formatted)
	end) then
		self:_logLocalRejection(
			formatted,
			"CLIENT_COOLDOWN_ACTIVE",
			"The client Bat cooldown rejected this click, so no server request was sent."
		)
	end
end

function BatController:_onEquipped()
	self._isEquipped = true
end

function BatController:Destroy()
	self._trove:Destroy()

	for k in self._targetStates do
		self:_untrackPlayer(k)
	end

	v2:AtDebug():Log("Bat client controller destroyed")
end

function BatController:_init()
	for _, v3 in ipairs(Players:GetPlayers()) do
		local v4 = v3
		task.defer(function()
			self:_trackPlayer(v4)
		end)
	end

	self._trove:Connect(Players.PlayerAdded, function(p)
		self:_trackPlayer(p)
	end)
	self._trove:Connect(Players.PlayerRemoving, function(p)
		self:_untrackPlayer(p)
	end)
	self._trove:Connect(self._tool.Equipped, function()
		self:_onEquipped()
	end)
	self._trove:Connect(self._tool.Unequipped, function()
		self._isEquipped = false
		self:_updateHighlights()
	end)
	self._trove:Connect(self._tool.Activated, function()
		self:_onActivated()
	end)

	if Constants.IS_MOBILE then
		self._trove:Connect(RunService.PreRender, function()
			self:_updateHighlights()
		end)
	end

	self._trove:Connect(self._tool.Destroying, function()
		self:Destroy()
	end)
	local character = Player.FindCharacter(localPlayer)

	if character and self._tool.Parent == character then
		self:_onEquipped()
	end
end

return BatController