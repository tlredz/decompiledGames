local Moonlite = {}
require(script.Types)
local Specials = require(script.Specials)
local EaseFuncs = require(script.EaseFuncs)
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

if RunService:IsServer() then
	warn("Moonlite should NOT be used on the server! Rig transforms will not be replicated.")
end

local class = {}
class.__index = class
local v = {
	Instance = true,
	boolean = true,
	["nil"] = true
}
local v2 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function lerp(value, value2, p: number)
	if type(value) ~= "number" then
		return value:Lerp(value2, p)
	end

	assert(type(value2) == "number")
	return value + (value2 - value) * p
end

-- equivalent calls inferred from this helper; original call sites unknown
local function toPath(path)
	return table.concat(path.InstanceNames, ".")
end

local function resolveAnimPath(path, _root)
	if not path then
		return nil
	end

	local count = #path.InstanceNames
	local v3 = _root or game

	if pcall(function()
		for i = 2, count do
			local instanceName = path.InstanceNames[i]
			local instanceType = path.InstanceTypes[i]
			local v4 = v3[instanceName]
			assert(typeof(v4) == "Instance")
			assert(v4.ClassName == instanceType)
			v3 = v4
		end
	end) then
		return v3
	end

	warn("!! PATH RESOLVE FAILED:", table.concat(path.InstanceNames, "."))
	return nil
end

local function resolveJoints(folder)
	local result = {}

	for _, motor6D in folder:GetDescendants() do
		if not (motor6D:IsA("Motor6D") and motor6D.Active) then
			continue
		end

		local part1 = motor6D.Part1
		local name = part1 and part1.Name

		if name then
			result[name] = {
				Name = name,
				Joint = motor6D,
				Children = {}
			}
		end
	end

	for k, v3 in result do
		local part0 = v3.Joint.Part0

		if not part0 then
			continue
		end

		local parent = result[part0.Name]

		if not parent then
			continue
		end

		parent.Children[k] = v3
		v3.Parent = parent
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

local function setPropValue(p, k, p2: string, p3, flag: boolean?)
	if k then
		local v3 = Specials.Get(p._scratch, k, p2)

		if v3 then
			if v3.Get == nil and flag and p3 == true then
				p3 = false
			end

			return pcall(v3.Set, p3)
		end
	end

	return pcall(function()
		k[p2] = p3
	end)
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

			if not (_hier and _keyframes) then
				continue
			end

			local v4 = readValue(_hier)
			local v5 = v4:gmatch("[^%.]+")
			local joint = joints[v5()]

			while joint do
				local children = joint.Children
				local v6 = v5()

				if v6 == nil then
					break
				end

				if children[v6] then
					joint = children[v6]
				else
					warn((`failed to resolve joint '{v4}' (could not find child '{v6}' in {joint.Name}!)`))
					joint = nil
				end
			end

			if not joint then
				continue
			end

			local joint2 = joint.Joint
			p[joint2] = {
				Props = {
					Transform = {
						Default = CFrame.identity,
						Static = false,
						Sequence = unpackKeyframes(_keyframes, function(cframe: CFrame)
							return cframe:Inverse() * v3
						end)
					}
				},
				Target = joint2
			}
		end
	else
		local props = {}

		for _, folder in child:GetChildren() do
			if not (folder:IsA("Folder") and folder ~= markerTrack) then
				continue
			end

			local default = folder:FindFirstChild("default")
			local name = folder.Name
			props[name] = {
				Default = default and readValue(default),
				Static = Specials.Static(override, name),
				Sequence = unpackKeyframes(folder)
			}
		end

		p[override] = {
			Props = props,
			Target = override
		}
	end

	if markerTrack then
		local v3 = {}
		data._markers[override] = v3

		for _, child2 in markerTrack:GetChildren() do
			local v4 = assert((tonumber(child2.Name)))
			local valueBase2 = readValueBase(child2, "width") -- equivalent call inferred; original call site unknown
			local valueBase3 = readValueBase(child2, "name") -- equivalent call inferred; original call site unknown
			local v7 = {}
			local kFMarkers = child2:FindFirstChild("KFMarkers")

			if kFMarkers then
				for _, valueBase in kFMarkers:GetChildren() do
					if not valueBase:IsA("ValueBase") then
						continue
					end

					local value = valueBase.Value
					v7[value] = readValueBase(valueBase, "Val")
				end
			end

			local v8 = v3[v4]

			if not v8 then
				v8 = {
					StartMarkers = {},
					EndMarkers = {}
				}
				v3[v4] = v8
			end

			if valueBase2 > 0 then
				local v9 = math.min(v4 + valueBase2, data.Frames)
				local v10 = v3[v9]

				if not v10 then
					v10 = {
						StartMarkers = {},
						EndMarkers = {}
					}
					v3[v9] = v10
				end

				v10.EndMarkers[valueBase3] = v7
			end

			v8.StartMarkers[valueBase3] = v7
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

	for k, item in items do
		local v3 = {}
		_buffer[k] = v3

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

			for i = time, data.FrameRate do
				if not v3[i] then
					v3[i] = {}
				end

				v3[i][k2] = v5
			end
		end
	end
end

local function compileRouting(state)
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

	for k2, v4 in v3 do
		if k2.Name == "Camera" then
			setPropValue(k, k2, "AttachToPart", nil)
		end

		for k3, v5 in v4 do
			setPropValue(k, k2, k3, v5)
		end
	end

	v2[k] = nil
end

local function stepTrack(state, p: number)
	local v3 = math.floor(state.TimePosition * state.FrameRate)
	local v4 = math.min(p, 1 / state.FrameRate)

	if state.Frames < v3 then
		if state.Looped then
			state.TimePosition = 0
			v3 = 0
		else
			state._completed:Fire(Enum.PlaybackState.Completed)
			return true
		end
	end

	for k, v5 in state._buffer do
		if state._locks[k] ~= nil then
			continue
		end

		local v6 = v5[v3]

		if not v6 then
			continue
		end

		for k2, v7 in v6 do
			setPropValue(state, k, k2, v7)
		end
	end

	for k, _marker in state._markers do
		local v5 = _marker[v3]

		if not v5 then
			continue
		end

		for k2, startMarker in v5.StartMarkers do
			if state._markerSignals[k2] then
				state._markerSignals[k2]:Fire(k, startMarker)
			end
		end

		for k2, endMarker in v5.EndMarkers do
			if state._endMarkerSignals[k2] then
				state._endMarkerSignals[k2]:Fire(k, endMarker)
			end
		end
	end

	state.TimePosition += v4
	return false
end

function Moonlite.CreatePlayer(save, root)
	local jSONDecode = HttpService:JSONDecode(save.Value)
	local bindableEvent = Instance.new("BindableEvent")
	local object = setmetatable({
		Completed = bindableEvent.Event,
		Looped = jSONDecode.Information.Looped,
		Frames = jSONDecode.Information.Length,
		FrameRate = jSONDecode.Information.FPS or 60,
		TimePosition = 0,
		_save = save,
		_data = jSONDecode,
		_compiled = false,
		_completed = bindableEvent,
		_markers = {},
		_markerSignals = {},
		_endMarkerSignals = {},
		_locks = {},
		_elements = {},
		_buffer = {},
		_scratch = {},
		_root = root
	}, class)
	compileRouting(object)
	return object
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
	for _, item in self._data.Items do
		local path = item.Path
		local path2 = toPath(path) -- equivalent call inferred; original call site unknown

		if not (value:lower() == path2:lower() and (path.ItemType == "Rig" or override:IsA(path.ItemType))) then
			continue
		end

		item.Override = override
		compileRouting(self)
		return true
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
	if v2[self] then
		return
	end

	if self.TimePosition >= self:GetTimeLength() then
		self.TimePosition = 0
	end

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

RunService:BindToRenderStep("__UPDATE_MOONLITE_TRACKS", Enum.RenderPriority.Camera.Value + 1, function(p: number)
	for k in v2 do
		if stepTrack(k, p) then
			restoreTrack(k)
		end
	end
end)
return Moonlite