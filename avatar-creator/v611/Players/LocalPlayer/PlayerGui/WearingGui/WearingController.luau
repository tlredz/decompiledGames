local MenuFade = require(game.ReplicatedStorage:WaitForChild("MenuFade"))
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local localPlayer = Players.LocalPlayer
local parent = script.Parent
local CatalogUI = require(game.ReplicatedStorage:WaitForChild("CatalogUI"))
local wearingRemote = game.ReplicatedStorage:WaitForChild("WearingRemote")
local panel = parent.Root.Panel
local current = panel.Current
local results = current.Results
local flag = false
local now = 0
local flag2 = false
local connections = {}
local onActivated

local function call(p, options)
	local v = 0.9 - (os.clock() - now)

	if v > 0 then
		task.wait(v)
	end

	now = os.clock()
	local success, result = pcall(function()
		return wearingRemote:InvokeServer(p, options or {})
	end)
	return (not success or type(result) ~= "table" or not result) and {
		error = "Connection interrupted. Please try again."
	} or result
end

local function purchase(p, id)
	if flag then
		return
	end

	flag = true
	current.Status.Text = "Checking ownership and availability..."
	local v = call(p, {
		id = id
	})
	flag = false
	current.Status.Text = v.error or v.message

	if flag2 then
		flag2 = false
		task.defer(onActivated)
	end
end

local function layout()
	local v = results.AbsoluteSize.X - 8
	local MobileCatalogLayout = require(game.ReplicatedStorage.MobileCatalogLayout)
	local isMobile = MobileCatalogLayout.IsMobile()
	local v2 = math.max(1, (math.floor((v + 12) / (isMobile and 148 or 180))))
	local v3 = isMobile and math.min(142, (math.max(48, results.AbsoluteSize.Y - 100))) or 142
	results.Grid.CellSize = UDim2.fromOffset(
		math.floor((v - (v2 - 1) * 12) / v2),
		not isMobile and 265 or v3 + 100 or 265
	)

	for _, frame in results:GetChildren() do
		if not frame:IsA("Frame") then
			continue
		end

		frame.Thumbnail.Position = UDim2.fromOffset(6, 4)
		frame.Thumbnail.Size = UDim2.new(1, -12, 0, v3)
		frame.ItemName.Position = UDim2.fromOffset(10, v3 + 8)
		frame.ItemName.Size = UDim2.new(1, -20, 0, isMobile and 28 or 40)
		frame.ItemName.TextSize = isMobile and 12 or 14
		frame.Price.Position = UDim2.fromOffset(10, v3 + (isMobile and 40 or 52))
		frame.Price.Size = UDim2.new(1, -20, 0, isMobile and 18 or 24)
		frame.Price.TextSize = isMobile and 11 or 12
		frame.Buy.Position = UDim2.fromOffset(10, v3 + (isMobile and 62 or 83))
		frame.Buy.Size = UDim2.new(1, -20, 0, isMobile and 34 or 32)
		frame.Buy.TextSize = isMobile and 12 or 14
	end
end

results:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)

onActivated = function()
	if not (parent.Enabled and current.Visible) then
		return
	end

	if flag then
		flag2 = true
		return
	end

	flag = true
	current.Status.Text = "Loading what you're wearing..."
	local v = call("List")
	flag = false

	if v.error then
		current.Status.Text = v.error
		return
	end

	for _, guiObject in ipairs(results:GetChildren()) do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end

	local count = 0
	local count2 = 0
	local count3 = 0
	local count4 = 0

	for i, v2 in ipairs(v.items or {}) do
		local v3 = CatalogUI.make("Frame", "Item_" .. string.format("%.0f", v2.id), results, {
			BackgroundColor3 = CatalogUI.colors.surface,
			BorderSizePixel = 0,
			LayoutOrder = i
		})
		CatalogUI.round(v3, 10)
		v3:SetAttribute("ItemId", v2.id)
		CatalogUI.make("ImageLabel", "Thumbnail", v3, {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(6, 4),
			Size = UDim2.new(1, -12, 0, 142),
			ScaleType = Enum.ScaleType.Fit,
			Image = "rbxthumb://type=Asset&id=" .. string.format("%.0f", v2.id) .. "&w=420&h=420"
		})
		local label = CatalogUI.label("ItemName", v3, v2.name, UDim2.fromOffset(10, 150), UDim2.new(1, -20, 0, 40), 14)
		label.TextTruncate = Enum.TextTruncate.AtEnd
		local v4 = "Unavailable individually"

		if v2.known then
			if v2.owned then
				count += 1
				v4 = "Owned"
			elseif v2.redemptionOnly then
				count2 += 1
				v4 = "Redeem through UGC Claim"
			elseif v2.available then
				count3 += 1
				v4 = type(v2.price) ~= "number" and "Price in Roblox prompt" or v2.price == 0 and "Free" or "R$ " .. v2.price or "Price in Roblox prompt"
			else
				count2 += 1
			end
		else
			count4 += 1
			v4 = "Could not check item"
		end

		local label_2 = CatalogUI.label("Price", v3, v4, UDim2.fromOffset(10, 194), UDim2.new(1, -20, 0, 24), 12)
		label_2.TextColor3 = CatalogUI.colors.muted
		local button = CatalogUI.button(
			"Buy",
			v3,
			v2.owned and "Owned" or not v2.known and "Retry" or v2.available and "Buy item" or "Unavailable",
			UDim2.fromOffset(10, 225),
			UDim2.new(1, -20, 0, 32),
			v2.available and not v2.owned
		)

		if v2.redemptionOnly and not v2.owned then
			button.Text = "Redemption only"
		end

		button.Interactable = not (v2.redemptionOnly or v2.owned) and (v2.available or not v2.known)
		local v5 = v2
		button.Activated:Connect(function()
			if v5.known then
				purchase("BuyOne", v5.id)
			else
				onActivated()
			end
		end)
	end

	current.Summary.Text = #(v.items or {}) .. " equipped  ·  " .. count .. " owned  ·  " .. count3 .. " available to buy"
	current.BuyAll.Text = count3 > 20 and "Buy next 20 items" or "Buy all available"
	local buyAll = current.BuyAll
	buyAll.Interactable = count3 > 0 and count4 == 0
	current.BuyAll.AutoButtonColor = current.BuyAll.Interactable
	current.BuyAll.BackgroundColor3 = current.BuyAll.Interactable and CatalogUI.colors.accent or CatalogUI.colors.raised
	current.Status.Text = count4 > 0 and "Some item checks failed. Refresh before buying all." or count2 > 0 and count2 .. " items require redemption, are off sale, or are bundle-only." or "Roblox shows the final price before you confirm a purchase."
	current.Empty.Visible = #(v.items or {}) == 0
	layout()

	if flag2 then
		flag2 = false
		task.defer(onActivated)
	end
end

current.Refresh.Activated:Connect(onActivated)
current.BuyAll.Activated:Connect(function()
	purchase("BuyAll")
end)
panel.Close.Activated:Connect(function()
	MenuFade.Set(parent, "Enabled", false)
end)

local function schedule()
	if parent.Enabled and current.Visible then
		flag2 = true
		task.delay(1.2, function()
			if flag2 and not flag then
				flag2 = false
				onActivated()
			end
		end)
	end
end

local function bindCharacter(instance)
	for _, connection in ipairs(connections) do
		connection:Disconnect()
	end

	connections = {}
	local humanoid = instance:WaitForChild("Humanoid", 10)

	if not humanoid then
		return
	end

	table.insert(connections, humanoid.ApplyDescriptionFinished:Connect(schedule))
	table.insert(connections, instance.ChildAdded:Connect(function(instance2)
		if (instance2:IsA("Accessory") or instance2:IsA("Clothing") or instance2:IsA("ShirtGraphic")) and parent.Enabled then
			if not current.Visible then
				return
			end

			flag2 = true
			task.delay(1.2, function()
				if flag2 and not flag then
					flag2 = false
					onActivated()
				end
			end)
		end
	end))
	table.insert(connections, instance.ChildRemoved:Connect(function(instance2)
		if (instance2:IsA("Accessory") or instance2:IsA("Clothing") or instance2:IsA("ShirtGraphic")) and parent.Enabled then
			if not current.Visible then
				return
			end

			flag2 = true
			task.delay(1.2, function()
				if flag2 and not flag then
					flag2 = false
					onActivated()
				end
			end)
		end
	end))

	if parent.Enabled then
		if not current.Visible then
			return
		end

		flag2 = true
		task.delay(1.2, function()
			if flag2 and not flag then
				flag2 = false
				onActivated()
			end
		end)
	end
end

localPlayer.CharacterAdded:Connect(bindCharacter)

if localPlayer.Character then
	task.spawn(bindCharacter, localPlayer.Character)
end

MarketplaceService.PromptPurchaseFinished:Connect(function(p)
	if p == localPlayer and parent.Enabled then
		if not current.Visible then
			return
		end

		flag2 = true
		task.delay(1.2, function()
			if flag2 and not flag then
				flag2 = false
				onActivated()
			end
		end)
	end
end)
MarketplaceService.PromptBulkPurchaseFinished:Connect(function(p)
	if p == localPlayer and parent.Enabled then
		if not current.Visible then
			return
		end

		flag2 = true
		task.delay(1.2, function()
			if flag2 and not flag then
				flag2 = false
				onActivated()
			end
		end)
	end
end)
local object = setmetatable({}, {
	__mode = "k"
})

local function bind(button)
	if not button:IsA("GuiButton") or button.Name ~= "WearingButton" or object[button] then
		return
	end

	object[button] = true
	button.Activated:Connect(function()
		MenuFade.Set(parent, "Enabled", not MenuFade.IsOpen(parent, "Enabled"))

		if MenuFade.IsOpen(parent, "Enabled") then
			for _, childName in ipairs({ "CatalogGui", "CommunityGui" }) do
				local child = localPlayer.PlayerGui:FindFirstChild(childName)

				if child then
					MenuFade.Set(child, "Enabled", false)
				end
			end

			onActivated()
		end
	end)
end

for _, descendant in ipairs(localPlayer.PlayerGui:GetDescendants()) do
	bind(descendant)
end

localPlayer.PlayerGui.DescendantAdded:Connect(bind)
layout()
panel:GetAttributeChangedSignal("ActiveTab"):Connect(function()
	if panel:GetAttribute("ActiveTab") == "Wearing" then
		task.defer(onActivated)
	end
end)