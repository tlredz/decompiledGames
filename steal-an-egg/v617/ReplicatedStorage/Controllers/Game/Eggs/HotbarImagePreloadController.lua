local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HotbarImagePreloadController = require(ReplicatedStorage.Client.HotbarImagePreloadController)
local Trove = require(ReplicatedStorage.Packages.Trove)
return {
	Start = function()
		local maid = Trove.new()
		maid:Add(HotbarImagePreloadController.new()):Start()
		maid:AttachToInstance(script)
	end
}