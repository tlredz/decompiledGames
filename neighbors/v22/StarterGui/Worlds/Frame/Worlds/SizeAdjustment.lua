local Global = require(game.ReplicatedStorage.Assets.Data.Global)
local parent = script.Parent
local info = parent.Info
local uDim = UDim2.new(0, 700, 0, 400)
local uDim2 = UDim2.new(0, 600, 0, 400)

local function updateFrameSize()
	parent.Size = info.Visible and uDim or uDim2
end

if Global.ServerLayoutType == "Neighbors" then
	parent.Size = UDim2.new(0, 700, 0, 400)
	return
end

if info.Visible then
	uDim2 = uDim or uDim2
end

parent.Size = uDim2
info:GetPropertyChangedSignal("Visible"):Connect(updateFrameSize)