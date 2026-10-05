local parent = script.Parent
local v = nil

function UpdateIcon()
	if v then
		v.Icon = parent.Enabled and "rbxasset://textures/GunCursor.png" or "rbxasset://textures/GunWaitCursor.png"
	end
end

function OnEquipped(p)
	v = p
	UpdateIcon()
end

function OnChanged(p: string)
	if p == "Enabled" then
		UpdateIcon()
	end
end

parent.Equipped:Connect(OnEquipped)
parent.Changed:Connect(OnChanged)