local ReplicatedStorage = game:GetService("ReplicatedStorage")
local parent = script.Parent.Parent
local ConcertFunctions = require(ReplicatedStorage.Concert.ConcertFunctions)
require(parent.ConcertState)
local ConcertUtils = require(parent.ConcertUtils)
local assetFolder = ReplicatedStorage.Assets.Concert[script.Name]
return ConcertUtils.DefineStage({
	Name = script.Name,
	Order = 12,
	AssetFolder = assetFolder,
	Init = function(_)
		local stageDecor_WhyAmILikeThis = assetFolder:FindFirstChild("StageDecor_WhyAmILikeThis")
		ConcertFunctions.InitStageAsset(stageDecor_WhyAmILikeThis)
	end,
	Cleanup = function(_)
		ConcertFunctions.CleanupStageAsset()
	end,
	Lyrics = ConcertUtils.GetLyricDataFromFolder(assetFolder:FindFirstChild("Lyrics"))
})