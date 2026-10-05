local ValueBase = {}
ValueBase.__index = ValueBase
local FayeUtility = require(script.Parent.FayeUtility)
local TypeActions = require(script.Parent.TypeActions)
local PropertyActions = require(script.Parent.PropertyActions)
local ValueClasses = require(script.Parent.ValueClasses)

function ValueBase.__tostring()
	return "Value"
end

function ValueBase:__sub(p)
	if p == nil then
		return self
	end

	self:Remove(p)
	return self
end

function ValueBase:__add(p)
	if p == nil then
		return self
	end

	self:Add(p)
	return self
end

function ValueBase.Remove(data, p, ...)
	if data.IsProperty then
		if data.Instance ~= nil and data.Property ~= nil then
			if data.IsAttribute then
				local attribute = data.Instance:GetAttribute(data.Property)

				if attribute == nil then
					data.Instance:SetAttribute(data.Property, p)
					return
				end

				local tof = FayeUtility.tof(attribute)

				if PropertyActions.Attributes[tof] and tof == FayeUtility.tof(p) and PropertyActions.Attributes[tof].Remove ~= nil then
					PropertyActions.Attributes[tof].Remove(data.Instance, data.Property, p)
				end
			else
				local v = data.Instance[data.Property]
				local tof = FayeUtility.tof(v)

				if PropertyActions.Property[tof] and tof == FayeUtility.tof(p) and PropertyActions.Property[tof].Remove ~= nil then
					PropertyActions.Property[tof].Remove(data.Instance, data.Property, p)
				end
			end
		end
	else
		local tof = FayeUtility.tof(p)

		if data.ValueType == "table" or data.ValueType == tof then
			if TypeActions[data.ValueType] ~= nil and TypeActions[data.ValueType].Remove ~= nil then
				TypeActions[data.ValueType].Remove(data, p, ...)
			end
		else
			warn((`Type mismatch for removing - {debug.traceback()}`))
		end
	end
end

function ValueBase.Add(data, p, ...)
	if data.IsProperty then
		if data.Instance ~= nil and data.Property ~= nil then
			if data.IsAttribute then
				local attribute = data.Instance:GetAttribute(data.Property)

				if attribute == nil then
					data.Instance:SetAttribute(data.Property, p)
					return
				end

				local tof = FayeUtility.tof(attribute)

				if PropertyActions.Attributes[tof] and tof == FayeUtility.tof(p) and PropertyActions.Attributes[tof].Add ~= nil then
					PropertyActions.Attributes[tof].Add(data.Instance, data.Property, p)
				end
			else
				local v = data.Instance[data.Property]
				local tof = FayeUtility.tof(v)

				if PropertyActions.Property[tof] and tof == FayeUtility.tof(p) and PropertyActions.Property[tof].Add ~= nil then
					PropertyActions.Property[tof].Add(data.Instance, data.Property, p)
				end
			end
		end
	else
		local tof = FayeUtility.tof(p)

		if data.ValueType == "table" or data.ValueType == tof then
			if TypeActions[data.ValueType] ~= nil and TypeActions[data.ValueType].Add ~= nil then
				TypeActions[data.ValueType].Add(data, p, ...)
			end
		else
			warn((`Type mismatch for adding - {debug.traceback()}`))
		end
	end
end

function ValueBase:SetSignalEnabled(signalEnabled: boolean)
	self.SignalEnabled = signalEnabled
end

function ValueBase:Refresh()
	if self.SignalEnabled == nil or self.SignalEnabled == true then
		self.Changed:Fire(self:Get())
	end
end

function ValueBase:Reset()
	if self.IsProperty then
		if self.Instance ~= nil and self.Property ~= nil then
			if self.IsAttribute then
				self.Instance:SetAttribute(self.Property, self.Initial)
				return self.Initial
			end

			self.Instance[self.Property] = self.Initial
			return self.Initial
		end
	elseif self.Value ~= self.Initial then
		self:Set(self.Initial)
	end
end

function ValueBase.Compare(data, p)
	if not data.IsProperty then
		return data.Value == p
	end

	if data.Instance == nil or data.Property == nil then
		return
	end

	if data.IsAttribute then
		return data.Instance:GetAttribute(data.Property) == p
	end

	return data.Instance[data.Property] == p
end

function ValueBase.GetItem(p, p2)
	if p2 == nil then
		return
	end

	if p.ValueTypeIsTable then
		return p.Value[p2]
	end

	return nil
end

function ValueBase.ItemExists(p, p2)
	if p2 == nil then
		return false
	end

	if p.ValueTypeIsTable then
		return p.Value[p2] ~= nil or table.find(p.Value, p2) ~= nil
	end

	return false
end

function ValueBase:Get()
	if self.IsProperty then
		if self.Instance == nil or self.Property == nil then
			return
		end

		if self.IsAttribute then
			return self.Instance:GetAttribute(self.Property)
		end

		return self.Instance[self.Property]
	else
		if not self.ValueTypeIsTable or self.Value == nil then
			return self.Value
		end

		if self.Value.__type == FayeUtility.instanceTxt then
			return self.Value.Instance
		end

		if ValueClasses[self.Value.__type] then
			return self.Value:Get()
		end

		return self.Value
	end
end

function ValueBase:Set(p, flag: boolean?)
	if self.IsProperty then
		if self.Instance ~= nil and self.Property ~= nil then
			if self.IsAttribute then
				self.Instance:SetAttribute(self.Property, p)
				return p
			end

			local tof = FayeUtility.tof(self.Instance[self.Property])
			local tof2 = FayeUtility.tof(p)

			if tof == tof2 or (tof == "Instance" or tof == "nil") and (tof2 == "Instance" or tof2 == "nil") or (tof == "number" or tof == "string") and (tof2 == "number" or tof2 == "string") then
				self.Instance[self.Property] = p
				return p
			end
		end
	else
		if self.Value == p then
			return
		end

		self.Value = p
		self.ValueType = FayeUtility.tof(p)
		self.ValueTypeIsTable = self.ValueType == FayeUtility.tabletxt

		if self.SignalEnabled ~= true and self.SignalEnabled ~= nil or self.Changed == nil then
			return p
		end

		if flag then
			self.Changed:BasicFire(p)
			return p
		else
			self.Changed:Fire(p)
		end

		return p
	end
end

function ValueBase:ReCalibrate(instance, property: string?)
	if self.IsProperty then
		if instance == nil or property == nil then
			return
		end

		if instance ~= nil then
			self.Instance = instance
		end

		if property ~= nil then
			self.Property = property
		end

		if self.Instance == nil or self.Property == nil then
			return
		end

		if self.ChangeListener ~= nil then
			self.ChangeListener:Disconnect()
			self.ChangeListener = nil
		end

		if self.IsAttribute == nil then
			self.Initial = self.Instance[self.Property]
			self.ChangeListener = self.Instance:GetPropertyChangedSignal(self.Property):Connect(function()
				if (self.SignalEnabled == nil or self.SignalEnabled == true) and self.Changed ~= nil then
					self.Changed:Fire(self.Instance[self.Property])
				end
			end)
		else
			self.Initial = self.Instance:GetAttribute(self.Property)
			self.ChangeListener = self.Instance:GetAttributeChangedSignal(self.Property):Connect(function()
				if (self.SignalEnabled == nil or self.SignalEnabled == true) and self.Changed ~= nil then
					self.Changed:Fire(self.Instance:GetAttribute(self.Property))
				end
			end)
		end
	end
end

function ValueBase:Destroy()
	if self.Thread ~= nil then
		FayeUtility.RemoveFromThread(self.Thread, self)
		self.Thread = nil
	end

	if self.ChangeListener ~= nil then
		self.ChangeListener:Disconnect()
		self.ChangeListener = nil
	end

	if self.Changed ~= nil then
		self.Changed:Destroy()
		self.Changed = nil
	end
end

return ValueBase