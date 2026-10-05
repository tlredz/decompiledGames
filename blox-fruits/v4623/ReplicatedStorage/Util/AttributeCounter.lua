local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local AttributeCounter = {}
local v = RunService:IsServer() and "Server" or "Client"

-- equivalent calls inferred from this helper; original call sites unknown
local function validateArguments(instance, value: string)
	local v2

	if typeof(instance) == "Instance" then
		v2 = typeof(value) == "string"
	else
		v2 = false
	end

	assert(v2)
end

local function readCounter(instance, attributeName: string)
	local attribute = instance:GetAttribute(attributeName)

	if attribute == nil then
		return 0
	end

	if typeof(attribute) ~= "number" then
		error(`{instance:GetFullName()}.{attributeName} must be a number`, 3)
	end

	return attribute
end

function AttributeCounter.get(instance, value: string)
	validateArguments(instance, value) -- equivalent call inferred; original call site unknown
	local v2 = value .. "Server"
	local attribute = instance:GetAttribute(v2)

	if attribute == nil then
		attribute = 0
	elseif typeof(attribute) ~= "number" then
		error(`{instance:GetFullName()}.{v2} must be a number`, 3)
	end

	local v3 = value .. "Client"
	local attribute2 = instance:GetAttribute(v3)

	if attribute2 == nil then
		attribute2 = 0
	elseif typeof(attribute2) ~= "number" then
		error(`{instance:GetFullName()}.{v3} must be a number`, 3)
	end

	return attribute + attribute2
end

function AttributeCounter.active(p, p2: string)
	return AttributeCounter.get(p, p2) > 0
end

function AttributeCounter.add(instance, value: string)
	validateArguments(instance, value) -- equivalent call inferred; original call site unknown
	local v2 = value .. v
	local attribute = instance:GetAttribute(v2)

	if attribute == nil then
		attribute = 0
	elseif typeof(attribute) ~= "number" then
		error(`{instance:GetFullName()}.{v2} must be a number`, 3)
	end

	instance:SetAttribute(v2, attribute + 1)
end

function AttributeCounter.remove(instance, value: string)
	validateArguments(instance, value) -- equivalent call inferred; original call site unknown
	local v2 = value .. v
	local attribute = instance:GetAttribute(v2)

	if attribute == nil then
		attribute = 0
	elseif typeof(attribute) ~= "number" then
		error(`{instance:GetFullName()}.{v2} must be a number`, 3)
	end

	if attribute <= 0 then
		return
	end

	instance:SetAttribute(v2, attribute - 1)
end

function AttributeCounter.anyInstanceLock(instance, value: string)
	validateArguments(instance, value) -- equivalent call inferred; original call site unknown
	return {
		locked = false,
		Lock = function(self)
			if not self.locked then
				AttributeCounter.add(instance, value)
				self.locked = true
			end
		end,
		Unlock = function(self)
			if self.locked then
				AttributeCounter.remove(instance, value)
				self.locked = false
			end
		end,
		Get = function(self)
			return self.locked
		end
	}
end

function AttributeCounter.extendedLock(instance, items)
	local v2

	if typeof(instance) == "Instance" then
		v2 = typeof(items) == "table"
	else
		v2 = false
	end

	assert(v2)
	local v3 = {}

	for _, item in pairs(items) do
		assert(v3[item] == nil)
		v3[item] = AttributeCounter.anyInstanceLock(instance, item)
	end

	return {
		Get = function(self)
			for _, v4 in pairs(v3) do
				if v4:Get() then
					return true
				end
			end

			return false
		end,
		Lock = function(self)
			for _, v4 in pairs(v3) do
				v4:Lock()
			end
		end,
		Unlock = function(self)
			for _, v4 in pairs(v3) do
				v4:Unlock()
			end
		end
	}
end

function AttributeCounter.destroyable(instance, value: string)
	validateArguments(instance, value) -- equivalent call inferred; original call site unknown
	AttributeCounter.add(instance, value)
	return {
		destroyed = false,
		Destroy = function(p)
			if not p.destroyed then
				AttributeCounter.remove(instance, value)
				p.destroyed = true
			end
		end
	}
end

function AttributeCounter.connect(humanoid, value: string, callback, flag: boolean?)
	validateArguments(humanoid, value) -- equivalent call inferred; original call site unknown
	assert(typeof(callback) == "function")
	local v2 = AttributeCounter.get(humanoid, value)
	local flag2 = false
	local connection = nil
	local connection2 = nil
	local diedConnection = nil
	local characterRemovingConnection = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function disconnectAll()
		if flag2 then
			return
		end

		flag2 = true

		if connection then
			connection:Disconnect()
			connection = nil
		end

		if connection2 then
			connection2:Disconnect()
			connection2 = nil
		end

		if diedConnection then
			diedConnection:Disconnect()
			diedConnection = nil
		end

		if characterRemovingConnection then
			characterRemovingConnection:Disconnect()
			characterRemovingConnection = nil
		end
	end

	local function update()
		if flag2 then
			return
		end

		local v3 = AttributeCounter.get(humanoid, value)
		local v4 = v3 ~= v2
		v2 = v3
		callback(v3, v4)
	end

	connection = humanoid:GetAttributeChangedSignal(value .. "Client"):Connect(update)
	connection2 = humanoid:GetAttributeChangedSignal(value .. "Server"):Connect(update)

	if humanoid:IsA("Humanoid") then
		local parent = humanoid.Parent
		diedConnection = humanoid.Died:Once(disconnectAll)
		local playerFromCharacter

		if parent and parent:IsA("Model") then
			playerFromCharacter = Players:GetPlayerFromCharacter(parent)
		end

		if playerFromCharacter and parent and parent:IsA("Model") then
			characterRemovingConnection = playerFromCharacter.CharacterRemoving:Connect(function(character)
				if character == parent then
					disconnectAll() -- equivalent call inferred; original call site unknown
				end
			end)
		end
	end

	local v3 = {
		Disconnect = function()
			if flag2 then
				return
			end

			flag2 = true

			if connection then
				connection:Disconnect()
				connection = nil
			end

			if connection2 then
				connection2:Disconnect()
				connection2 = nil
			end

			if diedConnection then
				diedConnection:Disconnect()
				diedConnection = nil
			end

			if characterRemovingConnection then
				characterRemovingConnection:Disconnect()
				characterRemovingConnection = nil
			end
		end
	}

	if not flag then
		return v3
	end

	local success, result = pcall(function()
		callback(v2, false)
		return true
	end)

	if not success then
		disconnectAll() -- equivalent call inferred; original call site unknown
		error(result, 0)
	end

	return v3
end

return AttributeCounter