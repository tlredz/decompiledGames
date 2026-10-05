local Realm = require(game.ReplicatedStorage.Util.Realm)
local Map = require(game.ReplicatedStorage.Definitions.Map)
require(game.ReplicatedStorage.Util.TypeUtil)
local currentMap = Map.findCurrentMap()
local v = { "rbxassetid://73063695637121", "rbxassetid://131363577936529", "rbxassetid://125746164639626" }
local colosseum1s = {
	["Starter Island"] = {
		0,
		0,
		0,
		Color3.fromHex("60aa58")
	},
	["Pirate Village"] = {
		0,
		1,
		0,
		Color3.fromHex("c3a172")
	},
	Prison = {
		0,
		2,
		0,
		Color3.fromHex("7b9eb4")
	},
	Sky = {
		0,
		3,
		0,
		Color3.fromHex("c1dddc")
	},
	["Upper Sky"] = {
		0,
		4,
		0,
		Color3.fromHex("c1dddc")
	},
	["Frozen Village"] = {
		0,
		5,
		0,
		Color3.fromHex("d7d5e7")
	},
	Underwater = {
		1,
		0,
		0,
		Color3.fromHex("d7d5e7")
	},
	Colosseum1 = {
		1,
		1,
		0,
		Color3.fromHex("d3b184")
	},
	Desert = {
		1,
		2,
		0,
		Color3.fromHex("f6d062")
	},
	Fountain = {
		1,
		3,
		0,
		Color3.fromHex("bab1a4")
	},
	Jungle = {
		1,
		4,
		0,
		Color3.fromHex("9ab223")
	},
	["Marine Fortress"] = {
		1,
		5,
		0,
		Color3.fromHex("c5b8b7")
	},
	["Starter Marine"] = {
		2,
		0,
		0,
		Color3.fromHex("6d7090")
	},
	["Middle Town"] = {
		2,
		1,
		0,
		Color3.fromHex("c6b58e")
	},
	Volcano = {
		2,
		2,
		0,
		Color3.fromHex("f0682e")
	},
	Cave = {
		0,
		0,
		1,
		Color3.fromHex("453231")
	},
	["Haunted Ship"] = {
		0,
		1,
		1,
		Color3.fromHex("275d4a")
	},
	["Green Zone"] = {
		0,
		2,
		1,
		Color3.fromHex("4f982d")
	},
	["Hot And Cold"] = {
		0,
		3,
		1,
		Color3.fromHex("a2bccd")
	},
	Remote = {
		0,
		4,
		1,
		Color3.fromHex("564a4f")
	},
	["Kingdom Of Rose"] = {
		0,
		5,
		1,
		Color3.fromHex("c89553")
	},
	["Forgotten Island"] = {
		1,
		0,
		1,
		Color3.fromHex("334071")
	},
	["Snow Mountain"] = {
		1,
		1,
		1,
		Color3.fromHex("c0c0c0")
	},
	["Docks 4"] = {
		1,
		2,
		1,
		Color3.fromHex("86c3c2")
	},
	["Docks 2"] = {
		1,
		3,
		1,
		Color3.fromHex("c1935b")
	},
	["Docks 3"] = {
		1,
		4,
		1,
		Color3.fromHex("55392e")
	},
	["Docks 1"] = {
		1,
		5,
		1,
		Color3.fromHex("a89654")
	},
	Raid = {
		2,
		0,
		1,
		Color3.fromHex("a47457")
	},
	Lab = {
		2,
		1,
		1,
		Color3.fromHex("383ace")
	},
	Doghouse = {
		2,
		2,
		1,
		Color3.fromHex("c32a1f")
	},
	Cafe = {
		2,
		3,
		1,
		Color3.fromHex("d2b350")
	},
	Colosseum = {
		2,
		4,
		1,
		Color3.fromHex("b8814c")
	},
	["Dark Arena"] = {
		2,
		5,
		1,
		Color3.fromHex("#6f2015")
	},
	Graveyard = {
		3,
		0,
		1,
		Color3.fromHex("#439671")
	},
	["Winter Castle"] = {
		3,
		1,
		1,
		Color3.fromHex("#6cb4bb")
	},
	["Cake Land"] = {
		0,
		0,
		2,
		Color3.fromHex("c44ea1")
	},
	["Sea Castle"] = {
		0,
		1,
		2,
		Color3.fromHex("c8c1c0")
	},
	["Chocolate Land"] = {
		0,
		2,
		2,
		Color3.fromHex("913c29")
	},
	["Christmas Land"] = {
		0,
		3,
		2,
		Color3.fromHex("c4c2c9")
	},
	["Great Tree"] = {
		0,
		4,
		2,
		Color3.fromHex("86dd57")
	},
	["Haunted Castle"] = {
		0,
		5,
		2,
		Color3.fromHex("9e77b0")
	},
	["Hydra Island"] = {
		1,
		0,
		2,
		Color3.fromHex("64ac31")
	},
	["Submerged Island"] = {
		1,
		1,
		2,
		Color3.fromHex("63aeeb")
	},
	Port = {
		1,
		2,
		2,
		Color3.fromHex("976047")
	},
	["Tiki Outpost"] = {
		1,
		3,
		2,
		Color3.fromHex("f4e1b5")
	},
	["Floating Turtle"] = {
		1,
		4,
		2,
		Color3.fromHex("4e8c46")
	},
	["Ice Cream Land"] = {
		2,
		0,
		2,
		Color3.fromHex("a25a32")
	},
	["Peanut Land"] = {
		1,
		5,
		2,
		Color3.fromHex("bd5c31")
	}
}
local colosseum

if Realm.getIfCurrentRealmHasTagAsync("IsSecondSea") then
	colosseum = colosseum1s.Colosseum
else
	colosseum = colosseum1s.Colosseum1
end

colosseum1s.Colosseum = colosseum
colosseum1s.Mansion = colosseum1s["Kingdom Of Rose"]
colosseum1s["Arena: " .. 1] = colosseum1s.Colosseum1
colosseum1s["Arena: " .. 2] = colosseum1s.Colosseum1
colosseum1s["Arena: " .. 3] = colosseum1s.Colosseum1
colosseum1s["Arena: " .. 4] = colosseum1s.Colosseum1
colosseum1s["Arena: " .. 5] = colosseum1s.Colosseum1
colosseum1s["Arena: " .. 6] = colosseum1s.Colosseum1
colosseum1s["Arena: " .. 7] = colosseum1s.Colosseum1
colosseum1s["Arena: " .. 8] = colosseum1s.Colosseum1
colosseum1s["Arena: " .. 9] = colosseum1s.Colosseum1
colosseum1s["Arena: " .. 10] = colosseum1s.Colosseum1
local snow

if Realm.getIfCurrentRealmHasTagAsync("IsSecondSea") then
	snow = colosseum1s["Snow Mountain"]
else
	snow = colosseum1s["Frozen Village"]
end

colosseum1s.Snow = snow
colosseum1s.Lava = colosseum1s["Hot And Cold"]
colosseum1s.Skull = colosseum1s["Forgotten Island"]
colosseum1s["Sea Of Treats"] = colosseum1s["Cake Land"]
colosseum1s["North Pole"] = colosseum1s["Christmas Land"]
colosseum1s["Turtle Mansion"] = colosseum1s["Floating Turtle"]
colosseum1s["Turtle Entrance"] = colosseum1s["Floating Turtle"]
colosseum1s["Turtle Center"] = colosseum1s["Floating Turtle"]
colosseum1s["Turtle Mountain"] = colosseum1s["Floating Turtle"]
colosseum1s["Hydra Town"] = colosseum1s["Hydra Island"]
colosseum1s["Hydra Arena"] = colosseum1s["Hydra Island"]
local name = nil
local scrollingFrame = script.Parent.MainContent.ScrollingFrame
local template = scrollingFrame.Template
local header = script.Parent.Header
local exit = header.Exit
local textLabel = header.TextLabel
local textLabel2 = textLabel.TextLabel

local function setIcon(p, value, flag: boolean?)
	local function apply(data, color: Color3?)
		if not data then
			p.Image = ""
			return
		end

		p.Image = data.Image
		p.ImageRectOffset = data.ImageRectOffset
		p.ImageRectSize = data.ImageRectSize
		local colorFade = p.Parent and p.Parent:FindFirstChild("ColorFade")

		if colorFade then
			colorFade.BackgroundColor3 = color or Color3.new(1, 1, 1)
		end
	end

	if type(value) == "string" then
		if currentMap then
			local islandsByReference = Map.getIslandsByReference(currentMap, "Any", value)

			if #islandsByReference == 1 then
				apply(islandsByReference[1].Display.Icon, islandsByReference[1].Display.Color)
				return
			end
		end

		local v4 = colosseum1s[value]

		if flag and not v4 then
			for k, v6 in colosseum1s do
				if not value:find(k, 1, true) then
					continue
				end

				v4 = v6
				break
			end
		end

		if not v4 then
			apply()
			return
		end

		local v5 = v4[3]
		local v6 = v4[2]
		local v7 = v4[1]
		local v8 = v4[4]
		apply({
			Image = v[v5 + 1],
			ImageRectOffset = Vector2.new(v6 * 150, v7 * 150),
			ImageRectSize = Vector2.new(150, 150)
		}, v8)
	elseif type(value) ~= "table" then
		apply()
	elseif value.Position == nil then
		apply(value.Display.Icon, value.Display.Color)
	else
		apply(value.Sprite)
	end
end

function getColor3Similarity(color: Color3, color2: Color3)
	local R = color.R
	local G = color.G
	local B = color.B
	local R2 = color2.R
	local G2 = color2.G
	local B2 = color2.B
	return 1 - math.sqrt((R2 - R) ^ 2 + (G2 - G) ^ 2 + (B2 - B) ^ 2) / 1.7320508075688772
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setTitle(text: string)
	textLabel.Text = text
	textLabel2.Text = text
end

local function setcolors(flag: boolean)
	local color = Color3.new(1, 0.839216, 0.192157)
	local color2 = Color3.new(1, 0.941176, 0.270588)
	local color3 = Color3.new(1, 0.945098, 0.341176)
	local color4 = Color3.new(1, 0.772549, 0.0784314)

	if flag then
		for _, descendant in script.Parent:GetDescendants(), nil, nil do
			local v4 = descendant
			pcall(function()
				if getColor3Similarity(v4.BorderColor3, color2) > 0.9 then
					v4.BorderColor3 = Color3.fromRGB(48, 158, 255)
				end

				if getColor3Similarity(v4.BorderColor3, color4) > 0.9 then
					v4.BorderColor3 = Color3.fromRGB(55, 108, 255)
				end
			end)
			local v5 = descendant
			pcall(function()
				if getColor3Similarity(v5.BackgroundColor3, color) > 0.9 then
					v5.BackgroundColor3 = Color3.fromRGB(116, 190, 255)
				end

				if getColor3Similarity(v5.BackgroundColor3, color3) > 0.9 then
					v5.BackgroundColor3 = Color3.fromRGB(148, 212, 255)
				end
			end)
		end
	else
		for _, descendant in script.Parent:GetDescendants(), nil, nil do
			local v4 = descendant
			pcall(function()
				if v4.BorderColor3 == Color3.fromRGB(48, 158, 255) then
					v4.BorderColor3 = color2
				end

				if v4.BorderColor3 == Color3.fromRGB(55, 108, 255) then
					v4.BorderColor3 = color4
				end
			end)
			local v5 = descendant
			pcall(function()
				if v5.BackgroundColor3 == Color3.fromRGB(116, 190, 255) then
					v5.BackgroundColor3 = color
				end

				if v5.BackgroundColor3 == Color3.fromRGB(148, 212, 255) then
					v5.BackgroundColor3 = color3
				end
			end)
		end
	end
end

local GatewayController = {
	setIcon = function(p, p2, flag: boolean?)
		setIcon(p, p2, flag)
	end,
	Clear = function()
		for _, button in pairs(scrollingFrame:GetChildren()) do
			if button.Name ~= "Template" and button:IsA("GuiButton") then
				button:Destroy()
			end
		end
	end
}

function GatewayController.LoadListAndAwaitSelection(items, p)
	name = nil
	setTitle("GATEWAY") -- equivalent call inferred; original call site unknown
	script.Parent.Visible = true
	GatewayController.Clear()

	for k, _ in pairs(items) do
		local clone = template:Clone()
		clone.TextName.Text = k
		clone.TextName.Position = UDim2.new(0.5, 0, 0.8, 0)
		clone.Name = k
		clone.Price.Visible = false
		clone.Visible = true
		clone.Parent = scrollingFrame
		setIcon(clone.IslandIcon, k)
		local v4 = k
		clone.MouseButton1Click:Connect(function()
			name = v4
		end)
	end

	setcolors(false)

	repeat
		task.wait()
	until name ~= nil or p and p.close

	script.Parent.Visible = false
	return name
end

function GatewayController.LoadPriceListAndAwaitSelection(items, p, value: string?)
	name = nil
	script.Parent.Visible = true
	setTitle(value or "SUBMARINE") -- equivalent call inferred; original call site unknown
	GatewayController.Clear()

	for _, item in pairs(items) do
		local clone = template:Clone()
		clone.TextName.Text = `{item.Name}`
		clone.Name = item.Name
		clone.Visible = true
		clone.Price.Text = `{item.TransportationPrice == 0 and "Free" or `${item.TransportationPrice}`}`
		clone.Parent = scrollingFrame
		setIcon(clone.IslandIcon, item.Name)
		local v5 = item
		clone.MouseButton1Click:Connect(function()
			name = v5.Name
		end)
	end

	setcolors(true)

	repeat
		task.wait()
	until name ~= nil or p and p.close

	script.Parent.Visible = false
	return name
end

exit.MouseButton1Click:Connect(function()
	name = false
end)
return GatewayController