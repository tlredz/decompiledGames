local createVector = vector.create
game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SpatialIndex = {}
SpatialIndex.__index = SpatialIndex

function SpatialIndex:Get(vector2: Vector3)
	local v = vector2 // self.SpatialSize * self.SpatialSize * self.SpatialVector
	local X = v.X
	local Y = v.Y
	local Z = v.Z

	if not self.Cache[X] then
		return
	end

	if self.Cache[X][Y] then
		return self.Cache[X][Y][Z]
	end
end

function SpatialIndex.Set(data, vector2: Vector3, p, p2)
	local v = vector2 // data.SpatialSize * data.SpatialSize * data.SpatialVector
	local X = v.X
	local Y = v.Y
	local Z = v.Z

	if not data.Cache[X] then
		data.Cache[X] = {}
	end

	if not data.Cache[X][Y] then
		data.Cache[X][Y] = {}
	end

	if not data.Cache[X][Y][Z] then
		data.Cache[X][Y][Z] = {}
	end

	if data.Cache[X][Y][Z][p] then
		return
	end

	data.Cache[X][Y][Z][p] = p2
	local v2 = (v - data.NowPosition) // data.SpatialSize
	local v3 = math.max(math.abs(v2.X), math.abs(v2.Y), (math.abs(v2.Z)))

	if data.SpatialFunctions[v3] then
		data.SpatialFunctions[v3](data, p, p2)
	else
		data.SpatialFunctions[-1](data, p, p2)
	end

	if v3 <= data.SpatialQuerySize then
		data.LastNeighbors[p] = p2
	end
end

function SpatialIndex:Remove(p, vector2: Vector3?)
	local v = vector2 or p.CFrame.Position // self.SpatialSize * self.SpatialSize * self.SpatialVector
	local X = v.X
	local Y = v.Y
	local Z = v.Z

	if not (self.Cache[X] and self.Cache[X][Y] and self.Cache[X][Y][Z]) then
		return
	end

	self.Cache[X][Y][Z][p] = nil

	if not next(self.Cache[X][Y][Z]) then
		self.Cache[X][Y][Z] = nil
	end

	if #self.Cache[X][Y] == 0 then
		self.Cache[X][Y] = nil
	end

	if #self.Cache[X] == 0 then
		self.Cache[X] = nil
	end
end

function SpatialIndex:GetNeighbors(vector2: Vector3, p: number)
	local v = vector2 // self.SpatialSize * self.SpatialSize * self.SpatialVector
	local v2 = p * self.SpatialVector
	local X = v2.X
	local Y = v2.Y
	local Z = v2.Z
	local result = {}

	for i = 0, p do
		if not result[i] then
			result[i] = {}
		end
	end

	for i = -X, X do
		for i2 = -Y, Y do
			for i3 = -Z, Z do
				local v3 = self:Get(v + Vector3.new(i, i2, i3) * self.SpatialSize)

				if not v3 then
					continue
				end

				local v4 = math.max(math.abs(i), math.abs(i2), (math.abs(i3)))

				for k, v5 in v3 do
					result[v4][k] = v5
				end
			end
		end
	end

	return result
end

function SpatialIndex:Destroy()
	for _, connection in self.Connections do
		connection:Disconnect()
	end

	self.Cache = nil
	self.Connections = nil
	self.Subject = nil
	self.SpatialSize = nil
	self.SpatialFunctions = nil
	self.SpatialQuerySize = nil
	self.CacheFunction = nil
	self.SpatialVector = nil
	self.LastNeighbors = nil
	self.NowPosition = nil
end

function SpatialIndex.new(subject, spatialSize: number, vector2: Vector3?, cacheFunction, spatialFunctions)
	local object = setmetatable({}, SpatialIndex)
	object.Cache = {}
	object.Connections = {}
	object.Subject = subject
	object.SpatialSize = spatialSize
	object.SpatialFunctions = spatialFunctions
	object.SpatialQuerySize = 0
	object.CacheFunction = cacheFunction
	object.SpatialVector = vector2 or createVector(1, 1, 1)
	object.LastNeighbors = {}
	object.NowPosition = object.Subject.CFrame.Position // object.SpatialSize * object.SpatialSize * object.SpatialVector
	local nowPosition = nil

	for _, _ in object.SpatialFunctions do
		object.SpatialQuerySize += 1
	end

	object.SpatialQuerySize -= 2
	cacheFunction(object)
	local renderSteppedConnection = RunService.RenderStepped:Connect(function(_: number)
		object.NowPosition = object.Subject.CFrame.Position // object.SpatialSize * object.SpatialSize * object.SpatialVector

		if nowPosition == object.NowPosition then
			return
		end

		nowPosition = object.NowPosition
		local lastNeighbors = {}

		for k, v2 in object:GetNeighbors(object.Subject.CFrame.Position, object.SpatialQuerySize) do
			if not object.SpatialFunctions[k] then
				continue
			end

			for k2, v3 in v2 do
				if k2.Parent then
					object.SpatialFunctions[k](object, k2, v3)
					lastNeighbors[k2] = v3
				else
					object:Remove(k2)
				end
			end
		end

		for k in object.LastNeighbors do
			if lastNeighbors[k] then
				continue
			end

			if k.Parent then
				object.SpatialFunctions[-1](object, k, object.LastNeighbors[k])
			else
				object:Remove(k)
			end
		end

		object.LastNeighbors = lastNeighbors
	end)
	table.insert(object.Connections, renderSteppedConnection)
	return object
end

return SpatialIndex