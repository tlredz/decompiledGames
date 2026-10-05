local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Signal = require(ReplicatedStorage.Packages.Signal)
local sine = Enum.EasingStyle.Sine
local inOut = Enum.EasingDirection.InOut
local color = Color3.new(1, 1, 1)
local v = {
	"ClockTime",
	"GeographicLatitude",
	"Brightness",
	"ExposureCompensation",
	"ShadowSoftness",
	"Ambient",
	"OutdoorAmbient",
	"ColorShift_Top",
	"ColorShift_Bottom",
	"EnvironmentDiffuseScale",
	"EnvironmentSpecularScale",
	"FogColor",
	"FogStart",
	"FogEnd"
}
local v2 = {
	{
		key = "Sky",
		class = "Sky",
		host = Lighting,
		props = {
			"CelestialBodiesShown",
			"SunAngularSize",
			"SunTextureId",
			"MoonAngularSize",
			"MoonTextureId",
			"StarCount",
			"SkyboxUp",
			"SkyboxDn",
			"SkyboxFt",
			"SkyboxBk",
			"SkyboxLf",
			"SkyboxRt"
		}
	},
	{
		key = "Atmosphere",
		class = "Atmosphere",
		host = Lighting,
		props = {
			"Density",
			"Haze",
			"Glare",
			"Offset",
			"Color",
			"Decay"
		}
	},
	{
		key = "Clouds",
		class = "Clouds",
		host = Workspace.Terrain,
		props = {
			"Color",
			"Cover",
			"Density",
			"Enabled"
		}
	},
	{
		key = "SunRays",
		class = "SunRaysEffect",
		host = Lighting,
		props = { "Intensity", "Spread", "Enabled" }
	},
	{
		key = "Bloom",
		class = "BloomEffect",
		host = Lighting,
		props = {
			"Intensity",
			"Threshold",
			"Size",
			"Enabled"
		}
	},
	{
		key = "Blur",
		class = "BlurEffect",
		host = Lighting,
		props = { "Size", "Enabled" }
	},
	{
		key = "DepthOfField",
		class = "DepthOfFieldEffect",
		host = Lighting,
		props = {
			"NearIntensity",
			"FarIntensity",
			"FocusDistance",
			"InFocusRadius",
			"Enabled"
		}
	},
	{
		key = "ColorCorrection",
		class = "ColorCorrectionEffect",
		host = Lighting,
		props = {
			"Saturation",
			"Contrast",
			"Brightness",
			"TintColor",
			"Enabled"
		}
	}
}
local v3 = {
	ClockTime = 24,
	GeographicLatitude = 360
}
local v4 = {
	["Sky.StarCount"] = true
}
local v5 = {
	["Bloom.Size"] = true,
	["Bloom.Threshold"] = true,
	["DepthOfField.FocusDistance"] = true,
	["DepthOfField.InFocusRadius"] = true,
	["SunRays.Spread"] = true
}
local changed = Signal.new()
local presets = {}
local v8 = {}
local v9 = nil
local v10 = nil
local heartbeatConnection = nil

local function locate(data)
	local child = data.host:FindFirstChild(data.key)

	if child and child:IsA(data.class) then
		return child
	end

	return nil
end

local function readProps(p, items)
	local result = {}

	for _, item in items do
		result[item] = p[item]
	end

	return result
end

local function writeProps(p, items, p2)
	for _, item in items do
		local v11 = p2[item]

		if v11 ~= nil and p[item] ~= v11 then
			p[item] = v11
		end
	end
end

local function readScene()
	local host = Lighting
	local result = {}

	for _, v12 in v do
		result[v12] = host[v12]
	end

	for _, v12 in v2 do
		local child = v12.host:FindFirstChild(v12.key)

		if not (child and child:IsA(v12.class)) then
			child = nil
		end

		if not child then
			continue
		end

		local key = v12.key
		local v13 = {}

		for _, v14 in v12.props do
			v13[v14] = child[v14]
		end

		result[key] = v13
	end

	return result
end

local function materialise(data)
	local instance = Instance.new(data.class)
	instance.Name = data.key
	instance.Parent = data.host
	return instance
end

-- equivalent calls inferred from this helper; original call sites unknown
local function retire(p, instance)
	if p.host == Lighting then
		instance:Destroy()
	else
		instance.Enabled = false
	end
end

local function writeScene(p)
	local host = Lighting

	for _, v12 in v do
		local v13 = p[v12]

		if v13 ~= nil and host[v12] ~= v13 then
			host[v12] = v13
		end
	end

	for _, v12 in v2 do
		local v13 = p[v12.key]
		local instance = v12.host:FindFirstChild(v12.key)

		if not (instance and instance:IsA(v12.class)) then
			instance = nil
		end

		if v13 == nil then
			if instance ~= nil then
				retire(v12, instance) -- equivalent call inferred; original call site unknown
			end
		else
			if not instance then
				instance = Instance.new(v12.class)
				instance.Name = v12.key
				instance.Parent = v12.host
			end

			for _, v14 in v12.props do
				local v15 = v13[v14]

				if v15 ~= nil and instance[v14] ~= v15 then
					instance[v14] = v15
				end
			end
		end
	end
end

local function readAuthored(child, p)
	local clone = table.clone(p)

	for k, v11 in child:GetAttributes() do
		if table.find(v, k) == nil then
			continue
		end

		local typeName = typeof(Lighting[k])

		if typeof(v11) ~= typeName then
			error((`{child:GetFullName()} expects a {typeName} in attribute {k}, found {typeof(v11)}`))
		end

		clone[k] = v11
	end

	for _, v11 in v2 do
		local firstChildOfClass = child:FindFirstChildOfClass(v11.class)

		if not firstChildOfClass then
			continue
		end

		local key = v11.key
		local v12 = {}

		for _, v13 in v11.props do
			v12[v13] = firstChildOfClass[v13]
		end

		clone[key] = v12
	end

	return clone
end

-- equivalent calls inferred from this helper; original call sites unknown
local function sameProps(p, p2, items)
	for _, item in items do
		if p[item] ~= p2[item] then
			return false
		end
	end

	return true
end

local function sameLook(p, p2)
	-- equivalent call inferred; original call site unknown
	if not sameProps(p, p2, v) then
		return false
	end

	for _, v11 in v2 do
		local v12 = p[v11.key]
		local v13 = p2[v11.key]

		if v12 == nil ~= (v13 == nil) then
			return false
		end

		if v12 == nil then
			continue
		end

		local flag = true
		local v14

		for _, v15 in v11.props do
			if v12[v15] == v13[v15] then
				continue
			end

			v14 = false
			flag = false
			break
		end

		if flag then
			v14 = true
		end

		if not v14 then
			return false
		end
	end

	return true
end

local function shortestTurn(p: number, p2: number, p3: number, p4: number)
	local v11 = p4 / 2
	return (p + (v11 - (v11 - (p2 - p)) % p4) * p3) % p4
end

local function interpolate(p, p2, p3: number, p4: number?, flag: boolean?)
	if p4 then
		local v11 = p4 / 2
		return (p + (v11 - (v11 - (p2 - p)) % p4) * p3) % p4
	end

	local typeName = typeof(p)

	if typeName == "number" then
		local v11 = p + (p2 - p) * p3

		if flag then
			return (math.floor(v11 + 0.5))
		end

		return v11
	else
		if typeName == "Color3" then
			return p:Lerp(p2, p3)
		end

		if p3 < 0.7 then
			return p
		end

		return p2
	end
end

local function restingValue(p, flag: boolean)
	local typeName = typeof(p)

	if typeName == "number" then
		if flag then
			return p
		end

		return 0
	elseif typeName == "Color3" then
		return color
	else
		return p
	end
end

local function isActive(p)
	return p ~= nil and p.Enabled ~= false
end

local function blendBlock(p, p2, p3, p4: number)
	local v11

	if p2 == nil then
		v11 = false
	else
		v11 = p2.Enabled ~= false
	end

	local v12

	if p3 == nil then
		v12 = false
	else
		v12 = p3.Enabled ~= false
	end

	if not (v11 or v12) then
		return nil
	end

	local result = {}

	for _, v13 in p.props do
		local v14

		if v11 then
			v14 = p2[v13]
		end

		local v15

		if v12 then
			v15 = p3[v13]
		end

		if not (v14 ~= nil or v15 ~= nil) then
			continue
		end

		local formatted = `{p.key}.{v13}`

		if v14 == nil then
			local v16 = v5[formatted] == true
			local typeName = typeof(v15)

			if typeName == "number" then
				if v16 then
					v14 = v15
				else
					v14 = 0
				end
			elseif typeName == "Color3" then
				v14 = color
			else
				v14 = v15
			end
		elseif v15 == nil then
			local v16 = v5[formatted] == true
			local typeName = typeof(v14)

			if typeName == "number" then
				if v16 then
					v15 = v14
				else
					v15 = 0
				end
			elseif typeName == "Color3" then
				v15 = color
			else
				v15 = v14
			end
		end

		local v16 = v4[formatted]
		local typeName = typeof(v14)

		if typeName == "number" then
			v15 = v14 + (v15 - v14) * p4

			if v16 then
				v15 = math.floor(v15 + 0.5)
			end
		elseif typeName == "Color3" then
			v15 = v14:Lerp(v15, p4)
		elseif p4 < 0.7 then
			v15 = v14
		end

		result[v13] = v15
	end

	return result
end

local function blend(origin, target, value: number)
	if value <= 0 then
		return origin
	end

	if value >= 1 then
		return target
	end

	local result = {}

	for _, v11 in v do
		result[v11] = interpolate(origin[v11], target[v11], value, v3[v11])
	end

	for _, v11 in v2 do
		result[v11.key] = blendBlock(v11, origin[v11.key], target[v11.key], value)
	end

	return result
end

local function byRankThenId(p, p2)
	if p.rank == p2.rank then
		return p.id < p2.id
	end

	return p.rank < p2.rank
end

local function resolve()
	local v11 = {}

	for _, v12 in v8 do
		table.insert(v11, v12)
	end

	table.sort(v11, byRankThenId)
	local default = presets.Default

	for _, v12 in v11 do
		if v12.preset then
			default = v12.preset
		else
			default = table.clone(default)

			for k, v13 in v12.patch do
				default[k] = v13
			end
		end
	end

	return default
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopStepping()
	v10 = nil

	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end
end

local function step()
	local v11 = v10

	if v11 == nil then
		stopStepping() -- equivalent call inferred; original call site unknown
	else
		local v12 = (os.clock() - v11.startedAt) / v11.seconds

		if not (v12 >= 1) then
			writeScene(blend(v11.origin, v11.target, TweenService:GetValue(v12, sine, inOut)))
			return
		end

		stopStepping() -- equivalent call inferred; original call site unknown
		writeScene(v11.target)
	end
end

local function easeTo(target, seconds: number)
	if seconds == seconds and not (seconds <= 0) then
		v10 = {
			origin = readScene(),
			target = target,
			startedAt = os.clock(),
			seconds = seconds
		}

		if heartbeatConnection == nil then
			heartbeatConnection = RunService.Heartbeat:Connect(step)
		end
	else
		stopStepping() -- equivalent call inferred; original call site unknown
		writeScene(target)
	end
end

local function refresh(value: number?)
	if Workspace:GetAttribute("Event_AdminAbuse") then
		return
	end

	local target = resolve()

	if sameLook(v9, target) then
		return
	end

	v9 = target
	local seconds = value or 1.5
	easeTo(target, seconds)
	changed:Fire(target, seconds)
end

local LightingController = {
	Presets = presets,
	Changed = changed,
	SetLayer = function(id: string, patch, value: number?, p2: number?)
		local v11 = {
			id = id,
			rank = value or 0
		}

		if type(patch) == "string" then
			local preset = presets[patch]

			if preset == nil then
				error(`unknown lighting preset "{patch}"`, 2)
			end

			v11.preset = preset
		else
			v11.patch = patch
		end

		v8[id] = v11
		refresh(p2)
	end,
	ClearLayer = function(p: string, p2: number?)
		if v8[p] == nil then
			return
		end

		v8[p] = nil
		refresh(p2)
	end,
	Current = function()
		return v9
	end,
	Settle = function()
		if Workspace:GetAttribute("Event_AdminAbuse") then
			return
		end

		stopStepping() -- equivalent call inferred; original call site unknown
		writeScene(v9)
	end,
	Start = function() end
}
local default2 = readScene()
presets.Default = default2

for _, child in script:WaitForChild("Presets"):GetChildren() do
	if presets[child.Name] ~= nil then
		error((`duplicate lighting preset {child:GetFullName()}`))
	end

	presets[child.Name] = readAuthored(child, default2)
end

table.freeze(presets)
v9 = default2
return LightingController