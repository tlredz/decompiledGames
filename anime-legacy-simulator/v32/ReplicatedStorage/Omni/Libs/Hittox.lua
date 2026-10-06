local createVector = vector.create
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local templates = script.Templates
local GoodSignal = require(script.GoodSignal)
local v = {}
local v2 = nil
local parent2 = nil
local v4 = nil
local v5 = false
local isServer = RunService:IsServer()
local Hittox = {}

local function GetHitboxSize(p: string, value)
	local v6 = nil

	if p == "Block" then
		return (value == nil or typeof(value) ~= "Vector3" or not value) and createVector(1, 1, 1) or value
	elseif p == "Ball" then
		return (value == nil or typeof(value) ~= "number" or not value) and 1 or value
	end

	return v6
end

local function Visualize(data)
	if not parent2 then
		return
	end

	local mode = data.Mode
	local size = data.Size
	local size2 = nil

	if mode == "Block" then
		size2 = (size == nil or typeof(size) ~= "Vector3" or not size) and createVector(1, 1, 1) or size
	elseif mode == "Ball" then
		size2 = (size == nil or typeof(size) ~= "number" or not size) and 1 or size
	end

	if not size2 then
		return
	end

	local clone = nil

	if data.Mode == "Block" then
		clone = templates.Block:Clone()
		clone.CFrame = data.Origin
		clone.Size = size2
		clone.Parent = parent2
	elseif data.Mode == "Ball" then
		clone = templates.Ball:Clone()
		clone.CFrame = data.Origin
		clone.Size = Vector3.new(size2, size2, size2)
		clone.Parent = parent2
	end

	if isServer then
		clone.Name = "Server"
	else
		clone.Name = "Client"
	end

	return clone, size2
end

local function GetHitPoint(value)
	if typeof(value) == "Vector3" then
		return CFrame.new(value), createVector(0, 0, 0)
	end

	if typeof(value) == "table" and typeof(value.CFrame) == "CFrame" then
		return
			value.CFrame,
			typeof(value.Size) ~= "Vector3" and createVector(0, 0, 0) or value.Size or createVector(0, 0, 0)
	end

	return nil, nil
end

local function SendDebug(mode: string, size, cframe: CFrame, owner)
	if not v4 then
		v2:FireAllClients({
			Mode = mode,
			Size = size,
			Origin = cframe
		})
		return
	end

	local v6 = nil

	for _, player in Players:GetPlayers() do
		local success, result = pcall(v4, player, owner)

		if not (success and result == true) then
			continue
		end

		v6 = v6 or {
			Mode = mode,
			Size = size,
			Origin = cframe
		}
		v2:FireClient(player, v6)
	end
end

local function MatchHitPoints(mode: string, p, origin: CFrame, hitPoints)
	local result = {}

	if typeof(hitPoints) ~= "table" then
		return result
	end

	if mode == "Block" then
		local v6 = p / 2

		for k, item in hitPoints do
			if typeof(k) ~= "string" then
				continue
			end

			local cframe, size

			if typeof(item) == "Vector3" then
				cframe = CFrame.new(item)
				size = createVector(0, 0, 0)
			elseif typeof(item) == "table" and typeof(item.CFrame) == "CFrame" then
				cframe = item.CFrame
				size = typeof(item.Size) == "Vector3" and item.Size

				if not size then
					size = createVector(0, 0, 0)
				end
			end

			if not (cframe and size) then
				continue
			end

			local pointToObjectSpace = origin:PointToObjectSpace(cframe.Position)
			local halfMagnitude = size.Magnitude / 2

			if not (math.abs(pointToObjectSpace.X) <= v6.X + halfMagnitude and math.abs(pointToObjectSpace.Y) <= v6.Y + halfMagnitude) then
				continue
			end

			if not (math.abs(pointToObjectSpace.Z) <= v6.Z + halfMagnitude) then
				continue
			end

			table.insert(result, k)
		end

		return result
	else
		if mode ~= "Ball" then
			return result
		end

		local v6 = p / 2
		local position = origin.Position

		for k, item in hitPoints do
			if typeof(k) ~= "string" then
				continue
			end

			local cframe, size

			if typeof(item) == "Vector3" then
				cframe = CFrame.new(item)
				size = createVector(0, 0, 0)
			elseif typeof(item) == "table" and typeof(item.CFrame) == "CFrame" then
				cframe = item.CFrame
				size = typeof(item.Size) == "Vector3" and item.Size

				if not size then
					size = createVector(0, 0, 0)
				end
			end

			if not (cframe and size) then
				continue
			end

			local halfSize = size / 2
			local pointToObjectSpace = cframe:PointToObjectSpace(position)

			if not ((pointToObjectSpace - Vector3.new(
				math.clamp(pointToObjectSpace.X, -halfSize.X, halfSize.X),
				math.clamp(pointToObjectSpace.Y, -halfSize.Y, halfSize.Y),
				(math.clamp(pointToObjectSpace.Z, -halfSize.Z, halfSize.Z))
			)).Magnitude <= v6) then
				continue
			end

			table.insert(result, k)
		end

		return result
	end
end

function Hittox.SetDebugModeEnabled(flag: boolean)
	v5 = flag == true
end

function Hittox.SetDebugFilter(callback)
	if typeof(callback) ~= "function" then
		callback = nil
	end

	v4 = callback
end

function Hittox.new(data)
	if not isServer or (not data or typeof(data) ~= "table") then
		return
	end

	if not data.Mode or typeof(data.Mode) ~= "string" or (not data.Origin or typeof(data.Origin) ~= "CFrame") then
		return
	end

	local instance, size = Visualize({
		Mode = data.Mode,
		Size = data.Size,
		Origin = data.Origin
	})

	if not (instance and size) then
		return
	end

	local overlapParams = OverlapParams.new()

	if data.Whitelist then
		overlapParams.FilterType = Enum.RaycastFilterType.Include
		overlapParams.FilterDescendantsInstances = data.Whitelist
	elseif data.Blacklist then
		overlapParams.FilterType = Enum.RaycastFilterType.Exclude
		overlapParams.FilterDescendantsInstances = data.Blacklist
	else
		overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	end

	local hitPoints = {}

	if typeof(data.HitPoints) == "table" then
		for k, hitPoint in data.HitPoints do
			if typeof(k) ~= "string" then
				continue
			end

			if typeof(hitPoint) == "Vector3" then
				hitPoints[k] = {
					CFrame = CFrame.new(hitPoint),
					Size = createVector(0, 0, 0)
				}
			elseif typeof(hitPoint) == "table" and typeof(hitPoint.CFrame) == "CFrame" then
				hitPoints[k] = {
					CFrame = hitPoint.CFrame,
					Size = typeof(hitPoint.Size) ~= "Vector3" and createVector(0, 0, 0) or hitPoint.Size or createVector(
						0,
						0,
						0
					)
				}
			end
		end
	end

	local object = setmetatable({}, {
		__index = v
	})
	object.Instance = instance
	object.Size = size
	object.HitPoints = hitPoints
	object.OVP = overlapParams
	object.Mode = data.Mode
	object.Owner = data.Owner
	object.HumanoidOnly = data.HumanoidOnly == true
	object.TouchStarted = GoodSignal.new()
	object.TouchEnded = GoodSignal.new()
	return object
end

function Hittox:Check()
	if not isServer then
		return
	end

	local v6 = Hittox.new(self)

	if not v6 then
		return
	end

	local v7 = v6:Check()
	v6:Destroy()
	return v7
end

function Hittox.CheckHitPoints(data)
	if not isServer or (not data or typeof(data) ~= "table") then
		return
	end

	if not data.Mode or typeof(data.Mode) ~= "string" or (not data.Origin or typeof(data.Origin) ~= "CFrame") then
		return
	end

	local mode = data.Mode
	local size = data.Size
	local v6 = nil

	if mode == "Block" then
		v6 = (size == nil or typeof(size) ~= "Vector3" or not size) and createVector(1, 1, 1) or size
	elseif mode == "Ball" then
		v6 = (size == nil or typeof(size) ~= "number" or not size) and 1 or size
	end

	if not v6 then
		return
	end

	SendDebug(data.Mode, v6, data.Origin, data.Owner)
	return (MatchHitPoints(data.Mode, v6, data.Origin, data.HitPoints))
end

function v:Start()
	if self.Connection then
		return
	end

	self.Connection = RunService.Heartbeat:Connect(function()
		self:Check()
	end)
end

function v:Stop()
	if not self.Connection then
		return
	end

	self.Connection:Disconnect()
	self.Connection = nil
end

function v:Check()
	if not self.Instance then
		return
	end

	local size = self.Size
	local partsInPart = nil

	if self.Mode == "Block" then
		partsInPart = workspace:GetPartsInPart(self.Instance, self.OVP)
	elseif self.Mode == "Ball" then
		partsInPart = workspace:GetPartBoundsInRadius(self.Instance.Position, size / 2, self.OVP)
	end

	if not partsInPart then
		return
	end

	SendDebug(self.Mode, size, self.Instance.CFrame, self.Owner)
	local parents

	if self.HumanoidOnly then
		parents = {}

		for _, v6 in partsInPart do
			local parent = v6.Parent

			if not (parent and parent:IsA("Model") and (parent:FindFirstChildOfClass("Humanoid") or parent:GetAttribute("Humanoid"))) then
				continue
			end

			if table.find(parents, parent) ~= nil then
				continue
			end

			table.insert(parents, parent)
		end
	else
		parents = partsInPart
	end

	if not parents then
		return
	end

	if self._CurrentTouching and #self._CurrentTouching > 0 then
		for _, v6 in parents do
			if table.find(self._CurrentTouching, v6) == nil then
				self.TouchStarted:Fire(v6)
			end
		end

		for _, v6 in self._CurrentTouching do
			if table.find(parents, v6) == nil then
				self.TouchEnded:Fire(v6)
			end
		end
	else
		for _, v6 in parents do
			self.TouchStarted:Fire(v6)
		end
	end

	self._CurrentTouching = parents
	return parents
end

function v.CheckHitPoints(data)
	if not data.Instance then
		return
	end

	local result = {}
	local size = data.Size
	local position = data.Instance.Position
	SendDebug(data.Mode, size, data.Instance.CFrame, data.Owner)

	if data.Mode == "Block" then
		local halfSize = size / 2

		for k, hitPoint in data.HitPoints do
			local pointToObjectSpace = data.Instance.CFrame:PointToObjectSpace(hitPoint.CFrame.Position)
			local halfMagnitude = hitPoint.Size.Magnitude / 2

			if not (math.abs(pointToObjectSpace.X) <= halfSize.X + halfMagnitude and math.abs(pointToObjectSpace.Y) <= halfSize.Y + halfMagnitude) then
				continue
			end

			if not (math.abs(pointToObjectSpace.Z) <= halfSize.Z + halfMagnitude) then
				continue
			end

			table.insert(result, k)
		end

		return result
	else
		if data.Mode ~= "Ball" then
			return result
		end

		local halfSize = size / 2

		for k, hitPoint in data.HitPoints do
			local halfSize2 = hitPoint.Size / 2
			local pointToObjectSpace = hitPoint.CFrame:PointToObjectSpace(position)

			if not ((pointToObjectSpace - Vector3.new(
				math.clamp(pointToObjectSpace.X, -halfSize2.X, halfSize2.X),
				math.clamp(pointToObjectSpace.Y, -halfSize2.Y, halfSize2.Y),
				(math.clamp(pointToObjectSpace.Z, -halfSize2.Z, halfSize2.Z))
			)).Magnitude <= halfSize) then
				continue
			end

			table.insert(result, k)
		end

		return result
	end
end

function v.SetOrigin(p, cFrame: CFrame)
	if not p.Instance or p.Weld then
		return
	end

	p.Instance.CFrame = cFrame
end

function v:SetSize(value)
	if not self.Instance then
		return
	end

	local mode = self.Mode
	local size = nil

	if mode == "Block" then
		size = (value == nil or typeof(value) ~= "Vector3" or not value) and createVector(1, 1, 1) or value
	elseif mode == "Ball" then
		size = (value == nil or typeof(value) ~= "number" or not value) and 1 or value
	end

	if not size then
		return
	end

	self.Size = size
	self.Instance.Size = size
end

function v:SetWeld(part, C1: CFrame)
	if not self.Instance or (not C1 or typeof(C1) ~= "CFrame") then
		return
	end

	if not part or typeof(part) ~= "Instance" or not part:IsA("BasePart") then
		return
	end

	local weld = self.Weld or Instance.new("WeldConstraint")
	weld.Part0 = part
	weld.Part1 = self.Instance
	weld.C1 = C1
	weld.Parent = self.Instance
	self.Instance.Anchored = false
	self.Weld = weld
end

function v:RemoveWeld()
	if not (self.Instance and self.Weld) then
		return
	end

	self.Instance.Anchored = true
	self.Weld:Destroy()
	self.Weld = nil
end

function v:Destroy()
	if self.Connection then
		self.Connection:Disconnect()
		self.Connection = nil
	end

	if self.Weld then
		self.Weld:Destroy()
		self.Weld = nil
	end

	if self.Instance then
		self.Instance:Destroy()
		self.Instance = nil
	end

	if self._CurrentTouching and #self._CurrentTouching > 0 then
		for _, v6 in self._CurrentTouching do
			self.TouchEnded:Fire(v6)
		end
	end

	self._CurrentTouching = nil
	self.TouchStarted:DisconnectAll()
	self.TouchEnded:DisconnectAll()
	setmetatable(self, nil)
end

if isServer then
	v2 = Instance.new("RemoteEvent")
	v2.Name = "Hittox"
	v2.Parent = script
else
	task.spawn(function()
		repeat
			v2 = script:FindFirstChild("Hittox")
			task.wait(0.1)
		until v2 ~= nil

		v2.OnClientEvent:Connect(function(p)
			if not v5 then
				return
			end

			local visualize = Visualize(p)

			if not visualize then
				return
			end

			task.delay(0.5, function()
				visualize:Destroy()
			end)
		end)
	end)
end

if isServer then
	parent2 = Instance.new("Folder")
	parent2.Name = "__Hittox"
	parent2.Parent = workspace
else
	task.spawn(function()
		while true do
			parent2 = workspace:FindFirstChild("__Hittox")

			if parent2 then
				break
			end

			task.wait(0.1)
		end
	end)
end

return Hittox