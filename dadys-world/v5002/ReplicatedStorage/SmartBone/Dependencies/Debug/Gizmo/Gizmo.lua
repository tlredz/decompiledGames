local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local terrain = workspace:WaitForChild("Terrain")
local terrain2 = workspace:WaitForChild("Terrain")
assert(terrain, "No terrain object found under workspace")
assert(terrain2, "No target parent found.")
local aOTWireframeHandle = terrain2:FindFirstChild("AOTGizmoAdornment")
local wireframeHandle = terrain2:FindFirstChild("GizmoAdornment")

if not aOTWireframeHandle then
	aOTWireframeHandle = Instance.new("WireframeHandleAdornment")
	aOTWireframeHandle.Adornee = terrain
	aOTWireframeHandle.ZIndex = 1
	aOTWireframeHandle.AlwaysOnTop = true
	aOTWireframeHandle.Name = "AOTGizmoAdornment"
	aOTWireframeHandle.Parent = terrain2
end

if not wireframeHandle then
	wireframeHandle = Instance.new("WireframeHandleAdornment")
	wireframeHandle.Adornee = terrain
	wireframeHandle.ZIndex = 1
	wireframeHandle.AlwaysOnTop = false
	wireframeHandle.Name = "GizmoAdornment"
	wireframeHandle.Parent = terrain2
end

local gizmos = script.Parent:WaitForChild("Gizmos")
local v3 = {}
local v4 = {}
local v5 = {}
local v6 = {}
local v7 = {
	AlwaysOnTop = true,
	Color3 = Color3.fromRGB(13, 105, 172),
	Transparency = 0
}
local v8 = {}
local flag = false

local function Retain(p, p2)
	table.insert(v4, { p, p2 })
end

local function Register(p)
	p.Parent = terrain2
	table.insert(v3, p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Release(instance)
	local className = instance.ClassName

	if not v8[className] then
		v8[className] = {}
	end

	instance:Remove()
	table.insert(v8[className], instance)
end

local function Request(className)
	if not v8[className] then
		return Instance.new(className)
	end

	local v9 = table.remove(v8[className])

	if v9 then
		return v9
	end

	return Instance.new(className)
end

local function Lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local deepCopy

deepCopy = function(items)
	local result = {}

	for k, item in pairs(items) do
		if type(item) == "table" then
			item = deepCopy(item)
		end

		result[k] = item
	end

	return result
end

local Gizmo = {
	Enabled = true,
	ActiveRays = 0,
	ActiveInstances = 0,
	Styles = {
		Color = "Color3",
		Transparency = "Transparency",
		AlwaysOnTop = "AlwaysOnTop"
	},
	AOTWireframeHandle = aOTWireframeHandle,
	WireframeHandle = wireframeHandle,
	GetPoolSize = function()
		local total = 0

		for _, v9 in v8 do
			total += #v9
		end

		return total
	end,
	PushProperty = function(p, p2)
		v7[p] = p2

		if p == "AlwaysOnTop" then
			return
		end

		pcall(function()
			aOTWireframeHandle[p] = p2
			wireframeHandle[p] = p2
		end)
	end,
	PopProperty = function(p)
		if v7[p] then
			return v7[p]
		end

		return aOTWireframeHandle[p]
	end
}

function Gizmo.SetStyle(p, value, p2)
	if p ~= nil and typeof(p) == "Color3" then
		Gizmo.PushProperty("Color3", p)
	end

	if value ~= nil and typeof(value) == "number" then
		Gizmo.PushProperty("Transparency", value)
	end

	if p2 ~= nil and typeof(p2) == "boolean" then
		Gizmo.PushProperty("AlwaysOnTop", p2)
	end
end

function Gizmo.DoCleaning()
	aOTWireframeHandle:Clear()
	wireframeHandle:Clear()

	for _, v9 in v3 do
		Release(v9) -- equivalent call inferred; original call site unknown
	end

	v3 = {}
	Gizmo.ActiveRays = 0
	Gizmo.ActiveInstances = 0
end

function Gizmo.ScheduleCleaning()
	if flag then
		return
	end

	flag = true
	task.delay(0, function()
		Gizmo.DoCleaning()
		flag = false
	end)
end

function Gizmo.AddDebrisInSeconds(p: number, p2)
	table.insert(v5, {
		"Seconds",
		p,
		os.clock(),
		p2
	})
end

function Gizmo.AddDebrisInFrames(p: number, p2)
	table.insert(v5, {
		"Frames",
		p,
		0,
		p2
	})
end

function Gizmo.TweenProperties(p_Properties, goal, tweenInfo)
	local v9 = {
		p_Properties = p_Properties,
		Properties = deepCopy(p_Properties),
		Goal = goal,
		TweenInfo = tweenInfo,
		Time = 0
	}
	v6[v9] = true
	return function()
		v6[v9] = nil
	end
end

function Gizmo.Init()
	RunService.RenderStepped:Connect(function(dt)
		if Gizmo.Enabled then
			if not terrain2:FindFirstChild("AOTGizmoAdornment") then
				aOTWireframeHandle = Instance.new("WireframeHandleAdornment")
				aOTWireframeHandle.Adornee = terrain
				aOTWireframeHandle.ZIndex = 1
				aOTWireframeHandle.AlwaysOnTop = true
				aOTWireframeHandle.Name = "AOTGizmoAdornment"
				aOTWireframeHandle.Parent = terrain2
				Gizmo.AOTWireframeHandle = aOTWireframeHandle
			end

			if not terrain2:FindFirstChild("GizmoAdornment") then
				wireframeHandle = Instance.new("WireframeHandleAdornment")
				wireframeHandle.Adornee = terrain
				wireframeHandle.ZIndex = 1
				wireframeHandle.AlwaysOnTop = false
				wireframeHandle.Name = "GizmoAdornment"
				wireframeHandle.Parent = terrain2
				Gizmo.WireframeHandle = wireframeHandle
			end
		end

		for k in v6 do
			k.Time += dt
			local v9 = k.Time / k.TweenInfo.Time
			local v10 = v9 > 1 and 1 or v9

			-- equivalent calls inferred from this helper; original call sites unknown
			local function LerpProperty(property, p, value)
				if type(property) == "number" then
					return property + (p - property) * value
				end

				return property:Lerp(p, value)
			end

			for k2, property in k.Properties do
				if not k.Goal[k2] then
					continue
				end

				local value = TweenService:GetValue(v10, k.TweenInfo.EasingStyle, k.TweenInfo.EasingDirection)
				local lerpProperty = LerpProperty(property, k.Goal[k2], value) -- equivalent call inferred; original call site unknown
				k.p_Properties[k2] = lerpProperty
			end

			if v10 == 1 then
				v6[k] = nil
			end
		end

		for i = #v5, 1, -1 do
			local v9 = v5[i]
			local v10 = v9[1]
			local v11 = v9[2]
			local v12 = v9[3]
			local v13 = v9[4]

			if v10 == "Seconds" then
				if v11 < os.clock() - v12 then
					table.remove(v5, i)
				else
					v13()
				end
			elseif v11 < v12 then
				table.remove(v5, i)
			else
				v9[2] += 1
				v13()
			end
		end

		for i = #v4, 1, -1 do
			local v9 = v4[i]
			local v10 = v9[2]

			if not v10.Enabled then
				continue
			end

			if v10.Destroy then
				table.remove(v4, i)
			end

			v9[1]:Update(v10)
		end
	end)
end

function Gizmo.SetEnabled(enabled)
	Gizmo.Enabled = enabled

	if enabled == false then
		Gizmo.DoCleaning()
	end
end

function Gizmo.RemoveAdornments()
	if terrain2:FindFirstChild("AOTGizmoAdornment") then
		terrain2:FindFirstChild("AOTGizmoAdornment"):Destroy()
	end

	if terrain2:FindFirstChild("GizmoAdornment") then
		terrain2:FindFirstChild("GizmoAdornment"):Destroy()
	end
end

for _, moduleScript in gizmos:GetChildren() do
	local name = moduleScript.Name
	local module = require(moduleScript)
	Gizmo[name] = module.Init(Gizmo, v7, Request, Release, Retain, Register)
end

return Gizmo