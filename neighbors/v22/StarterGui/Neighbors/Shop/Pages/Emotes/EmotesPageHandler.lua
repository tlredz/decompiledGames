game:GetService("StarterGui")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local shop = script:FindFirstAncestor("Shop")
local _ = shop.Parent.Parent
local inspectItemPage = shop.InspectItemPage
local inspectItem = inspectItemPage.InspectItem
local parent = script.Parent
local example = script.Example
local UI = require(ReplicatedStorage.Modules.UI)
require(game.ReplicatedStorage.Assets.Data.UIData.RandomUITypes)
local Data = require(game.ReplicatedStorage.Modules.Data)
require(ReplicatedStorage.Modules.Server)
local Emotes = require(ReplicatedStorage.Assets.Data.Store.Emotes)
require(ReplicatedStorage.Modules.ThumbnailGenerator)
local Case = require(ReplicatedStorage.Assets.Data.Case)
local Network = require(ReplicatedStorage.Modules.Network)
local localPlayer = Players.LocalPlayer
local Radial = require(localPlayer.PlayerGui:WaitForChild("EmoteWheel"):WaitForChild("Radial"))
local titles = {}
Data.Inventory:WaitFor("Get")
Data.Emotes:WaitFor("Get")
local bindableEvent = Instance.new("BindableEvent")
local scale = 1
local v2 = 5

local function updateTemplateSize(p: number, p2: number)
	local v3 = 4 + parent.UIPadding.PaddingLeft.Offset + parent.UIPadding.PaddingRight.Offset
	local v4 = shop.Size.X.Offset + shop.Pages.Size.X.Offset + parent.Size.X.Offset - v3
	local offset = example.Size.X.Offset
	local v5 = (p - 1) * p2
	local v6 = p * offset
	local v7 = (v4 - v5) / v6
	example.UIStroke.Thickness /= v7
	scale = v7
	v2 = p2
end

if UserInputService.TouchEnabled then
	updateTemplateSize(4, 6)
else
	updateTemplateSize(5, 5)
end

local function GetShopEmotes()
	return Emotes
end

local function GetEquippedEmotes()
	local result = {}

	for k, item in Data.Emotes.Items do
		if item.Slot then
			result[k] = item
		end
	end

	return result
end

local function GetFavoriteEmotes()
	local result = {}

	for k, item in Data.Emotes.Items do
		if item.Favorited then
			result[k] = item
		end
	end

	return result
end

local function IsEmoteEquipped(p: string)
	local v3 = {}

	for k, item in Data.Emotes.Items do
		if item.Slot then
			v3[k] = item
		end
	end

	return v3[p] ~= nil
end

local function IsEmoteFavorited(p: string)
	local v3 = {}

	for k, item in Data.Emotes.Items do
		if item.Favorited then
			v3[k] = item
		end
	end

	return v3[p] ~= nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetEmoteInternalName(p)
	for k, emote in Emotes do
		if emote == p then
			return k
		end
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function DoesOwnEmote(p)
	local emoteInternalName = GetEmoteInternalName(p) -- equivalent call inferred; original call site unknown
	return Data.Emotes:Get(emoteInternalName)
end

local function IsWithinTimePeriod(p, p2: number)
	return p.Start < p2 and p2 < p.End
end

-- equivalent calls inferred from this helper; original call sites unknown
local function IsEmoteAvaliable(_)
	os.time()
	return true
end

local function CommaValue(p: number)
	return string.format("%0.0f", p):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

local function CreateEmoteCategory(text: string)
	local categoryList = UI:CreateCategoryList(parent)
	categoryList.List.UIListLayout.Padding = UDim.new(0, v2)
	categoryList.Collapsible.InfoContainer.Title.Text = text
	categoryList.Name = text:lower():gsub(" ", "")

	local function GetEmoteCount()
		local count = 0

		for _, button in categoryList.List:GetChildren() do
			if button:IsA("ImageButton") and button.Visible then
				count += 1
			end
		end

		return count
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function UpdateVisibility()
		categoryList.Visible = GetEmoteCount() > 0
	end

	categoryList.List.ChildAdded:Connect(function(button)
		UpdateVisibility() -- equivalent call inferred; original call site unknown

		if button:IsA("ImageButton") then
			button:GetPropertyChangedSignal("Visible"):Connect(function()
				UpdateVisibility() -- equivalent call inferred; original call site unknown
			end)
		end
	end)
	categoryList.List.ChildRemoved:Connect(function()
		UpdateVisibility() -- equivalent call inferred; original call site unknown
	end)
	UpdateVisibility() -- equivalent call inferred; original call site unknown
	return categoryList
end

local camera = Instance.new("Camera")
camera.CFrame = CFrame.new(0, 0, -350) * CFrame.Angles(0, 3.141592653589793, 0)
camera.FieldOfView = 1
local viewportFrame = Instance.new("ViewportFrame")
viewportFrame.Size = UDim2.fromScale(1, 1)
viewportFrame.CurrentCamera = camera
viewportFrame.Name = "EmoteDisplay"
viewportFrame.BackgroundTransparency = 1
local worldModel = Instance.new("WorldModel", viewportFrame)
local clone = ReplicatedStorage.Assets.Models.Dummy:Clone()
clone:PivotTo(CFrame.new(0, -2.5, 0))
clone.Parent = worldModel
local clone2 = camera:Clone()
clone2.Parent = inspectItem.Item
local clone3 = viewportFrame:Clone()
clone3.Visible = false
clone3.Parent = inspectItem.Item
clone3.CurrentCamera = clone2

local function CreateEmote(data)
	local clone4 = example:Clone()
	clone4.Icon.ImageTransparency = 1
	clone4.Visible = true
	clone4.Rarity.Visible = true
	clone4.Rarity.BackgroundColor3 = Case:GetColors()[data.Rarity]
	clone4.Name = data.Name
	clone4.UIScale.Scale = scale
	clone4.Size = UDim2.new(0, example.Size.X.Offset, 0, example.Size.Y.Offset * clone4.UIScale.Scale)
	local footer = clone4.Footer
	clone4.ItemName.Title.Text = data.Display
	local amount = footer.Credits.Amount
	local price = data.Price
	amount.Text = `${string.format("%0.0f", price):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")}`

	if not DoesOwnEmote(data.Name) and data.Offsale then
		clone4.Visible = not data.Offsale
	end

	local function UpdateViewport()
		if clone4.Icon:FindFirstChild(viewportFrame.Name) then
			if clone4:GetAttribute("Enabled") then
				return
			else
				clone4.Icon[viewportFrame.Name]:Destroy()
			end
		end

		if not clone4:GetAttribute("Enabled") then
			return
		end

		local clone5 = viewportFrame:Clone()
		local dummy = clone5:FindFirstChild("WorldModel"):FindFirstChild("Dummy")
		local animation = Instance.new("Animation", dummy)
		animation.AnimationId = `rbxassetid://{data.AnimationId}`
		task.defer(function()
			local track = dummy:WaitForChild("Controller", 1e999):LoadAnimation(animation)
			track.Looped = true
			track:Play(0)

			if UserInputService.TouchEnabled then
				track.TimePosition = track.Length * 0.5
				track:AdjustSpeed(0)
			end
		end)
		clone5.ZIndex = -100000
		clone5.Parent = clone4.Icon
	end

	clone4:GetAttributeChangedSignal("Enabled"):Connect(UpdateViewport)
	return clone4
end

local function GetFramePositionInScrollingFrame(p, p2)
	local absolutePosition = p.AbsolutePosition
	local canvasPosition = p2.CanvasPosition
	return absolutePosition - p2.AbsolutePosition + Vector2.new(canvasPosition.X, canvasPosition.Y)
end

local function UpdateEmotePreview(data)
	local doesOwnEmote = DoesOwnEmote(data) -- equivalent call inferred; original call site unknown
	local v4 = {}

	for k, item in Data.Emotes.Items do
		if item.Slot then
			v4[k] = item
		end
	end

	local emoteInternalName = GetEmoteInternalName(data) -- equivalent call inferred; original call site unknown
	local visible = v4[emoteInternalName]
	local v7 = {}

	for k, item in Data.Emotes.Items do
		if item.Favorited then
			v7[k] = item
		end
	end

	local emoteInternalName2 = GetEmoteInternalName(data) -- equivalent call inferred; original call site unknown
	local visible2 = v7[emoteInternalName2]
	inspectItemPage.Visible = true
	inspectItem.Description.Text = "Just your typical Neighbors emote!"
	local price = inspectItem.Price
	local price2 = data.Price
	price.Text = `{string.format("%0.0f", price2):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")}`
	inspectItem.Item.ItemImage.Visible = false
	inspectItem.Item.Title.Visible = false
	inspectItem.ItemName.Text = `{data.Display}`

	if doesOwnEmote then
		inspectItem.Buttons.Bind.Visible = not visible
		inspectItem.Buttons.Rebind.Visible = visible
		inspectItem.Buttons.Favorite.Visible = not visible2
		inspectItem.Buttons.Unfavorite.Visible = visible2
		inspectItem.Price.Visible = false
	else
		inspectItem.Buttons.Purchase.Visible = true
	end

	local dummy = clone3.WorldModel.Dummy
	clone3.Visible = true

	if dummy:FindFirstChild("Animation") then
		dummy.Animation:Destroy()
	end

	local animation = Instance.new("Animation", dummy)
	animation.AnimationId = `rbxassetid://{data.AnimationId}`
	task.wait()
	local track = dummy.Controller:LoadAnimation(animation)
	track.Looped = true
	track:Play()
	local connections = {}
	table.insert(connections, inspectItem.Buttons.Bind.MouseButton1Click:Connect(function()
		if doesOwnEmote then
			local emoteInternalName3 = GetEmoteInternalName(data) -- equivalent call inferred; original call site unknown
			Radial:StartBinding(emoteInternalName3)
			inspectItemPage.Visible = false
		end
	end))
	table.insert(connections, inspectItem.Buttons.Rebind.MouseButton1Click:Connect(function()
		if doesOwnEmote then
			local emoteInternalName3 = GetEmoteInternalName(data) -- equivalent call inferred; original call site unknown
			Radial:StartBinding(emoteInternalName3)
			inspectItemPage.Visible = false
		end
	end))
	table.insert(connections, inspectItem.Buttons.Purchase.MouseButton1Click:connect(function()
		local emoteInternalName3 = GetEmoteInternalName(data) -- equivalent call inferred; original call site unknown
		Network:fire("PurchaseEmote", emoteInternalName3)

		if localPlayer:GetAttribute("Credits") >= data.Price then
			inspectItemPage.Visible = false
		end
	end))
	table.insert(connections, inspectItem.Buttons.Favorite.MouseButton1Click:connect(function()
		local emoteInternalName3 = GetEmoteInternalName(data) -- equivalent call inferred; original call site unknown
		Network:fire("FavoriteEmote", emoteInternalName3)
		inspectItemPage.Visible = false
	end))
	table.insert(connections, inspectItem.Buttons.Unfavorite.MouseButton1Click:connect(function()
		local emoteInternalName3 = GetEmoteInternalName(data) -- equivalent call inferred; original call site unknown
		Network:fire("FavoriteEmote", emoteInternalName3)
		inspectItemPage.Visible = false
	end))
	inspectItemPage:GetPropertyChangedSignal("Visible"):Once(function()
		for _, connection in connections do
			connection:Disconnect()
		end

		track:Stop()
		track:Destroy()
		clone3.Visible = false
	end)
end

local v3 = {}

local function CreateEmoteList()
	local v4 = Emotes
	local emoteCategory = CreateEmoteCategory("Equipped")
	emoteCategory.Name = "0"
	emoteCategory.LayoutOrder = -2000
	local emoteCategory2 = CreateEmoteCategory("NEW!")
	emoteCategory2.Name = "1"
	emoteCategory2.LayoutOrder = -999
	local emoteCategory3 = CreateEmoteCategory("Favorites")
	emoteCategory3.Name = "2"
	emoteCategory3.LayoutOrder = -1000
	table.insert(titles, emoteCategory2.Collapsible.InfoContainer.Title)
	local v8 = {}
	local v9 = {}
	local count = 0
	local v10 = {}

	for k, v11 in v4 do
		table.insert(v8, {
			Name = k,
			Data = v11
		})
	end

	table.sort(v8, function(a, b)
		if a.Data.Price == b.Data.Price then
			return a.Name < b.Name
		end

		return a.Data.Price < b.Data.Price
	end)

	for _, v11 in v8 do
		v9[v11.Name] = count
		count += 1
	end

	for k, v11 in v4 do
		if not v10[v11.Group] then
			local emoteCategory4 = CreateEmoteCategory(v11.Group)
			emoteCategory4.LayoutOrder = v11.Order
			emoteCategory4.Parent = parent
			v10[v11.Group] = emoteCategory4
		end

		local emote = CreateEmote(v11)
		local v14 = k
		local v15 = v11

		local function UpdateParent()
			local v16 = {}

			for k2, item in Data.Emotes.Items do
				if item.Favorited then
					v16[k2] = item
				end
			end

			emote.Header.Favorite.Visible = v16[v14] and true or false
			local v18 = {}

			for k2, item in Data.Emotes.Items do
				if item.Slot then
					v18[k2] = item
				end
			end

			if v18[v14] ~= nil then
				emote.Parent = emoteCategory.List
				return
			end

			local v20 = {}

			for k2, item in Data.Emotes.Items do
				if item.Favorited then
					v20[k2] = item
				end
			end

			if v20[v14] ~= nil then
				emote.Parent = emoteCategory3.List
			elseif v15.NewEmote then
				emote.Parent = emoteCategory2.List
			else
				emote.Parent = v10[v15.Group].List
			end
		end

		UpdateParent()
		emote.LayoutOrder = v9[k]
		emote.Name = v11.Name
		local v16 = v11
		local emote2 = emote
		shop.Hotbar.SearchBar.Search.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
			if not IsEmoteAvaliable() then
				return
			end

			local text = shop.Hotbar.SearchBar.Search.TextBox.Text

			if v16.Display:lower():find(text:lower()) then
				emote2.Visible = true
			else
				emote2.Visible = false
			end

			if v16.Offsale and not DoesOwnEmote(v16) then
				emote2.Visible = false
			elseif v16.Offsale and DoesOwnEmote(v16) then
				emote2.Visible = true
			end
		end)
		local v18 = v11
		local emote3 = emote
		local UpdateParent2 = UpdateParent
		bindableEvent.Event:Connect(function()
			if not IsEmoteAvaliable() then
				emote3.Visible = false
				return
			end

			emote3.Visible = true
			UpdateParent2()
			local hidden = emote3.Icon.Hidden
			hidden.Visible = not DoesOwnEmote(v18)
			emote3.Footer.Credits.Visible = emote3.Icon.Hidden.Visible
			emote3.Icon.Size = not emote3.Footer.Credits.Visible and UDim2.new(1, 0, 1, 0) or UDim2.new(1, 0, 1, -19)
			emote3.ItemName.Position = not emote3.Footer.Credits.Visible and UDim2.new(0.5, 0, 1, 0) or UDim2.new(
				0.5,
				0,
				1,
				-19
			)

			if v18.Offsale and not DoesOwnEmote(v18) then
				emote3.Visible = false
			elseif v18.Offsale and DoesOwnEmote(v18) then
				emote3.Visible = true
			end
		end)
		emote.Visible = IsEmoteAvaliable()
		local hidden = emote.Icon.Hidden
		hidden.Visible = not DoesOwnEmote(v11)
		emote.Footer.Credits.Visible = emote.Icon.Hidden.Visible
		emote.Icon.Size = not emote.Footer.Credits.Visible and UDim2.new(1, 0, 1, 0) or UDim2.new(1, 0, 1, -19)
		emote.ItemName.Position = not emote.Footer.Credits.Visible and UDim2.new(0.5, 0, 1, 0) or UDim2.new(
			0.5,
			0,
			1,
			-19
		)
		local v20 = v11
		emote.MouseButton1Click:Connect(function()
			if inspectItemPage.Visible then
				return
			end

			UpdateEmotePreview(v20)
		end)

		if v11.Offsale then
			if DoesOwnEmote(v11) then
				if v11.Offsale and DoesOwnEmote(v11) then
					emote.Visible = true
				end
			else
				emote.Visible = false
			end
		elseif v11.Offsale and DoesOwnEmote(v11) then
			emote.Visible = true
		end

		UI:Bind(emote)
		UI:AddShadowOnHover(emote)
		table.insert(v3, emote)
	end

	emoteCategory.Parent = parent
	emoteCategory2.Parent = parent
	emoteCategory3.Parent = parent
end

local function UpdateEmoteStates()
	if shop.Visible and parent.Visible then
		local Y = parent.AbsoluteSize.Y
		local Y2 = parent.AbsolutePosition.Y
		local v4 = Y2 - Y * 0.5 - 40
		local v5 = Y2 + Y * 0.5 + 40

		for _, v6 in v3 do
			local Y3 = v6.AbsolutePosition.Y
			local Y4 = v6.AbsoluteSize.Y

			if v4 < Y3 + Y4 * 0.5 and Y3 - Y4 < v5 then
				v6:SetAttribute("Enabled", true)
			else
				v6:SetAttribute("Enabled", false)
			end
		end
	else
		for _, v4 in v3 do
			v4:SetAttribute("Enabled", false)
		end
	end
end

CreateEmoteList()
UpdateEmoteStates()

function _G:StartBinding()
	Radial:StartBinding(self)
end

Data.Emotes:GetPropertyChangedSignal("Items"):Connect(function()
	bindableEvent:Fire()
end)
shop:GetPropertyChangedSignal("Visible"):Connect(UpdateEmoteStates)
parent:GetPropertyChangedSignal("Visible"):Connect(UpdateEmoteStates)
parent:GetPropertyChangedSignal("CanvasPosition"):Connect(UpdateEmoteStates)
parent:GetPropertyChangedSignal("CanvasSize"):Connect(UpdateEmoteStates)
RunService:BindToRenderStep("EmotesShopRGBText", Enum.RenderPriority.Camera.Value, function()
	if not shop.Visible then
		return
	end

	local color = Color3.fromHSV(tick() % 10 / 10, 1, 1)

	for _, v4 in titles do
		v4.TextColor3 = color
	end
end)