local localPlayer = game.Players.LocalPlayer
local v = {}
local v2 = {}
local clones = {}
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
game:GetService("GamepadService")
game:GetService("TweenService")
local inputContext = game.Players.LocalPlayer.PlayerGui:WaitForChild("InputContext")
local gameplayContext = inputContext:WaitForChild("GameplayContext")
local emoteContext = inputContext:WaitForChild("EmoteContext")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage:WaitForChild("Database"):WaitForChild("Sync"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ProfileData = require(ReplicatedStorage2:WaitForChild("Modules"):WaitForChild("ProfileData"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local remotes = ReplicatedStorage3:WaitForChild("Remotes")
local ReplicatedStorage4 = game:GetService("ReplicatedStorage")
local ItemService = require(ReplicatedStorage4:WaitForChild("ClientServices"):WaitForChild("ItemService"))
local ReplicatedStorage5 = game:GetService("ReplicatedStorage")
local playEmote = ReplicatedStorage5:WaitForChild("Remotes"):WaitForChild("Misc"):WaitForChild("PlayEmote")
local emoteWindow = script.Parent:WaitForChild("EmoteWindow")
local emoteContainer = emoteWindow:WaitForChild("EmoteContainer")
emoteContainer:WaitForChild("VerticalNavigation")
local emotePages = emoteContainer:WaitForChild("EmotePages")
local avatarEmotes = emotePages:WaitForChild("Avatar Emotes")
local gameEmotes = emotePages:WaitForChild("Game Emotes")
local emoteNavigation = emoteWindow:WaitForChild("EmoteNavigation")
local v3 = { avatarEmotes, gameEmotes }
local emoteFrame = emotePages:WaitForChild("Game Emotes"):WaitForChild("Row1"):WaitForChild("EmoteFrame")
local rowFrame = script:WaitForChild("RowFrame")
local v4 = false
local humanoid = nil
local v5 = 8
local X = emoteFrame.AbsoluteSize.X
local v6 = {
	[avatarEmotes] = 0,
	[gameEmotes] = 0
}
local layoutOrder2 = 1
TweenInfo.new(0.2, Enum.EasingStyle.Sine)

-- equivalent calls inferred from this helper; original call sites unknown
local function updateEmoteContainerEnabled()
	emoteContext.Sink = v4
	emoteWindow.Visible = v4

	if UserInputService.PreferredInput == Enum.PreferredInput.Gamepad then
		if v4 then
			GuiService:Select(emotePages.UIPageLayout.CurrentPage.UIPageLayout.CurrentPage)
		else
			GuiService.SelectedObject = nil
			inputContext.GameplayContext.Emotes:Fire(false)
		end
	end
end

local function onEmoteButtonPressed()
	v4 = not v4
	updateEmoteContainerEnabled() -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playAvatarEmote(p: string)
	v4 = false
	updateEmoteContainerEnabled() -- equivalent call inferred; original call site unknown
	humanoid:PlayEmote(p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playGameEmote(p: string)
	v4 = false
	updateEmoteContainerEnabled() -- equivalent call inferred; original call site unknown
	playEmote:Fire(p)
end

local function addGameEmotes()
	for _, v8 in ProfileData.Emotes.Owned do
		if clones[v8] then
			continue
		end

		local itemInfo = ItemService:GetItemInfo(v8, "Emotes")

		if not itemInfo then
			continue
		end

		local layoutOrder = math.floor((layoutOrder2 - 1) / v5) + 1
		local text = (layoutOrder2 - 1) % v5 + 1
		local clone = emoteFrame:Clone()
		clone.Name = "Emote" .. text
		clone:SetAttribute("EmoteName", v8)
		clone.EmoteName.Text = itemInfo.Name or v8
		clone.EmoteIcon.Image = ItemService:GetItemImage(itemInfo)
		clone.Hotkey.KeyLabel.Text = text
		clone.Hotkey.Visible = UserInputService.KeyboardEnabled
		clone.LayoutOrder = layoutOrder2
		local v11 = v8
		clone.PlayButton.Activated:Connect(function()
			playGameEmote(v11) -- equivalent call inferred; original call site unknown
		end)
		local clone2 = gameEmotes:FindFirstChild("Row" .. layoutOrder)

		if not clone2 then
			clone2 = rowFrame:Clone()
			clone2.Name = "Row" .. layoutOrder
			clone2.Parent = gameEmotes
		end

		clone2.LayoutOrder = layoutOrder
		v6[gameEmotes] = layoutOrder
		clone.Parent = clone2
		clones[v8] = clone
		layoutOrder2 += 1
	end
end

local function onCharacterAdded(character)
	v4 = false
	updateEmoteContainerEnabled() -- equivalent call inferred; original call site unknown
	humanoid = character:WaitForChild("Humanoid")
	local appliedDescription = humanoid:GetAppliedDescription()
	table.clear(v)
	table.clear(v2)

	for k, v8 in appliedDescription:GetEmotes() do
		v[k] = {
			Image = `rbxthumb://type=Asset&w=150&h=150&id={v8[1]}`,
			Slot = nil
		}
	end

	for _, v8 in appliedDescription:GetEquippedEmotes() do
		local name = v8.Name

		if not v[name] or table.find(v2, name) then
			continue
		end

		v[name].Slot = v8.Slot
		table.insert(v2, v8.Slot, name)
	end

	for k, _ in v do
		if not table.find(v2, k) then
			table.insert(v2, k)
		end
	end

	for _, frame in avatarEmotes:GetChildren() do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end

	for count, text in v2 do
		local layoutOrder = math.floor((count - 1) / v5) + 1
		local v10 = (count - 1) % v5 + 1
		local clone = emoteFrame:Clone()
		clone.Name = "Emote" .. v10
		clone:SetAttribute("EmoteName", text)
		clone.EmoteName.Text = text
		clone.EmoteIcon.Image = v[text].Image
		clone.Hotkey.KeyLabel.Text = v10
		clone.Hotkey.Visible = UserInputService.KeyboardEnabled
		clone.LayoutOrder = v10
		local v11 = text
		clone.PlayButton.Activated:Connect(function()
			playAvatarEmote(v11) -- equivalent call inferred; original call site unknown
		end)
		local clone2 = avatarEmotes:FindFirstChild("Row" .. layoutOrder)

		if not clone2 then
			clone2 = rowFrame:Clone()
			clone2.Name = "Row" .. layoutOrder
			clone2.Parent = avatarEmotes
		end

		clone2.LayoutOrder = layoutOrder
		v6[avatarEmotes] = layoutOrder
		clone.Parent = clone2
		count += 1
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateTitleText()
	local currentPage = emotePages.UIPageLayout.CurrentPage
	local currentPage2 = currentPage.UIPageLayout.CurrentPage
	local name = currentPage.Name
	local layoutOrder = currentPage2.LayoutOrder
	local v8 = v6[currentPage]
	emoteNavigation.Title.TextLabel.Text = `{name} ({layoutOrder}/{v8})`
end

local function onPreferredInputChanged()
	local keycodeLabel = emoteNavigation:WaitForChild("SwapFrame"):WaitForChild("Container"):WaitForChild("KeycodeLabel")
	keycodeLabel.Visible = UserInputService.PreferredInput == Enum.PreferredInput.KeyboardAndMouse
	local keycodeLabel_2 = emoteNavigation:WaitForChild("Up"):WaitForChild("Container"):WaitForChild("KeycodeLabel")
	keycodeLabel_2.Visible = UserInputService.PreferredInput == Enum.PreferredInput.KeyboardAndMouse
	local keycodeLabel_3 = emoteNavigation:WaitForChild("Down"):WaitForChild("Container"):WaitForChild("KeycodeLabel")
	keycodeLabel_3.Visible = UserInputService.PreferredInput == Enum.PreferredInput.KeyboardAndMouse
end

local function onInitialize()
	emoteFrame.Parent = script
	emotePages["Game Emotes"].Row1:Destroy()
	v4 = false
	updateEmoteContainerEnabled() -- equivalent call inferred; original call site unknown
	v5 = math.clamp(math.floor(emotePages.AbsoluteSize.X / (X + 5)), 0, 8)

	for _, child in emoteContext:GetChildren() do
		if string.sub(child.Name, 1, 5) ~= "Emote" then
			continue
		end

		local v9 = tonumber((string.sub(child.Name, 6)))
		child.Pressed:Connect(function()
			if not v4 then
				return
			end

			local currentPage = emotePages.UIPageLayout.CurrentPage
			local child2 = currentPage.UIPageLayout.CurrentPage:FindFirstChild("Emote" .. v9)

			if not child2 then
				return
			end

			local emoteName = child2:GetAttribute("EmoteName")

			if currentPage == gameEmotes then
				playGameEmote(emoteName) -- equivalent call inferred; original call site unknown
			elseif currentPage == avatarEmotes then
				playAvatarEmote(emoteName) -- equivalent call inferred; original call site unknown
			end
		end)
	end

	emoteContext:WaitForChild("ScrollRight").Pressed:Connect(function()
		if not v4 then
			return
		end

		emotePages.UIPageLayout:Next()
		updateTitleText() -- equivalent call inferred; original call site unknown
	end)
	emoteContext:WaitForChild("ScrollLeft").Pressed:Connect(function()
		if not v4 then
			return
		end

		emotePages.UIPageLayout:Previous()
		updateTitleText() -- equivalent call inferred; original call site unknown
	end)
	emoteContext:WaitForChild("ScrollUp").Pressed:Connect(function()
		if not v4 then
			return
		end

		emotePages.UIPageLayout.CurrentPage.UIPageLayout:Previous()
		updateTitleText() -- equivalent call inferred; original call site unknown
	end)
	emoteContext:WaitForChild("ScrollDown").Pressed:Connect(function()
		if not v4 then
			return
		end

		emotePages.UIPageLayout.CurrentPage.UIPageLayout:Next()
		updateTitleText() -- equivalent call inferred; original call site unknown
	end)

	for _, v8 in v3 do
		local v9 = v8
		v8.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseWheel then
				if input.Position.Z > 0 then
					v9.UIPageLayout:Previous()
				else
					v9.UIPageLayout:Next()
				end
			end
		end)
	end

	repeat
		task.wait()
	until localPlayer.Character ~= nil

	onCharacterAdded(localPlayer.Character)
	localPlayer.CharacterAdded:Connect(onCharacterAdded)
	gameplayContext:WaitForChild("Emotes").Pressed:Connect(onEmoteButtonPressed)
	addGameEmotes()
	remotes:WaitForChild("Inventory"):WaitForChild("InventoryDataChanged").Event:Connect(function(p, _, _)
		if p ~= "Emotes" and p ~= "Toys" then
			return
		end

		addGameEmotes()
	end)

	if GuiService:IsTenFootInterface() then
		emoteWindow.Position = UDim2.new(0.5, 0, 1, -100)
		emoteWindow.UIScale.Scale = 1.33
	end

	onPreferredInputChanged()
	UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(onPreferredInputChanged)
	emoteContext:WaitForChild("Cancel").Pressed:Connect(function()
		v4 = false
		updateEmoteContainerEnabled() -- equivalent call inferred; original call site unknown
	end)
	local textLabel = emoteNavigation:WaitForChild("Title"):WaitForChild("TextLabel")
	textLabel.Text = emotePages:WaitForChild("UIPageLayout").CurrentPage.Name
	updateTitleText() -- equivalent call inferred; original call site unknown
end

onInitialize()