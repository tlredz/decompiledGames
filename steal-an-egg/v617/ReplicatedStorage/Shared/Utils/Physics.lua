local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)
local v = {
	{
		name = "Massless",
		value = true
	},
	{
		name = "CanTouch",
		value = false
	},
	{
		name = "CanCollide",
		value = false
	}
}

local function eachPart(folder, fn)
	for _, part in folder:GetDescendants() do
		if part:IsA("BasePart") then
			fn(part)
		end
	end
end

return table.freeze({
	SetAnchored = function(p, anchored: boolean)
		t.strict(t.instanceIsA("Model"))(p)
		t.strict(t.boolean)(anchored)
		eachPart(p, function(p2)
			p2.Anchored = anchored
		end)
	end,
	DisableAllPhysics = function(p, flag: boolean?)
		t.strict(t.Instance)(p)
		t.strict(t.optional(t.boolean))(flag)
		local canQuery = flag == true
		eachPart(p, function(p2)
			for _, v4 in v do
				p2[v4.name] = v4.value
			end

			p2.CanQuery = canQuery
		end)
	end,
	SetCollisionGroup = function(p, collisionGroup: string)
		t.strict(t.instanceIsA("Model"))(p)
		t.strict(t.string)(collisionGroup)
		eachPart(p, function(p2)
			p2.CollisionGroup = collisionGroup
		end)
	end
})