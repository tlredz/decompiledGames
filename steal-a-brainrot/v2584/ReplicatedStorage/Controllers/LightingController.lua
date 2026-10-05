local Lighting = game:GetService("Lighting")
local v = {
	"Ambient",
	"OutdoorAmbient",
	"Brightness",
	"ExposureCompensation",
	"EnvironmentDiffuseScale",
	"EnvironmentSpecularScale",
	"GlobalShadows",
	"FogColor",
	"FogStart",
	"FogEnd"
}
local v2 = {}
local LightingController = {}

for _, v3 in v do
	v2[v3] = {}
end

local v3 = {}
local v4 = {}
local v5 = {}
local v6 = {}
local v7 = false
local v8 = {}
local v9 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function ensureCaptured(p: string)
	if not v4[p] then
		v3[p] = Lighting[p]
		v4[p] = true
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setLightingProp(p: string, p2)
	local v10 = Lighting

	if v10[p] == p2 then
		return
	end

	v9[p] = true
	v10[p] = p2
	v9[p] = false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyTop(p: string)
	if v7 then
		if v4[p] then
			setLightingProp(p, v3[p]) -- equivalent call inferred; original call site unknown
		end
	else
		local v10 = v2[p]
		local v11 = v10[#v10]

		if v11 then
			setLightingProp(p, v11.value) -- equivalent call inferred; original call site unknown
		elseif v4[p] then
			setLightingProp(p, v3[p]) -- equivalent call inferred; original call site unknown
			v3[p] = nil
			v4[p] = false
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function attachDriftConn(propertyName: string)
	if v8[propertyName] then
		return
	end

	v8[propertyName] = Lighting:GetPropertyChangedSignal(propertyName):Connect(function()
		if v9[propertyName] or v7 then
			return
		end

		local v10 = v2[propertyName]
		local v11 = v10[#v10]

		if not v11 then
			return
		end

		local v12 = Lighting

		if v12[propertyName] ~= v11.value then
			v9[propertyName] = true
			v12[propertyName] = v11.value
			v9[propertyName] = false
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function detachDriftConn(prop: string)
	local connection = v8[prop]

	if not connection then
		return
	end

	connection:Disconnect()
	v8[prop] = nil
end

local function insertSorted(list, p)
	for i = #list, 1, -1 do
		if not (list[i].priority <= p.priority) then
			continue
		end

		table.insert(list, i + 1, p)
		return
	end

	table.insert(list, 1, p)
end

function LightingController.Push(_, context: string, p2)
	local priority = p2.Priority or 0
	local v10 = {}

	for _, prop in v do
		local v12 = p2[prop]

		if v12 == nil then
			continue
		end

		ensureCaptured(prop) -- equivalent call inferred; original call site unknown
		local entry = {
			context = context,
			value = v12,
			priority = priority
		}
		insertSorted(v2[prop], entry)
		table.insert(v10, {
			prop = prop,
			entry = entry
		})
		v5[prop] = true
		attachDriftConn(prop)
		applyTop(prop) -- equivalent call inferred; original call site unknown
	end

	local colorCorrectionEffect

	if p2.ColorCorrection then
		local colorCorrection = p2.ColorCorrection
		colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
		colorCorrectionEffect.Name = `LightingController_{context}`

		if colorCorrection.TintColor ~= nil then
			colorCorrectionEffect.TintColor = colorCorrection.TintColor
		end

		if colorCorrection.Brightness ~= nil then
			colorCorrectionEffect.Brightness = colorCorrection.Brightness
		end

		if colorCorrection.Saturation ~= nil then
			colorCorrectionEffect.Saturation = colorCorrection.Saturation
		end

		if colorCorrection.Contrast ~= nil then
			colorCorrectionEffect.Contrast = colorCorrection.Contrast
		end

		if v7 then
			colorCorrectionEffect.Enabled = false
		end

		colorCorrectionEffect.Parent = workspace.CurrentCamera or Lighting
		v6[colorCorrectionEffect] = true
	else
		colorCorrectionEffect = nil
	end

	local flag = false
	return function()
		if flag then
			return
		end

		flag = true

		for _, v11 in v10 do
			local v12 = v2[v11.prop]
			local index = table.find(v12, v11.entry)

			if index then
				table.remove(v12, index)
			end

			if #v12 == 0 then
				v5[v11.prop] = nil
				detachDriftConn(v11.prop) -- equivalent call inferred; original call site unknown
			end

			applyTop(v11.prop) -- equivalent call inferred; original call site unknown
		end

		if colorCorrectionEffect then
			v6[colorCorrectionEffect] = nil
			colorCorrectionEffect:Destroy()
		end
	end
end

function LightingController.SetSuspended(_, flag: boolean)
	if v7 == flag then
		return
	end

	v7 = flag

	if v7 then
		for k in v5 do
			if not v4[k] then
				continue
			end

			setLightingProp(k, v3[k]) -- equivalent call inferred; original call site unknown
		end

		for k in v6 do
			k.Enabled = false
		end
	else
		for k in v5 do
			applyTop(k) -- equivalent call inferred; original call site unknown
		end

		for k in v6 do
			k.Enabled = true
		end
	end
end

function LightingController.IsSuspended(_)
	return v7
end

return LightingController