require(script.Parent.FayeTypes)
local simplesignal = require(script.Parent.Parent.simplesignal)
local FayeUtility = require(script.Parent.Misc.FayeUtility)
local ValueBase = require(script.Parent.Misc.ValueBase)
local ValueClasses = require(script.Parent.Misc.ValueClasses)
local name = script.Name
local v = {
	__type = name
}
v.__index = v

function v:Destroy()
	local thread = self.Thread

	if thread ~= nil then
		if thread.Remove then
			thread:Remove(self)
		else
			local v2 = FayeUtility.tf(thread, self)

			if v2 ~= nil then
				FayeUtility.tr(thread, v2)
			end
		end

		self.Thread = nil
	end

	if self.Changed ~= nil then
		self.Changed:Destroy()
		self.Changed = nil
	end

	if self.Connection ~= nil and self.Connection.Disconnect ~= nil then
		self.Connection:Disconnect()
		self.Connection = nil
	end

	if self.Custom ~= nil then
		FayeUtility.tc(self.Custom)
		self.Custom = nil
	end
end

function v.Add(p, p2)
	if p.valueIsValue then
		p.Value:Add(p2)
	else
		ValueBase.Add(p, p2)
	end
end

function v.Remove(p, p2)
	if p.valueIsValue then
		p.Value:Remove(p2)
	else
		ValueBase.Remove(p, p2)
	end
end

function v:__sub(p)
	if p == nil then
		return self
	end

	self:Remove(p)
	return self
end

function v:__add(p)
	if p == nil then
		return self
	end

	self:Add(p)
	return self
end

function v:SetTime(time: number)
	if time ~= nil and FayeUtility.tof(time) ~= "number" then
		return self
	end

	self.Time = time
	return self
end

function v:For(p2, p3: number?)
	if self.Custom == nil then
		self.Custom = {}
	end

	self.Custom[p2] = p3
	self.IsSensitive = true
	return self
end

function v:Get()
	if self.Value == nil then
		return
	end

	if self.valueIsValue then
		return self.Value:Get()
	end

	return self.Value
end

function setValue(state, object, flag: boolean?)
	if state.Connection ~= nil and state.Connection.Disconnect ~= nil then
		state.Connection:Disconnect()
		state.Connection = nil
	end

	state.ValueType = FayeUtility.tof(object)
	local v2 = state.ValueType == "table"
	state.valueIsValue = v2 and ValueClasses[object.__type]
	state.Value = object

	local function CallSignal(p, flag2: boolean?)
		if state.SignalEnabled == false then
			return
		end

		state.curentUsageId += 1
		local curentUsageId = state.curentUsageId
		local time = state.Time

		if p ~= nil and state.Custom ~= nil and state.Custom[p] ~= nil then
			time = state.Custom[p]
		end

		if time ~= nil and time ~= 0 and flag2 == nil then
			if not state.IsActive then
				return
			end

			task.wait(time)

			if not state.IsActive then
				return
			end
		end

		if (state.IsSensitive == nil or curentUsageId == state.curentUsageId) and state.Changed ~= nil then
			state.Changed:Fire(p)
		end
	end

	if v2 and state.valueIsValue then
		local v3 = object:Get()

		if flag == nil then
			task.spawn(CallSignal, v3)
		else
			CallSignal(v3, true)
		end

		state.Connection = object.Changed:Connect(function(p)
			CallSignal(p)
		end)
		return v3
	else
		if flag == nil then
			task.spawn(CallSignal, object)
		else
			CallSignal(object, true)
		end

		return object
	end
end

function v.Set(p, p2)
	setValue(p, p2)
	return p
end

function v:Refresh()
	if self.Value == nil then
		return
	end

	if self.SignalEnabled == nil or self.SignalEnabled == true then
		self.Value.Changed:Fire(self:Get())
	end
end

function v:SetSignalEnabled(signalEnabled: boolean)
	self.SignalEnabled = signalEnabled
end

function v:Sensitive()
	self.IsSensitive = true
	return self
end

function v:ResetTime()
	self.Time = self.DefaultTime
end

local count = 0
local name2 = script.Name

function v.__tostring()
	return name2
end

return function(p, p2: number, thread)
	count += 1
	local v2 = {
		Thread = thread,
		Connection = nil,
		Value = p,
		curentUsageId = 0,
		DefaultTime = p2,
		Time = p2,
		Id = name .. count,
		IsActive = true,
		Changed = simplesignal.new()
	}
	setmetatable(v2, v)
	v2.Initial = setValue(v2, p, true)

	if thread ~= nil then
		FayeUtility.AddToThread(thread, v2)
	end

	return v2
end