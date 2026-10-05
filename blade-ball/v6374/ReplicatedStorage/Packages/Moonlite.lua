local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
require3(script.Types)
local v = require3(script.Specials)
local v2 = require3(script.EaseFuncs)
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local isStudio = RunService:IsStudio()

if RunService:IsServer() and isStudio then
	warn("Moonlite should NOT be used on the server! Rig transforms will not be replicated.")
end

local class = {}
class.__index = class
local v3 = {
	Instance = true,
	boolean = true,
	string = true,
	["nil"] = true
}
local v4 = {}
local object = setmetatable({}, {
	__mode = "k"
})

-- equivalent calls inferred from this helper; original call sites unknown
local function lerp(value, p, p2: number)
	if type(value) == "number" then
		return (math.lerp(value, p, p2))
	end

	return value:Lerp(p, p2)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function toPath(path)
	return table.concat(path.InstanceNames, ".")
end

local function resolveAnimPath(path, _root, p)
	if not path then
		return nil
	end

	local instanceNames = path.InstanceNames
	local instanceTypes = path.InstanceTypes
	local v5 = #instanceNames
	local v6 = _root or game

	for i = 2, v5 do
		local instanceName = instanceNames[i]
		local instanceType = instanceTypes[i]

		if instanceName == "CoreGui" then
			instanceNames[i] = "ReplicatedStorage"
			instanceTypes[i] = "ReplicatedStorage"
			instanceName = "ReplicatedStorage"
			instanceType = "ReplicatedStorage"
		end

		local child = nil

		if p then
			local v7 = p[v6]

			if v7 then
				child = v7[instanceName]
			end
		end

		if not child then
			child = v6:FindFirstChild(instanceName)

			if child and child.ClassName == instanceType then
				if p then
					local childrenByInstanceName = p[v6]

					if not childrenByInstanceName then
						childrenByInstanceName = {}
						p[v6] = childrenByInstanceName
					end

					childrenByInstanceName[instanceName] = child
				end
			else
				if isStudio then
					warn("!! PATH RESOLVE FAILED:", table.concat(path.InstanceNames, "."), "\n", v6, _root or game)
				end

				return nil
			end
		end

		v6 = child
	end

	return v6
end

local Moonlite = {
	_resolveAnimPath = resolveAnimPath
}

local function resolveJoints(folder)
	local v5 = {}
	local result = {}

	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("Motor6D") and descendant.Active then
			local part1 = descendant.Part1
			local name = part1 and part1.Name

			if name then
				v5[name] = {
					Name = name,
					Joint = descendant,
					Children = {}
				}
			end
		elseif descendant:IsA("Bone") then
			local name = descendant.Name
			v5[name] = {
				Name = name,
				Joint = descendant,
				Children = {}
			}
		end
	end

	for k, v6 in v5 do
		local joint = v6.Joint

		if joint:IsA("Motor6D") then
			local part0 = joint.Part0

			if part0 then
				local parent = v5[part0.Name]

				if parent then
					parent.Children[k] = v6
					v6.Parent = parent
				end
			end
		elseif joint:IsA("Bone") then
			local parent = joint.Parent

			if parent then
				local parent2 = v5[parent.Name]

				if parent2 then
					parent2.Children[k] = v6
					v6.Parent = parent2
				end
			end
		end
	end

	for _, v6 in v5 do
		local name = v6.Name
		local parent = v6.Parent

		while parent do
			name = `{parent.Name}.{name}`
			parent = parent.Parent
		end

		result[name] = v6
	end

	return result
end

local function parseEase(child)
	local type2 = child:FindFirstChild("Type")
	local params = child:FindFirstChild("Params")
	local v6

	if type2 and type2:IsA("StringValue") then
		v6 = type2.Value
	end

	local v5 = {
		Type = assert(v6),
		Params = {}
	}

	if not params then
		return v5
	end

	for _, valueBase in params:GetChildren() do
		if not valueBase:IsA("ValueBase") then
			continue
		end

		local value = valueBase.Value
		v5.Params[valueBase.Name] = value
	end

	return v5
end

local function parseEaseOld(ease)
	local style = ease:FindFirstChild("Style")
	assert(style and style:IsA("StringValue"), "No style in legacy ease!")
	local direction = ease:FindFirstChild("Direction")
	assert(direction and direction:IsA("StringValue"), "No direction in legacy ease!")
	return {
		Type = style.Value,
		Params = {
			Direction = direction.Value
		}
	}
end

local function readValue(valueBase)
	if not valueBase:IsA("ValueBase") then
		return valueBase:GetAttribute("Value")
	end

	local v5

	if tonumber(valueBase.Name) then
		v5 = assert(valueBase.Parent)
	else
		v5 = valueBase
	end

	local value = valueBase.Value
	local enumType = v5:FindFirstChild("EnumType")

	if enumType and enumType:IsA("StringValue") then
		return Enum[enumType.Value][value]
	end

	if v5:FindFirstChild("Vector2") then
		return (Vector2.new(value.X, value.Y))
	end

	if v5:FindFirstChild("ColorSequence") then
		return (ColorSequence.new(value))
	end

	if v5:FindFirstChild("NumberSequence") then
		return (NumberSequence.new(value))
	end

	if v5:FindFirstChild("NumberRange") then
		value = NumberRange.new(value)
	end

	return value
end

local function getPropValue(object2, k, k2: string)
	local v5 = k and v.Get(object2._scratch, k, k2)

	if not v5 then
		return pcall(function()
			return k[k2]
		end)
	end

	local get = v5.Get

	if get then
		return pcall(get, k)
	end

	return true, v5.Default
end

local function setPropValue(p, p2, p3: string, p4, flag: boolean?)
	local v5 = p2 and v.Get(p._scratch, p2, p3)

	if not v5 then
		return pcall(function()
			p2[p3] = p4
		end)
	end

	if v5.Get == nil and flag and p4 == true then
		p4 = false
	end

	return pcall(v5.Set, p4)
end

local function parseKeyframePack(child)
	local name = tonumber(child.Name)
	assert(name, "Bad frame number")
	local values = child:FindFirstChild("Values")
	assert(values, "No value folder!")
	assert(values:FindFirstChild("0"), "No starting value!")
	local values2 = {}
	local frameCount = 0

	for _, child2 in values:GetChildren() do
		local name2 = tonumber(child2.Name)

		if not name2 then
			continue
		end

		local success, result = pcall(readValue, child2)

		if not success then
			continue
		end

		values2[name2] = result
		frameCount = math.max(name2, frameCount)
	end

	local eases = child:FindFirstChild("Eases")
	local ease = child:FindFirstChild("Ease")
	local eases2 = {}

	if eases then
		for _, child2 in eases:GetChildren() do
			local name2 = tonumber(child2.Name)
			assert(name2, (`Bad index on ease @{child2:GetFullName()}`))
			eases2[name2] = parseEase(child2)
		end
	elseif ease then
		eases2[frameCount] = parseEaseOld(ease)
	end

	return {
		FrameIndex = name,
		FrameCount = frameCount,
		Values = values2,
		Eases = eases2
	}
end

local function unpackKeyframes(instance, callback)
	local v5 = {}
	local names = {}
	local result = {}

	for _, child in instance:GetChildren() do
		local name = tonumber(child.Name)

		if not name then
			continue
		end

		v5[name] = parseKeyframePack(child)
		table.insert(names, name)
	end

	table.sort(names)

	for i = 2, #names do
		local prev = v5[names[i - 1]]
		local next3 = v5[names[i]]
		prev.Next = next3
		next3.Prev = prev
	end

	local next2 = v5[names[1]]

	while next2 do
		local frameIndex = next2.FrameIndex
		local v6 = nil

		for i = 0, next2.FrameCount do
			local ease = next2.Eases[i] or v6
			local value = next2.Values[i]

			if value == nil then
				continue
			end

			if callback then
				value = callback(value)
			end

			table.insert(result, {
				Time = frameIndex + i,
				Value = value,
				Ease = ease
			})

			if ease then
				v6 = ease
			end
		end

		next2 = next2.Next
	end

	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function readValueBase(instance, childName: string)
	local valueBase = instance:FindFirstChild(childName)
	assert(valueBase and valueBase:IsA("ValueBase"))
	return valueBase.Value
end

local function compileItem(data, item, p)
	assert(data._data and data._save, "This track is already compiled from source")
	local index = table.find(data._data.Items, item)

	if not index then
		return
	end

	local path = item.Path
	local itemType = path.ItemType
	local override = item.Override or resolveAnimPath(path, data._root)
	local child = data._save:FindFirstChild((tostring(index)))

	if not (override and child) then
		return
	end

	assert(override)
	assert(child)
	local rig = child:FindFirstChild("Rig")
	local markerTrack = child:FindFirstChild("MarkerTrack")

	if rig and itemType == "Rig" then
		local joints = resolveJoints(override)

		for _, child2 in rig:GetChildren() do
			if child2.Name ~= "_joint" then
				continue
			end

			local _hier = child2:FindFirstChild("_hier")
			local default = child2:FindFirstChild("default")
			local _keyframes = child2:FindFirstChild("_keyframes")
			local v5 = default and readValue(default)
			local v6 = _hier and _keyframes and joints[readValue(_hier)]

			if not v6 then
				continue
			end

			local joint = v6.Joint
			local transform = {
				Default = CFrame.identity,
				Static = false,
				Sequence = 0
			}
			local sequence

			if joint:IsA("Motor6D") then
				sequence = unpackKeyframes(_keyframes, function(cframe: CFrame)
					return cframe:Inverse() * v5
				end)
			else
				sequence = unpackKeyframes(_keyframes, function(cframe: CFrame)
					return cframe
				end)
			end

			transform.Sequence = sequence
			p[joint] = {
				Props = {
					Transform = transform
				},
				Target = joint
			}
		end
	end

	local props = {}

	for _, folder in child:GetChildren() do
		if not (folder:IsA("Folder") and folder ~= markerTrack and folder.Name ~= "Rig") then
			continue
		end

		local default = folder:FindFirstChild("default")
		local name = folder.Name
		props[name] = {
			Default = default and readValue(default),
			Static = v.Static(override, name),
			Sequence = unpackKeyframes(folder)
		}
	end

	p[override] = {
		Props = props,
		Target = override
	}

	if markerTrack then
		local v6 = {}
		data._markers[override] = v6

		for _, child2 in markerTrack:GetChildren() do
			if not child2:FindFirstChild("name") then
				continue
			end

			local v7 = assert((tonumber(child2.Name)))
			local valueBase2 = readValueBase(child2, "width") -- equivalent call inferred; original call site unknown
			local valueBase3 = readValueBase(child2, "name") -- equivalent call inferred; original call site unknown
			local v10 = {}
			local kFMarkers = child2:FindFirstChild("KFMarkers")

			if kFMarkers then
				for _, valueBase in kFMarkers:GetChildren() do
					if not valueBase:IsA("ValueBase") then
						continue
					end

					local value = valueBase.Value
					v10[value] = readValueBase(valueBase, "Val")
				end
			end

			local v11 = v6[v7]

			if not v11 then
				v11 = {
					StartMarkers = {},
					EndMarkers = {}
				}
				v6[v7] = v11
			end

			if valueBase2 > 0 then
				local v12 = math.min(v7 + valueBase2, data.Frames)
				local v13 = v6[v12]

				if not v13 then
					v13 = {
						StartMarkers = {},
						EndMarkers = {}
					}
					v6[v12] = v13
				end

				v13.EndMarkers[valueBase3] = v10
			end

			v11.StartMarkers[valueBase3] = v10
		end
	end
end

local function getInterpolator(value)
	if typeof(value) == "ColorSequence" then
		return function(sequence, sequence2, p: number)
			local v5 = lerp(sequence.Keypoints[1].Value, sequence2.Keypoints[1].Value, p) -- equivalent call inferred; original call site unknown
			return ColorSequence.new(v5)
		end
	end

	if typeof(value) == "NumberSequence" then
		return function(sequence, sequence2, p: number)
			local v5 = lerp(sequence.Keypoints[1].Value, sequence2.Keypoints[1].Value, p) -- equivalent call inferred; original call site unknown
			return NumberSequence.new(v5)
		end
	end

	if typeof(value) == "NumberRange" then
		return function(range: NumberRange, range2: NumberRange, p: number)
			local v5 = lerp(range.Min, range2.Min, p) -- equivalent call inferred; original call site unknown
			return NumberRange.new(v5)
		end
	end

	if v3[typeof(value)] then
		return function(p, p2, p3: number)
			if p3 >= 1 then
				return p2
			end

			return p
		end
	end

	return lerp
end

local function expandFrames(frames: number, frameRate: number, props)
	local result = {}

	for k, item in props do
		if not item.Sequence[1] then
			continue
		end

		local default = item.Default
		local interpolator = getInterpolator(item.Sequence[1].Value)
		local time = 0
		local ease = nil

		for _, v5 in item.Sequence do
			if not result[v5.Time] then
				result[v5.Time] = {}
			end

			local v6 = v5.Time - time
			result[v5.Time][k] = v5.Value

			if v6 <= 1 then
				default = v5.Value
				ease = v5.Ease
			else
				if not item.Static then
					local v7 = v2.Get(ease)

					for i = 0, v6 do
						local v8 = v7(i / v6)
						local v9 = time + i

						if not result[v9] then
							result[v9] = {}
						end

						result[v9][k] = interpolator(default, v5.Value, v8)
					end
				end

				ease = v5.Ease
				default = v5.Value
			end

			time = v5.Time
		end

		if item.Static or not (time < frames) then
			continue
		end

		local v5 = result[time][k]

		for i = time, frameRate do
			if not result[i] then
				result[i] = {}
			end

			result[i][k] = v5
		end
	end

	return result
end

local function compileFrames(data, items)
	local _buffer = data._buffer
	local _elements = data._elements

	for k, item in items do
		_buffer[k] = expandFrames(data.Frames, data.FrameRate, item.Props)
		table.insert(_elements, k)
	end
end

local function compileRouting(state)
	assert(state._data and state._save, "This track is already compiled from source")
	table.clear(state._buffer)
	table.clear(state._elements)
	table.clear(state._markers)
	local v5 = {}

	for _, item in state._data.Items do
		compileItem(state, item, v5)
	end

	compileFrames(state, v5)
	state._compiled = true
end

local function restoreTrack(k)
	local v5 = v4[k]

	if not v5 then
		return
	end

	if k.RestoreDefaults then
		for k2, v6 in v5 do
			for k3, v7 in v6 do
				setPropValue(k, k2, k3, v7)
			end
		end

		setPropValue(k, workspace.CurrentCamera, "AttachToPart", nil)
		setPropValue(k, workspace.CurrentCamera, "LookAtPart", nil)
	end

	v4[k] = nil
end

local function stepTrack(state, p: number)
	local currentFrame = math.floor(state.TimePosition * state.FrameRate)

	if state.Frames < currentFrame then
		if not state.Looped then
			state._completed:Fire(Enum.PlaybackState.Completed)
			return true
		end

		state.TimePosition = 0
		state.CurrentFrame = 0
		state._onLoop:Fire()
		currentFrame = 0
	end

	for i = state.CurrentFrame, currentFrame do
		for k, v6 in state._buffer do
			if state._locks[k] ~= nil then
				continue
			end

			local v7 = v6[i]

			if not v7 then
				continue
			end

			for k2, v8 in v7 do
				setPropValue(state, k, k2, v8)
			end
		end

		for k, _marker in state._markers do
			local v6 = _marker[i]

			if not v6 then
				continue
			end

			for k2, startMarker in v6.StartMarkers do
				if state._markerSignals[k2] then
					state._markerSignals[k2]:Fire(k, startMarker)
				end
			end

			for k2, endMarker in v6.EndMarkers do
				if state._endMarkerSignals[k2] then
					state._endMarkerSignals[k2]:Fire(k, endMarker)
				end
			end
		end
	end

	state.CurrentFrame = currentFrame
	state.TimePosition += p
	return false
end

function Moonlite.CreatePlayer(stringValue, root)
	local bindableEvent = Instance.new("BindableEvent")
	local bindableEvent2 = Instance.new("BindableEvent")

	if typeof(stringValue) == "Instance" and stringValue:IsA("StringValue") then
		local jSONDecode = HttpService:JSONDecode(stringValue.Value)
		local object2 = setmetatable({
			Completed = bindableEvent.Event,
			OnLoop = bindableEvent2.Event,
			Looped = jSONDecode.Information.Looped,
			Frames = jSONDecode.Information.Length,
			FrameRate = jSONDecode.Information.FPS or 60,
			RestoreDefaults = true,
			TimePosition = 0,
			CurrentFrame = 0,
			_save = stringValue,
			_data = jSONDecode,
			_overrides = {},
			_compiled = false,
			_completed = bindableEvent,
			_onLoop = bindableEvent2,
			_markers = {},
			_markerSignals = {},
			_endMarkerSignals = {},
			_locks = {},
			_elements = {},
			_buffer = {},
			_scratch = {},
			_root = root
		}, class)
		compileRouting(object2)
		return object2
	else
		local moduleInfo

		if typeof(stringValue) == "Instance" then
			moduleInfo = require3(stringValue)
		else
			moduleInfo = stringValue
		end

		return (setmetatable({
			Completed = bindableEvent.Event,
			OnLoop = bindableEvent2.Event,
			Looped = moduleInfo.Information.Looped,
			Frames = moduleInfo.Information.Length,
			FrameRate = moduleInfo.Information.FPS or 60,
			RestoreDefaults = true,
			TimePosition = 0,
			CurrentFrame = 0,
			_source = stringValue,
			_moduleInfo = moduleInfo,
			_overrides = {},
			_compiled = false,
			_completed = bindableEvent,
			_onLoop = bindableEvent2,
			_markers = {},
			_markerSignals = {},
			_endMarkerSignals = {},
			_locks = {},
			_elements = {},
			_buffer = {},
			_scratch = {},
			_root = root
		}, class))
	end
end

function class:Compile()
	if self._save then
		compileRouting(self)
		return self
	end

	if not self._moduleInfo then
		return self
	end

	local v5 = object[self._source]

	if not v5 then
		v5 = {}
		object[self._source] = v5
	end

	local _buffer = self._buffer
	local _elements = self._elements
	local _overrides = self._overrides
	debug.profilebegin("Compile Frames")
	local v6 = {}

	for k, v7 in self._moduleInfo.Compiled do
		local joined

		if v7.Path then
			local path = v7.Path
			joined = table.concat(path.InstanceNames, ".")
		else
			joined = tostring(k)
		end

		local v8 = _overrides[joined] or resolveAnimPath(v7.Path or k, self._root, v6)

		if not v8 then
			continue
		end

		local v9 = v5[joined]

		if not v9 then
			v9 = expandFrames(self.Frames, self.FrameRate, v7.Props)
			v5[joined] = v9
		end

		_buffer[v8] = v9
		table.insert(_elements, v8)
	end

	debug.profileend()
	self._compiled = true
	return self
end

function class:Destroy()
	for _, _markerSignal in self._markerSignals do
		_markerSignal:Destroy()
	end

	for _, _endMarkerSignal in self._endMarkerSignals do
		_endMarkerSignal:Destroy()
	end

	self._completed:Destroy()
	table.clear(self._markerSignals)
	table.clear(self._endMarkerSignals)
end

function class.IsPlaying(p)
	return v4[p] ~= nil
end

function class:GetTimeLength()
	return self.Frames / self.FrameRate
end

function class:GetMarkerReachedSignal(p2: string)
	if not self._markerSignals[p2] then
		self._markerSignals[p2] = Instance.new("BindableEvent")
	end

	return self._markerSignals[p2].Event
end

function class:GetMarkerEndedSignal(p2: string)
	if not self._endMarkerSignals[p2] then
		self._endMarkerSignals[p2] = Instance.new("BindableEvent")
	end

	return self._endMarkerSignals[p2].Event
end

function class:GetSetting(p2: string)
	return self._scratch[p2]
end

function class:SetSetting(p2: string, p3)
	self._scratch[p2] = p3
end

function class:GetElements()
	return table.clone(self._elements)
end

function class:LockElement(p2, value)
	if not self._locks[p2] then
		self._locks[p2] = {}
	end

	if value then
		self._locks[p2][value or "Default"] = true
	end

	return true
end

function class:UnlockElement(p2, value)
	local _lock = self._locks[p2]

	if _lock then
		_lock[value or "Default"] = nil

		if not next(_lock) then
			self._locks[p2] = nil
		end
	end

	return true
end

function class:IsElementLocked(p2)
	return self._locks[p2] ~= nil
end

function class:ReplaceElementByPath(value: string, override)
	local lower = value:lower()

	if self._data then
		for _, item in self._data.Items do
			local path = item.Path

			if not (lower == table.concat(path.InstanceNames, "."):lower() and (path.ItemType == "Rig" or override:IsA(path.ItemType))) then
				continue
			end

			item.Override = override
			return true
		end
	else
		for _, v5 in self._moduleInfo.Compiled do
			local path = v5.Path

			if not path then
				continue
			end

			local path2 = toPath(path) -- equivalent call inferred; original call site unknown

			if lower ~= path2:lower() then
				continue
			end

			local itemType = path.ItemType

			if not (itemType == "Rig" or override:IsA(itemType)) then
				continue
			end

			self._overrides[path2] = override
			return true
		end
	end

	return false
end

function class:FindElement(p2: string)
	for _, _element in self._elements do
		if _element and _element.Name == p2 then
			return _element
		end
	end

	return nil
end

function class:FindElementOfType(className: string)
	for _, _element in self._elements do
		if _element and _element:IsA(className) then
			return _element
		end
	end

	return nil
end

function class:Stop()
	self.TimePosition = 0
	task.spawn(restoreTrack, self)
	self._completed:Fire(Enum.PlaybackState.Cancelled)
end

function class:Reset()
	self.TimePosition = 0
	stepTrack(self, 0)
	return true
end

function class:Play()
	assert(self._compiled, "Track is not compiled.")

	if v4[self] then
		return
	end

	if self.TimePosition >= self:GetTimeLength() then
		self.TimePosition = 0
	end

	local v5 = {}

	for k, v6 in self._buffer do
		if not v6[0] then
			continue
		end

		local v7 = {}
		v5[k] = v7

		for k2 in v6[0] do
			local propValue, v8 = getPropValue(self, k, k2)

			if propValue then
				v7[k2] = v8
			end
		end
	end

	v4[self] = v5
	self._completed:Fire(Enum.PlaybackState.Playing)
end

RunService.PreSimulation:Connect(function(dt: number)
	for k in v4 do
		if stepTrack(k, dt) then
			restoreTrack(k)
		end
	end
end)
return Moonlite