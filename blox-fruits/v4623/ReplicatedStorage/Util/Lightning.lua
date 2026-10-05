local createVector = vector.create
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
require(script:WaitForChild("Curves"))
local Draw = require(script:WaitForChild("Draw"))
local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)
local Lightning = {
	Stack = {}
}
Lightning.__index = Lightning

function Lightning:Initalize()
	RunService:BindToRenderStep("Lightning Step", 1, function(p)
		self:Step(p)
	end)
end

function Lightning.new(properties)
	local object = setmetatable({
		Life = 0,
		Lifetime = properties.Lifetime,
		Properties = properties
	}, Lightning)
	local color = Color3.new()
	local v = 0
	local v2 = 0
	local v3 = {
		Colors = function(_, _, p)
			local function ClosestAlpha()
				local v4 = nil
				local v5 = nil

				for k, color2 in pairs(properties.Colors) do
					if not (not v4 or math.abs(p - color2.Time) < v4) then
						continue
					end

					v4 = math.abs(p - color2.Time)

					if k > 1 and p > color2.Time and k + 1 <= #properties.Colors then
						v5 = k + 1
					else
						v5 = k
					end
				end

				return v5
			end

			local function GetColor(value, value2, p2)
				-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
				local function lerp(p3, p4, p5)
					return p3 * (1 - p5) + p4 * p5
				end

				local v4 = lerp(value.R, value2.R, p2)
				local v5 = lerp(value.G, value2.G, p2)
				return Color3.new(v4, v5, lerp(value.B, value2.B, p2))
			end

			local closestAlpha = ClosestAlpha()

			if closestAlpha then
				local v5 = closestAlpha == 1
				local v6 = v5 and closestAlpha or closestAlpha - 1

				if v5 then
					closestAlpha = closestAlpha + 1 or closestAlpha
				end

				local color2 = properties.Colors[v6]
				local color3 = properties.Colors[closestAlpha]
				local v7 = color2.Time - color3.Time
				local v8 = math.abs((p - color2.Time) / v7)
				color = GetColor(color2.Value, color3.Value, v8)
			end
		end,
		Sizes = function(_, _, p)
			local function ClosestAlpha()
				local v4 = nil
				local v5 = nil

				for k, siz in pairs(properties.Sizes) do
					if not (not v4 or math.abs(p - siz.Time) < v4) then
						continue
					end

					v4 = math.abs(p - siz.Time)

					if k > 1 and p > siz.Time and k + 1 <= #properties.Sizes then
						v5 = k + 1
					else
						v5 = k
					end
				end

				return v5
			end

			local closestAlpha = ClosestAlpha()

			if closestAlpha then
				local v5 = closestAlpha == 1
				local v6 = v5 and closestAlpha or closestAlpha - 1

				if v5 then
					closestAlpha = closestAlpha + 1 or closestAlpha
				end

				local siz = properties.Sizes[v6]
				local siz2 = properties.Sizes[closestAlpha]
				local v7 = siz2.Size - siz.Size
				local v8 = siz2.Time - siz.Time
				local v9 = math.abs((p - siz.Time) / v8)
				v2 = siz.Size + v7 * v9
			end
		end,
		Transparency = function(_, _, p)
			local function ClosestAlpha()
				local v4 = nil
				local v5 = nil

				for k, transparency in pairs(properties.Transparencies) do
					if not (not v4 or math.abs(p - transparency.Time) < v4) then
						continue
					end

					v4 = math.abs(p - transparency.Time)

					if k > 1 and p > transparency.Time and k + 1 <= #properties.Transparencies then
						v5 = k + 1
					else
						v5 = k
					end
				end

				return v5
			end

			local closestAlpha = ClosestAlpha()

			if closestAlpha then
				local v5 = closestAlpha == 1
				local v6 = v5 and closestAlpha or closestAlpha - 1

				if v5 then
					closestAlpha = closestAlpha + 1 or closestAlpha
				end

				local transparency = properties.Transparencies[v6]
				local transparency2 = properties.Transparencies[closestAlpha]
				local v7 = transparency2.Transparency - transparency.Transparency
				local v8 = transparency2.Time - transparency.Time
				local v9 = math.abs((p - transparency.Time) / v8)
				v = transparency.Transparency + v7 * v9
			end
		end,
		Points = function(p, p2, _)
			for _, point in pairs(p.Properties.Points) do
				local v4 = point.LastLockedPos and point.LockToPart.Position - point.LastLockedPos or Vector3.new()
				local v5 = point.Position + v4
				point.Velocity = point.Velocity:Lerp(Vector3.new(), point.Drag * p2) + point.Acceleration * p2
				point.Position = v5 + point.Velocity * p2

				if point.LockToPart then
					point.LastLockedPos = point.LockToPart.Position
				end
			end
		end
	}
	local drawType = object.Properties.DrawType

	if drawType == "Singular" then
		local arcSize = object.Properties.ArcSize
		object.SegmentHandler = object:DrawSingularSegments(arcSize.Min, arcSize.Max, v, color, v2)
	elseif drawType == "Multiple" then
		object.SegmentHandler = object:DrawMultipleSegments(v, color, v2)
	end

	local GUID = HttpService:GenerateGUID(false)

	Lightning.Stack[GUID] = function(p)
		object.Life += p

		if object.Life <= object.Lifetime then
			local v4 = object.Life / object.Lifetime

			for _, v5 in pairs(v3) do
				object:Thread(v5, object, p, v4)
			end

			object:UpdateSegments(p, v, color, v2)
		else
			object:WipeSegments()
			Lightning.Stack[GUID] = nil
		end
	end

	return object
end

function Lightning:DrawSingularSegments(p2, p3, transparency, color, p4)
	local random = Random.new()

	local function GetSegmentData(p5, p6, vector2, vector3, vector4)
		local v = p6 - p5
		local magnitude = v.Magnitude
		local unit = v.Unit
		local v2 = p5 + 0.25 * magnitude * unit
		local v3 = p5 + 0.5 * magnitude * unit
		local v4 = p5 + 0.75 * magnitude * unit
		local magnitude2 = (p5 - v2).Magnitude
		local magnitude3 = (v2 - v3).Magnitude
		local magnitude4 = (v3 - v4).Magnitude
		local number = random:NextNumber(p2, p3)
		local changesSegmentOffset = self.Properties.ChangesSegmentOffset

		if changesSegmentOffset then
			local bounds = self.Properties.OffsetChangePercent.Bounds
			changesSegmentOffset = self.Properties.OffsetChangePercent.EqualOrBelow >= random:NextNumber(unpack(bounds))
		end

		if not vector2 or not vector3 or not vector4 or changesSegmentOffset then
			vector2 = Vector3.new(
				random:NextNumber(math.max(-number, -number * magnitude2), (math.min(number, number * magnitude2))),
				random:NextNumber(math.max(-number, -number * magnitude2), (math.min(number, number * magnitude2))),
				random:NextNumber(math.max(-number, -number * magnitude2), (math.min(number, number * magnitude2)))
			)
			vector3 = Vector3.new(
				random:NextNumber(math.max(-number, -number * magnitude3), (math.min(number, number * magnitude3))),
				random:NextNumber(math.max(-number, -number * magnitude3), (math.min(number, number * magnitude3))),
				random:NextNumber(math.max(-number, -number * magnitude3), (math.min(number, number * magnitude3)))
			)
			vector4 = Vector3.new(
				random:NextNumber(math.max(-number, -number * magnitude4), (math.min(number, number * magnitude4))),
				random:NextNumber(math.max(-number, -number * magnitude4), (math.min(number, number * magnitude4))),
				random:NextNumber(math.max(-number, -number * magnitude4), (math.min(number, number * magnitude4)))
			)
		end

		local v5 = v2 + vector2
		local v6 = v3 + vector3
		local v7 = v4 + vector4
		return {
			{
				Distance = (v5 - p5).Magnitude,
				Direction = CFrame.new(p5, v5)
			},
			{
				Distance = (v6 - v5).Magnitude,
				Direction = CFrame.new(v5, v6)
			},
			{
				Distance = (v7 - v6).Magnitude,
				Direction = CFrame.new(v6, v7)
			},
			{
				Distance = (p6 - v7).Magnitude,
				Direction = CFrame.new(v7, p6)
			}
		}, { vector2, vector3, vector4 }
	end

	local v, v2 = GetSegmentData(self.Properties.Points.Start.Position, self.Properties.Points.End.Position)
	local v3 = {}

	for k, v4 in pairs(v) do
		local part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.Color = color
		part.Transparency = transparency
		part.Material = Enum.Material.Neon
		part.Size = createVector(0.2, 0.2, 0.2)
		local specialMesh = Instance.new("SpecialMesh")
		specialMesh.Name = "Mesh"
		specialMesh.MeshType = Enum.MeshType.Brick
		specialMesh.Scale = createVector(0.2, 0.2, 1)
		specialMesh.Offset = createVector(0, 0, 0)
		specialMesh.VertexColor = createVector(1, 1, 1)
		specialMesh.Parent = part
		specialMesh.Scale = Vector3.new(p4, p4, v4.Distance / 1) * 5
		part.CFrame = v4.Direction * CFrame.new(0, 0, -0.5 * v4.Distance)
		part.Parent = workspace._WorldOrigin
		table.insert(v3, k, {
			Instance = part,
			Mesh = specialMesh
		})
	end

	local v4 = v2
	return {
		Update = function(self, p5, p6, p7, transparency2, color2, p8)
			local v5, v6 = GetSegmentData(p6, p7, unpack(v2))
			local flag = false

			for k, v7 in pairs(v6) do
				if v2[k] ~= v7 then
					flag = true
				end
			end

			if flag then
				v4 = v6
				v5 = GetSegmentData(p6, p7, unpack(v4))
			end

			for k, v7 in pairs(v4) do
				v2[k] = v2[k]:Lerp(v7, (math.min(p5 * 20, 1)))
			end

			for k, v7 in pairs(v5) do
				local v8 = v3[k]
				v8.Mesh.Scale = Vector3.new(p8, p8, v7.Distance / 1) * 5
				v8.Instance.Color = color2
				v8.Instance.Transparency = transparency2
				v8.Instance.CFrame = v7.Direction * CFrame.new(0, 0, -0.5 * v7.Distance)
			end
		end,
		Destroy = function(self)
			for _, v5 in pairs(v3) do
				v5.Instance:Destroy()
			end
		end
	}
end

function Lightning:DrawMultipleSegments(transparency, color, thickness)
	local position = self.Properties.Points.Start.Position
	local position2 = self.Properties.Points.End.Position
	local v = Draw.new(position, position2, {
		color = color,
		thickness = thickness,
		transparency = transparency,
		seed = self.Properties.Seed,
		bends = self.Properties.Bends,
		fork_bends = self.Properties.Fork_Bends,
		fork_chance = self.Properties.Fork_Chance,
		max_depth = self.Properties.Max_Depth
	})
	v:Draw(workspace._WorldOrigin)
	return {
		Update = function(self, _, p5, p6, p7, p8, p9)
			v:Update(p5, p6, p7, p8, p9)
		end,
		Destroy = function(self)
			v:Destroy()
		end
	}
end

function Lightning:UpdateSegments(p2, p3, p4, p5)
	if self.SegmentHandler then
		local position = self.Properties.Points.Start.Position
		local position2 = self.Properties.Points.End.Position
		self.SegmentHandler:Update(p2, position, position2, p3, p4, p5)
	end
end

function Lightning:WipeSegments()
	if self.SegmentHandler then
		self.SegmentHandler:Destroy()
		self.SegmentHandler = nil
	end
end

function Lightning:Thread(callback, ...)
	local v = table.pack(...)
	return coroutine.resume(coroutine.create(function()
		callback(table.unpack(v))
	end))
end

function Lightning:Step(p)
	for _, v in pairs(self.Stack) do
		self:Thread(v, p)
	end
end

if RunService:IsRunning() and GlobalUtil.FFlags.IsUnitTest == false then
	Lightning:Initalize()
end

return Lightning