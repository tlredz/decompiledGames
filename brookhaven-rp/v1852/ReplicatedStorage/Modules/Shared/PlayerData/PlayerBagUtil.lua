local PlayerBagUtil = {}
local playersBagsByInstance = {}
setmetatable(playersBagsByInstance, {
	__mode = "k"
})
local v = {}
setmetatable(v, {
	__mode = "k"
})

function PlayerBagUtil.GetPlayerBag(instance)
	if playersBagsByInstance[instance] then
		return playersBagsByInstance[instance]
	end

	local playersBag = instance:FindFirstChild("PlayersBag")

	if not playersBag then
		return nil
	end

	playersBagsByInstance[instance] = playersBag
	return playersBag
end

function PlayerBagUtil.GetPlayerBagInstance(p, childName: string)
	local playerBag = PlayerBagUtil.GetPlayerBag(p)

	if not playerBag then
		return nil
	end

	if v[p] and v[p][childName] then
		return v[p][childName]
	end

	local child = playerBag:FindFirstChild(childName)
	v[p] = v[p] or {}
	v[p][childName] = child
	return child
end

function PlayerBagUtil.WaitForPlayersBag(instance)
	if playersBagsByInstance[instance] then
		return playersBagsByInstance[instance]
	end

	local playersBag = instance:WaitForChild("PlayersBag", 60)
	playersBagsByInstance[instance] = playersBag
	return playersBag
end

function PlayerBagUtil.WaitForInstanceFromBag(p, childName: string)
	local v2 = PlayerBagUtil.WaitForPlayersBag(p)

	if not v2 then
		return nil
	end

	if not v[p] then
		v[p] = {}
	end

	if v[p][childName] then
		return v[p][childName]
	end

	local child = v2:WaitForChild(childName, 60)
	v[p] = v[p] or {}
	v[p][childName] = child
	return child
end

return PlayerBagUtil