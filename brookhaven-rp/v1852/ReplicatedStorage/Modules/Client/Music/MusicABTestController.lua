local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Signal = require(ReplicatedStorage.Packages.Signal)
local MusicABTestController = {
	ShouldRunTestChanged = Signal.new()
}
local v = nil

function MusicABTestController.FrameworkStart()
	local _, _, v2 = Remotes.invokeServer("NewUserData")
	ABTest.GetExperimentVariable("music-purchase-flow", "install-date"):andThen(function(p)
		v = v2 > p.UnixTimestampMillis
		MusicABTestController.ShouldRunTestChanged:Fire(v)
	end)
end

function MusicABTestController.ShouldRunABTest()
	if v == nil then
		return Promise.new(function(callback, _)
			MusicABTestController.ShouldRunTestChanged:Once(function(p)
				callback(p)
			end)
		end)
	end

	return Promise.resolve(v)
end

return MusicABTestController