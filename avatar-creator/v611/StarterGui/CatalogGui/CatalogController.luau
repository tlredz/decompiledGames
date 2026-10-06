local MenuFade = require(game.ReplicatedStorage:WaitForChild("MenuFade"))
local CatalogPriceRange = require(game.ReplicatedStorage:WaitForChild("CatalogPriceRange"))
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")
local localPlayer = Players.LocalPlayer
local parent = script.Parent
local CatalogUI = require(game.ReplicatedStorage:WaitForChild("CatalogUI"))
local catalogRemote = game.ReplicatedStorage:WaitForChild("CatalogRemote")
local panel = parent.Root.Panel
local results = panel.Results
local catalogHome = panel:WaitForChild("CatalogHome")
local filterPanel = panel.FilterPanel
local fields = filterPanel.Fields
local details = panel.Details
local info = details.Body.Info
local preview = details.Body.Preview
local name = "Featured"
local name2 = "Recommended"
local offSale = false
local v2 = "User"
local v3 = {}
local v4 = false
local fn
local now = 0
local v5 = 0
local count = 0
local token = nil
local flag = false
local flag2 = false
local count2 = 0
local v6 = {}

local function resumeAvatarAnimations()
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local animate = character and character:FindFirstChild("Animate")

	if not humanoid or humanoid.Health <= 0 or not (animate and animate:IsA("LocalScript") and animate.Enabled) then
		return
	end

	animate.Enabled = false
	local animator = humanoid:FindFirstChildOfClass("Animator")

	if animator then
		for _, v7 in animator:GetPlayingAnimationTracks() do
			v7:Stop(0)
		end
	end

	animate.Enabled = true
end

local function stopCatalogEmote()
	for k in pairs(v6) do
		local v7 = k
		pcall(function()
			v7:Stop(0)
		end)
	end

	v6 = {}
end

local fn2
local catalogExtras = game.ReplicatedStorage:WaitForChild("CatalogExtras")
local flag3 = false
local now2 = 0
local favorite = false

local function extra(p, options)
	while flag3 do
		task.wait()
	end

	flag3 = true
	local v7 = 0.2 - (os.clock() - now2)

	if v7 > 0 then
		task.wait(v7)
	end

	now2 = os.clock()
	local success, result = pcall(function()
		return catalogExtras:InvokeServer(p, options or {})
	end)
	flag3 = false
	return success and result or {
		error = "Please try again."
	}
end

local v7 = {}
local v8 = false
local object = setmetatable({}, {
	__mode = "k"
})
local v9 = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function favoriteKey(p)
	return p.ItemType .. ":" .. string.format("%.0f", p.Id)
end

local function paintStars()
	for k, v10 in pairs(object) do
		if not k.Parent then
			continue
		end

		k.Text = v7[v10] and "★" or "☆"
		k.TextColor3 = v7[v10] and Color3.fromRGB(255, 208, 92) or CatalogUI.colors.text
	end
end

local function addStar(p, p2)
	local v10 = favoriteKey(p2) -- equivalent call inferred; original call site unknown
	local button = CatalogUI.button("FavoriteStar", p, "☆", UDim2.new(1, -38, 1, -38), UDim2.fromOffset(30, 30))
	button.ZIndex = 5
	button.TextSize = 24
	button.TextWrapped = false
	object[button] = v10
	button.Text = v7[v10] and "★" or "☆"
	button.TextColor3 = v7[v10] and Color3.fromRGB(255, 208, 92) or CatalogUI.colors.text
	button.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			v9 = os.clock() + 0.6
		end
	end)
	button.Activated:Connect(function()
		v9 = os.clock() + 0.6

		if not button.Interactable then
			return
		end

		button.Interactable = false
		local v11 = extra("Favorite", {
			id = p2.Id,
			kind = p2.ItemType,
			value = not v7[v10]
		})

		if button.Parent then
			button.Interactable = true
		end

		if v11.error then
			panel.Status.Text = v11.error
			return
		end

		v7[v10] = v11.favorite and true or nil
		paintStars()
	end)
end

local v10 = {}
local v11 = nil
local count3 = 0
local v12 = {}
local v13 = false
local v14 = nil
local v15 = 0
local camera = Instance.new("Camera")
camera.FieldOfView = 35
camera.Parent = preview.Avatar
preview.Avatar.CurrentCamera = camera
local worldModel = Instance.new("WorldModel")
worldModel.Parent = preview.Avatar

local function call(p, p2)
	local success, result = pcall(function()
		return catalogRemote:InvokeServer(p, p2)
	end)

	if success and type(result) == "table" then
		return result
	end

	return {
		error = "Connection interrupted. Please try again."
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function price(p)
	if CatalogPriceRange.IsOffSale(p) then
		return "Off sale"
	end

	local price2 = CatalogPriceRange.Price(p)

	if price2 == nil then
		return "Off sale"
	elseif price2 == 0 then
		return "Free"
	end

	return "R$ " .. string.format("%.0f", price2)
end

local function creatorLine(button, p, p2, value)
	local v16 = (type(p.CreatorName) ~= "string" or p.CreatorName == "") and "Unknown creator" or p.CreatorName or "Unknown creator"
	local label = CatalogUI.label(
		"Creator",
		button,
		"By " .. v16,
		UDim2.fromOffset(10, p2),
		UDim2.new(1, -20, 0, 18),
		value or 12
	)
	label.TextColor3 = CatalogUI.colors.muted
	label.TextWrapped = false
	label.TextTruncate = Enum.TextTruncate.AtEnd

	if p.CreatorHasVerifiedBadge ~= true then
		return label
	end

	label.Size = UDim2.new(1, -40, 0, 18)
	local v17 = CatalogUI.make("TextLabel", "VerifiedBadge", button, {
		Size = UDim2.fromOffset(18, 18),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = utf8.char(57344),
		Font = Enum.Font.Gotham,
		TextSize = 16,
		TextColor3 = Color3.new(1, 1, 1),
		TextWrapped = false,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center
	})

	-- equivalent calls inferred from this helper; original call sites unknown
	local function positionBadge()
		v17.Position = UDim2.fromOffset(math.min(label.TextBounds.X, label.AbsoluteSize.X) + 10 + 2, p2)
	end

	label:GetPropertyChangedSignal("TextBounds"):Connect(positionBadge)
	label:GetPropertyChangedSignal("AbsoluteSize"):Connect(positionBadge)
	positionBadge() -- equivalent call inferred; original call site unknown
	return label
end

local function limitedBadge() end

-- equivalent calls inferred from this helper; original call sites unknown
local function thumbnail(p)
	return "rbxthumb://type=" .. (p.ItemType == "Bundle" and "BundleThumbnail" or "Asset") .. "&id=" .. string.format(
		"%.0f",
		p.Id
	) .. "&w=420&h=420"
end

local function layoutResultCard(button, p, p2)
	local thumbnail2 = button:FindFirstChild("Thumbnail")

	if not thumbnail2 then
		return
	end

	thumbnail2.Position = UDim2.fromOffset(4, 4)
	thumbnail2.Size = UDim2.fromOffset(p - 8, p2)
	local itemName = button.ItemName
	itemName.Position = UDim2.fromOffset(6, p2 + 5)
	itemName.Size = UDim2.fromOffset(p - 12, 28)
	itemName.TextSize = 12
	itemName.TextScaled = false
	button.Creator.Visible = false
	local verifiedBadge = button:FindFirstChild("VerifiedBadge")

	if verifiedBadge then
		verifiedBadge.Visible = false
	end

	local price2 = button.Price
	price2.Position = UDim2.fromOffset(6, p2 + 33)
	price2.Size = UDim2.fromOffset(p - 12, 17)
	price2.TextSize = 12
	price2.TextScaled = false
	local favoriteStar = button:FindFirstChild("FavoriteStar")

	if favoriteStar then
		favoriteStar.Position = UDim2.fromOffset(p - 36, 4)
		favoriteStar.Size = UDim2.fromOffset(32, 32)
	end
end

local function layout()
	panel.Title.Visible = false
	panel.Subtitle.Visible = false
	panel.SearchInput.PlaceholderText = "Search"
	local MobileCatalogLayout = require(game.ReplicatedStorage.MobileCatalogLayout)

	if MobileCatalogLayout.IsMobile() then
		return
	end

	panel.SearchInput.Position = UDim2.fromOffset(20, 18)
	panel.SearchInput.Size = UDim2.new(1, -284, 0, 88)
	panel.SearchInput.TextSize = 22
	panel.Search.Position = UDim2.new(1, -222, 0, 64)
	panel.Search.Size = UDim2.fromOffset(96, 44)
	panel.Search.TextSize = 16
	panel.Filters.Position = UDim2.new(1, -118, 0, 64)
	panel.Filters.Size = UDim2.fromOffset(98, 44)
	panel.Filters.TextSize = 16
	panel.Tabs.Position = UDim2.fromOffset(20, 120)
	local visible2 = not catalogHome.Visible

	if visible2 then
		if panel.Status.Text == "" then
			visible2 = false
		else
			visible2 = not string.find(panel.Status.Text, "items loaded", 1, true)
		end
	end

	panel.Status.Visible = visible2
	panel.Status.Position = UDim2.fromOffset(20, 162)
	panel.Status.Size = UDim2.new(1, -40, 0, 22)
	local v17 = visible2 and 190 or 164
	results.Position = UDim2.fromOffset(20, v17)
	results.Size = UDim2.new(1, -40, 1, -v17 - (panel.More.Visible and 56 or 12))
	local v18 = panel.Size.X.Offset + panel.Parent.AbsoluteSize.X * panel.Size.X.Scale
	local v19 = panel.AbsoluteSize.X / math.max(1, v18)
	local v20 = results.AbsoluteSize.X / math.max(0.1, v19) - 8
	local v21 = math.max(1, (math.floor((v20 + 8) / 152)))
	local v22 = math.max(48, (math.floor((v20 - (v21 - 1) * 8) / v21)))
	local v23 = math.min(v22 - 8, 120)
	results.Grid.CellSize = UDim2.fromOffset(v22, v23 + 50)
	results.Grid.CellPadding = UDim2.fromOffset(8, 8)

	for _, button in results:GetChildren() do
		if button:IsA("GuiButton") then
			layoutResultCard(button, v22, v23)
		end
	end

	local body = details.Body
	local v24 = body.AbsoluteSize.X < 600
	local v25 = math.max(540, body.AbsoluteSize.Y - 4)

	if v24 then
		preview.Position = UDim2.new()
		preview.Size = UDim2.new(1, -6, 0, 310)
		info.Position = UDim2.fromOffset(0, 330)
		info.Size = UDim2.new(1, -6, 0, 860)
		body.CanvasSize = UDim2.fromOffset(0, 1200)
	else
		preview.Position = UDim2.new()
		preview.Size = UDim2.new(0.43, 0, 0, (math.min(v25, body.AbsoluteSize.X * 0.43 + 64)))
		info.Position = UDim2.new(0.46, 0, 0, 0)
		info.Size = UDim2.new(0.54, -6, 0, 860)
		body.CanvasSize = UDim2.fromOffset(0, (math.max(v25 + 4, 870)))
	end
end

results:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)
panel.More:GetPropertyChangedSignal("Visible"):Connect(layout)
panel.Status:GetPropertyChangedSignal("Text"):Connect(layout)
details.Body:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)

local function aim()
	if not v14 then
		return
	end

	local boundingBox, v16 = v14:GetBoundingBox()
	local v17 = math.max(0.3, preview.Avatar.AbsoluteSize.X / math.max(1, preview.Avatar.AbsoluteSize.Y))
	local v18 = math.max(v16.Y, v16.X / v17) / (math.tan((math.rad(camera.FieldOfView / 2))) * 2) + v16.Z * 0.7
	local position = boundingBox.Position
	local vector = Vector3.new(math.sin(v15) * v18, 0.3, -math.cos(v15) * v18)
	camera.CFrame = CFrame.lookAt(position + vector, position)
end

local function avatar()
	local character = localPlayer.Character

	if not character then
		info.Message.Text = "Wait for your character to spawn."
		return
	end

	local archivable = character.Archivable
	character.Archivable = true
	local clone = character:Clone()
	character.Archivable = archivable

	if not clone then
		info.Message.Text = "Avatar preview could not load."
		return
	end

	for _, descendant in ipairs(clone:GetDescendants()) do
		if descendant:IsA("LuaSourceContainer") or descendant:IsA("Tool") or descendant:IsA("BillboardGui") or descendant:IsA("Sound") then
			descendant:Destroy()
		elseif descendant:IsA("BasePart") then
			descendant.CanCollide = false
			descendant.Anchored = false
		end
	end

	local humanoidRootPart = clone:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		humanoidRootPart.Anchored = true
	end

	if v14 then
		v14:Destroy()
	end

	v14 = clone
	v14.Name = "TryOnAvatar"
	v14.Parent = worldModel
	v14:PivotTo(CFrame.new())
	v15 = 0
	aim()
	MenuFade.Set(preview.Avatar, "Visible", true)
	MenuFade.Set(preview.Thumbnail, "Visible", false)
end

preview.Avatar:GetPropertyChangedSignal("AbsoluteSize"):Connect(aim)
preview.RotateLeft.Activated:Connect(function()
	v15 -= 0.5235987755982988
	aim()
end)
preview.RotateRight.Activated:Connect(function()
	v15 += 0.5235987755982988
	aim()
end)
preview.ImageMode.Activated:Connect(function()
	MenuFade.Set(preview.Avatar, "Visible", false)
	MenuFade.Set(preview.Thumbnail, "Visible", true)
end)
preview.AvatarMode.Activated:Connect(avatar)

local function renderItem(data)
	local v16

	if data.NoCoinReward == true then
		v16 = true
	else
		local LimitedCoinPolicy = require(game.ReplicatedStorage.LimitedCoinPolicy)
		v16 = LimitedCoinPolicy.IsLimited(data)
	end

	v11 = data
	info.ItemName.Text = data.Name or "Catalog item"
	info.Creator.Text = "By " .. (data.CreatorName or "Roblox") .. (data.CreatorHasVerifiedBadge ~= true and "" or " " .. utf8.char(57344) or "") .. "  ·  " .. (data.AssetType or data.BundleType or data.ItemType)
	local price2 = info.Price
	local text = price(data) -- equivalent call inferred; original call site unknown
	price2.Text = text
	info.DescriptionScroll.Description.Text = (not data.Description or data.Description == "") and "No description provided." or data.Description or "No description provided."

	if v16 then
		info.DescriptionScroll.Description.Text = [[
Limited purchases do not give coins.

]] .. info.DescriptionScroll.Description.Text
	end

	preview.Thumbnail.Image = thumbnail(data)
	UDim2.fromOffset(16, 16)
	local buy = info.Buy
	local v18 = price(data) -- equivalent call inferred; original call site unknown
	local text2

	if v18 == "Off sale" then
		text2 = "Unavailable"
	else
		local v20 = price(data) -- equivalent call inferred; original call site unknown
		text2 = v20 == "Free" and "Get free" or "Buy"
	end

	buy.Text = text2
	local buy2 = info.Buy
	local v20 = price(data) -- equivalent call inferred; original call site unknown
	buy2.Interactable = v20 ~= "Off sale"

	if data.SaleLocationType == "ExperiencesDevApiOnly" then
		info.Buy.Text = "Experience only"
		info.Buy.Interactable = false
	end

	if not v16 and info.Buy.Interactable and type(data.CoinReward) == "number" and data.CoinReward > 0 then
		info.Buy.Text = info.Buy.Text .. " (+" .. tostring(data.CoinReward) .. " coins)"
	end

	info.Buy.AutoButtonColor = info.Buy.Interactable
end

local function showItem(p, p2)
	if MenuFade.IsOpen(filterPanel, "Visible") or MenuFade.IsOpen(details, "Visible") and not p2 then
		return
	end

	count2 += 1
	local v16 = count2
	v11 = nil
	info.Favorite.Interactable = false
	info.Favorite.Text = "Loading favorite..."
	info.RelatedHeading.Text = "Loading related items..."

	for _, guiObject in ipairs(info.Related:GetChildren()) do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end

	MenuFade.Set(details, "Visible", true)
	MenuFade.Set(filterPanel, "Visible", false)
	details.Body.CanvasPosition = Vector2.zero
	info.DescriptionScroll.CanvasPosition = Vector2.zero
	MenuFade.Set(preview.Thumbnail, "Visible", true)
	MenuFade.Set(preview.Avatar, "Visible", false)
	info.Message.Text = "Loading item details..."
	info.TryOn.Interactable = false
	info.Buy.Interactable = false
	renderItem(p)
	v11 = nil
	info.TryOn.Interactable = false
	info.Buy.Interactable = false
	layout()
	local v17 = call("Details", {
		id = p.Id,
		kind = p.ItemType
	})

	if v16 ~= count2 then
		return
	end

	if v17.error then
		info.Message.Text = v17.error
		return
	end

	renderItem(v17.item)
	local favoriteStar = preview:FindFirstChild("FavoriteStar")

	if favoriteStar then
		favoriteStar:Destroy()
	end

	addStar(preview, v17.item)
	local favoriteStar2 = preview.FavoriteStar
	favoriteStar2.Position = UDim2.new(1, -48, 1, -48)
	favoriteStar2.Size = UDim2.fromOffset(36, 36)

	if fn2 then
		task.spawn(fn2, v17.item, v16)
	end

	local trying = v17.trying == true

	if v17.item.AssetType == "EmoteAnimation" then
		trying = false

		for k in pairs(v6) do
			if not k.IsPlaying then
				continue
			end

			trying = true
			break
		end
	end

	v10[p.ItemType .. tostring(p.Id)] = trying
	info.TryOn.Text = trying and "Take off" or "Try on"
	info.TryOn.Interactable = true
	info.Message.Text = v17.item.SaleLocationType == "ExperiencesDevApiOnly" and "This item must be claimed in its creator's experience. Check the item description for instructions." or "Try-on changes your character in this game only. Roblox confirms the final price before purchase."
end

local function append(items)
	local count4 = 0

	for _, v16 in ipairs(items) do
		local v17 = v16.ItemType .. string.format("%.0f", v16.Id)

		if v12[v17] or not CatalogPriceRange.Matches(v16, v3.minPrice, v3.maxPrice, v3.offSale) then
			continue
		end

		v12[v17] = true
		count3 += 1
		local button = CatalogUI.button("Item_" .. v17, results, "", UDim2.new(), UDim2.new())
		button.BackgroundColor3 = CatalogUI.colors.surface
		button.LayoutOrder = count3
		button:SetAttribute("ItemId", v16.Id)
		button:SetAttribute("ItemType", v16.ItemType)
		CatalogUI.make("ImageLabel", "Thumbnail", button, {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(7, 4),
			Size = UDim2.new(1, -14, 0, 145),
			Image = thumbnail(v16),
			ScaleType = Enum.ScaleType.Fit
		})
		local label_2 = CatalogUI.label(
			"ItemName",
			button,
			v16.Name,
			UDim2.fromOffset(10, 151),
			UDim2.new(1, -20, 0, 40),
			14
		)
		label_2.TextTruncate = Enum.TextTruncate.AtEnd
		creatorLine(button, v16, 193)
		local label = CatalogUI.label
		local v18 = "Price"
		local v19 = price(v16) -- equivalent call inferred; original call site unknown
		local label_3 = label(v18, button, v19, UDim2.fromOffset(10, 217), UDim2.new(1, -56, 0, 20), 13)
		label_3.TextColor3 = Color3.fromRGB(178, 162, 255)
		addStar(button, v16)
		local v20 = v16
		button.Activated:Connect(function()
			if os.clock() < v9 then
				return
			end

			showItem(v20)
		end)
		count4 += 1

		if count4 % 8 == 0 then
			task.wait()
		end
	end

	layout()
	return count4
end

local function search(p)
	if flag then
		return
	end

	flag = true
	now = os.clock()
	panel.Search.Text = "..."
	panel.More.Interactable = false
	panel.Status.Text = p and "Loading more items..." or "Searching Roblox..."

	if not p then
		token = nil
		v4 = false
		v12 = {}
		count3 = 0
		v5 = 0
		count = 0

		for _, guiObject in ipairs(results:GetChildren()) do
			if guiObject:IsA("GuiObject") then
				guiObject:Destroy()
			end
		end

		results.CanvasPosition = Vector2.zero
		v3.category = name
		v3.keyword = panel.SearchInput.Text
		local backToCatalog = panel.BackToCatalog
		local visible2

		if v3.creatorId == nil then
			if v3.creator == nil then
				visible2 = false
			else
				visible2 = v3.creator ~= ""
			end
		else
			visible2 = true
		end

		backToCatalog.Visible = visible2
		panel.Title.Text = (not v3.creator or v3.creator == "") and "Catalog" or v3.creator .. "'s items" or "Catalog"
		panel.Subtitle.Text = v3.creator and v3.creator ~= "" and "Popular items from this creator" or "Discover pieces for your next look"
	end

	local v16

	if name == "Matching" then
		local success, result = pcall(function()
			return game.ReplicatedStorage.EditorToolsRemote:InvokeServer("Matching", {
				maxPrice = v3.maxPrice
			})
		end)
		v16 = success and result or {
			error = "Suggestions unavailable. Try again."
		}
	elseif name == "Favorites" then
		v16 = extra("List", {
			keyword = panel.SearchInput.Text
		})
	else
		v16 = call(p and "More" or "Search", p and {
			token = token
		} or v3)
	end

	panel.Search.Text = "Search"
	panel.More.Interactable = true

	if v16.error then
		flag = false
		panel.Status.Text = v16.error
		MenuFade.Set(panel.More, "Visible", false)
	else
		token = v16.token

		if not v8 then
			local v17 = extra("Keys", {})

			if v17.favorites then
				v7 = {}

				for k in pairs(v17.favorites) do
					v7[k] = true
				end

				v8 = true
			end
		end

		v5 = append(v16.items or {}) ~= 0 and 0 or v5 + 1 or 0
		paintStars()
		v4 = not v16.finished
		flag = false

		if fn then
			task.defer(fn)
		end

		local v17 = v4 and (v5 >= 2 or count >= 2)
		MenuFade.Set(panel.More, "Visible", v17)
		local status = panel.Status
		local text

		if count3 == 0 then
			text = v4 and "Finding items within your filters..." or "No matching items. Try another search or clear your filters."
		else
			text = (({
				Featured = "Recommended",
				Accessories = "Accessories · All",
				AccessoriesHead = "Accessories · Head",
				AccessoriesFace = "Accessories · Face",
				AccessoriesNeck = "Accessories · Neck",
				AccessoriesShoulder = "Accessories · Shoulder",
				AccessoriesFront = "Accessories · Front",
				AccessoriesBack = "Accessories · Back",
				AccessoriesWaist = "Accessories · Waist",
				Classic = "Classic · All",
				ClassicShirts = "Classic · Shirts",
				ClassicPants = "Classic · Pants",
				ClassicTShirts = "Classic · T-shirts",
				LimitedU = "Limited U",
				LimitedUGC = "Limited UGC",
				FreeLimiteds = "Free Limiteds"
			})[name] or name) .. "  ·  " .. count3 .. " items loaded"
		end

		status.Text = text

		if v17 and count3 == 0 then
			panel.Status.Text = "No matches in these pages. Load more or adjust your filters."
		end
	end
end

local v16 = CatalogUI.make("Frame", "ClassicDropdown", panel, {
	Size = UDim2.fromOffset(164, 184),
	BackgroundColor3 = CatalogUI.colors.surface,
	Visible = false,
	Active = true,
	ZIndex = 9
})
CatalogUI.round(v16, 10)

-- equivalent calls inferred from this helper; original call sites unknown
local function closeClassic()
	v16.Visible = false
end

local function placeClassic()
	local v17 = panel.Tabs.Classic.AbsolutePosition - panel.AbsolutePosition
	local v18 = panel.AbsoluteSize.X / math.max(
		1,
		panel.Size.X.Offset + panel.Parent.AbsoluteSize.X * panel.Size.X.Scale
	)
	local v19 = v18 <= 0 and 1 or v18
	local v20 = panel.AbsoluteSize.X / v19
	v16.Position = UDim2.fromOffset(
		math.clamp(v17.X / v19, 8, (math.max(8, v20 - 172))),
		(v17.Y + panel.Tabs.Classic.AbsoluteSize.Y) / v19 + 6
	)
end

panel.Tabs.Classic.Text = "Classic"
panel.Tabs.Classic.Activated:Connect(function()
	placeClassic()
	v16.Visible = not v16.Visible
end)

for i, v17 in ipairs({
	{ "All", "Classic" },
	{ "Shirts", "ClassicShirts" },
	{ "Pants", "ClassicPants" },
	{ "T-shirts", "ClassicTShirts" }
}) do
	local button = CatalogUI.button(
		v17[2],
		v16,
		v17[1],
		UDim2.fromOffset(6, 6 + (i - 1) * 44),
		UDim2.new(1, -12, 0, 40)
	)
	button.ZIndex = 10
	local v18 = v17
	button.Activated:Connect(function()
		if flag then
			return
		end

		closeClassic() -- equivalent call inferred; original call site unknown
		name = v18[2]

		for i2, button2 in ipairs(panel.Tabs:GetChildren()) do
			if button2:IsA("TextButton") then
				button2.BackgroundColor3 = button2 == panel.Tabs.Classic and CatalogUI.colors.accent or CatalogUI.colors.raised
			end
		end

		search(false)
	end)
end

UserInputService.InputBegan:Connect(function(input)
	if not v16.Visible then
		return
	end

	if input.KeyCode == Enum.KeyCode.Escape then
		closeClassic() -- equivalent call inferred; original call site unknown
		return
	end

	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end

	local vector = Vector2.new(input.Position.X, input.Position.Y)

	local function inside(p)
		local absolutePosition = p.AbsolutePosition
		local absoluteSize = p.AbsoluteSize
		return vector.X >= absolutePosition.X and vector.Y >= absolutePosition.Y and vector.X <= absolutePosition.X + absoluteSize.X and vector.Y <= absolutePosition.Y + absoluteSize.Y
	end

	local v17 = v16
	local absolutePosition = v17.AbsolutePosition
	local absoluteSize = v17.AbsoluteSize
	local v18

	if vector.X >= absolutePosition.X and vector.Y >= absolutePosition.Y and vector.X <= absolutePosition.X + absoluteSize.X then
		v18 = vector.Y <= absolutePosition.Y + absoluteSize.Y
	else
		v18 = false
	end

	if not v18 then
		local classic = panel.Tabs.Classic
		local absolutePosition2 = classic.AbsolutePosition
		local absoluteSize2 = classic.AbsoluteSize
		local v19

		if vector.X >= absolutePosition2.X and vector.Y >= absolutePosition2.Y and vector.X <= absolutePosition2.X + absoluteSize2.X then
			v19 = vector.Y <= absolutePosition2.Y + absoluteSize2.Y
		else
			v19 = false
		end

		if not v19 then
			closeClassic() -- equivalent call inferred; original call site unknown
		end
	end
end)
panel.Tabs:GetPropertyChangedSignal("CanvasPosition"):Connect(closeClassic)
panel:GetPropertyChangedSignal("AbsoluteSize"):Connect(closeClassic)
parent:GetPropertyChangedSignal("Enabled"):Connect(closeClassic)

for _, v17 in ipairs({ catalogHome, details, filterPanel }) do
	v17:GetPropertyChangedSignal("Visible"):Connect(closeClassic)
end

panel.Tabs.BodyEditor.Activated:Connect(closeClassic)
local v17 = CatalogUI.make("ScrollingFrame", "AccessoriesDropdown", panel, {
	Size = UDim2.fromOffset(164, 364),
	BackgroundColor3 = CatalogUI.colors.surface,
	Visible = false,
	Active = true,
	ZIndex = 9
})
CatalogUI.round(v17, 10)

-- equivalent calls inferred from this helper; original call sites unknown
local function closeAccessories()
	v17.Visible = false
end

v17.CanvasSize = UDim2.fromOffset(0, 364)
v17.ScrollingDirection = Enum.ScrollingDirection.Y
v17.ScrollBarThickness = 6
v17.ScrollBarImageColor3 = CatalogUI.colors.accent
v17.ClipsDescendants = true
v17.BorderSizePixel = 0

local function placeAccessories()
	local v18 = panel.Tabs.Accessories.AbsolutePosition - panel.AbsolutePosition
	local v19 = panel.AbsoluteSize.X / math.max(
		1,
		panel.Size.X.Offset + panel.Parent.AbsoluteSize.X * panel.Size.X.Scale
	)
	local v20 = v19 <= 0 and 1 or v19
	local v21 = panel.AbsoluteSize.X / v20
	local v22 = panel.AbsoluteSize.Y / v20
	local v23 = math.min(184, (math.max(1, v21 - 16)))
	local v24 = math.clamp((v18.Y + panel.Tabs.Accessories.AbsoluteSize.Y) / v20 + 6, 8, (math.max(8, v22 - 52)))
	local v25 = math.max(1, v22 - v24 - 8)
	v17.Size = UDim2.fromOffset(v23, (math.min(364, v25)))
	v17.Position = UDim2.fromOffset(math.clamp(v18.X / v20, 8, (math.max(8, v21 - v23 - 8))), v24)
end

panel.Tabs.Accessories.Text = "Accessories"
panel.Tabs.Accessories.Activated:Connect(function()
	placeAccessories()
	v17.CanvasPosition = Vector2.zero
	v17.Visible = not v17.Visible
end)

for i, v18 in ipairs({
	{ "All", "Accessories" },
	{ "Head", "AccessoriesHead" },
	{ "Face", "AccessoriesFace" },
	{ "Neck", "AccessoriesNeck" },
	{ "Shoulder", "AccessoriesShoulder" },
	{ "Front", "AccessoriesFront" },
	{ "Back", "AccessoriesBack" },
	{ "Waist", "AccessoriesWaist" }
}) do
	local button = CatalogUI.button(
		v18[2],
		v17,
		v18[1],
		UDim2.fromOffset(6, 6 + (i - 1) * 44),
		UDim2.new(1, -12, 0, 40)
	)
	button.ZIndex = 10
	local v19 = v18
	button.Activated:Connect(function()
		if flag then
			return
		end

		closeAccessories() -- equivalent call inferred; original call site unknown
		name = v19[2]

		for i2, button2 in ipairs(panel.Tabs:GetChildren()) do
			if button2:IsA("TextButton") then
				button2.BackgroundColor3 = button2 == panel.Tabs.Accessories and CatalogUI.colors.accent or CatalogUI.colors.raised
			end
		end

		search(false)
	end)
end

UserInputService.InputBegan:Connect(function(input)
	if not v17.Visible then
		return
	end

	if input.KeyCode == Enum.KeyCode.Escape then
		closeAccessories() -- equivalent call inferred; original call site unknown
		return
	end

	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end

	local vector = Vector2.new(input.Position.X, input.Position.Y)

	local function inside(p)
		local absolutePosition = p.AbsolutePosition
		local absoluteSize = p.AbsoluteSize
		return vector.X >= absolutePosition.X and vector.Y >= absolutePosition.Y and vector.X <= absolutePosition.X + absoluteSize.X and vector.Y <= absolutePosition.Y + absoluteSize.Y
	end

	local v18 = v17
	local absolutePosition = v18.AbsolutePosition
	local absoluteSize = v18.AbsoluteSize
	local v19

	if vector.X >= absolutePosition.X and vector.Y >= absolutePosition.Y and vector.X <= absolutePosition.X + absoluteSize.X then
		v19 = vector.Y <= absolutePosition.Y + absoluteSize.Y
	else
		v19 = false
	end

	if not v19 then
		local accessories = panel.Tabs.Accessories
		local absolutePosition2 = accessories.AbsolutePosition
		local absoluteSize2 = accessories.AbsoluteSize
		local v20

		if vector.X >= absolutePosition2.X and vector.Y >= absolutePosition2.Y and vector.X <= absolutePosition2.X + absoluteSize2.X then
			v20 = vector.Y <= absolutePosition2.Y + absoluteSize2.Y
		else
			v20 = false
		end

		if not v20 then
			closeAccessories() -- equivalent call inferred; original call site unknown
		end
	end
end)
panel.Tabs:GetPropertyChangedSignal("CanvasPosition"):Connect(closeAccessories)
panel:GetPropertyChangedSignal("AbsoluteSize"):Connect(closeAccessories)
parent:GetPropertyChangedSignal("Enabled"):Connect(closeAccessories)

for _, v18 in ipairs({ catalogHome, details, filterPanel }) do
	v18:GetPropertyChangedSignal("Visible"):Connect(closeAccessories)
end

panel.Tabs.BodyEditor.Activated:Connect(closeAccessories)
panel.Tabs.Classic.Activated:Connect(closeAccessories)
panel.Tabs.Accessories.Activated:Connect(closeClassic)

for _, button in ipairs(panel.Tabs:GetChildren()) do
	if not (button:IsA("TextButton") and button.Name ~= "BodyEditor" and button.Name ~= "Classic" and button.Name ~= "Accessories") then
		continue
	end

	local v18 = button
	button.Activated:Connect(function()
		if flag then
			return
		end

		closeClassic() -- equivalent call inferred; original call site unknown
		closeAccessories() -- equivalent call inferred; original call site unknown
		local v19 = name
		name = v18.Name

		if name == "FreeLimiteds" then
			v3.minPrice = 0
			v3.maxPrice = 0
			fields.MinPrice.Text = "0"
			fields.MaxPrice.Text = "0"
		elseif v19 == "FreeLimiteds" then
			v3.minPrice = nil
			v3.maxPrice = nil
			fields.MinPrice.Text = "1"
			fields.MaxPrice.Text = ""
		end

		if name == "Favorites" or name == "Matching" then
			v3 = {
				minPrice = v3.minPrice,
				maxPrice = v3.maxPrice,
				offSale = v3.offSale
			}
		end

		for i, button2 in ipairs(panel.Tabs:GetChildren()) do
			if button2:IsA("TextButton") then
				button2.BackgroundColor3 = button2 == v18 and CatalogUI.colors.accent or CatalogUI.colors.raised
			end
		end

		search(false)
	end)
end

panel.Search.Activated:Connect(function()
	search(false)
end)
panel.SearchInput.FocusLost:Connect(function(p)
	if p then
		search(false)
	end
end)
panel.More.Activated:Connect(function()
	if flag then
		return
	end

	v5 = 0
	count = 0
	search(true)
end)
panel.Filters.Activated:Connect(function()
	MenuFade.Set(filterPanel, "Visible", true)
end)
filterPanel.Close.Activated:Connect(function()
	MenuFade.Set(filterPanel, "Visible", false)
end)

local function styleSort()
	for _, button in ipairs(fields.SortOptions:GetChildren()) do
		if button:IsA("TextButton") then
			button.BackgroundColor3 = button.Name == name2 and CatalogUI.colors.accent or CatalogUI.colors.raised
		end
	end
end

for _, button in ipairs(fields.SortOptions:GetChildren()) do
	if not button:IsA("TextButton") then
		continue
	end

	local v18 = button
	button.Activated:Connect(function()
		name2 = v18.Name
		styleSort()
	end)
end

fields.CreatorType.Activated:Connect(function()
	v2 = v2 == "User" and "Group" or "User"
	fields.CreatorType.Text = v2
	fields.Creator.PlaceholderText = v2 == "User" and "Exact username" or "Group name"
end)
fields.OffSale.Activated:Connect(function()
	offSale = not offSale
	fields.OffSale.Text = "Include off-sale: " .. (offSale and "Yes" or "No")
end)
filterPanel.Clear.Activated:Connect(function()
	name2 = "Recommended"
	offSale = false
	v2 = "User"
	fields.Creator.Text = ""
	fields.MinPrice.Text = "1"
	fields.MaxPrice.Text = ""
	fields.CreatorType.Text = "User"
	fields.Creator.PlaceholderText = "Exact username"
	fields.OffSale.Text = "Include off-sale: No"
	styleSort()
end)
filterPanel.Apply.Activated:Connect(function()
	if flag then
		return
	end

	local match = fields.MinPrice.Text:match("^%s*(.-)%s*$")
	local match2 = fields.MaxPrice.Text:match("^%s*(.-)%s*$")
	local minPrice

	if match ~= "" then
		minPrice = tonumber(match) or nil
	end

	local maxPrice

	if match2 ~= "" then
		maxPrice = tonumber(match2) or nil
	end

	if match ~= "" and (not minPrice or minPrice < 0 or minPrice > 1000000000) or match2 ~= "" and (not maxPrice or maxPrice < 0 or maxPrice > 1000000000) or minPrice and maxPrice and maxPrice < minPrice then
		fields.Hint.Text = "Enter valid prices; minimum cannot exceed maximum."
		return
	end

	fields.Hint.Text = "Without search text, off-sale recommendations use most-favorited items. Price limits apply to on-sale items."
	v3 = {
		sort = name2,
		creator = fields.Creator.Text:match("^%s*(.-)%s*$"),
		creatorType = v2,
		offSale = offSale,
		minPrice = minPrice,
		maxPrice = maxPrice
	}
	MenuFade.Set(filterPanel, "Visible", false)
	search(false)
end)
details.Back.Activated:Connect(function()
	if v11 and v11.AssetType == "EmoteAnimation" then
		stopCatalogEmote()
		resumeAvatarAnimations()
		v10[v11.ItemType .. tostring(v11.Id)] = nil
	end

	count2 += 1
	v11 = nil
	MenuFade.Set(details, "Visible", false)
end)
local canvasPositionsByScrollingFrame = nil
local flag4 = false
local count4 = 0

local function pauseCatalog()
	canvasPositionsByScrollingFrame = {}

	for _, scrollingFrame in ipairs(parent:GetDescendants()) do
		if scrollingFrame:IsA("ScrollingFrame") then
			canvasPositionsByScrollingFrame[scrollingFrame] = scrollingFrame.CanvasPosition
		end
	end

	flag4 = true
	parent:SetAttribute("PreserveCatalogPage", true)
	MenuFade.Set(parent, "Enabled", false)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resumeScroll()
	local v18 = canvasPositionsByScrollingFrame

	if not v18 then
		return
	end

	count4 += 1
	local v19 = count4

	-- equivalent calls inferred from this helper; original call sites unknown
	local function restore()
		if v19 ~= count4 or not MenuFade.IsOpen(parent, "Enabled") then
			return
		end

		for k, canvasPosition in pairs(v18) do
			if k.Parent then
				k.CanvasPosition = canvasPosition
			end
		end
	end

	restore() -- equivalent call inferred; original call site unknown
	task.delay(0.25, restore)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function close()
	MenuFade.Set(parent, "Enabled", false)
	count2 += 1
end

-- equivalent calls inferred from this helper; original call sites unknown
local function showHome()
	MenuFade.Set(details, "Visible", false)
	MenuFade.Set(filterPanel, "Visible", false)
	count2 += 1
	v11 = nil
	MenuFade.Set(catalogHome, "Visible", true)
end

panel.Close.Activated:Connect(showHome)
catalogHome.Close.Activated:Connect(close)
local v18 = CatalogUI.make("Frame", "CloseCatalogBounds", parent, {
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Size = UDim2.fromScale(1, 1),
	Active = false,
	ZIndex = 1
})
local v19 = CatalogUI.make("TextButton", "CloseCatalog", parent, {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromOffset(0, 0),
	Size = UDim2.fromOffset(260, 52),
	BackgroundColor3 = Color3.fromRGB(202, 43, 58),
	BorderSizePixel = 0,
	Text = "Close",
	TextColor3 = Color3.new(1, 1, 1),
	Font = Enum.Font.GothamBold,
	TextSize = 23,
	ZIndex = 100,
	Active = true,
	AutoButtonColor = true
})
v19:SetAttribute("IconNavigation", true)
CatalogUI.round(v19, 12)

local function positionCatalogClose()
	local MobileCatalogLayout = require(game.ReplicatedStorage.MobileCatalogLayout)

	if MobileCatalogLayout.IsMobile() then
		return
	end

	local absoluteSize = panel.AbsoluteSize
	local absoluteSize2 = v18.AbsoluteSize

	if absoluteSize.X <= 0 or absoluteSize2.X <= 0 then
		return
	end

	local v20 = panel.AbsolutePosition - v18.AbsolutePosition
	local v21 = v20.X + absoluteSize.X - 38 - 10
	v19.AnchorPoint = Vector2.new(0.5, 0.5)
	v19.Size = UDim2.fromOffset(76, 40)
	v19.Position = UDim2.fromOffset(v21, v20.Y + 20 + 10)
	v19.TextSize = 18
end

panel:GetPropertyChangedSignal("AbsolutePosition"):Connect(positionCatalogClose)
panel:GetPropertyChangedSignal("AbsoluteSize"):Connect(positionCatalogClose)
v18:GetPropertyChangedSignal("AbsolutePosition"):Connect(positionCatalogClose)
v18:GetPropertyChangedSignal("AbsoluteSize"):Connect(positionCatalogClose)
positionCatalogClose()
v19.Activated:Connect(pauseCatalog)

for _, button in ipairs(catalogHome:GetChildren()) do
	if not (button:IsA("GuiButton") and button:GetAttribute("Category")) then
		continue
	end

	local v20 = button
	button.Activated:Connect(function()
		if flag then
			return
		end

		name = v20:GetAttribute("Category")
		v3 = {}
		name2 = "Recommended"
		offSale = false
		v2 = "User"
		panel.SearchInput.Text = ""
		fields.Creator.Text = ""
		fields.MinPrice.Text = "1"
		fields.MaxPrice.Text = ""
		fields.CreatorType.Text = "User"
		fields.OffSale.Text = "Include off-sale: No"
		styleSort()

		for i, button2 in ipairs(panel.Tabs:GetChildren()) do
			if button2:IsA("TextButton") then
				button2.BackgroundColor3 = button2.Name == name and CatalogUI.colors.accent or CatalogUI.colors.raised
			end
		end

		MenuFade.Set(catalogHome, "Visible", false)
		v13 = true
		search(false)
	end)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.Escape and parent.Enabled then
		if MenuFade.IsOpen(details, "Visible") then
			MenuFade.Set(details, "Visible", false)
			count2 += 1
		elseif MenuFade.IsOpen(filterPanel, "Visible") then
			MenuFade.Set(filterPanel, "Visible", false)
		else
			close() -- equivalent call inferred; original call site unknown
		end
	end
end)
local v20 = CatalogUI.make("ImageLabel", "LookBackdrop", parent.Root.LivePreview, {
	BackgroundTransparency = 1,
	Position = parent.Root.LivePreview.Avatar.Position,
	Size = parent.Root.LivePreview.Avatar.Size,
	ZIndex = 0,
	Visible = false,
	ScaleType = Enum.ScaleType.Crop
})
CatalogUI.round(v20, 12)

local function fitBackground()
	v20.Position = parent.Root.LivePreview.Avatar.Position
	v20.Size = parent.Root.LivePreview.Avatar.Size
end

parent.Root.LivePreview.Avatar:GetPropertyChangedSignal("Position"):Connect(fitBackground)
parent.Root.LivePreview.Avatar:GetPropertyChangedSignal("Size"):Connect(fitBackground)
local v21 = nil

local function appearance(p)
	if p == "Try" and v11 and v11.AssetType == "AvatarBackground" then
		if flag2 then
			return
		end

		flag2 = true
		local v22 = v11
		local v23 = v22.ItemType .. tostring(v22.Id)
		info.TryOn.Text = "Loading..."
		local v24 = call("Try", {
			id = v22.Id,
			kind = v22.ItemType
		})
		flag2 = false

		if not v24.error then
			if v21 then
				v10[v21] = nil
			end

			v21 = v24.trying and v23 or nil
			v10[v23] = v24.trying or nil
			v20.Visible = v24.trying == true
			v20:SetAttribute("BackgroundAssetId", v24.trying and v22.Id or nil)

			if v24.imageId then
				v20.Image = "rbxassetid://" .. tostring(v24.imageId)
				v20.ImageColor3 = Color3.new(1, 1, 1)
			end
		end

		info.TryOn.Text = v10[v23] and "Take off" or "Try on"
		info.Message.Text = v24.error or v24.message
	else
		if flag2 or p == "Try" and not v11 then
			return
		end

		flag2 = true
		local v22 = v11
		local v23 = count2
		info.Message.Text = p == "Reset" and "Restoring your avatar..." or "Trying on item..."
		info.TryOn.Text = "Please wait"
		local v24 = p == "Reset" or v22 and v10[v22.ItemType .. tostring(v22.Id)]
		local v25 = v22 and (v22.AssetType == "EmoteAnimation" or v22.BundleType == "Animations" or v22.AssetType and v22.AssetType:find("Animation"))
		local v26 = nil
		local animationPlayedConnection = nil

		if v24 and (v25 or p == "Reset") then
			stopCatalogEmote()
			local character = localPlayer.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
			local animate = character and character:FindFirstChild("Animate")

			if animate and animate:IsA("LocalScript") and animate.Enabled then
				MenuFade.Set(animate, "Enabled", false)
				v26 = animate
			end

			if animator then
				for _, v27 in ipairs(animator:GetPlayingAnimationTracks()) do
					v27:Stop(0)
				end

				animationPlayedConnection = animator.AnimationPlayed:Connect(function(object2)
					object2:Stop(0)
				end)
			end

			info.Message.Text = "Animation stopped. Restoring your look..."
		end

		local v28

		if v22 then
			v28 = {
				id = v22.Id,
				kind = v22.ItemType,
				replayEmote = v22.AssetType == "EmoteAnimation" and not v10[v22.ItemType .. tostring(v22.Id)]
			} or {}
		else
			v28 = {}
		end

		local v29 = call(p, v28)

		if animationPlayedConnection then
			animationPlayedConnection:Disconnect()
		end

		if v26 and v26.Parent then
			MenuFade.Set(v26, "Enabled", true)
		end

		flag2 = false

		if not v29.error then
			if p == "Reset" then
				v10 = {}
				MenuFade.Set(v20, "Visible", false)
				v21 = nil
			elseif v22 then
				v10[v22.ItemType .. tostring(v22.Id)] = v29.trying == true
			end
		end

		if v22 and v22.AssetType == "EmoteAnimation" and count2 ~= v23 then
			v10[v22.ItemType .. tostring(v22.Id)] = nil
		end

		info.TryOn.Text = v11 and v10[v11.ItemType .. tostring(v11.Id)] and "Take off" or "Try on"

		if not v29.error and (v29.stopEmote or p == "Reset") then
			stopCatalogEmote()
		end

		info.Message.Text = v29.error or v29.message

		if not v29.error then
			if v25 and v22.AssetType ~= "EmoteAnimation" then
				resumeAvatarAnimations()
			end

			if v29.emote then
				task.wait(0.5)
			end

			MenuFade.Set(preview.Avatar, "Visible", false)
			MenuFade.Set(preview.Thumbnail, "Visible", true)
			local humanoid = v29.emote and count2 == v23 and v11 == v22 and localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")

			if humanoid then
				stopCatalogEmote()
				local animator = humanoid:FindFirstChildOfClass("Animator")
				local v30 = {}

				if animator then
					for _, v31 in ipairs(animator:GetPlayingAnimationTracks()) do
						v30[v31] = true
					end
				end

				local animationPlayedConnection2 = animator and animator.AnimationPlayed:Connect(function(p2)
					v6[p2] = true
				end)
				local success, result = pcall(function()
					return humanoid:PlayEmoteAsync("CatalogPreview")
				end)

				if animationPlayedConnection2 then
					animationPlayedConnection2:Disconnect()
				end

				if animator then
					for _, v31 in ipairs(animator:GetPlayingAnimationTracks()) do
						if not v30[v31] then
							v6[v31] = true
						end
					end
				end

				if count2 ~= v23 or v11 ~= v22 then
					stopCatalogEmote()
				end

				if not (success and result) then
					info.Message.Text = "Emote equipped; Roblox could not play it on this rig."
				end
			end
		end
	end
end

info.TryOn.Activated:Connect(function()
	appearance("Try")
end)
info.Reset.Activated:Connect(function()
	appearance("Reset")
end)
info.Buy.Activated:Connect(function()
	if flag2 or not v11 then
		return
	end

	flag2 = true
	local v22 = v11
	info.Message.Text = "Opening Roblox purchase prompt..."
	local v23 = call("Buy", {
		id = v22.Id,
		kind = v22.ItemType
	})
	flag2 = false
	info.Message.Text = v23.error or v23.message
end)

local function purchaseFinished(p, p2, p3)
	if p == localPlayer and v11 and v11.Id == p2 then
		info.Message.Text = p3 and "Purchase complete! The item is in your Roblox inventory." or "Purchase closed. No new purchase was confirmed."
	end
end

MarketplaceService.PromptPurchaseFinished:Connect(purchaseFinished)
MarketplaceService.PromptBundlePurchaseFinished:Connect(purchaseFinished)
local object2 = setmetatable({}, {
	__mode = "k"
})

local function connectButton(button)
	if not button:IsA("GuiButton") or object2[button] then
		return
	end

	local textLabel = button:FindFirstChildWhichIsA("TextLabel")
	local name3 = button.Name:lower()
	local text = button:IsA("TextButton") and button.Text or textLabel and textLabel.Text or ""

	if name3 == "catalogbutton" or name3 == "catelogbutton" and text:lower() == "catalog" then
		object2[button] = true
		button.Activated:Connect(function()
			MenuFade.Set(parent, "Enabled", not MenuFade.IsOpen(parent, "Enabled"))

			if MenuFade.IsOpen(parent, "Enabled") then
				if flag4 then
					flag4 = false
					resumeScroll() -- equivalent call inferred; original call site unknown
					parent:SetAttribute("PreserveCatalogPage", false)
				else
					showHome() -- equivalent call inferred; original call site unknown
				end
			end
		end)
	end
end

for _, descendant in ipairs(localPlayer.PlayerGui:GetDescendants()) do
	connectButton(descendant)
end

localPlayer.PlayerGui.DescendantAdded:Connect(connectButton)
localPlayer.CharacterAdded:Connect(function()
	stopCatalogEmote()

	if v14 then
		v14:Destroy()
		v14 = nil
	end

	MenuFade.Set(preview.Avatar, "Visible", false)
	MenuFade.Set(preview.Thumbnail, "Visible", true)

	if MenuFade.IsOpen(parent, "Enabled") then
		info.Message.Text = "Your avatar reset after respawning."
	end
end)
layout()
local v22 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function nearBottom()
	return results.CanvasPosition.Y + results.AbsoluteWindowSize.Y >= results.AbsoluteCanvasSize.Y - math.max(
		600,
		results.AbsoluteWindowSize.Y
	)
end

fn = function()
	if catalogHome.Visible or v22 or flag or v5 >= 2 or count >= 2 or not parent.Enabled or details.Visible or filterPanel.Visible or not (v4 and token) or not nearBottom() then
		return
	end

	v22 = true
	task.delay(math.max(0.1, 1.1 - (os.clock() - now)), function()
		v22 = false

		if catalogHome.Visible or flag or v5 >= 2 or count >= 2 or not parent.Enabled or details.Visible or filterPanel.Visible or not (v4 and token) or not nearBottom() then
			return
		end

		now = os.clock()
		count += 1
		search(true)
	end)
end

results:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
	v5 = 0
	count = 0
	MenuFade.Set(panel.More, "Visible", false)
	fn()
end)
results:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(fn)
results:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(fn)
details:GetPropertyChangedSignal("Visible"):Connect(fn)
filterPanel:GetPropertyChangedSignal("Visible"):Connect(fn)
info.Creator.BrowseCreator.Activated:Connect(function()
	if flag or flag2 or not v11 then
		return
	end

	local v23 = v11

	if not v23.CreatorTargetId then
		return
	end

	count2 += 1
	MenuFade.Set(details, "Visible", false)
	v11 = nil
	name = "All"
	name2 = "Recommended"
	v2 = v23.CreatorType == "Group" and "Group" or "User"
	v3 = {
		creatorId = v23.CreatorTargetId,
		creator = v23.CreatorName,
		creatorType = v2,
		sort = name2,
		minPrice = 1,
		offSale = false
	}
	panel.SearchInput.Text = ""
	fields.Creator.Text = v23.CreatorName or ""
	fields.CreatorType.Text = v2
	fields.MinPrice.Text = "1"
	fields.MaxPrice.Text = ""
	fields.OffSale.Text = "Include off-sale: No"
	offSale = false
	styleSort()

	for _, button in ipairs(panel.Tabs:GetChildren()) do
		if button:IsA("TextButton") then
			button.BackgroundColor3 = button.Name == "All" and CatalogUI.colors.accent or CatalogUI.colors.raised
		end
	end

	panel.Title.Text = (v23.CreatorName or "Creator") .. "'s items"
	panel.Subtitle.Text = "Popular items from this creator"
	search(false)
end)
info.Creator.BrowseCreator.MouseEnter:Connect(function()
	info.Creator.TextColor3 = CatalogUI.colors.text
end)
info.Creator.BrowseCreator.MouseLeave:Connect(function()
	info.Creator.TextColor3 = CatalogUI.colors.muted
end)
panel.BackToCatalog.Activated:Connect(function()
	if flag then
		return
	end

	v3 = {}
	name = "Featured"
	name2 = "Recommended"
	v2 = "User"
	offSale = false
	panel.SearchInput.Text = ""
	fields.Creator.Text = ""
	fields.CreatorType.Text = "User"
	fields.Creator.PlaceholderText = "Exact username"
	fields.MinPrice.Text = "1"
	fields.MaxPrice.Text = ""
	fields.OffSale.Text = "Include off-sale: No"
	styleSort()

	for _, button in ipairs(panel.Tabs:GetChildren()) do
		if button:IsA("TextButton") then
			button.BackgroundColor3 = button.Name == "Featured" and CatalogUI.colors.accent or CatalogUI.colors.raised
		end
	end

	search(false)
end)

fn2 = function(p, p2)
	local v23 = {
		id = p.Id,
		kind = p.ItemType
	}
	local v24 = extra("State", v23)

	if p2 ~= count2 then
		return
	end

	favorite = v24.favorite == true
	v7[favoriteKey(p)] = favorite and true or nil
	paintStars()
	info.Favorite.Text = v24.error and "Retry favorite" or favorite and "Remove favorite" or "Save favorite"
	info.Favorite.Interactable = true
	local v25 = extra("Related", v23)

	if p2 ~= count2 then
		return
	end

	info.RelatedHeading.Text = v25.error and "Related items unavailable" or #(v25.items or {}) == 0 and "No related items found" or "Related items"

	for _, v26 in ipairs(CatalogPriceRange.Filter(v25.items or {}, v3.minPrice, v3.maxPrice, v3.offSale)) do
		local button = CatalogUI.button(
			"Related_" .. tostring(v26.Id),
			info.Related,
			"",
			UDim2.new(),
			UDim2.fromOffset(125, 194)
		)
		CatalogUI.make("ImageLabel", "Thumbnail", button, {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(4, 4),
			Size = UDim2.new(1, -8, 0, 108),
			Image = thumbnail(v26)
		})
		CatalogUI.label("ItemName", button, v26.Name, UDim2.fromOffset(7, 116), UDim2.new(1, -14, 0, 32), 11)
		creatorLine(button, v26, 149, 10)
		local label = CatalogUI.label
		local v28 = price(v26) -- equivalent call inferred; original call site unknown
		label("Price", button, v28, UDim2.fromOffset(7, 171), UDim2.new(1, -42, 0, 18), 11)
		addStar(button, v26)
		local v29 = v26
		button.Activated:Connect(function()
			if os.clock() < v9 or flag2 then
				return
			end

			showItem(v29, true)
		end)
	end
end

info.Favorite.Activated:Connect(function()
	if not (v11 and info.Favorite.Interactable) then
		return
	end

	local v23 = v11
	local v24 = count2
	info.Favorite.Interactable = false
	local v25 = extra("Favorite", {
		id = v23.Id,
		kind = v23.ItemType,
		value = not favorite
	})

	if v24 ~= count2 then
		return
	end

	info.Favorite.Interactable = true

	if v25.error then
		info.Message.Text = v25.error
		return
	end

	favorite = v25.favorite
	info.Favorite.Text = favorite and "Remove favorite" or "Save favorite"
	info.Message.Text = v25.studio and "Favorite updated for this Studio session." or "Favorites updated."
end)

for _, button in ipairs(fields:GetChildren()) do
	if not (button:IsA("TextButton") and button:GetAttribute("Budget") ~= nil) then
		continue
	end

	local v23 = button
	button.Activated:Connect(function()
		local budget = v23:GetAttribute("Budget")
		fields.MinPrice.Text = budget == 0 and "0" or "1"
		fields.MaxPrice.Text = tostring(budget)
		fields.Hint.Text = "Budget selected. Press Apply filters."
	end)
end

localPlayer:GetAttributeChangedSignal("CatalogHistoryRevision"):Connect(function()
	v10 = {}
	info.TryOn.Text = "Try on"
	stopCatalogEmote()
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function syncCatalogNavigation()
	panel.Close.Visible = not panel.BackToCatalog.Visible
end

panel.BackToCatalog:GetPropertyChangedSignal("Visible"):Connect(syncCatalogNavigation)
syncCatalogNavigation() -- equivalent call inferred; original call site unknown
local visible = false

for _, button in ipairs(parent.Root.AnniversaryPanel.Items:GetChildren()) do
	if not (button:IsA("GuiButton") and button:GetAttribute("ItemId")) then
		continue
	end

	local v23 = button
	button.Activated:Connect(function()
		if flag2 or flag or details.Visible or filterPanel.Visible then
			return
		end

		visible = catalogHome.Visible
		MenuFade.Set(catalogHome, "Visible", false)
		showItem({
			Id = v23:GetAttribute("ItemId"),
			ItemType = "Asset",
			Name = v23.ItemName.Text,
			CreatorName = "Roblox"
		})
	end)
end

details.Back.Activated:Connect(function()
	if visible then
		visible = false
		showHome() -- equivalent call inferred; original call site unknown
	end
end)
parent:GetPropertyChangedSignal("Enabled"):Connect(function()
	if not (parent.Enabled or parent:GetAttribute("PreserveCatalogPage")) then
		visible = false
	end
end)
localPlayer:GetAttributeChangedSignal("MobileLayoutRevision"):Connect(function()
	layout()
	positionCatalogClose()
end)