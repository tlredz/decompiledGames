local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ContentProvider")
game:GetService("ServerStorage")
game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
game:GetService("HttpService")
game:GetService("RunService")
game:GetService("StarterGui")
local Players = game:GetService("Players")
require(ReplicatedStorage.Packages.Serialization)
local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)
require(ReplicatedStorage.Packages.CreateTween)
require(ReplicatedStorage.Packages.TopbarPlus)
local Gradients = require(ReplicatedStorage.Packages.Gradients)
local Observers = require(ReplicatedStorage.Packages.Observers)
require(ReplicatedStorage.Shared.Mutations)
local FFlags = require(ReplicatedStorage.Packages.FFlags)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Timer = require(ReplicatedStorage.Packages.Timer)
local Trove = require(ReplicatedStorage.Packages.Trove)
require(ReplicatedStorage.Packages.Spr)
local Net = require(ReplicatedStorage.Packages.Net)
local ReplicatorClient = require(ReplicatedStorage.Packages.ReplicatorClient)
local Marketplace = require(ReplicatedStorage.Shared.Marketplace)
local santaMerchantStock = ReplicatorClient.get("SantaMerchantStock")
local NotificationController = require(ReplicatedStorage.Controllers.NotificationController)
require(ReplicatedStorage.Controllers.NewPlayersController)
local InterfaceController = require(ReplicatedStorage.Controllers.InterfaceController)
require(ReplicatedStorage.Controllers.CharacterController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
require(ReplicatedStorage.Controllers.PlotController)
local ShopController = require(ReplicatedStorage.Controllers.ShopController)
local NumberUtils = require(ReplicatedStorage.Utils.NumberUtils)
local TimeUtils = require(ReplicatedStorage.Utils.TimeUtils)
require(ReplicatedStorage.Utils.MathUtils)
local VFX = require(ReplicatedStorage.Shared.VFX)
local AnimatedButton = require(ReplicatedStorage.Classes.AnimatedButton)
require(ReplicatedStorage.Shared.Updates)
require(ReplicatedStorage.Shared.Animals)
local Animals = require(ReplicatedStorage.Shared.Animals)
require(ReplicatedStorage.Shared.Index)
require(ReplicatedStorage.Datas.Mutations)
local Rarities = require(ReplicatedStorage.Datas.Rarities)
local Animals2 = require(ReplicatedStorage.Datas.Animals)
local SantaMerchantData = require(ReplicatedStorage.Datas.SantaMerchantData)
local localPlayer = Players.LocalPlayer
local santaMerchant = localPlayer.PlayerGui:WaitForChild("SantaMerchant").SantaMerchant
local brainrots = santaMerchant.Brainrots
local close = santaMerchant.Header.Close
local giftPlayerSelect = santaMerchant.GiftPlayerSelect
local giftButton = giftPlayerSelect:WaitForChild("GiftButton")
local txt = giftButton:WaitForChild("Txt")
local playerSelected = giftPlayerSelect:WaitForChild("PlayerSelected")
local headshot = playerSelected:WaitForChild("PlayerImage"):WaitForChild("Headshot")
local playerName = playerSelected:WaitForChild("PlayerName")
local remoteEvent = Net:RemoteEvent("SantaMerchantService/CollectGoldElf")
local remoteEvent2 = Net:RemoteEvent("SantaMerchantService/SetFocused")
local remoteEvent3 = Net:RemoteEvent("SantaMerchantService/Animation")
local remoteFunction = Net:RemoteFunction("SantaMerchantService/Buy")
local remoteEvent4 = Net:RemoteEvent("ShopService/Purchase")
local v = nil

local function loadAnimation(animator, animation, maid)
	local track = animator:LoadAnimation(animation)
	maid:Add(function()
		track:Stop(0)
		track:Destroy()
	end)
	return track
end

return {
	Start = function(_)
		santaMerchant.Visible = false
		v = InterfaceController:Register("SantaMerchant", santaMerchant, "TopQuint")
		v:AttachCloseButton(close)
		v.OnOpen:Connect(function()
			remoteEvent2:FireServer("3b343fd9-437f-4be1-8988-9ce65d875909", true)
		end)
		v.OnClose:Connect(function()
			remoteEvent2:FireServer("3b343fd9-437f-4be1-8988-9ce65d875909", false)
		end)
		v:Close()

		local function renderBrainrotAtFrame(state, brainrot)
			local animal = Animals2[brainrot]

			if not animal then
				return
			end

			local rarity = Rarities[animal.Rarity]
			state.Title.Text = Animals:GetDisplayName(brainrot)

			if rarity.GradientPreset then
				state.Title.TextColor3 = Color3.new(1, 1, 1)
				Gradients.apply(state.Title, rarity.GradientPreset)
			else
				state.Title.TextColor3 = rarity.Color
			end

			state.Visible = true
			Animals:AttachOnViewportWithOptimizations(brainrot, state.ViewportFrame)
		end

		local v2 = table.create(#SantaMerchantData.Brainrots)
		local v3 = Signal.new()

		for k, brainrot in SantaMerchantData.Brainrots do
			local brainrot2 = brainrot.Brainrot
			local _ = Animals2[brainrot2]
			local v4 = brainrots:FindFirstChild((tostring(k))) or brainrots.UIGridLayout.Template:Clone()
			v2[k] = v4
			v4.Visible = true
			v4.LayoutOrder = k
			renderBrainrotAtFrame(v4, brainrot2)

			local function updateStock()
				local v7 = santaMerchantStock:TryIndex({ "stock", brainrot2 }) or 0
				v4.Quantity.Text = not (v7 > 0) and "SOLD OUT" or `{NumberUtils:Comma(v7)} Left`
				local quantity = v4.Quantity
				local textColor

				if v7 > 0 then
					textColor = Color3.fromRGB(255, 255, 255)
				else
					textColor = Color3.fromRGB(255, 72, 72)
				end

				quantity.TextColor3 = textColor
			end

			updateStock()
			v3:Connect(updateStock)
			santaMerchantStock:Listen({ "stock", brainrot2 }, updateStock)
			v4.DropRate.Text = `${NumberUtils:ToString(Animals:GetGeneration(brainrot2))}/s`
			v4.BuyYellow.Price.Text = NumberUtils:ToString(brainrot.Price or 0)

			if brainrot.ProductId then
				v4.Buy.Price.Text = "???"
				local v7 = brainrot
				local v8 = v4
				task.spawn(function()
					-- equivalent calls inferred from this helper; original call sites unknown
					local function formatPriceInRobux(p)
						if p == 999999999 then
							return "???"
						end

						return (NumberUtils:Comma(p))
					end

					local productInfo = Marketplace:GetProductInfo(v7.ProductId, "Product")
					local price = v8.Buy.Price
					local priceInRobux = productInfo.PriceInRobux or 999999999
					price.Text = ("%*"):format(formatPriceInRobux(priceInRobux))
				end)
			end

			v4.Parent = brainrots
			local v7 = AnimatedButton.new(v4.BuyYellow)
			v7:Animate()
			local v8 = k
			v7.OnActivated:Connect(function()
				if remoteFunction:InvokeServer("c103bb01-2db1-41db-8c97-809b965dbfcd", v8) then
					SoundController:PlaySound("Sounds.Sfx.Success")
					InterfaceController:SetState("SantaMerchant", false)
				end
			end)

			if not brainrot.ProductId then
				continue
			end

			local v9 = AnimatedButton.new(v4.Buy)
			v9:Animate()
			local v10 = brainrot
			v9.OnActivated:Connect(function()
				remoteEvent4:FireServer(v10.ProductId, ShopController:GetGiftingTarget())
			end)
		end

		local function updateGiftInfo()
			local giftingTarget = ShopController:GetGiftingTarget()

			if giftingTarget then
				local playerByUserId = Players:GetPlayerByUserId(giftingTarget)
				txt.Text = "Back"
				playerSelected.Visible = true
				local v4 = playerName
				local text

				if playerByUserId then
					text = "@" .. playerByUserId.Name or giftingTarget
				else
					text = giftingTarget
				end

				v4.Text = text
				headshot.Image = `rbxthumb://type=AvatarHeadShot&id={giftingTarget}&w=100&h=100`

				for _, v6 in v2 do
					v6.BuyYellow.Visible = false
				end
			else
				playerSelected.Visible = false
				txt.Text = "Gift Player"

				for _, v4 in v2 do
					v4.BuyYellow.Visible = true
				end
			end
		end

		ShopController.ToggleGiftSignal:Connect(updateGiftInfo)
		task.spawn(updateGiftInfo)
		local v4 = AnimatedButton.new(giftButton)
		v4:Animate()
		v4.OnActivated:Connect(function()
			if ShopController:GetGiftingTarget() then
				ShopController:RemoveGiftingTarget()
			else
				ShopController:OpenGiftingScreen()
			end
		end)
		v.OnClose:Connect(function()
			if ShopController:GetGiftingTarget() then
				ShopController:RemoveGiftingTarget()
			end
		end)
		local santaMerchantStockId = ReplicatedStorage:GetAttribute("SantaMerchantStockId")
		Timer.Simple(1, function()
			local v5 = workspace:GetServerTimeNow() + (ReplicatedStorage:GetAttribute("__timeSkipDebugSantaMerchant") or 0)
			local santaMerchantNextStockId = tonumber(ReplicatedStorage:GetAttribute("SantaMerchantNextStockId"))
			local text

			if santaMerchantNextStockId then
				local instant = FFlags:GetInstant("SantaMerchantService/LeavingTimestamp", 1766790000)

				if santaMerchantNextStockId + 1 < v5 then
					text = `Leaves in {TimeUtils:E(instant - v5)}`
				else
					text = `Restocking in {TimeUtils:E(santaMerchantNextStockId - v5)}`
				end
			else
				text = ""
			end

			local santaMerchant2 = workspace:FindFirstChild("Santa Merchant")
			local santaMerchantStockId2 = ReplicatedStorage:GetAttribute("SantaMerchantStockId")

			if santaMerchantStockId ~= santaMerchantStockId2 then
				local v7 = santaMerchantStockId
				santaMerchantStockId = santaMerchantStockId2
				v3:Fire()

				if v7 ~= nil then
				end
			end

			santaMerchant.Header.Title.Text = text

			if santaMerchant2 then
				santaMerchant2.Overhead.BillboardGui.Countdown.Text = text
			end
		end)
		Synchronizer:WaitAndCall(localPlayer, function(object)
			local function updateCurrency()
				local v5 = object:Get("ChristmasEvent.GoldElves") or 0
				santaMerchant.Header.Elves.Amount.Text = NumberUtils:Comma(v5)
			end

			object:OnChanged("ChristmasEvent.GoldElves", updateCurrency)
			task.spawn(updateCurrency)
		end)

		local function playCharacterAnimation(player, p)
			local character = player.Character

			if not character then
				return
			end

			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = script.Reward:Clone()
			clone.Currency.Text = `+{p}`
			clone.Parent = humanoidRootPart
			TweenService:Create(clone, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				StudsOffset = createVector(0, 2.5, 2.2)
			}):Play()
			TweenService:Create(
				clone.ImageLabel,
				TweenInfo.new(1.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, 1.5),
				{
					ImageTransparency = 1
				}
			):Play()
			TweenService:Create(
				clone.Currency,
				TweenInfo.new(1.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, 1.5),
				{
					TextTransparency = 1
				}
			):Play()
			TweenService:Create(
				clone.Currency.UIStroke,
				TweenInfo.new(1.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, 1.5),
				{
					Transparency = 1
				}
			):Play()
			task.delay(5, function()
				clone:Destroy()
			end)
		end

		remoteEvent.OnClientEvent:Connect(function(p, cframe)
			local clone = script.Smoke:Clone()
			clone:PivotTo(cframe)
			clone.Parent = workspace
			clone.smoke1:Emit(5)
			task.spawn(function()
				SoundController:PlaySound(ReplicatedStorage.Sounds.Sfx.Puff2, cframe.Position, false)
			end)
			task.delay(3, function()
				clone:Destroy()
			end)
			playCharacterAnimation(p, 1)
		end)
		Observers.observeTag("SantaMerchantNPC", function(instance)
			local maid = Trove.new()
			local track = instance.Humanoid.Animator:LoadAnimation(script.Idle)
			maid:Add(function()
				track:Stop(0)
				track:Destroy()
			end)
			track.Priority = Enum.AnimationPriority.Idle
			track.Looped = true
			track:Play()
			return maid:WrapClean()
		end, { workspace })
		remoteEvent3.OnClientEvent:Connect(function(_: string, childName: string)
			local santaMerchant2 = workspace:FindFirstChild("Santa Merchant")

			if not santaMerchant2 then
				return
			end

			local v5 = santaMerchant2.VFX:FindFirstChild(childName) or script.VFX["1"]

			if not v5 then
				return
			end

			task.spawn(function()
				SoundController:PlaySound(
					ReplicatedStorage.Sounds.Sfx.SantaMerchantSFX,
					santaMerchant2.SpawnPart.Position,
					false
				)
			end)
			VFX.emit(v5)
		end)
		Observers.observeTag("SantaMerchantPrompt", function(p)
			local maid = Trove.new()

			local function updatePrompt()
				if not Synchronizer:Wait(localPlayer) then
					return
				end

				p.ObjectText = "Santa's Shop"
				p.ActionText = "View"
			end

			maid:Add(task.spawn(function()
				if not Synchronizer:Wait(localPlayer) then
					return
				end

				maid:Add(Timer.Simple(1, updatePrompt))
				task.spawn(updatePrompt)
			end))
			maid:Add(p.Triggered:Connect(function()
				if not Synchronizer:Get(localPlayer) then
					return
				end

				InterfaceController:Toggle("SantaMerchant")
			end))
			return function()
				maid:Destroy()
			end
		end)
	end
}