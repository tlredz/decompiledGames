local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClanEvents = require(ReplicatedStorage.CAM.Global.ClanEvents)
local parentModule = require(script.Parent)
return parentModule.new({
	Cost = 1,
	Pool = ClanEvents.BuildPool(nil)
})