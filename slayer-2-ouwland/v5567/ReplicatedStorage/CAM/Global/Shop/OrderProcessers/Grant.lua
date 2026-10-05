local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local v = nil
local v2 = nil
local v3 = nil
return function(p, p2, _: string, value: number?, p3)
	local grant

	if p3 ~= nil then
		grant = p3.Grant or nil
	end

	if p == nil or p2 == nil then
		return false, "No player"
	end

	if type(grant) ~= "table" then
		return false, "Listing grants nothing"
	end

	local v4 = math.max(math.floor(value or 1), 1)
	local content = {}

	if grant.Wen ~= nil then
		v3 = v3 or require(ServerStorage.SAM.Services.Adders.Wen)
		content[#content + 1] = v3(p, p2, grant.Wen * v4, "Shop")
	end

	if grant.Exp ~= nil then
		v = v or require(ServerStorage.SAM.Services.Adders.Exp)
		content[#content + 1] = v(p, p2, grant.Exp * v4, "Shop")
	end

	if grant.Mastery ~= nil then
		v2 = v2 or require(ServerStorage.SAM.Services.Adders.Mastery)
		content[#content + 1] = v2(p, p2, {
			To = { grant.Track },
			Points = grant.Mastery * v4
		})
	end

	if #content == 0 then
		return false, "Nothing left to credit"
	end

	SignalEvent.ToClient(p, "CurrencyNotification", {
		Content = content,
		Time = 5
	})
	return true
end