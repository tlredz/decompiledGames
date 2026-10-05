local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Settings = require(script.Settings)
local VectorMap = require(script.VectorMap)
local _ = {
	WindDirection = createVector(0.5, 0, 0.5),
	WindSpeed = 20,
	WindPower = 0.5
}
local bindableEvent = Instance.new("BindableEvent")
local bindableEvent2 = Instance.new("BindableEvent")
local bindableEvent3 = Instance.new("BindableEvent")
local bindableEvent4 = Instance.new("BindableEvent")
local bindableEvent5 = Instance.new("BindableEvent")
local WindShake = {}
WindShake.RenderDistance = 150
WindShake.MaxRefreshRate = 0.016666666666666666
WindShake.SharedSettings = Settings.new(script)
WindShake.ObjectMetadata = {}
WindShake.VectorMap = VectorMap.new()
WindShake.Handled = 0
WindShake.Active = 0
WindShake._partList = table.create(500)
WindShake._cframeList = table.create(500)
WindShake.ObjectShakeAdded = bindableEvent.Event
WindShake.ObjectShakeRemoved = bindableEvent2.Event
WindShake.ObjectShakeUpdated = bindableEvent3.Event
WindShake.Paused = bindableEvent4.Event
WindShake.Resumed = bindableEvent5.Event

function WindShake:Connect(p2: string, object)
	local v = self[p2]
	assert(typeof(v) == "function", "Unknown function: " .. p2)
	return object:Connect(function(...)
		return v(self, ...)
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

	self.Handled += 1
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

	bindableEvent:Fire(instance)
end

function WindShake.RemoveObjectShake(state, instance)
	if typeof(instance) ~= "Instance" then
		return
	end

	local objectMetadata = state.ObjectMetadata
	local v = objectMetadata[instance]

	if v then
		state.Handled -= 1
		objectMetadata[instance] = nil
		v.Settings:Destroy()
		state.VectorMap:RemoveObject(v.ChunkKey, instance)

		if instance:IsA("BasePart") then
			instance.CFrame = v.Origin
		elseif instance:IsA("Bone") then
			instance.WorldCFrame = v.Origin
		end
	end

	bindableEvent2:Fire(instance)
end

function WindShake.Update(state, p: number)
	debug.profilebegin("WindShake")
	local count = 0
	debug.profilebegin("Update")
	local now = os.clock()
	local v = p * 3
	local v2 = math.min(1, p * 5)
	local count2 = 0
	local _partList = state._partList
	local _cframeList = state._cframeList
	table.clear(_partList)
	table.clear(_cframeList)
	local objectMetadata = state.ObjectMetadata
	local currentCamera = workspace.CurrentCamera
	local position = currentCamera.CFrame.Position
	local renderDistance = state.RenderDistance
	local maxRefreshRate = state.MaxRefreshRate
	local sharedSettings = state.SharedSettings
	local windPower = sharedSettings.WindPower
	local windSpeed = sharedSettings.WindSpeed
	local windDirection = sharedSettings.WindDirection
	state.VectorMap:ForEachObjectInView(currentCamera, renderDistance, function(p2: string, state2)
		local v3 = objectMetadata[state2]
		local lastUpdate = v3.LastUpdate or 0
		local v4 = p2 == "Bone"
		local worldCFrame

		if v4 then
			worldCFrame = state2.WorldCFrame
		else
			worldCFrame = state2.CFrame
		end

		local v5 = (position - worldCFrame.Position).Magnitude / renderDistance
		local v6 = v5 * v5
		local v7 = 1 / math.random(60, 120)
		local v8 = v * v6 + maxRefreshRate

		if now - lastUpdate + v7 <= v8 then
			return
		end

		v3.LastUpdate = now
		count += 1
		local settings = v3.Settings
		local windDirection2 = settings.WindDirection or windDirection

		if windDirection2.Magnitude < 0.00001 then
			return
		end

		local v9 = (settings.WindPower or windPower) * 0.2

		if v9 < 0.00001 then
			return
		end

		local v10 = now * ((settings.WindSpeed or windSpeed) * 0.08)

		if v10 < 0.00001 then
			return
		end

		local seed = v3.Seed
		local v11 = (math.noise(v10, 0, seed) + 0.4) * v9
		local v12 = math.clamp(v2 + v6, 0.1, 0.5)
		local v13 = v9 / 3
		local cframe = v3.Origin * (settings.PivotOffset or CFrame.identity)
		local vector2 = cframe:VectorToObjectSpace(windDirection2)

		if v4 then
			state2.Transform = state2.Transform:Lerp(
				CFrame.fromAxisAngle(vector2:Cross(createVector(0, 1, 0)), -v11) * CFrame.Angles(
					math.noise(seed, 0, v10) * v13,
					math.noise(seed, v10, 0) * v13,
					math.noise(v10, seed, 0) * v13
				) + vector2 * v11 * v9,
				v12
			)
			return
		end

		count2 += 1
		_partList[count2] = state2
		_cframeList[count2] = worldCFrame:Lerp(
			cframe * CFrame.fromAxisAngle(vector2:Cross(createVector(0, 1, 0)), -v11) * CFrame.Angles(
				math.noise(seed, 0, v10) * v13,
				math.noise(seed, v10, 0) * v13,
				math.noise(v10, seed, 0) * v13
			) * (settings.PivotOffsetInverse or CFrame.identity) + windDirection2 * v11 * (v9 * 2),
			v12
		)
	end)
	state.Active = count
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
	bindableEvent4:Fire()
end

function WindShake:Resume()
	if self.Running then
		return
	end

	self.Running = true
	self.UpdateConnection = self:Connect("Update", RunService.Heartbeat)
	bindableEvent5:Fire()
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
	self.AddedConnection = self:Connect("AddObjectShake", (CollectionService:GetInstanceAddedSignal("WindShake")))
	self.RemovedConnection = self:Connect(
		"RemoveObjectShake",
		(CollectionService:GetInstanceRemovedSignal("WindShake"))
	)

	for _, v in CollectionService:GetTagged("WindShake") do
		self:AddObjectShake(v)
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

	for k, item in items do
		instance:SetAttribute(k, item)
	end

	bindableEvent3:Fire(instance)
end

function WindShake.UpdateAllObjectSettings(p, items)
	if typeof(items) ~= "table" then
		return
	end

	for k, _ in p.ObjectMetadata do
		for k2, item in items do
			k:SetAttribute(k2, item)
		end

		bindableEvent3:Fire(k)
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