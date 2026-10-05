local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataValue = require(ReplicatedStorage.CAM.Client.Modules.DataValue)
local MapKeys = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.MapKeys)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
require(ReplicatedStorage.Packages.faye)
return {
	Watch = function(maid, p: string)
		local v = MapKeys.ByName[p]
		local v2 = DataValue.new(v.Path, v.Default, MapKeys.Scope)
		local value = maid:Value(v2:Get() == true)
		maid:Add(function()
			v2:Destroy()
		end)
		maid:Connect(v2.Changed, function(p2)
			value:Set(p2 == true)
		end)

		local function commit(flag: boolean)
			if flag == (v2:Get() == true) then
				return
			end

			SignalEvent.ToServer(MapKeys.Action, p, flag)
		end

		return value, commit
	end
}