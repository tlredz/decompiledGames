local FayeUtility = {
	tof = typeof,
	max = math.max,
	tr = table.remove,
	tf = table.find,
	tins = table.insert,
	tc = table.clear,
	tabletxt = "table",
	numbertxt = "number",
	instanceTxt = "Instance",
	valueBaseTxt = "ValueBase",
	functiontxt = "function"
}
require(script.Parent.Parent.FayeTypes)
local Clean = require(script.Parent.Parent.Clean)

function FayeUtility.RemoveFromThread(object, p)
	if object == nil or p == nil then
		return
	end

	if object.Remove then
		object:Remove(p)
		return
	end

	local v = FayeUtility.tf(object, p)

	if v ~= nil then
		FayeUtility.tr(object, v)
	end
end

function FayeUtility:ConnectToEntity(p, callback)
	if not (self ~= nil and self.Connect ~= nil) then
		return false
	end

	self:Connect(p, callback)
	return true
end

function FayeUtility.AddToEntity(object, p)
	if not (object ~= nil and object.Add) then
		return false
	end

	object:Add(p)
	return true
end

function FayeUtility.RemoveFromEntity(object, p)
	if object == nil or p == nil or not object.Remove then
		return false
	end

	object:Remove(p)
	return true
end

function FayeUtility:Connect(callback, object2)
	if self == nil or callback == nil then
		return
	end

	local connection = self:Connect(callback)

	if object2 == nil then
		connection:Connect(callback)
	elseif object2.Connect then
		object2:Connect(self, callback)
	elseif object2.Add then
		object2:Add(connection)
	else
		FayeUtility.tins(object2, connection)
	end
end

function FayeUtility.CallDestroy(instance)
	if instance == nil then
		return
	end

	if instance.Destroy then
		instance:Destroy()
	else
		Clean(instance)
	end
end

function FayeUtility.TableRemove(p, p2)
	if p == nil or p2 == nil then
		return
	end

	local v = FayeUtility.tf(p, p2)

	if v ~= nil then
		FayeUtility.tr(p, v)
	end
end

function FayeUtility.AddToThread(object, p)
	if object == nil or p == nil then
		return
	end

	if object.Add then
		object:Add(p)
	else
		FayeUtility.tins(object, p)
	end
end

function FayeUtility:ClearAllConnections(p: number?)
	for i = p or #self, 1, -1 do
		if self[i] ~= nil and self[i].Disconnect ~= nil then
			self[i]:Disconnect()
		end

		self[i] = nil
	end
end

local ValueClasses = require(script.Parent.ValueClasses)

function FayeUtility:GetValue()
	if self == nil then
		return
	end

	if FayeUtility.tof(self) == FayeUtility.tabletxt and self.__type ~= nil and ValueClasses[self.__type] then
		return FayeUtility.GetValue(self:Get())
	end

	return self
end

return FayeUtility