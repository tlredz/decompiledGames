local Config = require(script.Parent.Config)
local v = {}
local v2 = {}
local result = {}
local OnlineRewardConfig = {}

for _, reward in Config.reward.list or {} do
	local cnId = reward.cnId

	if typeof(cnId) ~= "string" then
		continue
	end

	local v4 = string.match(cnId, "^在线(%d+)分钟奖励$")

	if not v4 then
		continue
	end

	local minutes = tonumber(v4)

	if minutes and minutes > 0 and minutes % 1 == 0 and not (v[minutes] or v2[cnId]) then
		v[minutes] = true
		v2[cnId] = true
		local v6 = {
			index = #result + 1,
			minutes = minutes,
			seconds = minutes * 60,
			rewardCnId = cnId,
			reward = reward,
			asset = 0
		}
		local asset

		if typeof(reward.assetCnId) == "string" then
			asset = Config.asset.byCnId[reward.assetCnId]
		end

		v6.asset = asset
		table.insert(result, v6)
	else
		warn("[OnlineRewardConfig] 无效或重复的在线奖励: " .. cnId)
	end
end

if #result > 5 then
	warn("[OnlineRewardConfig] 在线奖励超过五档，UI 只支持前五档")

	while #result > 5 do
		table.remove(result)
	end
end

for k, v3 in result do
	if k > 1 and v3.minutes <= result[k - 1].minutes then
		warn("[OnlineRewardConfig] 在线奖励需要按分钟升序排列，存档序号依赖原表顺序")
	end
end

function OnlineRewardConfig.getTiers()
	return result
end

function OnlineRewardConfig.getTier(p: number)
	return result[p]
end

return OnlineRewardConfig