local createVector = vector.create
local RunService = game:GetService("RunService")
local parent = script.Parent
local parent2 = parent.Parent
local mesh = parent:WaitForChild("Mesh")
local objectSpace = parent2.CFrame:ToObjectSpace(parent.CFrame)
local v = {
	{
		MeshId = "rbxassetid://139607285870934",
		Rotation = 1,
		Scale = createVector(0.81, 1.01, 0.74)
	},
	{
		MeshId = "rbxassetid://110924288772044",
		Rotation = 1,
		Scale = createVector(0.81, 1.01, 1.04)
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
		MeshId = "rbxassetid://100358355445065",
		Rotation = 0,
		Scale = createVector(1.01, 1.18, 0.54)
	},
	{
		MeshId = "rbxassetid://76801627927069",
		Rotation = 0,
		Scale = createVector(0.98, 1.67, 1.04)
	},
	{
		MeshId = "rbxassetid://129209812595771",
		Rotation = 0,
		Scale = createVector(0.99, 1.67, 0.8)
	},
	{
		MeshId = "rbxassetid://136429943065415",
		Rotation = 1,
		Scale = createVector(0.89, 0.66, 0.5)
	}
}

for i = #v, 1, -1 do
	local v2 = v[i]
	v[#v + 1] = {
		MeshId = v2.MeshId,
		Rotation = math.abs(v2.Rotation - 1),
		Scale = v2.Scale
	}
end

local count = #v
local cframe = CFrame.Angles(0, 0, 0)

-- equivalent calls inferred from this helper; original call sites unknown
local function set(p)
	local v2 = v[p]

	if not v2 then
		return
	end

	mesh.MeshId = v2.MeshId
	mesh.Scale = v2.Scale * (parent.Size / createVector(3, 8, 1))
	cframe = CFrame.Angles(0, v2.Rotation * 3.141592653589793, 0)
end

local now = 0
local sin = math.sin
local v2 = math.random() * 100
RunService.RenderStepped:Connect(function()
	parent.CFrame = parent2.CFrame * objectSpace * cframe

	if tick() - now < 0.15 then
		return
	end

	now = tick()
	local v3 = (tick() + v2) * 0.4
	local v7 = sin(7.4 * v3) + sin(7.4 * v3 * 0.7)
	local v8 = 7.4 * v3 * 0.2
	set(math.round(((v7 + sin(v8)) / 6 + 0.5) * count)) -- equivalent call inferred; original call site unknown
end)