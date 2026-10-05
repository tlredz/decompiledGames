local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FFlagClient = require(ReplicatedStorage.ClientGameModules.FFlagClient)
local DuoPassData = require(ReplicatedStorage.Shared.DuoPassData)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Utils = require(ReplicatedStorage.Common.Utils)
return Observers.observeTagNoAncestry("DuoPassExpiresTime", function(p)
	local connection = Utils.Thread.Every(1, function()
		local key

		if FFlagClient:IsDataReady() then
			key = FFlagClient:GetKey(DuoPassData.GetFFlagKey("EndTime"))
		end

		p.Text = not key and "LOADING" or Utils.ValueConvertor:FormatTimeWithDaysFull(key - workspace:GetServerTimeNow())
	end)
	return function()
		connection:Disconnect()
	end
end)