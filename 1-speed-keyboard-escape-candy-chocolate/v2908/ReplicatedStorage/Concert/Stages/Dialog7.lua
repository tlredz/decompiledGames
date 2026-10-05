local ReplicatedStorage = game:GetService("ReplicatedStorage")
local parent = script.Parent.Parent
local ConcertUtils = require(parent.ConcertUtils)
local assetFolder = ReplicatedStorage.Assets.Concert[script.Name]
return ConcertUtils.DefineStage({
	Name = script.Name,
	Order = 9.5,
	AssetFolder = assetFolder,
	IsPremiereOnly = true
})