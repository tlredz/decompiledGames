local ReplicatedStorage = game:GetService("ReplicatedStorage")
local parent = script.Parent.Parent
local ConcertFunctions = require(ReplicatedStorage.Concert.ConcertFunctions)
require(parent.ConcertState)
local ConcertUtils = require(parent.ConcertUtils)
local assetFolder = ReplicatedStorage.Assets.Concert[script.Name]
return ConcertUtils.DefineStage({
	Name = script.Name,
	Order = 4,
	AssetFolder = assetFolder,
	Init = function(_)
		local stageDeco_DiamondsAreForever = assetFolder:FindFirstChild("StageDeco_DiamondsAreForever")
		ConcertFunctions.InitStageAsset(stageDeco_DiamondsAreForever)
	end,
	Cleanup = function(_)
		ConcertFunctions.CleanupStageAsset()
	end,
	Lyrics = ConcertUtils.GetLyricDataFromFolder(assetFolder:FindFirstChild("Lyrics"))
})