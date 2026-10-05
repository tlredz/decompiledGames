local createVector = vector.create
local TypeRegistry = require(script.Parent.TypeRegistry)
local EventsCollision = require(script.Parent.EventsCollision)
local EventsPayload = require(script.Parent.EventsPayload)
local EventsSchema = require(script.Parent.EventsSchema)
local Pool = require(script.Parent.Pool)
local Events = {}
local _ = TypeRegistry.CONFIG_NAME
local v = {}
Events._frameCount = 0
Events._burstDropped = 0
Events._burstReportPending = false
local v2 = false
local count = 0
local count2 = 0
local v3 = {}
local v4 = {}
local count3 = 0

local function nextChainId()
	count3 += 1
	return count3
end

function Events.newChainCtx()
	count3 += 1
	return {
		ChainId = count3,
		Depth = 0
	}
end

function Events.withEmitIndex(items, emitIndex)
	if not items then
		return {
			EmitIndex = emitIndex
		}
	end

	local result = {
		EmitIndex = emitIndex
	}

	for k, item in pairs(items) do
		if k ~= "EmitIndex" then
			result[k] = item
		end
	end

	return result
end

function Events.withEmitIndexAndCount(items, emitIndex, emitCount)
	if not items then
		return {
			EmitIndex = emitIndex,
			EmitCount = emitCount
		}
	end

	local result = {
		EmitIndex = emitIndex,
		EmitCount = emitCount
	}

	for k, item in pairs(items) do
		if k ~= "EmitIndex" and k ~= "EmitCount" then
			result[k] = item
		end
	end

	return result
end

function Events.withEvenOffset(items, emitIndex, emitCount, evenOffsetIdx_Pos, evenOffsetN_Pos, evenOffsetIdx_Rot, evenOffsetN_Rot)
	local result = {
		EmitIndex = emitIndex,
		EmitCount = emitCount
	}

	if items then
		for k, item in pairs(items) do
			if k ~= "EmitIndex" and k ~= "EmitCount" and k ~= "EvenOffsetIdx_Pos" and k ~= "EvenOffsetN_Pos" and k ~= "EvenOffsetIdx_Rot" and k ~= "EvenOffsetN_Rot" then
				result[k] = item
			end
		end
	end

	if evenOffsetN_Pos and evenOffsetN_Pos > 0 then
		result.EvenOffsetIdx_Pos = evenOffsetIdx_Pos
		result.EvenOffsetN_Pos = evenOffsetN_Pos
	end

	if evenOffsetN_Rot and evenOffsetN_Rot > 0 then
		result.EvenOffsetIdx_Rot = evenOffsetIdx_Rot
		result.EvenOffsetN_Rot = evenOffsetN_Rot
	end

	return result
end

function Events.descendCtx(data)
	if not data then
		return nil
	end

	if data.EventOriginCF == nil and data.IgnoreLink == nil and data.UseFullOrigin == nil and data.EventOriginResolver == nil then
		return data
	end

	return {
		ChainCtx = data.ChainCtx,
		EmitIndex = data.EmitIndex,
		EmitCount = data.EmitCount
	}
end

local v5 = pcall(function()
	return Instance.new("ModuleScript").Source
end)

function Events._compile(instance)
	if v5 then
		local clone = instance:Clone()
		clone.Name = "_CompiledEventModule"
		clone.Archivable = false
		clone.Parent = instance.Parent
		local success, result = pcall(require, clone)

		if not success then
			clone:Destroy()
			return nil, result
		end

		if type(result) == "function" then
			return result, nil, clone
		end

		clone:Destroy()
		return nil, "module must return function(payload)"
	else
		local success, result = pcall(require, instance)

		if not success then
			return nil, result
		end

		if type(result) == "function" then
			return result, nil, nil
		end

		return nil, "module must return function(payload)"
	end
end

function Events._isCacheValid(p, moduleScript)
	if not (p and moduleScript and moduleScript:IsA("ModuleScript") and moduleScript.Name == "Module") then
		return false
	end

	local expectedEventCfg = p.expectedEventCfg

	if not (expectedEventCfg and expectedEventCfg.Parent and expectedEventCfg.Name == p.expectedEventName) then
		return false
	end

	if expectedEventCfg.Parent and expectedEventCfg.Parent.Name == "Events" then
		return moduleScript.Parent == expectedEventCfg
	end

	return false
end

function Events._invalidate(p)
	local v6 = v[p]

	if not v6 then
		return
	end

	if v6.sourceConn then
		v6.sourceConn:Disconnect()
		v6.sourceConn = nil
	end

	if v6.ancestryConn then
		v6.ancestryConn:Disconnect()
		v6.ancestryConn = nil
	end

	if v6.nameConn then
		v6.nameConn:Disconnect()
		v6.nameConn = nil
	end

	if v6.compiledClone then
		pcall(function()
			v6.compiledClone:Destroy()
		end)
		v6.compiledClone = nil
	end

	v[p] = nil
end

function Events:compile()
	if not (self and self:IsA("ModuleScript")) then
		return nil
	end

	local v6 = v[self]

	if v6 and not v6.dirty and Events._isCacheValid(v6, self) then
		return v6.fn
	end

	if v6 then
		Events._invalidate(self)
	end

	local _compile, v7, compiledClone = Events._compile(self)

	if not _compile then
		Events.reportScriptError(self, v7)
		return nil
	end

	local parent = self.Parent

	if not (parent and parent:IsA("Configuration")) then
		compiledClone:Destroy()
		return nil
	end

	local v9 = {
		fn = _compile,
		expectedEventCfg = parent,
		expectedEventName = parent.Name,
		dirty = false,
		compiledClone = compiledClone
	}

	if v5 then
		v9.sourceConn = self:GetPropertyChangedSignal("Source"):Connect(function()
			if v[self] then
				v[self].dirty = true
			end
		end)
	end

	v9.ancestryConn = self.AncestryChanged:Connect(function()
		if not Events._isCacheValid(v[self], self) then
			Events._invalidate(self)
		end
	end)
	v9.nameConn = self:GetPropertyChangedSignal("Name"):Connect(function()
		if self.Name ~= "Module" then
			pcall(function()
				self.Name = "Module"
			end)
		end
	end)
	v[self] = v9
	return _compile
end

function Events.cleanup()
	local v6 = {}

	for k in pairs(v) do
		table.insert(v6, k)
	end

	for _, v7 in ipairs(v6) do
		Events._invalidate(v7)
	end

	count2 += 1
	Events._frameCount = 0
	Events._burstDropped = 0
	Events._burstReportPending = false
	count = 0
	v2 = false
	table.clear(v3)
	table.clear(v4)
end

function Events._reportBurst()
	Events._burstDropped += 1

	if not Events._burstReportPending then
		Events._burstReportPending = true
		local v7 = count2
		task.delay(1, function()
			if v7 ~= count2 then
				return
			end

			if Events._burstDropped > 0 then
				warn(("[Part-Icles Events] dropped %d event fires this second."):format(Events._burstDropped))
			end

			Events._burstDropped = 0
			Events._burstReportPending = false
		end)
	end
end

function Events.reserveFrameFire()
	if Events._frameCount >= 256 then
		Events._reportBurst()
		return false
	end

	Events._frameCount += 1
	return true
end

function Events.tickFrame()
	Events._frameCount = 0
end

function Events.dropDepth(p)
	count += 1

	if not v2 then
		v2 = true
		local v6 = count2
		task.delay(1, function()
			if v6 ~= count2 then
				return
			end

			if count > 0 then
				warn(("[Part-Icles Events] dropped %d event fire(s) this second (chain depth limit reached%s)."):format(
					count,
					p and " on " .. p or ""
				))
			end

			count = 0
			v2 = false
		end)
	end
end

function Events.reportScriptError(instance, p)
	local fullName = instance and instance:GetFullName() or "<destroyed>"
	warn(("[Part-Icles Events] %s\n  %s"):format(fullName, (tostring(p))))
end

function Events.getWorldCF(p)
	local visualPart = p.VisualPart

	if not (visualPart and visualPart.Parent) then
		return nil
	end

	if visualPart:IsA("BasePart") then
		return visualPart.CFrame
	end

	if visualPart:IsA("Attachment") then
		return visualPart.WorldCFrame
	end

	if visualPart:IsA("Model") then
		return visualPart:GetPivot()
	end

	if visualPart:IsA("PointLight") then
		local parent = visualPart.Parent

		if parent and parent:IsA("BasePart") then
			return parent.CFrame
		end

		if parent and parent:IsA("Attachment") then
			return parent.WorldCFrame
		end

		return nil
	else
		if not visualPart:IsA("Beam") then
			return nil
		end

		local attachment0 = visualPart.Attachment0

		if not attachment0 then
			return nil
		end

		local attachment1 = visualPart.Attachment1

		if attachment1 then
			return CFrame.new((attachment0.WorldPosition + attachment1.WorldPosition) * 0.5)
		end

		return CFrame.new(attachment0.WorldPosition)
	end
end

function Events.getWorldPosition(p)
	local worldCF = Events.getWorldCF(p)
	return worldCF and worldCF.Position or nil
end

function Events.getSourceWorldCF(instance)
	if not (instance and instance.Parent) then
		return nil
	end

	if instance:IsA("BasePart") then
		return instance.CFrame
	end

	if instance:IsA("Attachment") then
		return instance.WorldCFrame
	end

	if instance:IsA("Model") then
		return instance:GetPivot()
	end

	if instance:IsA("Beam") then
		local attachment0 = instance.Attachment0

		if not attachment0 then
			return nil
		end

		local attachment1 = instance.Attachment1

		if attachment1 then
			return CFrame.new((attachment0.WorldPosition + attachment1.WorldPosition) * 0.5)
		end

		return CFrame.new(attachment0.WorldPosition)
	else
		if not instance:IsA("PointLight") then
			return nil
		end

		local parent = instance.Parent

		if parent and parent:IsA("BasePart") then
			return parent.CFrame
		end

		if parent and parent:IsA("Attachment") then
			return parent.WorldCFrame
		end

		return nil
	end
end

function Events:makeHitParams()
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	local filterDescendantsInstances = {}

	if self.VisualPart then
		table.insert(filterDescendantsInstances, self.VisualPart)
	end

	if self._sourceItem then
		table.insert(filterDescendantsInstances, self._sourceItem)
	end

	if self._sourceItem then
		local renderTemplate = self._sourceItem:FindFirstChild("RenderTemplate")

		if renderTemplate then
			table.insert(filterDescendantsInstances, renderTemplate)
		end

		local emitParent = self._sourceItem:FindFirstChild("EmitParent")

		if emitParent and emitParent:IsA("ObjectValue") and emitParent.Value then
			table.insert(filterDescendantsInstances, emitParent.Value)
		end
	end

	if self.VisualPart and self.VisualPart:IsA("Attachment") and self.VisualPart.Parent then
		table.insert(filterDescendantsInstances, self.VisualPart.Parent)
	end

	if self._sourceItem then
		local event = EventsSchema.readEvent(self._sourceItem, "OnHit")

		if event then
			local collisionGroup = event:GetAttribute("CollisionGroup")

			if type(collisionGroup) == "string" and collisionGroup ~= "" then
				pcall(function()
					raycastParams.CollisionGroup = collisionGroup
				end)
			end

			local excludeList = event:FindFirstChild("ExcludeList")

			if excludeList then
				for _, objectValue in ipairs(excludeList:GetChildren()) do
					if objectValue:IsA("ObjectValue") and objectValue.Value then
						table.insert(filterDescendantsInstances, objectValue.Value)
					end
				end
			end
		end
	end

	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	raycastParams.IgnoreWater = true
	return raycastParams
end

function Events.makePayload(_, p, p2, p3)
	return EventsPayload.build(p, p2, p3, Events.getWorldCF(p))
end

function Events.resolveEmitModeCF(p, data, p2)
	if p == "AtPosition" then
		if data and data._eventName == "OnEmit" then
			local worldCF = Events.getWorldCF(p2)

			if worldCF then
				return worldCF
			end

			if p2.CurrentPosition then
				return CFrame.new(p2.CurrentPosition)
			end
		end

		local hitPosition = data.HitPosition or data.DeathPosition or data.EmitPosition

		if hitPosition and data._eventName == "OnHit" and data.HitNormal then
			hitPosition += data.HitNormal * 0.1
		end

		return hitPosition and CFrame.new(hitPosition) or nil
	else
		if p == "AtSource" then
			return Events.getSourceWorldCF(p2._sourceItem)
		end

		if p ~= "AtCFrame" then
			return nil
		end

		local v6 = data and data._eventName == "OnEmit" and Events.getWorldCF(p2)

		if v6 then
			return v6
		end

		local worldCFrame = data and data.WorldCFrame

		if worldCFrame and data._eventName == "OnHit" and data.HitNormal then
			worldCFrame += data.HitNormal * 0.1
		end

		return worldCFrame or nil
	end
end

function Events._supportsOriginOverride(instance)
	return instance:IsA("BasePart") or instance:IsA("Attachment") or instance:IsA("Model")
end

local function _newHolderPart()
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Massless = true
	part.Transparency = 1
	part.Size = createVector(0.001, 0.001, 0.001)
	part.Archivable = false
	return part
end

local function _anchorClone(part)
	if part:IsA("BasePart") then
		part.Anchored = true
	end

	for _, part2 in ipairs(part:GetDescendants()) do
		if part2:IsA("BasePart") then
			part2.Anchored = true
		end
	end
end

local function _positionClone(instance, cframe)
	if instance:IsA("Model") then
		instance:PivotTo(cframe)
	elseif instance:IsA("BasePart") then
		instance.CFrame = cframe
	elseif instance:IsA("Attachment") then
		instance.WorldCFrame = cframe
	end
end

local function _getAttachmentHolder(object)
	local folder = object:GetFolder()
	local _AttachmentHolder = folder:FindFirstChild("_AttachmentHolder")

	if _AttachmentHolder then
		return _AttachmentHolder
	end

	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Massless = true
	part.Transparency = 1
	part.Size = createVector(0.001, 0.001, 0.001)
	part.Archivable = false
	part.Name = "_AttachmentHolder"
	part.CFrame = CFrame.new()
	part.Parent = folder
	return part
end

local function _stampAuthoredEnabled(folder)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function visit(effect)
		if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
			pcall(function()
				effect:SetAttribute("_PartIcleAuthoredEnabled", effect.Enabled)
			end)
		end
	end

	visit(folder) -- equivalent call inferred; original call site unknown

	for _, descendant in ipairs(folder:GetDescendants()) do
		visit(descendant) -- equivalent call inferred; original call site unknown
	end
end

local function _restoreAuthoredEnabled(folder)
	local function visit(effect)
		if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
			local _PartIcleAuthoredEnabled = effect:GetAttribute("_PartIcleAuthoredEnabled")
			pcall(function()
				effect.Enabled = _PartIcleAuthoredEnabled == true
			end)
		end
	end

	visit(folder)

	for _, descendant in ipairs(folder:GetDescendants()) do
		visit(descendant)
	end
end

local function _killEmittersForRelease(folder)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function visit(effect)
		if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
			pcall(function()
				effect.Enabled = false
			end)
		end
	end

	visit(folder) -- equivalent call inferred; original call site unknown

	for _, descendant in ipairs(folder:GetDescendants()) do
		visit(descendant) -- equivalent call inferred; original call site unknown
	end
end

local function _kindFor(trail)
	if trail:IsA("BasePart") then
		return "Part"
	end

	if trail:IsA("Model") or trail:IsA("Folder") then
		return "Model"
	end

	if trail:IsA("Attachment") then
		return "Attachment"
	end

	if trail:IsA("ParticleEmitter") then
	end

	return "Part"
end

local function _computeCloneLifetime(folder)
	local v6 = 2

	local function visit(effect)
		if effect:IsA("ParticleEmitter") then
			local emitDelay = tonumber(effect:GetAttribute("EmitDelay")) or 0
			local emitDuration = tonumber(effect:GetAttribute("EmitDuration")) or 0
			local v7 = 2
			pcall(function()
				v7 = math.max(v7, effect.Lifetime.Max)
			end)
			local v8 = emitDelay + emitDuration + v7 + 0.5

			if v6 < v8 then
				v6 = v8
			end
		elseif effect:IsA("Trail") then
			local emitDuration = tonumber(effect:GetAttribute("EmitDuration")) or 0
			local v7 = 2
			pcall(function()
				v7 = math.max(v7, effect.Lifetime)
			end)
			local v8 = emitDuration + v7 + 0.5

			if v6 < v8 then
				v6 = v8
			end
		end
	end

	visit(folder)

	for _, descendant in ipairs(folder:GetDescendants()) do
		visit(descendant)
	end

	return v6 > 600 and 600 or v6
end

local function _buildEmitClone(trail)
	local parent = nil

	if trail:IsA("BasePart") then
		parent = trail:Clone()
		parent.Archivable = false
	elseif trail:IsA("Model") then
		parent = trail:Clone()
		parent.Archivable = false
	elseif trail:IsA("Folder") then
		parent = Instance.new("Model")
		parent.Archivable = false
		local clone = trail:Clone()
		clone.Archivable = false
		clone.Parent = parent

		for _, part in ipairs(clone:GetDescendants()) do
			if not part:IsA("BasePart") or part:GetAttribute("_isAnchor") then
				continue
			end

			parent.WorldPivot = CFrame.new(part.Position)
			break
		end
	elseif trail:IsA("Attachment") then
		parent = trail:Clone()
	elseif trail:IsA("ParticleEmitter") then
		parent = Instance.new("Part")
		parent.Anchored = true
		parent.CanCollide = false
		parent.CanQuery = false
		parent.CanTouch = false
		parent.Massless = true
		parent.Transparency = 1
		parent.Size = createVector(0.001, 0.001, 0.001)
		parent.Archivable = false

		if trail.Parent and trail.Parent:IsA("BasePart") then
			pcall(function()
				parent.Size = trail.Parent.Size
			end)
		end

		local clone_2 = trail:Clone()
		clone_2.Parent = parent
	end

	if parent then
		_stampAuthoredEnabled(parent)
		pcall(function()
			parent:SetAttribute("_PartIcleEmit", true)
		end)
	end

	return parent
end

function Events._emitTransformed(object, instance, p, p2, p3, p4, value)
	local v6 = p4 or Events.newChainCtx()
	local depth = v6.Depth + 1

	if (value or 4) <= depth then
		Events.dropDepth(p2 and p2._eventName)
		return
	end

	local chainCtx = {
		ChainId = v6.ChainId,
		Depth = depth
	}
	local v9 = {
		ChainCtx = chainCtx,
		EventDriven = true
	}

	if p == "AtTarget" then
		object:EnableEmit(instance, nil, v9)
	elseif Events._supportsOriginOverride(instance) then
		local emitModeCF = Events.resolveEmitModeCF(p, p2, p3)

		if emitModeCF then
			if not object.EnableEmitAt then
				warn("[Part-Icles Events] EnableEmitAt missing on particle; skipped origin-override emit")
				return
			end

			local function originResolver()
				return Events.resolveEmitModeCF(p, p2, p3) or emitModeCF
			end

			object:EnableEmitAt(instance, emitModeCF, {
				IgnoreLink = true,
				ChainCtx = chainCtx,
				OriginResolver = originResolver,
				UseFullOrigin = p == "AtCFrame",
				EventDriven = true
			})
		else
			local v10 = tostring(p) .. ":" .. tostring(p2 and p2._eventName)

			if not v4[v10] then
				v4[v10] = true
				warn(("[Part-Icles Events] EmitMode %q has no resolvable origin (payload position nil)"):format((tostring(p))))
			end
		end
	else
		local v10 = tostring(p) .. ":" .. instance.ClassName

		if not v3[v10] then
			v3[v10] = true
			warn(("[Part-Icles Events] transformed %s target requires EmitMode=AtTarget"):format(instance.ClassName))
		end
	end
end

function Events.emitTargetInstance(object, trail, p, p2, p3, chainCtx, p5)
	if not (trail and trail.Parent) then
		return
	end

	if p == nil or p == "AtTarget" or trail:IsA("Trail") then
		if trail:GetAttribute("Transformed") then
			Events._emitTransformed(object, trail, p, p2, p3, chainCtx, p5)
		else
			pcall(function()
				object:AbsoluteEmit(trail, false, {
					ChainCtx = chainCtx
				})
			end)
		end
	else
		if trail:GetAttribute("Transformed") then
			Events._emitTransformed(object, trail, p, p2, p3, chainCtx, p5)
			return
		end

		local emitModeCF = Events.resolveEmitModeCF(p, p2, p3)

		if not emitModeCF then
			pcall(function()
				object:AbsoluteEmit(trail, false, {
					ChainCtx = chainCtx
				})
			end)
			return
		end

		local v6 = _kindFor(trail)
		local attachment = Pool.acquire(trail, v6)
		local v7

		if attachment then
			v7 = false
		else
			attachment = _buildEmitClone(trail)

			if attachment then
				v7 = true
			else
				pcall(function()
					object:AbsoluteEmit(trail, false, {
						ChainCtx = chainCtx
					})
				end)
				return
			end
		end

		if not v7 then
			_restoreAuthoredEnabled(attachment)
			Pool.restoreTrails(attachment, v6)
		end

		if attachment:IsA("Attachment") then
			local folder = object:GetFolder()
			local parent = folder:FindFirstChild("_AttachmentHolder")

			if not parent then
				parent = Instance.new("Part")
				parent.Anchored = true
				parent.CanCollide = false
				parent.CanQuery = false
				parent.CanTouch = false
				parent.Massless = true
				parent.Transparency = 1
				parent.Size = createVector(0.001, 0.001, 0.001)
				parent.Archivable = false
				parent.Name = "_AttachmentHolder"
				parent.CFrame = CFrame.new()
				parent.Parent = folder
			end

			attachment.Parent = parent
			attachment.WorldCFrame = emitModeCF
		else
			_anchorClone(attachment)
			local instance = attachment

			if instance:IsA("Model") then
				instance:PivotTo(emitModeCF)
			elseif instance:IsA("BasePart") then
				instance.CFrame = emitModeCF
			elseif instance:IsA("Attachment") then
				instance.WorldCFrame = emitModeCF
			end

			attachment.Parent = object:GetFolder()
			local instance2 = attachment

			if instance2:IsA("Model") then
				instance2:PivotTo(emitModeCF)
			elseif instance2:IsA("BasePart") then
				instance2.CFrame = emitModeCF
			elseif instance2:IsA("Attachment") then
				instance2.WorldCFrame = emitModeCF
			end
		end

		local v8 = {
			ChainCtx = chainCtx,
			UseFullOrigin = p == "AtCFrame",
			IgnoreLink = p == "AtPosition" or p == "AtCFrame",
			SkipClone = true
		}
		pcall(function()
			object:AbsoluteEmitAt(attachment, emitModeCF, v8)
		end)
		local v9 = _computeCloneLifetime(attachment)
		task.delay(v9, function()
			if not attachment.Parent then
				return
			end

			_killEmittersForRelease(attachment)
			Pool.release(attachment, trail, v6, nil)
		end)
	end
end

function Events:fire(state, p, p2, p3)
	local v6 = p2 or Events.newChainCtx()
	local v7 = state.Events and state.Events[p]

	if not (v7 and v7.Enabled) then
		return
	end

	local v8 = math.clamp(math.floor(tonumber(v7.ChainDepthLimit) or 4), 1, 32)

	if v8 <= v6.Depth then
		Events.dropDepth(p)
		return
	end

	if not (v7.EmitTarget or v7.Module) then
		return
	end

	local v9 = p3 or Events.makePayload(self, state, p, nil)
	v9._eventName = v9._eventName or p

	if not Events.reserveFrameFire() then
		return
	end

	v9.Source = v9.Source or state._sourceItem
	v9.Particle = v9.Particle or state.VisualPart
	v9.RenderTemplate = v9.RenderTemplate or v9.Particle

	if v7.Module then
		function v9.Emit(p4, p5)
			Events.emitTargetInstance(self, p4, p5 or v7.EmitMode, v9, state, v6, v8)
		end

		function v9.Kill()
			if self._killParticle then
				self:_killParticle(state, {
					fireOnDeath = false
				})
			end
		end

		EventsPayload.attachSkipSetters(v9, state)

		function v9.SetColor(p4)
			EventsPayload.applyColor(state, p4)
		end

		function v9.SetTransparency(p4)
			EventsPayload.applyTransparency(state, p4)
		end

		function v9.Teleport(p4)
			EventsPayload.applyTeleport(state, p4)
		end

		EventsPayload.attachAdvancedSetters(v9, state)

		function v9.SetSpeedMultiplier(speedMultiplier)
			if type(speedMultiplier) == "number" then
				state.SpeedMultiplier = speedMultiplier
			end
		end

		function v9.SetLifetime(value)
			if type(value) == "number" then
				state.LifeTime = math.max(0.001, value)
			end
		end
	end

	local v10 = #self.ActiveEmits + (self._lingerVisualCount or 0) >= (self.MAX_ACTIVE_PARTICLES or 1000)

	if v10 and v7.EmitTarget and not Events._capSkipWarned then
		Events._capSkipWarned = true
		warn("[Part-Icles Events] active-particle cap reached; event EmitTargets are being skipped")
	end

	if v7.EmitTarget and not v10 then
		Events.emitTargetInstance(self, v7.EmitTarget, v7.EmitMode, v9, state, v6, v8)
	end

	local v11 = v7.Module and Events.compile(v7.Module)

	if v11 then
		task.spawn(function()
			local v12, v13 = xpcall(v11, debug.traceback, v9)

			if not v12 then
				Events.reportScriptError(v7.Module, v13)
			end
		end)
	end
end

function Events.afterUpdate(p, state, _, lastHitCheckTime)
	if not (state.Events and state.Events.OnHit) or state._ownsOnHit then
		return
	end

	if state._lastEffectiveDt and state._lastEffectiveDt < 0 then
		state.LastHitCheckPos = Events.getWorldPosition(state)
		state.LastHitCheckTime = lastHitCheckTime
	else
		local worldPosition = Events.getWorldPosition(state)

		if not worldPosition then
			return
		end

		if state.LastHitCheckPos then
			local hitCheckInterval = state.Events.OnHit.HitCheckInterval or 0

			if hitCheckInterval > 0 and lastHitCheckTime - (state.LastHitCheckTime or 0) < hitCheckInterval then
				return
			end

			local lastHitCheckPos = state.LastHitCheckPos
			local v6 = lastHitCheckTime - (state.LastHitCheckTime or lastHitCheckTime)
			local v7 = v6 <= 0 and 0.016666666666666666 or v6
			local v8 = worldPosition - lastHitCheckPos

			if v8.Magnitude > 0.05 then
				local raycastResult = workspace:Raycast(lastHitCheckPos, v8, state.HitParams)

				if raycastResult then
					if not state._hitFired then
						local payload = Events.makePayload(p, state, "OnHit", nil)
						payload.HitInstance = raycastResult.Instance
						payload.Other = raycastResult.Instance
						payload.HitPosition = raycastResult.Position
						payload.HitNormal = raycastResult.Normal
						Events.fire(p, state, "OnHit", state.EventChainCtx, payload)

						if EventsCollision.handle(p, state, raycastResult, v8, v7) == "snap" then
							return
						end
					end
				elseif not state._collisionStopped then
					state._hitFired = false
				end

				state.LastHitCheckPos = worldPosition
				state.LastHitCheckTime = lastHitCheckTime
			end
		else
			state.LastHitCheckPos = worldPosition
			state.LastHitCheckTime = lastHitCheckTime
		end
	end
end

return Events