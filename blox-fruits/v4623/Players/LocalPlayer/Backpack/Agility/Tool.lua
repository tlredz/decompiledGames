local _ = game.Players.LocalPlayer
local parent = script.Parent

if not script.Parent.Parent:IsA("Model") then
	repeat
		script.Parent.AncestryChanged:wait()
	until script.Parent.Parent:IsA("Model")
end

local character = game.Players.LocalPlayer.Character
local _ = character.HumanoidRootPart
local _ = character.Humanoid
local flag = nil
parent.Equipped:Connect(function()
	flag = true
end)
parent.Unequipped:Connect(function()
	flag = false
end)
parent.Activated:Connect(function()
	if flag then
		script.Parent.RemoteFunction:InvokeServer()
	end
end)