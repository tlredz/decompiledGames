local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local parent = script.Parent
local handle = parent:WaitForChild("Handle")
handle:GetPropertyChangedSignal("Transparency"):Connect(function()
	local character = localPlayer.Character and localPlayer.Character.Parent == workspace and localPlayer.Character or localPlayer.CharacterAdded:Wait()

	if not parent:IsDescendantOf(character) then
		workspace.Gravity = 196.2
	elseif handle.Transparency == 1 then
		workspace.Gravity = 196.2
	else
		workspace.Gravity = 29.429999999999996
	end
end)
parent.Equipped:Connect(function()
	if handle.Transparency == 1 then
		workspace.Gravity = 196.2
	else
		workspace.Gravity = 29.429999999999996
	end
end)
parent.Unequipped:Connect(function()
	workspace.Gravity = 196.2
end)