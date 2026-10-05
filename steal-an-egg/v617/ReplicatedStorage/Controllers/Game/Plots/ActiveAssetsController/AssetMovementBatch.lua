local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Log = require(ReplicatedStorage.Packages.Log)
local Trove = require(ReplicatedStorage.Packages.Trove)
local t = require(ReplicatedStorage.Packages.t)
local ModelBounds = require(ReplicatedStorage.Shared.Utils.ModelBounds)
local PlacedEggRenderer = require(ReplicatedStorage.Shared.Eggs.PlacedEggRenderer)
local PlotState = require(ReplicatedStorage.Client.PlotState)
require(script.Parent.Types)
local PetUpdateSchedule = require(script.Parent.PetUpdateSchedule)
local GameFlags = require(ReplicatedStorage.Shared.Flags.GameFlags)
local v = Log.new()
local AssetMovementBatch = {}
AssetMovementBatch.__index = AssetMovementBatch
AssetMovementBatch.__class = "AssetMovementBatch"
assert(workspace.Transient:IsA("Folder"), "Workspace.Transient must be a Folder")
local world = workspace.World
assert(world:IsA("Folder"), "Workspace.World must be a Folder")
local areas = world.Areas
assert(areas:IsA("Folder"), "Workspace.World.Areas must be a Folder")
local ground = areas.Ground
assert(ground:IsA("BasePart"), "Workspace.World.Areas.Ground must be a BasePart")

function AssetMovementBatch.new()
	local self = setmetatable({}, AssetMovementBatch)
	self._trove = Trove.new()
	self._entries = {}
	self._orderedModels = {}
	self._partsBuffer = {}
	self._cframeBuffer = {}
	self._foreignEntryCount = 0
	self._foreignPresentationSuppressed = false
	self._foreignPresentationForcedSuppressed = false
	self._scheduleSettings = {
		Enabled = true,
		HiddenInterval = 0.1,
		DistantInterval = 0.1,
		DistantDistance = 300
	}
	self:_init()
	v:AtDebug():Log("Created asset movement batch")
	return self
end

function AssetMovementBatch._createGroundingRaycastParams(p)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = { PlacedEggRenderer.GetRenderFolder(), ground, p }
	raycastParams.IgnoreWater = true
	return raycastParams
end

function AssetMovementBatch._groundCFrame(p: number, cframe: CFrame, p2)
	local position = cframe.Position
	local v2 = position + createVector(0, 64, 0)
	local raycastResult = workspace:Raycast(v2, createVector(0, -2000, 0), p2)

	if raycastResult == nil then
		return nil
	end

	local vector2 = Vector3.new(position.X, raycastResult.Position.Y - p, position.Z)
	return CFrame.new(vector2) * cframe.Rotation
end

function AssetMovementBatch._groundTargetCFrame(data)
	local _groundCFrame = AssetMovementBatch._groundCFrame(
		data.BottomLocalY,
		data.TargetCFrame,
		data.GroundingRaycastParams
	)

	if _groundCFrame ~= nil then
		return _groundCFrame
	end

	local targetCFrame = data.TargetCFrame
	local position = targetCFrame.Position
	local Y = data.SimulationCFrame.Position.Y
	return CFrame.new(position.X, Y, position.Z) * targetCFrame.Rotation
end

function AssetMovementBatch._movementAlpha(p: number)
	return (math.clamp(p * 8, 0, 1))
end

function AssetMovementBatch._airborneMovementAlpha(p: number)
	return (math.clamp(p * 14, 0, 0.45))
end

function AssetMovementBatch._isPresentationEnabled(p, flag: boolean)
	return not p.PresentationHidden and (p.IsLocalOwner or not flag)
end

function AssetMovementBatch:_advanceSuppressedSimulation()
	local targetCFrame = self.TargetCFrame
	local position = targetCFrame.Position
	local position2 = self.SimulationCFrame.Position
	self.SimulationCFrame = CFrame.new(position.X, position2.Y, position.Z) * targetCFrame.Rotation
end

function AssetMovementBatch:_forgetEntry(p)
	local _entry = self._entries[p]

	if _entry ~= nil then
		if not _entry.IsLocalOwner then
			assert(self._foreignEntryCount > 0, "Foreign movement entry count cannot underflow")
			self._foreignEntryCount -= 1
		end

		self._entries[p] = nil
	end
end

function AssetMovementBatch:_removeMissingModels()
	for i = #self._orderedModels, 1, -1 do
		local _orderedModel = self._orderedModels[i]

		if not (self._entries[_orderedModel] == nil or _orderedModel.Parent == nil) then
			continue
		end

		self:_forgetEntry(_orderedModel)
		table.remove(self._orderedModels, i)
	end
end

function AssetMovementBatch:_flush(p: number, flag: boolean)
	table.clear(self._partsBuffer)
	table.clear(self._cframeBuffer)

	for _, _orderedModel in ipairs(self._orderedModels) do
		local _entry = self._entries[_orderedModel]

		if not (_entry ~= nil and _orderedModel.Parent ~= nil and AssetMovementBatch._isPresentationEnabled(
			_entry,
			flag
		)) then
			continue
		end

		local simulationCFrame

		if _entry.GroundingDue then
			simulationCFrame = AssetMovementBatch._groundTargetCFrame(_entry)
		else
			simulationCFrame = _entry.SimulationCFrame
		end

		_entry.SimulationCFrame = simulationCFrame

		if not _entry.GroundingEnabled then
			simulationCFrame = _entry.TargetCFrame
		end

		local v2

		if _entry.GroundingEnabled then
			v2 = AssetMovementBatch._movementAlpha(p)
		else
			v2 = AssetMovementBatch._airborneMovementAlpha(p)
		end

		if _entry.CatchUpRemaining > 0 then
			v2 = math.clamp(p / _entry.CatchUpRemaining, 0, 1)
			_entry.CatchUpRemaining = math.max(_entry.CatchUpRemaining - p, 0)
		end

		local currentCFrame

		if _entry.PresentationFrozen then
			currentCFrame = _entry.CurrentCFrame
		else
			currentCFrame = _entry.CurrentCFrame:Lerp(simulationCFrame, v2)
		end

		local v3 = currentCFrame * _entry.PresentationOffset
		local pivot = _orderedModel:GetPivot()
		_entry.CurrentCFrame = currentCFrame

		for _, visiblePart in ipairs(_entry.VisibleParts) do
			if visiblePart.Parent == nil then
				continue
			end

			table.insert(self._partsBuffer, visiblePart)
			table.insert(self._cframeBuffer, v3 * pivot:ToObjectSpace(visiblePart.CFrame))
		end
	end

	if #self._partsBuffer > 0 then
		workspace:BulkMoveTo(self._partsBuffer, self._cframeBuffer, Enum.BulkMoveMode.FireCFrameChanged)
	end
end

function AssetMovementBatch:_step(p: number)
	self:_removeMissingModels()
	local _scheduleSettings = self._scheduleSettings
	_scheduleSettings.Enabled = GameFlags.PetUpdateSchedulingEnabled:Get()
	_scheduleSettings.HiddenInterval = GameFlags.HiddenPetUpdateInterval:Get()
	_scheduleSettings.DistantInterval = GameFlags.DistantPetUpdateInterval:Get()
	_scheduleSettings.DistantDistance = GameFlags.DistantPetUpdateDistance:Get()
	local currentCamera = workspace.CurrentCamera
	local position

	if currentCamera ~= nil then
		position = currentCamera.CFrame.Position
	end

	local _foreignPresentationForcedSuppressed = self._foreignPresentationForcedSuppressed or self._foreignEntryCount >= 30
	local v2 = self._foreignPresentationSuppressed ~= _foreignPresentationForcedSuppressed
	local v3 = self._foreignPresentationSuppressed and not _foreignPresentationForcedSuppressed
	self._foreignPresentationSuppressed = _foreignPresentationForcedSuppressed

	for _, _orderedModel in ipairs(self._orderedModels) do
		local _entry = self._entries[_orderedModel]

		if not (_entry ~= nil and _orderedModel.Parent ~= nil) then
			continue
		end

		local v4 = (_entry.PresentationHidden or _entry.IsLocalOwner or position == nil) and 0 or _entry.VisualRadius * (_orderedModel:GetScale() / _entry.InitialScale)
		local interval = PetUpdateSchedule.GetInterval(
			_entry.PresentationHidden,
			_entry.IsLocalOwner,
			_entry.CurrentCFrame.Position,
			v4,
			position,
			_scheduleSettings
		)
		local groundingDue, v6, stepElapsed = PetUpdateSchedule.TakeStep(
			_entry.StepElapsed,
			p,
			interval,
			_entry.ForceStep or v2
		)
		_entry.StepElapsed = stepElapsed
		_entry.ForceStep = false
		_entry.GroundingDue = groundingDue

		if groundingDue then
			_entry.Step(v6, not _entry.IsLocalOwner and _foreignPresentationForcedSuppressed)
		end

		if _entry.PresentationHidden or not _entry.IsLocalOwner and _foreignPresentationForcedSuppressed then
			AssetMovementBatch._advanceSuppressedSimulation(_entry)
		elseif not _entry.IsLocalOwner and v3 then
			_entry.CatchUpRemaining = math.max(_entry.CatchUpRemaining, 0.25)
		end
	end

	self:_flush(p, _foreignPresentationForcedSuppressed)
end

function AssetMovementBatch:Add(instance, visibleParts, cframe: CFrame, bottomLocalY: number, assetArea, isLocalOwner: boolean, step)
	t.strict(t.instanceIsA("Model"))(instance)
	t.strict(t.array(t.instanceIsA("BasePart")))(visibleParts)
	t.strict(t.CFrame)(cframe)
	t.strict(t.number)(bottomLocalY)
	t.strict(t.instanceIsA("BasePart"))(assetArea)
	t.strict(t.boolean)(isLocalOwner)
	assert(self._entries[instance] == nil, (`Asset model {instance.Name} is already registered in the movement batch`))
	local _createGroundingRaycastParams = AssetMovementBatch._createGroundingRaycastParams(assetArea)
	local simulationCFrame = AssetMovementBatch._groundCFrame(bottomLocalY, cframe, _createGroundingRaycastParams) or cframe
	local boundingBox, v3 = instance:GetBoundingBox()
	local visualRadius = v3.Magnitude * 0.5 + (boundingBox.Position - instance:GetPivot().Position).Magnitude
	self._entries[instance] = {
		Model = instance,
		VisibleParts = visibleParts,
		AssetArea = assetArea,
		GroundingRaycastParams = _createGroundingRaycastParams,
		IsLocalOwner = isLocalOwner,
		BottomLocalY = bottomLocalY,
		TargetCFrame = cframe,
		CurrentCFrame = cframe,
		SimulationCFrame = simulationCFrame,
		Step = step,
		GroundingEnabled = true,
		PresentationFrozen = false,
		PresentationOffset = CFrame.identity,
		CatchUpRemaining = 0,
		PresentationHidden = false,
		StepElapsed = 0,
		ForceStep = true,
		GroundingDue = true,
		VisualRadius = visualRadius,
		InitialScale = instance:GetScale()
	}

	if not isLocalOwner then
		self._foreignEntryCount += 1
	end

	table.insert(self._orderedModels, instance)
end

function AssetMovementBatch:GetSimulationCFrame(p2)
	t.strict(t.instanceIsA("Model"))(p2)
	local _entry = self._entries[p2]
	assert(_entry ~= nil, (`Asset model {p2.Name} is not registered in the movement batch`))
	return _entry.SimulationCFrame
end

function AssetMovementBatch.ResolveGroundedCFrame(instance, cframe: CFrame)
	t.strict(t.instanceIsA("Model"))(instance)
	t.strict(t.CFrame)(cframe)
	local v2, v3 = ModelBounds(instance)
	local v4 = instance:GetPivot():PointToObjectSpace(v2.Position).Y - v3.Y * 0.5
	local petAreas = { PlacedEggRenderer.GetRenderFolder(), ground }
	local plot = PlotState.ResolvePlot()

	if plot and plot.PetArea then
		table.insert(petAreas, plot.PetArea)
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = petAreas
	raycastParams.IgnoreWater = true
	return AssetMovementBatch._groundCFrame(v4, cframe, raycastParams) or cframe
end

function AssetMovementBatch:SetAssetArea(p2, assetArea)
	t.strict(t.instanceIsA("Model"))(p2)
	t.strict(t.instanceIsA("BasePart"))(assetArea)
	local _entry = self._entries[p2]
	assert(_entry ~= nil, (`Asset model {p2.Name} is not registered in the movement batch`))

	if _entry.AssetArea == assetArea then
		return
	end

	_entry.AssetArea = assetArea
	_entry.GroundingRaycastParams = AssetMovementBatch._createGroundingRaycastParams(assetArea)
	_entry.ForceStep = true
end

function AssetMovementBatch:SetTarget(p2, targetCFrame: CFrame)
	t.strict(t.instanceIsA("Model"))(p2)
	t.strict(t.CFrame)(targetCFrame)
	local _entry = self._entries[p2]
	assert(_entry ~= nil, (`Asset model {p2.Name} is not registered in the movement batch`))
	_entry.TargetCFrame = targetCFrame
end

function AssetMovementBatch:SetGroundingEnabled(p2, groundingEnabled: boolean)
	t.strict(t.instanceIsA("Model"))(p2)
	t.strict(t.boolean)(groundingEnabled)
	local _entry = self._entries[p2]
	assert(_entry ~= nil, (`Asset model {p2.Name} is not registered in the movement batch`))
	_entry.GroundingEnabled = groundingEnabled
end

function AssetMovementBatch:SetPresentationFrozen(p2, presentationFrozen: boolean, value: number?)
	t.strict(t.instanceIsA("Model"))(p2)
	t.strict(t.boolean)(presentationFrozen)
	t.strict(t.optional(t.number))(value)
	local _entry = self._entries[p2]
	assert(_entry ~= nil, (`Asset model {p2.Name} is not registered in the movement batch`))
	_entry.PresentationFrozen = presentationFrozen
	_entry.CatchUpRemaining = presentationFrozen and 0 or math.max(value or 0, 0)
end

function AssetMovementBatch:SetPresentationOffset(p2, presentationOffset: CFrame)
	t.strict(t.instanceIsA("Model"))(p2)
	t.strict(t.CFrame)(presentationOffset)
	local _entry = self._entries[p2]
	assert(_entry ~= nil, (`Asset model {p2.Name} is not registered in the movement batch`))
	_entry.PresentationOffset = presentationOffset
end

function AssetMovementBatch:SetHidden(p2, presentationHidden: boolean)
	local _entry = self._entries[p2]
	assert(_entry ~= nil, "Asset model must be registered before changing visibility")

	if _entry.PresentationHidden == presentationHidden then
		return
	end

	_entry.PresentationHidden = presentationHidden
	_entry.ForceStep = true

	if not presentationHidden then
		_entry.CatchUpRemaining = math.max(_entry.CatchUpRemaining, 0.25)
	end
end

function AssetMovementBatch:SetForeignPresentationSuppressed(foreignPresentationForcedSuppressed: boolean)
	t.strict(t.boolean)(foreignPresentationForcedSuppressed)
	self._foreignPresentationForcedSuppressed = foreignPresentationForcedSuppressed
end

function AssetMovementBatch:Remove(p)
	t.strict(t.instanceIsA("Model"))(p)
	self:_forgetEntry(p)

	for i = #self._orderedModels, 1, -1 do
		if self._orderedModels[i] ~= p then
			continue
		end

		table.remove(self._orderedModels, i)
		break
	end
end

function AssetMovementBatch:Destroy()
	self._trove:Destroy()
	table.clear(self._entries)
	table.clear(self._orderedModels)
	table.clear(self._partsBuffer)
	table.clear(self._cframeBuffer)
	self._foreignEntryCount = 0
	self._foreignPresentationSuppressed = false
	self._foreignPresentationForcedSuppressed = false
end

function AssetMovementBatch:_init()
	self._trove:Add(RunService.PreRender:Connect(function(dt: number)
		self:_step(dt)
	end))
end

return AssetMovementBatch