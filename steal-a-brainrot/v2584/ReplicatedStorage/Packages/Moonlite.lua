local Moonlite = {}
require(script.Types)
local Specials = require(script.Specials)
local EaseFuncs = require(script.EaseFuncs)
local RunService = game:GetService("RunService")
game:GetService("HttpService")

if RunService:IsServer() and RunService:IsStudio() then
	warn("Moonlite should NOT be used on the server! Rig transforms will not be replicated.")
end

local class = {}
class.__index = class
local v = {
	Instance = true,
	boolean = true,
	string = true,
	["nil"] = true
}
local v2 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function lerp(value, p, p2: number)
	if type(value) == "number" then
		return (math.lerp(value, p, p2))
	end

	return value:Lerp(p, p2)
end

local deepCopy

deepCopy = function(items)
	local result = {}

	for k, item in next, items, nil do
		if type(k) == "table" then
			k = deepCopy(k)
		end

		if type(item) == "table" then
			item = deepCopy(item)
		end

		result[k] = item
	end

	return result
end

local function toPath(p)
	return table.concat(p.InstanceNames, ".")
end

local function resolveAnimPath(p, _root)
	if not p then
		return nil
	end

	local count = #p.InstanceNames
	local v3 = _root or game
	local success, result = pcall(function()
		for i = 2, count do
			local instanceName = p.InstanceNames[i]
			local instanceType = p.InstanceTypes[i]

			if instanceName == "CoreGui" then
				p.InstanceNames[i] = "ReplicatedStorage"
				p.InstanceTypes[i] = "ReplicatedStorage"
				instanceName = p.InstanceNames[i]
				instanceType = p.InstanceTypes[i]
			end

			local child = v3:FindFirstChild(instanceName)
			assert(typeof(child) == "Instance")
			assert(child.ClassName == instanceType)
			v3 = child
		end
	end)

	if success then
		return v3
	end

	warn("!! PATH RESOLVE FAILED:", table.concat(p.InstanceNames, "."), "\n", result)
	return nil
end

local function resolveJoints(folder)
	local v3 = {}
	local result = {}

	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("Motor6D") and descendant.Active then
			local part1 = descendant.Part1
			local name = part1 and part1.Name

			if name then
				v3[name] = {
					Name = name,
					Joint = descendant,
					Children = {}
				}
			end
		elseif descendant:IsA("Bone") then
			local name = descendant.Name
			v3[name] = {
				Name = name,
				Joint = descendant,
				Children = {}
			}
		end
	end

	for k, v4 in v3 do
		local joint = v4.Joint

		if joint:IsA("Motor6D") then
			local part0 = joint.Part0

			if part0 then
				local parent = v3[part0.Name]

				if parent then
					parent.Children[k] = v4
					v4.Parent = parent
				end
			end
		elseif joint:IsA("Bone") then
			local parent = joint.Parent

			if parent then
				local parent2 = v3[parent.Name]

				if parent2 then
					parent2.Children[k] = v4
					v4.Parent = parent2
				end
			end
		end
	end

	for _, v4 in v3 do
		local name = v4.Name
		local parent = v4.Parent

		while parent do
			name = `{parent.Name}.{name}`
			parent = parent.Parent
		end

		result[name] = v4
	end

	return result
end

local function parseEase(child)
	local type2 = child:FindFirstChild("Type")
	local params = child:FindFirstChild("Params")
	local v4

	if type2 and type2:IsA("StringValue") then
		v4 = type2.Value
	end

	local v3 = {
		Type = assert(v4),
		Params = {}
	}

	if not params then
		return v3
	end

	for _, valueBase in params:GetChildren() do
		if not valueBase:IsA("ValueBase") then
			continue
		end

		local value = valueBase.Value
		v3.Params[valueBase.Name] = value
	end

	return v3
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

	local v3

	if tonumber(valueBase.Name) then
		v3 = assert(valueBase.Parent)
	else
		v3 = valueBase
	end

	local value = valueBase.Value
	local enumType = v3:FindFirstChild("EnumType")

	if enumType and enumType:IsA("StringValue") then
		return Enum[enumType.Value][value]
	end

	if v3:FindFirstChild("Vector2") then
		return (Vector2.new(value.X, value.Y))
	end

	if v3:FindFirstChild("ColorSequence") then
		return (ColorSequence.new(value))
	end

	if v3:FindFirstChild("NumberSequence") then
		return (NumberSequence.new(value))
	end

	if v3:FindFirstChild("NumberRange") then
		value = NumberRange.new(value)
	end

	return value
end

local function getPropValue(object, k, k2: string)
	local v3 = k and Specials.Get(object._scratch, k, k2)

	if not v3 then
		return pcall(function()
			return k[k2]
		end)
	end

	local get = v3.Get

	if get then
		return pcall(get, k)
	end

	return true, v3.Default
end

local function setPropValue(p, p2, p3: string, p4, flag: boolean?)
	local v3 = p2 and Specials.Get(p._scratch, p2, p3)

	if not v3 then
		return pcall(function()
			p2[p3] = p4
		end)
	end

	if v3.Get == nil and flag and p4 == true then
		p4 = false
	end

	return pcall(v3.Set, p4)
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
	local v3 = {}
	local names = {}
	local result = {}

	for _, child in instance:GetChildren() do
		local name = tonumber(child.Name)

		if not name then
			continue
		end

		v3[name] = parseKeyframePack(child)
		table.insert(names, name)
	end

	table.sort(names)

	for i = 2, #names do
		local prev = v3[names[i - 1]]
		local next3 = v3[names[i]]
		prev.Next = next3
		next3.Prev = prev
	end

	local next2 = v3[names[1]]

	while next2 do
		local frameIndex = next2.FrameIndex
		local v4 = nil

		for i = 0, next2.FrameCount do
			local ease = next2.Eases[i] or v4
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
				v4 = ease
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
			local v3 = default and readValue(default)
			local v4 = _hier and _keyframes and joints[readValue(_hier)]

			if not v4 then
				continue
			end

			local joint = v4.Joint
			local transform = {
				Default = CFrame.identity,
				Sequence = 0
			}
			local sequence

			if joint:IsA("Motor6D") then
				sequence = unpackKeyframes(_keyframes, function(cframe: CFrame)
					return cframe:Inverse() * v3
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
		local default2 = default and readValue(default)
		local static = Specials.Static(override, name)

		if static == false then
			static = nil
		end

		props[name] = {
			Default = default2,
			Static = static,
			Sequence = unpackKeyframes(folder)
		}
	end

	p[override] = {
		Props = props,
		Target = override
	}

	if markerTrack then
		local v4 = {}
		data._markers[override] = v4

		for _, child2 in markerTrack:GetChildren() do
			if not child2:FindFirstChild("name") then
				continue
			end

			local v5 = assert((tonumber(child2.Name)))
			local valueBase2 = readValueBase(child2, "width") -- equivalent call inferred; original call site unknown
			local valueBase3 = readValueBase(child2, "name") -- equivalent call inferred; original call site unknown
			local v8 = {}
			local kFMarkers = child2:FindFirstChild("KFMarkers")

			if kFMarkers then
				for _, valueBase in kFMarkers:GetChildren() do
					if not valueBase:IsA("ValueBase") then
						continue
					end

					local value = valueBase.Value
					v8[value] = readValueBase(valueBase, "Val")
				end
			end

			local v9 = v4[v5]

			if not v9 then
				v9 = {
					StartMarkers = {},
					EndMarkers = {}
				}
				v4[v5] = v9
			end

			if valueBase2 > 0 then
				local v10 = math.min(v5 + valueBase2, data.Frames)
				local v11 = v4[v10]

				if not v11 then
					v11 = {
						StartMarkers = {},
						EndMarkers = {}
					}
					v4[v10] = v11
				end

				v11.EndMarkers[valueBase3] = v8
			end

			v9.StartMarkers[valueBase3] = v8
		end
	end
end

local function getInterpolator(value)
	if typeof(value) == "ColorSequence" then
		return function(sequence, sequence2, p: number)
			local v3 = lerp(sequence.Keypoints[1].Value, sequence2.Keypoints[1].Value, p) -- equivalent call inferred; original call site unknown
			return ColorSequence.new(v3)
		end
	end

	if typeof(value) == "NumberSequence" then
		return function(sequence, sequence2, p: number)
			local v3 = lerp(sequence.Keypoints[1].Value, sequence2.Keypoints[1].Value, p) -- equivalent call inferred; original call site unknown
			return NumberSequence.new(v3)
		end
	end

	if typeof(value) == "NumberRange" then
		return function(range: NumberRange, range2: NumberRange, p: number)
			local v3 = lerp(range.Min, range2.Min, p) -- equivalent call inferred; original call site unknown
			return NumberRange.new(v3)
		end
	end

	if v[typeof(value)] then
		return function(p, p2, p3: number)
			if p3 >= 1 then
				return p2
			end

			return p
		end
	end

	return lerp
end

local function compileFrames(data, items)
	local _buffer = data._buffer
	local _elements = data._elements

	for k, item in items do
		local v3 = {}
		_buffer[k] = v3
		table.insert(_elements, k)

		for k2, v4 in item.Props do
			if not v4.Sequence[1] then
				continue
			end

			local default = v4.Default
			local interpolator = getInterpolator(v4.Sequence[1].Value)
			local time = 0
			local ease = nil

			for _, v5 in v4.Sequence do
				if not v3[v5.Time] then
					v3[v5.Time] = {}
				end

				local v6 = v5.Time - time
				v3[v5.Time][k2] = v5.Value

				if v6 <= 1 then
					default = v5.Value
					ease = v5.Ease
				else
					if not v4.Static then
						local v7 = EaseFuncs.Get(ease)

						for i = 0, v6 do
							local v8 = v7(i / v6)
							local v9 = time + i

							if not v3[v9] then
								v3[v9] = {}
							end

							v3[v9][k2] = interpolator(default, v5.Value, v8)
						end
					end

					ease = v5.Ease
					default = v5.Value
				end

				time = v5.Time
			end

			if v4.Static or not (time < data.Frames) then
				continue
			end

			local v5 = v3[time][k2]

			for i = time, data.Frames do
				if not v3[i] then
					v3[i] = {}
				end

				v3[i][k2] = v5
			end
		end
	end
end

local function compileRouting(state)
	assert(state._data and state._save, "This track is already compiled from source")
	table.clear(state._buffer)
	table.clear(state._elements)
	table.clear(state._markers)
	local v3 = {}

	for _, item in state._data.Items do
		compileItem(state, item, v3)
	end

	compileFrames(state, v3)
	state._compiled = true
end

local function restoreTrack(k)
	local v3 = v2[k]

	if not v3 then
		return
	end

	if k.RestoreDefaults then
		for k2, v4 in v3 do
			for k3, v5 in v4 do
				setPropValue(k, k2, k3, v5)
			end
		end

		setPropValue(k, workspace.CurrentCamera, "AttachToPart", nil)
		setPropValue(k, workspace.CurrentCamera, "LookAtPart", nil)
	end

	table.clear(k._lastSteppedFrames)
	v2[k] = nil
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
		table.clear(state._lastSteppedFrames)
		state._onLoop:Fire()
		currentFrame = 0
	end

	for i = state.CurrentFrame, currentFrame do
		for k, v4 in state._buffer do
			if state._locks[k] ~= nil then
				continue
			end

			local v5 = v4[i] or state._lastSteppedFrames[k]

			if not v5 then
				continue
			end

			state._lastSteppedFrames[k] = v5

			for k2, v6 in v5 do
				setPropValue(state, k, k2, v6)
			end
		end

		for k, _marker in state._markers do
			local v4 = _marker[i]

			if not v4 then
				continue
			end

			for k2, startMarker in v4.StartMarkers do
				if state._markerSignals[k2] then
					state._markerSignals[k2]:Fire(k, startMarker)
				end
			end

			for k2, endMarker in v4.EndMarkers do
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

function Moonlite.CreatePlayer(p, root)
	local bindableEvent = Instance.new("BindableEvent")
	local bindableEvent2 = Instance.new("BindableEvent")
	local moduleInfo = deepCopy(p)
	return (setmetatable({
		Completed = bindableEvent.Event,
		OnLoop = bindableEvent2.Event,
		Looped = moduleInfo.Information.Looped,
		Frames = moduleInfo.Information.Length,
		FrameRate = moduleInfo.Information.FPS or 60,
		RestoreDefaults = true,
		TimePosition = 0,
		CurrentFrame = 0,
		_moduleInfo = moduleInfo,
		_compiled = false,
		_completed = bindableEvent,
		_onLoop = bindableEvent2,
		_markers = {},
		_markerSignals = {},
		_endMarkerSignals = {},
		_locks = {},
		_elements = {},
		_buffer = {},
		_lastSteppedFrames = {},
		_scratch = {},
		_root = root
	}, class))
end

function class:Compile()
	if self._save then
		compileRouting(self)
		return self
	end

	if not self._moduleInfo then
		return self
	end

	local v3 = {}

	for k, v4 in self._moduleInfo.Compiled do
		local path = v4.Path or k
		local override = v4.Override or resolveAnimPath(path, self._root)

		if not override then
			continue
		end

		for _, v5 in v4.Props do
			local default = v5.Default

			if type(default) == "table" and type(default.ItemType) == "string" then
				default = default.Override or resolveAnimPath(default, self._root)
			end

			v5.Default = default

			for _, v6 in v5.Sequence do
				local value = v6.Value

				if type(value) == "table" and type(value.ItemType) == "string" then
					value = value.Override or resolveAnimPath(value, self._root)
				end

				v6.Value = value
			end
		end

		v3[override] = v4
	end

	compileFrames(self, v3)
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
	return v2[p] ~= nil
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
	local v3 = string.lower(value)

	if self._data then
		for _, item in self._data.Items do
			local path = item.Path

			if not (string.lower(toPath(path)) == v3 and (path.ItemType == "Rig" or override:IsA(path.ItemType))) then
				continue
			end

			item.Override = override
			return true
		end
	elseif self._moduleInfo then
		local v4 = false

		for k, v5 in self._moduleInfo.Compiled do
			local path = v5.Path or k
			local itemType = path.ItemType

			if string.lower(toPath(path)) == v3 and (itemType == "Rig" or override:IsA(path.ItemType)) then
				v5.Override = override
				v4 = true
			end

			for _, v6 in v5.Props do
				local default = v6.Default

				if type(default) == "table" and type(default.ItemType) == "string" and v3 == string.lower(toPath(default)) and (default.ItemType == "Rig" or override:IsA(default.ItemType)) then
					v5.Override = override
					v4 = true
				end

				for _, v7 in v6.Sequence do
					local value2 = v7.Value

					if not (type(value2) == "table" and type(value2.ItemType) == "string") then
						continue
					end

					if not (v3 == string.lower(toPath(value2)) and (value2.ItemType == "Rig" or override:IsA(value2.ItemType))) then
						continue
					end

					v5.Override = override
					v4 = true
				end
			end
		end

		return v4
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
	self.CurrentFrame = 0
	table.clear(self._lastSteppedFrames)
	task.spawn(restoreTrack, self)
	self._completed:Fire(Enum.PlaybackState.Cancelled)
end

function class:Reset()
	self.TimePosition = 0
	self.CurrentFrame = 0
	stepTrack(self, 0)
	return true
end

function class:Play()
	assert(self._compiled, "Track is not compiled.")

	if v2[self] then
		return
	end

	if self.TimePosition >= self:GetTimeLength() then
		self.TimePosition = 0
		self.CurrentFrame = 0
	end

	table.clear(self._lastSteppedFrames)
	local v3 = {}

	for k, v4 in self._buffer do
		if not v4[0] then
			continue
		end

		local v5 = {}
		v3[k] = v5

		for k2 in v4[0] do
			local propValue, v6 = getPropValue(self, k, k2)

			if propValue then
				v5[k2] = v6
			end
		end
	end

	v2[self] = v3
	self._completed:Fire(Enum.PlaybackState.Playing)
end

RunService.PreSimulation:Connect(function(dt)
	debug.profilebegin("Moonlite:stepTracks")

	for k in v2 do
		if stepTrack(k, dt) then
			restoreTrack(k)
		end
	end

	debug.profileend()
end)

function Moonlite.instanceToMoonAnimPath(instance)
	if not instance:IsDescendantOf(game) then
		error("Instance is not descendant of game")
	end

	local parent = instance
	local instanceNames = {}
	local instanceTypes = {}

	while parent ~= game do
		table.insert(instanceNames, 1, parent.Name)
		table.insert(instanceTypes, 1, parent.ClassName)
		parent = parent.Parent
	end

	table.insert(instanceNames, 1, "game")
	table.insert(instanceTypes, 1, "DataModel")
	return {
		InstanceTypes = instanceTypes,
		ItemType = instance.ClassName,
		InstanceNames = instanceNames
	}
end

Moonlite.resolveAnimPath = resolveAnimPath
Moonlite.toPathString = toPath
return Moonlite