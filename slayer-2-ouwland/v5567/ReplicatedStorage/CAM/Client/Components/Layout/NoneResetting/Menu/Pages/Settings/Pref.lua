local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataValue = require(ReplicatedStorage.CAM.Client.Modules.DataValue)
local SettingsKeys = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.SettingsKeys)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
require(ReplicatedStorage.Packages.faye)
return function(maid, data, p: string, p2: string?)
	local v = DataValue.new(data.Path, data.Default, data.Scope or SettingsKeys.Scope)
	local value = maid:Value(v:Get())
	maid:Add(function()
		v:Destroy()
	end)
	maid:Connect(v.Changed, function(p3)
		value:Set(p3)
	end)

	local function commit(p3)
		if p3 == v:Get() then
			return
		end

		if p2 == nil then
			SignalEvent.ToServer(p, p3)
		else
			SignalEvent.ToServer(p, p2, p3)
		end
	end

	return value, commit
end