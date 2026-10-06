local RunService = game:GetService("RunService")
local v = {}
local v2 = {}
local v3 = {}
local isServer = RunService:IsServer()
local isClient = RunService:IsClient()
local v4 = {}
local ValueToInstance

ValueToInstance = function(name: string, items)
	if items == nil then
		return
	end

	local typeName = typeof(items)

	if typeName == "number" then
		local numberValue = Instance.new("NumberValue")
		numberValue.Name = name
		numberValue.Value = items
		return numberValue
	elseif typeName == "string" then
		local stringValue = Instance.new("StringValue")
		stringValue.Name = name
		stringValue.Value = items
		return stringValue
	elseif typeName == "boolean" then
		local boolValue = Instance.new("BoolValue")
		boolValue.Name = name
		boolValue.Value = items
		return boolValue
	elseif typeName == "Instance" then
		local objectValue = Instance.new("ObjectValue")
		objectValue.Name = name
		objectValue.Value = items
		return objectValue
	elseif typeName == "Vector3" then
		local vector3Value = Instance.new("Vector3Value")
		vector3Value.Name = name
		vector3Value.Value = items
		return vector3Value
	elseif typeName == "CFrame" then
		local cFrameValue = Instance.new("CFrameValue")
		cFrameValue.Name = name
		cFrameValue.Value = items
		return cFrameValue
	elseif typeName == "Color3" then
		local color3Value = Instance.new("Color3Value")
		color3Value.Name = name
		color3Value.Value = items
		return color3Value
	elseif typeName == "BrickColor" then
		local brickColorValue = Instance.new("BrickColorValue")
		brickColorValue.Name = name
		brickColorValue.Value = items
		return brickColorValue
	else
		if typeName ~= "table" then
			return nil
		end

		local configuration = Instance.new("Configuration")
		configuration.Name = name

		for k, item in items do
			local valueToInstance = ValueToInstance(k, item)

			if valueToInstance then
				valueToInstance.Parent = configuration
			end
		end

		return configuration
	end
end

function InstanceToValue(instance, flag: boolean)
	if not instance or typeof(instance) ~= "Instance" then
		return
	end

	local value = nil
	local className = instance.ClassName

	if className == "NumberValue" then
		value = instance.Value
	elseif className == "StringValue" then
		value = instance.Value
	elseif className == "BoolValue" then
		value = instance.Value
	elseif className == "ObjectValue" then
		value = instance.Value
	elseif className == "Vector3Value" then
		value = instance.Value
	elseif className == "CFrameValue" then
		value = instance.Value
	elseif className == "Color3Value" then
		value = instance.Value
	elseif className == "BrickColorValue" then
		value = instance.Value
	elseif className == "Configuration" then
		value = {}

		for _, child in instance:GetChildren() do
			local v5 = InstanceToValue(child, false)

			if v5 then
				value[child.Name] = v5
			end
		end
	end

	if flag then
		return {
			Time = instance:GetAttribute("Time"),
			Value = value,
			Delay = instance:GetAttribute("Delay"),
			Duration = instance:GetAttribute("Duration")
		}
	end

	return value
end

local function CreateManagerForClient(instance)
	if v[instance] then
		return v[instance]
	end

	local folder2 = nil

	for _, folder in instance:GetChildren() do
		if not (folder.Name == "StateManager" and folder:IsA("Folder")) then
			continue
		end

		folder2 = folder
		break
	end

	if not folder2 then
		return
	end

	local object = setmetatable({}, {
		__index = v3
	})
	object.Instance = instance
	object.Folder = folder2
	object.Connections = {}
	object.Connections.Destroyed = instance.AncestryChanged:Connect(function(_, parent)
		if not (instance and parent) then
			object:Destroy()
		end
	end)
	object.Connections.StateAdded = folder2.ChildAdded:Connect(function(child)
		local name = child.Name
		local v7 = v2[name]

		if v7 then
			local state = object:GetState(name)

			for _, v8 in v7 do
				v8(object.Instance, object, state)
			end
		end
	end)
	object.Connections.StateRemoved = folder2.ChildRemoved:Connect(function(child)
		local name = child.Name
		local v7 = v2[name]

		if v7 then
			local state = object:GetState(name)

			for _, v8 in v7 do
				v8(object.Instance, object, state)
			end
		end
	end)
	v[instance] = object
	return object
end

function v4.New(p)
	if isClient then
		return CreateManagerForClient(p.Object)
	end

	if not p or typeof(p) ~= "table" or not (p.Object and p.Object:IsA("Instance")) then
		return
	end

	local folder = Instance.new("Folder")
	folder.Name = "StateManager"
	folder.Parent = p.Object

	if p.Tags and typeof(p.Tags) == "table" then
		for _, tag in p.Tags do
			if tag and typeof(tag) == "string" then
				p.Object:AddTag(tag)
			end
		end
	end

	local object = setmetatable({}, {
		__index = v3
	})
	object.Instance = p.Object
	object.Folder = folder
	object.LastCleanup = 0
	object.Connections = {}
	object.Connections.Destroyed = p.Object.AncestryChanged:Connect(function(_, parent)
		if not (p.Object and parent) then
			object:Destroy()
		end
	end)
	v[p.Object] = object
	return object
end

function v4.Get(instance)
	if instance and instance:IsA("Instance") then
		if isClient then
			return CreateManagerForClient(instance)
		end

		return v[instance]
	end
end

function v4.MonitorateState(value: string, callback)
	if not value or typeof(value) ~= "string" or (not callback or typeof(callback) ~= "function") then
		return
	end

	if not v2[value] then
		v2[value] = {}
	end

	table.insert(v2[value], callback)
end

function v3:SetState(data)
	if isClient or (not data or typeof(data) ~= "table") then
		return
	end

	if not data.State or typeof(data.State) ~= "string" then
		return
	end

	local serverTimeNow = workspace:GetServerTimeNow()
	local delay

	if typeof(data.Delay) == "number" then
		delay = data.Delay or nil
	end

	local duration

	if typeof(data.Duration) == "number" then
		duration = data.Duration or nil
	end

	local child = self.Folder:FindFirstChild(data.State)

	if child then
		child:Destroy()
	end

	if data.Value == nil then
		local v5 = v2[data.State]

		if v5 then
			for _, v6 in v5 do
				v6(self.Instance, self, data.Value)
			end
		end
	else
		local valueToInstance = ValueToInstance(data.State, data.Value)

		if not valueToInstance then
			return
		end

		if delay then
			valueToInstance:SetAttribute("Delay", delay)
		end

		if duration then
			valueToInstance:SetAttribute("Duration", duration)
		end

		valueToInstance:SetAttribute("Time", serverTimeNow)
		valueToInstance.Parent = self.Folder
		local v6 = {
			Value = data.Value,
			Delay = delay,
			Duration = duration,
			Time = serverTimeNow
		}
		local v7 = v2[data.State]

		if v7 then
			for _, v8 in v7 do
				v8(self.Instance, self, data.Value)
			end
		end

		return v6
	end
end

function v3:IncrementState(state2: string, value2: number)
	if isClient or (not state2 or typeof(state2) ~= "string") then
		return
	end

	if not value2 or typeof(value2) ~= "number" then
		return
	end

	local state = self:GetState(state2)

	if not state or typeof(state) ~= "number" then
		return
	end

	self:SetState({
		State = state2,
		Value = state + value2
	})
	return state + value2
end

function v3:GetState(childName: string)
	if not childName or typeof(childName) ~= "string" then
		return
	end

	local child = self.Folder:FindFirstChild(childName)

	if not child then
		return
	end

	local v5 = InstanceToValue(child, true)

	if not v5 then
		return
	end

	local v6 = workspace:GetServerTimeNow() - v5.Time
	local value = v5.Value

	if v5.Delay and v6 < v5.Delay then
		return
	end

	if v5.Duration and v5.Duration < v6 then
		return
	else
		return value
	end
end

function v3:GetAllStates()
	local statesByName = {}

	for _, child in self.Folder:GetChildren() do
		local name = child.Name
		statesByName[name] = self:GetState(name)
	end

	return statesByName
end

function v3:OnStateChanged(value: string, callback)
	if not value or typeof(value) ~= "string" or (not callback or typeof(callback) ~= "function") then
		return
	end

	local childAddedConnection = self.Folder.ChildAdded:Connect(function(child)
		if child.Name ~= value then
			return
		end

		callback(self:GetState(value))
	end)
	local childRemovedConnection = self.Folder.ChildRemoved:Connect(function(child)
		if child.Name ~= value then
			return
		end

		callback(nil)
	end)
	return {
		Disconnect = function()
			childAddedConnection:Disconnect()
			childRemovedConnection:Disconnect()
		end
	}
end

function v3:Clean()
	if isClient then
		return
	end

	local serverTimeNow = workspace:GetServerTimeNow()

	for _, child in self.Folder:GetChildren() do
		local duration = child:GetAttribute("Duration")

		if not duration then
			continue
		end

		local time = child:GetAttribute("Time")

		if not time then
			continue
		end

		local delay = child:GetAttribute("Delay")
		local v5 = serverTimeNow - time

		if delay then
			v5 -= delay
		end

		if duration <= v5 then
			child:Destroy()
		end
	end
end

function v3:Destroy()
	if not self then
		return
	end

	for _, connection in self.Connections do
		connection:Disconnect()
	end

	table.clear(self.Connections)
	v[self.Instance] = nil
	setmetatable(self, nil)
end

if isServer then
	RunService.Heartbeat:Connect(function()
		local now = tick()

		for _, v5 in v do
			if now - v5.LastCleanup < 1 then
				continue
			end

			v5.LastCleanup = now
			v5:Clean()
		end
	end)
end

return table.freeze(v4)