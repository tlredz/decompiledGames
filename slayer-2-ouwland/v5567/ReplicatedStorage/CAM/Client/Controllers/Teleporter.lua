local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Teleporter = require(ReplicatedStorage.CAM.Client.Modules.Teleporter)
return {
	RegularTeleport = function(placeId: number, jobId: string?)
		if placeId == nil then
			return
		end

		task.spawn(function()
			Teleporter.Request({
				placeId = placeId,
				jobId = jobId
			})
		end)
	end
}