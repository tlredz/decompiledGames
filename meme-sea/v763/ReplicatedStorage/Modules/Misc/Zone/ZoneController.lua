local createVector = vector.create
local ZoneController = {}
local Maid = require(script.Parent.Maid)
local RotatedRegion3 = require(script.Parent.RotatedRegion3)
local Enum2 = require(script.Parent.Enum)
local enums = Enum2.enums
local Players = game:GetService("Players")
local v = {}
local total = 0
local total2 = 0
local v2 = {}
local v3 = {}
local groupParts = {}
local v4 = {}
local groupParts2 = {}
local v5 = {}
local parts = {}
local v6 = 0
local RunService = game:GetService("RunService")
local heartbeat = RunService.Heartbeat
local v7 = {}
local localPlayer = RunService:IsClient() and Players.LocalPlayer
local v8 = {}

local function dictLength(items)
	local count = 0

	for _, _ in pairs(items) do
		count += 1
	end

	return count
end

local function fillOccupants(p, p2, player)
	local charactersByPlayer = p[p2]

	if not charactersByPlayer then
		charactersByPlayer = {}
		p[p2] = charactersByPlayer
	end

	charactersByPlayer[player] = player.Character or true
end

local v9 = {
	player = function(p)
		return ZoneController._getZonesAndPlayers(v, total, true, p)
	end,
	localPlayer = function(p)
		local touchingZones = ZoneController.getTouchingZones(localPlayer, true, p)
		local result = {}

		for _, touchingZone in pairs(touchingZones) do
			if not touchingZone.activeTriggers.localPlayer then
				continue
			end

			local v10 = localPlayer
			local characters = result[touchingZone]

			if not characters then
				characters = {}
				result[touchingZone] = characters
			end

			characters[v10] = v10.Character or true
		end

		return result
	end
}

local function preventMultiFrameUpdates(callback)
	local v10 = 0
	local flag = false
	return function(...)
		v10 += 1

		if flag then
			return
		end

		local v11 = table.pack(...)
		coroutine.wrap(function()
			heartbeat:Wait()
			flag = false

			if v10 > 1 then
				v10 = 1
				return callback(unpack(v11))
			else
				v10 = 0
			end
		end)()
		flag = true
		return callback(...)
	end
end

local fn

local function fn2()
	total2 = 0
	parts = {}
	local v10 = {
		UpperTorso = true,
		LowerTorso = true,
		Torso = true,
		LeftHand = true,
		RightHand = true,
		LeftFoot = true,
		RightFoot = true
	}

	for _, v11 in ipairs(Players:GetPlayers()) do
		local characterRegion = ZoneController.getCharacterRegion(v11)

		if not characterRegion then
			continue
		end

		local size = characterRegion.Size
		local v12 = size.X * size.Y * size.Z
		total2 += v12

		for _, part in ipairs(v11.Character:GetChildren()) do
			if not part:IsA("BasePart") or v10[part.Name] then
				continue
			end

			table.insert(parts, part)
			local parentChangedConnection = nil
			local v13 = part
			parentChangedConnection = part:GetPropertyChangedSignal("Parent"):Connect(function()
				if v13.Parent == nil then
					parentChangedConnection:Disconnect()
					fn()
				end
			end)
		end
	end
end

local v10 = 0
local flag = false

fn = function(...)
	v10 += 1

	if flag then
		return
	end

	local v11 = table.pack(...)
	coroutine.wrap(function()
		heartbeat:Wait()
		flag = false

		if v10 > 1 then
			v10 = 1
			return fn2(unpack(v11))
		else
			v10 = 0
		end
	end)()
	flag = true
	return fn2(...)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playerAdded(p)
	p.CharacterAdded:Connect(function(character)
		character:SetAttribute("SpawnTime", os.time())
		local humanoid = character:WaitForChild("Humanoid", 3)

		if humanoid then
			fn()

			for _, numberValue in ipairs(humanoid:GetChildren()) do
				if numberValue:IsA("NumberValue") then
					numberValue.Changed:Connect(function()
						fn()
					end)
				end
			end
		end
	end)
end

Players.PlayerAdded:Connect(playerAdded)

for _, v11 in ipairs(Players:GetPlayers()) do
	playerAdded(v11) -- equivalent call inferred; original call site unknown
end

Players.PlayerRemoving:Connect(function(player)
	fn()
	v8[player] = nil
end)

function ZoneController:_registerZone()
	v3[self] = true
	local registeredMaid = self._maid:give(Maid.new())
	self._registeredMaid = registeredMaid
	registeredMaid:give(self.updated:Connect(function()
		ZoneController._updateZoneDetails()
	end))
	ZoneController._updateZoneDetails()
end

function ZoneController:_deregisterZone()
	v3[self] = nil
	self._registeredMaid:clean()
	self._registeredMaid = nil
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

	local v11 = v2[p]
	v2[p] = v11 and v11 + 1 or 1
	object.activeTriggers[p] = true

	if object.touchedConnectionActions[p] then
		object:_formTouchedConnection(p)
	end

	if v9[p] then
		ZoneController._formHeartbeat(p)
	end
end

function ZoneController:updateDetection()
	for k, v11 in pairs({
		enterDetection = "_currentEnterDetection",
		exitDetection = "_currentExitDetection"
	}) do
		local centre = self[k]

		if centre == enums.Detection.Automatic then
			if total2 > 729000 then
				centre = enums.Detection.Centre
			else
				centre = enums.Detection.WholeBody
			end
		end

		self[v11] = centre
	end
end

function ZoneController._formHeartbeat(p)
	if v7[p] then
		return
	end

	local v11 = 0
	v7[p] = heartbeat:Connect(function()
		local now = os.clock()

		if v11 <= now then
			local v12 = nil
			local v13 = nil

			for k, _ in pairs(v) do
				if not k.activeTriggers[p] then
					continue
				end

				local accuracy = k.accuracy

				if v12 == nil or accuracy < v12 then
					v12 = accuracy
				end

				ZoneController.updateDetection(k)
				local _currentEnterDetection = k._currentEnterDetection

				if v13 == nil or _currentEnterDetection < v13 then
					v13 = _currentEnterDetection
				end
			end

			local v14 = v9[p](v13)

			for k, _ in pairs(v) do
				if not k.activeTriggers[p] then
					continue
				end

				local accuracy = k.accuracy
				local v15 = v14[k] or {}
				local flag2 = false

				for _, _ in pairs(v15) do
					flag2 = true
					break
				end

				if flag2 and v12 < accuracy then
					v12 = accuracy
				end

				k:_updateOccupants(p, v15)
			end

			v11 = now + enums.Accuracy.getProperty(v12)
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
	groupParts = {}
	v4 = {}
	groupParts2 = {}
	v5 = {}
	total = 0

	for k, _ in pairs(v3) do
		local v11 = v[k]

		if v11 then
			total += k.volume
		end

		for _, groupPart in pairs(k.groupParts) do
			if v11 then
				table.insert(groupParts, groupPart)
				v4[groupPart] = k
			end

			table.insert(groupParts2, groupPart)
			v5[groupPart] = k
		end
	end
end

function ZoneController._getZonesAndPlayers(items, total3, p, p2)
	if not total3 then
		for k, _ in pairs(items) do
			total3 += k.volume
		end
	end

	local result = {}

	if total2 < total3 then
		for _, v11 in pairs(Players:GetPlayers()) do
			local touchingZones = ZoneController.getTouchingZones(v11, p, p2)

			for _, touchingZone in pairs(touchingZones) do
				if not (not p or touchingZone.activeTriggers.player) then
					continue
				end

				local characters = result[touchingZone]

				if not characters then
					characters = {}
					result[touchingZone] = characters
				end

				characters[v11] = v11.Character or true
			end
		end
	else
		for k, _ in pairs(items) do
			if not (not p or k.activeTriggers.player) then
				continue
			end

			local partsInRegion3 = workspace:FindPartsInRegion3WithWhiteList(k.region, parts, #parts)
			local playerFromCharactersByName = {}

			for _, v11 in pairs(partsInRegion3) do
				local name = v11.Parent.Name

				if not playerFromCharactersByName[name] then
					playerFromCharactersByName[name] = Players:GetPlayerFromCharacter(v11.Parent)
				end
			end

			for _, v11 in pairs(playerFromCharactersByName) do
				if not (v11 and k:findPlayer(v11)) then
					continue
				end

				local characters = result[k]

				if not characters then
					characters = {}
					result[k] = characters
				end

				characters[v11] = v11.Character or true
			end
		end
	end

	return result
end

function ZoneController.getZones()
	local result = {}

	for k, _ in pairs(v3) do
		table.insert(result, k)
	end

	return result
end

function ZoneController.getCharacterRegion(player)
	local character = player.Character
	local head = character and character:FindFirstChild("Head")
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and head) then
		return nil
	end

	local Y = head.Size.Y
	local size = humanoidRootPart.Size
	local v11 = size * createVector(2, 2, 1) + Vector3.new(0, Y, 0)
	local v12 = humanoidRootPart.CFrame * CFrame.new(0, Y / 2 - size.Y / 2, 0)
	return RotatedRegion3.new(v12, v11), v12, v11
end

function ZoneController.getTouchingZones(player, p, p2)
	local v11 = v8[player]
	v8[player] = nil
	local v12 = v11 or p2
	local v13

	if v12 == enums.Detection.WholeBody then
		v13 = ZoneController.getCharacterRegion(player)
	else
		local character = player.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		local cFrame = humanoidRootPart and humanoidRootPart.CFrame
		v13 = cFrame and RotatedRegion3.new(cFrame, createVector(0.1, 0.1, 0.1))
	end

	if not v13 then
		return {}
	end

	local v14 = p and groupParts or groupParts2
	local v15 = p and v4 or v5
	local partsInRegion3 = v13:FindPartsInRegion3WithWhiteList(v14, #v14)

	if #partsInRegion3 > 0 then
		local humanoidRootPart = player.Character.HumanoidRootPart
		local cFrame = humanoidRootPart.CFrame
		local X = humanoidRootPart.Size.X
		local v16

		if v12 == enums.Detection.WholeBody then
			v16 = { (cFrame * CFrame.new(-X, 0, 0)).Position, (cFrame * CFrame.new(X, 0, 0)).Position }
		else
			v16 = { humanoidRootPart.Position }
		end

		if not ZoneController.verifyTouchingParts(v16, partsInRegion3) then
			return {}
		end
	end

	local v16 = {}
	local result = {}

	for _, v17 in pairs(partsInRegion3) do
		local v18 = v15[v17]

		if not v18 then
			continue
		end

		v16[v18] = true
		result[v17] = v18
	end

	local _currentExitDetection = nil
	local result2 = {}

	for k, _ in pairs(v16) do
		if _currentExitDetection == nil or k._currentExitDetection < _currentExitDetection then
			_currentExitDetection = k._currentExitDetection
		end

		table.insert(result2, k)
	end

	if _currentExitDetection then
		v8[player] = _currentExitDetection
	end

	return result2, result
end

function ZoneController.getHeightOfParts(items)
	local v11 = nil
	local v12 = nil

	for _, item in pairs(items) do
		local midpoint = (item.Size.Y + 10) / 2
		local v14 = item.Position.Y + midpoint
		local v15 = item.Position.Y - midpoint

		if v11 == nil or v11 < v14 then
			v11 = v14
		end

		if v12 == nil or v15 < v12 then
			v12 = v15
		end
	end

	return v11 - v12, v12, v11
end

function ZoneController.vectorIsBetweenYBounds(data, filterDescendantsInstances)
	local heightOfParts, v11, v12 = ZoneController.getHeightOfParts(filterDescendantsInstances)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	raycastParams.FilterType = Enum.RaycastFilterType.Include

	for i = 1, 2 do
		local vector2 = Vector3.new(data.X, i == 1 and v12 or v11, data.Z)
		local v14

		if i == 1 then
			v14 = -heightOfParts or heightOfParts
		else
			v14 = heightOfParts
		end

		local vector3 = Vector3.new(0, v14, 0)
		local raycastResult = workspace:Raycast(vector2, vector3, raycastParams)
		local Y = data.Y
		local Y2 = raycastResult and raycastResult.Position.Y

		if not Y2 or i == 1 and Y2 < Y or i == 2 and Y < Y2 then
			return false
		end
	end

	return true
end

function ZoneController.verifyTouchingParts(items, items2)
	local v11 = {
		MeshPart = true,
		UnionOperation = true
	}
	local v12 = true

	for _, item in pairs(items2) do
		if not v11[item.ClassName] then
			v12 = false
		end
	end

	if not v12 then
		return true
	end

	for _, item in pairs(items) do
		if ZoneController.vectorIsBetweenYBounds(item, items2) then
			return true
		end
	end

	return false
end

return ZoneController