local FireworkConstants = {}
local CollectionService = game:GetService("CollectionService")
local CountableDevProducts = require(script.Parent.Parent.PlayerData.CountableDevProducts)
FireworkConstants.PLACEMENT_FOLDER_NAME = "July_Fireworks"
FireworkConstants.VFX_FOLDER_NAME = "FireworkVFX"
FireworkConstants.PLACED_MODELS_FOLDER_NAME = "FireworkPlacedModels"
FireworkConstants.SESSION_DATA_KEY = "Fireworks"
FireworkConstants.SESSION_PLACED_COUNT_KEY = "PlacedCount"
FireworkConstants.MAX_PLACE_DISTANCE = 35
FireworkConstants.PLACE_DEBOUNCE_SECONDS = 0.25
FireworkConstants.MAX_PLACED_PUBLIC = 10
FireworkConstants.MAX_PLACED_PRIVATE_SERVER = 50
FireworkConstants.LAUNCH_STAGGER_MIN_SECONDS = 0.2
FireworkConstants.LAUNCH_STAGGER_MAX_SECONDS = 0.5
FireworkConstants.LAUNCH_DURATION_MIN_SECONDS = 1.4
FireworkConstants.LAUNCH_DURATION_MAX_SECONDS = 3
FireworkConstants.LAUNCH_STUDS_PER_SECOND = 50
FireworkConstants.FLOOR_SPARKLER_EMIT_DELAY_SECONDS = 0.05
FireworkConstants.FLOOR_SPARKLER_VFX_CLEANUP_SECONDS = 12
FireworkConstants.DEFAULT_PRESET_NAME = "Default"
FireworkConstants.PRESET_RECOLOR_STRENGTH = 1.35
FireworkConstants.PRESET_COLOR_BY_NAME = {
	Red = Color3.fromRGB(255, 60, 60),
	Blue = Color3.fromRGB(60, 120, 255),
	Pink = Color3.fromRGB(255, 180, 200),
	Green = Color3.fromRGB(80, 200, 80),
	Yellow = Color3.fromRGB(255, 230, 60)
}
FireworkConstants.PRESET_SECONDARY_COLOR_BY_NAME = {
	Red = Color3.fromRGB(255, 133, 133),
	Blue = Color3.fromRGB(102, 176, 255),
	Pink = Color3.fromRGB(255, 222, 232),
	Green = Color3.fromRGB(143, 240, 200),
	Yellow = Color3.fromRGB(255, 255, 158)
}
FireworkConstants.ALL_TYPE_NAMES = {
	"Basic",
	"Bobcat",
	"Brookhaven",
	"FloorSparkler",
	"GalaxySpiral",
	"HeartBurst"
}
FireworkConstants.RECOLORABLE_TYPES = {
	Basic = true,
	FloorSparkler = true,
	GalaxySpiral = true,
	HeartBurst = true
}
FireworkConstants.INVENTORY_TYPES = {
	GalaxySpiral = true,
	HeartBurst = true
}
FireworkConstants.OUT_OF_USES_MSG = "Purchase more uses to place more fireworks!"
FireworkConstants.USES_PER_PURCHASE = 10
FireworkConstants.LIVE_OPS_EVENT_KEY = "Fireworks"
FireworkConstants.CONSUMED_KEY_BY_TYPE = {
	GalaxySpiral = "GalaxySpiralConsumed",
	HeartBurst = "HeartBurstConsumed"
}
FireworkConstants.COUNTABLE_PRODUCT_BY_TYPE = {
	GalaxySpiral = CountableDevProducts.JULY_FIREWORK_GALAXY_PACK,
	HeartBurst = CountableDevProducts.JULY_FIREWORK_HEART_PACK
}
FireworkConstants.TOOL_NAME_BY_TYPE = {
	GalaxySpiral = "JulyFireworkGalaxySpiral",
	HeartBurst = "JulyFireworkHeartBurst"
}
FireworkConstants.TELEMETRY_DISPLAY_NAME_BY_TYPE = {
	Basic = "Basic",
	Bobcat = "Bobcat",
	Brookhaven = "BH",
	FloorSparkler = "Floor Sparkler",
	GalaxySpiral = "Galaxy Spiral",
	HeartBurst = "Heart Burst"
}

function FireworkConstants.IsFireworkTypeName(p: string)
	for _, v in FireworkConstants.ALL_TYPE_NAMES do
		if v == p then
			return true
		end
	end

	return false
end

function FireworkConstants.IsFireworkTool(tool)
	if tool:IsA("Tool") then
		return FireworkConstants.GetFireworkTypeFromTool(tool) ~= nil or (CollectionService:HasTag(tool, "FireworkTool") or string.sub(
			tool.Name,
			1,
			12
		) == "JulyFirework")
	end

	return false
end

local v = {
	JulyFireworkBasic = "Basic",
	JulyFireworkBobcat = "Bobcat",
	JulyFireworkBrookhaven = "Brookhaven",
	JulyFireworkFloorSparkler = "FloorSparkler",
	JulyFireworkGalaxySpiral = "GalaxySpiral",
	JulyFireworkHeartBurst = "HeartBurst"
}

function FireworkConstants.GetFireworkTypeFromTool(instance)
	local fireworkType = instance:GetAttribute("FireworkType")

	if typeof(fireworkType) == "string" and FireworkConstants.IsFireworkTypeName(fireworkType) then
		return fireworkType
	end

	local v2 = v[instance.Name]

	if v2 == nil then
		return nil
	end

	return v2
end

function FireworkConstants.CanRecolor(p: string)
	return FireworkConstants.RECOLORABLE_TYPES[p] == true
end

function FireworkConstants.GetPresetColorByName(p: string)
	return FireworkConstants.PRESET_COLOR_BY_NAME[p]
end

function FireworkConstants.GetPresetSecondaryColorByName(p: string)
	return FireworkConstants.PRESET_SECONDARY_COLOR_BY_NAME[p]
end

function FireworkConstants.IsPresetColorName(p: string)
	return FireworkConstants.PRESET_COLOR_BY_NAME[p] ~= nil
end

function FireworkConstants.IsColorPickerButtonName(p: string)
	return p == FireworkConstants.DEFAULT_PRESET_NAME or FireworkConstants.PRESET_COLOR_BY_NAME[p] ~= nil
end

function FireworkConstants.IsDefaultPresetName(p: string)
	return p == FireworkConstants.DEFAULT_PRESET_NAME
end

function FireworkConstants.RequiresInventory(p: string)
	return FireworkConstants.INVENTORY_TYPES[p] == true
end

function FireworkConstants.GetCountableProductForType(p: string)
	return FireworkConstants.COUNTABLE_PRODUCT_BY_TYPE[p]
end

function FireworkConstants.GetInventoryTypeForCountableProductId(p: number)
	for k, v2 in FireworkConstants.COUNTABLE_PRODUCT_BY_TYPE do
		if CountableDevProducts.GetId(v2) == p then
			return k
		end
	end

	return nil
end

function FireworkConstants.GetToolNameForType(p: string)
	return FireworkConstants.TOOL_NAME_BY_TYPE[p]
end

function FireworkConstants.GetTelemetryDisplayName(p: string)
	return FireworkConstants.TELEMETRY_DISPLAY_NAME_BY_TYPE[p]
end

return FireworkConstants