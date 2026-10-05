local PhysicsService = game:GetService("PhysicsService")
local Config = require(script.Parent.Config)

-- equivalent calls inferred from this helper; original call sites unknown
local function isCollidableGroup(p: string)
	return table.find(Config.chaserCollidableGroups, p) ~= nil
end

local Collision = {
	configure = function()
		if not PhysicsService:IsCollisionGroupRegistered(Config.chaserCollisionGroup) then
			PhysicsService:RegisterCollisionGroup(Config.chaserCollisionGroup)
		end

		for _, v in PhysicsService:GetRegisteredCollisionGroups() do
			PhysicsService:CollisionGroupSetCollidable(Config.chaserCollisionGroup, v.name, isCollidableGroup(v.name))
		end
	end
}

function Collision.apply(folder)
	Collision.configure()

	for _, part in folder:GetDescendants() do
		if part:IsA("BasePart") then
			part.CollisionGroup = Config.chaserCollisionGroup
		end
	end
end

return Collision