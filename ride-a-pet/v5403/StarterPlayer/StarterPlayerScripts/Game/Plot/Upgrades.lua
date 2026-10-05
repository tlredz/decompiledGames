local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local PurchaseCue = require(ReplicatedStorage2:WaitForChild("GameServices"):WaitForChild("PurchaseCue"))
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local HatchLuck = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("HatchLuck"))
local String = require(ReplicatedStorage:WaitForChild("Services"):WaitForChild("String"))
local Monetization = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("Monetization"))
local GamepadAim = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("GamepadAim"))
local upgrade = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Billboards"):WaitForChild("Upgrade")
local maxUpgrade = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Billboards"):WaitForChild("MaxUpgrade")
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local upgrades = remotes:WaitForChild("Game"):WaitForChild("Plot"):WaitForChild("Upgrades")
local funnelStep = remotes:WaitForChild("Game"):WaitForChild("FunnelStep")
local plots = workspace:WaitForChild("Plots")
local SFX = game.SoundService:WaitForChild("SFX")
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local color = Color3.fromRGB(255, 45, 45)
local colorSequence = ColorSequence.new(Color3.fromRGB(255, 105, 105), Color3.fromRGB(190, 15, 15))
local v = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function LuckMultiplierOn()
	return localPlayer:GetAttribute("Setting_LuckMultiplier") ~= false
end

local clonesByInstance = {}
local clonesByInstance2 = {}
local maxUpgradesByInstance = {}
local v2 = {}
local v3 = {}
local tweensByBar = {}
local v4 = utf8.char(57346)
local priceInRobuxesByProductId = {}
local v5 = {}

local function FormatRobux(p)
	return v4 .. String:AddComma(p)
end

local function RefreshRobuxPrice(robuxPrice, productId)
	if not (robuxPrice and productId) then
		return
	end

	robuxPrice:SetAttribute("ProductId", productId)
	local v6 = priceInRobuxesByProductId[productId]

	if v6 then
		robuxPrice.Text = v4 .. String:AddComma(v6)
		return
	end

	if v5[productId] then
		return
	end

	v5[productId] = true
	task.spawn(function()
		local success, productInfo = pcall(
			MarketplaceService.GetProductInfo,
			MarketplaceService,
			productId,
			Enum.InfoType.Product
		)
		v5[productId] = nil
		local priceInRobux = success and productInfo and tonumber(productInfo.PriceInRobux)

		if not priceInRobux then
			return
		end

		priceInRobuxesByProductId[productId] = priceInRobux

		if robuxPrice.Parent and robuxPrice:GetAttribute("ProductId") == productId then
			robuxPrice.Text = v4 .. String:AddComma(priceInRobux)
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function DisconnectOwner(p)
	local v6 = v3[p]

	if v6 then
		v3[p] = nil

		for _, connection in v6 do
			connection:Disconnect()
		end
	end
end

local UpdateBoard

-- equivalent calls inferred from this helper; original call sites unknown
local function TintButton(p, p2)
	if not p then
		return
	end

	if v[p] == nil then
		v[p] = p.BackgroundColor3
	end

	p.BackgroundColor3 = p2 and v[p] or color
end

-- equivalent calls inferred from this helper; original call sites unknown
local function TintBar(bar, p)
	if not bar then
		return
	end

	local uIGradient = bar:FindFirstChildOfClass("UIGradient")

	if uIGradient then
		if v[uIGradient] == nil then
			v[uIGradient] = uIGradient.Color
		end

		uIGradient.Color = p and v[uIGradient] or colorSequence
	else
		TintButton(bar, p) -- equivalent call inferred; original call site unknown
	end
end

local function PaintGate(p)
	local luckMultiplierOn = LuckMultiplierOn() -- equivalent call inferred; original call site unknown
	local v7 = clonesByInstance[p]

	if v7 then
		TintButton(v7:FindFirstChild("Purchase"), luckMultiplierOn) -- equivalent call inferred; original call site unknown
		local bonusProgress = v7:FindFirstChild("BonusProgress")
		local bar = bonusProgress and bonusProgress:FindFirstChild("Bar")
		TintBar(bar, luckMultiplierOn) -- equivalent call inferred; original call site unknown
	end

	local v8 = clonesByInstance2[p]

	if v8 then
		TintButton(v8:FindFirstChild("Purchase"), luckMultiplierOn) -- equivalent call inferred; original call site unknown
	end
end

local function PaintEveryGate()
	for k in clonesByInstance do
		local data = k:FindFirstChild("Data")
		local owner = data and data:FindFirstChild("Owner")
		UpdateBoard(k, owner and owner.Value)
		PaintGate(k)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ShowMessage(p)
	pcall(function()
		local Handler = require(playerGui.Reusable.GameMessages.Handler)
		Handler:AddMessage(p)
	end)
end

local flag = false

-- equivalent calls inferred from this helper; original call sites unknown
local function RefuseUpgrade()
	ShowMessage("Turn On Luck Multiplier Settings First") -- equivalent call inferred; original call site unknown

	if flag then
		return
	end

	flag = true
	task.delay(1, function()
		flag = false
		local main = playerGui:FindFirstChild("Main")
		local settings = main and main:FindFirstChild("Settings")

		if settings then
			local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
			require(ReplicatedStorage3:WaitForChild("UIController")).open(settings)
		end
	end)
end

localPlayer:GetAttributeChangedSignal("Setting_LuckMultiplier"):Connect(PaintEveryGate)

local function SetMaxVisible(p, enabled)
	local v6 = clonesByInstance2[p]
	local v7 = maxUpgradesByInstance[p]

	if v6 then
		v6.Enabled = enabled
	end

	if not v7 then
		return
	end

	local v8 = v2[v7]

	if not v8 then
		v8 = {
			Transparency = v7.Transparency,
			CanQuery = v7.CanQuery,
			CanTouch = v7.CanTouch
		}
		v2[v7] = v8
	end

	v7.Transparency = not enabled and 1 or v8.Transparency or 1
	local canQuery

	if enabled then
		canQuery = v8.CanQuery or false
	else
		canQuery = false
	end

	v7.CanQuery = canQuery
	v7.CanTouch = enabled and v8.CanTouch or false
end

UpdateBoard = function(p, instance)
	local v6 = clonesByInstance[p]

	if not v6 then
		return
	end

	local savedData = instance and instance:FindFirstChild("SavedData")
	local hatchUpgrades = savedData and savedData:FindFirstChild("HatchUpgrades")
	local cash = savedData and savedData:FindFirstChild("Cash")

	if hatchUpgrades then
		v6.Enabled = true
		local active = instance == localPlayer
		local value = hatchUpgrades.Value
		local usedFreeHatchUpgrades = savedData and savedData:FindFirstChild("UsedFreeHatchUpgrades")
		local price = HatchLuck.GetPrice(HatchLuck.GetPaidUpgrades(
			value,
			not usedFreeHatchUpgrades and 0 or usedFreeHatchUpgrades.Value or 0
		))
		local multiplierEnabled = HatchLuck.MultiplierEnabled(instance)
		v6.CurrentUpgrade.Text = HatchLuck.FormatMultiplier(HatchLuck.EffectiveUpgrades(instance, value))
		v6.NextUpgrade.Text = HatchLuck.FormatMultiplier(not multiplierEnabled and 0 or value + 1 or 0)

		if HatchLuck.EventMultiplier() > 1 then
			v6.CurrentUpgrade.Text = string.format(
				"%s + Increased (Event)",
				HatchLuck.FormatMultiplier(HatchLuck.EffectiveUpgrades(instance, value))
			)
		end

		local freeHatchUpgrades = savedData and savedData:FindFirstChild("FreeHatchUpgrades")
		local value2 = freeHatchUpgrades and freeHatchUpgrades.Value or 0
		local visible = value2 > 0
		v6.Purchase.Price.Text = visible and "FREE" or String:FormatCurrency(price)
		local freeCount = v6.Purchase:FindFirstChild("FreeCount")

		if freeCount then
			freeCount.Text = "x" .. value2
			freeCount.Visible = visible
		end

		local v9 = visible or price <= (not cash and 0 or cash.Value or 0)
		v6.Purchase.NotEnough.Visible = not v9
		local v10 = clonesByInstance2[p]

		if v10 then
			local v11, v12

			if visible then
				v11 = 0
				v12 = 0
			else
				local paidUpgrades = HatchLuck.GetPaidUpgrades(
					value,
					usedFreeHatchUpgrades and usedFreeHatchUpgrades.Value or 0
				)
				v12, v11 = HatchLuck.GetMaxAffordable(paidUpgrades, cash and cash.Value or 0)
			end

			if visible then
				v12 = value2 or v12
			end

			v10.Purchase.Price.Text = v11 > 0 and String:FormatCurrency(v11) or "FREE"
			v10.Purchase.Active = active
			SetMaxVisible(p, visible or v12 >= 2)
		end

		local luckUpgradeBuys = savedData and savedData:FindFirstChild("LuckUpgradeBuys")
		local textLabel = v6.UpgradeLuck:FindFirstChild("TextLabel")

		if textLabel then
			textLabel.Text = "x" .. HatchLuck.GetFreeUpgradesForBuys(not luckUpgradeBuys and 0 or luckUpgradeBuys.Value or 0)
		end

		v6.UpgradeLuck:SetAttribute("PackBuys", not luckUpgradeBuys and 0 or luckUpgradeBuys.Value or 0)
		local v11 = Monetization[HatchLuck.GetPackProductKey(luckUpgradeBuys and luckUpgradeBuys.Value or 0)]
		RefreshRobuxPrice(v6.UpgradeLuck:FindFirstChild("RobuxPrice"), v11)
		local v12 = value % HatchLuck.BonusEvery
		v6.BonusProgress.Progress.Text = v12 .. "/" .. HatchLuck.BonusEvery
		local bar = v6.BonusProgress.Bar
		local v13 = math.max(v12 / HatchLuck.BonusEvery, 0.1)
		local fillTarget = bar:GetAttribute("FillTarget")
		local fillOwnerId = bar:GetAttribute("FillOwnerId")
		local fillUpgrades = bar:GetAttribute("FillUpgrades")
		local userId = instance.UserId

		if fillTarget ~= v13 or fillOwnerId ~= userId then
			local v14 = fillTarget == nil
			local v15 = not v14

			if v15 then
				if fillOwnerId == userId and typeof(fillUpgrades) == "number" and fillUpgrades < value then
					v15 = v13 < (fillTarget or 0)
				else
					v15 = false
				end
			end

			bar:SetAttribute("FillTarget", v13)
			bar:SetAttribute("FillOwnerId", userId)
			bar:SetAttribute("FillUpgrades", value)
			local v16 = tweensByBar[bar]

			if v16 then
				v16:Cancel()
			end

			local uDim = UDim2.new(v13, 0, 1, 0)

			if v14 or fillOwnerId ~= userId then
				bar.Size = uDim
			elseif v15 then
				local tween = TweenService:Create(bar, tweenInfo2, {
					Size = UDim2.new(1, 0, 1, 0)
				})
				tweensByBar[bar] = tween
				tween.Completed:Once(function(p2)
					if p2 ~= Enum.PlaybackState.Completed or (tweensByBar[bar] ~= tween or bar:GetAttribute("FillTarget") ~= v13) then
						return
					end

					local tween2 = TweenService:Create(bar, tweenInfo2, {
						Size = uDim
					})
					tweensByBar[bar] = tween2
					tween2:Play()
				end)
				tween:Play()
			else
				local tween = TweenService:Create(bar, tweenInfo, {
					Size = uDim
				})
				tweensByBar[bar] = tween
				tween:Play()
			end
		end

		v6.Purchase.Active = active
		v6.UpgradeLuck.Active = active
		PaintGate(p)
	else
		v6.Enabled = false
		local v7 = clonesByInstance2[p]
		local v8 = maxUpgradesByInstance[p]

		if v7 then
			v7.Enabled = false
		end

		if not v8 then
			return
		end

		if not v2[v8] then
			v2[v8] = {
				Transparency = v8.Transparency,
				CanQuery = v8.CanQuery,
				CanTouch = v8.CanTouch
			}
		end

		v8.Transparency = 1
		v8.CanQuery = false
		v8.CanTouch = false
	end
end

local function WaitPatiently(instance, childName, p)
	local child = instance:WaitForChild(childName, 15)

	if child then
		return child
	end

	warn((`[Upgrades] {p}: still waiting for {childName}`))
	return instance:WaitForChild(childName)
end

local function BindOwner(instance, value)
	DisconnectOwner(instance) -- equivalent call inferred; original call site unknown
	UpdateBoard(instance, value)

	if not value then
		return
	end

	local connections = {}
	v3[instance] = connections
	task.spawn(function()
		local v6 = value
		local name = value.Name
		local savedData = v6:WaitForChild("SavedData", 15)

		if not savedData then
			warn((`[Upgrades] {name}: still waiting for SavedData`))
			savedData = v6:WaitForChild("SavedData")
		end

		local hatchUpgrades

		if savedData then
			local name2 = value.Name
			hatchUpgrades = savedData:WaitForChild("HatchUpgrades", 15)

			if not hatchUpgrades then
				warn((`[Upgrades] {name2}: still waiting for HatchUpgrades`))
				hatchUpgrades = savedData:WaitForChild("HatchUpgrades")
			end
		else
			hatchUpgrades = savedData
		end

		local cash

		if savedData then
			local name2 = value.Name
			cash = savedData:WaitForChild("Cash", 15)

			if not cash then
				warn((`[Upgrades] {name2}: still waiting for Cash`))
				cash = savedData:WaitForChild("Cash")
			end
		else
			cash = savedData
		end

		if not (hatchUpgrades and cash and v3[instance] == connections) then
			return
		end

		table.insert(connections, hatchUpgrades.Changed:Connect(function()
			UpdateBoard(instance, value)
		end))
		table.insert(connections, cash.Changed:Connect(function()
			UpdateBoard(instance, value)
		end))
		table.insert(
			connections,
			ReplicatedStorage:GetAttributeChangedSignal(HatchLuck.EventAttribute):Connect(function()
				UpdateBoard(instance, value)
			end)
		)

		for _, childName in { "FreeHatchUpgrades", "LuckUpgradeBuys" } do
			local child = savedData:FindFirstChild(childName)

			if child then
				table.insert(connections, child.Changed:Connect(function()
					UpdateBoard(instance, value)
				end))
			end
		end

		UpdateBoard(instance, value)
	end)
end

local v6 = {}

local function FaceNormal(adornee, face)
	local cFrame = adornee.CFrame
	local size = adornee.Size

	if face == Enum.NormalId.Front then
		return cFrame.LookVector, size.Z / 2
	end

	if face == Enum.NormalId.Back then
		return -cFrame.LookVector, size.Z / 2
	end

	if face == Enum.NormalId.Right then
		return cFrame.RightVector, size.X / 2
	end

	if face == Enum.NormalId.Left then
		return -cFrame.RightVector, size.X / 2
	end

	if face == Enum.NormalId.Top then
		return cFrame.UpVector, size.Y / 2
	end

	return -cFrame.UpVector, size.Y / 2
end

local function BoardFacesCamera(p)
	local adornee = p.Adornee
	local currentCamera = workspace.CurrentCamera

	if adornee and adornee:IsA("BasePart") and currentCamera then
		local v7, v8 = FaceNormal(adornee, p.Face)
		local v9 = adornee.Position + v7 * v8
		return (currentCamera.CFrame.Position - v9):Dot(v7) > 0
	else
		return false
	end
end

task.spawn(function()
	while true do
		task.wait(0.1)

		for k, v7 in v6 do
			local enabled = v7.Enabled and BoardFacesCamera(v7)

			if k.Enabled ~= enabled then
				k.Enabled = enabled
			end
		end
	end
end)

local function MakeInputOverlay(clone)
	local clone2 = clone:Clone()
	clone2.Name = clone.Name .. "Input"
	clone2.AlwaysOnTop = true
	clone2.MaxDistance = 120

	for _, descendant in clone2:GetDescendants() do
		if descendant:IsA("UIStroke") or descendant:IsA("UIGradient") then
			descendant:Destroy()
		elseif descendant:IsA("GuiObject") then
			descendant.BackgroundTransparency = 1

			if descendant:IsA("ImageLabel") or descendant:IsA("ImageButton") then
				descendant.ImageTransparency = 1
			end

			if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
				descendant.TextTransparency = 1
				descendant.TextStrokeTransparency = 1
			end

			if descendant:IsA("GuiButton") then
				descendant.AutoButtonColor = false
			end
		end
	end

	clone2.Enabled = clone.Enabled and BoardFacesCamera(clone)
	v6[clone2] = clone
	clone:GetPropertyChangedSignal("Enabled"):Connect(function()
		clone2.Enabled = clone.Enabled and BoardFacesCamera(clone)
	end)
	clone.Destroying:Connect(function()
		v6[clone2] = nil
		clone2:Destroy()
	end)
	clone2.Parent = clone.Parent
	return clone2
end

local function MirrorButton(instance, p)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function Sync()
		p.Visible = instance.Visible
		p.Active = instance.Active
	end

	instance:GetPropertyChangedSignal("Visible"):Connect(Sync)
	instance:GetPropertyChangedSignal("Active"):Connect(Sync)
	Sync() -- equivalent call inferred; original call site unknown
end

local function WatchPlot(instance)
	if clonesByInstance[instance] then
		return
	end

	local name = instance.Name
	local hatchUpgrade = instance:WaitForChild("HatchUpgrade", 15)

	if not hatchUpgrade then
		warn((`[Upgrades] {name}: still waiting for HatchUpgrade`))
		hatchUpgrade = instance:WaitForChild("HatchUpgrade")
	end

	local name2 = instance.Name
	local screen = hatchUpgrade:WaitForChild("Screen", 15)

	if not screen then
		warn((`[Upgrades] {name2}: still waiting for Screen`))
		screen = hatchUpgrade:WaitForChild("Screen")
	end

	local name3 = instance.Name
	local data = instance:WaitForChild("Data", 15)

	if not data then
		warn((`[Upgrades] {name3}: still waiting for Data`))
		data = instance:WaitForChild("Data")
	end

	local name4 = instance.Name
	local owner = data:WaitForChild("Owner", 15)

	if not owner then
		warn((`[Upgrades] {name4}: still waiting for Owner`))
		owner = data:WaitForChild("Owner")
	end

	if not screen or not owner or not instance.Parent or clonesByInstance[instance] then
		return
	end

	local clone = upgrade:Clone()
	clone.Adornee = screen
	clone.Parent = playerGui
	clonesByInstance[instance] = clone
	local success, result = pcall(function()
		local maxUpgrade2 = hatchUpgrade:FindFirstChild("MaxUpgrade")

		if maxUpgrade2 then
			local clone2 = maxUpgrade:Clone()
			clone2.Adornee = maxUpgrade2
			clone2.Parent = playerGui
			clonesByInstance2[instance] = clone2
			maxUpgradesByInstance[instance] = maxUpgrade2
			local v7 = instance
			local v8 = clonesByInstance2[v7]
			local v9 = maxUpgradesByInstance[v7]

			if v8 then
				v8.Enabled = false
			end

			if v9 then
				if not v2[v9] then
					v2[v9] = {
						Transparency = v9.Transparency,
						CanQuery = v9.CanQuery,
						CanTouch = v9.CanTouch
					}
				end

				v9.Transparency = 1
				v9.CanQuery = false
				v9.CanTouch = false
			end

			local function BuyMax()
				if not (owner.Value == localPlayer and BoardFacesCamera(clone2)) then
					return
				end

				if LuckMultiplierOn() then
					local savedData = localPlayer:FindFirstChild("SavedData")
					local freeHatchUpgrades = savedData and savedData:FindFirstChild("FreeHatchUpgrades")

					if freeHatchUpgrades and freeHatchUpgrades.Value > 0 then
						SFX.Purchase:Play()
					end

					upgrades:FireServer(freeHatchUpgrades and freeHatchUpgrades.Value > 0 and "MaxFree" or "Max")
				else
					RefuseUpgrade() -- equivalent call inferred; original call site unknown
				end
			end

			clone2.Purchase.Activated:Connect(BuyMax)
			GamepadAim.Register(clone2.Purchase, BuyMax)
			local inputOverlay = MakeInputOverlay(clone2)
			inputOverlay.Purchase.Activated:Connect(BuyMax)
			MirrorButton(clone2.Purchase, inputOverlay.Purchase)
		end

		local function BuyOne()
			if not (owner.Value == localPlayer and BoardFacesCamera(clone)) then
				return
			end

			if LuckMultiplierOn() then
				local savedData = localPlayer:FindFirstChild("SavedData")
				local freeHatchUpgrades = savedData and savedData:FindFirstChild("FreeHatchUpgrades")

				if freeHatchUpgrades and freeHatchUpgrades.Value > 0 then
					SFX.Purchase:Play()
				end

				upgrades:FireServer()
			else
				RefuseUpgrade() -- equivalent call inferred; original call site unknown
			end
		end

		clone.Purchase.Activated:Connect(BuyOne)
		GamepadAim.Register(clone.Purchase, BuyOne)

		local function BuyPack()
			if not (owner.Value == localPlayer and BoardFacesCamera(clone)) then
				return
			end

			if LuckMultiplierOn() then
				local savedData = localPlayer:FindFirstChild("SavedData")
				local luckUpgradeBuys = savedData and savedData:FindFirstChild("LuckUpgradeBuys")
				local packProductKey = HatchLuck.GetPackProductKey(luckUpgradeBuys and luckUpgradeBuys.Value or 0)
				local v7 = Monetization[packProductKey]

				if not v7 then
					warn(string.format("Upgrades: no product id for %q", (tostring(packProductKey))))
					return
				end

				funnelStep:FireServer("PayerConversionV2", "Clicked")
				PurchaseCue.Play()
				MarketplaceService:PromptProductPurchase(localPlayer, v7)
			else
				RefuseUpgrade() -- equivalent call inferred; original call site unknown
			end
		end

		clone.UpgradeLuck.Activated:Connect(BuyPack)
		GamepadAim.Register(clone.UpgradeLuck, BuyPack)
		local inputOverlay2 = MakeInputOverlay(clone)
		inputOverlay2.Purchase.Activated:Connect(BuyOne)
		inputOverlay2.UpgradeLuck.Activated:Connect(BuyPack)
		MirrorButton(clone.Purchase, inputOverlay2.Purchase)
		MirrorButton(clone.UpgradeLuck, inputOverlay2.UpgradeLuck)
		local v8 = false
		inputOverlay2.UpgradeLuck.MouseEnter:Connect(function()
			if v8 or owner.Value ~= localPlayer then
				return
			end

			v8 = true
			funnelStep:FireServer("PayerConversionV2", "Hovered")
		end)
	end)

	if not success then
		warn((`[Upgrades] {instance.Name}: board wiring failed: {result}`))
	end

	owner.Changed:Connect(function()
		BindOwner(instance, owner.Value)
	end)
	BindOwner(instance, owner.Value)
end

for _, child in plots:GetChildren() do
	task.spawn(WatchPlot, child)
end

plots.ChildAdded:Connect(function(child)
	task.spawn(WatchPlot, child)
end)
local RunService = game:GetService("RunService")

local function FindMyBoard()
	for _, child in plots:GetChildren() do
		local data = child:FindFirstChild("Data")
		local owner = data and data:FindFirstChild("Owner")

		if owner and owner.Value == localPlayer then
			return child:FindFirstChild("HatchUpgrade")
		end
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function BoardPoint(instance)
	return instance:GetPivot().Position + createVector(0, 4, 0)
end

local function MakeBeam()
	local tutorialBeam = workspace:FindFirstChild("TutorialBeam")
	local beam = tutorialBeam and tutorialBeam:FindFirstChild("Beam")

	if beam then
		return beam:Clone()
	end

	local beam2 = Instance.new("Beam")
	beam2.Width0 = 2
	beam2.Width1 = 2
	beam2.FaceCamera = true
	beam2.LightEmission = 1
	beam2.Color = ColorSequence.new(Color3.fromRGB(80, 255, 120))
	return beam2
end

local flag2 = false

local function PointAtBoard()
	if flag2 then
		return
	end

	local myBoard = FindMyBoard()

	if not myBoard then
		return
	end

	flag2 = true
	local part = Instance.new("Part")
	part.Name = "LuckBoardBeamAnchor"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 1
	part.Size = createVector(1, 1, 1)
	part.Position = BoardPoint(myBoard)
	part.Parent = workspace
	local attachment = Instance.new("Attachment")
	attachment.Parent = part
	local beam = MakeBeam()
	beam.Attachment0 = attachment
	beam.Enabled = true
	beam.Parent = part
	local attachment2 = nil

	local function AttachToCharacter(instance)
		local humanoidRootPart = instance and instance:WaitForChild("HumanoidRootPart", 5)

		if not (humanoidRootPart and part.Parent) then
			return
		end

		if attachment2 then
			attachment2:Destroy()
		end

		attachment2 = Instance.new("Attachment")
		attachment2.Name = "LuckBoardBeamAttachment"
		attachment2.Parent = humanoidRootPart
		beam.Attachment1 = attachment2
	end

	task.spawn(AttachToCharacter, localPlayer.Character)
	local characterAddedConnection = localPlayer.CharacterAdded:Connect(AttachToCharacter)
	local lastTime = os.clock()
	local heartbeatConnection = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Finish()
		if heartbeatConnection then
			heartbeatConnection:Disconnect()
		end

		characterAddedConnection:Disconnect()

		if attachment2 then
			attachment2:Destroy()
		end

		part:Destroy()
		flag2 = false
	end

	heartbeatConnection = RunService.Heartbeat:Connect(function()
		if myBoard.Parent then
			part.Position = BoardPoint(myBoard)
			local character = localPlayer.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart and (humanoidRootPart.Position - part.Position).Magnitude <= 16 or os.clock() - lastTime > 90 then
				Finish() -- equivalent call inferred; original call site unknown
			end
		else
			Finish() -- equivalent call inferred; original call site unknown
		end
	end)
end

task.spawn(function()
	local rebirths = localPlayer:WaitForChild("SavedData"):WaitForChild("Rebirths")
	local noSaveData = localPlayer:WaitForChild("NoSaveData", 30)
	local dataLoaded = noSaveData and noSaveData:WaitForChild("DataLoaded", 30)

	if not dataLoaded then
		return
	end

	while not dataLoaded.Value and localPlayer.Parent do
		dataLoaded.Changed:Wait()
	end

	if not localPlayer.Parent then
		return
	end

	local value = tonumber(rebirths.Value) or 0
	rebirths.Changed:Connect(function()
		local value2 = tonumber(rebirths.Value) or 0
		local v7

		if value == 0 then
			v7 = value2 == 1
		else
			v7 = false
		end

		value = value2

		if not v7 then
			return
		end

		task.delay(1.5, function()
			pcall(function()
				local Handler = require(playerGui:WaitForChild("Reusable"):WaitForChild("GameMessages"):WaitForChild("Handler"))
				Handler:AddMessage("Your Luck Board Has Been Moved", 10)
			end)
			PointAtBoard()
		end)
	end)
end)