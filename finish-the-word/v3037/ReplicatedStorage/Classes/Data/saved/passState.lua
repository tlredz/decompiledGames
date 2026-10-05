local import = _G.import("class")
local import2 = _G.import("iterator")
local MarketplaceService = game:GetService("MarketplaceService")
local v = import.new()

function v:hasPass(p2)
	local gamePassCache = self.GamePassCache
	local v2 = tostring(p2)
	local selected = gamePassCache[v2] or MarketplaceService:UserOwnsGamePassAsync(self.UserId, p2)
	gamePassCache[v2] = selected or nil
	return selected
end

function v.hasSubscription(p, p2)
	local playerByUserId = game.Players:GetPlayerByUserId(p.UserId)

	if not playerByUserId then
		return false
	end

	local success, result = pcall(function()
		return MarketplaceService:GetUserSubscriptionStatusAsync(playerByUserId, p2)
	end)
	return success and result and result.IsSubscribed == true and true or false
end

function v.addPass(p, p2)
	p.GamePassCache[tostring(p2)] = true
end

function v:switchPass(p, p2, p3)
	local v2 = type(p) == "table" and p or { p }

	if import2.fromArray(v2):has(function(_, p4)
		return self:hasPass(p4)
	end) then
		p3 = p2 or p3
	end

	return p3
end

function v.processedPass(p, p2)
	return p.ProcessedPasses[tostring(p2)] or false
end

function v:new()
	self.GamePassCache = {
		_Insertable = true
	}
	self.ProcessedPasses = {
		_Insertable = true
	}
end

return v