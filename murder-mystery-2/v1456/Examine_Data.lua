local parent = script.Parent.Parent
local examine = parent.Examine
local main = examine.Main
local _ = parent.Processing
local _ = game.ReplicatedStorage.Remotes
local radio = game.Players.LocalPlayer:GetAttribute("Radio")
local v = ""

-- equivalent calls inferred from this helper; original call sites unknown
local function GetImage(image)
	if _G.Cache[image] ~= nil then
		return _G.Cache[image]
	end

	local v2

	if tonumber(image) then
		v2 = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=" .. image or image
	else
		v2 = image
	end

	local v3 = v2 .. "&bust=" .. math.random(1, 10000)
	_G.Cache[image] = v3
	return v3
end

local ContextActionService = game:GetService("ContextActionService")
local names = {}

local function SetSelectionGroup(p)
	for _, v2 in pairs(names) do
		local GuiService = game:GetService("GuiService")
		GuiService:RemoveSelectionGroup(v2)
	end

	if p then
		local GuiService = game:GetService("GuiService")
		GuiService:AddSelectionParent(p.Name, p)
		table.insert(names, p.Name)
	end
end

local DatabaseCompatability = require(script:WaitForChild("DatabaseCompatability"))
local rarity = DatabaseCompatability.Rarity
local v2 = {
	Classic = 1,
	Common = 2,
	Uncommon = 3,
	Rare = 4,
	Legendary = 5,
	Godly = 6,
	Victim = 7,
	Unique = 7,
	Christmas = 1.5,
	Halloween = 1.6,
	Ancient = 6.5
}
local v3 = {
	Weapons = nil,
	Effects = nil,
	Perks = nil,
	Emotes = nil,
	Radios = nil,
	Pets = nil
}
local v4 = {
	"Weapons",
	"Perks",
	"Effects",
	"Pets"
}
local CopyTable

CopyTable = function(items)
	local result = {}

	for k, item in pairs(items) do
		if type(item) == "table" then
			item = CopyTable(item)
		end

		result[k] = item
	end

	return result
end

local function CreateWeaponFrame(guiObject, p, p2, value)
	local v5 = (guiObject:IsA("ImageLabel") or guiObject:IsA("ImageButton")) and guiObject or guiObject.Icon

	if p == nil then
		v5.Image = ""
		guiObject.ItemName.Text = ""

		if guiObject:FindFirstChild("Amount") then
			guiObject.Amount.Text = ""
		end
	else
		local v6 = DatabaseCompatability[value or "Weapons"][p]
		local image = GetImage(v6.Image) -- equivalent call inferred; original call site unknown
		v5.Image = image
		guiObject.ItemName.Text = v6.ItemName or v6.Name
		guiObject.ItemName.TextColor3 = v6.Rarity and rarity[v6.Rarity] or Color3.new(1, 1, 1)

		if tonumber(p2) and guiObject:FindFirstChild("Amount") then
			guiObject.Amount.Text = "x" .. p2
		end

		if guiObject:FindFirstChild("Rarity") then
			guiObject.Rarity.Text = v6.Rarity or ""
			guiObject.Rarity.TextColor3 = rarity[v6.Rarity] or Color3.new(1, 1, 1)
		end
	end
end

local function SortData(p)
	for _, v5 in pairs(v4) do
		local copyTable = CopyTable(p[v5])

		if copyTable == nil then
			continue
		end

		table.sort(copyTable.Owned, function(a, b)
			return a < b
		end)
		v3[v5] = copyTable
	end

	for _, v5 in pairs({ "Weapons", "Pets" }) do
		local copyTable = CopyTable(p[v5])
		local owned = {}

		for k, amount in pairs(copyTable.Owned) do
			table.insert(owned, {
				ItemID = k,
				Amount = amount
			})
		end

		local v8 = v5
		table.sort(owned, function(a, b)
			local v9 = { a.ItemID, b.ItemID }
			local v10 = { a.Amount, b.Amount }
			local v11 = { DatabaseCompatability[v8][v9[1]], DatabaseCompatability[v8][v9[2]] }
			local v12 = { v2[v11[1].Rarity], v2[v11[2].Rarity] }

			if v9[1] == "DefaultKnife" then
				return true
			end

			if v9[2] == "DefaultKnife" then
				return false
			end

			if v9[1] == "DefaultGun" then
				return true
			end

			if v9[2] == "DefaultGun" then
				return false
			end

			if v12[1] ~= v12[2] then
				return v12[1] > v12[2]
			end

			if v10[1] == v10[2] then
				return v11[1][v8 == "Weapons" and "ItemName" or "Name"] < v11[2][v8 == "Weapons" and "ItemName" or "Name"]
			end

			return v10[1] > v10[2]
		end)
		copyTable.Owned = owned
		v3[v5] = copyTable
	end
end

local _ = {
	Common = "Uncommon",
	Uncommon = "Rare",
	Rare = "Legendary"
}
local v5 = {
	Weapons = {
		FrameFunction = function(data, _, p)
			local weapon = DatabaseCompatability.Weapons[p.ItemID]
			data.Icon.Image = weapon.Image
			data.ItemName.Text = weapon.ItemName
			data.ItemName.TextColor3 = rarity[weapon.Rarity]
			data.Rarity.Text = weapon.Rarity
			data.Rarity.TextColor3 = rarity[weapon.Rarity]

			if p.Amount > 1 then
				data.Amount.Text = "x" .. p.Amount
			end
		end
	},
	Effects = {
		FrameFunction = function(data, _, p)
			local effect = DatabaseCompatability.Effects[p]
			data.Icon.Image = effect.Image
			data.Type.Text = effect.Type
			data.ItemName.Text = effect.Name
		end
	},
	Perks = {
		FrameFunction = function(p, _, p2)
			local perk = DatabaseCompatability.Perks[p2]
			local icon = p.Icon
			local image = GetImage(perk.Image) -- equivalent call inferred; original call site unknown
			icon.Image = image
			p.ItemName.Text = perk.Name
		end
	},
	Emotes = {
		FrameFunction = function(data, _, p)
			local emote = DatabaseCompatability.Emotes[p]
			data.ItemName.Text = emote.Name
			data.Icon.Image = emote.Image
			data.Type.Text = ""
		end
	},
	Radios = {
		FrameFunction = function(p, _, p2)
			local radio2 = DatabaseCompatability.Radios[p2]
			p.ItemName.Text = radio2.Name
			p.Icon.Image = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=" .. radio2.Image
		end
	},
	Toys = {
		FrameFunction = function(p, _, p2)
			local toy = DatabaseCompatability.Toys[p2]
			p.ItemName.Text = toy.Name
			local icon = p.Icon
			local image = GetImage(toy.Image) -- equivalent call inferred; original call site unknown
			icon.Image = image
		end
	},
	Pets = {
		FrameFunction = function(data, _, p)
			local pet = DatabaseCompatability.Pets[p.ItemID]
			local icon = data.Icon
			local image = GetImage(pet.Image) -- equivalent call inferred; original call site unknown
			icon.Image = image
			data.ItemName.Text = pet.Name
			data.ItemName.TextColor3 = rarity[pet.Rarity]
			data.Rarity.Text = pet.Rarity
			data.Rarity.TextColor3 = rarity[pet.Rarity]

			if p.Amount > 1 then
				data.Amount.Text = "x" .. p.Amount
			end

			data.MouseEnter:connect(function()
				data.Rarity.Visible = true
			end)
			data.MouseLeave:connect(function()
				data.Rarity.Visible = false
			end)
		end
	}
}

local function CreateGrid(p)
	if v3[p] == nil then
		return
	end

	local count = 0
	local scrollFrame = main[p].Items.ScrollFrame
	local container = scrollFrame.Container
	local v6 = not v5[p] and 0.2 or v5[p].Size or 0.2
	local fn = not v5[p] and function() end or v5[p].FrameFunction or function() end
	local Y = scrollFrame.CanvasPosition.Y
	local flag = false
	scrollFrame.Changed:connect(function()
		if flag then
			return
		end

		local Y2 = scrollFrame.CanvasPosition.Y

		if Y < Y2 then
			flag = true
			scrollFrame.CanvasPosition = Vector2.new(0, scrollFrame.CanvasPosition.Y + 20)
			local RunService = game:GetService("RunService")
			RunService.RenderStepped:wait()
			flag = false
		end

		Y = scrollFrame.CanvasPosition.Y
	end)
	container:ClearAllChildren()

	local function CreateFrame(k, p2)
		if p2 ~= "None" then
			local v7 = math.floor(count / (1 / v6))
			local v8 = count % (1 / v6)
			local clone = script.Item:Clone()
			clone.Parent = container
			clone.Size = UDim2.new(v6, 0, v6, 0)
			clone.Position = UDim2.new(clone.Size.X.Scale * v8, 0, 0, clone.AbsoluteSize.Y * v7)
			clone.Name = "Slot" .. count

			if k and p2 then
				fn(clone.Container, k, p2)
			end

			scrollFrame.CanvasSize = UDim2.new(0, 0, 0, (v7 + 1) * clone.AbsoluteSize.Y)
			count += 1
		end
	end

	if main[p]:FindFirstChild("BuyRadio") and radio then
		main[p].BuyRadio.Visible = false
	end

	for k, v7 in pairs(v3[p].Owned) do
		CreateFrame(k, v7)
	end
end

local v6 = true
local v7 = {
	{
		"Examine",
		Enum.KeyCode.ButtonA,
		{
			"Weapons",
			"Perks",
			"Effects",
			"Pets"
		},
		1
	}
}

local function Navigate(p, p2)
	if not v6 then
		return
	end

	v6 = false
	local v8 = v7[p]
	local _ = v8[3]
	local v9 = parent[v8[1]].Main[v8[3][v8[4]]]
	v7[p][4] = v8[4] + p2
	local v10 = (v8[4] - 1) % #v8[3] + 1
	local v11 = parent[v8[1]].Main[v8[3][v10]]

	for _, child in pairs(parent[v8[1]].Title.Nav:GetChildren()) do
		child.Style = child.Name == v11.Name and Enum.ButtonStyle.RobloxRoundDefaultButton or Enum.ButtonStyle.RobloxRoundButton
	end

	parent[v8[1]].Title.Title.Text = v .. "'s " .. v11.Name
	v11.Position = UDim2.new(p2, 0, 0, 0)
	v9:TweenPosition(UDim2.new(-p2, 0, 0, 0), "Out", "Quad", 0.2, false)
	v11:TweenPosition(UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.2, false)
	v7[p][4] = v10
	SetSelectionGroup(NexFrame)
	local GuiService = game:GetService("GuiService")
	GuiService.SelectedObject = v11.Items.ScrollFrame.Container:FindFirstChild("Slot0") and v11.Items.ScrollFrame.Container:FindFirstChild("Slot0").Container.Button or nil
	wait(0.2)
	v6 = true
end

function _G.Examine(p, p2)
	v = p2
	local GuiService = game:GetService("GuiService")
	local selectedObject = GuiService.SelectedObject
	local name, parent2

	if selectedObject then
		name = selectedObject.Name
		parent2 = selectedObject.Parent
	end

	SortData(p)

	for _, v8 in pairs(v4) do
		CreateGrid(v8)
	end

	if name and parent2 then
		local GuiService2 = game:GetService("GuiService")
		GuiService2.SelectedObject = parent2[name]
	end

	examine.Title.Title.Text = v .. "'s Weapons"
	SetSelectionGroup(examine.Main)
	local GuiService2 = game:GetService("GuiService")
	GuiService2.SelectedObject = examine.Main.Weapons.Items.ScrollFrame.Container:FindFirstChild("Slot0") and examine.Main.Weapons.Items.ScrollFrame.Container:FindFirstChild("Slot0").Container.Button or nil
	examine:TweenPosition(UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.2, false)

	local function fn() end

	ContextActionService:BindAction("NoX", function(_, p3)
		if p3 == Enum.UserInputState.Begin and not _G.PauseBinds then
			fn()
		end
	end, false, Enum.KeyCode.ButtonX)

	local function fn2() end

	ContextActionService:BindAction("NoB", function(_, p3)
		if p3 == Enum.UserInputState.Begin and not _G.PauseBinds then
			fn2()
		end
	end, false, Enum.KeyCode.ButtonB)
	game.Players.LocalPlayer:WaitForChild("PlayerGui"):SetTopbarTransparency(0)

	local function fn3()
		Navigate(1, 1)
	end

	ContextActionService:BindAction("NavRight", function(_, p3)
		if p3 == Enum.UserInputState.Begin and not _G.PauseBinds then
			fn3()
		end
	end, false, Enum.KeyCode.ButtonR1)

	local function fn4()
		Navigate(1, -1)
	end

	ContextActionService:BindAction("NavLeft", function(_, p3)
		if p3 == Enum.UserInputState.Begin and not _G.PauseBinds then
			fn4()
		end
	end, false, Enum.KeyCode.ButtonL1)
	parent.Leaderboard.Visible = false
	parent.Chat.Visible = false
	wait(0.2)
	ContextActionService:UnbindAction("NoB")

	local function fn5()
		ContextActionService:UnbindAction("NoX")
		ContextActionService:UnbindAction("NoB")
		ContextActionService:UnbindAction("NavLeft")
		ContextActionService:UnbindAction("NavRight")
		ContextActionService:UnbindAction("BuyCrateBundle")
		examine:TweenPosition(UDim2.new(0, 0, -1, -36), "Out", "Quad", 0.2, false)
		game.Players.LocalPlayer:WaitForChild("PlayerGui"):SetTopbarTransparency(0.5)
		parent.Leaderboard.Visible = true
		parent.Chat.Visible = true
		wait(0.2)
		ContextActionService:UnbindAction("Close")
		SetSelectionGroup(parent.Leaderboard)
		local GuiService3 = game:GetService("GuiService")
		GuiService3.SelectedObject = parent.Leaderboard.List.Player1.Container.Button
	end

	ContextActionService:BindAction("Close", function(_, p3)
		if p3 == Enum.UserInputState.Begin and not _G.PauseBinds then
			fn5()
		end
	end, false, Enum.KeyCode.ButtonB)
end