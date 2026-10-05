local RunService = game:GetService("RunService")
local Type = require(game.ReplicatedStorage.Packages.Type)
local React = require(game.ReplicatedStorage.Packages.React)
local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local useRestockTime = require(game.ReplicatedStorage.React.Hooks.Fruit.useRestockTime)
local useShopContext = require(game.ReplicatedStorage.React.Hooks.useShopContext)
local useGlobalState = require(game.ReplicatedStorage.React.Hooks.useGlobalState)
local interface = Type.interface({
	Name = Type.string,
	OnSale = Type.boolean,
	Offsale = Type.boolean,
	Rarity = Type.integer,
	Data = Type.optional(Type.interface({
		Lvl = Type.map(Type.string, Type.integer),
		Cost = Type.map(Type.string, Type.integer),
		Cooldown = Type.map(Type.string, Type.number),
		Awakening = Type.optional(Type.interface({
			Cost = Type.map(Type.string, Type.integer),
			Cooldown = Type.map(Type.string, Type.number),
			Fragments = Type.map(Type.string, Type.integer)
		})),
		Cap = Type.integer
	})),
	Price = Type.integer,
	HasPermanent = Type.optional(Type.boolean)
})
local remotes = game.ReplicatedStorage:WaitForChild("Remotes")
local commF_ = remotes:WaitForChild("CommF_")
local commE = remotes:WaitForChild("CommE")

function validateServerFruitDataMap(items)
	if typeof(items) ~= "table" then
		return nil
	end

	for k, item in items do
		local v, v2 = interface(item)

		if v then
			continue
		end

		warn((`usePlayerServerFruitData: invalid cached fruit data for key {k}: {v2}`))
		return nil
	end

	return items
end

function getAsync(p, p2)
	if RunService:IsRunning() == false then
		return
	end

	local v = validateServerFruitDataMap(commF_:InvokeServer("GetFruits", p == "AdvancedFruitDealer"))

	if not v then
		return p2
	end

	TableUtil.deepFreeze(v)
	return v
end

return function()
	local v = useShopContext()
	local v2, v3 = useGlobalState(`usePlayerServerFruitData-{v}`, nil)
	local v4 = { v2, v, (useRestockTime()) }
	React.useEffect(function()
		local flag = false
		task.defer(function()
			if flag then
				return
			end

			if v2 == nil then
				local async = getAsync(v, v2)

				if flag then
					return
				else
					v3(async)
				end
			end
		end)
		local onClientEventConnection = commE.OnClientEvent:Connect(function(p: string, ...)
			if p == "ItemChanged" or p == "ItemRemoved" then
				local async = getAsync(v, v2)

				if flag then
					return
				end

				if async ~= v2 then
					v3(async)
				end
			end
		end)
		return function()
			onClientEventConnection:Disconnect()
			flag = true
		end
	end, v4)
	return v2
end