local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Settings = require(script.Settings)
local Octree = require(game.ReplicatedStorage.Util.Octree)
local v = Settings.new(script, {
	WindDirection = vector.create(0.5, 0, 0.5),
	WindSpeed = 15,
	WindPower = 0.25
})
local bindableEvent = Instance.new("BindableEvent")
local bindableEvent2 = Instance.new("BindableEvent")
local bindableEvent3 = Instance.new("BindableEvent")
local bindableEvent4 = Instance.new("BindableEvent")
local bindableEvent5 = Instance.new("BindableEvent")
local WindShake = {}
WindShake.ObjectMetadata = {}
WindShake.Octree = Octree.new()
WindShake.Handled = 0
WindShake.Active = 0
WindShake.LastUpdate = os.clock()
WindShake.ObjectShakeAdded = bindableEvent.Event
WindShake.ObjectShakeRemoved = bindableEvent2.Event
WindShake.ObjectShakeUpdated = bindableEvent3.Event
WindShake.Paused = bindableEvent4.Event
WindShake.Resumed = bindableEvent5.Event

function WindShake:Connect(p2: string, object)
	local v2 = self[p2]
	assert(typeof(v2) == "function", "Unknown function: " .. p2)
	return object:Connect(function(...)
		return v2(self, ...)
	end)
end

function WindShake:AddObjectShake(part, p)
	if not (typeof(part) == "Instance" and part:IsA("BasePart") and part.Anchored ~= false) then
		return
	end

	local objectMetadata = self.ObjectMetadata

	if objectMetadata[part] then
		return
	end

	self.Handled += 1
	objectMetadata[part] = {
		Node = self.Octree:CreateNode(part.Position, part),
		Settings = Settings.new(part, v),
		Seed = math.random(1000) * 0.1,
		Origin = part.CFrame,
		Remover = part:GetPropertyChangedSignal("Anchored"):Connect(function()
			self:RemoveObjectShake(part)
		end)
	}
	self:UpdateObjectSettings(part, p)
	bindableEvent:Fire(part)
end

function WindShake:RemoveObjectShake(part)
	if typeof(part) ~= "Instance" then
		return
	end

	local objectMetadata = self.ObjectMetadata
	local v2 = objectMetadata[part]

	if v2 then
		self.Handled -= 1
		objectMetadata[part] = nil
		v2.Settings:Destroy()
		v2.Node:Destroy()
		v2.Remover:Disconnect()

		if part:IsA("BasePart") then
			part.CFrame = v2.Origin
		end
	end

	bindableEvent2:Fire(part)
end

function WindShake.Update(state)
	local now = os.clock()
	local v2 = now - state.LastUpdate

	if not (v2 < 0.04) then
		local Global = require(game.ReplicatedStorage.Global)

		if not Global.FastMode then
			state.LastUpdate = now
			debug.profilebegin("WindShake")
			local currentCamera = workspace.CurrentCamera
			local cFrame = currentCamera and currentCamera.CFrame
			debug.profilebegin("Octree Search")
			local radiusSearch = state.Octree:RadiusSearch(cFrame.Position + cFrame.LookVector * 115, 120)
			debug.profileend()
			local count = #radiusSearch
			state.Active = count

			if count < 1 then
				return
			end

			local v3 = math.min(1, v2 * 8)
			local values = table.create(count)
			local objectMetadata = state.ObjectMetadata
			debug.profilebegin("Calc")

			for i, v4 in ipairs(radiusSearch) do
				local v5 = objectMetadata[v4]
				local lastCompute = v5.LastCompute or 0
				local origin = v5.Origin
				local cFrame2 = v5.CFrame or origin

				if now - lastCompute > 0.06666666666666667 then
					local settings = v5.Settings
					local seed = v5.Seed
					local v6 = settings.WindPower * 0.1
					local v7 = now * (settings.WindSpeed * 0.08)
					local v8 = math.noise(v7, 0, seed) * v6
					local v9 = math.noise(v7, 0, -seed) * v6
					local v10 = math.noise(v7, 0, seed + seed) * v6
					local pivotOffset = v4.PivotOffset
					v5.Target = (origin * pivotOffset * CFrame.Angles(v8, v9, v10) + settings.WindDirection * ((0.5 + math.noise(
						v7,
						seed,
						seed
					)) * v6)) * pivotOffset:Inverse()
					v5.LastCompute = now
				end

				local lerped = cFrame2:Lerp(v5.Target, v3)
				v5.CFrame = lerped
				values[i] = lerped
			end

			debug.profileend()
			workspace:BulkMoveTo(radiusSearch, values, Enum.BulkMoveMode.FireCFrameChanged)
			debug.profileend()
		end
	end
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

function WindShake:Init()
	if self.Initialized then
		return
	end

	self.Initialized = true
	local windPower = script:GetAttribute("WindPower")
	local windSpeed = script:GetAttribute("WindSpeed")
	local windDirection = script:GetAttribute("WindDirection")

	if typeof(windPower) ~= "number" then
		script:SetAttribute("WindPower", v.WindPower)
	end

	if typeof(windSpeed) ~= "number" then
		script:SetAttribute("WindSpeed", v.WindSpeed)
	end

	if typeof(windDirection) ~= "Vector3" then
		script:SetAttribute("WindDirection", v.WindDirection)
	end

	self:Cleanup()
	self.AddedConnection = self:Connect("AddObjectShake", (CollectionService:GetInstanceAddedSignal("WindShake")))
	self.RemovedConnection = self:Connect(
		"RemoveObjectShake",
		(CollectionService:GetInstanceRemovedSignal("WindShake"))
	)

	for _, v2 in pairs(CollectionService:GetTagged("WindShake")) do
		self:AddObjectShake(v2)
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

	table.clear(self.ObjectMetadata)
	self.Octree:ClearNodes()
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

	bindableEvent3:Fire(instance)
end

function WindShake.UpdateAllObjectSettings(p, items)
	if typeof(items) ~= "table" then
		return
	end

	for k, _ in pairs(p.ObjectMetadata) do
		for k2, item in pairs(items) do
			k:SetAttribute(k2, item)
		end

		bindableEvent3:Fire(k)
	end
end

function WindShake:SetDefaultSettings(p)
	self:UpdateObjectSettings(script, p)
end

return WindShake