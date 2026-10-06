local Janitor = require(script.Parent.Janitor)
local Enum2 = require(script.Parent.Enum)
require(script.Parent.Signal)
local Tracker = require(script.Tracker)
local CollectiveWorldModel = require(script.CollectiveWorldModel)
local enums = Enum2.enums
local Players = game:GetService("Players")
local v = {}
local total = 0
local v2 = {}
local v3 = {}
local zoneParts = {}
local v4 = {}
local zoneParts2 = {}
local v5 = {}
local v6 = 0
local RunService = game:GetService("RunService")
local heartbeat = RunService.Heartbeat
local v7 = {}
local localPlayer = RunService:IsClient() and Players.LocalPlayer
local ZoneController = {}
local trackers = {
	player = Tracker.new("player"),
	item = Tracker.new("item")
}
ZoneController.trackers = trackers

local function dictLength(items)
	local count = 0

	for _, _ in pairs(items) do
		count += 1
	end

	return count
end

-- equivalent calls inferred from this helper; original call sites unknown
local function fillOccupants(p, p2, player)
	local charactersByPlayer = p[p2]

	if not charactersByPlayer then
		charactersByPlayer = {}
		p[p2] = charactersByPlayer
	end

	charactersByPlayer[player] = player:IsA("Player") and player.Character or true
end

local v9 = {
	player = function(p)
		return ZoneController._getZonesAndItems("player", v, total, true, p)
	end,
	localPlayer = function(p)
		local v10 = {}
		local character = localPlayer.Character

		if not character then
			return v10
		end

		local touchingZones = ZoneController.getTouchingZones(character, true, p, trackers.player)

		for _, touchingZone in pairs(touchingZones) do
			if not touchingZone.activeTriggers.localPlayer then
				continue
			end

			fillOccupants(v10, touchingZone, localPlayer) -- equivalent call inferred; original call site unknown
		end

		return v10
	end,
	item = function(p)
		return ZoneController._getZonesAndItems("item", v, total, true, p)
	end
}

function ZoneController:_registerZone()
	v3[self] = true
	local registeredJanitor = self.janitor:add(Janitor.new(), "destroy")
	self._registeredJanitor = registeredJanitor
	registeredJanitor:add(self.updated:Connect(function()
		ZoneController._updateZoneDetails()
	end), "Disconnect")
	ZoneController._updateZoneDetails()
end

function ZoneController:_deregisterZone()
	v3[self] = nil
	self._registeredJanitor:destroy()
	self._registeredJanitor = nil
	ZoneController._updateZoneDetails()
end

function ZoneController._registerConnection(object, p)
	local activeTriggers = object.activeTriggers
	local count = 0

	for _, _ in pairs(activeTriggers) do
		count += 1
	end

	v6 += 1

	if count == 0 then
		v[object] = true
		ZoneController._updateZoneDetails()
	end

	local v10 = v2[p]
	v2[p] = v10 and v10 + 1 or 1
	object.activeTriggers[p] = true

	if object.touchedConnectionActions[p] then
		object:_formTouchedConnection(p)
	end

	if v9[p] then
		ZoneController._formHeartbeat(p)
	end
end

function ZoneController:updateDetection()
	for k, v10 in pairs({
		enterDetection = "_currentEnterDetection",
		exitDetection = "_currentExitDetection"
	}) do
		local centre = self[k]
		local combinedTotalVolumes = Tracker.getCombinedTotalVolumes()

		if centre == enums.Detection.Automatic then
			if combinedTotalVolumes > 729000 then
				centre = enums.Detection.Centre
			else
				centre = enums.Detection.WholeBody
			end
		end

		self[v10] = centre
	end
end

function ZoneController._formHeartbeat(p)
	if v7[p] then
		return
	end

	local v10 = 0
	v7[p] = heartbeat:Connect(function()
		local now = os.clock()

		if v10 <= now then
			local v11 = nil
			local v12 = nil

			for k, _ in pairs(v) do
				if not k.activeTriggers[p] then
					continue
				end

				local accuracy = k.accuracy

				if v11 == nil or accuracy < v11 then
					v11 = accuracy
				end

				ZoneController.updateDetection(k)
				local _currentEnterDetection = k._currentEnterDetection

				if v12 == nil or _currentEnterDetection < v12 then
					v12 = _currentEnterDetection
				end
			end

			local v13 = v9[p](v12)
			local v14 = {}
			local v15 = {}

			for k, v16 in pairs(v13) do
				local v17 = k.settingsGroupName and ZoneController.getGroup(k.settingsGroupName)

				if not (v17 and v17.onlyEnterOnceExitedAll == true) then
					continue
				end

				for k2, _ in pairs(v16) do
					local v18 = v14[k.settingsGroupName]

					if not v18 then
						v18 = {}
						v14[k.settingsGroupName] = v18
					end

					v18[k2] = k
				end

				v15[k] = v16
			end

			for k, v16 in pairs(v15) do
				local v17 = v14[k.settingsGroupName]

				if not v17 then
					continue
				end

				for k2, _ in pairs(v16) do
					local v18 = v17[k2]

					if v18 and v18 ~= k then
						v16[k2] = nil
					end
				end
			end

			local v16 = {
				{},
				{}
			}

			for k, _ in pairs(v) do
				if not k.activeTriggers[p] then
					continue
				end

				local accuracy = k.accuracy
				local v17 = v13[k] or {}
				local flag = false

				for _, _ in pairs(v17) do
					flag = true
					break
				end

				if flag and v11 < accuracy then
					v11 = accuracy
				end

				local _updateOccupants = k:_updateOccupants(p, v17)
				v16[1][k] = _updateOccupants.exited
				v16[2][k] = _updateOccupants.entered
			end

			local v17 = { "Exited", "Entered" }

			for k, v18 in pairs(v16) do
				local v20 = p .. v17[k]

				for k2, v21 in pairs(v18) do
					local v22 = k2[v20]

					if not v22 then
						continue
					end

					for _, v23 in pairs(v21) do
						v22:Fire(v23)
					end
				end
			end

			v10 = now + enums.Accuracy.getProperty(v11)
		end
	end)
end

function ZoneController._deregisterConnection(object, p)
	v6 -= 1

	if v2[p] == 1 then
		v2[p] = nil
		local connection = v7[p]

		if connection then
			v7[p] = nil
			connection:Disconnect()
		end
	else
		v2[p] -= 1
	end

	object.activeTriggers[p] = nil
	local activeTriggers = object.activeTriggers
	local count = 0

	for _, _ in pairs(activeTriggers) do
		count += 1
	end

	if count == 0 then
		v[object] = nil
		ZoneController._updateZoneDetails()
	end

	if object.touchedConnectionActions[p] then
		object:_disconnectTouchedConnection(p)
	end
end

function ZoneController._updateZoneDetails()
	zoneParts = {}
	v4 = {}
	zoneParts2 = {}
	v5 = {}
	total = 0

	for k, _ in pairs(v3) do
		local v10 = v[k]

		if v10 then
			total += k.volume
		end

		for _, zonePart in pairs(k.zoneParts) do
			if v10 then
				table.insert(zoneParts, zonePart)
				v4[zonePart] = k
			end

			table.insert(zoneParts2, zonePart)
			v5[zonePart] = k
		end
	end
end

function ZoneController._getZonesAndItems(p, items, total2, p2, p3)
	if not total2 then
		for k, _ in pairs(items) do
			total2 += k.volume
		end
	end

	local v10 = {}
	local v11 = trackers[p]

	if v11.totalVolume < total2 then
		for _, character in pairs(v11.items) do
			local touchingZones = ZoneController.getTouchingZones(character, p2, p3, v11)

			for _, touchingZone in pairs(touchingZones) do
				if not (not p2 or touchingZone.activeTriggers[p]) then
					continue
				end

				local playerFromCharacter

				if p == "player" then
					playerFromCharacter = Players:GetPlayerFromCharacter(character)
				else
					playerFromCharacter = character
				end

				if not playerFromCharacter then
					continue
				end

				fillOccupants(v10, touchingZone, playerFromCharacter) -- equivalent call inferred; original call site unknown
			end
		end
	else
		for k, _ in pairs(items) do
			if not (not p2 or k.activeTriggers[p]) then
				continue
			end

			local partBoundsInBox = CollectiveWorldModel:GetPartBoundsInBox(
				k.region.CFrame,
				k.region.Size,
				v11.whitelistParams
			)
			local v12 = {}

			for _, v13 in pairs(partBoundsInBox) do
				local v14 = v11.partToItem[v13]

				if not v12[v14] then
					v12[v14] = true
				end
			end

			for character, _ in pairs(v12) do
				if p == "player" then
					local playerFromCharacter = Players:GetPlayerFromCharacter(character)

					if k:findPlayer(playerFromCharacter) then
						fillOccupants(v10, k, playerFromCharacter) -- equivalent call inferred; original call site unknown
					end
				elseif k:findItem(character) then
					fillOccupants(v10, k, character) -- equivalent call inferred; original call site unknown
				end
			end
		end
	end

	return v10
end

function ZoneController.getZones()
	local result = {}

	for k, _ in pairs(v3) do
		table.insert(result, k)
	end

	return result
end

function ZoneController.getTouchingZones(part, p, p2, p3)
	local v10

	if p3 then
		v10 = p3.exitDetections[part]
		p3.exitDetections[part] = nil
	end

	local v11 = v10 or p2
	local size = nil
	local cFrame = nil
	local isA = part:IsA("BasePart")
	local v12 = not isA
	local children = {}

	if isA then
		size = part.Size
		cFrame = part.CFrame
		table.insert(children, part)
	elseif v11 == enums.Detection.WholeBody then
		size, cFrame = Tracker.getCharacterSize(part)
		children = part:GetChildren()
	else
		local humanoidRootPart = part:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			size = humanoidRootPart.Size
			cFrame = humanoidRootPart.CFrame
			table.insert(children, humanoidRootPart)
		end
	end

	if not (size and cFrame) then
		return {}
	end

	local filterDescendantsInstances = p and zoneParts or zoneParts2
	local v14 = p and v4 or v5
	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Whitelist
	overlapParams.MaxParts = #filterDescendantsInstances
	overlapParams.FilterDescendantsInstances = filterDescendantsInstances
	local partBoundsInBox = CollectiveWorldModel:GetPartBoundsInBox(cFrame, size, overlapParams)
	local v15 = {}
	local result = {}
	local filterDescendantsInstances2 = {}

	for _, v17 in pairs(partBoundsInBox) do
		local v18 = v14[v17]

		if v18 and v18.allZonePartsAreBlocks then
			v15[v18] = true
			result[v17] = v18
		else
			table.insert(filterDescendantsInstances2, v17)
		end
	end

	local count = #filterDescendantsInstances2
	local count2 = 0

	if count > 0 then
		local overlapParams2 = OverlapParams.new()
		overlapParams2.FilterType = Enum.RaycastFilterType.Whitelist
		overlapParams2.MaxParts = count
		overlapParams2.FilterDescendantsInstances = filterDescendantsInstances2

		for _, part2 in pairs(children) do
			local flag = false

			if not part2:IsA("BasePart") or v12 and Tracker.bodyPartsToIgnore[part2.Name] then
				continue
			end

			local partsInPart = CollectiveWorldModel:GetPartsInPart(part2, overlapParams2)

			for _, v19 in pairs(partsInPart) do
				if result[v19] then
					continue
				end

				local v20 = v14[v19]

				if v20 then
					v15[v20] = true
					result[v19] = v20
					count2 += 1
				end

				if count2 ~= count then
					continue
				end

				flag = true
				break
			end

			if flag then
				break
			end
		end
	end

	local _currentExitDetection = nil
	local result2 = {}

	for k, _ in pairs(v15) do
		if _currentExitDetection == nil or k._currentExitDetection < _currentExitDetection then
			_currentExitDetection = k._currentExitDetection
		end

		table.insert(result2, k)
	end

	if _currentExitDetection and p3 then
		p3.exitDetections[part] = _currentExitDetection
	end

	return result2, result
end

local v10 = {}

function ZoneController.setGroup(name, items)
	local result = v10[name]

	if not result then
		result = {}
		v10[name] = result
	end

	result.onlyEnterOnceExitedAll = true
	result._name = name
	result._memberZones = {}

	if typeof(items) == "table" then
		for k, item in pairs(items) do
			result[k] = item
		end
	end

	return result
end

function ZoneController.getGroup(p)
	return v10[p]
end

local v11 = nil
local name2 = string.format("ZonePlus%sContainer", RunService:IsClient() and "Client" or "Server")

function ZoneController.getWorkspaceContainer()
	local v13 = v11 or workspace:FindFirstChild(name2)

	if v13 then
		return v13
	end

	v13 = Instance.new("Folder")
	v13.Name = name2
	v13.Parent = workspace
	v11 = v13
	return v13
end

return ZoneController