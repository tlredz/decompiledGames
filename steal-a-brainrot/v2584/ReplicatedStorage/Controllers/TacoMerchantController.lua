local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AnimatedButton = require(ReplicatedStorage.Classes.AnimatedButton)
local ConfirmationController = require(ReplicatedStorage.Controllers.ConfirmationController)
local InterfaceController = require(ReplicatedStorage.Controllers.InterfaceController)
local ShopController = require(ReplicatedStorage.Controllers.ShopController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local TacoDropController = require(ReplicatedStorage.Controllers.TacoDropController)
local TacoMerchantData = require(ReplicatedStorage.Datas.TacoMerchantData)
local Animals = require(ReplicatedStorage.Shared.Animals)
local TacoMerchantFlags = require(ReplicatedStorage.Shared.Flags.TacoMerchantFlags)
local Net = require(ReplicatedStorage.Packages.Net)
local Observers = require(ReplicatedStorage.Packages.Observers)
local ReplicatorClient = require(ReplicatedStorage.Packages.ReplicatorClient)
local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)
local Trove = require(ReplicatedStorage.Packages.Trove)
local NumberUtils = require(ReplicatedStorage.Utils.NumberUtils)
local remoteFunction = Net:RemoteFunction("TacoMerchantService/Buy")
local remoteFunction2 = Net:RemoteFunction("TacoMerchantService/Deposit")
local remoteFunction3 = Net:RemoteFunction("TacoMerchantService/GetDepositQuote")
local remoteEvent = Net:RemoteEvent("ShopService/Purchase")
local remoteEvent2 = Net:RemoteEvent("TacoMerchantService/Animation")
local tacoMerchantStock = ReplicatorClient.get("TacoMerchantStock")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
return {
	Start = function(self)
		TacoDropController:Start()
		local tacoMerchant = playerGui:FindFirstChild("TacoMerchant")
		local tacoMerchant2 = tacoMerchant and tacoMerchant:FindFirstChild("TacoMerchant")
		local close = tacoMerchant2 and tacoMerchant2:FindFirstChild("Close")
		local products = tacoMerchant2 and tacoMerchant2:FindFirstChild("Products")
		local title = tacoMerchant2 and tacoMerchant2:FindFirstChild("Title")

		if not (tacoMerchant2 and tacoMerchant2:IsA("Frame") and close and close:IsA("GuiButton") and products and products:IsA("Frame") and title and title:IsA("TextLabel")) then
			warn("Taco Merchant interface is incomplete")
			return
		end

		tacoMerchant2.Visible = false
		local v = InterfaceController:Register("TacoMerchant", tacoMerchant2, "TopQuint")
		v:AttachCloseButton(close)
		v:Close()

		for k, brainrot in TacoMerchantData.Brainrots do
			local guiObject = products:FindFirstChild((`Brainrot{k}`))
			assert(guiObject and guiObject:IsA("GuiObject"), (`Missing Taco Merchant card {k}`))
			local name = guiObject:FindFirstChild("Name")
			local moneySecond = guiObject:FindFirstChild("MoneySecond")
			local stock = guiObject:FindFirstChild("Stock")
			local viewportFrame = guiObject:FindFirstChild("ViewportFrame")
			local buyYellow = guiObject:FindFirstChild("BuyYellow")
			local buy = guiObject:FindFirstChild("Buy")
			assert(name and name:IsA("TextLabel"), (`Missing Taco Merchant name {k}`))
			assert(moneySecond and moneySecond:IsA("TextLabel"), (`Missing Taco Merchant generation {k}`))
			assert(stock and stock:IsA("TextLabel"), (`Missing Taco Merchant stock {k}`))
			assert(viewportFrame and viewportFrame:IsA("ViewportFrame"), (`Missing Taco Merchant viewport {k}`))
			assert(buyYellow and buyYellow:IsA("GuiButton"), (`Missing Taco Merchant Taco button {k}`))
			assert(buy and buy:IsA("GuiButton"), (`Missing Taco Merchant Robux button {k}`))
			name.Text = brainrot.Brainrot
			Animals:AttachOnViewportWithOptimizations(brainrot.Brainrot, viewportFrame)
			moneySecond.Text = not (Animals:GetGeneration(brainrot.Brainrot) > 0) and "" or `${NumberUtils:ToString(Animals:GetGeneration(brainrot.Brainrot))}/s`
			local price = buyYellow:FindFirstChild("Price")
			assert(price and price:IsA("TextLabel"), (`Missing Taco Merchant Taco price {k}`))
			-- equivalent calls inferred from this helper; original call sites unknown
			local v2 = brainrot

			local function updateTacoPrice()
				local v5 = TacoMerchantFlags.TacoPrices:Get()[v2.Brainrot] or v2.TacoPrice
				price.Text = not (v5 > 0) and "???" or `<image id="89041930759464"><font scale="0.8">{NumberUtils:ToString(v5)}</font>`
				buyYellow.Interactable = v5 > 0
				buyYellow.AutoButtonColor = v5 > 0
			end

			updateTacoPrice() -- equivalent call inferred; original call site unknown
			TacoMerchantFlags.TacoPrices.Changed:Connect(updateTacoPrice)
			local v5 = AnimatedButton.new(buyYellow)
			v5:Animate()
			local v6 = k
			v5.OnActivated:Connect(function()
				if remoteFunction:InvokeServer(v6) then
					SoundController:PlaySound("Sounds.Sfx.Success")
					InterfaceController:SetState("TacoMerchant", false)
				end
			end)
			local price2 = buy:FindFirstChild("Price")
			assert(price2 and price2:IsA("TextLabel"), (`Missing Taco Merchant Robux price {k}`))

			if brainrot.ProductId > 0 then
				ShopController:BindLabelToProductPrice(price2, brainrot.ProductId)
				local v7 = AnimatedButton.new(buy)
				v7:Animate()
				local v8 = brainrot
				v7.OnActivated:Connect(function()
					remoteEvent:FireServer(v8.ProductId)
				end)
			else
				price2.Text = " ???"
				buy.Interactable = false
				buy.AutoButtonColor = false
			end

			local v7 = brainrot

			local function updateStock()
				local v9 = tacoMerchantStock:TryIndex({ "stock", v7.Brainrot }) or 0
				stock.RichText = true
				stock.Text = not (v9 > 0) and "SOLD OUT" or `{NumberUtils:Comma(v9)} <font color="rgb(255,127,0)">left</font>`
				local v10 = stock
				local textColor

				if v9 > 0 then
					textColor = Color3.fromRGB(255, 255, 255)
				else
					textColor = Color3.fromRGB(255, 72, 72)
				end

				v10.TextColor3 = textColor
			end

			updateStock()
			tacoMerchantStock:Listen({ "stock", brainrot.Brainrot }, updateStock)
		end

		ReplicatedStorage:GetAttributeChangedSignal("TacoMerchantEvent"):Connect(function()
			if ReplicatedStorage:GetAttribute("TacoMerchantEvent") ~= true then
				InterfaceController:SetState("TacoMerchant", false)
			end
		end)
		remoteEvent2.OnClientEvent:Connect(function(_: string, _: string)
			local events = workspace:FindFirstChild("Events")
			local tacoMerchant3 = events and events:FindFirstChild("Taco Merchant")
			local tacoMerchantModel = tacoMerchant3 and tacoMerchant3:FindFirstChild("Model")
			local spawnVFX = tacoMerchantModel and tacoMerchantModel:FindFirstChild("SpawnVFX")

			if not (spawnVFX and spawnVFX:IsA("BasePart")) then
				return
			end

			local tacoMerchantSFX = ReplicatedStorage.Sounds.Sfx:FindFirstChild("TacoMerchantSFX")

			if tacoMerchantSFX then
				SoundController:PlaySound(tacoMerchantSFX, spawnVFX.Position, false)
			end
		end)
		Observers.observeTag("TacoMerchantPrompt", function(p)
			local maid = Trove.new()

			-- equivalent calls inferred from this helper; original call sites unknown
			local function updatePrompt()
				p.ActionText = "View Offers"
				p.ObjectText = "Taco Merchant"
				p.Enabled = ReplicatedStorage:GetAttribute("TacoMerchantEvent") == true
			end

			updatePrompt() -- equivalent call inferred; original call site unknown
			maid:Add(p.Triggered:Connect(function()
				if ReplicatedStorage:GetAttribute("TacoMerchantEvent") == true and Synchronizer:Get(localPlayer) then
					InterfaceController:Toggle("TacoMerchant")
				end
			end))
			maid:Add(ReplicatedStorage:GetAttributeChangedSignal("TacoMerchantEvent"):Connect(updatePrompt))
			return maid:WrapClean()
		end)
		local v2 = false
		Observers.observeTag("TacoMerchant", function(instance)
			local maid = Trove.new()
			local deliveryHitbox = instance:FindFirstChild("DeliveryHitbox")

			if deliveryHitbox and deliveryHitbox:IsA("BasePart") then
				maid:Add(deliveryHitbox.Touched:Connect(function(otherPart)
					if otherPart.Name ~= "HumanoidRootPart" or v2 or ConfirmationController:IsInPrompt() then
						return
					end

					local playerFromCharacter = Players:GetPlayerFromCharacter(otherPart.Parent)
					local stealingIndex = playerFromCharacter and playerFromCharacter:GetAttribute("StealingIndex")

					if playerFromCharacter ~= localPlayer or typeof(stealingIndex) ~= "string" or ReplicatedStorage:GetAttribute("TacoMerchantEvent") ~= true then
						return
					end

					v2 = true
					local success, result = pcall(remoteFunction3.InvokeServer, remoteFunction3, deliveryHitbox)

					if success then
						if typeof(result) ~= "table" or typeof(result.Brainrot) ~= "string" or typeof(result.Reward) ~= "number" then
							v2 = false
							return
						end

						local v3 = result.Reward == 1 and "Taco" or "Tacos"
						local formatted = `<font color="#FFDE59">{result.Reward} {v3}</font>`

						if ConfirmationController:Show(
							`Are you sure you want to sell {result.Brainrot} for <image id="89041930759464"> {formatted}?`,
							nil,
							"TacoMerchantTemplate"
						) then
							local success2, result2 = pcall(
								remoteFunction2.InvokeServer,
								remoteFunction2,
								deliveryHitbox,
								result.Brainrot
							)

							if success2 then
								if result2 then
									SoundController:PlaySound(ReplicatedStorage.Sounds.Sfx["Fuse Machine"].Deposit)
								end
							else
								warn(result2)
							end
						end

						v2 = false
					else
						warn(result)
						v2 = false
					end
				end))
				return maid:WrapClean()
			end

			warn("TacoMerchant is missing DeliveryHitbox")
			return maid:WrapClean()
		end)
	end
}