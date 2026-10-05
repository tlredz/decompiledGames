local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Log = require(ReplicatedStorage.Packages.Log)
local Marketplace = require(ReplicatedStorage.Shared.Utils.Marketplace)
require(script.Parent.ProductTypes)
local v = game.CreatorType == Enum.CreatorType.Group and "Group" or "User"
local creatorId = game.CreatorId
local v2 = Log.new()

local function creatorId2(p)
	if not p then
		return nil
	end

	local creatorTargetId = p.CreatorTargetId or p.Id

	if creatorTargetId and creatorTargetId > 0 then
		return creatorTargetId
	end

	return nil
end

return {
	Validate = function(p: string, p2)
		local current = Marketplace.Current(p2.ProductId, Enum.InfoType.Product)

		if current == nil then
			v2:AtWarning():Log(`Failed to validate marketplace product info for {p}`, {
				ProductId = p2.ProductId
			})
			return
		end

		local priceInRobux = current.PriceInRobux or 0

		if priceInRobux <= 0 then
			v2:AtWarning():Log(`Product {p} has an invalid Robux price`, {
				ProductId = p2.ProductId,
				PriceInRobux = priceInRobux
			})
		elseif priceInRobux > 10000 then
			v2:AtWarning():Log(`Product {p} is priced above the Studio validation threshold`, {
				ProductId = p2.ProductId,
				PriceInRobux = priceInRobux,
				MaxAllowedPrice = 10000
			})
		end

		local creator = current.Creator
		local creatorTargetId

		if creator then
			creatorTargetId = creator.CreatorTargetId or creator.Id

			if not (creatorTargetId and creatorTargetId > 0) then
				creatorTargetId = nil
			end
		end

		if creator and creator.CreatorType and creatorTargetId and (creator.CreatorType ~= v or creatorTargetId ~= creatorId) then
			v2:AtWarning():Log(`Product {p} is owned by the wrong creator`, {
				ProductId = p2.ProductId
			})
		end
	end
}