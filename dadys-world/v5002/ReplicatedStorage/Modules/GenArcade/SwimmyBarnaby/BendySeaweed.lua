local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local v = {
	{
		MeshId = "rbxassetid://76801627927069",
		Rotation = 0,
		Scale = createVector(0.98, 1.67, 1.04)
	},
	{
		MeshId = "rbxassetid://139607285870934",
		Rotation = 1,
		Scale = createVector(0.81, 1.01, 0.74)
	},
	{
		MeshId = "rbxassetid://100358355445065",
		Rotation = 0,
		Scale = createVector(1.01, 1.18, 0.54)
	},
	{
		MeshId = "rbxassetid://89746798782543",
		Rotation = 1,
		Scale = createVector(0.88, 0.66, 1.04)
	},
	{
		MeshId = "rbxassetid://139847521496953",
		Rotation = 0,
		Scale = createVector(0.95, 1.18, 1.04)
	},
	{
		MeshId = "rbxassetid://136429943065415",
		Rotation = 1,
		Scale = createVector(0.89, 0.66, 0.5)
	}
}

for i = #v - 1, 1, -1 do
	local v2 = v[i]
	v[#v + 1] = {
		MeshId = v2.MeshId,
		Rotation = math.abs(v2.Rotation - 1),
		Scale = v2.Scale
	}
end

local count = #v

local function addObj(instance)
	local v2 = {}

	for k, v3 in pairs(v) do
		v2[k] = v3
	end

	setmetatable(v2, {
		__call = function(p)
			local _index = p._index or math.random(1, count)
			local _mult = p._mult or 1
			p._index = _index + 1 * _mult

			if p._index >= #p then
				p._index = #p
				p._mult = -_mult
			elseif p._index <= 1 then
				p._index = 1
				p._mult = -_mult
			end

			return _index
		end
	})
	local parent = instance.Parent
	local mesh = instance:WaitForChild("Mesh")
	local objectSpace = parent.CFrame:ToObjectSpace(instance.CFrame)
	local surfaceGui = parent:FindFirstChild("SurfaceGui")
	local textLabel = surfaceGui and surfaceGui:FindFirstChild("TextLabel")
	local now = 0
	local _ = math.sin
	local _ = math.random() * 100
	local cframe = CFrame.Angles(0, 0, 0)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function set(p)
		local v3 = v2[p]

		if not v3 then
			return
		end

		mesh.MeshId = v3.MeshId
		mesh.Scale = v3.Scale * (instance.Size / createVector(3, 8, 1))
		cframe = CFrame.Angles(0, v3.Rotation * 3.141592653589793, 0)
		instance.CFrame = parent.CFrame * objectSpace * cframe
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function update()
		instance.CFrame = parent.CFrame * objectSpace * cframe

		if tick() - now < 0.1 then
			return
		end

		now = tick()
		local text = v2()

		if textLabel then
			textLabel.Text = text
		end

		set(text) -- equivalent call inferred; original call site unknown
	end

	local connections = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function disconnect()
		if not connections then
			return
		end

		for _, connection in pairs(connections) do
			connection:Disconnect()
		end

		connections = nil
	end

	connections[#connections + 1] = instance.AncestryChanged:Connect(function(_, parent2)
		if parent2 == nil then
			disconnect() -- equivalent call inferred; original call site unknown
		end
	end)
	connections[#connections + 1] = RunService.RenderStepped:Connect(function()
		if connections then
			update() -- equivalent call inferred; original call site unknown
		end
	end)
end

CollectionService:GetInstanceAddedSignal("BendySeaweed"):Connect(addObj)
return {}