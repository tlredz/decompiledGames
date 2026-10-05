local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Shared.Packs)
local IS_TESTING_PLACE = workspace:GetAttribute("IS_TESTING_PLACE")
local remotes = ReplicatedStorage2.Remotes
local bindableEvent = Instance.new("BindableEvent")
local ClientPackManager = {
	Packs = {},
	PacksBonus = {},
	PacksPlayTime = {}
}

local function updatePacks(packs)
	ClientPackManager.Packs = packs
	bindableEvent:Fire(packs)
end

function ClientPackManager.onChange(p, onEvent)
	onEvent(p.Packs)
	return bindableEvent.Event:Connect(onEvent)
end

function ClientPackManager:getPackData(value)
	local v2 = string.find(value, "_") ~= nil
	local pack = self.Packs[value]
	local v3 = v[value]

	if v2 then
		local v4, v5 = string.match(value, "(%w+)_(%w+)")

		if not (v4 and v5) then
			return
		end

		local v6 = v[v4]

		if not v6.SubPacks then
			return
		end

		local subPack = v6.SubPacks[v5]
		local expiresAt

		if pack.ExpiresAt then
			expiresAt = pack.ExpiresAt
		elseif v6.ExpireDate then
			expiresAt = v6.ExpireDate.UnixTimestamp
		end

		return {
			ExpiresAt = expiresAt,
			Purchases = pack.Purchases,
			PurchaseLimit = subPack.PurchaseLimit
		}
	else
		local expiresAt

		if pack and pack.ExpiresAt then
			expiresAt = pack.ExpiresAt
		elseif v3.ExpireDate then
			expiresAt = v3.ExpireDate.UnixTimestamp
		end

		local purchases

		if pack then
			purchases = pack.Purchases
		end

		local purchaseLimit

		if v3 then
			purchaseLimit = v3.PurchaseLimit
		end

		return {
			ExpiresAt = expiresAt,
			Purchases = purchases,
			PurchaseLimit = purchaseLimit
		}
	end
end

function ClientPackManager:canSeePack(p)
	local timeLeft = self:getTimeLeft(p)

	if timeLeft and timeLeft <= 0 then
		return false
	end

	local v2 = v[self:getRootName(p)]

	if not v2 then
		return false
	end

	local packPlayTime = self:getPackPlayTime(p)
	return not (v2.PlayTime and (not packPlayTime or packPlayTime < v2.PlayTime) and not IS_TESTING_PLACE)
end

function ClientPackManager:getTimeLeft(p)
	local packData = self:getPackData(p)

	if not packData then
		return nil
	end

	local unixTimestamp = DateTime.now().UnixTimestamp

	if packData.ExpiresAt then
		return (math.max(0, packData.ExpiresAt - unixTimestamp))
	end

	return nil
end

function ClientPackManager:getUnitsLeft(p)
	local packData = self:getPackData(p)

	if not packData then
		return
	end

	if packData.PurchaseLimit then
		return packData.PurchaseLimit - packData.Purchases
	end
end

function ClientPackManager:getRootName(value)
	if string.find(value, "_") ~= nil then
		return assert(string.match(value, "(%w+)_"))
	end

	return value
end

function ClientPackManager:getPackPlayTime(p2: string)
	return self.PacksPlayTime[p2]
end

remotes.Store.UpdatePacks.OnClientEvent:Connect(updatePacks)
remotes.Store.UpdatePacksBonus.OnClientEvent:Connect(function(packsBonus)
	ClientPackManager.PacksBonus = packsBonus
	bindableEvent:Fire(packsBonus)
end)
remotes.Store.UpdatePackPlayTime.OnClientEvent:Connect(function(p: string, p2: number)
	ClientPackManager.PacksPlayTime[p] = p2
end)
return ClientPackManager