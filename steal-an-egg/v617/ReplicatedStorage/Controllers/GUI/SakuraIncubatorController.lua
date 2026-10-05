local ContextActionService = game:GetService("ContextActionService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Assets = require(ReplicatedStorage.Data.Assets)
local directory = Assets.Directory
local ButtonFX = require(ReplicatedStorage.Client.UI.VFX.ButtonFX)
local ButtonHintStrip = require(ReplicatedStorage.Client.ButtonHintStrip)
require(ReplicatedStorage.Shared.Globals.Constants)
local EggRecords = require(ReplicatedStorage.Shared.Util.EggRecords)
require(ReplicatedStorage.Shared.Types.Eggs)
local GUI = require(ReplicatedStorage.Client.GUI)
local TryLock = require(ReplicatedStorage.Shared.Utils.TryLock)
local Log = require(ReplicatedStorage.Packages.Log)
local Message = require(ReplicatedStorage.Client.Message)
local Mutations = require(ReplicatedStorage.Shared.Modules.Mutations)
local Toast = require(ReplicatedStorage.Client.Notifications.Toast)
local PlatformController = require(ReplicatedStorage.Client.PlatformController)
local Products = require(ReplicatedStorage.Data.Products)
local Storefront = require(ReplicatedStorage.Client.Functions.Storefront)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Sakura = require(ReplicatedStorage.Data.Sakura)
local SakuraBloomPolicy = require(ReplicatedStorage.Client.Modules.SakuraBloomPolicy)
local SakuraSignals = require(ReplicatedStorage.Client.SakuraSignals)
local Sakura2 = require(ReplicatedStorage.Shared.Types.Sakura)
local Save = require(ReplicatedStorage.Shared.Save)
local Simple = require(ReplicatedStorage.Packages.FormatNumber.Simple)
local Tabs = require(ReplicatedStorage.Client.Tabs)
local Trove = require(ReplicatedStorage.Packages.Trove)
local v = utf8.char(57346)
local color = Color3.fromRGB(255, 0, 0)
local v2 = Log.new()
local tryLock = TryLock()
local _ = Players.LocalPlayer
return {
	Start = function()
		local sakuraEggCharge = GUI.SakuraEggCharge().SakuraEggCharge
		assert(sakuraEggCharge:IsA("Frame"), "SakuraEggCharge.SakuraEggCharge must be a Frame")
		local content = sakuraEggCharge.Content
		assert(content:IsA("Frame"), "SakuraEggCharge.Content must be a Frame")
		local eggIconHolder = content.EggIconHolder
		local icon = eggIconHolder.Icon
		assert(icon:IsA("ImageLabel"), "SakuraEggCharge EggIconHolder.Icon must be an ImageLabel")
		local title = icon.Title
		assert(title:IsA("TextLabel"), "SakuraEggCharge EggIconHolder.Icon.Title must be a TextLabel")
		local mutate = content.Mutate
		assert(mutate:IsA("ImageButton"), "SakuraEggCharge.Content.Mutate must be an ImageButton")
		local deposit = content.Deposit
		assert(deposit:IsA("ImageButton"), "SakuraEggCharge.Content.Deposit must be an ImageButton")

		local function optionalGui(instance, childName: string, className: string)
			local child = instance:FindFirstChild(childName, true)

			if child and child:IsA(className) then
				return child
			end

			return nil
		end

		local removeEgg = sakuraEggCharge:FindFirstChild("RemoveEgg", true)

		if not (removeEgg and removeEgg:IsA("GuiButton")) then
			removeEgg = nil
		end

		local help = sakuraEggCharge:FindFirstChild("Help", true)

		if not (help and help:IsA("GuiButton")) then
			help = nil
		end

		local costLabel = sakuraEggCharge:FindFirstChild("CostLabel", true)

		if not (costLabel and costLabel:IsA("TextLabel")) then
			costLabel = nil
		end

		local crystalBalance = sakuraEggCharge:FindFirstChild("CrystalBalance", true)

		if not (crystalBalance and crystalBalance:IsA("TextLabel")) then
			crystalBalance = nil
		end

		local sliderBar = content.SliderBar
		local fill = sliderBar.Progress.Fill
		assert(fill:IsA("Frame"), "SakuraEggCharge SliderBar.Progress.Fill must be a Frame")
		local sliderButton = sliderBar.SliderButton
		assert(sliderButton:IsA("ImageButton"), "SakuraEggCharge SliderBar.SliderButton must be an ImageButton")
		local progressBar = content.ProgressBar
		local imageLabel = progressBar.Frame1.ImageLabel
		assert(imageLabel:IsA("ImageLabel"), "SakuraEggCharge ProgressBar.Frame1.ImageLabel must be an ImageLabel")
		local uIGradient = imageLabel.UIGradient
		assert(
			uIGradient:IsA("UIGradient"),
			"SakuraEggCharge ProgressBar.Frame1.ImageLabel.UIGradient must be a UIGradient"
		)
		local imageLabel2 = progressBar.Frame2.ImageLabel
		assert(imageLabel2:IsA("ImageLabel"), "SakuraEggCharge ProgressBar.Frame2.ImageLabel must be an ImageLabel")
		local uIGradient2 = imageLabel2.UIGradient
		assert(
			uIGradient2:IsA("UIGradient"),
			"SakuraEggCharge ProgressBar.Frame2.ImageLabel.UIGradient must be a UIGradient"
		)
		uIGradient.Enabled = true
		uIGradient2.Enabled = true
		local sliderButton2 = progressBar.SliderButton
		assert(sliderButton2:IsA("ImageButton"), "SakuraEggCharge ProgressBar.SliderButton must be an ImageButton")
		local currentChargeLabel = content.CurrentChargeHolder.CurrentChargeLabel
		assert(currentChargeLabel:IsA("TextLabel"), "SakuraEggCharge CurrentChargeLabel must be a TextLabel")
		local sidePopUp = sakuraEggCharge.SidePopUp
		local mutationList = sidePopUp.MutationList
		assert(mutationList:IsA("ScrollingFrame"), "SakuraEggCharge SidePopUp.MutationList must be a ScrollingFrame")
		local buyLuck = sidePopUp.BuyLuck
		assert(buyLuck:IsA("ImageButton"), "SakuraEggCharge SidePopUp.BuyLuck must be an ImageButton")
		local price = buyLuck.Price
		assert(price:IsA("TextLabel"), "SakuraEggCharge BuyLuck.Price must be a TextLabel")
		local textLabel = buyLuck.TextLabel
		assert(textLabel:IsA("TextLabel"), "SakuraEggCharge BuyLuck.TextLabel must be a TextLabel")
		local eggPicker = sakuraEggCharge.EggPicker
		assert(eggPicker:IsA("Frame"), "SakuraEggCharge.EggPicker must be a Frame")
		local eggs = eggPicker.Eggs
		assert(eggs:IsA("ScrollingFrame"), "SakuraEggCharge EggPicker.Eggs must be a ScrollingFrame")
		local inventoryTemplate = ReplicatedStorage:WaitForChild("Controllers"):WaitForChild("GUI"):WaitForChild("BackpackController"):WaitForChild("Main"):WaitForChild("InventoryTemplate")
		assert(inventoryTemplate:IsA("GuiButton"), "BackpackController.Main.InventoryTemplate must be a GuiButton")
		local v4 = nil
		local v5 = nil

		for _, label in ipairs(deposit:GetChildren()) do
			if not label:IsA("TextLabel") then
				continue
			end

			if label.Text:find("Deposit") then
				v4 = label
			else
				v5 = label
			end
		end

		assert(v4 and v5, "SakuraEggCharge Deposit button needs its two TextLabels")
		local lockedOverlay = mutate.LockedOverlay
		assert(lockedOverlay:IsA("Frame"), "SakuraEggCharge Mutate.LockedOverlay must be a Frame")
		local textLabel2 = mutate:FindFirstChildOfClass("TextLabel")
		assert(textLabel2, "SakuraEggCharge Mutate button needs its ready TextLabel")
		local v6 = nil

		for _, label in ipairs(lockedOverlay:GetChildren()) do
			if label:IsA("TextLabel") and label.Text ~= "Mutate" then
				v6 = label
			end
		end

		assert(v6, "SakuraEggCharge Mutate.LockedOverlay needs its unlock TextLabel")
		local frames = {}

		for _, frame in ipairs(mutationList:GetChildren()) do
			if frame:IsA("Frame") and frame:FindFirstChild("MutationName") then
				table.insert(frames, frame)
			end
		end

		table.sort(frames, function(a, b)
			return a.AbsolutePosition.Y < b.AbsolutePosition.Y
		end)
		assert(#frames >= 2, "SakuraEggCharge MutationList needs two mutation rows")
		local imageColor3 = icon.ImageColor3
		local imageLabel3 = Instance.new("ImageLabel")
		imageLabel3.Name = "ClickIndicator"
		imageLabel3.Image = "rbxassetid://96606025304766"
		imageLabel3.BackgroundTransparency = 1
		imageLabel3.AnchorPoint = Vector2.new(0.5, 0.5)
		imageLabel3.Position = UDim2.fromScale(0.8, 0.8)
		imageLabel3.Size = UDim2.fromScale(0.45, 0.45)
		imageLabel3.ZIndex = icon.ZIndex + 2
		imageLabel3.Visible = false
		local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
		uIAspectRatioConstraint.Parent = imageLabel3
		local uIScale = Instance.new("UIScale")
		uIScale.Parent = imageLabel3
		imageLabel3.Parent = icon
		local tween = TweenService:Create(
			uIScale,
			TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, -1, true),
			{
				Scale = 1.3
			}
		)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setClickIndicator(visible: boolean)
			if imageLabel3.Visible == visible then
				return
			end

			imageLabel3.Visible = visible

			if not visible then
				tween:Cancel()
				return
			end

			uIScale.Scale = 1
			tween:Play()
		end

		local backgroundColor3 = mutate.BackgroundColor3
		local lerped = backgroundColor3:Lerp(Color3.new(0, 0, 0), 0.45)
		local backgroundColor32 = deposit.BackgroundColor3
		local lerped2 = backgroundColor32:Lerp(Color3.new(0, 0, 0), 0.45)
		local maid = Trove.new()
		local v7 = 1
		local v8 = false
		local flag = false
		local v9 = true
		local priceInRobuxesByProductId = {}

		-- equivalent calls inferred from this helper; original call sites unknown
		local function notifyError(text: string)
			Toast.Show({
				Text = text,
				Color = color,
				Seconds = 3
			})
		end

		local function getState()
			local v10 = Save.Await()

			if v10 == nil then
				return nil, 0
			end

			return v10.Sakura, v10.SakuraCrystals
		end

		local function isUnlocked()
			local isLoaded = Save.IsLoaded()
			local v10

			if isLoaded then
				v10 = Save.Peek()
			end

			return SakuraBloomPolicy.HasBloomUnlocked(isLoaded, v10)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getRarityNumber(assetCategory: string)
			local v10 = directory[assetCategory]
			assert(v10 ~= nil, (`Missing asset config {assetCategory}`))
			return v10.Rarity.Rank
		end

		local function getRequired(p)
			if p.Egg == false then
				return 0
			end

			return Sakura.GetRequiredCrystals()
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getDepositCapacity(p, p2: number)
			local v10 = p.Egg == false and 0 or Sakura.GetRequiredCrystals()

			if v10 <= 0 then
				return 0
			end

			return (math.max(0, (math.min(p2, Sakura.GetFreeChargeCap(v10) - p.Deposited))))
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getSliderAmount(sakura, sakuraCrystals: number)
			local depositCapacity = getDepositCapacity(sakura, sakuraCrystals) -- equivalent call inferred; original call site unknown

			if depositCapacity <= 0 then
				return 0
			end

			return (math.max(1, (math.floor(depositCapacity * v7 + 0.5))))
		end

		local numberSequence = NumberSequence.new(1)
		local numberSequence2 = NumberSequence.new(0)

		local function applyArcCut(uIGradient3, imageLabel4, point: Vector2, rotation: number)
			local absoluteSize = imageLabel4.AbsoluteSize
			local vector = Vector2.new(math.cos((math.rad(rotation))), (math.sin((math.rad(rotation)))))
			local v10 = absoluteSize.X * math.abs(vector.X) + absoluteSize.Y * math.abs(vector.Y)

			if v10 <= 0 then
				return
			end

			local v11 = 0.5 + (point - (imageLabel4.AbsolutePosition + absoluteSize / 2)):Dot(vector) / v10
			uIGradient3.Rotation = rotation

			if v11 <= 0.001 then
				uIGradient3.Transparency = numberSequence
			elseif v11 >= 1 then
				uIGradient3.Transparency = numberSequence2
			else
				uIGradient3.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(v11 - 0.001, 0),
					NumberSequenceKeypoint.new(v11, 1),
					NumberSequenceKeypoint.new(1, 1)
				})
			end
		end

		local function setArc(p: number)
			local v10 = math.clamp(p / Sakura.Incubator.MaxChargePercent, 0, 1)
			local v11 = 3.4173546754048973 - v10 * 3.693116697220001
			sliderButton2.Position = UDim2.fromScale(math.cos(v11) * 0.473 + 0.5, 0.7587 - math.sin(v11) * 0.7207)
			local absoluteSize = progressBar.AbsoluteSize
			local v12 = math.deg((math.atan2(
				0.7207 * absoluteSize.Y * math.sin(v11),
				0.473 * absoluteSize.X * math.cos(v11)
			)))

			if v12 < -90 then
				v12 += 360
			end

			local v13 = 90 - v12
			local v14 = progressBar.AbsolutePosition + Vector2.new(0.5 * absoluteSize.X, 0.7587 * absoluteSize.Y)

			if v10 <= 0 then
				uIGradient.Transparency = numberSequence
			else
				applyArcCut(uIGradient, imageLabel, v14, math.clamp(v13, -180, 0))
			end

			if v10 >= 1 then
				uIGradient2.Transparency = numberSequence2
			else
				applyArcCut(uIGradient2, imageLabel2, v14, math.clamp(v13, 0, 180))
			end
		end

		local numberValue = Instance.new("NumberValue")
		local v10 = nil
		numberValue.Changed:Connect(function(p: number)
			setArc(p)
			currentChargeLabel.Text = `{math.floor(p + 0.5)}%`
		end)

		local function showCharge(chargePercent: number, flag2: boolean)
			if v10 then
				v10:Cancel()
				v10 = nil
			end

			if flag2 or math.abs(numberValue.Value - chargePercent) < 0.01 then
				numberValue.Value = chargePercent
				setArc(chargePercent)
				currentChargeLabel.Text = `{math.floor(chargePercent + 0.5)}%`
			else
				local tween2 = TweenService:Create(
					numberValue,
					TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
					{
						Value = chargePercent
					}
				)
				v10 = tween2
				tween2:Play()
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setSlider(value: number)
			v7 = math.clamp(value, 0, 1)
			fill.Size = UDim2.fromScale(v7, 1)
			sliderButton.Position = UDim2.fromScale(v7, sliderButton.Position.Y.Scale)
		end

		local scheduleRender

		local function getProductPrice(p: string)
			local v11 = Products.Directory[p]
			local v12 = priceInRobuxesByProductId[v11.ProductId]

			if v12 then
				return v12
			end

			task.spawn(function()
				local success, productInfo = pcall(
					MarketplaceService.GetProductInfo,
					MarketplaceService,
					v11.ProductId,
					Enum.InfoType.Product
				)

				if success and productInfo and productInfo.PriceInRobux then
					priceInRobuxesByProductId[v11.ProductId] = productInfo.PriceInRobux
					scheduleRender()
				end
			end)
			return nil
		end

		local function renderEggIcon(sakura)
			local egg = sakura.Egg

			if egg == false then
				icon.Image = "rbxassetid://111633736515788"
				icon.ImageColor3 = imageColor3
				title.Visible = true
				setClickIndicator(true) -- equivalent call inferred; original call site unknown
			else
				local v11 = directory[egg.Egg.AssetCategory]
				assert(v11 ~= nil, (`Missing asset config {egg.Egg.AssetCategory}`))
				icon.Image = v11.Egg.Icon
				icon.ImageColor3 = Color3.new(1, 1, 1)
				title.Visible = false
				setClickIndicator(false) -- equivalent call inferred; original call site unknown
			end
		end

		local function renderMutationRows(chargePercent: number, luckBoost: number)
			local v11 = {
				{
					Name = Sakura.MutationName,
					Chance = Sakura.GetEffectiveMutationChance(chargePercent, luckBoost)
				},
				{
					Name = Sakura.SpecialMutationName,
					Chance = Sakura.GetSpecialChance(chargePercent, luckBoost)
				}
			}

			for i, v12 in ipairs(v11) do
				local v13 = frames[i]
				local mutationName = v13.MutationName
				local chanceLabel = v13.ChanceLabel
				assert(
					mutationName:IsA("TextLabel") and chanceLabel:IsA("TextLabel"),
					"Mutation row needs MutationName and ChanceLabel"
				)
				local v14 = Mutations.Get(v12.Name)
				mutationName.Text = Mutations.LabelOf(v12.Name)

				if v14 then
					mutationName.TextColor3 = v14.Tint
				end

				chanceLabel.Text = string.format("%.1f%%", v12.Chance):gsub("%.0%%", "%%")
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function renderCost()
			local formatted = `Mutation Cost: <font color="#FF69B4">{Simple.FormatCompact(Sakura.GetRequiredCrystals())} crystals</font>`

			if costLabel then
				costLabel.Text = formatted
			end
		end

		local function render()
			local v11 = Save.Await()
			local sakura, sakuraCrystals

			if v11 == nil then
				sakuraCrystals = 0
			else
				sakura = v11.Sakura
				sakuraCrystals = v11.SakuraCrystals
			end

			if sakura == nil then
				return
			end

			local egg = sakura.Egg
			local v12 = sakura.Egg == false and 0 or Sakura.GetRequiredCrystals()
			local chargePercent = Sakura.GetChargePercent(sakura.Deposited, v12)
			local visible = egg ~= false
			local v14 = chargePercent >= 100
			local depositCapacity = getDepositCapacity(sakura, sakuraCrystals) -- equivalent call inferred; original call site unknown
			local v15 = visible and sakura.Deposited >= Sakura.GetFreeChargeCap(v12)
			renderEggIcon(sakura)
			showCharge(chargePercent, v9)
			v9 = false

			if crystalBalance then
				crystalBalance.Text = `You have <font color="#FF69B4">{Simple.FormatCompact(sakuraCrystals)}</font> crystals`
			end

			if removeEgg then
				removeEgg.Visible = visible
			end

			renderCost() -- equivalent call inferred; original call site unknown
			renderMutationRows(chargePercent, sakura.LuckBoost)
			local sliderAmount = getSliderAmount(sakura, sakuraCrystals) -- equivalent call inferred; original call site unknown
			sliderBar.Visible = visible and depositCapacity > 0

			if visible and sliderAmount > 0 then
				deposit.Active = true
				deposit.BackgroundColor3 = backgroundColor32
				v4.Text = `Deposit {Simple.FormatCompact(sliderAmount)}`
				v5.Text = `+{math.floor(sliderAmount / v12 * 100 + 0.5)}% Charge`
			elseif visible then
				deposit.Active = false
				deposit.BackgroundColor3 = lerped2
				v4.Text = v15 and "Fully Charged" or "No Crystals"
				v5.Text = ""
			else
				deposit.Active = true
				deposit.BackgroundColor3 = backgroundColor32
				v4.Text = "Place Egg"
				v5.Text = "Choose an egg to mutate"
			end

			mutate.Active = v14
			local mutate2 = mutate
			local backgroundColor

			if v14 then
				backgroundColor = backgroundColor3
			else
				backgroundColor = lerped
			end

			mutate2.BackgroundColor3 = backgroundColor
			lockedOverlay.Visible = not v14
			textLabel2.Visible = v14
			v6.Text = "(Unlocks at 100%)"
			local maxLuckBoosts = Sakura.Incubator.MaxLuckBoosts
			buyLuck.Visible = visible and sakura.LuckBoost < maxLuckBoosts
			textLabel.Text = `<font color="#FF69B4">{Sakura.GetLuckMultiplier(sakura.LuckBoost + 1)}x</font> Great Bloom Odds ({sakura.LuckBoost}/{maxLuckBoosts})`
			local luckBoostProductName = Sakura.Incubator.LuckBoostProductNames[sakura.LuckBoost + 1]
			local v18

			if luckBoostProductName then
				local v19 = Products.Directory[luckBoostProductName]
				v18 = priceInRobuxesByProductId[v19.ProductId]

				if not v18 then
					task.spawn(function()
						local success, productInfo = pcall(
							MarketplaceService.GetProductInfo,
							MarketplaceService,
							v19.ProductId,
							Enum.InfoType.Product
						)

						if success and productInfo and productInfo.PriceInRobux then
							priceInRobuxesByProductId[v19.ProductId] = productInfo.PriceInRobux
							scheduleRender()
						end
					end)
					v18 = nil
				end
			end

			price.Text = not v18 and "" or `{v}{v18}`
		end

		scheduleRender = function()
			if flag then
				return
			end

			flag = true
			task.defer(function()
				flag = false
				render()
			end)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function closePicker()
			maid:Clean()
			eggPicker.Visible = false
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function requestInsert(p: string)
			tryLock(function()
				local v11, v12 = Remotes.Bloomery.AskLoadEgg:InvokeServer(p)

				if v11 then
					closePicker() -- equivalent call inferred; original call site unknown
					v7 = 1
					fill.Size = UDim2.fromScale(v7, 1)
					sliderButton.Position = UDim2.fromScale(v7, sliderButton.Position.Y.Scale)
					scheduleRender()
				else
					notifyError(typeof(v12) ~= "string" and "Failed to place egg" or v12) -- equivalent call inferred; original call site unknown
				end
			end)
		end

		local function buildPickerRow(p: string, p2, layoutOrder: number)
			local decoded = EggRecords.Decode(p2)
			local v11 = directory[decoded.AssetCategory]
			assert(v11 ~= nil, (`Missing asset config {decoded.AssetCategory}`))
			local clone = inventoryTemplate:Clone()
			clone.Name = `SakuraEgg.{p}`
			clone.LayoutOrder = layoutOrder
			clone.Active = true
			clone.AutoButtonColor = false
			clone.BackgroundColor3 = Color3.new(0, 0, 0)
			clone.BackgroundTransparency = 0.5
			clone.Visible = true
			local uIStroke = clone:FindFirstChild("UIStroke")

			if uIStroke and uIStroke:IsA("UIStroke") then
				uIStroke.Thickness = 0
			end

			local icon2 = clone.Icon
			assert(icon2:IsA("ImageLabel"), "Inventory row Icon must be an ImageLabel")
			icon2.Image = v11.Egg.Icon
			icon2.ImageColor3 = Color3.new(1, 1, 1)
			local toolName = clone.ToolName
			assert(toolName:IsA("TextLabel"), "Inventory row ToolName must be a TextLabel")

			for _, uIGradient3 in ipairs(toolName:GetChildren()) do
				if uIGradient3:IsA("UIGradient") then
					uIGradient3:Destroy()
				end
			end

			local clone_2 = v11.Rarity.RarityGradient:Clone()
			clone_2.Parent = toolName
			toolName.Text = EggRecords.DisplayNameWithWeight(decoded)
			toolName.Visible = true

			for _, childName in ipairs({
				"FavIcon",
				"Weight",
				"Shadow",
				"Shadow_2"
			}) do
				local guiObject = clone:FindFirstChild(childName)

				if guiObject and guiObject:IsA("GuiObject") then
					guiObject.Visible = false
				end
			end

			local baseTemplate = clone:FindFirstChild("BaseTemplate")

			if baseTemplate then
				for _, guiObject in ipairs(baseTemplate:GetChildren()) do
					if guiObject:IsA("GuiObject") then
						guiObject.Visible = false
					end
				end
			end

			clone.Parent = eggs
			maid:Add(clone)
			maid:Add(clone.Activated:Connect(function()
				requestInsert(p) -- equivalent call inferred; original call site unknown
			end))
			ButtonFX(clone)
		end

		local function openPicker()
			local v11 = Save.Await()
			local v12 = Save.Await()
			local sakura

			if v12 ~= nil then
				sakura = v12.Sakura
				local _ = v12.SakuraCrystals
			end

			if v11 == nil or sakura == nil then
				return
			end

			if not sakura.Unlocked then
				notifyError("The Sakura Incubator is still sealed") -- equivalent call inferred; original call site unknown
				return
			end

			if sakura.Egg ~= false then
				return
			end

			maid:Clean()
			local v13 = {}

			for k, v14 in pairs(v11.EggInventory) do
				if v14.Placement ~= nil or Sakura.HasSakuraMutation(v14.Mutations) then
					continue
				end

				table.insert(v13, k)
			end

			if #v13 == 0 then
				local count = 0

				for _, v14 in pairs(v11.EggInventory) do
					if v14.Placement ~= nil then
						count += 1
					end
				end

				if count > 0 then
					notifyError("All your eggs are placed - pick one up from your pen first!") -- equivalent call inferred; original call site unknown
				else
					notifyError("You have no eggs to mutate - steal or hatch one first!") -- equivalent call inferred; original call site unknown
				end
			else
				table.sort(v13, function(a, b)
					local rarityNumber = getRarityNumber(v11.EggInventory[a].AssetCategory) -- equivalent call inferred; original call site unknown
					local rarityNumber2 = getRarityNumber(v11.EggInventory[b].AssetCategory) -- equivalent call inferred; original call site unknown

					if rarityNumber == rarityNumber2 then
						return a < b
					end

					return rarityNumber2 < rarityNumber
				end)

				for i, v14 in ipairs(v13) do
					buildPickerRow(v14, v11.EggInventory[v14], i)
				end

				eggs.CanvasPosition = Vector2.zero
				eggPicker.Visible = true
			end
		end

		local function playDepositFlyIn()
			local eggIconHolder2 = eggIconHolder

			for i = 1, 6 do
				task.delay((i - 1) * 0.05, function()
					local imageLabel4 = Instance.new("ImageLabel")
					imageLabel4.BackgroundTransparency = 1
					imageLabel4.Image = "rbxassetid://71612969542341"
					imageLabel4.AnchorPoint = Vector2.new(0.5, 0.5)
					imageLabel4.Size = UDim2.fromScale(0.05, 0.08)
					imageLabel4.Position = UDim2.fromScale(
						deposit.Position.X.Scale + (math.random() - 0.5) * 0.1,
						deposit.Position.Y.Scale
					)
					imageLabel4.ZIndex = 20
					imageLabel4.Parent = content
					local tween2 = TweenService:Create(
						imageLabel4,
						TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
						{
							Position = UDim2.fromScale(eggIconHolder2.Position.X.Scale, eggIconHolder2.Position.Y.Scale),
							Size = UDim2.fromScale(0.02, 0.03)
						}
					)
					tween2.Completed:Once(function()
						imageLabel4:Destroy()
					end)
					tween2:Play()
				end)
			end

			task.wait(0.75)
		end

		local function requestDeposit()
			local v11 = Save.Await()
			local sakura

			if v11 ~= nil then
				sakura = v11.Sakura
				local _ = v11.SakuraCrystals
			end

			if sakura == nil or sakura.Egg ~= false then
				tryLock(function()
					local v12 = Save.Await()
					local sakura2, sakuraCrystals

					if v12 == nil then
						sakuraCrystals = 0
					else
						sakura2 = v12.Sakura
						sakuraCrystals = v12.SakuraCrystals
					end

					if sakura2 == nil or sakura2.Egg == false then
						return
					end

					local sliderAmount = getSliderAmount(sakura2, sakuraCrystals) -- equivalent call inferred; original call site unknown

					if sliderAmount <= 0 then
						notifyError("You have no Sakura Crystals to deposit") -- equivalent call inferred; original call site unknown
						return
					end

					playDepositFlyIn()
					local v13, v14 = Remotes.Bloomery.AskHandoff:InvokeServer(sliderAmount)

					if v13 then
						scheduleRender()
						return
					end

					notifyError(typeof(v14) ~= "string" and "Failed to deposit" or v14) -- equivalent call inferred; original call site unknown
				end)
			else
				openPicker()
			end
		end

		local function requestRemove()
			local v11 = Save.Await()
			local sakura

			if v11 ~= nil then
				sakura = v11.Sakura
				local _ = v11.SakuraCrystals
			end

			if sakura == nil or sakura.Egg == false or (sakura.Deposited > 0 or sakura.LuckBoost > 0) and not Message.Confirm("Remove this egg? Its charge and luck will be lost.") then
				return
			end

			tryLock(function()
				local v12, v13 = Remotes.Bloomery.AskEjectEgg:InvokeServer()

				if v12 then
					scheduleRender()
					return
				end

				notifyError(typeof(v13) ~= "string" and "Failed to remove egg" or v13) -- equivalent call inferred; original call site unknown
			end)
		end

		local function requestMutate()
			tryLock(function()
				local v11, v12, v13 = Remotes.Bloomery.AskMutate:InvokeServer()

				if v11 then
					if not Sakura2.MutateResult(v13) then
						v2:AtError():Log("Sakura mutate returned an invalid result")
						return
					end

					SakuraSignals.Reveal:Fire(v13)
					scheduleRender()
				else
					notifyError(typeof(v12) ~= "string" and "Failed to mutate" or v12) -- equivalent call inferred; original call site unknown
				end
			end)
		end

		local function requestLuck()
			local v11 = Save.Await()
			local v12 = v11 and Sakura.Incubator.LuckBoostProductNames[v11.Sakura.LuckBoost + 1]

			if not v12 then
				return
			end

			Storefront.Prompt(Products.Directory[v12].ProductId, true)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateSliderFromInput(vector: Vector2)
			local X = sliderBar.AbsolutePosition.X
			local X2 = sliderBar.AbsoluteSize.X

			if X2 <= 0 then
				return
			end

			setSlider((vector.X - X) / X2) -- equivalent call inferred; original call site unknown
			render()
		end

		eggPicker.Visible = false
		v7 = 1
		fill.Size = UDim2.fromScale(v7, 1)
		sliderButton.Position = UDim2.fromScale(v7, sliderButton.Position.Y.Scale)
		GUI.OnActivated(deposit, requestDeposit)
		ButtonFX(deposit)
		GUI.OnActivated(mutate, requestMutate)
		ButtonFX(mutate)

		if removeEgg then
			removeEgg.Visible = false
			GUI.OnActivated(removeEgg, requestRemove)
			ButtonFX(removeEgg)
		end

		GUI.OnActivated(buyLuck, requestLuck)
		ButtonFX(buyLuck)
		icon.Active = true
		icon.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				openPicker()
			end
		end)
		sliderButton.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				v8 = true
			end
		end)
		sliderBar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				v8 = true
				updateSliderFromInput(Vector2.new(input.Position.X, input.Position.Y)) -- equivalent call inferred; original call site unknown
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if not v8 then
				return
			end

			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				updateSliderFromInput(Vector2.new(input.Position.X, input.Position.Y)) -- equivalent call inferred; original call site unknown
			end
		end)
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				v8 = false
			end
		end)
		Save.WatchFields({ "Sakura", "SakuraCrystals", "EggInventory" }, function()
			if Tabs.IsActive("SakuraEggCharge") then
				local isLoaded = Save.IsLoaded()
				local v11

				if isLoaded then
					v11 = Save.Peek()
				end

				if SakuraBloomPolicy.HasBloomUnlocked(isLoaded, v11) then
					scheduleRender()
				else
					Tabs.Deactivate({
						instant = true
					})
				end
			end
		end)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function bindGamepadSlider()
			ContextActionService:BindActionAtPriority("SakuraDepositSlider", function(_, p, p2)
				if p ~= Enum.UserInputState.Begin then
					return Enum.ContextActionResult.Pass
				end

				local v11 = p2.KeyCode == Enum.KeyCode.ButtonR1 and 0.1 or -0.1
				v7 = math.clamp(v7 + v11, 0, 1)
				fill.Size = UDim2.fromScale(v7, 1)
				sliderButton.Position = UDim2.fromScale(v7, sliderButton.Position.Y.Scale)
				render()
				return Enum.ContextActionResult.Sink
			end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.ButtonL1, Enum.KeyCode.ButtonR1)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function unbindGamepadSlider()
			ContextActionService:UnbindAction("SakuraDepositSlider")
		end

		if help then
			GUI.OnActivated(help, function()
				local isLoaded = Save.IsLoaded()
				local v11

				if isLoaded then
					v11 = Save.Peek()
				end

				if not SakuraBloomPolicy.HasBloomUnlocked(isLoaded, v11) then
					return
				end

				Tabs.Deactivate({
					instant = true
				})
				SakuraSignals.ShowTutorial:Fire()
			end)
			ButtonFX(help)
		end

		Tabs.Activated:Connect(function(p: string)
			if p == "SakuraEggCharge" then
				local isLoaded = Save.IsLoaded()
				local v11

				if isLoaded then
					v11 = Save.Peek()
				end

				if not SakuraBloomPolicy.HasBloomUnlocked(isLoaded, v11) then
					Tabs.Deactivate({
						instant = true
					})
					return
				end

				local v12 = Save.Await()

				if Players.LocalPlayer:GetAttribute("SakuraTutorialSkip") or v12 == nil or v12.Sakura.TutorialSeen then
					v7 = 1
					fill.Size = UDim2.fromScale(v7, 1)
					sliderButton.Position = UDim2.fromScale(v7, sliderButton.Position.Y.Scale)
					v9 = true
					scheduleRender()
					bindGamepadSlider() -- equivalent call inferred; original call site unknown

					if PlatformController.IsConsole() then
						ButtonHintStrip.Present("SakuraDepositSlider", Enum.KeyCode.ButtonR1, "Deposit Amount")
					end
				else
					Tabs.Deactivate({
						instant = true
					})
					SakuraSignals.ShowTutorial:Fire()
				end
			end
		end)
		Tabs.Deactivated:Connect(function(p: string?)
			if p == "SakuraEggCharge" then
				closePicker() -- equivalent call inferred; original call site unknown
				unbindGamepadSlider() -- equivalent call inferred; original call site unknown
				ButtonHintStrip.Retract("SakuraDepositSlider")
			end
		end)
		render()
	end
}