local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local OnlyRunOnPlayerHotbar = require(ReplicatedStorage.Modules.Shared.Components.Tools.Extensions.OnlyRunOnPlayerHotbar)
local v = Component.new({
	Tag = "DanglingTool",
	Extensions = { OnlyRunOnPlayerHotbar }
})
local localPlayer = Players.LocalPlayer
local currentCamera = Workspace.CurrentCamera

local function getStableLook(p, p2, cFrame)
	local unit = (p2 - p).Unit
	local cross = unit:Cross(cFrame.RightVector)

	if cross.Magnitude < 0.01 then
		cross = unit:Cross(cFrame.UpVector)
	end

	return CFrame.fromMatrix(p, cross.Unit, cross.Unit:Cross(unit).Unit, -unit)
end

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	assert(
		self.Instance:IsA("Tool"),
		(`DanglingTool: Component added to non-Tool instance: {self.Instance:GetFullName()}`)
	)
	self._dangleRoot = nil

	for _, descendant in self.Instance:GetDescendants() do
		if not descendant:HasTag("DangleRoot") then
			continue
		end

		self._dangleRoot = descendant
		break
	end

	if not self._dangleRoot then
		local thread = coroutine.running()
		local descendantAddedConnection = nil
		local thread2 = task.delay(3, function()
			if descendantAddedConnection then
				descendantAddedConnection:Disconnect()
			end

			task.spawn(thread, nil)
		end)
		descendantAddedConnection = self.Instance.DescendantAdded:Connect(function(descendant)
			if not descendant:HasTag("DangleRoot") then
				return
			end

			descendantAddedConnection:Disconnect()
			task.cancel(thread2)
			task.spawn(thread, descendant)
		end)
		self._dangleRoot = coroutine.yield()
	end

	assert(
		self._dangleRoot,
		(`DanglingTool: No instance tagged with DangleRoot found in {self.Instance:GetFullName()} after {3} seconds.`)
	)
	self._isEnabled = true
	self._isEquipped = false
	self._isSimulating = false
	self._links = {}
	self._resolvedParts = {
		[self._dangleRoot] = {
			isRoot = true
		}
	}
	self._pendingConstraints = {}
	self._readyConstraints = {}
	self:_setupReactive()
	self._Janitor:Add(self.Instance:GetPropertyChangedSignal("Parent"):Connect(function()
		self:_updateEquipState()
	end))
	self:_updateEquipState()
end

function v:Enable()
	if self._isEnabled then
		return
	end

	self._isEnabled = true

	if self._isEquipped then
		self:_startLodThread()
	end
end

function v:Disable(flag: boolean?)
	if not self._isEnabled then
		return
	end

	self._isEnabled = false
	self._Janitor:Remove("LodThread")
	self:_setSimulationActive(false, flag == true)
end

function v:_updateEquipState()
	local parent = self.Instance.Parent
	local humanoid = parent and parent:FindFirstChildOfClass("Humanoid")

	if humanoid and not self._isEquipped then
		self:_onEquip()
	elseif not humanoid and self._isEquipped then
		self:_onUnequip()
	end
end

function v:_setupReactive()
	local function tryResolvePending()
		for i = #self._pendingConstraints, 1, -1 do
			local _pendingConstraint = self._pendingConstraints[i]
			local attachment0 = _pendingConstraint.Attachment0
			local attachment1 = _pendingConstraint.Attachment1

			if not (attachment0 and attachment1 and attachment0.Parent and attachment1.Parent) then
				continue
			end

			local weldConstraint = _pendingConstraint.Parent:FindFirstChildOfClass("WeldConstraint")

			if not weldConstraint then
				continue
			end

			table.remove(self._pendingConstraints, i)
			table.insert(self._readyConstraints, {
				constraint = _pendingConstraint,
				weld = weldConstraint,
				att0 = attachment0,
				att1 = attachment1,
				p0 = attachment0.Parent,
				p1 = attachment1.Parent
			})
		end

		self:_tryResolveTree()
	end

	local flag = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function queueResolution()
		if flag then
			return
		end

		flag = true
		task.defer(function()
			flag = false

			if not self._pendingConstraints then
				return
			end

			tryResolvePending()
		end)
	end

	local function onDescendantAdded(ballSocketConstraint)
		if ballSocketConstraint:IsA("BallSocketConstraint") then
			table.insert(self._pendingConstraints, ballSocketConstraint)
			self._Janitor:Add(ballSocketConstraint:GetPropertyChangedSignal("Attachment0"):Connect(queueResolution))
			self._Janitor:Add(ballSocketConstraint:GetPropertyChangedSignal("Attachment1"):Connect(queueResolution))
		end

		queueResolution() -- equivalent call inferred; original call site unknown
	end

	self._Janitor:Add(self.Instance.DescendantAdded:Connect(onDescendantAdded))

	for _, descendant in self.Instance:GetDescendants() do
		onDescendantAdded(descendant)
	end
end

function v:_tryResolveTree()
	local flag = true

	while flag do
		flag = false

		for i = #self._readyConstraints, 1, -1 do
			local _readyConstraint = self._readyConstraints[i]
			local p0 = _readyConstraint.p0
			local p1 = _readyConstraint.p1
			local _resolvedPart = self._resolvedParts[p0]
			local _resolvedPart2 = self._resolvedParts[p1]

			if _resolvedPart and not _resolvedPart2 then
				self:_buildLink(
					p1,
					p0,
					_readyConstraint.att1,
					_readyConstraint.att0,
					_readyConstraint.constraint,
					_readyConstraint.weld
				)
				table.remove(self._readyConstraints, i)
				flag = true
			elseif _resolvedPart2 and not _resolvedPart then
				self:_buildLink(
					p0,
					p1,
					_readyConstraint.att0,
					_readyConstraint.att1,
					_readyConstraint.constraint,
					_readyConstraint.weld
				)
				table.remove(self._readyConstraints, i)
				flag = true
			elseif _resolvedPart and _resolvedPart2 then
				table.remove(self._readyConstraints, i)
				_readyConstraint.constraint:Destroy()
			end
		end
	end
end

function v:_buildLink(instance, p, _, anchorAtt, instance2, _)
	local _resolvedPart = self._resolvedParts[p]
	local scale = self.Instance:GetScale()
	local v2 = {
		part = instance,
		origTrans = instance.Transparency,
		parentOutgoingAtt = anchorAtt
	}

	if p == self._dangleRoot then
		v2.isRoot = true
		v2.anchorAtt = anchorAtt
		v2.initAnchorPos = self._dangleRoot.CFrame * anchorAtt.Position
	else
		v2.isRoot = false
		v2.parentLink = _resolvedPart
		v2.initAnchorPos = p.CFrame * anchorAtt.Position
	end

	v2.initPos = instance.Position
	v2.l = (v2.initPos - v2.initAnchorPos).Magnitude
	v2.baseL = v2.l / scale
	v2.offset = getStableLook(v2.initAnchorPos, v2.initPos, self._dangleRoot.CFrame):ToObjectSpace(instance.CFrame)
	v2.baseOffset = CFrame.new(v2.offset.Position / scale) * v2.offset.Rotation
	instance.Massless = true
	instance.CanCollide = false
	instance:SetAttribute("DanglingToolManaged", true)
	v2.simPart = instance:Clone()

	for _, descendant in v2.simPart:GetDescendants() do
		if not (descendant:IsA("LuaSourceContainer") or descendant:IsA("JointInstance") or descendant:IsA("Constraint") or descendant:IsA("WeldConstraint") or descendant:IsA("Attachment") or descendant:IsA("ProximityPrompt") or descendant:IsA("ClickDetector") or descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or descendant:IsA("Beam") or descendant:IsA("Sound")) then
			continue
		end

		descendant:Destroy()
	end

	v2.simPart.Anchored = true
	v2.simPart.Transparency = 1
	v2.simPart:SetAttribute("DanglingToolManaged", true)
	v2.simPart:SetAttribute("DanglingSimPart", true)
	self._Janitor:Add(v2.simPart)
	v2.simPart.Parent = self.Instance

	if self._isSimulating then
		v2.simPart.Transparency = v2.origTrans
		v2.part.Transparency = 1
		v2.pos = instance.Position
		v2.prevPos = v2.pos
	end

	self._resolvedParts[instance] = v2
	table.insert(self._links, v2)
	instance2:Destroy()
end

function v:_setSimulationActive(isSimulating, flag: boolean?)
	if self._isSimulating == isSimulating then
		return
	end

	self._isSimulating = isSimulating

	if isSimulating then
		for _, _link in self._links do
			_link.simPart.Transparency = _link.origTrans
			_link.part.Transparency = 1
			_link.pos = _link.part.Position
			_link.prevPos = _link.pos
			_link.simPart.Size = _link.part.Size
		end

		self:_startHeartbeat()
	else
		for _, _link in self._links do
			_link.simPart.Transparency = 1
			_link.part.Transparency = flag == true and 1 or _link.origTrans
		end

		self._Janitor:Remove("PhysicsLoop")
	end
end

function v:_startHeartbeat()
	local vector = Vector3.new(0, -Workspace.Gravity, 0)
	self._lastScale = self.Instance:GetScale()
	self._Janitor:Add(RunService.Heartbeat:Connect(function(dt)
		local v2 = math.min(dt, 0.033)
		local v3 = v2 * v2
		local scale = self.Instance:GetScale()

		if self._lastScale and self._lastScale ~= scale then
			local v4 = scale / self._lastScale
			local position = self._dangleRoot.Position

			for _, _link in self._links do
				if _link.pos and _link.prevPos then
					_link.pos = position + (_link.pos - position) * v4
					_link.prevPos = position + (_link.prevPos - position) * v4
				end

				_link.simPart.Size = _link.part.Size
			end
		end

		self._lastScale = scale

		for _, _link in self._links do
			local v4 = _link.pos - _link.prevPos
			_link.prevPos = _link.pos
			_link.pos = _link.pos + v4 * 0.95 + vector * v3
		end

		for _, _link in self._links do
			local v4 = _link.baseL * scale
			local v5

			if _link.isRoot then
				v5 = self._dangleRoot.CFrame * _link.anchorAtt.Position
			else
				v5 = _link.parentLink.simPart.CFrame * _link.parentOutgoingAtt.Position
			end

			local v6 = _link.pos - v5
			local magnitude = v6.Magnitude

			if magnitude > 0.001 then
				_link.pos = v5 + v6 / magnitude * v4
			else
				_link.pos = v5 + Vector3.new(0, -v4, 0)
			end

			local v7 = CFrame.new(_link.baseOffset.Position * scale) * _link.baseOffset.Rotation
			_link.simPart.CFrame = getStableLook(v5, _link.pos, self._dangleRoot.CFrame) * v7
		end
	end), "Disconnect", "PhysicsLoop")
end

function v:_startLodThread()
	local v2 = self.Instance.Parent == localPlayer.Character and true
	self._lodThread = task.spawn(function()
		task.wait()

		if not (self._isEquipped and self._isEnabled) then
			return
		end

		while self._isEquipped and self._isEnabled do
			local vector = currentCamera.CFrame.Position - self._dangleRoot.Position
			local dot = vector:Dot(vector)

			if v2 or dot < 3600 then
				self:_setSimulationActive(true)
				task.wait(0.2)
			else
				self:_setSimulationActive(false)
				local v3 = math.clamp(
					((math.abs(vector.X) + math.abs(vector.Y) + math.abs(vector.Z)) / 3 - 60) / 100,
					0.2,
					1.5
				)
				task.wait(v3)
			end
		end
	end)
	self._Janitor:Add(function()
		if self._lodThread then
			task.cancel(self._lodThread)
			self._lodThread = nil
		end
	end, true, "LodThread")
end

function v:_onEquip()
	self._isEquipped = true

	if self._isEnabled then
		self:_startLodThread()
	end
end

function v:_onUnequip()
	self._isEquipped = false
	self._Janitor:Remove("LodThread")
	self:_setSimulationActive(false)
end

function v:Stop()
	self._Janitor:Destroy()
	self._pendingConstraints = nil
end

return v