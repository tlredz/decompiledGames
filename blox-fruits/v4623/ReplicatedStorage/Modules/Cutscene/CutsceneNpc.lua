local createVector = vector.create
local v = {
	Tween = game:GetService("TweenService")
}
local modules = {
	Maid = require(game.ReplicatedStorage.Util.Maid),
	Signal = require(game.ReplicatedStorage.Util.Signal),
	Animation = require(script.Parent.CutsceneUtil.Animation),
	Appearance = require(script.Parent.CutsceneUtil.Appearance)
}
require(script.Parent.Types)
local class = {}
class.__index = class
local v3 = {}
local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

function v3:cloneTemplate()
	assert(self:IsA("Model"), "CutsceneNpc template must be a Model")
	local archivable = self.Archivable
	self.Archivable = true
	local success, result = pcall(self.Clone, self)
	self.Archivable = archivable

	if not success then
		error(`Failed to clone cutscene NPC "{self.Name}": {tostring(result)}`, 3)
	end

	return result
end

function v3.shouldStrip(instance)
	return instance:IsA("LuaSourceContainer") or instance:IsA("ProximityPrompt") or instance:IsA("ClickDetector")
end

function v3:findRoot()
	local primaryPart = self.PrimaryPart or self:FindFirstChild("HumanoidRootPart", true) or self:FindFirstChild(
		"Torso",
		true
	) or self:FindFirstChild("UpperTorso", true) or self:FindFirstChildWhichIsA("BasePart", true)
	assert(primaryPart and primaryPart:IsA("BasePart"), (`Cutscene NPC "{self.Name}" has no usable pivot part`))
	self.PrimaryPart = primaryPart
	return primaryPart
end

function v3.ensureAnimator(parent)
	local humanoid = parent:FindFirstChildWhichIsA("Humanoid", true)
	local parent2 = parent:FindFirstChildWhichIsA("AnimationController", true)

	if humanoid then
		parent2 = humanoid
	elseif not parent2 then
		parent2 = Instance.new("AnimationController")
		parent2.Parent = parent
	end

	local animator = parent2:FindFirstChildWhichIsA("Animator")

	if animator then
		return animator
	end

	local animator2 = Instance.new("Animator")
	animator2.Parent = parent2
	return animator2
end

function v3.prepareModel(folder, p, data)
	if data.StripScripts ~= false then
		for _, descendant in folder:GetDescendants() do
			if v3.shouldStrip(descendant) then
				descendant:Destroy()
			end
		end
	end

	local anchorRoot = data.AnchorRoot ~= false
	local canCollide = data.CanCollide == true
	local canTouch = data.CanTouch == true
	local canQuery = data.CanQuery == true

	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Anchored = anchorRoot and descendant == p
			descendant.CanCollide = canCollide
			descendant.CanTouch = canTouch
			descendant.CanQuery = canQuery
			descendant.Massless = true
			descendant.AssemblyLinearVelocity = createVector(0, 0, 0)
			descendant.AssemblyAngularVelocity = createVector(0, 0, 0)

			if data.CastShadow ~= nil then
				descendant.CastShadow = data.CastShadow
			end
		elseif descendant:IsA("Humanoid") then
			descendant.AutoRotate = false
			descendant.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		end
	end
end

function v3.resolveTargetPosition(model)
	if typeof(model) == "Vector3" then
		return model
	end

	if typeof(model) == "CFrame" then
		return model.Position
	end

	if model:IsA("Model") then
		return model:GetPivot().Position
	end

	return model.Position
end

function v3:finishMove(lastMoveStatus)
	local _activeMove = self._activeMove

	if not _activeMove then
		return
	end

	self._activeMove = nil

	if lastMoveStatus == "Completed" and not self._destroyed then
		self._model:PivotTo(_activeMove.Goal)
	end

	_activeMove.Maid:DoCleaning()
	self._lastMoveId = _activeMove.Id
	self._lastMoveStatus = lastMoveStatus
	self.MoveFinished:Fire(lastMoveStatus)
end

function v3.animationMaidKey(p: string)
	return (`Animation_{p}`)
end

function class.new(p, parent, options)
	local v4 = options or {}
	local template = v3.cloneTemplate(p)
	template.Name = v4.Name or p.Name
	modules.Appearance.restore(template)

	if v4.Appearance then
		modules.Appearance.apply(template, v4.Appearance)
	end

	local root = v3.findRoot(template)
	v3.prepareModel(template, root, v4)
	local animator = v3.ensureAnimator(template)
	local maid = modules.Maid.new()
	local signal = modules.Signal()
	local object = setmetatable({
		_maid = maid,
		_model = template,
		_rootPart = root,
		_animator = animator,
		_animationMaids = {},
		_animationTracks = {},
		_activeMove = nil,
		_nextMoveId = 0,
		_lastMoveId = nil,
		_lastMoveStatus = nil,
		_destroyed = false,
		MoveFinished = signal
	}, class)
	maid:GiveTask(signal)
	maid:GiveTask(template)

	if v4.Pivot then
		template:PivotTo(v4.Pivot)
	end

	template.Parent = parent
	return object
end

function class.is(p)
	return typeof(p) == "table" and getmetatable(p) == class
end

function class:GetModel()
	return self._model
end

function class:PivotTo(cframe: CFrame)
	assert(not self._destroyed, "CutsceneNpc is destroyed")
	v3.finishMove(self, "Replaced")
	self._model:PivotTo(cframe)
end

function class:LookAt(p)
	assert(not self._destroyed, "CutsceneNpc is destroyed")
	local position = self._model:GetPivot().Position
	local targetPosition = v3.resolveTargetPosition(p)

	if (targetPosition - position).Magnitude <= 0.00001 then
		return
	end

	self:PivotTo(CFrame.lookAt(position, targetPosition))
end

function class:TweenTo(cframe: CFrame, p)
	assert(not self._destroyed, "CutsceneNpc is destroyed")
	v3.finishMove(self, "Replaced")
	self._nextMoveId += 1
	local _nextMoveId = self._nextMoveId
	local cFrameValue = Instance.new("CFrameValue")
	cFrameValue.Value = self._model:GetPivot()
	local tween = v.Tween:Create(cFrameValue, p or tweenInfo, {
		Value = cframe
	})
	local maid = modules.Maid.new()
	self._activeMove = {
		Id = _nextMoveId,
		Maid = maid,
		Tween = tween,
		Goal = cframe
	}
	maid:GiveTask(cFrameValue:GetPropertyChangedSignal("Value"):Connect(function()
		if not self._destroyed and self._activeMove and self._activeMove.Id == _nextMoveId then
			self._model:PivotTo(cFrameValue.Value)
		end
	end))
	maid:GiveTask(tween.Completed:Connect(function(p2)
		if self._activeMove and self._activeMove.Id == _nextMoveId then
			v3.finishMove(self, p2 == Enum.PlaybackState.Completed and "Completed" or "Cancelled")
		end
	end))
	maid:GiveTask(tween)
	maid:GiveTask(cFrameValue)
	tween:Play()
	return tween
end

function class:MoveTo(cframe: CFrame, p)
	self:TweenTo(cframe, p)
	local _nextMoveId = self._nextMoveId

	while self._lastMoveId ~= _nextMoveId do
		self.MoveFinished:Wait()
	end

	return self._lastMoveStatus
end

function class:PlayAnimation(p: string, p2)
	assert(not self._destroyed, "CutsceneNpc is destroyed")
	local v4

	if p2 then
		v4 = p2.FadeTime
	end

	self:StopAnimation(p, v4)
	local maid = modules.Maid.new()
	local v5 = modules.Animation.play(self._model, p, p2, maid)
	self._animationMaids[p] = maid
	self._animationTracks[p] = v5
	self._maid[v3.animationMaidKey(p)] = maid
	return v5
end

function class:StopAnimation(value, p: number?)
	local v4 = nil

	if typeof(value) == "string" then
		v4 = value
	elseif value ~= nil then
		for k, _animationTrack in self._animationTracks do
			if _animationTrack ~= value then
				continue
			end

			v4 = k
			break
		end
	end

	if v4 then
		local _animationTrack = self._animationTracks[v4]

		if _animationTrack then
			modules.Animation.stop(_animationTrack, p)
		end

		self._animationTracks[v4] = nil
		self._animationMaids[v4] = nil
		self._maid[v3.animationMaidKey(v4)] = nil
	else
		local v5 = {}

		for k in self._animationTracks do
			table.insert(v5, k)
		end

		for _, v6 in v5 do
			self:StopAnimation(v6, p)
		end
	end
end

function class:SetAttributes(items)
	assert(not self._destroyed, "CutsceneNpc is destroyed")

	for k, item in items do
		self._model:SetAttribute(k, item)
	end

	modules.Appearance.restore(self._model)
end

function class:ApplyAppearance(p2)
	assert(not self._destroyed, "CutsceneNpc is destroyed")
	modules.Appearance.apply(self._model, p2)
end

function class:Destroy()
	if self._destroyed then
		return
	end

	self._destroyed = true
	v3.finishMove(self, "Destroyed")
	self:StopAnimation(nil, 0)
	self._maid:DoCleaning()
end

return table.freeze(class)