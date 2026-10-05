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

function OnChanged(p)
	if p == "Enabled" then
		UpdateIcon()
	end
end

function OnUnequipped()
	Mouse.Icon = ""
	Mouse = nil
end

Tool.Equipped:connect(OnEquipped)
Tool.Changed:connect(OnChanged)
Tool.Unequipped:Connect(OnUnequipped)