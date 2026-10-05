local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
game:GetService("TweenService")
local legacyControllers = ReplicatedStorage.client.legacyControllers
local _ = ReplicatedStorage.events
local _ = Players.LocalPlayer
local packages = ReplicatedStorage.packages
local _ = ReplicatedStorage.resources
local shared = ReplicatedStorage.shared
local modules = shared.modules
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local mouse = localPlayer:GetMouse()
local Monetization = require(shared.Monetization)
local Trove = require(packages.Trove)
local Timer = require(packages.Timer)
local Net = require(packages.Net)
local Signal = require(packages.Signal)
require(packages.Hovering)
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local GiftController = require(legacyControllers.Shop.GiftController)
local NotificationController = require(legacyControllers.NotificationController)
local BundleController = require(legacyControllers.Shop.BundleController)
local InputController = require(legacyControllers.InputController)
local WorldController = require(legacyControllers.WorldController)
local CurrencyController = require(legacyControllers.CurrencyController)
local GeneralUtils = require(shared.utils.GeneralUtils)
local assets = require(shared.utils.assets)
local SkinCrates = require(modules.SkinCrates)
local RodSkins = require(modules.RodSkins)
local ViewportModule = require(ReplicatedStorage.client.modules.ViewportModule)
local remoteEvent = Net:RemoteEvent("ToggleSkinCrates")
local remoteFunction = Net:RemoteFunction("SkinCrates/RequestSpin")
local remoteFunction2 = Net:RemoteFunction("SkinCrates/Purchase")
local skinCrate = playerGui:WaitForChild("SkinCrate")
local crates = skinCrate:WaitForChild("Crates")
local close = crates:WaitForChild("Close")
local list = crates:WaitForChild("List")
local floating = skinCrate:WaitForChild("Floating")
local spin = skinCrate:WaitForChild("Spin")
local list2 = spin:WaitForChild("ListBackground"):WaitForChild("List")
local uIListLayout = list2:WaitForChild("UIListLayout")
local buttons = spin:WaitForChild("Buttons")
local spin2 = buttons:WaitForChild("Spin")
local close2 = buttons:WaitForChild("Close")
local title = spin:WaitForChild("Header"):WaitForChild("Title")
local v = false
local v2 = Trove.new()
local renderSteppedConnection = nil
local v3 = nil
local v4 = Signal.new()
local SkinCrateController = {
	closeConnection = nil
}

local function formatPercentage(p)
	local v5

	if p < 1 then
		local v6 = string.format("%.10f", p):sub(3)
		local count = 0

		for i = 1, #v6 do
			if v6:sub(i, i) ~= "0" then
				break
			end

			count += 1
		end

		v5 = count + 2
	else
		v5 = 2
	end

	local v6 = 10 ^ v5
	local v7 = math.floor(p * v6) / v6
	return string.format("%." .. v5 .. "f%%", v7)
end

local function FormatNumber(p: number)
	return (tostring(p):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""))
end

function SkinCrateController:ShowFloating(p: string, p2)
	v3 = p2
	SkinCrateController:BuildRodSlot(p, floating)

	if not renderSteppedConnection then
		renderSteppedConnection = RunService.RenderStepped:Connect(function()
			local X = skinCrate.AbsoluteSize.X
			local Y = skinCrate.AbsoluteSize.Y
			local v5 = mouse.X / X
			local v6 = mouse.Y / Y
			floating.Position = UDim2.fromScale(v5 + 0.01, v6)
		end)
	end

	floating.Visible = true
end

function SkinCrateController:HideFloating(p)
	if v3 ~= p then
		return
	end

	floating.Visible = false

	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end
end

function SkinCrateController:Spin(p: string, p2: string)
	local v5 = SkinCrates.List[p2]
	local skin = RodSkins.Skins[p]

	if v == true then
		return
	end

	v = true
	v2:Clean()
	list2.Position = UDim2.fromScale(0, 0.5)
	buttons.Visible = false
	title.Text = v5.DisplayText or p2
	uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	local total = 0

	for i = 1, #v5.List do
		total += v5.List[i].Weight * 100000
	end

	local random = Random.new()
	local v6 = nil

	for i = 1, 101 do
		if i == 95 then
			v6 = SkinCrateController:BuildRodSlot(p)
			v6.LayoutOrder = 95
			v6.Name = 95
			v6.Parent = list2
			v2:Add(v6)
		else
			local integer = random:NextInteger(1, total)
			local total2 = 0

			for i2 = 1, #v5.List do
				local v7 = v5.List[i2]
				total2 += v7.Weight * 100000

				if not (integer <= total2) then
					continue
				end

				local rodSlot = SkinCrateController:BuildRodSlot(v7.Value)
				rodSlot.LayoutOrder = i
				rodSlot.Name = i
				rodSlot.Parent = list2
				v2:Add(rodSlot)
				break
			end
		end
	end

	spin.Visible = true
	local v7 = (v6.AbsolutePosition.X - list2.AbsolutePosition.X - list2.AbsoluteSize.X / 2 + v6.AbsoluteSize.X / 2) / list2.AbsoluteSize.X
	local uDim = UDim2.fromScale(-v7, 0.5)
	local wheelSound = skinCrate:WaitForChild("WheelSound")
	local success = skinCrate:WaitForChild("Success")
	wheelSound:Play()
	local tweenInfo = TweenInfo.new(9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local fastTween = GeneralUtils.fastTween(list2, tweenInfo, {
		Position = uDim
	}, true)
	fastTween:Play()
	fastTween.Completed:Once(function(_)
		NotificationController:Notify(
			`You have unlocked skin <font color="#{RodSkins.Rarities[RodSkins.Skins[p].Rarity].Color:ToHex()}">{p}</font> [for {skin.TargetRod}]`,
			10
		)
		success:Play()
		v = false
		spin.Visible = false
		buttons.Visible = true
	end)
end

function SkinCrateController:BuildRodSlot(name: string, clone)
	if clone == nil or not clone then
		clone = script:WaitForChild("SkinTemplate"):Clone()
	end

	clone.Name = name
	local skin = RodSkins.Skins[name]
	local rarity = RodSkins.Rarities[skin.Rarity]
	local title = clone:WaitForChild("Title")
	title.Text = skin.DisplayText or name
	local icon = clone:WaitForChild("Icon")
	icon.Image = not skin.Icon and "" or skin.Icon or ""
	local stroke = clone:WaitForChild("Stroke")
	stroke.Color = rarity.Color
	local uIGradient = clone:WaitForChild("Gradient"):WaitForChild("UIGradient")
	uIGradient.Color = rarity.ColorSequence
	local corner = clone:WaitForChild("Corner")
	corner.ImageColor3 = rarity.Color

	if skin.Icon then
		return clone
	end

	local camera = Instance.new("Camera")
	camera.Parent = clone:WaitForChild("ViewportFrame")
	local clone2 = assets.getAsync("skin", name):WaitForChild("Skin"):Clone()
	clone2.Parent = clone:WaitForChild("ViewportFrame")
	local viewportFrame = clone:WaitForChild("ViewportFrame")
	viewportFrame.CurrentCamera = camera
	local v5 = ViewportModule.new(clone:WaitForChild("ViewportFrame"), camera)
	local boundingBox, _ = clone2:GetBoundingBox()
	v5:SetModel(clone2)
	local cframe = CFrame.fromEulerAnglesYXZ(0, 0, 0.4363323129985824)
	local fitDistance = v5:GetFitDistance(boundingBox.Position)
	camera.CFrame = CFrame.new(boundingBox.Position) * cframe * CFrame.new(0, 0, fitDistance * 0.5)
	return clone
end

function SkinCrateController:HideSpin()
	if v == true then
		return
	end

	spin.Visible = false
	v2:Clean()
end

local activatedConnection = nil

function SkinCrateController:SetupSpin(p: string, flag: boolean?)
	if activatedConnection then
		activatedConnection:Disconnect()
		activatedConnection = nil
	end

	local v5 = SkinCrates.List[p]

	if not (v5 and v ~= true) then
		return
	end

	v2:Clean()
	spin2.Visible = flag ~= true

	if flag == true then
		if crates.Visible == true then
			crates.Visible = false
		end

		activatedConnection = close2.Activated:Connect(function()
			crates.Visible = true

			if activatedConnection then
				activatedConnection:Disconnect()
				activatedConnection = nil
			end
		end)
	end

	list2.Position = UDim2.fromScale(0, 0.5)
	title.Text = (v5.DisplayText or p) .. (flag == true and " Odds" or "")
	uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	local total = 0

	for i = 1, #v5.List do
		total += v5.List[i].Weight * 100000
	end

	for i = 1, #v5.List do
		local v6 = v5.List[i]
		local v7 = v6.Weight * 100000 / total * 100
		local rodSlot = self:BuildRodSlot(v6.Value)
		rodSlot.Size = UDim2.fromScale(math.min(rodSlot.Size.X.Scale, (1 - #v5.List * 0.01) / #v5.List), 0.7)
		rodSlot.Name = i
		local percentage = rodSlot:WaitForChild("Percentage")
		percentage.Text = formatPercentage(v7)
		rodSlot.Parent = list2
		v2:Add(rodSlot)
	end

	spin.Visible = true
end

function SkinCrateController:UpdatePrice(childName: string, p: number, p2: string)
	local child = list:FindFirstChild(childName)

	if not child then
		return
	end

	local buy = child:WaitForChild("Preview"):WaitForChild("Buttons"):WaitForChild("Buy")
	buy.Text = `{p2}{tostring(p):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")}`
end

function SkinCrateController:BuildList()
	local v5 = {
		[5] = script:WaitForChild("CrateTemplate5Slots"),
		[7] = script:WaitForChild("CrateTemplate7Slots"),
		[8] = script:WaitForChild("CrateTemplate7Slots"),
		[10] = script:WaitForChild("CrateTemplate10Slots")
	}
	local tracker_locationsdiscovered = legacyLocalPlayerData.fetch():WaitForChild("Stats"):WaitForChild("tracker_locationsdiscovered")
	local currentWorldIndex = WorldController:GetCurrentWorldIndex()

	for _, name2 in SkinCrates.Banner do
		local v7 = SkinCrates.List[name2]

		if not table.find(v7.Worlds, currentWorldIndex) then
			continue
		end

		local v8 = {}

		for i = 1, #v7.List do
			table.insert(v8, v7.List[i].Value)
		end

		local layoutOrder = v7.LayoutOrder or 1
		local clone = (v5[#v7.List] or v5[7]):Clone()
		clone.Parent = list
		clone.Name = name2
		clone.LayoutOrder = layoutOrder
		local preview = clone:WaitForChild("Preview")
		local header = preview:WaitForChild("Header")
		local new = header:WaitForChild("New")
		local title2 = header:WaitForChild("Title")
		local rewards = preview:WaitForChild("Rewards")
		local icon = rewards:WaitForChild("Icon")
		rewards:WaitForChild("Corner")
		local glow = rewards:WaitForChild("Glow")
		local stroke = preview:WaitForChild("Stroke")
		local corner = preview:WaitForChild("Corner")
		local buy = preview:WaitForChild("Buttons"):WaitForChild("Buy")
		local gift = preview:WaitForChild("Buttons"):WaitForChild("Gift")
		local previewButton = clone:WaitForChild("PreviewButton")
		local drops = rewards:WaitForChild("Drops")
		new.Visible = v7.New == true
		title2.Text = v7.DisplayText or v7.CrateName
		icon.Image = v7.Icon or ""
		glow.ImageColor3 = v7.Color
		stroke.Color = v7.Color
		corner.ImageColor3 = v7.Color

		for _, button in drops:GetDescendants() do
			if not button:IsA("ImageButton") then
				continue
			end

			local name = button.Name

			if not RodSkins.Rarities[name] then
				continue
			end

			local v9 = nil

			for k, v11 in v8 do
				if RodSkins.Skins[v11].Rarity ~= name then
					continue
				end

				table.remove(v8, k)
				v9 = v11
				break
			end

			if not v9 then
				continue
			end

			local skin = RodSkins.Skins[v9]
			local vector1 = button:FindFirstChild("vector1")

			if vector1 then
				vector1.Image = skin.Icon or ""
			else
				local viewportFrame = button:FindFirstChild("ViewportFrame")

				if viewportFrame then
					local camera = Instance.new("Camera", viewportFrame)
					local clone2 = assets.getAsync("skin", v9):WaitForChild("Skin"):Clone()
					clone2.Parent = viewportFrame
					viewportFrame.CurrentCamera = camera
					local v11 = ViewportModule.new(viewportFrame, camera)
					local boundingBox, _ = clone2:GetBoundingBox()
					v11:SetModel(clone2)
					local cframe = CFrame.fromEulerAnglesYXZ(0, 0, 0.4363323129985824)
					local fitDistance = v11:GetFitDistance(boundingBox.Position)
					camera.CFrame = CFrame.new(boundingBox.Position) * cframe * CFrame.new(0, 0, fitDistance * 0.5)
				end
			end

			local v11 = button
			button.MouseEnter:Connect(function()
				SkinCrateController:ShowFloating(v9, v11)
			end)
			local v12 = button
			button.MouseLeave:Connect(function()
				SkinCrateController:HideFloating(v12)
			end)
		end

		gift.Visible = v7.Price == nil
		local v9 = name2
		previewButton.Activated:Connect(function()
			SkinCrateController:SetupSpin(v9, true)
		end)

		if v7.TargetLocation and not tracker_locationsdiscovered:FindFirstChild((`{v7.TargetLocation}Discovered`)) then
			clone.LayoutOrder = layoutOrder + 500
			local location = clone:WaitForChild("Locked"):WaitForChild("Location")
			location.Text = v7.TargetLocation
			local locked = clone:WaitForChild("Locked")
			locked.Visible = true
			local header_2 = clone:WaitForChild("Preview"):WaitForChild("Header")
			header_2.Visible = false
			buy.Visible = false
			glow.ImageColor3 = Color3.fromRGB(99, 99, 99)
			stroke.Color = Color3.fromRGB(99, 99, 99)
			corner.ImageColor3 = Color3.fromRGB(99, 99, 99)
			local childAddedConnection = nil
			local v10 = v7
			local v11 = clone
			local v12 = buy
			local v13 = glow
			local v14 = stroke
			local v15 = corner
			local layoutOrder2 = layoutOrder
			childAddedConnection = tracker_locationsdiscovered.ChildAdded:Connect(function(child)
				if child.Name == `{v10.TargetLocation}Discovered` then
					local locked = v11:WaitForChild("Locked")
					locked.Visible = false
					local header = v11:WaitForChild("Preview"):WaitForChild("Header")
					header.Visible = true
					v12.Visible = true
					v13.ImageColor3 = v10.Color
					v14.Color = v10.Color
					v15.ImageColor3 = v10.Color
					childAddedConnection:Disconnect()
					v11.LayoutOrder = layoutOrder2
				end
			end)
		end

		local v10 = v7
		local v11 = name2
		buy.Activated:Connect(function()
			if v10.Price then
				local v12, v13 = remoteFunction2:InvokeServer(v11)

				if v12 == true then
					NotificationController:Notify(v13, 3, "success")
				elseif v13 then
					NotificationController:Notify(v13, 3, "error")
				end
			else
				Monetization.BuyProduct:FireServer(v10.ProductId)
			end
		end)
		local v12 = v7
		local v13 = name2
		gift.Activated:Connect(function()
			GiftController:PromptGift(v12.ProductId or 1, v13)
		end)
	end
end

function SkinCrateController:Toggle(visible: boolean)
	if visible == nil then
		visible = not crates.Visible
	end

	if crates.Visible == visible then
		return
	end

	crates.Visible = visible
end

function SkinCrateController:Start()
	crates:GetPropertyChangedSignal("Visible"):Connect(function()
		SkinCrateController:HideFloating()
	end)
	remoteEvent.OnClientEvent:Connect(function(...)
		self:Toggle(...)
	end)
	close.Activated:Connect(function()
		self:Toggle(false)
	end)
	InputController:Get("Gamepad").ButtonDown:Connect(function(p, flag: boolean)
		if not (flag ~= true and p == Enum.KeyCode.ButtonB) then
			return
		end

		self:Toggle(false)
	end)
	SkinCrateController:BuildList()
	local v5 = Timer.new(300)
	v5.Tick:Connect(function()
		for k, v6 in SkinCrates.List do
			if not v6.ProductId then
				continue
			end

			local lastPrice = v6.LastPrice

			for _ = 1, 5 do
				local v7 = v6
				local success, result = pcall(function()
					return MarketplaceService:GetProductInfo(v7.ProductId, Enum.InfoType.Product)
				end)

				if success then
					lastPrice = result.PriceInRobux
					break
				else
					task.wait(0.5)
				end
			end

			if v6.Price then
				lastPrice = v6.Price or lastPrice
			end

			SkinCrateController:UpdatePrice(
				k,
				lastPrice,
				v6.Price and CurrencyController:GetDisplay(v6.Currency) or utf8.char(57346)
			)
		end
	end)
	v5:StartNow()
	crates.Visible = false
	close2.Activated:Connect(function()
		self:HideSpin()
	end)
	spin2.Activated:Connect(function()
		local v6, v7, v8 = remoteFunction:InvokeServer()

		if v6 == true then
			v4:Fire(v7, v8)
		end
	end)
	v4:Connect(function(...)
		SkinCrateController:Spin(...)
	end)
	local limitedbundle = crates:FindFirstChild("limitedbundle")
	local gift = limitedbundle:WaitForChild("bundlepreview"):WaitForChild("Gift")
	local buyButton = limitedbundle:WaitForChild("bundlepreview"):WaitForChild("BuyButton")
	local border = buyButton:WaitForChild("border")
	local corner = buyButton:WaitForChild("corner")
	local bundles = legacyLocalPlayerData.fetch():WaitForChild("Cache"):WaitForChild("Bundles")
	local featuredBundle = Monetization.products.Bundles.FeaturedBundle
	local bundle = Monetization.products.Bundles.bundles[featuredBundle]

	if not bundle then
		return
	end

	local activatedConnection2 = buyButton.Activated:Connect(function()
		Monetization.BuyProduct:FireServer(bundle.ProductId)
	end)
	local activatedConnection3 = gift.Activated:Connect(function()
		GiftController:PromptGift(bundle.ProductId)
	end)

	if BundleController:RequestState(featuredBundle) == true then
		BundleController.OnBundleDisabled:Connect(function(p: string)
			if p == featuredBundle then
				if activatedConnection2 then
					activatedConnection2:Disconnect()
					activatedConnection2 = nil
				end

				if activatedConnection3 then
					activatedConnection3:Disconnect()
					activatedConnection3 = nil
				end

				buyButton.Text = "Off Sale"
				buyButton.TextColor3 = Color3.fromRGB(74, 74, 74)
				border.Color = Color3.fromRGB(74, 74, 74)
				corner.ImageColor3 = Color3.fromRGB(74, 74, 74)
			end
		end)
	else
		if activatedConnection2 then
			activatedConnection2:Disconnect()
			activatedConnection2 = nil
		end

		if activatedConnection3 then
			activatedConnection3:Disconnect()
			activatedConnection3 = nil
		end

		buyButton.Text = "Off Sale"
		buyButton.TextColor3 = Color3.fromRGB(74, 74, 74)
		border.Color = Color3.fromRGB(74, 74, 74)
		corner.ImageColor3 = Color3.fromRGB(74, 74, 74)
	end

	local robuxPrice = Monetization:GetRobuxPrice(bundle.ProductId)

	if robuxPrice then
		buyButton.Text = utf8.char(57346) .. tostring(robuxPrice)
	end

	if bundles:FindFirstChild(featuredBundle) then
		if activatedConnection2 then
			activatedConnection2:Disconnect()
			activatedConnection2 = nil
		end

		buyButton.Text = "Owned"
	else
		local childAddedConnection = nil
		childAddedConnection = bundles.ChildAdded:Connect(function(child)
			if child.Name ~= Monetization.products.Bundles.FeaturedBundle then
				return
			end

			childAddedConnection:Disconnect()
			buyButton.Text = "Owned"

			if activatedConnection2 then
				activatedConnection2:Disconnect()
				activatedConnection2 = nil
			end
		end)
	end
end

return SkinCrateController