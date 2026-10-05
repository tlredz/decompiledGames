local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.TelemetryController)
local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local NewEstatesSurfacingAbTestController = require(ReplicatedStorage.Modules.Client.Houses.ABTests.NewEstatesSurfacingAbTestController)
local Signal = require(ReplicatedStorage.Packages.Signal)
local v = { "North", "South", "Island" }
local v2 = {
	[37] = "Island",
	[33] = "North",
	[34] = "South"
}
local EstateSurfacingTelemetry = {
	OnPlotTeleported = Signal.new(),
	OnOccupiedEstateTeleported = Signal.new(),
	isActive = function()
		return NewEstatesSurfacingAbTestController.IsSurfacingEnabled()
	end
}

local function getOwnsEstate()
	return GamepassController.IsOwned(Gamepasses.ESTATES_UNLOCKED)
end

function EstateSurfacingTelemetry.buildEstateInfo()
	local HouseViewCamera = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.House.HouseViewCamera)
	local result = {}

	for _, v3 in v do
		local v4 = v3 .. " Estate"
		local estateRegionPlotCamera = HouseViewCamera.ResolveEstateRegionPlotCamera(v3)

		if estateRegionPlotCamera == nil then
			result[v4] = "Occupied"
		else
			local houseOwned = estateRegionPlotCamera:FindFirstChild("HouseOwned")
			result[v4] = houseOwned ~= nil and houseOwned:IsA("BoolValue") and houseOwned.Value == true and "Occupied" or "Open"
		end
	end

	return result
end

function EstateSurfacingTelemetry.sendHouseInventory(houseID: string)
	if not EstateSurfacingTelemetry.isActive() then
		return
	end

	TelemetryController.SendClientInteraction("estateSurfacing", {
		step = "houseInventory",
		houseID = houseID,
		ownsEstate = GamepassController.IsOwned(Gamepasses.ESTATES_UNLOCKED)
	})
end

function EstateSurfacingTelemetry.sendTeleportPrompt(houseID: string, p2: string, flag: boolean?)
	if not (EstateSurfacingTelemetry.isActive() and houseID ~= "") then
		return
	end

	TelemetryController.SendClientInteraction("estateSurfacing", {
		step = "teleportPrompt",
		houseID = houseID,
		ownsEstate = GamepassController.IsOwned(Gamepasses.ESTATES_UNLOCKED),
		action = p2 .. " Estate",
		estateInfo = EstateSurfacingTelemetry.buildEstateInfo()
	})

	if flag == false then
		EstateSurfacingTelemetry.OnOccupiedEstateTeleported:Fire()
	else
		EstateSurfacingTelemetry.OnPlotTeleported:Fire()
	end
end

function EstateSurfacingTelemetry.sendClaimPlot(houseID: string, p2: number)
	if not (EstateSurfacingTelemetry.isActive() and houseID ~= "") then
		return false
	end

	local v3 = v2[p2]

	if v3 == nil then
		return false
	end

	TelemetryController.SendClientInteraction("estateSurfacing", {
		step = "claimPlot",
		houseID = houseID,
		ownsEstate = GamepassController.IsOwned(Gamepasses.ESTATES_UNLOCKED),
		action = v3 .. " Estate",
		estateInfo = EstateSurfacingTelemetry.buildEstateInfo()
	})
	return true
end

function EstateSurfacingTelemetry.getEstateRegionFromCamera(folder)
	for _, stringValue in folder:GetDescendants() do
		if not (stringValue:IsA("StringValue") and string.sub(stringValue.Value, 1, 7) == "House# ") then
			continue
		end

		local v3 = tonumber((string.sub(stringValue.Value, 8)))

		if v3 ~= nil then
			return v2[v3]
		end
	end

	for _, stringValue in folder:GetChildren() do
		if not (stringValue:IsA("StringValue") and string.sub(stringValue.Value, 1, 7) == "House# ") then
			continue
		end

		local v3 = tonumber((string.sub(stringValue.Value, 8)))

		if v3 ~= nil then
			return v2[v3]
		end
	end

	return nil
end

function EstateSurfacingTelemetry.getPendingHouseIdFromAttribute(instance)
	local pendingEstateName = instance:GetAttribute("PendingEstateName")

	if typeof(pendingEstateName) == "string" then
		return pendingEstateName
	end

	return ""
end

return EstateSurfacingTelemetry