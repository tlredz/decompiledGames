local createVector = vector.create
local Util = require(script.Parent.Util)
local Worldspace = {}

function CreateDot(p)
	local part = Instance.new("Part")
	part.Name = "Dot"
	part.Shape = "Cylinder"
	part.Color = Color3.new(1, 1, 1)
	part.Material = Enum.Material.SmoothPlastic
	part.CastShadow = false
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Anchored = true
	part.Rotation = createVector(0, 0, 90)
	part.Parent = p.Instance
	return part
end

function PositionDot(p, p2, p3: number, flag: boolean)
	local v = math.ceil(#p._PartArray * p3 / 100) - 1
	local v2 = p._PartArray[v]

	if v <= 0 then
		if #p._PartArray > 0 then
			v2 = p._PartArray[1]
			flag = true
		else
			return
		end
	end

	local v3 = v2.Size.Z / 2

	if flag then
		v3 = -v3
	end

	local v4 = CFrame.new((Vector3.new(0, 0, v3))) * CFrame.Angles(0, 0, 1.5707963267948966)
	p2.CFrame = v2.CFrame:ToWorldSpace(v4)
end

function Position(data, p, p2: number)
	local v = math.rad(p2)
	local v2 = math.cos(v) * data.Radius
	local v3 = math.sin(v) * data.Radius
	local shiftRange = Util.ShiftRange({ 0, 360 }, { 0, -360 }, p2)
	local v4 = CFrame.new(Vector3.new(v2, 0, v3) + data.Position) * CFrame.Angles(0, math.rad(shiftRange), 0)
	p.CFrame = CFrame.Angles(math.rad(data.Rotation.X), math.rad(data.Rotation.Y), (math.rad(data.Rotation.Z))):ToWorldSpace(v4)
end

function UpdateFill(data)
	local v = data.Progress / 100
	local v2 = math.ceil(#data._PartArray * v)
	local _ = #data._PartArray - v2

	for k, v3 in pairs(data._PartArray) do
		if v2 <= k then
			v3.Transparency = 1
			v3:SetAttribute("Disabled", true)
		elseif v3:GetAttribute("Disabled") then
			v3:SetAttribute("Disabled", false)
			v3.Transparency = data.Transparency
		end
	end

	PositionDot(data, data._Dot, data.Progress)
end

function UpdateCircle(state)
	local v = state.Thickness * math.tan((math.rad(state._Deg)))
	state._Length = state.Radius * math.tan((math.rad(state._Deg / 2))) * 2 + v / 2
	local vector2 = Vector3.new(1, state.Thickness, state.Thickness)
	state._Dot.Size = vector2
	state._CenterDot.Size = vector2

	for k, v2 in pairs(state._PartArray) do
		v2.Size = Vector3.new(state.Thickness, 1, state._Length)
		Position(state, v2, state._Deg * k)
	end

	PositionDot(state, state._CenterDot, 0, true)
	PositionDot(state, state._Dot, state.Progress)
end

function UpdateAccuracy(state)
	local v = math.ceil(state.Accuracy * 20)
	state._Deg = 360 / v

	if state._PartArray == v then
		return
	end

	local v2 = math.abs(#state._PartArray - v)

	if #state._PartArray < v then
		for _ = 0, v2 do
			local part = Instance.new("Part")
			part.Color = Color3.new(1, 1, 1)
			part.Material = Enum.Material.SmoothPlastic
			part.CastShadow = false
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
			part.Anchored = true
			part.Parent = state.Instance
			table.insert(state._PartArray, part)
		end
	elseif v < #state._PartArray then
		for i = #state._PartArray, v, -1 do
			state._PartArray[i]:Destroy()
			table.remove(state._PartArray, i)

			if #state._PartArray == v + 1 then
				break
			end
		end
	end

	UpdateCircle(state)
	UpdateFill(state)
end

local v = {
	Progress = function(p)
		UpdateFill(p)
	end,
	Rotation = function(p)
		UpdateCircle(p)
	end,
	Position = function(p)
		UpdateCircle(p)
	end,
	Thickness = function(p)
		UpdateCircle(p)
	end,
	Radius = function(p)
		UpdateCircle(p)
	end,
	Accuracy = function(p)
		UpdateAccuracy(p)
	end,
	Color = function(data)
		for _, v2 in pairs(data._PartArray) do
			v2.Color = data.Color
		end

		data._Dot.Transparency = data.Color
		data._CenterDot.Transparency = data.Color
	end,
	Transparency = function(data)
		for _, v2 in pairs(data._PartArray) do
			if not v2:GetAttribute("Disabled") then
				v2.Transparency = data.Transparency
			end

			if data._Dot:GetAttribute("Disabled") then
				continue
			end

			data._Dot.Transparency = data.Transparency
			data._CenterDot.Transparency = data.Transparency
		end
	end,
	Rounded = function(data)
		data._Dot:SetAttribute("Disabled", not data.Rounded)
		local transparency = data.Transparency
		local transparency2 = not data.Rounded and 1 or transparency
		data._Dot.Transparency = transparency2
		data._CenterDot.Transparency = transparency2
	end,
	Parent = function(state)
		if state.Parent == nil and state._InitializeParent == true then
			state.Parent = workspace
			state._Folder = false
		end

		state.Instance.Parent = state.Parent
	end
}

function Worldspace.new(items)
	local v2 = {
		Progress = 0,
		Rotation = createVector(0, 0, 0),
		Position = createVector(0, 0, 0),
		Accuracy = 3,
		Thickness = 4,
		Radius = 10,
		Color = Color3.fromRGB(255, 255, 255),
		Transparency = 0,
		Rounded = true,
		Parent = nil
	}

	if items then
		for k, item in pairs(items) do
			v2[k] = item
		end
	end

	v2._PartArray = {}
	v2._DisabledParts = {}
	v2._Deg = 0
	v2._Length = 0
	v2._InitializeParent = true
	v2.Instance = Instance.new("Folder")
	v2.Instance.Name = "ProgressCircle"
	v2._Dot = CreateDot(v2)
	v2._CenterDot = CreateDot(v2)

	for _, v3 in pairs(v) do
		v3(v2)
	end

	local self = setmetatable({}, {
		__index = function(_, p, _)
			if v2[p] ~= nil then
				return v2[p]
			end

			if Worldspace[p] == nil then
				return
			else
				return Worldspace[p]
			end
		end,
		__newindex = function(_, p, p2)
			if v[p] and v2[p] ~= p2 then
				v2[p] = p2
				v[p](v2)
			end
		end
	})
	v2._TweenService = Util.TweenService.new(self)
	return self
end

function Worldspace:Tween(p2, p3)
	self._TweenService:Tween(p2, p3)
end

function Worldspace:Destroy()
	self.Instance:Destroy()
	self._TweenService:Destroy()
	setmetatable(self, nil)
end

return Worldspace