local Players = game:GetService("Players")
local RemoteSignal = require(script.Parent.RemoteSignal)
require(script.Parent.Parent.Types)
local Util = require(script.Parent.Parent.Util)
local none = Util.None
local RemoteProperty = {}
RemoteProperty.__index = RemoteProperty

function RemoteProperty.new(p, p2: string, p3, p4, p5)
	local object = setmetatable({}, RemoteProperty)
	object._rs = RemoteSignal.new(p, p2, false, p4, p5)
	object._value = p3
	object._perPlayer = {}
	object._playerRemoving = Players.PlayerRemoving:Connect(function(player)
		object._perPlayer[player] = nil
	end)
	object._rs:Connect(function(p6)
		local _value = object._perPlayer[p6]

		if _value == nil then
			_value = object._value
		elseif _value == none then
			_value = nil
		end

		object._rs:Fire(p6, _value)
	end)
	return object
end

function RemoteProperty:Set(p)
	self._value = p
	table.clear(self._perPlayer)
	self._rs:FireAll(p)
end

function RemoteProperty:SetTop(p)
	self._value = p

	for _, v in ipairs(Players:GetPlayers()) do
		if self._perPlayer[v] == nil then
			self._rs:Fire(v, p)
		end
	end
end

function RemoteProperty:SetFilter(callback, p)
	for _, v in ipairs(Players:GetPlayers()) do
		if callback(v, p) then
			self:SetFor(v, p)
		end
	end
end

function RemoteProperty:SetFor(p2, p3)
	if p2.Parent then
		local _perPlayer = self._perPlayer
		local v

		if p3 == nil then
			v = none
		else
			v = p3
		end

		_perPlayer[p2] = v
	end

	self._rs:Fire(p2, p3)
end

function RemoteProperty:SetForList(list, p)
	for _, v in ipairs(list) do
		self:SetFor(v, p)
	end
end

function RemoteProperty:ClearFor(p)
	if self._perPlayer[p] == nil then
		return
	end

	self._perPlayer[p] = nil
	self._rs:Fire(p, self._value)
end

function RemoteProperty:ClearForList(list)
	for _, v in ipairs(list) do
		self:ClearFor(v)
	end
end

function RemoteProperty:ClearFilter(callback)
	for _, v in ipairs(Players:GetPlayers()) do
		if callback(v) then
			self:ClearFor(v)
		end
	end
end

function RemoteProperty:Get()
	return self._value
end

function RemoteProperty:GetFor(p2)
	local v = self._perPlayer[p2]

	if v == nil then
		return self._value
	end

	if v == none then
		return nil
	end

	return v
end

function RemoteProperty:Destroy()
	self._rs:Destroy()
	self._playerRemoving:Disconnect()
end

return RemoteProperty