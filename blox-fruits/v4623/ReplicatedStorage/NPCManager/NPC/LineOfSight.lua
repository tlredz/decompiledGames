local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.NPCManager.Types)
local localPlayer = Players.LocalPlayer
local object = setmetatable({}, {
	__mode = "k"
})
local v = nil
task.spawn(function()
	local success, rayMapCollidable = pcall(require, ReplicatedStorage.Util.RayMapCollidable)

	if success then
		v = rayMapCollidable
	else
		warn((`[NPCManager] line-of-sight dependency failed to load: {tostring(rayMapCollidable)}`))
	end
end)
local LineOfSight = {}

local function headPosition(instance, p: number)
	if not instance then
		return nil
	end

	local head = instance:FindFirstChild("Head")

	if head and head:IsA("BasePart") then
		return head.Position
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		return humanoidRootPart.Position + createVector(0, 1, 0) * p
	end

	return nil
end

function LineOfSight.test(object2, p)
	if not v then
		return false
	end

	local v2 = headPosition(localPlayer.Character, not p and 1.5 or p.EyeHeight or 1.5)
	local v3 = headPosition(object2:getModel(), p and p.HeadHeight or 2)

	if not (v2 and v3) then
		return false
	end

	local v4 = v3 - v2
	return v4.Magnitude <= 0.05 or v(v2, v4, false, {}, false) == nil
end

function LineOfSight.isClear(object2, p)
	local now = os.clock()
	local v2 = object[object2]

	if v2 and now - v2.at < (not p and 0.1 or p.CacheSeconds or 0.1) then
		return v2.clear
	end

	local success, result = pcall(LineOfSight.test, object2, p)

	if not success then
		warn((`[NPCManager] line-of-sight check failed for {object2:getModel().Name}: {tostring(result)}`))
		result = false
	end

	object[object2] = {
		at = now,
		clear = result
	}
	return result
end

return LineOfSight