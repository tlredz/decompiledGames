local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Shared.Types.AssetItem)
local AssetDisplayText = require(ReplicatedStorage.Shared.Modules.AssetDisplayText)
local AssetInfoBillboard = require(ReplicatedStorage.Shared.Modules.AssetInfoBillboard)
local AssetRigFactory = require(ReplicatedStorage.Shared.Modules.AssetRigFactory)
local AssetToolRig = require(ReplicatedStorage.Shared.Modules.AssetToolRig)
local ItemDisplay = {}
ItemDisplay.ApplyBillboardDisplay = AssetInfoBillboard.WriteTitle
ItemDisplay.ApplyModelScale = AssetRigFactory.Resize
ItemDisplay.CreateActiveModel = AssetRigFactory.BuildActive
ItemDisplay.CreateDataBillboard = AssetInfoBillboard.Attach
ItemDisplay.CreateTool = AssetToolRig.Build
ItemDisplay.CreateWanderingAssetModel = AssetRigFactory.BuildWandering
ItemDisplay.GetDataBillboardMaxDistance = AssetInfoBillboard.Range
ItemDisplay.GetDisplayScale = AssetRigFactory.Scale
ItemDisplay.GetModelScale = AssetRigFactory.RigScale
ItemDisplay.GetMutationRichTextLine = AssetDisplayText.MutationRun
ItemDisplay.GetNameFromItemData = AssetDisplayText.ForRecord
ItemDisplay.GetVisibleBounds = AssetRigFactory.Extents
ItemDisplay.IsDroppableBaseMutation = AssetDisplayText.IsDroppable
ItemDisplay.ResolveBaseMutation = AssetDisplayText.FirstDroppable
ItemDisplay.SetDataBillboardMoneyPerSecond = AssetInfoBillboard.SetRate
ItemDisplay.StripRuntimeRig = AssetRigFactory.Strip

function ItemDisplay.CreateModel(p, _: boolean?)
	return AssetRigFactory.Build(p)
end

function ItemDisplay.CreateActiveModelWithHumanoid(p: string?, p2)
	return AssetRigFactory.BuildActive(p, p2)
end

return ItemDisplay