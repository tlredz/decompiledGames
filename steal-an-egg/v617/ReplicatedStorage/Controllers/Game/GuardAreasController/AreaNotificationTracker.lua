local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Areas = require(ReplicatedStorage.Data.Areas)
local t = require(ReplicatedStorage.Packages.t)
local GuardAreaGeometry = require(ReplicatedStorage.Shared.Util.GuardAreaGeometry)
local LightingController = require(ReplicatedStorage.Controllers.Game.LightingController)
local Player = require(ReplicatedStorage.Shared.Player)
local Sakura = require(ReplicatedStorage.Data.Sakura)
local SakuraBloomPolicy = require(ReplicatedStorage.Client.Modules.SakuraBloomPolicy)
local Save = require(ReplicatedStorage.Shared.Save)
local v = {
	["Cherry Blossom"] = true,
	[Sakura.AreaDisplay.AreaId] = true
}
local localPlayer = Players.LocalPlayer
local world = Workspace:WaitForChild("World")
assert(world:IsA("Folder"), "Workspace.World must be a Folder")
local areas = world.Areas
assert(areas:IsA("Folder"), "Workspace.World.Areas must be a Folder")
local separationLine = areas.SeparationLine
assert(separationLine:IsA("BasePart"), "Workspace.World.Areas.SeparationLine must be a BasePart")
local guardAreas = areas.GuardAreas
assert(guardAreas:IsA("Folder"), "Workspace.World.Areas.GuardAreas must be a Folder")
local build = world:WaitForChild("Build")
local cherryBlossom = areas:WaitForChild("CherryBlossom")
assert(cherryBlossom:IsA("Folder"), "Workspace.World.Areas.CherryBlossom must be a Folder")
local v2 = {}
local areaId = nil
local v3 = nil
local v4 = nil

local function rebuildAreaEntries(_)
	table.clear(v2)

	for _, v5 in ipairs(GuardAreaGeometry.ReadAreaBounds(guardAreas)) do
		v2[#v2 + 1] = {
			AreaId = v5.AreaId,
			Bounds = v5.Bounds,
			Config = Areas.Directory[v5.AreaId]
		}
	end

	local bounds = cherryBlossom:FindFirstChild("Bounds")

	if bounds and bounds:IsA("BasePart") then
		v2[#v2 + 1] = {
			AreaId = Sakura.AreaDisplay.AreaId,
			Bounds = bounds,
			Config = Sakura.AreaDisplay
		}
	end

	table.sort(v2, function(a, b)
		local rank = a.Config.Rarity.Rank
		local rank2 = b.Config.Rarity.Rank

		if rank == rank2 then
			return a.AreaId < b.AreaId
		end

		return rank < rank2
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isEntryAvailable(p)
	if p.Bounds.Parent and p.Bounds.Parent:GetAttribute("ZoneHidden") == true then
		return false
	end

	return not v[p.AreaId] or build:FindFirstChild("CherryBlossomZone") ~= nil
end

local function resolveCurrentArea(position: Vector3)
	t.strict(t.Vector3)(position)

	for _, v5 in ipairs(v2) do
		local entryAvailable = isEntryAvailable(v5) -- equivalent call inferred; original call site unknown

		if entryAvailable and GuardAreaGeometry.IsWithinFootprint(v5.Bounds, position) then
			return v5
		end
	end

	return nil
end

local function isBloomUnlocked()
	local isLoaded = Save.IsLoaded()
	local v5

	if isLoaded then
		v5 = Save.Peek()
	end

	return SakuraBloomPolicy.HasBloomUnlocked(isLoaded, v5)
end

local function updateZoneLighting(p, p2)
	if p2 and v[p2] then
		if Workspace:GetAttribute("Event_GreatBloom") then
			local isLoaded = Save.IsLoaded()
			local v5

			if isLoaded then
				v5 = Save.Peek()
			end

			if not SakuraBloomPolicy.HasBloomUnlocked(isLoaded, v5) then
				p = nil
			end
		else
			p = nil
		end
	end

	local lighting

	if p then
		lighting = p.Lighting
	end

	if lighting == v4 then
		return
	end

	v4 = lighting

	if lighting == nil then
		LightingController.ClearLayer("ZoneLighting", 2)
	else
		LightingController.SetLayer("ZoneLighting", lighting, 25, 2)
	end
end

local function step(callback)
	local part = Player.FindRootPart(localPlayer)

	if part == nil then
		areaId = nil
		updateZoneLighting(nil)
	else
		assert(part:IsA("BasePart"), (`{part:GetFullName()} must be a BasePart`))

		if GuardAreaGeometry.IsPastLine(separationLine, part.Position) then
			local currentArea = resolveCurrentArea(part.Position)

			if currentArea == nil then
				areaId = nil
				updateZoneLighting(nil)
			else
				Players.LocalPlayer:SetAttribute("AreaId", currentArea.AreaId)
				updateZoneLighting(currentArea.Config, currentArea.AreaId)

				if currentArea.AreaId == areaId then
					return
				end

				areaId = currentArea.AreaId
				local rank = currentArea.Config.Rarity.Rank
				local v5 = v3
				v3 = rank

				if v5 ~= nil and rank <= v5 then
					return
				end

				callback(currentArea.Config, currentArea.AreaId)
			end
		else
			areaId = nil
			v3 = nil
			updateZoneLighting(nil)
		end
	end
end

return {
	Start = function(callback)
		t.strict(t.callback)(callback)
		rebuildAreaEntries(nil)
		guardAreas.ChildAdded:Connect(rebuildAreaEntries)
		guardAreas.ChildRemoved:Connect(rebuildAreaEntries)
		local total = 0
		RunService.Heartbeat:Connect(function(dt: number)
			total += dt

			if total < 0.1 then
				return
			end

			total = 0
			step(callback)
		end)
	end
}