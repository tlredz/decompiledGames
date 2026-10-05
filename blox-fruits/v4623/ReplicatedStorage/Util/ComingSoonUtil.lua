local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local ItemId = require(game.ReplicatedStorage.Economy.ItemId)
local ComingSoonUtil = {
	ATTR_KEY = "IsComingSoonList",
	OnChanged = workspace:GetAttributeChangedSignal("IsComingSoonList"),
	getIsComingSoonList = function()
		if RunService:IsServer() then
			local ComingSoonService = require(game.ServerScriptService.Services.ComingSoonService)

			if ComingSoonService.IsInitialized == true then
				return ComingSoonService:GetList()
			end
		else
			local isComingSoonList = workspace:GetAttribute("IsComingSoonList")

			if not isComingSoonList then
				return {}
			end

			local success, result = pcall(function()
				return TableUtil.map(HttpService:JSONDecode(isComingSoonList), function(_: number, p: number)
					return ItemConfig.match(p):unwrap()
				end)
			end)

			if success then
				return result
			end
		end

		return {}
	end
}

function ComingSoonUtil.getIsComingSoon(value)
	local v = nil

	if type(value) == "string" then
		v = ItemId.getId(value, "Redeemable"):unwrap()
	elseif type(value) == "number" then
		v = value
	end

	assert(v, (`bad itemId / product storage key: "{value}"`))
	local unwrapped = ItemConfig.match(v):unwrap()

	if unwrapped.Index.IdType == "Redeemable" then
		local isComingSoonList = ComingSoonUtil.getIsComingSoonList()

		for _, v2 in isComingSoonList do
			if v2.Index.ItemId == v then
				return true
			end
		end

		return false
	else
		warn(debug.traceback((`getIfComingSoon requires a "Redeemable" idType, received "{unwrapped.Index.DebugLabel}"`)))
		error((`getIfComingSoon requires a "Redeemable" idType, received "{unwrapped.Index.DebugLabel}"`))
		return false
	end
end

return ComingSoonUtil