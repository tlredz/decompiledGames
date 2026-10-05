error("This is not supposed to run!")
local class = {}
class.__index = class
local class2 = {}
class2.__index = class2

function class.new()
	return {}
end

function class.Is(_)
	return true
end

function class.IsActive(_)
	return true
end

function class.Connect(_, _) end

function class.Once(_, _) end

function class.Wait(_) end

function class.Fire(_, ...) end

function class.DisconnectAll(_) end

function class.Destroy(_) end

function class2.Disconnect(_) end

local Docs = {}

function Docs.new()
	return class.new()
end

function Docs.Is(_)
	return true
end

return Docs