local CommerceRewards = require(script.Parent.CommerceRewards)
local CommerceCatalog = require(script.Parent.CommerceCatalog)
local Gems = require(script.Parent.Gems)
local CommerceGifts = {
	Product = function(p)
		if p and p.Kind == "GemPack" then
			return p
		end

		return nil
	end,
	Overlaps = function(p, p2)
		if p.Name == p2.Name then
			return true
		end

		for _, pass in p.Snapshot.Passes do
			if table.find(p2.Snapshot.Passes, pass) then
				return true
			end
		end

		return false
	end,
	Owns = function(p, p2, p3)
		if p2.Kind ~= "Gamepass" and not p2.AllGamepasses or #p3.Passes == 0 then
			return false
		end

		for _, pass in p3.Passes do
			if p[pass] ~= true then
				return false
			end
		end

		return true
	end
}

function CommerceGifts.Pending(p, p2)
	local snapshot = CommerceRewards.Snapshot(p2)

	if not snapshot then
		return false
	end

	for _, v in p.Inbox.List do
		if not v.Claimed and v.CommerceGift and CommerceGifts.Overlaps({
			Name = p2.Name,
			Snapshot = snapshot
		}, v.CommerceGift) then
			return true
		end
	end

	return false
end

function CommerceGifts.DisplayRewards(data)
	local result = {}

	for _, pass in data.Passes do
		table.insert(result, {
			Type = "Gamepass",
			Name = pass,
			Amount = 1
		})
	end

	for _, reward in data.Rewards do
		table.insert(result, table.clone(Gems.Reward(reward, data.Origin)))
	end

	return result
end

function CommerceGifts.Receive(p, receiptId: string, data)
	local ID = "Gift:" .. receiptId

	if p.Inbox.List[ID] then
		return true
	end

	p.Inbox.List[ID] = {
		ID = ID,
		Title = "Gift: " .. data.Name,
		Time = data.Time,
		UserInfo = data.Sender,
		Claimed = false,
		Rewards = CommerceGifts.DisplayRewards(data.Snapshot),
		Messages = { "You received " .. data.Name .. " from @" .. data.Sender.UserName .. ". Claim it below!" },
		CommerceGift = {
			Name = data.Name,
			Kind = data.Kind,
			AllGamepasses = data.AllGamepasses,
			Snapshot = data.Snapshot,
			ReceiptId = receiptId
		}
	}
	p.Commerce.Purchases[data.Name] = math.max(p.Commerce.Purchases[data.Name] or 0, data.PurchaseCount)
	return true
end

function CommerceGifts.Claim(p, state)
	if not state or state.Deleted or state.Claimed or not state.CommerceGift then
		return false, "Unavailable"
	end

	local commerceGift = state.CommerceGift

	if CommerceGifts.Owns(p.Gamepasses, commerceGift, commerceGift.Snapshot) then
		return false, "You already own this gift. Please contact support."
	end

	if not CommerceRewards.Apply(p, commerceGift.Snapshot, "Gift:" .. commerceGift.ReceiptId) then
		return false, "Unable to collect this gift. Check your inventory space and try again!"
	end

	state.Claimed = true
	return true
end

function CommerceGifts.IsProductConfigured(p)
	return p ~= nil and p.Kind == "GemPack" and CommerceCatalog.IsConfigured(p) and CommerceRewards.Snapshot(p) ~= nil
end

return CommerceGifts