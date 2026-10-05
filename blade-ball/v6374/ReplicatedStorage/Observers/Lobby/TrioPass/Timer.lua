local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FFlagClient = require(ReplicatedStorage.ClientGameModules.FFlagClient)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Utils = require(ReplicatedStorage.Common.Utils)
return Observers.observeTagNoAncestry("TrioPassExpiresTime", function(p)
	local connection = Utils.Thread.Every(1, function()
		local key

		if FFlagClient:IsDataReady() then
			key = FFlagClient:GetKey("SilentVeilTrioPassEndTime")
		end

		p.Text = not key and "LOADING" or Utils.ValueConvertor:FormatTimeWithDays(key - workspace:GetServerTimeNow())
	end)
	return function()
		connection:Disconnect()
	end
end)