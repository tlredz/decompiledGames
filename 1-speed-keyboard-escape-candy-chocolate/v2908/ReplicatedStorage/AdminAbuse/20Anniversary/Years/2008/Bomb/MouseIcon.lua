local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HandleReload = require(ReplicatedStorage:WaitForChild("HandleReload"))
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
	wait()
	UpdateIcon() -- equivalent call inferred; original call site unknown
end

local function OnUnequipped()
	if v then
		v.Icon = ""
	end
end

local function OnChanged(p)
	if p == "Enabled" then
		UpdateIcon() -- equivalent call inferred; original call site unknown

		if parent.Enabled == false then
			HandleReload.new(parent, 6)
		end
	end
end

parent.Equipped:connect(OnEquipped)
parent.Unequipped:connect(OnUnequipped)
parent.Changed:connect(OnChanged)