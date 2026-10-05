local createVector = vector.create
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ValleyPanels = require(script.Parent.Parent.Presentation.ValleyPanels)
local GearCatalog = require(script.Parent.GearCatalog)
local GearStoreClient = {}
GearStoreClient.__index = GearStoreClient
local v = utf8.char(57346)

local function motion(object, parent)
	local uIScale = Instance.new("UIScale")
	uIScale.Parent = parent
	local v2 = nil

	local function animate(scale)
		if v2 then
			v2:Cancel()
		end

		v2 = TweenService:Create(uIScale, TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Scale = scale
		})
		v2:Play()
	end

	for _, v3 in {
		{ parent.MouseEnter, 1.035 },
		{ parent.MouseLeave, 1 },
		{ parent.SelectionGained, 1.035 },
		{ parent.SelectionLost, 1 },
		{ parent.MouseButton1Down, 0.94 },
		{ parent.MouseButton1Up, 1 }
	} do
		local v4 = v3
		table.insert(object.connections, v3[1]:Connect(function()
			animate(parent.Active and v4[2] or 1)
		end))
	end
end

function GearStoreClient.new(store, kind)
	local object2 = setmetatable({
		store = store,
		cards = {},
		prices = {},
		connections = {},
		open = false,
		kind = kind,
		order = {}
	}, GearStoreClient)
	local root = ValleyPanels.make("Frame", store.root, "GearShop", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0
	})
	object2.root = root
	object2.heading = ValleyPanels.text(root, "Heading", "BUILD YOUR LOADOUT", 0, 0, 600, 32, 27, ValleyPanels.Paper)
	object2.subtitle = ValleyPanels.text(
		root,
		"Subtitle",
		"Equip 1 ability + 1 item. Abilities unlock forever; item packs give 3 charges.",
		0,
		38,
		900,
		26,
		15,
		ValleyPanels.Muted
	)
	object2.abilityHeading = ValleyPanels.text(
		root,
		"AbilitiesHeading",
		"ABILITIES  ·  PERMANENT UNLOCKS",
		0,
		78,
		600,
		24,
		16,
		ValleyPanels.Gold
	)
	object2.itemHeading = ValleyPanels.text(
		root,
		"ItemsHeading",
		"ITEMS  ·  3-CHARGE PACKS",
		0,
		78,
		600,
		24,
		16,
		ValleyPanels.Gold
	)
	object2.release = ValleyPanels.text(root, "Release", "COMING NEXT UPDATE", 0, 70, 900, 22, 12, ValleyPanels.Gold)

	for _, v3 in GearCatalog.Order do
		local v4 = GearCatalog.get(v3)

		if v4.Kind == "Ability" ~= (kind == "Ability") then
			continue
		end

		table.insert(object2.order, v3)
		local v5 = ValleyPanels.make("Frame", root, v3, {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0
		})
		ValleyPanels.corner(v5, 16)
		ValleyPanels.stroke(v5, v4.Accent, 0.72)
		local outline = v5.Outline
		local uIGradient = Instance.new("UIGradient")
		uIGradient.Color = ColorSequence.new(Color3.fromRGB(31, 48, 61), Color3.fromRGB(15, 27, 38))
		uIGradient.Rotation = 115
		uIGradient.Parent = v5
		local uIScale = Instance.new("UIScale")
		uIScale.Parent = v5
		table.insert(object2.connections, v5.MouseEnter:Connect(function()
			TweenService:Create(outline, TweenInfo.new(0.18), {
				Transparency = 0.2
			}):Play()
		end))
		local v7 = outline
		local v8 = v3
		table.insert(object2.connections, v5.MouseLeave:Connect(function()
			TweenService:Create(v7, TweenInfo.new(0.18), {
				Transparency = (object2.store.state.equippedGear == v8 or GearCatalog.equippedForRole(
					object2.store.state,
					GearCatalog.get(v8).UseRole
				) == v8) and 0.05 or 0.72
			}):Play()
		end))
		ValleyPanels.make("Frame", v5, "Accent", {
			BackgroundColor3 = v4.Accent,
			BorderSizePixel = 0,
			Size = UDim2.new(1, -32, 0, 2),
			Position = UDim2.fromOffset(16, 15)
		})
		local text = ValleyPanels.text(v5, "Role", v4.Role, 18, 23, 220, 18, 10, v4.Accent)
		text.Font = Enum.Font.GothamBold
		local v9 = ValleyPanels.make("ViewportFrame", v5, "Preview", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(18, 48),
			Size = UDim2.fromOffset(90, 88),
			Ambient = Color3.fromRGB(210, 218, 227),
			LightColor = Color3.new(1, 1, 1),
			LightDirection = createVector(-1, -1, -1)
		})
		local icon = ValleyPanels.make("ImageLabel", v5, "AbilityIcon", {
			BackgroundTransparency = 1,
			Position = v9.Position,
			Size = v9.Size,
			Image = v4.IconImage or "",
			ImageRectOffset = v4.IconRectOffset or Vector2.zero,
			ImageRectSize = v4.IconRectSize or Vector2.zero,
			Visible = v4.IconImage ~= nil,
			ScaleType = Enum.ScaleType.Fit
		})
		v9.Visible = not icon.Visible
		local child = script.Parent.Assets:FindFirstChild(v4.Preview)
		local previewData

		if child and not v4.IconImage then
			local worldModel = Instance.new("WorldModel")
			worldModel.Parent = v9
			local model = Instance.new("Model")
			model.Parent = worldModel
			local clone = child:Clone()
			clone.Parent = model

			for _, descendant in model:GetDescendants() do
				if descendant:IsA("LuaSourceContainer") or descendant:IsA("JointInstance") or descendant:IsA("WeldConstraint") then
					descendant:Destroy()
				elseif descendant:IsA("BasePart") then
					descendant.Anchored = true
					descendant.CanCollide = false
					descendant.CanTouch = false
					descendant.CanQuery = false
				end
			end

			local boundingBox, v12 = model:GetBoundingBox()
			model:PivotTo(model:GetPivot() - boundingBox.Position)
			local camera = Instance.new("Camera")
			camera.Parent = v9
			v9.CurrentCamera = camera
			camera.FieldOfView = 35
			local extent = math.max(v12.X, v12.Y, v12.Z, 0.5)
			camera.CFrame = CFrame.lookAt(Vector3.new(extent * 0.9, extent * 0.55, extent * 1.9), createVector(0, 0, 0))
			previewData = {
				camera = camera,
				extent = extent,
				phase = #object2.connections * 0.17
			}
		end

		local text2 = ValleyPanels.text(v5, "Title", v4.Name, 120, 57, 185, 50, 19, ValleyPanels.Paper)
		text2.Font = Enum.Font.GothamBold
		local text3 = ValleyPanels.text(v5, "Tag", v4.Tag, 120, 112, 185, 25, 10, v4.Accent)
		local text4 = ValleyPanels.text(v5, "Description", v4.Description, 18, 153, 275, 56, 13, ValleyPanels.Muted)
		local text5 = ValleyPanels.text(v5, "Stock", "0 CHARGES OWNED", 18, 222, 275, 20, 11, v4.Accent)
		local button = ValleyPanels.button(
			v5,
			"Coins",
			v4.Coins .. " COINS",
			18,
			244,
			130,
			42,
			Color3.fromRGB(81, 67, 39)
		)
		local button2 = ValleyPanels.button(
			v5,
			"Robux",
			"CHECKING PRICE",
			156,
			244,
			130,
			42,
			Color3.fromRGB(36, 64, 71)
		)
		local button3 = ValleyPanels.button(
			v5,
			"Gems",
			v4.Gems .. " GEMS",
			18,
			292,
			270,
			38,
			Color3.fromRGB(43, 70, 65)
		)
		local v12 = v4
		local v14 = v3
		table.insert(object2.connections, button3.Activated:Connect(function()
			if v12.Kind == "Ability" and button3.Active then
				store:notice(v12.Kind == "Ability" and "Unlocking ability…" or "Adding 3 charges…")
				script.Parent.Parent.Weapons.ArmoryEvent:FireServer("BuyGearGems", v14)
			end
		end))
		local button4 = ValleyPanels.button(v5, "Equip", "SELECT LOADOUT", 18, 298, 270, 32, Color3.fromRGB(31, 47, 59))
		button4.TextSize = 11
		object2.cards[v3] = {
			root = v5,
			border = outline,
			scale = uIScale,
			previewData = previewData,
			icon = icon,
			role = text,
			title = text2,
			tag = text3,
			desc = text4,
			stock = text5,
			coin = button,
			robux = button2,
			gem = button3,
			equip = button4,
			preview = v9
		}

		for _, v15 in {
			button,
			button2,
			button3,
			button4
		} do
			motion(object2, v15)
			v15.TextSize = 12
		end

		local v15 = v4
		local v17 = v3
		table.insert(object2.connections, button.Activated:Connect(function()
			if v15.Kind == "Ability" or not button.Active then
				return
			end

			store:notice(v15.Kind == "Ability" and "Unlocking ability…" or "Adding 3 charges…")
			script.Parent.Parent.Weapons.ArmoryEvent:FireServer("BuyGear", v17)
		end))
		local v19 = v3
		table.insert(object2.connections, button4.Activated:Connect(function()
			if button4.Active then
				script.Parent.Parent.Weapons.ArmoryEvent:FireServer("EquipGear", v19)
			end
		end))
		local v21 = v4
		table.insert(object2.connections, button2.Activated:Connect(function()
			if not button2.Active or store.player:GetAttribute("InMatch") == true then
				return
			end

			if not pcall(MarketplaceService.PromptProductPurchase, MarketplaceService, store.player, v21.ProductId) then
				store:notice("The purchase window could not open. Please try again.")
			end
		end))
	end

	if kind == "Ability" then
		local v3 = {
			Runner = 1,
			Catcher = 2
		}
		table.sort(object2.order, function(a, b)
			local v4 = GearCatalog.get(a)
			local v5 = GearCatalog.get(b)

			if v4.UseRole ~= v5.UseRole then
				return (v3[v4.UseRole] or 3) < (v3[v5.UseRole] or 3)
			end

			if v4.Gems == v5.Gems then
				return v4.Name < v5.Name
			end

			return v4.Gems > v5.Gems
		end)
	end

	object2.teamHeadings = {
		Runner = ValleyPanels.text(root, "RunnerHeading", "RUNNERS", 0, 0, 600, 24, 16, ValleyPanels.Gold),
		Catcher = ValleyPanels.text(root, "ChaserHeading", "CHASERS", 0, 0, 600, 24, 16, ValleyPanels.Gold)
	}
	return object2
end

function GearStoreClient:refresh()
	local state = self.store.state
	local open = self.open

	if open then
		if state.loaded == true then
			open = not state.pending and self.store.player:GetAttribute("InMatch") ~= true
		else
			open = false
		end
	end

	local salesEnabled = GearCatalog.SalesEnabled or RunService:IsStudio()
	self.release.Visible = not GearCatalog.SalesEnabled

	for k, card in self.cards do
		local v2 = GearCatalog.get(k)
		local v3 = not state.gear and 0 or state.gear[k] or 0
		local visible = v2.Kind == "Ability"
		local v5 = visible and state.abilities and state.abilities[k] == true and true or not visible and v3 > 0
		local v6 = (visible and GearCatalog.equippedForRole(state, v2.UseRole) or state.equippedGear) == k
		local v7 = visible and not v5 or not visible and v3 + GearCatalog.PackSize <= GearCatalog.MaxInventory
		local stock = card.stock
		local text

		if visible then
			text = v5 and "UNLOCKED  ·  REUSABLE ABILITY" or "PERMANENT UNLOCK  ·  NO CHARGES"
		else
			text = tostring(v3) .. " CHARGES OWNED  ·  +3 PER PACK"
		end

		stock.Text = text
		card.coin.Text = not state.loaded and "LOADING…" or not salesEnabled and "COMING SOON" or v2.Coins .. " COINS"
		card.coin.Visible = not visible
		card.coin.Active = not visible and open and salesEnabled and v7 and (state.coins or 0) >= v2.Coins
		card.gem.Text = v2.Gems .. " GEMS"
		card.gem.Visible = visible
		card.gem.Active = visible and open and salesEnabled and v7 and (state.gems or 0) >= v2.Gems
		local price = self.prices[k]
		local priceInRobux

		if type(price) == "table" then
			priceInRobux = price.PriceInRobux
		else
			priceInRobux = false
		end

		local v9

		if type(priceInRobux) == "number" and priceInRobux == priceInRobux then
			v9 = priceInRobux >= 0
		else
			v9 = false
		end

		local robux = card.robux
		local text2 = v9 and v .. " " .. tostring(priceInRobux) .. (price.IsForSale and "" or " · SOON")

		if not text2 then
			if type(price) == "table" then
				text2 = price.IsForSale == false and "ROBUX · SOON" or "PRICE UNAVAILABLE"
			else
				text2 = price == false and "UNAVAILABLE" or "CHECKING PRICE"
			end
		end

		robux.Text = text2
		local robux2 = card.robux
		local salesEnabled2 = open and GearCatalog.SalesEnabled

		if salesEnabled2 then
			if v7 then
				if game.GameId == 10764627709 then
					salesEnabled2 = v9 and price.IsForSale == true
				else
					salesEnabled2 = false
				end
			else
				salesEnabled2 = v7
			end
		end

		robux2.Active = salesEnabled2
		card.border.Transparency = v6 and 0.05 or 0.72
		card.equip.BackgroundColor3 = v6 and Color3.fromRGB(48, 83, 75) or Color3.fromRGB(31, 47, 59)
		local equip = card.equip
		local text3

		if v6 then
			text3 = visible and "ABILITY EQUIPPED  ✓" or "ITEM EQUIPPED  ✓"
		elseif v5 then
			text3 = visible and "EQUIP ABILITY" or "EQUIP ITEM"
		else
			text3 = visible and "UNLOCK TO EQUIP" or "NO CHARGES OWNED"
		end

		equip.Text = text3
		card.equip.Active = open and v5

		if visible and v5 then
			card.coin.Text = "OWNED"
			card.gem.Text = "OWNED"
			card.robux.Text = "OWNED"
		end

		for _, v12 in {
			card.coin,
			card.robux,
			card.gem,
			card.equip
		} do
			v12.AutoButtonColor = v12.Active
			v12.TextTransparency = v12.Active and 0 or 0.35
		end
	end
end

function GearStoreClient:setOpen(open)
	local open2 = self.open
	self.open = open

	if open and not open2 then
		for k, v2 in self.order do
			local card = self.cards[v2]
			card.scale.Scale = 0.96
			TweenService:Create(
				card.scale,
				TweenInfo.new(
					0.32,
					Enum.EasingStyle.Back,
					Enum.EasingDirection.Out,
					0,
					false,
					math.min(k - 1, 5) * 0.035
				),
				{
					Scale = 1
				}
			):Play()
			self.prices[v2] = nil
			local v3 = v2
			task.spawn(function()
				local success, productInfoAsync = pcall(
					MarketplaceService.GetProductInfoAsync,
					MarketplaceService,
					GearCatalog.get(v3).ProductId,
					Enum.InfoType.Product
				)

				if self.destroyed then
					return
				end

				self.prices[v3] = success and productInfoAsync or false
				self:refresh()
			end)
		end
	end

	self:refresh()
end

function GearStoreClient.layout(data, p, p2, p3)
	local visible = data.kind == "Ability"
	local v3

	if p2 then
		v3 = 1
	elseif visible and p >= 900 then
		v3 = 4
	elseif p >= 940 then
		v3 = 3
	else
		v3 = 2
	end

	local v4 = (p - 8 - 14 * (v3 - 1)) / v3
	local v5 = math.ceil(#data.order / v3) * 366 + 112
	data.heading.Text = visible and "CHOOSE YOUR ABILITIES" or "STOCK UP ON ITEMS"
	data.subtitle.Text = visible and "Permanent unlocks · Select 1 Runner and 1 Chaser Ability" or "Equip one item. Each pack adds 3 charges."
	data.abilityHeading.Visible = visible
	data.itemHeading.Visible = not visible
	data.abilityHeading.Size = UDim2.fromOffset(p - 8, 24)
	data.itemHeading.Position = UDim2.fromOffset(0, 78)
	data.itemHeading.Size = UDim2.fromOffset(p - 8, 24)
	data.root.Position = UDim2.fromOffset(0, p3)
	data.root.Size = UDim2.fromOffset(p, v5)
	data.heading.Size = UDim2.fromOffset(p - 8, 32)
	data.heading.TextSize = p2 and 23 or 27
	data.subtitle.Size = UDim2.fromOffset(p - 8, 36)
	data.subtitle.TextSize = p2 and 13 or 15

	for _, teamHeading in data.teamHeadings do
		teamHeading.Visible = false
	end

	local useRole = nil
	local total = 112
	local v6 = 0

	for k, v7 in data.order do
		local card = data.cards[v7]
		local v8 = GearCatalog.get(v7)
		local v9 = k - 1

		if visible then
			if v8.UseRole == useRole then
				v9 = v6
			else
				if useRole then
					total += math.ceil(v6 / v3) * 366 + 18
				end

				useRole = v8.UseRole
				local teamHeading = data.teamHeadings[useRole]
				teamHeading.Visible = true
				teamHeading.Position = UDim2.fromOffset(0, total)
				teamHeading.Size = UDim2.fromOffset(p - 8, 24)
				total += 36
				v9 = 0
			end

			v6 = v9 + 1
		end

		card.root.Position = UDim2.fromOffset(v9 % v3 * (v4 + 14), total + math.floor(v9 / v3) * 366)
		card.root.Size = UDim2.fromOffset(v4, 352)
		card.role.Size = UDim2.fromOffset(v4 - 36, 18)
		local v10 = visible and v3 == 4
		local v11 = v10 and 76 or 90
		local v12 = v10 and 104 or 120
		card.preview.Position = UDim2.fromOffset(v10 and 16 or 18, 48)
		card.preview.Size = UDim2.fromOffset(v11, v11)
		card.icon.Position = card.preview.Position
		card.icon.Size = card.preview.Size
		card.title.Position = UDim2.fromOffset(v12, 57)
		card.title.Size = UDim2.fromOffset(v4 - v12 - 18, 50)
		card.title.TextSize = v10 and 17 or 19
		card.tag.Position = UDim2.fromOffset(v12, 112)
		card.tag.Size = UDim2.fromOffset(v4 - v12 - 18, 25)
		card.desc.Size = UDim2.fromOffset(v4 - 36, 56)
		card.desc.TextSize = v10 and 12 or 13
		card.stock.Size = UDim2.fromOffset(v4 - 36, 20)
		local v13 = visible and { card.gem, card.robux } or { card.coin, card.robux }
		card.coin.Visible = not visible
		card.gem.Visible = visible
		local v14 = (v4 - 36 - (#v13 - 1) * 6) / #v13

		for k2, v15 in v13 do
			v15.Position = UDim2.fromOffset(18 + (k2 - 1) * (v14 + 6), 258)
			v15.Size = UDim2.fromOffset(v14, 38)
			v15.TextSize = 11
		end

		card.equip.Position = UDim2.fromOffset(18, 308)
		card.equip.Size = UDim2.fromOffset(v4 - 36, 30)
	end

	if visible then
		v5 = total + math.ceil(v6 / v3) * 366
		data.root.Size = UDim2.fromOffset(p, v5)
	end

	return p3 + v5 + 18
end

function GearStoreClient:step(p)
	if not self.open then
		return
	end

	self.elapsed = (self.elapsed or 0) + math.min(p, 0.1)

	for _, card in self.cards do
		local previewData = card.previewData

		if not previewData then
			continue
		end

		local v2 = self.elapsed * 0.28 + previewData.phase
		previewData.camera.CFrame = CFrame.lookAt(
			Vector3.new(
				math.sin(v2) * previewData.extent * 2,
				previewData.extent * (math.sin(self.elapsed * 1.6 + previewData.phase) * 0.06 + 0.45),
				math.cos(v2) * previewData.extent * 2
			),
			createVector(0, 0, 0)
		)
	end
end

function GearStoreClient:destroy()
	self.destroyed = true

	for _, connection in self.connections do
		connection:Disconnect()
	end
end

return GearStoreClient