local ReplicatedStorage = game:GetService("ReplicatedStorage")
local module = require("./AttributeSignal")
local v = {
	string = true,
	boolean = true,
	number = true,
	UDim = true,
	UDim2 = true,
	BrickColor = true,
	Color3 = true,
	Vector2 = true,
	Vector3 = true,
	CFrame = true,
	NumberSequence = true,
	ColorSequence = true,
	NumberRange = true,
	Rect = true,
	Font = true
}
local restreamAttributesEvent = nil
local class = {}
class.__index = class
local v2 = {}

function class:SetAttribute(p: string, p2)
	if not v[typeof(p)] then
		error((`invalid attribute value type for instance {self._inst:GetFullName()}`))
	end

	if self._attr[p] ~= p2 then
		self._attr[p] = p2

		if self._signals[p] then
			self._signals[p]:Fire()
		end
	end
end

function class:GetAttribute(p2: string)
	return self._attr[p2]
end

function class:GetAttributeAsync(p: string)
	if self._attr[p] then
		return self._attr[p]
	end

	local thread = coroutine.running()
	local v3 = nil
	v3 = self:OnAttributeChanged(p, function()
		v3()
		task.spawn(thread, self._attr[p])
	end)
	return coroutine.yield()
end

function class:GetAttributes()
	return table.clone(self._attr)
end

function class:OnAttributeChanged(p2: string, callback)
	if not self._signals[p2] then
		self._signals[p2] = module.new()
	end

	local _signal = self._signals[p2]
	local connection = _signal:Connect(callback)
	return function()
		connection:Disconnect()

		if not _signal:HasConnection() then
			self._signals[p2] = nil
		end
	end
end

function class:Destroy()
	if v2[self._inst] == self then
		v2[self._inst] = nil
	end
end

local AttributeAPI = {
	container = function(instance)
		assert(typeof(instance) == "Instance", (`invalid argument #1 got {typeof(instance)} expected Instance`))

		if v2[instance] then
			return v2[instance]
		end

		local v3 = nil
		v3 = setmetatable({
			_attr = {},
			_signals = {},
			_inst = instance,
			_destroyingConnection = instance.Destroying:Connect(function()
				if v2[instance] == v3 then
					v2[instance] = nil
				end
			end)
		}, class)
		v2[instance] = v3

		if restreamAttributesEvent then
			restreamAttributesEvent:FireServer(instance)
		end

		return v3
	end
}
local v3 = module.new()

function AttributeAPI.waitUntilReady()
	return v3:Wait()
end

task.spawn(function()
	local __AttributeAPIInternal = ReplicatedStorage:WaitForChild("__AttributeAPIInternal", 1e999)
	local attributeChangedEvent = __AttributeAPIInternal:WaitForChild("attributeChangedEvent")
	local batchAttributesChangedEvent = __AttributeAPIInternal:WaitForChild("batchAttributesChangedEvent")
	local sendInitialAttributesEvent = __AttributeAPIInternal:WaitForChild("sendInitialAttributesEvent")
	restreamAttributesEvent = __AttributeAPIInternal:WaitForChild("restreamAttributesEvent")

	for k in next, v2, nil do
		restreamAttributesEvent:FireServer(k)
	end

	attributeChangedEvent.OnClientEvent:Connect(function(p, p2, p3)
		local v4 = v2[p]

		if not v4 then
			return
		end

		if v4._attr[p2] ~= p3 then
			v4._attr[p2] = p3

			if v4._signals[p2] then
				v4._signals[p2]:Fire()
			end
		end
	end)
	batchAttributesChangedEvent.OnClientEvent:Connect(function(p, items)
		local v4 = v2[p]

		if not v4 then
			return
		end

		for k, item in items do
			if v4._attr[k] == item then
				continue
			end

			v4._attr[k] = item

			if v4._signals[k] then
				v4._signals[k]:Fire()
			end
		end
	end)
	sendInitialAttributesEvent.OnClientEvent:Connect(function(items)
		for _, item in items do
			local attr = item[1]
			local v5 = item[2]

			if not v5 then
				continue
			end

			if v2[v5] then
				local v6 = v2[v5]

				for k, v7 in attr do
					if v6._attr[k] == v7 then
						continue
					end

					v6._attr[k] = v7

					if v6._signals[k] then
						v6._signals[k]:Fire()
					end
				end
			else
				local container = AttributeAPI.container(v5)
				container._attr = attr
				v2[v5] = container

				for _, _signal in container._signals do
					_signal:Fire()
				end
			end
		end

		v3:Fire()
	end)
	v3:Fire()
end)
return AttributeAPI