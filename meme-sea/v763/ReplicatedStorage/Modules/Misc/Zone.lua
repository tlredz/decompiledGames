local createVector = vector.create
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local heartbeat = RunService.Heartbeat
local localPlayer = RunService:IsClient() and Players.LocalPlayer
game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Enum = require(script.Enum)
local enums = Enum.enums
local Maid = require(script.Maid)
local RotatedRegion3 = require(script.RotatedRegion3)
local Signal = require(script.Signal)
local ZonePlusReference = require(script.ZonePlusReference)
local object = ZonePlusReference.getObject()
local ZoneController = require(script.ZoneController)
local RunService2 = game:GetService("RunService")
local v = RunService2:IsClient() and "Client" or "Server"
local child = object and object:FindFirstChild(v)
local Value = child and require(object.Value) or {}
Value.__index = Value

if not child then
	ZonePlusReference.addToReplicatedStorage()
end

Value.enum = enums

function Value.new(group)
	local class = {}
	setmetatable(class, Value)
	local typeName = typeof(group)

	if typeName ~= "table" and typeName ~= "Instance" then
		warn("A zone group must be a model, folder, basepart or table!")
	end

	class.accuracy = enums.Accuracy.High
	class.autoUpdate = false
	class.respectUpdateQueue = true
	local maid = Maid.new()
	class._maid = maid
	class._updateConnections = maid:give(Maid.new())
	class.group = group
	class.groupParts = {}
	class.region = nil
	class.volume = nil
	class.boundMin = nil
	class.boundMax = nil
	class.recommendedMaxParts = nil
	class.zoneId = HttpService:GenerateGUID()
	class.activeTriggers = {}
	class.occupants = {}
	class.trackingTouchedTriggers = {}
	class.enterDetection = enums.Detection.Automatic
	class.exitDetection = enums.Detection.Automatic
	class._currentEnterDetection = nil
	class._currentExitDetection = nil
	class.totalPartVolume = 0
	ZoneController.updateDetection(class)
	class.updated = maid:give(Signal.new())
	local v3 = { "player", "part", "localPlayer" }
	local v4 = { "entered", "exited" }

	for _, v5 in pairs(v3) do
		local v6 = 0
		local total = 0

		for _, v7 in pairs(v4) do
			local v8 = maid:give(Signal.new(true))
			local v9 = v7:sub(1, 1):upper() .. v7:sub(2)
			class[v5 .. v9] = v8
			local v10 = v5
			v8.connectionsChanged:Connect(function(p)
				if v10 == "localPlayer" and not localPlayer and p == 1 then
					error(("Can only connect to 'localPlayer%s' on the client!"):format(v9))
				end

				v6 = total
				total += p

				if v6 == 0 and total > 0 then
					ZoneController._registerConnection(class, v10, v9)
				elseif v6 > 0 and total == 0 then
					ZoneController._deregisterConnection(class, v10)
				end
			end)
		end
	end

	Value.touchedConnectionActions = {}

	for _, v5 in pairs(v3) do
		local v6 = class[("_%sTouchedZone"):format(v5)]

		if not v6 then
			continue
		end

		class.trackingTouchedTriggers[v5] = {}
		local v7 = v6

		Value.touchedConnectionActions[v5] = function(p)
			v7(class, p)
		end
	end

	class:_update()
	ZoneController._registerZone(class)
	maid:give(function()
		ZoneController._deregisterZone(class)
	end)
	return class
end

function Value:_calculateRegion(items, p)
	local v2 = {
		Min = {},
		Max = {}
	}

	for k, v3 in pairs(v2) do
		v3.Values = {}
		local v4 = k

		function v3.parseCheck(p2, p3)
			if v4 == "Min" then
				return p2 <= p3
			elseif v4 == "Max" then
				return p3 <= p2
			end
		end

		function v3:parse(items2)
			for k2, item in pairs(items2) do
				local v5 = self.Values[k2] or item

				if self.parseCheck(item, v5) then
					self.Values[k2] = item
				end
			end
		end
	end

	for _, item in pairs(items) do
		local v3 = item.Size * 0.5
		local v4 = {
			item.CFrame * CFrame.new(-v3.X, -v3.Y, -v3.Z),
			item.CFrame * CFrame.new(-v3.X, -v3.Y, v3.Z),
			item.CFrame * CFrame.new(-v3.X, v3.Y, -v3.Z),
			item.CFrame * CFrame.new(-v3.X, v3.Y, v3.Z),
			item.CFrame * CFrame.new(v3.X, -v3.Y, -v3.Z),
			item.CFrame * CFrame.new(v3.X, -v3.Y, v3.Z),
			item.CFrame * CFrame.new(v3.X, v3.Y, -v3.Z),
			item.CFrame * CFrame.new(v3.X, v3.Y, v3.Z)
		}

		for _, cframe in pairs(v4) do
			local components, v5, v6 = cframe:GetComponents()
			local v7 = { components, v5, v6 }
			v2.Min:parse(v7)
			v2.Max:parse(v7)
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function roundToFour(p2)
		return math.floor((p2 + 2) / 4) * 4
	end

	local v3 = {}
	local v4 = {}

	for k, v5 in pairs(v2) do
		for _, value in pairs(v5.Values) do
			local v6 = k == "Min" and v4 or v3

			if not p then
				value = roundToFour(value + (k == "Min" and -2 or 2))
			end

			table.insert(v6, value)
		end
	end

	local vector2 = Vector3.new(unpack(v4))
	local vector3 = Vector3.new(unpack(v3))
	return Region3.new(vector2, vector3), vector2, vector3
end

function Value:_displayBounds()
	if not self.displayBoundParts then
		self.displayBoundParts = true
		local v2 = {
			BoundMin = self.boundMin,
			BoundMax = self.boundMax
		}

		for k, position in pairs(v2) do
			local part = Instance.new("Part")
			part.Anchored = true
			part.CanCollide = false
			part.Transparency = 0.5
			part.Size = createVector(1, 1, 1)
			part.Color = Color3.fromRGB(255, 0, 0)
			part.CFrame = CFrame.new(position)
			part.Name = k
			part.Parent = workspace
			self._maid:give(part)
		end
	end
end

function Value:_update()
	local group = self.group
	local groupParts = {}
	local v3 = 0
	self._updateConnections:clean()
	local typeName = typeof(group)
	local v4 = {}

	if typeName == "table" then
		for _, part in ipairs(group) do
			if part:IsA("BasePart") then
				table.insert(groupParts, part)
			end
		end
	elseif typeName == "Instance" then
		if group:IsA("BasePart") then
			table.insert(groupParts, group)
		else
			table.insert(v4, group)

			for _, part in ipairs(group:GetChildren()) do
				if part:IsA("BasePart") then
					table.insert(groupParts, part)
				else
					table.insert(v4, part)
				end
			end
		end
	end

	self.groupParts = groupParts

	local function update()
		if self.autoUpdate then
			local now = os.clock()

			if self.respectUpdateQueue then
				v3 += 1
				now += 0.1
			end

			local heartbeatConnection = nil
			heartbeatConnection = RunService.Heartbeat:Connect(function()
				if now <= os.clock() then
					heartbeatConnection:Disconnect()

					if self.respectUpdateQueue then
						v3 -= 1
					end

					if v3 == 0 and self.zoneId then
						self:_update()
					end
				end
			end)
		end
	end

	local v5 = { "Size", "Position" }

	for _, v6 in ipairs(groupParts) do
		for _, propertyName in ipairs(v5) do
			self._updateConnections:give(v6:GetPropertyChangedSignal(propertyName):Connect(update))
		end
	end

	local v6 = { "ChildAdded", "ChildRemoved" }

	for _, _ in ipairs(v4) do
		for _, v7 in ipairs(v6) do
			self._updateConnections:give(self.group[v7]:Connect(function(part)
				if part:IsA("BasePart") and self.autoUpdate then
					local now = os.clock()

					if self.respectUpdateQueue then
						v3 += 1
						now += 0.1
					end

					local heartbeatConnection = nil
					heartbeatConnection = RunService.Heartbeat:Connect(function()
						if now <= os.clock() then
							heartbeatConnection:Disconnect()

							if self.respectUpdateQueue then
								v3 -= 1
							end

							if v3 == 0 and self.zoneId then
								self:_update()
							end
						end
					end)
				end
			end))
		end
	end

	local _calculateRegion, boundMin, boundMax = self:_calculateRegion(groupParts)
	local _calculateRegion2, _, _ = self:_calculateRegion(groupParts, true)
	self.region = _calculateRegion
	self.exactRegion = _calculateRegion2
	self.boundMin = boundMin
	self.boundMax = boundMax
	local size = _calculateRegion.Size
	self.volume = size.X * size.Y * size.Z
	self:_updateTouchedConnections()
	self.updated:Fire()
end

function Value._updateOccupants(p, p2, items)
	local occupant = p.occupants[p2]

	if not occupant then
		occupant = {}
		p.occupants[p2] = occupant
	end

	local v2 = p[p2 .. "Exited"]
	local v3 = p[p2 .. "Entered"]

	if v2 then
		for k, v4 in pairs(occupant) do
			local item = items[k]

			if not (item == nil or item ~= v4) then
				continue
			end

			occupant[k] = nil
			v2:Fire(k)
		end
	end

	if v3 then
		for k, _ in pairs(items) do
			if occupant[k] ~= nil then
				continue
			end

			occupant[k] = k.Character
			v3:Fire(k)
		end
	end
end

function Value:_formTouchedConnection(p)
	local v2 = "_touchedMaid" .. p
	local v3 = self[v2]

	if v3 then
		v3:clean()
	else
		self[v2] = self._maid:give(Maid.new())
	end

	self:_updateTouchedConnection(p)
end

function Value:_updateTouchedConnection(p2)
	local v2 = self["_touchedMaid" .. p2]

	if not v2 then
		return
	end

	for _, groupPart in pairs(self.groupParts) do
		v2:give(groupPart.Touched:Connect(self.touchedConnectionActions[p2], self))
	end
end

function Value:_updateTouchedConnections()
	for k, _ in pairs(self.touchedConnectionActions) do
		local v2 = self["_touchedMaid" .. k]

		if not v2 then
			continue
		end

		v2:clean()
		self:_updateTouchedConnection(k)
	end
end

function Value:_disconnectTouchedConnection(p2)
	local v2 = "_touchedMaid" .. p2
	local v3 = self[v2]

	if v3 then
		v3:clean()
		self[v2] = nil
	end
end

local function round(p, p2)
	return math.round(p * 10 ^ p2) * 10 ^ (-p2)
end

function Value:_partTouchedZone(instance)
	local part = self.trackingTouchedTriggers.part

	if part[instance] then
		return
	end

	local v2 = 0
	local flag = false
	local position = instance.Position
	local now = os.clock()
	local _getRegionConstructor = self:_getRegionConstructor(instance)
	local v3 = self._maid:give(Maid.new())
	part[instance] = v3

	if not ({
		Seat = true,
		VehicleSeat = true
	})[instance.ClassName] and ({
		HumanoidRootPart = true
	})[instance.Name] then
		instance.CanTouch = false
	end

	local v4 = math.round(instance.Size.X * instance.Size.Y * instance.Size.Z * 100000) * 0.00001
	self.totalPartVolume += v4
	v3:give(heartbeat:Connect(function()
		local now2 = os.clock()

		if v2 <= now2 then
			local property = enums.Accuracy.getProperty(self.accuracy)
			v2 = now2 + property
			local part2 = self:findPart(instance, _getRegionConstructor)

			if flag then
				if not part2 then
					flag = false
					position = instance.Position
					now = os.clock()
					self.partExited:Fire(instance)
				end
			elseif part2 then
				flag = true
				self.partEntered:Fire(instance)
			elseif (instance.Position - position).Magnitude > 1.5 and property <= now2 - now then
				v3:clean()
			end
		end
	end))
	v3:give(function()
		part[instance] = nil
		instance.CanTouch = true
		self.totalPartVolume = math.round((self.totalPartVolume - v4) * 100000) * 0.00001
	end)
end

function Value:_getRegionConstructor(instance)
	local success, result = pcall(function()
		return instance.Shape.Name
	end)

	if not success then
		result = ({
			WedgePart = "Wedge",
			CornerWedgePart = "CornerWedge"
		})[instance.ClassName] or "new"
	end

	return result
end

function Value:findLocalPlayer()
	if not localPlayer then
		error("Can only call 'findLocalPlayer' on the client!")
	end

	return self:findPlayer(localPlayer)
end

function Value:findPlayer(p2)
	ZoneController.updateDetection(self)
	local touchingZones = ZoneController.getTouchingZones(p2, false, self._currentEnterDetection)

	for _, touchingZone in pairs(touchingZones) do
		if touchingZone == self then
			return true
		end
	end

	return false
end

function Value:findPart(instance, p, _, _)
	local v2 = p or self:_getRegionConstructor(instance)
	local cFrame = instance.CFrame
	local partsInRegion3 = RotatedRegion3[v2](instance.CFrame, createVector(0.1, 0.1, 0.1)):FindPartsInRegion3WithWhiteList(
		self.groupParts,
		#self.groupParts
	)

	if not (#partsInRegion3 > 0) then
		return #RotatedRegion3[v2](instance.CFrame, instance.Size):FindPartsInRegion3WithWhiteList(
			self.groupParts,
			#self.groupParts
		) > 0
	end

	local v3 = instance.Size.X / 2
	local v4 = { (cFrame * CFrame.new(-v3, 0, 0)).Position, (cFrame * CFrame.new(v3, 0, 0)).Position }

	if ZoneController.verifyTouchingParts(v4, partsInRegion3) then
		return true
	end

	return false
end

function Value:getPlayers()
	ZoneController.updateDetection(self)
	local result = {}
	local v2 = ZoneController._getZonesAndPlayers({
		self = true
	}, self.volume, false, self._currentEnterDetection)[self]

	if v2 then
		for k, _ in pairs(v2) do
			table.insert(result, k)
		end
	end

	return result
end

function Value:getParts()
	local result = {}

	if self.activeTriggers.part then
		local part = self.trackingTouchedTriggers.part

		for k, _ in pairs(part) do
			table.insert(result, k)
		end

		return result
	else
		local partsInRegion3 = workspace:FindPartsInRegion3WithIgnoreList(self.region, self.groupParts)

		for _, v2 in pairs(partsInRegion3) do
			if self:findPart(v2) then
				table.insert(result, v2)
			end
		end

		return result
	end
end

function Value.getRandomPoint(p)
	local exactRegion = p.exactRegion
	local size = exactRegion.Size
	local cFrame = exactRegion.CFrame
	local random = Random.new()
	local v2 = nil

	while true do
		local v3 = cFrame * CFrame.new(
			random:NextNumber(-size.X / 2, size.X / 2),
			random:NextNumber(-size.Y / 2, size.Y / 2),
			random:NextNumber(-size.Z / 2, size.Z / 2)
		)
		local partsInRegion3 = RotatedRegion3.new(v3, createVector(0.1, 0.1, 0.1)):FindPartsInRegion3WithWhiteList(
			p.groupParts,
			#p.groupParts
		)

		if #partsInRegion3 > 0 then
			v2 = ZoneController.verifyTouchingParts({ v3.Position }, partsInRegion3)
		end

		if v2 then
			return v3.Position, partsInRegion3
		end
	end
end

function Value:setAccuracy(p2)
	local accuracy = tonumber(p2)

	if accuracy then
		if not enums.Accuracy.getName(accuracy) then
			error(("%s is an invalid enumId!"):format(accuracy))
		end
	else
		accuracy = enums.Accuracy[p2]

		if not accuracy then
			error(("'%s' is an invalid enumName!"):format(p2))
		end
	end

	self.accuracy = accuracy
end

function Value:setDetection(p2)
	local v2 = tonumber(p2)

	if v2 then
		if not enums.Detection.getName(v2) then
			error(("%s is an invalid enumId!"):format(v2))
		end
	else
		v2 = enums.Detection[p2]

		if not v2 then
			error(("'%s' is an invalid enumName!"):format(p2))
		end
	end

	self.enterDetection = v2
	self.exitDetection = v2
end

function Value:destroy()
	self._maid:clean()
end

Value.Destroy = Value.destroy
return Value