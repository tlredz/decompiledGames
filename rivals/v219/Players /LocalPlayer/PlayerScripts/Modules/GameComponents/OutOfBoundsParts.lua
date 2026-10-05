local ReplicatedStorage = game:GetService("ReplicatedStorage")
local OutOfBoundsMachine = require(ReplicatedStorage.Modules.OutOfBoundsMachine)
local object = setmetatable({}, OutOfBoundsMachine)
object.__index = object

function object._new()
	local self = setmetatable(OutOfBoundsMachine.new(nil, nil), object)
	self:_Init()
	return self
end

function object:_Init()
	self.Kill:Connect(function(p2, object2)
		local objectID = object2 and object2:Get("ObjectID") or nil
		ReplicatedStorage.Remotes.Replication.Fighter.OutOfBounds:FireServer(p2, objectID)
	end)
end

return object._new()