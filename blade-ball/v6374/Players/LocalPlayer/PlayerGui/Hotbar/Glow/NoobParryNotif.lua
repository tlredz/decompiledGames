local parent = script.Parent
local TweenService = game:GetService("TweenService")
game:GetService("ReplicatedStorage")
local block = parent.Parent.Block
local flag = true
local redOutline = block.RedOutline
game.ReplicatedStorage.Remotes.NoobParryHappened.OnClientEvent:Connect(function()
	TweenService:Create(
		redOutline,
		TweenInfo.new(0.2, Enum.EasingStyle.Circular, Enum.EasingDirection.In, 3, true, 0),
		{
			ImageTransparency = 0
		}
	):Play()
	task.wait(1.2000000000000002)
	TweenService:Create(redOutline, TweenInfo.new(0.2), {
		ImageTransparency = 1
	}):Play()
end)

local function position()
	if flag then
		return
	end

	local v = block.AbsoluteSize * 1.4
	local v2 = block.AbsoluteSize * 0.3999999999999999
	redOutline.Position = UDim2.new(0, block.AbsolutePosition.X - v2.X / 2, 0, block.AbsolutePosition.Y - v2.Y / 2)
	redOutline.Size = UDim2.new(0, v.X, 0, v.Y)
end

position()
block:GetPropertyChangedSignal("AbsolutePosition"):Connect(position)
block:GetPropertyChangedSignal("AbsoluteSize"):Connect(position)

-- equivalent calls inferred from this helper; original call sites unknown
local function scale()
	redOutline.UIScale.Scale = block.UIScale.Scale
end

scale() -- equivalent call inferred; original call site unknown
block.UIScale:GetPropertyChangedSignal("Scale"):Connect(scale)