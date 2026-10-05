local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage.Packages.Net)
local Observers = require(ReplicatedStorage.Packages.Observers)
local ReplicatorClient = require(ReplicatedStorage.Packages.ReplicatorClient)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)
local Timer = require(ReplicatedStorage.Packages.Timer)
local Trove = require(ReplicatedStorage.Packages.Trove)
local InterfaceController = require(ReplicatedStorage.Controllers.InterfaceController)
require(ReplicatedStorage.Controllers.CustomRichTextController)
require(ReplicatedStorage.Controllers.NotificationController)
local ShopController = require(ReplicatedStorage.Controllers.ShopController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local AnimatedButton = require(ReplicatedStorage.Classes.AnimatedButton)
local Marketplace = require(ReplicatedStorage.Shared.Marketplace)
local Animals = require(ReplicatedStorage.Shared.Animals)
local BeeMerchantFlags = require(ReplicatedStorage.Shared.Flags.BeeMerchantFlags)
local BeeMerchantData = require(ReplicatedStorage.Datas.BeeMerchantData)
local Animals2 = require(ReplicatedStorage.Datas.Animals)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local NumberUtils = require(ReplicatedStorage.Utils.NumberUtils)
local TimeUtils = require(ReplicatedStorage.Utils.TimeUtils)
local beeMerchantStock = ReplicatorClient.get("BeeMerchantStock")
local remoteEvent = Net:RemoteEvent("BeeMerchantService/SetFocused")
local remoteEvent2 = Net:RemoteEvent("BeeMerchantService/Animation")
local remoteFunction = Net:RemoteFunction("BeeMerchantService/Buy")
local remoteEvent3 = Net:RemoteEvent("ShopService/Purchase")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui

-- equivalent calls inferred from this helper; original call sites unknown
local function loadAnimation(animator, idle, maid)
	local track = animator:LoadAnimation(idle)
	maid:Add(function()
		track:Stop(0)
		track:Destroy()
	end)
	return track
end

-- equivalent calls inferred from this helper; original call sites unknown
local function renderBrainrot(frame, brainrot: string)
	local background = frame.Background
	local animal = Animals2[brainrot]
	frame.Visible = true
	Animals:AttachOnViewportWithOptimizations(brainrot, background.ViewportFrame)

	if animal then
		background.MoneySecond.Text = `${NumberUtils:ToString(Animals:GetGeneration(brainrot))}/s`
	else
		background.MoneySecond.Text = ""
	end
end

return {
	Start = function(_)
		local beeMerchant = playerGui:FindFirstChild("BeeMerchant")
		local beeMerchant2 = beeMerchant and beeMerchant:FindFirstChild("BeeMerchant")
		local close = beeMerchant2 and beeMerchant2:FindFirstChild("Close")
		local giftPlayerSelect = beeMerchant2 and beeMerchant2:FindFirstChild("GiftPlayerSelect")
		local giftButton = giftPlayerSelect and giftPlayerSelect:FindFirstChild("GiftButton")
		local txt = giftButton and giftButton:FindFirstChild("Txt")
		local playerSelected = giftPlayerSelect and giftPlayerSelect:FindFirstChild("PlayerSelected")
		local playerImage = playerSelected and playerSelected:FindFirstChild("PlayerImage")
		local headshot = playerImage and playerImage:FindFirstChild("Headshot")
		local playerName = playerSelected and playerSelected:FindFirstChild("PlayerName")

		if not (beeMerchant2 and beeMerchant2:IsA("Frame") and close and close:IsA("GuiButton") and giftButton and giftButton:IsA("GuiButton") and txt and txt:IsA("TextLabel") and playerSelected and playerSelected:IsA("GuiObject") and headshot and headshot:IsA("ImageLabel") and playerName and playerName:IsA("TextLabel")) then
			warn("Bee Merchant interface is incomplete")
			return
		end

		beeMerchant2.Visible = false
		local v = InterfaceController:Register("BeeMerchant", beeMerchant2, "TopQuint")
		v:AttachCloseButton(close)
		v.OnOpen:Connect(function()
			remoteEvent:FireServer("be53ceba-97ae-4600-9554-8ec56727d4c5", true)
		end)
		v.OnClose:Connect(function()
			remoteEvent:FireServer("be53ceba-97ae-4600-9554-8ec56727d4c5", false)
		end)
		v:Close()
		local frames = table.create(#BeeMerchantData.Brainrots)
		local v2 = Signal.new()

		for i, brainrot in ipairs(BeeMerchantData.Brainrots) do
			local brainrot2 = brainrot.Brainrot
			local frame = beeMerchant2:FindFirstChild((tostring(i)))
			assert(frame and frame:IsA("Frame"), (`Missing Bee merchant card {i}`))
			frames[i] = frame
			-- equivalent calls inferred from this helper; original call sites unknown
			local v4 = brainrot

			local function updateHoneyPrice()
				local v6 = BeeMerchantFlags.HoneyPrices:Get()[brainrot2] or v4.Price
				frame.BuyYellow.Price.Text = NumberUtils:ToString(v6)
			end

			updateHoneyPrice() -- equivalent call inferred; original call site unknown
			BeeMerchantFlags.HoneyPrices.Changed:Connect(updateHoneyPrice)
			local imageLabel = frame.BuyYellow:FindFirstChild("ImageLabel", true)

			if imageLabel and imageLabel:IsA("ImageLabel") then
				imageLabel.Image = "rbxassetid://79263604304661"
			end

			renderBrainrot(frame, brainrot2) -- equivalent call inferred; original call site unknown
			local brainrot3 = brainrot2
			local v7 = frame

			local function updateStock()
				local v8 = beeMerchantStock:TryIndex({ "stock", brainrot3 }) or 0
				local stock = v7.Background.Stock
				stock.RichText = true
				stock.Text = not (v8 > 0) and "SOLD OUT" or `{NumberUtils:Comma(v8)} <font color="rgb(255,127,0)">left</font>`
				local textColor

				if v8 > 0 then
					textColor = Color3.fromRGB(255, 255, 255)
				else
					textColor = Color3.fromRGB(255, 72, 72)
				end

				stock.TextColor3 = textColor
			end

			updateStock()
			v2:Connect(updateStock)
			beeMerchantStock:Listen({ "stock", brainrot2 }, updateStock)
			frame.Buy.Price.Text = `{NumberUtils:Comma(brainrot.RobuxPrice)}`

			if brainrot.ProductId > 0 then
				local v8 = brainrot
				local v9 = frame
				task.spawn(function()
					local success, result = pcall(function()
						return Marketplace:GetProductInfo(v8.ProductId, "Product")
					end)

					if success and typeof(result) == "table" and typeof(result.PriceInRobux) == "number" then
						v9.Buy.Price.Text = `{NumberUtils:Comma(result.PriceInRobux)}`
					end
				end)
			else
				frame.Buy.Interactable = false
				frame.Buy.AutoButtonColor = false
			end

			local v8 = AnimatedButton.new(frame.BuyYellow)
			v8:Animate()
			local v9 = i
			v8.OnActivated:Connect(function()
				if remoteFunction:InvokeServer("2083eb67-ecbd-4349-acee-4a86c7c2136c", v9) then
					SoundController:PlaySound("Sounds.Sfx.Success")
					InterfaceController:SetState("BeeMerchant", false)
				end
			end)

			if not (brainrot.ProductId > 0) then
				continue
			end

			local v10 = AnimatedButton.new(frame.Buy)
			v10:Animate()
			local v11 = brainrot
			v10.OnActivated:Connect(function()
				remoteEvent3:FireServer(v11.ProductId, ShopController:GetGiftingTarget())
			end)
		end

		local function updateGiftInfo()
			local giftingTarget = ShopController:GetGiftingTarget()

			if giftingTarget then
				local playerByUserId = Players:GetPlayerByUserId(giftingTarget)
				txt.Text = "Back"
				playerSelected.Visible = true
				playerName.Text = playerByUserId and `@{playerByUserId.Name}` or tostring(giftingTarget)
				headshot.Image = `rbxthumb://type=AvatarHeadShot&id={giftingTarget}&w=100&h=100`

				for _, v3 in ipairs(frames) do
					v3.BuyYellow.Visible = false
				end
			else
				playerSelected.Visible = false
				txt.Text = "Gift Player"

				for _, v3 in ipairs(frames) do
					v3.BuyYellow.Visible = true
				end
			end
		end

		ShopController.ToggleGiftSignal:Connect(updateGiftInfo)
		task.spawn(updateGiftInfo)
		local v3 = AnimatedButton.new(giftButton)
		v3:Animate()
		v3.OnActivated:Connect(function()
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
		local beeMerchantStockId = ReplicatedStorage:GetAttribute("BeeMerchantStockId")
		Timer.Simple(1, function()
			local serverTimeNow = workspace:GetServerTimeNow()
			local v4 = serverTimeNow + (ReplicatedStorage:GetAttribute("__timeSkipDebugBeeMerchant") or 0)
			local beeMerchantNextStockId = tonumber(ReplicatedStorage:GetAttribute("BeeMerchantNextStockId"))
			local beeNextEventTimestamp = tonumber(ReplicatedStorage:GetAttribute("BeeNextEventTimestamp"))
			local beeMerchantLeavingTimestamp = ReplicatedStorage:GetAttribute("BeeMerchantLeavingTimestamp")
			local text = ""

			if ReplicatedStorage:GetAttribute("BeeSwarmEvent") == true then
				text = "Swarm is active"
			elseif beeNextEventTimestamp then
				text = `Next swarm in {TimeUtils:E((math.max(beeNextEventTimestamp - serverTimeNow, 0)))}`
			end

			if beeMerchantNextStockId and v4 <= beeMerchantNextStockId + 1 then
				beeMerchant2.Title.Text = `Restocking in {TimeUtils:E((math.max(beeMerchantNextStockId - v4, 0)))}`
			elseif typeof(beeMerchantLeavingTimestamp) == "number" then
				beeMerchant2.Title.Text = `Leaves in {TimeUtils:E((math.max(beeMerchantLeavingTimestamp - v4, 0)))}`
			end

			local beehive = workspace:FindFirstChild("Beehive")
			local beeMerchantStockId2 = ReplicatedStorage:GetAttribute("BeeMerchantStockId")

			if beeMerchantStockId ~= beeMerchantStockId2 then
				beeMerchantStockId = beeMerchantStockId2
				v2:Fire()

				if beehive then
					beehive:GetAttribute("Hidden")
				end
			end

			if beehive then
				local overhead = beehive:FindFirstChild("Overhead")
				local billboardGui = overhead and overhead:FindFirstChild("BillboardGui")
				local countdown = billboardGui and billboardGui:FindFirstChild("Countdown")

				if countdown and countdown:IsA("TextLabel") then
					countdown.Text = text
				end
			end
		end)
		Observers.observeTag("BeeMerchantNPC", function(instance)
			local v4 = Trove.new()
			local humanoid = instance:FindFirstChildOfClass("Humanoid")
			local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

			if not animator then
				return v4:WrapClean()
			end

			local track = loadAnimation(animator, script.Idle, v4) -- equivalent call inferred; original call site unknown
			track.Priority = Enum.AnimationPriority.Idle
			track.Looped = true
			track:Play()
			return v4:WrapClean()
		end, { workspace })
		remoteEvent2.OnClientEvent:Connect(function(_: string, _: string)
			local beehive = workspace:FindFirstChild("Beehive")
			local beeHiveSpawnVFX = beehive and beehive:FindFirstChild("BeeHiveSpawnVFX", true)

			if not (beeHiveSpawnVFX and beeHiveSpawnVFX:IsA("BasePart")) then
				return
			end

			local beeMerchantSFX = ReplicatedStorage.Sounds.Sfx:FindFirstChild("BeeMerchantSFX")

			if beeMerchantSFX then
				SoundController:PlaySound(beeMerchantSFX, beeHiveSpawnVFX.Position, false)
			end
		end)
		Observers.observeTag("BeeMerchantPrompt", function(p)
			local maid = Trove.new()

			-- equivalent calls inferred from this helper; original call sites unknown
			local function updatePrompt()
				p.ObjectText = "Bee's Shop"
				p.ActionText = "View"
				p.Enabled = not ServerData.IsNewPlayersServer() and ReplicatedStorage:GetAttribute("BeeEvent") == true
			end

			updatePrompt() -- equivalent call inferred; original call site unknown
			maid:Add(ReplicatedStorage:GetAttributeChangedSignal("BeeEvent"):Connect(updatePrompt))
			maid:Add(p.Triggered:Connect(function()
				if not ServerData.IsNewPlayersServer() and ReplicatedStorage:GetAttribute("BeeEvent") == true and Synchronizer:Get(localPlayer) then
					InterfaceController:Toggle("BeeMerchant")
				end
			end))
			return maid:WrapClean()
		end)
	end
}