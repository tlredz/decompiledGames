local ReplicatedStorage = game:GetService("ReplicatedStorage")
local parent = script.Parent.Parent
local ConcertFunctions = require(ReplicatedStorage.Concert.ConcertFunctions)
require(parent.ConcertState)
local ConcertUtils = require(parent.ConcertUtils)
local assetFolder = ReplicatedStorage.Assets.Concert[script.Name]
return ConcertUtils.DefineStage({
	Name = script.Name,
	Order = 2,
	AssetFolder = assetFolder,
	Init = function(_)
		local stageDeco_ItBoy = assetFolder:FindFirstChild("StageDeco_ItBoy")
		ConcertFunctions.InitStageAsset(stageDeco_ItBoy)
	end,
	Cleanup = function(_)
		ConcertFunctions.CleanupStageAsset()
	end,
	Lyrics = ConcertUtils.GetLyricDataFromFolder(assetFolder:FindFirstChild("Lyrics"))
})