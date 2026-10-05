local createVector = vector.create
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ShopConfig = require(script.Parent.ShopConfig)
local OfferRules = require(script.Parent.OfferRules)
local ValleyPanels = require(script.Parent.Parent.Presentation.ValleyPanels)
local StorefrontClient = {}
StorefrontClient.__index = StorefrontClient

local function comma(p)
	return tostring((math.floor(p))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function box(p, p2, p3, p4, p5)
	p.Position = UDim2.fromOffset(p2, p3)
	p.Size = UDim2.fromOffset(p4, p5)
end

function StorefrontClient.new(parent, p, catalog, object, instance)
	local object2 = setmetatable({
		canvas = parent,
		root = parent.Storefront,
		player = instance,
		state = {
			owned = {}
		},
		offers = {},
		connections = {},
		prices = {},
		binding = ShopConfig.binding(game.GameId),
		open = false,
		catalog = catalog,
		previews = {},
		sections = {}
	}, StorefrontClient)
	local root = object2.root
	root.Coins.Description.Text = "Stock up on supplies. Larger bundles give more coins per Robux."
	root.Gems.Description.Text = "Buy supplies and gem items. Larger bundles give more gems per Robux."

	for _, guiObject in root:GetDescendants() do
		if not guiObject:IsA("GuiObject") or (guiObject:IsA("GuiButton") or guiObject:IsA("ScrollingFrame")) then
			continue
		end

		guiObject.Active = false
		guiObject.Selectable = false
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function connect(activated, fn)
		table.insert(object2.connections, activated:Connect(fn))
	end

	local function animateButton(parent2)
		local shopPressScale = parent2:FindFirstChild("ShopPressScale") or Instance.new("UIScale")
		shopPressScale.Name = "ShopPressScale"
		shopPressScale.Parent = parent2
		local v = nil

		local function set(p3)
			if v then
				v:Cancel()
			end

			v = TweenService:Create(
				shopPressScale,
				TweenInfo.new(0.17, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				{
					Scale = parent2.Active and p3 or 1
				}
			)
			v:Play()
		end

		local mouseEnter = parent2.MouseEnter
		table.insert(object2.connections, mouseEnter:Connect(function()
			set(1.025)
		end))
		local mouseLeave = parent2.MouseLeave
		table.insert(object2.connections, mouseLeave:Connect(function()
			set(1)
		end))
		local selectionGained = parent2.SelectionGained
		table.insert(object2.connections, selectionGained:Connect(function()
			set(1.025)
		end))
		local selectionLost = parent2.SelectionLost
		table.insert(object2.connections, selectionLost:Connect(function()
			set(1)
		end))
		local mouseButton1Down = parent2.MouseButton1Down
		table.insert(object2.connections, mouseButton1Down:Connect(function()
			set(0.95)
		end))
		local mouseButton1Up = parent2.MouseButton1Up
		table.insert(object2.connections, mouseButton1Up:Connect(function()
			set(1)
		end))
	end

	local function offer(buy, p3, kind, pack)
		animateButton(buy)
		local v = {
			button = buy,
			key = p3,
			kind = kind,
			id = kind == "Pass" and object2.binding.PassIds[p3] or kind ~= "Product" and 0 or object2.binding.ProductIds[p3] or 0 or 0,
			pack = pack
		}
		table.insert(object2.offers, v)

		local function fn()
			object2:purchase(v)
		end

		connect(buy.Activated, fn) -- equivalent call inferred; original call site unknown
	end

	local function feature(data, p3, p4)
		local v = catalog.get(p3.SkinId)

		for _, v2 in {
			"Eyebrow",
			"Title",
			"Tagline",
			"Description",
			"Footnote"
		} do
			data[v2].Text = p3[v2] or ""
		end

		if p4 == "Gem" and v then
			data.Title.Text = v.Name
			data.Tagline.Text = v.Subtitle
			data.Description.Text = v.Description
		end

		offer(data.Buy, (p4 == "Gem" or p4 == "Reward") and p3.SkinId or p3.OfferKey, p4)

		for _, v2 in { "Equip", "Swing", "Hit" } do
			animateButton(data.Sounds[v2])
			data.Sounds[v2].Active = v ~= nil
			local v3 = v2

			local function fn()
				if v then
					object:Fire("KnifePreview", p3.SkinId, v3)
				end
			end

			connect(data.Sounds[v2].Activated, fn) -- equivalent call inferred; original call site unknown
		end

		local child = v and p.Models:FindFirstChild(v.Model)
		local blade = child and child:FindFirstChild("Blade")

		if blade then
			data.Sounds.Visible = true
			local worldModel = Instance.new("WorldModel")
			worldModel.Parent = data.Weapon
			local model = Instance.new("Model")
			model.Name = "ShopPreview"
			model.Parent = worldModel
			local clone = blade:Clone()

			for _, descendant in clone:GetDescendants() do
				if not (descendant:IsA("LuaSourceContainer") or descendant:IsA("JointInstance") or descendant:IsA("WeldConstraint")) then
					continue
				end

				descendant:Destroy()
			end

			clone.Anchored = true
			clone.CanCollide = false
			clone.CanTouch = false
			clone.CanQuery = false
			clone.Transparency = 0
			clone.CFrame = child:GetAttribute("PreviewRotation") or CFrame.Angles(
				-0.4363323129985824,
				-0.20943951023931956,
				-0.5585053606381855
			)
			clone.Parent = model
			model.PrimaryPart = clone
			local boundingBox, v2 = model:GetBoundingBox()
			model:PivotTo(model:GetPivot() - boundingBox.Position)
			local camera = Instance.new("Camera")
			camera.FieldOfView = 33
			camera.Parent = data.Weapon
			data.Weapon.CurrentCamera = camera
			local v3 = {
				camera = camera,
				extent = math.max(v2.X, v2.Y, v2.Z),
				rotation = 0,
				dragging = false
			}
			table.insert(object2.previews, v3)
			task.spawn(function()
				local v4 = false
				local v5 = pcall(function()
					local ContentProvider = game:GetService("ContentProvider")
					ContentProvider:PreloadAsync({ clone }, function(_, p5)
						if p5 ~= Enum.AssetFetchStatus.Success then
							v4 = true
						end
					end)
				end)

				if object2.destroyed then
					return
				end

				data.Loading.Text = "PREVIEW UNAVAILABLE"
				data.Loading.Visible = not v5 or v4
			end)
			local inputBegan = data.Weapon.InputBegan
			table.insert(object2.connections, inputBegan:Connect(function(p5)
				if p5.UserInputType == Enum.UserInputType.MouseButton1 then
					v3.dragging = true
					v3.lastX = p5.Position.X
				end
			end))
		else
			data.Loading.Text = p4 == "Gem" and "NEXT GEM KNIFE" or "PREVIEW UNAVAILABLE"
			data.Loading.Visible = true
			data.Sounds.Visible = false
		end
	end

	local questCard = ValleyPanels.make("Frame", root, "QuestProgress", {
		BackgroundColor3 = Color3.fromRGB(21, 38, 48),
		BorderSizePixel = 0,
		Visible = false
	})
	ValleyPanels.corner(questCard, 13)
	ValleyPanels.stroke(questCard, ValleyPanels.Gold, 0.5)
	local text = ValleyPanels.text(questCard, "Heading", "NEXT FREE KNIFE", 18, 10, 360, 20, 15, ValleyPanels.Gold)
	text.Font = Enum.Font.GothamBold
	text.TextXAlignment = Enum.TextXAlignment.Left
	local text2 = ValleyPanels.text(
		questCard,
		"KnifeName",
		"Loading quests...",
		18,
		32,
		400,
		27,
		19,
		ValleyPanels.Paper
	)
	text2.Font = Enum.Font.GothamBold
	text2.TextXAlignment = Enum.TextXAlignment.Left
	local text_2 = ValleyPanels.text(questCard, "Status", "0% complete", 18, 66, 360, 20, 14, ValleyPanels.Muted)
	text_2.TextXAlignment = Enum.TextXAlignment.Left
	local v2 = ValleyPanels.make("Frame", questCard, "Track", {
		BackgroundColor3 = Color3.fromRGB(55, 69, 77),
		BorderSizePixel = 0
	})
	ValleyPanels.corner(v2, 5)
	local v3 = ValleyPanels.make("Frame", v2, "Fill", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = ValleyPanels.Gold,
		BorderSizePixel = 0
	})
	ValleyPanels.corner(v3, 5)
	local button = ValleyPanels.button(
		questCard,
		"OpenQuests",
		"VIEW QUESTS  ›",
		0,
		0,
		150,
		43,
		Color3.fromRGB(77, 112, 94)
	)
	button.TextScaled = true
	animateButton(button)
	local activated = button.Activated
	table.insert(object2.connections, activated:Connect(function()
		instance:SetAttribute("QuestOpenRequestedAt", os.clock())
	end))
	object2.questCard = questCard
	object2.questRemote = game.ReplicatedStorage.ChickenOrHero.Quests:WaitForChild("QuestEvent")
	local onClientEvent = object2.questRemote.OnClientEvent
	table.insert(object2.connections, onClientEvent:Connect(function(p3, questState)
		if p3 ~= "State" or type(questState) ~= "table" then
			return
		end

		object2.questState = questState
		object2:refreshQuest()
	end))
	local clone = root.Featured:Clone()
	clone.Name = "GhostFeatured"
	clone.Visible = false
	clone.Parent = root
	feature(root.Featured, ShopConfig.Flagship, "Pass")
	feature(clone, ShopConfig.GhostFlagship, "Pass")

	for _, v4 in ShopConfig.AdditionalKnives or {} do
		local clone2 = root:FindFirstChild(v4.SkinId)

		if not clone2 then
			clone2 = root.Featured:Clone()
			clone2.Name = v4.SkinId
			clone2.Parent = root
			clone2.Weapon:ClearAllChildren()
			clone2.Timer.Text = ""
			clone2.Timer.Visible = false
		end

		clone2.Index.Text = "ROBUX EXCLUSIVE"
		clone2:SetAttribute("TitleTextSize", v4.TitleTextSize)
		feature(clone2, v4, "Pass")
	end

	root.Earnable.Visible = false

	for _, childName in { "BalloonDagger", "TopWinsDagger" } do
		local v4 = catalog.get(childName)
		local child = root:FindFirstChild(childName)

		if child then
			feature(child, {
				SkinId = childName,
				Eyebrow = v4.Collection,
				Title = v4.Name,
				Tagline = v4.Subtitle,
				Description = v4.Description,
				Footnote = "Earn once. Keep forever."
			}, "Reward")
		end
	end

	offer(root.Perks.DoubleXP.Buy, "DoubleXP", "Pass")
	offer(root.Perks.VIP.Buy, "VIP", "Pass")
	local v4 = {
		coins = 0,
		gems = 0
	}

	for _, pack in ShopConfig.Packs do
		local currency = pack.Currency
		v4[currency] += 1
		local pack2 = root[pack.Currency == "coins" and "Coins" or "Gems"].Packs["Pack" .. v4[pack.Currency]]
		pack2.Amount.Text = tostring((math.floor(pack.Amount))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub(
			"^,",
			""
		)
		pack2.Caption.Text = pack.Label
		local buy = pack2.Buy
		local key = pack.Key
		animateButton(buy)
		local v5 = {
			button = buy,
			key = key,
			kind = "Product",
			id = object2.binding.ProductIds[key] or 0 or 0,
			pack = pack
		}
		table.insert(object2.offers, v5)
		local activated2 = buy.Activated
		table.insert(object2.connections, activated2:Connect(function()
			object2:purchase(v5)
		end))
	end

	local inputChanged = UserInputService.InputChanged
	table.insert(object2.connections, inputChanged:Connect(function(p3)
		if not object2.open then
			return
		end

		for _, preview in object2.previews do
			if not (preview.dragging and p3.UserInputType == Enum.UserInputType.MouseMovement) then
				continue
			end

			preview.rotation += (p3.Position.X - preview.lastX) * 0.012
			preview.lastX = p3.Position.X
		end
	end))
	local inputEnded = UserInputService.InputEnded
	table.insert(object2.connections, inputEnded:Connect(function(p3)
		if p3.UserInputType == Enum.UserInputType.MouseButton1 then
			for _, preview in object2.previews do
				preview.dragging = false
			end
		end
	end))

	for _, v5 in { "HasVIP", "HasDoubleXP", "EconomyLoaded" } do
		local attributeChangedSignal = instance:GetAttributeChangedSignal(v5)
		table.insert(object2.connections, attributeChangedSignal:Connect(function()
			object2:refresh()
		end))
	end

	local promptGamePassPurchaseFinished = MarketplaceService.PromptGamePassPurchaseFinished
	table.insert(object2.connections, promptGamePassPurchaseFinished:Connect(function(p3, _, p4)
		if p3 == instance and p4 then
			object2:notice("Verifying your new perk…")
		end
	end))

	if object2.binding.PurchasesEnabled == false then
		root.Footer.Text = "TEST EXPERIENCE · Robux purchases open in the live game. Owned passes still apply."
	end

	local GearStoreClient = require(script.Parent.Parent.Gear.GearStoreClient)
	object2.gear = GearStoreClient.new(object2, "Ability")
	object2.abilityRoot = object2.root:Clone()
	object2.abilityRoot:ClearAllChildren()
	object2.abilityRoot.Name = "Abilities"
	object2.abilityRoot.Visible = false
	object2.abilityRoot.Parent = parent
	object2.gear.root.Parent = object2.abilityRoot
	local GearStoreClient2 = require(script.Parent.Parent.Gear.GearStoreClient)
	object2.items = GearStoreClient2.new(object2, "Item")
	object2.itemRoot = object2.abilityRoot:Clone()
	object2.itemRoot:ClearAllChildren()
	object2.itemRoot.Name = "Items"
	object2.itemRoot.Parent = parent
	object2.items.root.Parent = object2.itemRoot
	object2:refresh()
	return object2
end

function StorefrontClient:refreshQuest()
	local questCard = self.questCard

	if not questCard then
		return
	end

	local questState = self.questState
	local event = questState and questState.event

	if questState then
		if questState.mode == "Event" then
			questState = event and event.phase == "Active"
		else
			questState = false
		end
	end

	local v = nil

	if questState then
		for _, v3 in event.weapons or {} do
			if v3.id ~= event.activeWeapon then
				continue
			end

			v = v3
			break
		end
	end

	local visible = questCard.Visible
	questCard.Visible = questState and v ~= nil

	if visible ~= questCard.Visible and self.layoutWidth then
		self:layout(self.layoutWidth, self.layoutPortrait)
	end

	if not questCard.Visible then
		return
	end

	questCard.KnifeName.Text = v.name
	local count = #v.quests
	local total = 0
	local count2 = 0

	for _, quest in v.quests do
		local v2 = math.clamp(quest.progress / math.max(quest.target, 1), 0, 1)

		if quest.alternateTarget then
			v2 = math.max(v2, (math.clamp((quest.alternateProgress or 0) / quest.alternateTarget, 0, 1)))
		end

		total += v2

		if quest.complete then
			count2 += 1
		end
	end

	local v2 = not (count > 0) and 0 or total / count or 0
	questCard.Status.Text = string.format("%d%% COMPLETE  ·  %d/%d QUESTS", math.floor(v2 * 100 + 0.5), count2, count)
	questCard.Track.Fill.Size = UDim2.fromScale(v2, 1)
	questCard.OpenQuests.Text = v.claimable and "CLAIM KNIFE  ›" or "VIEW QUESTS  ›"
end

function StorefrontClient:notice(text)
	self.canvas.Notice.Text = text
	self.noticeUntil = os.clock() + 7
end

function StorefrontClient:eligible(data)
	if data.kind == "Reward" then
		return self.catalog.get(data.key) ~= nil
	end

	if data.kind == "Gem" then
		local v = self.catalog.get(data.key)
		local offer = v and v.Offer
		return v ~= nil and v.EquipReady ~= false and v.Available == true and offer ~= nil and offer.Currency == "gems" and type(offer.Price) == "number" and offer.Price > 0
	else
		if data.id <= 0 then
			return false
		end

		if data.kind == "Pass" then
			local pass = ShopConfig.Passes[data.key]

			if not (pass and pass.SkinId) then
				return pass ~= nil
			end

			local v = self.catalog.get(pass.SkinId)
			return v ~= nil and v.EquipReady ~= false
		else
			local productGrant = ShopConfig.ProductGrants[data.id]
			return productGrant ~= nil and productGrant.UniverseId == game.GameId and productGrant.Currency == data.pack.Currency and productGrant.Amount == data.pack.Amount
		end
	end
end

function StorefrontClient:owned(p2)
	if not (p2.kind ~= "Reward" and p2.kind ~= "Gem") then
		return self.state.owned[p2.key] == true
	end

	if p2.kind ~= "Pass" then
		return false
	end

	local pass = ShopConfig.Passes[p2.key]
	return p2.key == "VIP" and self.player:GetAttribute("HasVIP") == true or p2.key == "DoubleXP" and self.player:GetAttribute("HasDoubleXP") == true or pass and pass.SkinId and self.state.owned[pass.SkinId] == true
end

function StorefrontClient:refresh()
	if self.items then
		self.items:refresh()
	end

	if self.gear then
		self.gear:refresh()
	end

	local serverTimeNow = workspace:GetServerTimeNow()
	local visible = ShopConfig.GhostFlagship.StartsAt <= serverTimeNow
	self.root.Featured.Visible = not visible
	self.root.GhostFeatured.Visible = visible

	for _, v2 in { "Featured", "GhostFeatured", "Earnable" } do
		local flagship = v2 == "Featured" and ShopConfig.Flagship or v2 == "GhostFeatured" and ShopConfig.GhostFlagship or ShopConfig.Earnable
		local timer = self.root[v2]:FindFirstChild("Timer")

		if not timer then
			continue
		end

		timer.Text = OfferRules.countdown(flagship, serverTimeNow)
		timer.Visible = timer.Text ~= ""
	end

	for _, offer in self.offers do
		local eligible = self:eligible(offer)
		local owned = self:owned(offer)

		if offer.kind == "Reward" then
			local v2 = self.state.equipped == offer.key
			offer.button.Text = not self.state.loaded and "LOADING COLLECTION…" or v2 and "EQUIPPED  ✓" or owned and "OWNED · EQUIP" or offer.key == "BalloonDagger" and "GET IT FREE · INVITE A FRIEND" or "REACH #1 GLOBAL WINS"
			local button = offer.button
			button.Active = self.state.loaded == true and not self.state.pending and not v2 and (owned or offer.key == "BalloonDagger")
		elseif offer.kind == "Gem" then
			local v2 = self.catalog.get(offer.key)
			local v3 = self.state.equipped == offer.key
			local status = OfferRules.status(v2 and v2.Offer, serverTimeNow)
			local v4 = status == "Active"
			local button = offer.button
			local text

			if eligible then
				if self.state.loaded then
					if v3 then
						text = "EQUIPPED  ✓"
					elseif owned then
						text = "OWNED · EQUIP"
					elseif v4 then
						text = "◆  " .. tostring((math.floor(v2.Offer.Price))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub(
							"^,",
							""
						) .. " GEMS"
					else
						text = status == "Expired" and "OFFER ENDED" or "NOT AVAILABLE YET"
					end
				else
					text = "LOADING COLLECTION…"
				end
			else
				text = "COMING SOON"
			end

			button.Text = text
			local button2 = offer.button

			if eligible then
				if self.state.loaded == true then
					eligible = not v3 and not self.state.pending and (owned or v4)
				else
					eligible = false
				end
			end

			button2.Active = eligible
		else
			local price = self.prices[offer.kind .. offer.id]
			local flagship

			if offer.kind == "Pass" then
				flagship = offer.key == ShopConfig.Flagship.OfferKey and ShopConfig.Flagship

				if not flagship then
					if offer.key == ShopConfig.GhostFlagship.OfferKey then
						flagship = ShopConfig.GhostFlagship
					else
						flagship = false
					end
				end
			else
				flagship = false
			end

			local v2 = not flagship or OfferRules.active(flagship, serverTimeNow)
			local v3

			if type(price) == "table" and type(price.PriceInRobux) == "number" and price.PriceInRobux == price.PriceInRobux then
				v3 = price.PriceInRobux >= 0
			else
				v3 = false
			end

			local button = offer.button
			local text

			if owned then
				text = "OWNED  ✓"
			elseif v2 then
				if not eligible then
					text = "COMING SOON"
				elseif price == false then
					text = "PRICE UNAVAILABLE"
				elseif type(price) ~= "table" then
					text = "CHECKING PRICE…"
				elseif not price.IsForSale then
					text = "NOT ON SALE"
				elseif not v3 then
					text = "PRICE UNAVAILABLE"
				else
					text = utf8.char(57346) .. " " .. tostring((math.floor(price.PriceInRobux))):reverse():gsub(
						"(%d%d%d)",
						"%1,"
					):reverse():gsub(
						"^,",
						""
					)
				end
			else
				text = OfferRules.status(flagship, serverTimeNow) == "Expired" and "OFFER ENDED" or "NOT AVAILABLE YET"
			end

			button.Text = text
			local button2 = offer.button
			local active

			if self.binding.PurchasesEnabled == false then
				active = false
			else
				active = eligible and not owned

				if active then
					if v3 then
						if price.IsForSale == true and self.state.loaded == true then
							active = not self.state.pending

							if active then
								if self.player:GetAttribute("InMatch") == true then
									active = false
								else
									active = v2
								end
							end
						else
							active = false
						end
					else
						active = v3
					end
				end
			end

			button2.Active = active
		end

		offer.button.AutoButtonColor = offer.button.Active
		offer.button.TextTransparency = offer.button.Active and 0 or 0.3
	end
end

function StorefrontClient:fetchPrices()
	for _, offer in self.offers do
		local v = offer.kind .. offer.id

		if offer.kind == "Gem" or offer.kind == "Reward" or not self:eligible(offer) or self:owned(offer) then
			continue
		end

		if self.prices[v] ~= nil then
			continue
		end

		self.prices[v] = "loading"
		local v2 = offer
		local v3 = v
		task.spawn(function()
			local success, productInfoAsync = pcall(
				MarketplaceService.GetProductInfoAsync,
				MarketplaceService,
				v2.id,
				v2.kind == "Pass" and Enum.InfoType.GamePass or Enum.InfoType.Product
			)

			if self.destroyed then
				return
			end

			self.prices[v3] = success and productInfoAsync or false
			self:refresh()
		end)
	end

	self:refresh()
end

function StorefrontClient:purchase(data)
	if not (self.open and data.button.Active and self:eligible(data)) then
		return
	end

	if self.player:GetAttribute("InMatch") == true or not self.state.loaded then
		return
	end

	if data.kind == "Reward" then
		if self:owned(data) then
			script.Parent.ArmoryEvent:FireServer("Equip", data.key)
		elseif data.key == "BalloonDagger" then
			script.Parent.ArmoryNavigation:Fire("Balloon")
		end
	elseif data.kind == "Gem" then
		if self:owned(data) or self.catalog.canBuy(data.key, workspace:GetServerTimeNow()) then
			if not self:owned(data) and self.state.gems < self.catalog.get(data.key).Offer.Price then
				self:notice("Collect more gems during crossings to claim this knife.")
				return
			end

			script.Parent.ArmoryEvent:FireServer(self:owned(data) and "Equip" or "Buy", data.key)
			self:notice(self:owned(data) and "Equipping your knife…" or "Adding this knife to your collection…")
		else
			self:refresh()
			self:notice("This offer has ended or is not available yet.")
		end
	else
		if self.binding.PurchasesEnabled == false then
			self:notice("Robux purchases are available in the live game.")
			return
		end

		if self:owned(data) then
			return
		end

		if data.kind == "Pass" and (data.key == ShopConfig.Flagship.OfferKey or data.key == ShopConfig.GhostFlagship.OfferKey) and not OfferRules.active(
			data.key == ShopConfig.Flagship.OfferKey and ShopConfig.Flagship or ShopConfig.GhostFlagship,
			workspace:GetServerTimeNow()
		) then
			self:refresh()
		elseif not pcall(function()
			if data.kind == "Pass" then
				MarketplaceService:PromptGamePassPurchase(self.player, data.id)
			else
				MarketplaceService:PromptProductPurchase(self.player, data.id)
			end
		end) then
			self:notice("The purchase window could not open. Please try again.")
		end
	end
end

function StorefrontClient:update(state)
	self.state = state
	self:refresh()

	if state.message and self.open then
		self:notice(state.message)
	end
end

function StorefrontClient:setOpen(p, p2)
	self.section = p2 or self.section or "Shop"
	local open = self.open
	self.open = p

	if self.gear then
		self.gear:setOpen(p and self.section == "Abilities")
	end

	self.items:setOpen(p and self.section == "Items")
	self.itemRoot.Visible = p and self.section == "Items"
	self.root.Visible = p and self.section == "Shop"

	if p and self.section == "Shop" and (not open or self.previousSection ~= "Shop") then
		self.questRemote:FireServer("Get")
	end

	self.previousSection = self.section
	self.abilityRoot.Visible = p and self.section == "Abilities"
	self.canvas.Notice.Visible = p

	if p and not open then
		self.prices = {}
		self:fetchPrices()
	end

	if not p then
		for _, preview in self.previews do
			preview.dragging = false
		end

		self.canvas.ScrollHint.Visible = false
	end
end

function StorefrontClient.focus(data, p)
	local v = (data.sections[p] or 0) * (data.root.AbsoluteSize.X / (data.layoutWidth or data.root.AbsoluteSize.X))
	data.root.CanvasPosition = Vector2.new(
		0,
		(math.clamp(v, 0, (math.max(0, data.root.AbsoluteCanvasSize.Y - data.root.AbsoluteWindowSize.Y))))
	)
end

function StorefrontClient:layout(layoutWidth, layoutPortrait)
	self.layoutWidth = layoutWidth
	self.layoutPortrait = layoutPortrait
	local root = self.root
	root.Coins.Description.Text = "Stock up on supplies. Larger bundles give more coins per Robux."
	root.Gems.Description.Text = "Buy supplies and gem items. Larger bundles give more gems per Robux."
	local promotionActive = ShopConfig.promotionActive(os.time())
	root.Promotion.Visible = promotionActive
	root.Promotion.Text = ShopConfig.Promotion.Text
	box(root.Promotion, 0, 0, layoutWidth, 28) -- equivalent call inferred; original call site unknown
	local v = promotionActive and 38 or 0

	local function feature(instance)
		box(instance, 1, v, layoutWidth - 9, layoutPortrait and 578 or 338) -- equivalent call inferred; original call site unknown
		local v5 = layoutWidth - 9
		local v6 = layoutPortrait and 24 or math.floor(v5 * 0.51)
		local v7 = layoutPortrait and v5 - 48 or v5 - v6 - 28
		box(instance.Index, 24, 19, 230, 22) -- equivalent call inferred; original call site unknown
		box(instance.Timer, v5 - 244, 19, 220, 22) -- equivalent call inferred; original call site unknown
		box(instance.Pitch, 24, 55, layoutPortrait and v5 - 48 or v6 - 52, layoutPortrait and 180 or 225) -- equivalent call inferred; original call site unknown
		box(instance.Weapon, 10, 35, layoutPortrait and v5 - 20 or v6 - 15, layoutPortrait and 190 or 256) -- equivalent call inferred; original call site unknown
		box(instance.Loading, 24, layoutPortrait and 132 or 151, layoutPortrait and v5 - 48 or v6 - 52, 30) -- equivalent call inferred; original call site unknown
		local v15 = layoutPortrait and 240 or 27
		box(instance.Eyebrow, v6, v15, v7, 20) -- equivalent call inferred; original call site unknown
		box(instance.Title, v6, v15 + 27, v7, 58) -- equivalent call inferred; original call site unknown
		instance.Title.TextSize = instance:GetAttribute("TitleTextSize") or layoutPortrait and 40 or 46
		box(instance.Tagline, v6, v15 + 86, v7, 29) -- equivalent call inferred; original call site unknown
		box(instance.Description, v6, v15 + 126, v7, 50) -- equivalent call inferred; original call site unknown
		box(instance.Buy, v6, v15 + 181, v7, 47) -- equivalent call inferred; original call site unknown
		box(instance.Footnote, v6, v15 + 236, v7, 34) -- equivalent call inferred; original call site unknown
		box(instance.Sounds, 24, layoutPortrait and 530 or 290, layoutPortrait and v5 - 48 or v6 - 52, 34) -- equivalent call inferred; original call site unknown
		instance.Hint.Visible = false
		instance.Sounds.Label.Visible = not layoutPortrait
		local v23 = layoutPortrait and 0 or 100
		local v24 = ((layoutPortrait and v5 - 48 or v6 - 52) - v23 - 12) / 3
		box(instance.Sounds.Label, 0, 0, 96, 34) -- equivalent call inferred; original call site unknown

		for k, v25 in { "Equip", "Swing", "Hit" } do
			box(instance.Sounds[v25], v23 + (k - 1) * (v24 + 6), 0, v24, 34) -- equivalent call inferred; original call site unknown
			instance.Sounds[v25].TextSize = 14
		end

		v += instance.Size.Y.Offset + 30
	end

	self.sections.Gear = v

	if self.gear then
		self.abilityRoot.Position = self.root.Position
		self.abilityRoot.Size = self.root.Size
		self.abilityRoot.CanvasSize = UDim2.fromOffset(0, self.gear:layout(layoutWidth, layoutPortrait, 0) + 20)
	end

	self.itemRoot.Position = self.root.Position
	self.itemRoot.Size = self.root.Size
	self.itemRoot.CanvasSize = UDim2.fromOffset(0, self.items:layout(layoutWidth, layoutPortrait, 0) + 20)
	self.sections.Featured = v
	local v2 = v
	feature(root.Featured)
	local v3 = v
	v = v2
	feature(root.GhostFeatured)
	v = v3
	local questProgress = root.QuestProgress

	if questProgress.Visible then
		local v4 = v
		local v5 = layoutWidth - 9
		questProgress.Position = UDim2.fromOffset(1, v4)
		questProgress.Size = UDim2.fromOffset(v5, layoutPortrait and 184 or 112)
		local v6 = layoutWidth - 9
		box(questProgress.Heading, 18, 10, layoutPortrait and v6 - 36 or v6 - 206, 20) -- equivalent call inferred; original call site unknown
		box(questProgress.KnifeName, 18, 32, layoutPortrait and v6 - 36 or v6 - 206, 27) -- equivalent call inferred; original call site unknown
		box(questProgress.Status, 18, layoutPortrait and 69 or 66, layoutPortrait and v6 - 36 or v6 - 206, 20) -- equivalent call inferred; original call site unknown
		box(questProgress.Track, 18, layoutPortrait and 99 or 93, layoutPortrait and v6 - 36 or v6 - 206, 8) -- equivalent call inferred; original call site unknown
		local openQuests = questProgress.OpenQuests
		local v11 = layoutPortrait and 18 or v6 - 179
		local v12 = layoutPortrait and v6 - 36 or 160
		openQuests.Position = UDim2.fromOffset(v11, layoutPortrait and 125 or 34)
		openQuests.Size = UDim2.fromOffset(v12, layoutPortrait and 43 or 44)
		v += questProgress.Size.Y.Offset + 20
	end

	for _, v4 in ShopConfig.AdditionalKnives or {} do
		local child = root:FindFirstChild(v4.SkinId)

		if not child then
			continue
		end

		self.sections[v4.SkinId] = v
		feature(child)
	end

	self.sections.Earnable = v

	for _, childName in { "BalloonDagger", "TopWinsDagger" } do
		if not root:FindFirstChild(childName) then
			continue
		end

		self.sections[childName] = v
		feature(root[childName])
	end

	box(root.PerksHeading, 0, v, layoutWidth, 24) -- equivalent call inferred; original call site unknown
	v += 36
	self.sections.VIP = v
	local v5 = layoutPortrait and 277 or 260
	box(root.Perks, 0, v, layoutWidth - 8, v5) -- equivalent call inferred; original call site unknown
	local v8 = (layoutWidth - 8 - 16) / 2

	for k, v9 in { "DoubleXP", "VIP" } do
		local perk = root.Perks[v9]
		box(perk, (k - 1) * (v8 + 16), 0, v8, v5) -- equivalent call inferred; original call site unknown
		box(perk.Index, 20, 17, v8 - 40, 19) -- equivalent call inferred; original call site unknown
		perk.Index.TextSize = layoutPortrait and 10 or 12
		box(perk.Title, 20, 45, v8 - 40, 53) -- equivalent call inferred; original call site unknown
		local description = perk.Description
		local v13 = v8 - 40
		description.Position = UDim2.fromOffset(20, 105)
		description.Size = UDim2.fromOffset(v13, layoutPortrait and 88 or 76)
		perk.Description.TextSize = layoutPortrait and 16 or 17
		box(perk.Buy, 20, v5 - 65, v8 - 40, 44) -- equivalent call inferred; original call site unknown
	end

	v += v5 + 10
	local stacking = root.Stacking
	local v9 = v
	local v10 = layoutWidth - 16
	stacking.Position = UDim2.fromOffset(4, v9)
	stacking.Size = UDim2.fromOffset(v10, layoutPortrait and 42 or 26)
	v += layoutPortrait and 69 or 56

	for _, v11 in { "Coins", "Gems" } do
		local v12 = root[v11]
		local v13 = layoutPortrait and 2 or 3
		local v14 = 6 / v13
		local v15 = layoutPortrait and 175 or 180
		local v16 = layoutWidth - 8
		local v17 = (v16 - 16 * (v13 - 1)) / v13
		local v18 = layoutPortrait and 88 or 70
		local v19 = v18 + v14 * v15 + (v14 - 1) * 16
		box(v12, 0, v, v16, v19) -- equivalent call inferred; original call site unknown
		box(v12.Heading, 0, 0, v16, 32) -- equivalent call inferred; original call site unknown
		local description = v12.Description
		description.Position = UDim2.fromOffset(0, 38)
		description.Size = UDim2.fromOffset(v16, layoutPortrait and 43 or 26)
		box(v12.Packs, 0, v18, v16, v19 - v18) -- equivalent call inferred; original call site unknown

		for i = 1, 6 do
			local pack = v12.Packs["Pack" .. i]
			box(pack, (i - 1) % v13 * (v17 + 16), math.floor((i - 1) / v13) * (v15 + 16), v17, v15) -- equivalent call inferred; original call site unknown
			box(pack.Art, 0, 9, v17, 43) -- equivalent call inferred; original call site unknown
			box(pack.Amount, 0, 54, v17, 39) -- equivalent call inferred; original call site unknown
			box(pack.Caption, 8, 97, v17 - 16, 18) -- equivalent call inferred; original call site unknown
			box(pack.Buy, 16, v15 - 53, v17 - 32, 38) -- equivalent call inferred; original call site unknown
			pack.Buy.TextSize = 15
		end

		v += v19 + 38
	end

	box(root.Footer, 0, v, layoutWidth, 32) -- equivalent call inferred; original call site unknown
	root.CanvasSize = UDim2.fromOffset(0, v + 40)
end

function StorefrontClient:step(p)
	if not self.open then
		return
	end

	if self.gear then
		self.gear:step(p)
	end

	self.items:step(p)
	local abilityRoot = self.section == "Abilities" and self.abilityRoot or self.section == "Items" and self.itemRoot or self.root
	local v = abilityRoot.AbsoluteCanvasSize.Y - abilityRoot.AbsoluteWindowSize.Y - abilityRoot.CanvasPosition.Y
	local scrollHint = self.canvas.ScrollHint
	scrollHint.Visible = v > 12 and self.canvas.Notice.Text == ""
	self.canvas.ScrollHint.Text = UserInputService.TouchEnabled and "SWIPE UP · MORE IN STORE  ↓" or "SCROLL FOR MORE  ↓"
	self.timerElapsed = (self.timerElapsed or 0) + p

	if self.timerElapsed >= 0.2 then
		self.timerElapsed = 0
		self:refresh()
	end

	for _, preview in self.previews do
		if not preview.dragging then
			preview.rotation += math.min(p, 0.1) * 0.15
		end

		local v3 = preview.extent * 2
		preview.camera.CFrame = CFrame.lookAt(
			Vector3.new(math.sin(preview.rotation) * v3, 0.1 * preview.extent, math.cos(preview.rotation) * v3),
			createVector(0, 0, 0)
		)
	end

	if self.noticeUntil and os.clock() > self.noticeUntil then
		self.canvas.Notice.Text = ""
		self.noticeUntil = nil
	end
end

function StorefrontClient:destroy()
	self.destroyed = true

	if self.items then
		self.items:destroy()
	end

	if self.gear then
		self.gear:destroy()
	end

	for _, connection in self.connections do
		connection:Disconnect()
	end
end

return StorefrontClient