Mouse_Icon = "rbxasset://textures/GunCursor.png"
Reloading_Icon = "rbxasset://textures/GunWaitCursor.png"
Tool = script.Parent
Mouse = nil

function UpdateIcon()
	if Mouse then
		Mouse.Icon = Tool.Enabled and Mouse_Icon or Reloading_Icon
	end
end

function OnEquipped(p)
	Mouse = p
	UpdateIcon()
end

Tool:GetPropertyChangedSignal("Enabled"):Connect(UpdateIcon)
Tool.Equipped:connect(OnEquipped)
Tool.Activated:Connect(function()
	local humanoid = Tool.Parent:FindFirstChildWhichIsA("Humanoid")

	if humanoid then
		Tool.Throw:InvokeServer(humanoid.TargetPoint)
	end
end)