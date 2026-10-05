local v = {
	["Update Log (1):"] = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(123, 255, 106)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(81, 165, 69))
	}),
	["Update Log (2):"] = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(228, 233, 93)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(232, 157, 31))
	}),
	["Update Log (3):"] = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(170, 0, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(217, 0, 255))
	}),
	["Update Log (4):"] = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 98, 255))
	})
}
local container = script.Parent.Frame.Container
local template = script.Template
local v2 = {
	["Update Log (5):"] = 1,
	["Update Log (4):"] = 2,
	["Update Log (3):"] = 3,
	["Update Log (2):"] = 4,
	["Update Log (1):"] = 5
}

for k, v3 in pairs({
	["Update Log (4):"] = {
		"- Added 1 New Fighting Style",
		"- Added 3 New Weapons",
		"- Added 3 New Accessories",
		"- Added 2 New Power",
		"- Added 2 New Boats",
		"- Added 2 New Islands",
		"- Added 2 New Bosses",
		"- Added 2 New Leaderboards",
		"- Added Country Leaderboards",
		"- Added Raids System",
		"- Added Boosts System",
		"- Added Bounty/Fame Buffs in PvP",
		"- Added Aura Colors",
		"- Added New Codes",
		"- Added Bed Point System",
		"- Added Team Changer NPC",
		"- Improved Stats for All Accessories",
		"- Revamped All Powers and Weapons",
		"- Revamped All UI",
		"- Added More Options in Settings",
		"- Added Auto Enable Pvp Option",
		"- Improved Mobile Shiftlock",
		"- Made Mobile Buttons Better",
		"- Added Private Server Commands:",
		"◦ /kick [Player Username]",
		"◦ /shutdown",
		"– Increased Meme Beast Spawn Time (10m > 30m)",
		"– Increased Power Spawn Time (5m > 1h)",
		"- Increased Level Capacity to 2400"
	},
	["Update Log (3):"] = {
		"- Added 1 New Power",
		"- Added 3 New Weapons",
		"- Added 3 New Bosses",
		"- Added 2 New Accessories",
		"- Added 2 New Islands",
		"- Added Trade System",
		"- Added New Ability: Aura",
		"- Increased Level Capacity to 2,000"
	},
	["Update Log (2):"] = {
		"- Added 2 New Powers",
		"- Added 1 New Weapon",
		"- Added 2 New Bosses",
		"- Added 7 New Accessories",
		"- Added Race v2",
		"- Increased Level Capacity to 1,500"
	},
	["Update Log (1):"] = {
		"- Added 1 New Power",
		"- Added 1 New Weapon",
		"- Added 1 New Boss",
		"- Added 1 New Island",
		"- Added Code System",
		"- Increased Level Capacity to 1,250"
	}
}) do
	local clone = template:Clone()
	clone.Name = k
	clone.Text = tostring(k)
	clone.Font = Enum.Font.BuilderSansBold
	clone.TextColor3 = Color3.fromRGB(255, 255, 255)
	clone.UIGradient.Enabled = true
	clone.UIStroke.Enabled = true
	clone.UIGradient.Color = v[k]
	clone.UIStroke.UIGradient.Color = v[k]
	clone.LayoutOrder = v2[clone.Text]
	clone.Parent = container

	for k2, v4 in pairs(v3) do
		local clone2 = template:Clone()
		clone2.Name = `Update_{k}_{k2}`
		clone2.Text = tostring(v4)

		if string.find(clone2.Text, "◦") then
			clone2.TextTransparency = 0.1
		end

		clone2.LayoutOrder = clone.LayoutOrder
		clone2.Parent = container
		clone2.Visible = true
	end

	clone.Visible = true
end