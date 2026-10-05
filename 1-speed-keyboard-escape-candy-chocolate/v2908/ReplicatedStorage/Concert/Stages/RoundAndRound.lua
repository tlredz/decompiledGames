local ReplicatedStorage = game:GetService("ReplicatedStorage")
local parent = script.Parent.Parent
local ConcertFunctions = require(ReplicatedStorage.Concert.ConcertFunctions)
require(parent.ConcertState)
local ConcertUtils = require(parent.ConcertUtils)
local assetFolder = ReplicatedStorage.Assets.Concert[script.Name]
return ConcertUtils.DefineStage({
	Name = script.Name,
	Order = 5,
	AssetFolder = assetFolder,
	Init = function(_)
		local stageDeco_RoundAndRound = assetFolder:FindFirstChild("StageDeco_RoundAndRound")
		ConcertFunctions.InitStageAsset(stageDeco_RoundAndRound)
	end,
	Cleanup = function(_)
		ConcertFunctions.CleanupStageAsset()
	end,
	Lyrics = ConcertUtils.GetLyricDataFromFolder(assetFolder:FindFirstChild("Lyrics"))
})