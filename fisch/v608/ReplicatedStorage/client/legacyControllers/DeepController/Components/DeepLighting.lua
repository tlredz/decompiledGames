local ReplicatedStorage = game:GetService("ReplicatedStorage")
local legacyControllers = ReplicatedStorage.client.legacyControllers
local DeepController = require(legacyControllers.DeepController)
local ZoneController = require(legacyControllers.ZoneController)
local LightingController = require(legacyControllers.LightingController)
local Trove = require(ReplicatedStorage.packages.Trove)
local DeepConfig = require(ReplicatedStorage.shared.modules.DeepConfig)
local DeepLighting = {
	ZoneTrove = Trove.new()
}
local v = 0
local flag = false
local count = 0

local function isZonePowered(currentZone)
	local deepSector = currentZone:FindFirstChild("deepSector")

	if deepSector and deepSector:IsA("StringValue") then
		return DeepController:IsSectorActive(deepSector.Value)
	end

	local deepDarkness = currentZone:FindFirstChild("deepDarkness")

	if deepDarkness and deepDarkness:IsA("BoolValue") and deepDarkness.Value then
		return DeepController:HasLightModule()
	end

	return true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isDeepZone(currentZone)
	if currentZone then
		return currentZone:FindFirstChild("deepSector") ~= nil or currentZone:FindFirstChild("deepDarkness") ~= nil
	end

	return false
end

local function applyOverride(p, lightingPropertiesDark)
	for className, v2 in p do
		local firstChildOfClass = lightingPropertiesDark:FindFirstChildOfClass(className)

		if not firstChildOfClass then
			continue
		end

		for k in v2 do
			v2[k] = firstChildOfClass[k]
		end
	end

	for attributeName in p.Lighting do
		local attribute = lightingPropertiesDark:GetAttribute(attributeName)

		if attribute ~= nil then
			p.Lighting[attributeName] = attribute
		end
	end
end

local function applyBlackout(p)
	local v2 = 1 - v
	local atmosphere = p.Atmosphere
	atmosphere.Density += (DeepConfig.BlackoutAtmosphereDensity - atmosphere.Density) * v
	atmosphere.Haze *= v2
	atmosphere.Glare *= v2
	p.Lighting.Brightness *= v2
	p.Lighting.Ambient = p.Lighting.Ambient:Lerp(Color3.new(), v)
	p.Lighting.OutdoorAmbient = p.Lighting.OutdoorAmbient:Lerp(Color3.new(), v)
end

local function runBlackout()
	if flag then
		return
	end

	local currentZone = ZoneController.CurrentZone
	local deepZone = isDeepZone(currentZone) -- equivalent call inferred; original call site unknown

	if not deepZone or currentZone and currentZone:FindFirstChild("deepDarkness") then
		return
	end

	flag = true
	count += 1
	local v2 = count

	for i = 1, DeepConfig.BlackoutFlickerCount do
		v = i % 2 == 1 and 1 or 0.2
		LightingController.UpdateLighting(0)
		task.wait(DeepConfig.BlackoutFlickerInterval)

		if count ~= v2 then
			return
		end
	end

	v = 1
	LightingController.UpdateLighting(0.15)
	task.wait(math.random(DeepConfig.BlackoutMinDuration, DeepConfig.BlackoutMaxDuration))

	if count ~= v2 then
		return
	end

	v = 0
	LightingController.UpdateLighting(1.5)
	flag = false
end

function DeepLighting.Start(_)
	local cycle = ReplicatedStorage:WaitForChild("world"):WaitForChild("cycle")
	local value = cycle.Value
	cycle.Changed:Connect(function(p)
		local v2 = value == "Night"
		value = p

		if v2 and p ~= "Night" then
			task.spawn(runBlackout)
		end
	end)
	local flag2 = false

	local function deferUpdate()
		if flag2 then
			return
		end

		flag2 = true
		task.defer(function()
			flag2 = false
			LightingController.UpdateLighting(1)
		end)
	end

	ZoneController:ObserveZone(function(_, instance)
		DeepLighting.ZoneTrove:Clean()

		if flag then
			flag = false
			v = 0
			count += 1
		end

		if not instance then
			return
		end

		local lightingPropertiesDark = instance:FindFirstChild("lightingPropertiesDark")

		if lightingPropertiesDark then
			DeepLighting.ZoneTrove:Connect(lightingPropertiesDark.AttributeChanged, deferUpdate)

			for className in LightingController.Defaults do
				local firstChildOfClass = lightingPropertiesDark:FindFirstChildOfClass(className)

				if firstChildOfClass then
					DeepLighting.ZoneTrove:Connect(firstChildOfClass.Changed, deferUpdate)
				end
			end
		end
	end)
	DeepController.SectorChanged:Connect(function()
		if workspace:GetAttribute("ClientCutsceneRunning") then
			return
		end

		LightingController.UpdateLighting(2)
	end)
	DeepController.LightModuleChanged:Connect(function()
		LightingController.UpdateLighting(0.35)
	end)
	LightingController.HookLighting:BindAtPriority(3000, function(p)
		local currentZone = ZoneController.CurrentZone

		-- equivalent call inferred; original call site unknown
		if not isDeepZone(currentZone) then
			return p
		end

		debug.profilebegin("DeepLighting")
		local lightingPropertiesDark = not isZonePowered(currentZone) and currentZone:FindFirstChild("lightingPropertiesDark")

		if lightingPropertiesDark then
			applyOverride(p, lightingPropertiesDark)
		end

		if v > 0 then
			applyBlackout(p)
		end

		debug.profileend()
		return p
	end)
end

return DeepLighting