local PhysicsService = game:GetService("PhysicsService")

-- equivalent calls inferred from this helper; original call sites unknown
local function ensureRegistered(p: string)
	if not PhysicsService:IsCollisionGroupRegistered(p) then
		pcall(function()
			PhysicsService:RegisterCollisionGroup(p)
		end)
	end
end

local Collision = {}

function Collision.setup(p)
	ensureRegistered(p.npcCollisionGroup) -- equivalent call inferred; original call site unknown
	ensureRegistered(p.npcBarrierCollisionGroup) -- equivalent call inferred; original call site unknown
	pcall(function()
		if not PhysicsService:IsCollisionGroupRegistered("PlayersNoCollide") then
			local v = "PlayersNoCollide"
			pcall(function()
				PhysicsService:RegisterCollisionGroup(v)
			end)
		end

		PhysicsService:CollisionGroupSetCollidable(p.npcCollisionGroup, "PlayersNoCollide", false)
		PhysicsService:CollisionGroupSetCollidable(p.npcCollisionGroup, p.npcCollisionGroup, false)
	end)
	pcall(function()
		for _, v in PhysicsService:GetRegisteredCollisionGroups() do
			PhysicsService:CollisionGroupSetCollidable(p.npcBarrierCollisionGroup, v.name, false)
		end

		PhysicsService:CollisionGroupSetCollidable(p.npcBarrierCollisionGroup, p.npcCollisionGroup, true)
	end)
end

function Collision.applyNpc(folder, p)
	for _, part in folder:GetDescendants() do
		if part:IsA("BasePart") then
			part.CollisionGroup = p.npcCollisionGroup
		end
	end
end

function Collision.applyBarriers(folder, p)
	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.CollisionGroup = p.npcBarrierCollisionGroup
		part.CanCollide = true
	end
end

return Collision