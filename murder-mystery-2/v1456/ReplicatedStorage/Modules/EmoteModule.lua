local EmoteModule = {}

repeat
	task.wait()
until _G.EmoteController ~= nil

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sync = require(ReplicatedStorage:WaitForChild("Database"):WaitForChild("Sync"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ProfileData = require(ReplicatedStorage2:WaitForChild("Modules"):WaitForChild("ProfileData"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local remotes = ReplicatedStorage3:WaitForChild("Remotes")
local v = {}
local v2 = {}
_G.EmotePages = {}
_G.CurrentPage = ""
EmoteModule.EmoteGUI = nil
local UserInputService = game:GetService("UserInputService")

-- equivalent calls inferred from this helper; original call sites unknown
local function GetImage(image)
	if _G.Cache[image] ~= nil then
		return _G.Cache[image]
	end

	local v3

	if tonumber(image) then
		v3 = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=" .. image or image
	else
		v3 = image
	end

	local v4 = v3 .. "&bust=" .. math.random(1, 10000)
	_G.Cache[image] = v4
	return v4
end

function EmoteModule.GeneratePage(items, p, name, _, _)
	local clone = script.Page:Clone()
	local clone2 = script.Container:Clone()
	clone2.Parent = clone
	clone.Name = name
	clone.Parent = p.EmotePages
	local v3 = {}

	for k, item in pairs(items) do
		v3[k] = item
	end

	table.insert(v3, 1, "")
	table.insert(v3, 2, "")
	v[name] = {}
	local v4 = #v3 - 2
	clone2.Size = UDim2.new(v4, 0, 1, 0)
	clone2:ClearAllChildren()
	local text = 3

	for _, name2 in v3 do
		local v7 = Sync.Emotes[name2] or Sync.Toys[name2]

		if not v7 then
			continue
		end

		local clone3 = script.Emote:Clone()
		clone3.Size = UDim2.new(1 / v4, 0, 1, 0)
		clone3.Position = UDim2.new(1 / v4 * (text - 1 - 1 - 1), 0, 0, 0)
		clone3.Name = name2
		clone3.Parent = clone2
		local icon = clone3.Container.Icon
		local image = GetImage(v7.Image) -- equivalent call inferred; original call site unknown
		icon.Image = image
		clone3.Container.EmoteName.Text = v7.Name
		clone3.Container.Hotkey.Text = text
		clone3.Container.Hotkey.Visible = UserInputService.KeyboardEnabled
		local v9 = name2
		clone3.Container.Button.MouseButton1Click:Connect(function()
			game.ReplicatedStorage.Remotes.Misc.PlayEmote:Fire(v9)
		end)
		v[name][text] = name2
		text += 1
	end

	table.insert(_G.EmotePages, name)
	local clone3 = script.Back:Clone()
	clone3.Size = UDim2.new(1 / v4, 0, 1, 0)
	local icon = clone3.Container.Icon
	local UserInputService2 = game:GetService("UserInputService")
	icon.Visible = not UserInputService2.GamepadEnabled
	local bButton = clone3.Container.BButton
	local UserInputService3 = game:GetService("UserInputService")
	bButton.Visible = UserInputService3.GamepadEnabled
	local hotkey = clone3.Container.Hotkey
	local UserInputService4 = game:GetService("UserInputService")
	hotkey.Visible = UserInputService4.KeyboardEnabled
	clone3.Parent = clone2
end

function EmoteModule.ShowPage(p)
	_G.EmoteController.Emotes = { nil, "Back" }

	for k, v3 in pairs(v[p]) do
		_G.EmoteController.Emotes[k] = v3
	end

	for _, child in pairs(EmoteModule.EmoteGUI.EmotePages:GetChildren()) do
		child.Visible = child.Name == p
	end

	_G.CurrentPage = p
	EmoteModule.EmoteGUI.PageName.Text = p
	task.wait()

	if UserInputService:GetLastInputType() == Enum.UserInputType.Gamepad1 and EmoteModule.EmoteGUI.Visible then
		local GuiService = game:GetService("GuiService")
		GuiService.SelectedObject = EmoteModule.EmoteGUI.EmotePages[p].Container:GetChildren()[1].Container.Button
	end
end

function _G.ChangePage(p)
	for k, emotePage in _G.EmotePages do
		if k == p then
			EmoteModule.ShowPage(emotePage)
		end
	end
end

function EmoteModule.GenerateEmotes(list, p)
	v = {}
	_G.EmotePages = {}
	_G.CurrentPage = ""
	p.EmotePages:ClearAllChildren()

	if #list > 0 then
		if #list > 6 then
			local v3 = {}
			local v4 = 0

			for k, v5 in pairs(list) do
				v4 = math.floor(k / 6) + 1
				v3[v4] = v3[v4] or {}
				table.insert(v3[v4], v5)
			end

			local v5 = nil

			for k, v6 in pairs(v3) do
				local v7 = "Your Emotes (" .. k .. "/" .. v4 .. ")"
				EmoteModule.GeneratePage(v6, p, v7)

				if k == 1 then
					v5 = v7
				end
			end

			EmoteModule.GeneratePage({
				"wave",
				"cheer",
				"laugh",
				"dance1",
				"dance2",
				"dance3"
			}, p, "Roblox Emotes")
			EmoteModule.ShowPage(v5, p)
		else
			EmoteModule.GeneratePage(list, p, "Your Emotes")
			EmoteModule.GeneratePage({
				"wave",
				"cheer",
				"laugh",
				"dance1",
				"dance2",
				"dance3"
			}, p, "Roblox Emotes")
			EmoteModule.ShowPage("Your Emotes", p)
		end
	else
		EmoteModule.GeneratePage({
			"wave",
			"cheer",
			"laugh",
			"dance1",
			"dance2",
			"dance3"
		}, p, "Roblox Emotes")
		EmoteModule.GeneratePage(list, p, "Your Emotes")
		EmoteModule.ShowPage("Roblox Emotes", p)
	end

	v2 = {}

	for _, v3 in pairs(list) do
		v2[v3] = true
	end
end

function EmoteModule.SetupPageButtons()
	local UserInputService2 = game:GetService("UserInputService")
	local visible = UserInputService2:GetLastInputType() == Enum.UserInputType.Gamepad1
	local v4 = not visible
	EmoteModule.EmoteGUI.Left.Text = visible and "" or v4 and "< Q" or "<"
	EmoteModule.EmoteGUI.Right.Text = visible and "" or v4 and "E >" or ">"

	if EmoteModule.EmoteGUI.Left:FindFirstChild("ButtonIcon") then
		EmoteModule.EmoteGUI.Left.ButtonIcon.Visible = visible
		EmoteModule.EmoteGUI.Right.ButtonIcon.Visible = visible
	end

	EmoteModule.EmoteGUI.Left.MouseButton1Click:Connect(_G.EmotePageLeft)
	EmoteModule.EmoteGUI.Right.MouseButton1Click:Connect(_G.EmotePageRight)
end

remotes:WaitForChild("Inventory"):WaitForChild("InventoryDataChanged").Event:Connect(function(p, _, _)
	if p == "Emotes" or p == "Toys" then
		for _, v3 in ProfileData.Emotes.Owned do
			if v2[v3] ~= nil then
				continue
			end

			EmoteModule.GenerateEmotes(ProfileData.Emotes.Owned, EmoteModule.EmoteGUI)
			return
		end
	end
end)
return EmoteModule