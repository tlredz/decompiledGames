local Cutter = {}
local v = {
	Wall = {},
	Floor = {},
	Ramp = {}
}
local v2 = {
	Wall = {},
	Floor = {},
	Ramp = {}
}
local v3 = {
	[2] = script.CutFrames.Wall.Door,
	[3] = script.CutFrames.Wall.Window,
	[4] = script.CutFrames.Wall.Fence,
	[5] = script.CutFrames.Wall.LeftTriangle,
	[6] = script.CutFrames.Wall.RightTriangle
}
local v4 = {
	[2] = script.CutFrames.Floor.LeftFloor,
	[3] = script.CutFrames.Floor.RightFloor,
	[4] = script.CutFrames.Floor.ForwardFloor,
	[5] = script.CutFrames.Floor.BackFloor
}
local v5 = {
	[2] = script.CutFrames.Ramp.LeftRamp,
	[3] = script.CutFrames.Ramp.RightRamp
}

local function getVariantKey(p: string, p2: number)
	if p2 == 1 then
		error("No cutting needed for variant 1")
	end

	local v6 = nil

	if p == "Wall" then
		v6 = v3
	elseif p == "Floor" then
		v6 = v4
	elseif p == "Ramp" then
		v6 = v5
	end

	return v6[p2]
end

function deepCopy(items)
	if type(items) ~= "table" then
		return items
	end

	local copiesByCopy = {}

	for k, item in next, items, nil do
		copiesByCopy[deepCopy(k)] = deepCopy(item)
	end

	setmetatable(copiesByCopy, deepCopy((getmetatable(items))))
	return copiesByCopy
end

function Cutter.getCutMatrix(p: string, p2: number, list)
	if p2 == 1 then
		error("No cutting needed for variant 1")
	end

	local v6 = nil

	if p == "Wall" then
		v6 = v3
	elseif p == "Floor" then
		v6 = v4
	elseif p == "Ramp" then
		v6 = v5
	end

	local v7 = v6[p2]

	if v[p][v7] then
		return v[p][v7]
	end

	local children = v7.ParentFrameVisual:GetChildren()
	local copy = deepCopy(list)
	local v8 = #list
	local v9 = #list[1]

	for i, list2 in ipairs(list) do
		for i2, _ in ipairs(list2) do
			copy[i][i2] = 0
		end
	end

	for _, v10 in ipairs(children) do
		for i, list2 in ipairs(list) do
			for i2, _ in ipairs(list2) do
				local v11 = (i2 - 0.5) / v9
				local v12 = (i - 0.5) / v8
				local scale = v10.Position.X.Scale
				local v13 = v10.Position.X.Scale + v10.Size.X.Scale
				local scale2 = v10.Position.Y.Scale
				local v14 = v10.Position.Y.Scale + v10.Size.Y.Scale
				local v15

				if scale <= v11 then
					v15 = v11 <= v13
				else
					v15 = false
				end

				local v16

				if scale2 <= v12 then
					v16 = v12 <= v14
				else
					v16 = false
				end

				if v15 and v16 then
					copy[i][i2] = 1
				end
			end
		end
	end

	v[p][v7] = copy
	return copy
end

function Cutter.getCutMatrixBackToScaleVector2(p: string, p2: number, list)
	if p2 == 1 then
		error("No cutting needed for variant 1")
	end

	local v6 = nil

	if p == "Wall" then
		v6 = v3
	elseif p == "Floor" then
		v6 = v4
	elseif p == "Ramp" then
		v6 = v5
	end

	local v7 = v6[p2]

	if v2[p][v7] then
		return v2[p][v7]
	end

	local children = v7.ParentFrameVisual:GetChildren()
	local count = #list
	local count2 = #list[1]
	local clones = {}

	for _, v8 in ipairs(children) do
		local copy = deepCopy(list)
		local v9 = 1e999
		local v10 = -1e999
		local v11 = 1e999
		local v12 = -1e999

		for i, list2 in ipairs(list) do
			for i2, _ in ipairs(list2) do
				copy[i][i2] = 0
			end
		end

		for i, list2 in ipairs(list) do
			for i2, _ in ipairs(list2) do
				local v13 = (i2 - 0.5) / count2
				local v14 = (i - 0.5) / count
				local scale = v8.Position.X.Scale
				local v15 = v8.Position.X.Scale + v8.Size.X.Scale
				local scale2 = v8.Position.Y.Scale
				local v16 = v8.Position.Y.Scale + v8.Size.Y.Scale
				local v17

				if scale <= v13 then
					v17 = v13 <= v15
				else
					v17 = false
				end

				local v18

				if scale2 <= v14 then
					v18 = v14 <= v16
				else
					v18 = false
				end

				if v17 and v18 then
					copy[i][i2] = 1
				end
			end
		end

		for i, list2 in ipairs(copy) do
			for i2, v13 in ipairs(list2) do
				local v14 = (i2 - 0.5) / count2
				local v15 = (i - 0.5) / count

				if v13 ~= 1 then
					continue
				end

				if v14 < v9 then
					v9 = v14
				end

				if v10 < v14 then
					v10 = v14
				end

				if v15 < v11 then
					v11 = v15
				end

				if v12 < v15 then
					v12 = v15
				end
			end
		end

		local v13 = v9 - 0.5 / count2
		local v14 = v10 + 0.5 / count2
		local v15 = v11 - 0.5 / count
		local v16 = v12 + 0.5 / count
		local clone = v8:Clone()
		clone.Position = UDim2.fromScale(v13, v15)
		clone.Size = UDim2.fromScale(v14 - v13, v16 - v15)
		table.insert(clones, clone)
	end

	v2[p][v7] = clones
	return clones
end

local function clearAllAttributes(instance)
	for k in pairs(instance:GetAttributes()) do
		instance:SetAttribute(k, nil)
	end
end

function Cutter.cutPartInstance(p: string, p2: number, parent, p3)
	if p2 == 1 then
		error("No cutting needed for variant 1")
	end

	local v6 = nil

	if p == "Wall" then
		v6 = v3
	elseif p == "Floor" then
		v6 = v4
	elseif p == "Ramp" then
		v6 = v5
	end

	local _ = v6[p2]
	local cutMatrixBackToScaleVector2 = Cutter.getCutMatrixBackToScaleVector2(p, p2, p3)
	local model = Instance.new("Model")
	model.Name = "CollisionModel"
	local isPotentialSurface = parent:GetAttribute("IsPotentialSurface")

	for _, v7 in ipairs(cutMatrixBackToScaleVector2) do
		local instance = Instance.fromExisting(parent)
		clearAllAttributes(instance)
		instance.CanCollide = not isPotentialSurface
		instance.CanTouch = not isPotentialSurface
		instance.CanQuery = false
		local scale = v7.Position.X.Scale
		local v8 = v7.Position.X.Scale + v7.Size.X.Scale
		local scale2 = v7.Position.Y.Scale
		local v9 = v7.Position.Y.Scale + v7.Size.Y.Scale
		instance.Size = Vector3.new((v8 - scale) * parent.Size.X, (v9 - scale2) * parent.Size.Y, parent.Size.Z)
		instance.Position = parent.CFrame:PointToWorldSpace(Vector3.new(-(-0.5 + scale), 0.5 - scale2, 0) * parent.Size):Lerp(
			parent.CFrame:PointToWorldSpace(Vector3.new(-(-0.5 + v8), 0.5 - v9, 0) * parent.Size),
			0.5
		)
		instance.Parent = model
	end

	model.Parent = parent
	parent.CanCollide = false
end

return Cutter