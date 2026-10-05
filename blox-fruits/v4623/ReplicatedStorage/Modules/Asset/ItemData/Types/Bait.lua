local RunService = game:GetService("RunService")
local Bait = {}
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)

if not RunService:IsRunning() then
	return Bait
end

local JobsReplicated = require(game.ReplicatedStorage.JobsReplicated)
local baitData = JobsReplicated.BaitData

if not baitData then
	return Bait
end

for k, type in baitData.Types do
	if k == "None" then
		continue
	end

	local maxStack = ItemConfig.match(k, "Bait"):unwrap().Inventory.MaxStack
	assert(maxStack, (`Bad maxStack for bait "{k}"`))
	Bait[k] = { math.clamp(type.BaitRarity or 0, 0, 4), maxStack }
end

return Bait