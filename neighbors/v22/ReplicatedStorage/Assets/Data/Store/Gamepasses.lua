local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local Server = require(ReplicatedStorage.Modules.Server)
local _ = game.PlaceId
local Gamepasses = {
	Verified = {
		Display = "Verified Badge",
		Id = 145353942,
		GiftId = 1851890682,
		AdultId = 1855934846,
		AdultGiftId = 1851896253
	},
	ProfileColors = {
		Display = "Better Profile",
		Id = 145354039,
		GiftId = 1851893751,
		AdultId = 1856286933,
		AdultGiftId = 1851896461
	},
	InfiniteSkips = {
		Display = "Infinite Skips",
		Id = 145354108,
		GiftId = 1851893954,
		AdultId = 1855850889,
		AdultGiftId = 1851896781
	},
	OutfitSelector = {
		Display = "Outfit Selector",
		Id = 153467045,
		GiftId = 1851894763,
		AdultId = 1856092913,
		AdultGiftId = 1851897651
	},
	ExtraSlots = {
		Display = "Extra Slots",
		Id = 150180452,
		GiftId = 1851894445,
		AdultId = 1856336792,
		AdultGiftId = 1851897503
	},
	ExtraSlots2 = {
		Display = "MORE Extra Slots",
		Id = 646113425,
		GiftId = 1851894219,
		AdultId = 1855858859,
		AdultGiftId = 1851897780
	},
	ExtraSlots3 = {
		Display = "SUPER Extra Slots",
		Id = 966777213,
		GiftId = 2657785484,
		AdultId = 1855831062,
		AdultGiftId = 2657786252
	},
	MegaParty = {
		Display = "MEGA Party Limit",
		Id = 646596279,
		GiftId = 1851895001,
		AdultId = 1855896909,
		AdultGiftId = 1851897976
	},
	HouseEditor = {
		Display = "House Editor",
		Id = 1315022529,
		GiftId = 3333765378,
		AdultId = 1855766948,
		AdultGiftId = 3333765834
	}
}
local v = {}

local function addGamepassId(p: number, p2: string, p3: string)
	if v[p] then
		warn((`Gamepass ({p3}) Id is duplicate: {p} -- {p2}`))
	end

	v[p] = true
end

local function checkForUniqueIds()
	for k, v2 in next, Gamepasses, nil do
		assert(v2.Id, (`No Id for {k}`))
		assert(v2.GiftId, (`No GiftId for {k}`))
		assert(v2.AdultId, (`No AdultId for {k}`))
		assert(v2.AdultGiftId, (`No AdultGiftId for {k}`))
		local id = v2.Id

		if v[id] then
			warn((`Gamepass (Regular) Id is duplicate: {id} -- {k}`))
		end

		v[id] = true
		local giftId = v2.GiftId

		if v[giftId] then
			warn((`Gamepass (Regular Gift) Id is duplicate: {giftId} -- {k}`))
		end

		v[giftId] = true
		local adultId = v2.AdultId

		if v[adultId] then
			warn((`Gamepass (Adult) Id is duplicate: {adultId} -- {k}`))
		end

		v[adultId] = true
		local adultGiftId = v2.AdultGiftId

		if v[adultGiftId] then
			warn((`Gamepass (Adult Gift) Id is duplicate: {adultGiftId} -- {k}`))
		end

		v[adultGiftId] = true
	end

	table.clear(v)
end

local function getGamepassPrice(p: number, p2)
	local productInfoAsync = nil
	local _, _ = pcall(function()
		productInfoAsync = MarketplaceService:GetProductInfoAsync(p, p2)
	end)

	if not productInfoAsync then
		warn((`[Gamepass Check] Failed to fetch gamepass price for: {p} ({p2.Name})`))
		return nil
	end

	if productInfoAsync.PriceInRobux then
		return productInfoAsync.PriceInRobux
	end

	warn((`[Gamepass Check] Gamepass price does not exist: {p} ({p2.Name})`))
	return nil
end

local function checkGamepassPrices()
	local count = 0

	for k, v2 in next, Gamepasses, nil do
		local gamepassPrice = getGamepassPrice(v2.RegularId, Enum.InfoType.GamePass)
		local gamepassPrice2 = getGamepassPrice(v2.RegularGiftId, Enum.InfoType.Product)
		local gamepassPrice3 = getGamepassPrice(v2.AdultId, Enum.InfoType.GamePass)
		local gamepassPrice4 = getGamepassPrice(v2.AdultGiftId, Enum.InfoType.Product)

		if gamepassPrice and gamepassPrice2 and gamepassPrice ~= gamepassPrice2 then
			warn((`[Gamepass Check] {k} has differing prices for regular gamepass & regular gift. ({gamepassPrice} -- {gamepassPrice2})`))
			count += 1
		end

		if not (gamepassPrice3 and gamepassPrice4 and gamepassPrice3 ~= gamepassPrice4) then
			continue
		end

		warn((`[Gamepass Check] {k} has differing prices for adult & adult gift. ({gamepassPrice3} -- {gamepassPrice4})`))
		count += 1
	end

	print("[Gamepass Check] Successfully checked all gamepass prices >>")

	if count > 0 then
		warn((`[Gamepass Check] {count} gamepasses have non-matching prices`))
	end
end

local isAdultServer = Server:IsAdultServer()

for k, v2 in next, Gamepasses, nil do
	v2.Key = k
	v2.RegularId = v2.Id
	v2.RegularGiftId = v2.GiftId

	if not isAdultServer then
		continue
	end

	v2.Id = v2.AdultId
	v2.GiftId = v2.AdultGiftId
end

local RunService = game:GetService("RunService")

if RunService:IsClient() then
	task.spawn(function()
		for _, v2 in next, Gamepasses, nil do
			local v3 = v2
			local success, result = pcall(function()
				return MarketplaceService:GetProductInfo(v3.Id, Enum.InfoType.GamePass)
			end)

			if success then
				v2.Price = result.PriceInRobux or "?"
				v2.Description = result.Description or "N/A"
				v2.Icon = `rbxassetid://{result.IconImageAssetId}`
			else
				v2.Price = "?"
				v2.Description = "---"
				v2.Icon = ""
			end

			v2.Ready = true
		end
	end)
	return Gamepasses
end

if Server:IsTestServer() then
	checkForUniqueIds()
	task.spawn(checkGamepassPrices)
end

return Gamepasses