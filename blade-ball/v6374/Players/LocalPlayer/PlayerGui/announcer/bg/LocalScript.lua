local remotes = game.ReplicatedStorage.Remotes
local mFrame = script.Parent.mFrame
local TweenService = game:GetService("TweenService")
local _, _ = remotes.getInitialEXP:InvokeServer()
remotes.getInitialLevel:InvokeServer()

local function tweenBar(p, p2)
	local v = p / p2
	TweenService:Create(mFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
		Size = UDim2.new(v, 0, 1, 0)
	}):Play()
end