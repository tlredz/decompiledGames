local ReplicatedStorage = game:GetService("ReplicatedStorage")
local guardRetrieval = require(ReplicatedStorage.Shared.Flags.GameplayBalance).GuardRetrieval
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Constants = require(ReplicatedStorage2.Shared.Globals.Constants)
local GuardDistance = require(script.Parent.GuardDistance)
local Physics = require(ReplicatedStorage2.Shared.Utils.Physics)
local t = require(ReplicatedStorage2.Packages.t)
require(script.Parent.Types.Interface)
local WaitFor = require(ReplicatedStorage2.Packages.WaitFor)
local GuardEggRetrievalComponent = {}
GuardEggRetrievalComponent.__index = GuardEggRetrievalComponent
GuardEggRetrievalComponent.__class = "GuardEggRetrievalComponent"

function GuardEggRetrievalComponent.new(instance, root, homeCFrame: CFrame)
	t.strict(t.instanceIsA("Model"))(instance)
	t.strict(t.instanceIsA("BasePart"))(root)
	t.strict(t.CFrame)(homeCFrame)
	local v, part = WaitFor.Descendant(instance, "EggPoint", Constants.STUDIO_YIELD_TIMEOUT):await()
	assert(v, (`Failed to resolve EggPoint under {instance:GetFullName()}: {tostring(part)}`))
	assert(part:IsA("BasePart"), (`{instance:GetFullName()}.EggPoint must be a BasePart`))
	local object = setmetatable({}, GuardEggRetrievalComponent)
	object._byUid = {}
	object._current = nil
	object._eggPoint = part
	object._homeCFrame = homeCFrame
	object._queue = {}
	object._root = root
	object._stage = nil
	object._weld = nil
	return object
end

function GuardEggRetrievalComponent:_enqueue(p2)
	for i, v in ipairs(self._queue) do
		if not (p2.Priority > v.Priority) then
			continue
		end

		table.insert(self._queue, i, p2)
		return
	end

	table.insert(self._queue, p2)
end

function GuardEggRetrievalComponent:_selectCurrent()
	if self._current ~= nil then
		return self._current
	end

	while #self._queue > 0 do
		local current = table.remove(self._queue, 1)
		assert(current ~= nil, "Non-empty guard retrieval queue must yield a target")
		local model = current.Model

		if self._byUid[current.EggUid] == current and (model == nil or model.Parent ~= nil) then
			self._current = current
			self._stage = "Approaching"
			return current
		else
			self._byUid[current.EggUid] = nil
		end
	end

	return nil
end

function GuardEggRetrievalComponent:_destroyWeld()
	local _weld = self._weld

	if _weld ~= nil then
		self._weld = nil
		_weld:Destroy()
	end
end

function GuardEggRetrievalComponent:_removeCurrent()
	local _current = self._current
	assert(_current ~= nil, "Guard retrieval current target is required")
	self:_destroyWeld()
	self._byUid[_current.EggUid] = nil
	self._current = nil
	self._stage = nil
	return _current
end

function GuardEggRetrievalComponent:Register(data)
	t.strict(t.table)(data)
	t.strict(t.string)(data.EggUid)
	t.strict(t.optional(t.instanceIsA("Model")))(data.Model)
	t.strict(t.Vector3)(data.DroppedPosition)
	t.strict(t.CFrame)(data.NestBottomCFrame)
	t.strict(t.number)(data.Priority)

	if self._byUid[data.EggUid] ~= nil then
		return false
	end

	self._byUid[data.EggUid] = data
	self:_enqueue(data)
	local _current = self._current

	if _current ~= nil and self._stage == "Approaching" and data.Priority > _current.Priority then
		self._current = nil
		self._stage = nil
		self:_enqueue(_current)
	end

	return true
end

function GuardEggRetrievalComponent:Clear(p: string)
	t.strict(t.string)(p)
	local v = self._byUid[p]

	if v == nil then
		return false
	end

	self._byUid[p] = nil

	if self._current == v then
		self:_destroyWeld()
		self._current = nil
		self._stage = nil
	end

	local index = table.find(self._queue, v)

	if index ~= nil then
		table.remove(self._queue, index)
	end

	return true
end

function GuardEggRetrievalComponent:HasPending()
	return next(self._byUid) ~= nil
end

function GuardEggRetrievalComponent:IsAttached(p2: string)
	t.strict(t.string)(p2)
	return self._current ~= nil and self._current.EggUid == p2 and self._stage == "Carrying"
end

function GuardEggRetrievalComponent:GetMoveTarget()
	local _selectCurrent = self:_selectCurrent()

	if _selectCurrent == nil then
		return nil
	end

	if self._stage == "Carrying" then
		return self._homeCFrame.Position
	end

	return _selectCurrent.DroppedPosition
end

function GuardEggRetrievalComponent:TryTransition(p: number)
	t.strict(t.number)(p)
	local _selectCurrent = self:_selectCurrent()

	if _selectCurrent == nil then
		return nil
	end

	local model = _selectCurrent.Model

	if model ~= nil and model.Parent == nil then
		self:Clear(_selectCurrent.EggUid)
		return nil
	end

	if self._stage == "Approaching" then
		if p < GuardDistance.XZ(self._root.Position, _selectCurrent.DroppedPosition) then
			return nil
		end

		if model ~= nil then
			local primaryPart = model.PrimaryPart
			assert(primaryPart ~= nil, (`Rendered guard retrieval egg {_selectCurrent.EggUid} must have a PrimaryPart`))
			Physics.SetAnchored(model, false)
			model:PivotTo(self._eggPoint.CFrame * CFrame.new(0, 0, -primaryPart.Size.Z * 0.5))
			local _eggPoint = self._eggPoint
			local weld

			if _eggPoint.Anchored then
				weld = Instance.new("Motor6D")
				weld.C0 = _eggPoint.CFrame:ToObjectSpace(primaryPart.CFrame)
			else
				weld = Instance.new("WeldConstraint")
			end

			weld.Part0 = _eggPoint
			weld.Part1 = primaryPart
			weld.Parent = _eggPoint
			self._weld = weld
		end

		self._stage = "Carrying"
		return "Attached"
	else
		if GuardDistance.XZ(self._root.Position, self._homeCFrame.Position) > guardRetrieval.DEPOSIT_DISTANCE_XZ then
			return nil
		end

		self:_destroyWeld()

		if model ~= nil then
			Physics.SetAnchored(model, true)
			model:PivotTo(_selectCurrent.NestBottomCFrame)
		end

		self:_removeCurrent()
		return "Deposited"
	end
end

function GuardEggRetrievalComponent:GetCurrentEggUid()
	local _selectCurrent = self:_selectCurrent()

	if _selectCurrent == nil then
		return nil
	end

	return _selectCurrent.EggUid
end

function GuardEggRetrievalComponent:Destroy()
	self:_destroyWeld()
	table.clear(self._byUid)
	table.clear(self._queue)
	self._current = nil
	self._stage = nil
end

return GuardEggRetrievalComponent