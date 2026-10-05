local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PartCache = require(ReplicatedStorage.CAM.Client.Modules.Effects.Craters.PartCache)
local CratersConfig = {}

function CratersConfig.Get_Part()
	return PartCache.GetPart()
end

function CratersConfig.Delete_Part(p, duration: number?)
	if duration == nil then
		PartCache.DeletePart(p)
	else
		task.delay(duration, PartCache.DeletePart, p)
	end
end

return CratersConfig