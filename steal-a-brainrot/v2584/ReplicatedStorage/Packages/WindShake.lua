local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Settings = require(script.Settings)
local VectorMap = require(script.VectorMap)
local _ = {
	WindDirection = createVector(0.5, 0, 0.5),
	WindPower = 0.5,
	WindSpeed = 20
}
local bindableEvent = Instance.new("BindableEvent")
local bindableEvent2 = Instance.new("BindableEvent")
local bindableEvent3 = Instance.new("BindableEvent")
local bindableEvent4 = Instance.new("BindableEvent")
local bindableEvent5 = Instance.new("BindableEvent")
local WindShake = {
	RenderDistance = 150,
	MaxRefreshRate = 0.016666666666666666,
	SharedSettings = Settings.new(script),
	ObjectMetadata = {},
	VectorMap = VectorMap.new(),
	Handled = 0,
	Active = 0,
	_partList = table.create(500),
	_cframeList = table.create(500),
	ObjectShakeAdded = bindableEvent3.Event,
	ObjectShakeRemoved = bindableEvent4.Event,
	ObjectShakeUpdated = bindableEvent5.Event,
	Paused = bindableEvent.Event,
	Resumed = bindableEvent2.Event,
	Initialized = nil,
	AddedConnection = nil,
	UpdateConnection = nil,
	RemovedConnection = nil,
	WorkspaceWindConnection = nil
}

local function Connect(p, object, callback)
	return object:Connect(function(...)
		return callback(p, ...)
	end)
end

function WindShake:AddObjectShake(instance, p)
	if not (typeof(instance) == "Instance" and (instance:IsA("BasePart") or instance:IsA("Bone"))) then
		return
	end

	local objectMetadata = self.ObjectMetadata

	if objectMetadata[instance] then
		return
	end

	local vectorMap = self.VectorMap
	local v2

	if instance:IsA("Bone") then
		v2 = instance.WorldPosition
	else
		v2 = instance.Position
	end

	local v = {
		ChunkKey = vectorMap:AddObject(v2, instance),
		Settings = Settings.new(instance),
		Seed = math.random(5000) * 0.32,
		Origin = 0,
		LastUpdate = 0
	}
	local origin

	if instance:IsA("Bone") then
		origin = instance.WorldCFrame
	else
		origin = instance.CFrame
	end

	v.Origin = origin
	v.LastUpdate = os.clock()
	objectMetadata[instance] = v

	if p then
		self:UpdateObjectSettings(instance, p)
	end

	bindableEvent3:Fire(instance)
	self.Handled += 1
end

function WindShake:RemoveObjectShake(instance)
	if not (typeof(instance) == "Instance" and (instance:IsA("BasePart") or instance:IsA("Bone"))) then
		return
	end

	local objectMetadata = self.ObjectMetadata
	local v = objectMetadata[instance]

	if v then
		self.Handled -= 1
		objectMetadata[instance] = nil
		v.Settings:Destroy()
		self.VectorMap:RemoveObject(v.ChunkKey, instance)

		if instance:IsA("BasePart") then
			instance.CFrame = v.Origin
		elseif instance:IsA("Bone") then
			instance.WorldCFrame = v.Origin
		end
	end

	bindableEvent4:Fire(instance)
end

function WindShake:Update(p: number)
	debug.profilebegin("WindShake")
	local count = 0
	debug.profilebegin("Update")
	local now = os.clock()
	local v = p * 3
	local v2 = math.min(1, p * 5)
	local count2 = 0
	local _partList = self._partList
	local _cframeList = self._cframeList
	table.clear(_partList)
	table.clear(_cframeList)
	local objectMetadata = self.ObjectMetadata
	local currentCamera = workspace.CurrentCamera
	local position = currentCamera.CFrame.Position
	local renderDistance = self.RenderDistance
	local maxRefreshRate = self.MaxRefreshRate
	local sharedSettings = self.SharedSettings
	local v3 = assert(sharedSettings.WindPower)
	local v4 = assert(sharedSettings.WindSpeed)
	local v5 = assert(sharedSettings.WindDirection)
	self.VectorMap:ForEachObjectInView(currentCamera, renderDistance, function(p2: string, state2)
		local v6 = objectMetadata[state2]
		local lastUpdate = v6.LastUpdate or 0
		local v7 = p2 == "Bone"
		local worldCFrame

		if v7 then
			worldCFrame = state2.WorldCFrame
		else
			worldCFrame = state2.CFrame
		end

		local v8 = (position - worldCFrame.Position).Magnitude / renderDistance
		local v9 = v8 * v8
		local v10 = 1 / math.random(60, 120)
		local v11 = v * v9 + maxRefreshRate

		if now - lastUpdate + v10 <= v11 then
			return
		end

		v6.LastUpdate = now
		count += 1
		local settings = v6.Settings
		local windDirection = settings.WindDirection or v5

		if windDirection.Magnitude < 0.00001 then
			return
		end

		local v12 = (settings.WindPower or v3) * 0.2

		if v12 < 0.00001 then
			return
		end

		local v13 = now * ((settings.WindSpeed or v4) * 0.08)

		if v13 < 0.00001 then
			return
		end

		local seed = v6.Seed
		local v14 = (math.noise(v13, 0, seed) + 0.4) * v12
		local v15 = math.clamp(v2 + v9, 0.1, 0.5)
		local v16 = v12 / 3
		local cframe = v6.Origin * (settings.PivotOffset or CFrame.identity)
		local vector2 = cframe:VectorToObjectSpace(windDirection)

		if v7 then
			state2.Transform = state2.Transform:Lerp(
				CFrame.fromAxisAngle(vector2:Cross(createVector(0, 1, 0)), -v14) * CFrame.Angles(
					math.noise(seed, 0, v13) * v16,
					math.noise(seed, v13, 0) * v16,
					math.noise(v13, seed, 0) * v16
				) + vector2 * v14 * v12,
				v15
			)
			return
		end

		count2 += 1
		_partList[count2] = state2
		_cframeList[count2] = worldCFrame:Lerp(
			cframe * CFrame.fromAxisAngle(vector2:Cross(createVector(0, 1, 0)), -v14) * CFrame.Angles(
				math.noise(seed, 0, v13) * v16,
				math.noise(seed, v13, 0) * v16,
				math.noise(v13, seed, 0) * v16
			) * (settings.PivotOffsetInverse or CFrame.identity) + windDirection * v14 * (v12 * 2),
			v15
		)
	end)
	self.Active = count
	debug.profileend()
	workspace:BulkMoveTo(_partList, _cframeList, Enum.BulkMoveMode.FireCFrameChanged)
	debug.profileend()
end

function WindShake:Pause()
	if self.UpdateConnection then
		self.UpdateConnection:Disconnect()
		self.UpdateConnection = nil
	end

	self.Active = 0
	self.Running = false
	bindableEvent:Fire()
end

function WindShake:Resume()
	if self.Running then
		return
	end

	local heartbeat = RunService.Heartbeat
	local update = self.Update
	self.UpdateConnection = heartbeat:Connect(function(...)
		return update(self, ...)
	end)
	self.Running = true
	bindableEvent2:Fire()
end

function WindShake:Init(p)
	if self.Initialized then
		return
	end

	local windPower = script:GetAttribute("WindPower")
	local windSpeed = script:GetAttribute("WindSpeed")
	local windDirection = script:GetAttribute("WindDirection")

	if typeof(windPower) ~= "number" then
		script:SetAttribute("WindPower", 0.5)
	end

	if typeof(windSpeed) ~= "number" then
		script:SetAttribute("WindSpeed", 20)
	end

	if typeof(windDirection) ~= "Vector3" then
		script:SetAttribute("WindDirection", createVector(0.5, 0, 0.5))
	end

	self:Cleanup()
	self.Initialized = true
	local instanceAddedSignal = CollectionService:GetInstanceAddedSignal("WindShake")
	local addObjectShake = self.AddObjectShake
	self.AddedConnection = instanceAddedSignal:Connect(function(...)
		return addObjectShake(self, ...)
	end)
	local instanceRemovedSignal = CollectionService:GetInstanceRemovedSignal("WindShake")
	local removeObjectShake = self.RemoveObjectShake
	self.RemovedConnection = instanceRemovedSignal:Connect(function(...)
		return removeObjectShake(self, ...)
	end)

	for _, instance in CollectionService:GetTagged("WindShake") do
		if instance:IsA("BasePart") or instance:IsA("Bone") then
			self:AddObjectShake(instance)
		end
	end

	if p and p.MatchWorkspaceWind then
		self:MatchWorkspaceWind()
		self.WorkspaceWindConnection = workspace:GetPropertyChangedSignal("GlobalWind"):Connect(function()
			self:MatchWorkspaceWind()
		end)
	end

	self:Resume()
end

function WindShake:Cleanup()
	if not self.Initialized then
		return
	end

	self:Pause()

	if self.AddedConnection then
		self.AddedConnection:Disconnect()
		self.AddedConnection = nil
	end

	if self.RemovedConnection then
		self.RemovedConnection:Disconnect()
		self.RemovedConnection = nil
	end

	if self.WorkspaceWindConnection then
		self.WorkspaceWindConnection:Disconnect()
		self.WorkspaceWindConnection = nil
	end

	table.clear(self.ObjectMetadata)
	self.VectorMap:ClearAll()
	self.Handled = 0
	self.Active = 0
	self.Initialized = false
end

function WindShake:UpdateObjectSettings(instance, items)
	if typeof(instance) ~= "Instance" or typeof(items) ~= "table" or not self.ObjectMetadata[instance] and instance ~= script then
		return
	end

	for k, item in pairs(items) do
		instance:SetAttribute(k, item)
	end

	bindableEvent5:Fire(instance)
end

function WindShake.UpdateAllObjectSettings(p, items)
	if typeof(items) ~= "table" then
		return
	end

	for k, _ in p.ObjectMetadata do
		for k2, item in pairs(items) do
			k:SetAttribute(k2, item)
		end

		bindableEvent5:Fire(k)
	end
end

function WindShake:SetDefaultSettings(p)
	self:UpdateObjectSettings(script, p)
end

function WindShake:MatchWorkspaceWind()
	local globalWind = workspace.GlobalWind
	local unit = globalWind.Unit
	local magnitude = globalWind.Magnitude
	local windPower, windSpeed

	if magnitude > 0 then
		windPower = not (magnitude > 1) and 0.3 or math.log10(magnitude) + 0.2

		if magnitude < 100 then
			windSpeed = magnitude * 1.2 + 5
		else
			windSpeed = 125
		end
	else
		windSpeed = 0
		windPower = 0
	end

	self:SetDefaultSettings({
		WindDirection = unit,
		WindSpeed = windSpeed,
		WindPower = windPower
	})
end

return WindShake