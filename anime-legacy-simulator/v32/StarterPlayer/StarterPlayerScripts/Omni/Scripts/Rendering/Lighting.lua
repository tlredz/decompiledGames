local module = require("@game/ReplicatedStorage/Omni")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local WeatherLighting = require(ReplicatedStorage.Omni.Shared.WeatherLighting)
local assets = ReplicatedStorage:WaitForChild("Assets")
local STARTERLIGHTING = assets:WaitForChild("STARTERLIGHTING")
local weather = assets:WaitForChild("Effects"):WaitForChild("Weather")
local flag = false
local v = nil
local v2 = nil
local v3 = nil
local v4 = nil
local heartbeatConnection = nil
local v5 = {}
local Lighting2 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function StopTransition()
	if not heartbeatConnection then
		return
	end

	heartbeatConnection:Disconnect()
	heartbeatConnection = nil
end

local function CaptureProperties(p, p2, items)
	for k in items do
		p[k] = p2[k]
	end
end

local function CaptureDefaults()
	local v6 = {}
	local v7 = {}

	for _, property in WeatherLighting.Properties do
		v6[property] = true
	end

	for k, instance in WeatherLighting.Instances do
		v7[k] = {}

		for _, v8 in instance do
			v7[k][v8] = true
		end
	end

	local v8 = {}

	for _, v9 in module.Shared.Lighting do
		table.insert(v8, v9)
	end

	for _, v9 in WeatherLighting.List do
		if v9.Lighting then
			table.insert(v8, v9.Lighting)
		end
	end

	for _, v9 in v8 do
		for k in v9.Properties or {} do
			v6[k] = true
		end

		for k, v10 in v9.Instances or {} do
			v7[k] = v7[k] or {}

			for k2 in v10 do
				v7[k][k2] = true
			end
		end
	end

	local v9 = {
		Properties = {},
		Instances = {}
	}
	local properties = v9.Properties
	local v10 = Lighting

	for k in v6 do
		properties[k] = v10[k]
	end

	for childName, v11 in v7 do
		local child = Lighting:FindFirstChild(childName)

		if not child then
			continue
		end

		v9.Instances[childName] = {}
		local instance = v9.Instances[childName]

		for k in v11 do
			instance[k] = child[k]
		end
	end

	return v9
end

local function GetSkyOverride(childName: string)
	local child = weather:FindFirstChild(childName)
	local sky = child and child:FindFirstChildWhichIsA("Sky")

	if not sky then
		return nil
	end

	local result = {}

	for _, v6 in WeatherLighting.Instances.Sky do
		result[v6] = sky[v6]
	end

	return result
end

local function ApplyTarget(p, flag2: boolean, lowMode: boolean)
	StopTransition() -- equivalent call inferred; original call site unknown
	local v6 = {}

	local function Collect(sky, items)
		for k, item in items do
			local from = sky[k]

			if from == item then
				continue
			end

			local v8 = lowMode

			if v8 then
				if sky.Name == "Atmosphere" then
					v8 = k == "Haze" or k == "Glare"
				else
					v8 = false
				end
			end

			local v9 = typeof(item) == "number" or typeof(item) == "Color3"

			if flag2 or v8 or not v9 or sky:IsA("Sky") then
				sky[k] = item
			else
				table.insert(v6, {
					Instance = sky,
					Property = k,
					From = from,
					To = item
				})
			end
		end
	end

	Collect(Lighting, p.Properties)

	for childName, instance in p.Instances do
		local child = Lighting:FindFirstChild(childName)

		if child then
			Collect(child, instance)
		end
	end

	if #v6 == 0 then
		return
	end

	local total = 0
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		total += dt
		local v7 = math.min(total / WeatherLighting.TransitionDuration, 1)
		local value = TweenService:GetValue(v7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

		for _, v8 in v6 do
			if not v8.Instance.Parent then
				continue
			end

			local to

			if v7 == 1 then
				to = v8.To
			elseif v8.Instance == Lighting and v8.Property == "ClockTime" then
				to = WeatherLighting.LerpClock(v8.From, v8.To, value)
			elseif typeof(v8.To) == "Color3" then
				to = v8.From:Lerp(v8.To, value)
			else
				to = v8.From + (v8.To - v8.From) * value
			end

			v8.Instance[v8.Property] = to
		end

		if v7 == 1 then
			StopTransition() -- equivalent call inferred; original call site unknown
		end
	end)
end

function Lighting2.GetCurrentLighting()
	if not module.Data then
		return nil
	end

	local currentMapInfo = module.Utils.PlayerStats.GetCurrentMapInfo(module.Data)
	return currentMapInfo and module.Shared.Lighting[currentMapInfo.Lighting]
end

function Lighting2.RefreshLighting()
	if not (flag and module.Data) then
		return
	end

	local currentLighting = Lighting2.GetCurrentLighting()
	local state = module.Shared.Weather.GetState()
	local v6 = (module.Data.Settings["Hide Weather Effects"] == true or not state) and "Clear" or state.Name
	local lowMode = module.Data.Settings["Low Mode"] == true

	if v2 == currentLighting and v3 == v6 and v4 == lowMode then
		return
	end

	local v7 = v3 == nil or v2 ~= currentLighting
	local v8 = WeatherLighting.Compose(v, currentLighting, v6, lowMode, (GetSkyOverride(v6)))
	v2 = currentLighting
	v3 = v6
	v4 = lowMode
	ApplyTarget(v8, v7, lowMode)
end

function Lighting2.RefreshLowMode()
	Lighting2.RefreshLighting()
end

function Lighting2.SetupLighting()
	Lighting:ClearAllChildren()

	for _, child in STARTERLIGHTING:GetChildren() do
		local clone = child:Clone()
		clone.Parent = Lighting
	end
end

function Lighting2.Destroy()
	flag = false
	StopTransition() -- equivalent call inferred; original call site unknown

	for _, connection in v5 do
		connection:Disconnect()
	end

	table.clear(v5)
	v2 = nil
	v3 = nil
	v4 = nil
end

function Lighting2.Init()
	if flag then
		return
	end

	Lighting2.SetupLighting()
	v = v or CaptureDefaults()
	flag = true
	v5.Weather = ReplicatedStorage:GetAttributeChangedSignal(module.Shared.Weather.AttributeName):Connect(Lighting2.RefreshLighting)
	v5.Maps = module:OnDataChanged({ "Maps" }, Lighting2.RefreshLighting)
	v5.Gamemode = module:OnDataChanged({ "Gamemode" }, Lighting2.RefreshLighting)
	v5.LowMode = module:OnDataChanged({ "Settings", "Low Mode" }, Lighting2.RefreshLowMode)
	v5.Hidden = module:OnDataChanged({ "Settings", "Hide Weather Effects" }, Lighting2.RefreshLighting)
	v5.Destroying = script.Destroying:Connect(Lighting2.Destroy)
	Lighting2.RefreshLighting()
end

return Lighting2