local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollisionGroups = require(ReplicatedStorage.Shared.Types.CollisionGroups)
local t = require(ReplicatedStorage.Packages.t)
local strict = t.strict(t.table)
local strict2 = t.strict(t.Vector2)
local strict3 = t.strict(t.number)
local strict4 = t.strict(t.string)
local strict5 = t.strict(t.instanceIsA("Model"))
local raycastParams = RaycastParams.new()
raycastParams.CollisionGroup = CollisionGroups.PLAYER_COLLISION_GROUP
raycastParams.IgnoreWater = true
return {
	KeyUnderCursor = function(items, point: Vector2, p: number)
		strict(items)
		strict2(point)
		strict3(p)
		assert(p > 0, "a hover probe with no reach can never touch anything")
		local currentCamera = workspace.CurrentCamera
		local v = currentCamera and currentCamera:ViewportPointToRay(point.X, point.Y)
		local raycastResult = v and workspace:Raycast(v.Origin, v.Direction * p, raycastParams)

		if not raycastResult then
			return nil
		end

		for k, ancestor in pairs(items) do
			strict4(k)
			strict5(ancestor)

			if ancestor.Parent and raycastResult.Instance:IsDescendantOf(ancestor) then
				return k
			end
		end

		return nil
	end
}