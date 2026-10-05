local parent = script.Parent
local clone = nil
local humanoidRootPart = nil
parent.Equipped:Connect(function()
	if parent.Parent:FindFirstChild("HumanoidRootPart") and game.Players:FindFirstChild(parent.Parent.Name) then
		local child = game.Players:FindFirstChild(parent.Parent.Name)
		clone = script:WaitForChild("xyz"):Clone()
		humanoidRootPart = parent.Parent:FindFirstChild("HumanoidRootPart")
		clone.Parent = child.PlayerGui.backpack.hotbar.Folder.Frame
	end
end)
parent.Unequipped:Connect(function()
	if clone then
		clone:Destroy()
	end

	clone = nil
	humanoidRootPart = nil
end)

local function roundNumber(p, value)
	return string.format("%." .. (value or 0) .. "f", p)
end

local RunService = game:GetService("RunService")
RunService.Heartbeat:Connect(function()
	if clone ~= nil and humanoidRootPart ~= nil then
		local X = humanoidRootPart.Position.X
		local v = string.format("%." .. 1 .. "f", X)
		local Y = humanoidRootPart.Position.Y
		local v2 = string.format("%." .. 1 .. "f", Y)
		local Z = humanoidRootPart.Position.Z
		local v3 = string.format("%." .. 1 .. "f", Z)
		clone.Text = "XYZ:  " .. v .. ", " .. v2 .. ", " .. v3 .. ` | {string.format("%04.1f", humanoidRootPart.AssemblyLinearVelocity.Magnitude)} s/s\t`
	end
end)
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input)
	if clone and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.C and input.KeyCode ~= Enum.KeyCode.X and input.KeyCode ~= Enum.KeyCode.LeftControl and input.KeyCode ~= Enum.KeyCode.RightControl and input.KeyCode ~= Enum.KeyCode.LeftMeta and input.KeyCode ~= Enum.KeyCode.RightMeta then
		clone:ReleaseFocus()
	end
end)