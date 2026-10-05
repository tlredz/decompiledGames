local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Modules.External.Madwork.ReplicaController)
local localPlayer = Players.LocalPlayer
local v = nil
local registerReplicaClass = ReplicatedStorage.Bindables.RegisterReplicaClass
local MyDataController = {
	waitForReplica = function(self)
		while not v do
			task.wait()
		end

		return v
	end,
	onReplicaReady = function(self, callback, _)
		local v2 = self:waitForReplica()
		task.spawn(callback, v2)
	end,
	getMyReplica = function(_)
		return v
	end,
	getDataFromPath = function(_, value: string)
		if not v or typeof(value) ~= "string" then
			return
		end

		local data = v.Data
		local parts = value:split(".")

		if #parts == 0 then
			return
		end

		while #parts > 1 do
			data = data[table.remove(parts, 1)]

			if data == nil then
				return
			end
		end

		return data[parts[1]]
	end
}
task.defer(function()
	registerReplicaClass:Invoke("PlayerProfile", function(p)
		if p.Tags.Player == localPlayer then
			v = p
		end
	end)
end)
return MyDataController