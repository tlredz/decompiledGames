local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local v = nil
local v2 = nil
local v3 = nil
local v4 = nil
return function(p, p2, _: string, _: number?, data)
	if p == nil or p2 == nil then
		return false, "No player"
	end

	if data == nil then
		return false, "No listing"
	end

	local reward = data.Reward

	if reward == nil then
		local product

		if typeof(data.Price) == "table" then
			product = data.Price.Product or nil
		end

		if typeof(product) ~= "number" then
			return false, "Listing has no product"
		end

		v = v or require(ServerStorage.SAM.Services.ProductBehaviours)
		return v.Run(product, p, p2, data)
	else
		local v5 = math.max(math.floor(tonumber(data.RewardAmount) or 1), 1)

		if reward == "Wen" then
			v3 = v3 or require(ServerStorage.SAM.Services.Adders.Wen)
			v3(p, p2, v5, "Shop")
			return true
		else
			v4 = v4 or require(ReplicatedStorage.CAM.Global.Collectibles.Items)

			if v4[reward] == nil then
				return false, (`Unknown reward item "{tostring(reward)}"`)
			end

			v2 = v2 or require(ServerStorage.SAM.Services.Adders.Item)
			return v2(p, reward, v5, nil, nil, nil, "Shop")
		end
	end
end