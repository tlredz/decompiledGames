-- failed to load script (decompiled with syntax error):
-- cBhGpMlmIGvjyZYwsFltRyhJl:104: Expected identifier when parsing expression, got ';'

local ViewProfileModule = {}
local InventoryModule = require(game.ReplicatedStorage.Modules.InventoryModule)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sync = require(ReplicatedStorage:WaitForChild("Database"):WaitForChild("Sync"))
local v = {
	[0] = "",
	[1] = "I",
	[2] = "II",
	[3] = "III",
	[4] = "IV",
	[5] = "V",
	[6] = "VI",
	[7] = "VII",
	[8] = "VIII",
	[9] = "IX",
	[10] = "X"
}
local RankIconsEmpty = require(game.ReplicatedStorage.RankIconsEmpty)
local v2 = { Color3.fromRGB(255, 170, 0), Color3.fromRGB(193, 218, 216), (Color3.fromRGB(139, 58, 0)) }
local ItemModule = require(script.Parent.ItemModule)
ViewProfileModule.GUI = {}
ViewProfileModule.PlayerInventories = {}

function ViewProfileModule.GenerateProfile(p, p2, data, p3)
	local profileContainer = ViewProfileModule.GUI.ProfileContainer
	local character = profileContainer.Character
	local container = profileContainer.Profile.Season1Stats.Container
	local trophies = profileContainer.Profile.Trophies
	local v3 = p2 == game.Players.LocalPlayer.Name and " (You)" or ""
	(profileContainer:FindFirstChild("Username") or profileContainer.Parent:FindFirstChild("Username")).Text = p2 .. v3
	local userThumbnailAsync = game.Players:GetUserThumbnailAsync(
		math.abs(game.Players[p2].userId),
		Enum.ThumbnailType.AvatarBust,
		Enum.ThumbnailSize.Size352x352
	)
	character.CharacterIcon.Image = userThumbnailAsync
	p.Nav.Profile.Icon.Image = userThumbnailAsync
	character.CharacterIcon.LevelFrame.LevelContainer.Icon.Level.Text = data.Level
	character.CharacterIcon.LevelFrame.LevelContainer.Icon.Image = RankIconsEmpty[data.Level]
	character.CharacterIcon.LevelFrame.LevelContainer.Prestige.Visible = data.Prestige > 0

	if data.Prestige > 0 then
		character.CharacterIcon.LevelFrame.LevelContainer.Prestige.Text = v[data.Prestige]
	end

	character.Elite.Visible = data.Elite == true
	character.Builder.Visible = data.MapBuilder == true
	character.WeaponDesigner.Visible = data.WeaponDesigner == true
	character.MM2Creator.Visible = data.Nikilis == true
	character.BetaTester.Visible = data.BetaTester == true
	character.Clown.Visible = data.Clown == true
	container.Eliminations.Amount.Text = data.Eliminations
	container.Saves.Amount.Text = data.Victories
	container.Survivals.Amount.Text = data.Survivals
	trophies.Visible = data.Trophies ~= nil

	for _, frame in trophies.Container:GetChildren() do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end

	if data.Trophies then
		for _, trophy in pairs(data.Trophies) do
			local clone = script.TrophyItem:Clone()
			local itemID = trophy.ItemID
			local rank = trophy.Rank
			clone.Container.Icon.Image = ItemModule.GetImage(Sync.Weapons[itemID].Image)
			clone.Container.Year.YearText.Text = Sync.Weapons[itemID].Year
			clone.ItemName.Label.Text = trophy.Rank and "Rank #" .. trophy.Rank or Sync.Weapons[itemID].ItemName

			if v2[rank] then
				clone.ItemName.BackgroundColor3 = v2[rank]
			end

			clone.Parent = trophies.Container
		end
	end

	ViewProfileModule.DisplayInventory(p, p2, p3)
end

local textChangedConnection = nil

function ViewProfileModule.DisplayInventory(p, p2, p3)
	for _, childName in pairs({
		"Weapons",
		"Effects",
		"Perks",
		"Emotes",
		"Radios",
		"Pets"
	}) do
		local title = p.Main:FindFirstChild(childName):FindFirstChild("Title")

		if title then
			title.Username.Text = p2 .. "'s " .. childName
		end

		for childName2, _ in pairs(InventoryModule.CreateBlankInventoryTable()[childName]) do
			;(p.Main:FindFirstChild(childName).Items.Container:FindFirstChild(childName2) or p.Main:FindFirstChild(childName).Items.Container:FindFirstChild("Holiday").Container:FindFirstChild(childName2)).Container:ClearAllChildren()
		end
	end

	local v3 = game.ReplicatedStorage.Remotes.Extras.GetFullInventory:InvokeServer(p2)
	local inventory = InventoryModule.GenerateInventory(p, v3, nil, p3)
	ViewProfileModule.PlayerInventories[p2] = inventory

	if textChangedConnection then
		textChangedConnection:disconnect()
	end

	local searchFrameTextBox = ViewProfileModule.GUI.SearchFrameTextBox
	textChangedConnection = searchFrameTextBox:GetPropertyChangedSignal("Text"):connect(function()
		local text = searchFrameTextBox.Text
		local v4 = string.gsub(text, "S", "")

		for _, weapon in pairs(inventory.Data.Weapons) do
			for _, v5 in pairs(weapon) do
				v5.Frame.Visible = string.find(string.lower(v5.Name), string.lower(v4))

				if v5.Frame.Parent.Parent:IsA("ScrollingFrame") then
					v5.Frame.Parent.Parent.CanvasPosition = Vector2.new(0, 0)
				else
					v5.Frame.Parent.Parent.Parent.Parent.CanvasPosition = Vector2.new(0, 0)
				end
			end
		end
	end)
end

function ViewProfileModule.DisplayInventoryFromData(p, p2, p3)
	for _, childName in pairs({
		"Weapons",
		"Effects",
		"Perks",
		"Emotes",
		"Radios",
		"Pets"
	}) do
		local title = p.Main:FindFirstChild(childName):FindFirstChild("Title")

		if title then
			title.Username.Text = p2 .. "'s " .. childName
		end

		for childName2, _ in pairs(InventoryModule.CreateBlankInventoryTable()[childName]) do
			;(p.Main:FindFirstChild(childName).Items.Container:FindFirstChild(childName2) or p.Main:FindFirstChild(childName).Items.Container:FindFirstChild("Holiday").Container:FindFirstChild(childName2)).Container:ClearAllChildren()
		end
	end

	local inventory = InventoryModule.GenerateInventory(p, p3)
	ViewProfileModule.PlayerInventories[p2] = inventory
end

function ViewProfileModule.DisplayInventoryFromProfile() end

function ViewProfileModule.ConnectViewProfile(p)
	InventoryModule.ConnectNavButtons(p.Nav, p.Main)
	InventoryModule.ConnectTabButtons(p, "Weapons")
end

return ViewProfileModule