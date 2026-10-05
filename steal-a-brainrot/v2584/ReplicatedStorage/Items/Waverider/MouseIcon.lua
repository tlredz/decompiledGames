local parent = script.Parent
local v = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function UpdateIcon()
	if v then
		v.Icon = parent.Enabled and "rbxasset://textures/GunCursor.png" or "rbxasset://textures/GunWaitCursor.png"
	end
end

local function OnEquipped(p)
	v = p
	UpdateIcon() -- equivalent call inferred; original call site unknown
end

local function OnChanged(p: string)
	if p == "Enabled" and v then
		v.Icon = parent.Enabled and "rbxasset://textures/GunCursor.png" or "rbxasset://textures/GunWaitCursor.png"
	end
end

parent.Equipped:Connect(OnEquipped)
parent.Changed:Connect(OnChanged)