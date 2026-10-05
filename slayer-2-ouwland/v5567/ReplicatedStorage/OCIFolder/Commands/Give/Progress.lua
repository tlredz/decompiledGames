local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local PlayerProgression = require(ReplicatedStorage.CAM.Global.PlayerProgression)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local Progression = require(ServerStorage.SAM.Services.Adders.Progression)
return function(p, p2: string, p3)
	local side = PlayerProgression.ResolveSide(p2)

	if side == nil then
		warn((`Give/Progress: no progression side named "{p2}" (Slayer or Demon)`))
		return
	end

	local content = Progression(p, side, tonumber(p3) or 1)

	if content ~= nil then
		SignalEvent.ToClient(p, "CurrencyNotification", {
			Content = content,
			Time = 5
		})
	end
end