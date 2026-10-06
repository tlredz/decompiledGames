local MenuFade = require(game.ReplicatedStorage:WaitForChild("MenuFade"))
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local localPlayer = Players.LocalPlayer
local parent = script.Parent
local CatalogUI = require(game.ReplicatedStorage:WaitForChild("CatalogUI"))
local OutfitCodec = require(game.ReplicatedStorage:WaitForChild("OutfitCodec"))
local communityRemote = game.ReplicatedStorage:WaitForChild("CommunityRemote")
local panel = parent.Root.Panel
local details = panel.Details
local info = details.Body.Info
local preview = details.Body.Preview
local results = panel.Results
local source = "Community"
local sort = "Top"
local item = nil
local flag = false
local flag2 = false
local count = 0
local v3 = {}
local v4 = {}
local v5 = nil
local v6 = 0
local camera = Instance.new("Camera")
camera.FieldOfView = 35
camera.Parent = preview.Avatar
preview.Avatar.CurrentCamera = camera
local worldModel = Instance.new("WorldModel")
worldModel.Parent = preview.Avatar
local count2 = 0
local v7 = {}
local v8 = 0
local now = 0
local v9 = false
local v10 = false

local function call(p, options)
	if p == "Feed" then
		local v11 = 1.1 - (os.clock() - now)

		if v11 > 0 then
			task.wait(v11)
		end

		now = os.clock()
	end

	local success, result = pcall(function()
		return communityRemote:InvokeServer(p, options or {})
	end)
	return (not success or type(result) ~= "table" or not result) and {
		error = "Connection interrupted. Please try again."
	} or result
end

local function modelFrom(p)
	local decoded = OutfitCodec.decode(p)
	local success, result = pcall(function()
		return Players:CreateHumanoidModelFromDescriptionAsync(decoded, Enum.HumanoidRigType.R15)
	end)
	decoded:Destroy()

	if not success then
		return nil
	end

	for _, descendant in ipairs(result:GetDescendants()) do
		if descendant:IsA("LuaSourceContainer") or descendant:IsA("Sound") then
			descendant:Destroy()
		elseif descendant:IsA("BasePart") then
			descendant.CanCollide = false
		end
	end

	local humanoidRootPart = result:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		humanoidRootPart.Anchored = true
	end

	result:PivotTo(CFrame.new())
	return result
end

local function fit(instance, camera2, p, value)
	local boundingBox, v11 = instance:GetBoundingBox()
	local v12 = math.max(0.3, p.AbsoluteSize.X / math.max(1, p.AbsoluteSize.Y))
	local v13 = math.max(v11.Y, v11.X / v12) / (math.tan((math.rad(camera2.FieldOfView / 2))) * 2) + v11.Z * 0.6
	camera2.CFrame = CFrame.lookAt(
		boundingBox.Position + Vector3.new(math.sin(value or 0) * v13, 0.2, -math.cos(value or 0) * v13),
		boundingBox.Position
	)
end

local fn

fn = function()
	while v8 < 2 and #v7 > 0 do
		local v11 = table.remove(v7, 1)
		v8 += 1
		task.spawn(function()
			local v13

			if v11.generation == count2 and v11.frame.Parent then
				v13 = modelFrom(v11.data)
			else
				v13 = nil
			end

			if v13 then
				if v11.generation == count2 and v11.frame.Parent then
					local worldModel2 = Instance.new("WorldModel")
					worldModel2.Parent = v11.frame
					v13.Parent = worldModel2
					local camera2 = Instance.new("Camera")
					camera2.FieldOfView = 35
					camera2.Parent = v11.frame
					v11.frame.CurrentCamera = camera2
					fit(v13, camera2, v11.frame, 0)
					v11.frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
						if v13.Parent then
							fit(v13, camera2, v11.frame, 0)
						end
					end)
				else
					v13:Destroy()
				end
			end

			v8 -= 1
			fn()
		end)
	end
end

local function layout()
	local v11 = results.AbsoluteSize.X - 8
	local v12 = math.max(1, (math.floor((v11 + 12) / 180)))
	results.Grid.CellSize = UDim2.fromOffset(math.floor((v11 - (v12 - 1) * 12) / v12), 250)
	local body = details.Body

	if body.AbsoluteSize.X < 600 then
		preview.Position = UDim2.new()
		preview.Size = UDim2.new(1, -6, 0, 310)
		info.Position = UDim2.fromOffset(0, 330)
		info.Size = UDim2.new(1, -6, 0, 490)
		body.CanvasSize = UDim2.fromOffset(0, 830)
	else
		preview.Position = UDim2.new()
		preview.Size = UDim2.new(0.43, 0, 0, (math.max(480, body.AbsoluteSize.Y - 4)))
		info.Position = UDim2.new(0.46, 0, 0, 0)
		info.Size = UDim2.new(0.54, -6, 0, 490)
		body.CanvasSize = UDim2.fromOffset(0, (math.max(490, body.AbsoluteSize.Y)))
	end
end

results:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)
details.Body:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)

local function showModel(appearance, count3)
	local v11 = modelFrom(appearance)

	if count3 == count then
		if not v11 then
			info.Message.Text = "Preview could not load. You can still try Wear."
			return
		end

		if v5 then
			v5:Destroy()
		end

		v5 = v11
		v11.Parent = worldModel
		v6 = 0
		fit(v11, camera, preview.Avatar, v6)
		MenuFade.Set(preview.Thumbnail, "Visible", false)
		MenuFade.Set(preview.Avatar, "Visible", true)
	elseif v11 then
		v11:Destroy()
	end
end

local function showItem(data)
	count += 1
	local v11 = count
	item = nil
	MenuFade.Set(details, "Visible", true)
	details.Body.CanvasPosition = Vector2.zero
	info.ItemName.Text = data.title
	info.Creator.Text = "By " .. (data.creator or "Roblox")
	local price = info.Price
	local text

	if data.source == "Roblox" then
		text = type(data.price) ~= "number" and "Roblox character bundle" or "R$ " .. data.price or "Roblox character bundle"
	else
		text = tostring(data.likes or 0) .. " likes"
	end

	price.Text = text
	info.DescriptionScroll.Description.Text = data.source == "Roblox" and "A character bundle from the Roblox Marketplace." or "A player-created outfit posted in this game. Wear it here, or review its available items before purchasing."
	info.Message.Text = "Loading outfit..."
	preview.Thumbnail.Visible = data.source == "Roblox"
	preview.Thumbnail.Image = data.source ~= "Roblox" and "" or "rbxthumb://type=BundleThumbnail&id=" .. string.format(
		"%.0f",
		data.id
	) .. "&w=420&h=420" or ""
	MenuFade.Set(preview.Avatar, "Visible", false)
	info.TryOn.Interactable = false
	info.Buy.Interactable = false
	MenuFade.Set(info.Like, "Visible", false)
	MenuFade.Set(info.RemovePost, "Visible", false)
	layout()
	local v13 = {
		id = data.id,
		source = data.source
	}
	local v14 = "Details"
	local success, result = pcall(function()
		return communityRemote:InvokeServer(v14, v13 or {})
	end)
	local v15 = (not success or type(result) ~= "table" or not result) and {
		error = "Connection interrupted. Please try again."
	} or result

	if count ~= v11 then
		return
	end

	if v15.error then
		info.Message.Text = v15.error
		return
	end

	item = v15.item
	info.TryOn.Interactable = true
	info.Buy.Interactable = true
	info.Buy.Text = item.source == "Roblox" and "Buy bundle" or "Buy available items"
	info.Like.Visible = item.source == "Community"
	info.Like.Text = item.liked and "Liked" or "Like outfit"
	info.Like.Interactable = not item.liked and item.creatorId ~= localPlayer.UserId
	info.RemovePost.Visible = item.creatorId == localPlayer.UserId
	info.RemovePost.Text = "Remove post"

	if item.description then
		info.DescriptionScroll.Description.Text = item.description
	end

	info.Message.Text = "Wear changes your look in this game only. Roblox confirms any purchase."

	if item.appearance then
		task.spawn(showModel, item.appearance, v11)
	end
end

local function filterCards()
	local text = panel.SearchInput.Text:lower()
	local count3 = 0

	for _, v11 in ipairs(v3) do
		local v12 = text == "" or (v11.item.title .. " " .. (v11.item.creator or "")):lower():find(text, 1, true)
		v11.button.Visible = v12 and true or false

		if v12 then
			count3 += 1
		end
	end
end

local function addCards(items)
	for _, v11 in ipairs(items) do
		local v12 = v11.source .. tostring(v11.id)

		if v4[v12] then
			continue
		end

		v4[v12] = true
		local button = CatalogUI.button("Outfit_" .. tostring(v11.id), results, "", UDim2.new(), UDim2.new())
		button.LayoutOrder = #v3 + 1
		button.BackgroundColor3 = CatalogUI.colors.surface
		button:SetAttribute("OutfitId", v11.id)
		button:SetAttribute("Source", v11.source)

		if v11.source == "Roblox" then
			CatalogUI.make("ImageLabel", "Thumbnail", button, {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(5, 4),
				Size = UDim2.new(1, -10, 0, 174),
				Image = "rbxthumb://type=BundleThumbnail&id=" .. string.format("%.0f", v11.id) .. "&w=420&h=420",
				ScaleType = Enum.ScaleType.Fit
			})
		else
			local frame = CatalogUI.make("ViewportFrame", "Preview", button, {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(5, 4),
				Size = UDim2.new(1, -10, 0, 174),
				Ambient = Color3.fromRGB(200, 200, 210),
				LightColor = Color3.new(1, 1, 1)
			})
			table.insert(v7, {
				frame = frame,
				data = v11.appearance,
				generation = count2
			})
		end

		local label = CatalogUI.label(
			"OutfitTitle",
			button,
			v11.title,
			UDim2.fromOffset(10, 180),
			UDim2.new(1, -20, 0, 32),
			14
		)
		label.TextTruncate = Enum.TextTruncate.AtEnd
		local label_2 = CatalogUI.label(
			"Creator",
			button,
			"By " .. (v11.creator or "Roblox"),
			UDim2.fromOffset(10, 213),
			UDim2.new(1, -20, 0, 18),
			11
		)
		label_2.TextColor3 = CatalogUI.colors.muted
		local label_3 = CatalogUI.label(
			"Likes",
			button,
			v11.source == "Roblox" and "R$ " .. tostring(v11.price) or (v11.likes or 0) .. " likes",
			UDim2.fromOffset(10, 232),
			UDim2.new(1, -20, 0, 16),
			11
		)
		label_3.TextColor3 = Color3.fromRGB(180, 163, 255)
		local v13 = v11
		button.Activated:Connect(function()
			showItem(v13)
		end)
		table.insert(v3, {
			button = button,
			item = v11
		})
	end

	filterCards()
	fn()
end

local function refresh(more)
	if flag then
		return
	end

	flag = true

	if not more then
		v9 = false
	end

	panel.Status.Text = more and "Loading more outfits..." or "Loading outfits..."
	panel.Search.Text = "..."

	if not more then
		count2 += 1
		v7 = {}
		v3 = {}
		v4 = {}

		for _, guiObject in ipairs(results:GetChildren()) do
			if guiObject:IsA("GuiObject") then
				guiObject:Destroy()
			end
		end

		results.CanvasPosition = Vector2.zero
	end

	local v11 = call("Feed", {
		source = source,
		sort = sort,
		more = more
	})
	flag = false
	panel.Search.Text = "Refresh"

	if v11.error then
		panel.Status.Text = v11.error
		v10 = true
	else
		v10 = false
		addCards(v11.items or {})
		v9 = v11.more == true
		panel.More.Visible = false
		panel.Empty.Visible = #v3 == 0
		panel.Status.Text = source == "Roblox" and "Paid bundles · Bestselling this week" or #v3 .. " outfits posted in this game" .. (v11.studio and " · Studio session" or "")
	end
end

local function fn2()
	if not parent.Enabled or details.Visible or flag or v10 or not v9 then
		return
	end

	if panel.SearchInput.Text ~= "" then
		return
	end

	if results.CanvasPosition.Y + results.AbsoluteWindowSize.Y >= results.AbsoluteCanvasSize.Y - 260 then
		task.spawn(refresh, true)
	end
end

results:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
	v10 = false
	fn2()
end)
results:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(function()
	if fn2 then
		fn2()
	end
end)
task.spawn(function()
	while parent.Parent do
		task.wait(0.3)
		fn2()
	end
end)
local v11 = {
	Top = { "Community", "Top" },
	Newest = { "Community", "Newest" },
	Mine = { "Mine", "Newest" },
	Roblox = { "Roblox", "Top" }
}

for _, button in ipairs(panel.Tabs:GetChildren()) do
	if not button:IsA("TextButton") then
		continue
	end

	local v12 = button
	button.Activated:Connect(function()
		if flag then
			return
		end

		source, sort = table.unpack(v11[v12.Name])

		for i, button2 in ipairs(panel.Tabs:GetChildren()) do
			if button2:IsA("TextButton") then
				button2.BackgroundColor3 = button2 == v12 and CatalogUI.colors.accent or CatalogUI.colors.raised
			end
		end

		refresh(false)
	end)
end

panel.Search.Activated:Connect(function()
	refresh(false)
end)
panel.More.Activated:Connect(function()
	refresh(true)
end)
panel.SearchInput:GetPropertyChangedSignal("Text"):Connect(filterCards)
panel.Close.Activated:Connect(function()
	MenuFade.Set(parent, "Enabled", false)
	count += 1
end)
details.Back.Activated:Connect(function()
	MenuFade.Set(details, "Visible", false)
	count += 1
	item = nil
end)
preview.RotateLeft.Activated:Connect(function()
	v6 -= 0.5235987755982988

	if v5 then
		fit(v5, camera, preview.Avatar, v6)
	end
end)
preview.RotateRight.Activated:Connect(function()
	v6 += 0.5235987755982988

	if v5 then
		fit(v5, camera, preview.Avatar, v6)
	end
end)
preview.ImageMode.Activated:Connect(function()
	if item and item.source == "Roblox" then
		MenuFade.Set(preview.Thumbnail, "Visible", true)
		MenuFade.Set(preview.Avatar, "Visible", false)
	end
end)
preview.AvatarMode.Activated:Connect(function()
	if item and item.appearance then
		showModel(item.appearance, count)
	else
		info.Message.Text = "Press Wear to try this bundle on your character."
	end
end)

local function action(p)
	if flag2 or p ~= "Reset" and not item then
		return
	end

	flag2 = true
	local v12 = item
	info.Message.Text = p == "Buy" and "Checking item availability and ownership..." or "Please wait..."
	local v13 = call(p, {
		id = v12 and v12.id,
		source = v12 and v12.source
	})
	flag2 = false
	info.Message.Text = v13.error or v13.message or "Done."

	if v13.item then
		item = v13.item
		info.Price.Text = item.likes .. " likes"
		info.Like.Text = item.liked and "Liked" or "Like outfit"
		info.Like.Interactable = not item.liked
	end

	if p == "Remove" and not v13.error then
		MenuFade.Set(details, "Visible", false)
		count += 1
		refresh(false)
	end
end

info.TryOn.Activated:Connect(function()
	action("Wear")
end)
info.Buy.Activated:Connect(function()
	action("Buy")
end)
info.Reset.Activated:Connect(function()
	action("Reset")
end)
info.Like.Activated:Connect(function()
	action("Like")
end)
info.RemovePost.Activated:Connect(function()
	if info.RemovePost.Text == "Confirm remove" then
		action("Remove")
	else
		info.RemovePost.Text = "Confirm remove"
	end
end)
local publishPanel = panel.PublishPanel
panel.Filters.Activated:Connect(function()
	MenuFade.Set(publishPanel, "Visible", true)
	publishPanel.Status.Text = "Publish your current in-game look to this game's community."
end)
publishPanel.Cancel.Activated:Connect(function()
	MenuFade.Set(publishPanel, "Visible", false)
end)
publishPanel.Confirm.Activated:Connect(function()
	if flag2 then
		return
	end

	flag2 = true
	publishPanel.Status.Text = "Publishing..."
	publishPanel.Confirm.Text = "Please wait"
	local v12 = {
		title = publishPanel.OutfitName.Text
	}
	local v13 = "Publish"
	local success, result = pcall(function()
		return communityRemote:InvokeServer(v13, v12 or {})
	end)
	local v14 = (not success or type(result) ~= "table" or not result) and {
		error = "Connection interrupted. Please try again."
	} or result
	flag2 = false
	publishPanel.Confirm.Text = "Publish current look"
	publishPanel.Status.Text = v14.error or v14.message

	if not v14.error then
		MenuFade.Set(publishPanel, "Visible", false)
		source = "Mine"
		sort = "Newest"

		for _, button in ipairs(panel.Tabs:GetChildren()) do
			if button:IsA("TextButton") then
				button.BackgroundColor3 = button.Name == "Mine" and CatalogUI.colors.accent or CatalogUI.colors.raised
			end
		end

		refresh(false)
	end
end)
MarketplaceService.PromptBulkPurchaseFinished:Connect(function(p, p2)
	if p == localPlayer then
		info.Message.Text = p2 == Enum.MarketplaceBulkPurchasePromptStatus.Completed and "Purchase prompt completed. Check your Roblox inventory for purchased items." or "Purchase prompt closed."
	end
end)
local object = setmetatable({}, {
	__mode = "k"
})

local function bind(button)
	if not button:IsA("GuiButton") or button.Name ~= "CommunityButton" or object[button] then
		return
	end

	object[button] = true
	button.Activated:Connect(function()
		MenuFade.Set(parent, "Enabled", not MenuFade.IsOpen(parent, "Enabled"))

		if MenuFade.IsOpen(parent, "Enabled") then
			local catalogGui = localPlayer.PlayerGui:FindFirstChild("CatalogGui")

			if catalogGui then
				MenuFade.Set(catalogGui, "Enabled", false)
			end

			refresh(false)
		end
	end)
end

for _, descendant in ipairs(localPlayer.PlayerGui:GetDescendants()) do
	bind(descendant)
end

localPlayer.PlayerGui.DescendantAdded:Connect(bind)
layout()
local UserInputService = game:GetService("UserInputService")
local v12 = false
local v13 = nil
local X = 0
preview.Avatar.Active = true
preview.Avatar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		v12 = true
		v13 = input.UserInputType == Enum.UserInputType.Touch and input or nil
		X = input.Position.X
		details.Body.ScrollingEnabled = false
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if not (v12 and parent.Enabled and details.Visible) then
		return
	end

	if v13 and input == v13 or not v13 and input.UserInputType == Enum.UserInputType.MouseMovement then
		v6 += (input.Position.X - X) * 0.012
		X = input.Position.X

		if v5 then
			fit(v5, camera, preview.Avatar, v6)
		end
	end
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function release()
	v12 = false
	v13 = nil
	details.Body.ScrollingEnabled = true
end

UserInputService.InputEnded:Connect(function(input)
	if input == v13 or input.UserInputType == Enum.UserInputType.MouseButton1 then
		release() -- equivalent call inferred; original call site unknown
	end
end)
parent:GetPropertyChangedSignal("Enabled"):Connect(release)
details:GetPropertyChangedSignal("Visible"):Connect(release)
preview.Avatar:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	if v5 then
		fit(v5, camera, preview.Avatar, v6)
	end
end)
preview.Avatar.InputEnded:Connect(function(input)
	if input == v13 or input.UserInputType == Enum.UserInputType.MouseButton1 then
		release() -- equivalent call inferred; original call site unknown
	end
end)
local RunService = game:GetService("RunService")
RunService.RenderStepped:Connect(function()
	if v12 and not (v13 or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)) then
		release() -- equivalent call inferred; original call site unknown
	end
end)
local interactablesByGuiObject = {}

local function syncOutfitInput()
	if parent.Enabled and MenuFade.IsOpen(details, "Visible") then
		for _, guiObject in ipairs(panel:GetDescendants()) do
			if not guiObject:IsA("GuiObject") or guiObject == details or guiObject:IsDescendantOf(details) then
				continue
			end

			if interactablesByGuiObject[guiObject] == nil then
				interactablesByGuiObject[guiObject] = guiObject.Interactable
			end

			guiObject.Interactable = false
		end
	else
		for k, interactable in pairs(interactablesByGuiObject) do
			if k.Parent then
				k.Interactable = interactable
			end
		end

		table.clear(interactablesByGuiObject)
	end
end

details:GetPropertyChangedSignal("Visible"):Connect(syncOutfitInput)
parent:GetPropertyChangedSignal("Enabled"):Connect(syncOutfitInput)
panel.DescendantAdded:Connect(function()
	task.defer(syncOutfitInput)
end)
syncOutfitInput()