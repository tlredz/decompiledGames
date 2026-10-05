local ReplicatedStorage = game:GetService("ReplicatedStorage")
local parent = script.Parent.Parent
local ConcertFunctions = require(ReplicatedStorage.Concert.ConcertFunctions)
require(parent.ConcertState)
local ConcertUtils = require(parent.ConcertUtils)
local assetFolder = ReplicatedStorage.Assets.Concert[script.Name]
return ConcertUtils.DefineStage({
	Name = script.Name,
	Order = 7,
	AssetFolder = assetFolder,
	Init = function(_)
		local stageDeco_MeantTobe = assetFolder:FindFirstChild("StageDeco_MeantTobe")
		ConcertFunctions.InitStageAsset(stageDeco_MeantTobe)
	end,
	Cleanup = function(_)
		ConcertFunctions.CleanupStageAsset()
	end,
	Lyrics = ConcertUtils.GetLyricDataFromFolder(assetFolder:FindFirstChild("Lyrics"))
})