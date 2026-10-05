local _ = {
	Fire = "http://www.roblox.com/asset/?id=9426132023"
}
local parent = script.Parent
local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
game.ReplicatedStorage.Remotes.Gameplay.KillEvent.OnClientEvent:Connect(function(_, _, p, value)
	for _, frame in pairs(parent:GetChildren()) do
		if frame:IsA("Frame") then
			frame.LayoutOrder += 1
		end
	end

	local clone = script.NewEvent:Clone()
	clone.Parent = script.Parent

	if p then
		local _ = "+" .. p .. " - "
	end

	clone.EventName.Text = value or "Eliminated"
	game.Debris:AddItem(clone, 2)
	clone.EventName.TextTransparency = 1
	clone.EventName.TextStrokeTransparency = 1
	local TweenService = game:GetService("TweenService")
	TweenService:Create(clone.EventName, tweenInfo, {
		TextTransparency = 0,
		TextStrokeTransparency = 0.3,
		Position = UDim2.new(0, 0, 0, 0)
	}):Play()
	wait(1.5)
	local TweenService2 = game:GetService("TweenService")
	TweenService2:Create(clone.EventName, tweenInfo2, {
		TextTransparency = 1,
		TextStrokeTransparency = 1
	}):Play()
end)