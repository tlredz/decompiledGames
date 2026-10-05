local parent = script.Parent.Parent
local inventory = parent.Lobby.Screens.Inventory
local nav = inventory.Nav
local main = inventory.Main
local _ = parent.Lobby.Dock
local _ = {
	"Weapons",
	"Effects",
	"Perks",
	"Emotes",
	"Radios",
	"Toys",
	"Pets"
}
local weapons = inventory.Main.Weapons
local actions = weapons.Actions
local equipped = weapons.Equipped
local items = weapons.Items
local _ = actions.ActionContainer.Craft
local equip = actions.Equip
local craft = actions.Craft
local recycle = actions.Recycle
local _ = {
	[items] = {
		[equip] = {
			Size = items.Size,
			Position = items.Position
		},
		[craft] = {
			Size = UDim2.new(0, -427, 1, -155),
			Position = items.Position
		},
		[recycle] = {
			Size = UDim2.new(0, -427, 1, -200),
			Position = items.Position
		}
	},
	[actions] = {
		[equip] = {
			Size = actions.Size,
			Position = actions.Position
		},
		[craft] = {
			Size = UDim2.new(1, 0, 0, 160),
			Position = UDim2.new(0, 0, 1, -160)
		},
		[recycle] = {
			Size = UDim2.new(1, 0, 0, 205),
			Position = UDim2.new(0, 0, 1, -205)
		}
	},
	[equipped] = {
		[equip] = {
			Size = equipped.Size,
			Position = equipped.Position
		},
		[craft] = {
			Size = UDim2.new(0, 130, 1, -155),
			Position = UDim2.new(1, 0, 0, 0)
		},
		[recycle] = {
			Size = UDim2.new(0, 130, 1, -200),
			Position = equipped.Position
		}
	}
}
local v = false

for _, button in pairs(nav.Main:GetChildren()) do
	if not button:IsA("TextButton") then
		continue
	end

	local v2 = button
	button.MouseButton1Click:connect(function()
		if not v then
			v = true
			nav:TweenPosition(UDim2.new(-1, 0, 0, 0), "Out", "Quad", 0.2)
			main[v2.Name]:TweenPosition(UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.2)
			wait(0.2)
			v = false
		end
	end)
end

for _, child in pairs(main:GetChildren()) do
	local back = child:FindFirstChild("Back") or child:FindFirstChild("TitleBar") and (child.TitleBar:FindFirstChild("Back") or child.TitleBar.Container:FindFirstChild("Back"))

	if not back then
		continue
	end

	local v2 = child
	back.MouseButton1Click:connect(function()
		if not v then
			v = true
			nav:TweenPosition(UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.2)
			main[v2.Name]:TweenPosition(UDim2.new(1, 0, 0, 0), "Out", "Quad", 0.2)
			wait(0.2)
			v = false
		end
	end)
end

main.Radios.Equipped.Container.Songs.MouseButton1Click:connect(function()
	main.Radios:TweenPosition(UDim2.new(1, 0, 0, 0), "Out", "Quad", 0)
	main.Songs:TweenPosition(UDim2.new(0, 0, 0, 0), "Out", "Quad", 0)
end)