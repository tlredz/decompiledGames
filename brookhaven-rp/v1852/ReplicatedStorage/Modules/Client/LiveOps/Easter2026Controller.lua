local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Packages.Signal)
require(ReplicatedStorage.Modules.Client.UI.IntroController)
local ReplicatedDataController = require(ReplicatedStorage.Modules.Client.Data.ReplicatedDataController)
local CountDownLatch = require(ReplicatedStorage.Modules.Shared.Async.CountDownLatch)
require(ReplicatedStorage.Modules.Client.UI.LegacyGame8Settings)
local Easter2026Controller = {
	SpringShufflerCounter = 0,
	SpringShufflerCounterUpdated = Signal.new(),
	FrameworkInit = function() end
}

function Easter2026Controller.FrameworkStart()
	local v = CountDownLatch.new(1)
	ReplicatedDataController.GetClientReplicaPromise():andThen(function(object)
		object:OnSet(
			{ "LiveOpsEventData", "Easter2026", "SpringShufflerCounter" },
			function(springShufflerCounter: number)
				Easter2026Controller.SpringShufflerCounter = springShufflerCounter
				Easter2026Controller.SpringShufflerCounterUpdated:Fire(springShufflerCounter)
			end
		)
		local springShufflerCounter = object.Data.LiveOpsEventData.Easter2026.SpringShufflerCounter or 0
		Easter2026Controller.SpringShufflerCounter = springShufflerCounter
		Easter2026Controller.SpringShufflerCounterUpdated:Fire(springShufflerCounter)
		v:countDown()
	end)
end

function Easter2026Controller.OnEventEnable() end

function Easter2026Controller.OnEventDisable() end

return Easter2026Controller