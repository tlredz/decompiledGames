local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
require(game.ReplicatedStorage.Economy.ItemId)
local Fish = {}

if GlobalUtil.FFlags.IsSandboxed ~= false then
	return Fish
end

local RunService = game:GetService("RunService")

if not RunService:IsRunning() then
	return Fish
end

local RunService2 = game:GetService("RunService")

if RunService2:IsServer() then
	local ServerFishData = require(game.ServerScriptService.JobsPackage.FishingSystem.ServerFishData)

	for _, v in ServerFishData.AllFish do
		local name = v.Name
		local v2 = name == "KEYITEM_BOTTLE_RECIPE_MISC" and 99 or ItemConfig.Query.selectFirst({
			Index = {
				StorageKey = name,
				IdType = {
					Operation = "OR",
					Values = {
						"Fish",
						"PhysicalMoveset",
						"Tool",
						"Consumable",
						"Accessory",
						"Potion",
						"Rod",
						"Material",
						"Scroll"
					}
				}
			}
		}):unwrap().Inventory.MaxStack
		assert(v2, (`Bad maxStack for fish "{v.Name}"`))
		Fish[v.Name] = { math.clamp(v.Rarity or 1, 1, 5), v2 }
	end
end

return Fish