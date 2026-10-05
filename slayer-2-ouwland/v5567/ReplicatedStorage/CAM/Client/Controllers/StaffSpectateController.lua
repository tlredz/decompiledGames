local ReplicatedStorage = game:GetService("ReplicatedStorage")
local simplesignal = require(ReplicatedStorage.Packages.simplesignal)
local StaffSpectateController = {
	Watched = nil,
	Changed = simplesignal.new()
}

function StaffSpectateController.handleWatch(watched: number?)
	if watched ~= nil and type(watched) ~= "number" or watched == StaffSpectateController.Watched then
		return
	end

	StaffSpectateController.Watched = watched
	StaffSpectateController.Changed:Fire(watched)
end

return StaffSpectateController