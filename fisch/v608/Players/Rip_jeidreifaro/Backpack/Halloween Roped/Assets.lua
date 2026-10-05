local createVector = vector.create
BaseUrl = "http://www.roblox.com/asset/?id="

local function Create_PrivImpl(className)
	if type(className) ~= "string" then
		error("Argument of Create must be a string", 2)
	end

	return function(options)
		local instance = Instance.new(className)
		local v = nil
		local parent = nil

		for k, v3 in pairs(options or {}) do
			if type(k) == "string" then
				if k == "Parent" then
					parent = v3
				else
					instance[k] = v3
				end
			elseif type(k) == "number" then
				if type(v3) ~= "userdata" then
					error("Bad entry in Create body: Numeric keys must be paired with children, got a: " .. type(v3), 2)
				end

				v3.Parent = instance
			elseif type(k) == "table" and k.__eventname then
				if type(v3) ~= "function" then
					error(
						"Bad entry in Create body: Key `[Create.E'" .. k.__eventname .. "']` must have a function value\n\t\t\t\t\t\t\tgot: " .. tostring(v3),
						2
					)
				end

				instance[k.__eventname]:connect(v3)
			elseif k == t.Create then
				if type(v3) == "function" then
					if v then
						error("Bad entry in Create body: Only one constructor function is allowed", 2)
					end
				else
					error([[
Bad entry in Create body: Key `[Create]` should be paired with a constructor function, 
							got: ]] .. tostring(v3), 2)
				end

				v = v3
			else
				error("Bad entry (" .. tostring(k) .. " => " .. tostring(v3) .. ") in Create body", 2)
			end
		end

		if v then
			v(instance)
		end

		if parent then
			instance.Parent = parent
		end

		return instance
	end
end

Create = setmetatable({}, {
	__call = function(_, ...)
		local v = ...

		if type(v) ~= "string" then
			error("Argument of Create must be a string", 2)
		end

		return function(options)
			local instance = Instance.new(v)
			local v2 = nil
			local parent = nil

			for k, v4 in pairs(options or {}) do
				if type(k) == "string" then
					if k == "Parent" then
						parent = v4
					else
						instance[k] = v4
					end
				elseif type(k) == "number" then
					if type(v4) ~= "userdata" then
						error(
							"Bad entry in Create body: Numeric keys must be paired with children, got a: " .. type(v4),
							2
						)
					end

					v4.Parent = instance
				elseif type(k) == "table" and k.__eventname then
					if type(v4) ~= "function" then
						error(
							"Bad entry in Create body: Key `[Create.E'" .. k.__eventname .. "']` must have a function value\n\t\t\t\t\t\t\tgot: " .. tostring(v4),
							2
						)
					end

					instance[k.__eventname]:connect(v4)
				elseif k == t.Create then
					if type(v4) == "function" then
						if v2 then
							error("Bad entry in Create body: Only one constructor function is allowed", 2)
						end
					else
						error([[
Bad entry in Create body: Key `[Create]` should be paired with a constructor function, 
							got: ]] .. tostring(v4), 2)
					end

					v2 = v4
				else
					error("Bad entry (" .. tostring(k) .. " => " .. tostring(v4) .. ") in Create body", 2)
				end
			end

			if v2 then
				v2(instance)
			end

			if parent then
				instance.Parent = parent
			end

			return instance
		end
	end
})

function Create.E(eventname)
	return {
		__eventname = eventname
	}
end

BasePart = Create("Part")({
	Material = Enum.Material.Plastic,
	Shape = Enum.PartType.Block,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	FormFactor = Enum.FormFactor.Custom,
	Size = createVector(0.2, 0.2, 0.2),
	Anchored = false,
	CanCollide = true,
	CollisionGroup = "Players",
	Locked = true
})
MeshData = {
	Meshes = {
		Body = 179154910,
		Wheel = 179154928
	},
	TextureId = 179154958
}

function CreateVehicle()
	local clone = BasePart:Clone()
	clone.Name = "Body"
	clone.Size = createVector(1, 5.125, 6)
	clone.CanCollide = false
	Create("SpecialMesh")({
		MeshType = Enum.MeshType.FileMesh,
		MeshId = MeshData.Meshes.Body,
		TextureId = MeshData.TextureId,
		Scale = createVector(1, 1, 1),
		VertexColor = createVector(1, 1, 1),
		Offset = createVector(0, 0, 0),
		Parent = clone
	})
	local clone2 = BasePart:Clone()
	clone2.Size = createVector(0.5, 1, 1)
	clone2.Shape = Enum.PartType.Cylinder
	clone2.CanCollide = true
	Create("SpecialMesh")({
		MeshType = Enum.MeshType.FileMesh,
		MeshId = "",
		TextureId = MeshData.TextureId,
		Scale = createVector(1, 1, 1),
		VertexColor = createVector(1, 1, 1),
		Offset = createVector(0, 0, 0),
		Parent = clone2
	})
	local clone3 = clone2:Clone()
	clone3.Name = "FrontWheel"
	clone3.Mesh.MeshId = MeshData.Meshes.Wheel
	local clone4 = clone2:Clone()
	clone4.Name = "BackWheel"
	clone4.Mesh.MeshId = MeshData.Meshes.Wheel
	local clone5 = BasePart:Clone()
	clone5.Name = "SmokePart"
	clone5.Transparency = 1
	Create("Smoke")({
		Name = "ExhaustSmoke",
		Size = 0.1,
		RiseVelocity = 0.01,
		Color = Color3.new(0.8549019607843137, 0.5215686274509804, 0.2549019607843137),
		Enabled = true,
		Parent = clone5
	})
	local clone6 = BasePart:Clone()
	clone6.Name = "LightPart"
	clone6.Transparency = 1
	Create("PointLight")({
		Name = "Light",
		Brightness = 2,
		Color = Color3.new(1, 0.9882352941176471, 0.6),
		Range = 10,
		Shadows = false,
		Enabled = false,
		Parent = clone6
	})
	local lights = {}
	local sparkles = {}
	local exhaustSmokes = {}

	for _ = 1, 5 do
		Create("Sparkles")({
			SparkleColor = Color3.new(0, 1, 0),
			Enabled = false,
			Parent = clone6
		})
	end

	local clone7 = clone3:Clone()
	clone7.Parent = clone
	Create("Motor6D")({
		Name = "FrontMotor",
		Part0 = clone,
		Part1 = clone7,
		C0 = CFrame.new(0, -2.05, -2.365) * CFrame.Angles(0, 1.5707963267948966, 0),
		C1 = CFrame.new() * CFrame.Angles(0, -1.5707963267948966, 0),
		Parent = clone
	})
	local clone8 = clone4:Clone()
	clone8.Parent = clone
	Create("Motor6D")({
		Name = "BackMotor",
		Part0 = clone,
		Part1 = clone8,
		C0 = CFrame.new(0, -2.05, 2.4) * CFrame.Angles(0, 1.5707963267948966, 0),
		C1 = CFrame.new() * CFrame.Angles(0, -1.5707963267948966, 0),
		Parent = clone
	})
	local clone9 = clone6:Clone()
	clone9.Parent = clone
	table.insert(lights, clone9.Light)

	for _, sparkles2 in pairs(clone9:GetChildren()) do
		if sparkles2:IsA("Sparkles") then
			table.insert(sparkles, sparkles2)
		end
	end

	Create("Weld")({
		Part0 = clone,
		Part1 = clone9,
		C0 = CFrame.new(0, -1, 1.75) * CFrame.Angles(0, 0, 0),
		Parent = clone9
	})
	local clone10 = clone5:Clone()
	clone10.Name = "ExhaustPipe"
	clone10.Parent = clone
	table.insert(exhaustSmokes, clone10.ExhaustSmoke)
	Create("Weld")({
		C0 = CFrame.new(0, 1.45, -2.75) * CFrame.Angles(0, 0, 0),
		Part0 = clone10,
		Part1 = clone,
		Parent = clone10
	})
	return {
		Vehicle = clone,
		Tables = {
			ExhaustSmoke = exhaustSmokes,
			Lights = lights,
			Sparkles = sparkles
		}
	}
end

for k, v in pairs(MeshData) do
	if type(v) == "table" then
		for k2, item in pairs(v) do
			if not (type(item) == "string" or type(item) == "number") then
				continue
			end

			MeshData[k][k2] = BaseUrl .. tostring(item)
		end
	elseif type(v) == "string" or type(v) == "number" then
		MeshData[k] = BaseUrl .. tostring(v)
	end
end

return {
	BaseUrl = BaseUrl,
	MeshData = MeshData,
	CreateVehicle = CreateVehicle
}