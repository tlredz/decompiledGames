local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Utils = require(ReplicatedStorage.Common.Utils)
require(ReplicatedStorage.Common.ColorsUtil)
return Observers.observeTagNoAncestry("UI_GridRescale_Y", function(instance)
	local maid = Utils.Maid.new()
	local uI_GridRatio = instance:GetAttribute("UI_GridRatio") or 1

	-- equivalent calls inferred from this helper; original call sites unknown
	local function UpdateSize()
		instance.CellSize = UDim2.new(
			instance.CellSize.X.Scale,
			instance.CellSize.X.Offset,
			0,
			instance.AbsoluteCellSize.X / uI_GridRatio
		)
	end

	maid:GiveTask(instance:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateSize))
	UpdateSize() -- equivalent call inferred; original call site unknown
	return function()
		maid:Destroy()
	end
end)