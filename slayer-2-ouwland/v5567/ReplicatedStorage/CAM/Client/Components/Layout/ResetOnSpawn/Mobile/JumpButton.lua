local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MobileLayout = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.MobileLayout)
local vector = Vector2.new(-170, -210)
local v = (-vector.Y - 120) / 120
local JumpButton = {
	Instance = function()
		local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")

		if playerGui == nil then
			return nil
		end

		local touchGui = playerGui:FindFirstChild("TouchGui")

		if touchGui == nil then
			return nil
		end

		local touchControlFrame = touchGui:FindFirstChild("TouchControlFrame")

		if touchControlFrame == nil then
			return nil
		end

		local jumpButton = touchControlFrame:FindFirstChild("JumpButton")

		if jumpButton == nil or not jumpButton:IsA("GuiObject") then
			return nil
		end

		return jumpButton
	end
}

function JumpButton.Metrics(p)
	local instance = JumpButton.Instance()

	if instance == nil or not (instance.AbsoluteSize.X > 0) then
		return p.AbsoluteSize + vector + Vector2.new(120, 120) * 0.5, 120, 0
	end

	local X = instance.AbsoluteSize.X
	local v2 = instance.AbsolutePosition + instance.AbsoluteSize * 0.5 - p.AbsolutePosition
	local v3 = p.AbsoluteSize.Y - (v2.Y + X * 0.5)
	return v2, X, (math.max(0, v * X - v3))
end

function JumpButton.RowShift(p)
	local instance = JumpButton.Instance()

	if instance == nil or instance.AbsoluteSize.X <= 0 then
		return 0
	end

	local absoluteSize = p.AbsoluteSize

	if absoluteSize.X <= 0 then
		return 0
	end

	local toolbar = MobileLayout.Toolbar
	local v2 = absoluteSize.X - toolbar.Edge
	local v3 = v2 - (toolbar.Size * toolbar.Count + toolbar.Padding * (toolbar.Count - 1))
	local v4 = absoluteSize.Y - toolbar.Edge
	local v5 = v4 - toolbar.Size
	local v6 = instance.AbsolutePosition - p.AbsolutePosition
	local X = v6.X
	local v7 = v6.X + instance.AbsoluteSize.X
	local Y = v6.Y

	if v6.Y + instance.AbsoluteSize.Y <= v5 or v4 <= Y or v2 <= X or v7 <= v3 then
		return 0
	end

	return v2 - X + 6
end

return JumpButton