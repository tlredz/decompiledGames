local LocalizationService = game:GetService("LocalizationService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage2:WaitForChild("UserInputService"))
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
game:GetService("Players")

while not workspace:GetAttribute("ClientStarted") do
	workspace:GetAttributeChangedSignal("ClientStarted"):Wait()
end

require(ReplicatedStorage.Common.MarketplaceService)
local GiftingController = require(ReplicatedStorage.Controllers.GiftingController)
local Utils = require(ReplicatedStorage.Common.Utils)
local BoatTween = require(ReplicatedStorage.ClientGameModules.BoatTween)
local SpinWheelRewards = require(ReplicatedStorage.Shared.SpinWheelRewards)
local ClientPackManager = require(ReplicatedStorage.ClientGameModules.ClientPackManager)
local TextUtility = require(ReplicatedStorage.ClientGameModules.TextUtility)
local GuiHandler = require(ReplicatedStorage.ClientGameModules.GuiHandler)
local SpinWheelSettings = require(ReplicatedStorage.Shared.SpinWheelSettings)
local Replion = require(ReplicatedStorage.Packages.Replion)
local Policy = require(game.ReplicatedStorage.Shared.Policy)
local TradeTokensController = require(ReplicatedStorage.Controllers.Trading.TradeTokensController)
local ServerInfo = require(ReplicatedStorage.ServerInfo)
local CreatePriceLabel = require(ReplicatedStorage.ClientGameModules.CreatePriceLabel)
local NotificationController = require(ReplicatedStorage.Controllers.NotificationController)

if ServerInfo.isDuelLobbyServer() or ServerInfo.isDungeonsLobbyServer() then
	return
end

local localPlayer = game.Players.LocalPlayer
local v = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not (UserInputService.GamepadEnabled or GuiService:IsTenFootInterface())
local visible = ReplicatedStorage.Remotes.canUseDailySpin:InvokeServer()
local v3 = { "NL", "BE" }
local countryRegionForPlayerAsync = ""
pcall(function()
	countryRegionForPlayerAsync = LocalizationService:GetCountryRegionForPlayerAsync(localPlayer)
end)
local wheelMenu = script.Parent.WheelMenu
local spinnyy = workspace:WaitForChild("Spawn", 1000000):WaitForChild("Spinnyy")
local parent = script.Parent
local v4 = nil
wheelMenu.Button.FirstDayButton.Visible = visible
wheelMenu.Button.SpinButton.Visible = true
wheelMenu.BuySpinsFrame.Visible = true

-- equivalent calls inferred from this helper; original call sites unknown
local function UpdateRolls(p)
	wheelMenu.Button.SpinButton.TextLabel.Text = "Spin! (" .. p .. ")"
	wheelMenu.Button.SpinButton.SpinTenButton.Visible = p >= 10
end

local v5 = Replion.Client:WaitReplion("Data")
UpdateRolls(v5:Get("rolls")) -- equivalent call inferred; original call site unknown
v5:OnChange("rolls", UpdateRolls)
parent.WheelMenu.Button.CloseButton.Activated:Connect(function()
	GuiHandler:Close("Wheel")
end)
local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include

local function updateDailyCoinSpin()
	if not v4 then
		return
	end

	local unixTimestamp = DateTime.now().UnixTimestamp
	local v6 = v4.LastSpinReset + SpinWheelSettings.COIN_SPIN_COOLDOWN
	local v7 = v4.CoinSpins < SpinWheelSettings.MAX_COIN_SPINS

	if v6 <= unixTimestamp then
		ReplicatedStorage.Remotes.UpdateSpinData:FireServer()
	end

	if not parent.Enabled then
		return
	end

	if not v7 then
		wheelMenu.BuySpinsFrame.BuyOneCoins.TextLabel.Text = `Next purchase in {TextUtility.formatTime(v6 - unixTimestamp)}`
		return
	end

	local v8 = SpinWheelSettings.MAX_COIN_SPINS - v4.CoinSpins
	wheelMenu.BuySpinsFrame.BuyOneCoins.ImageColor3 = Color3.fromRGB(255, 255, 255)
	wheelMenu.BuySpinsFrame.BuyOneCoins.TextLabel.Text = `Buy 1 Spin ({SpinWheelSettings.COIN_SPIN_PRICE} Coins {v8}/{SpinWheelSettings.MAX_COIN_SPINS})`
end

task.spawn(function()
	while true do
		updateDailyCoinSpin()
		task.wait(1)
	end
end)

local function getSpinWheelRewardInfo(p: string, p2)
	for k, v6 in p2 or SpinWheelRewards:GetSpinWheel(localPlayer), nil, nil do
		if v6.alternative and v6.alternative.name == p then
			local clone = table.clone(v6)

			for k2, v7 in v6.alternative do
				clone[k2] = v7
			end

			return clone, k
		elseif v6.name == p then
			return v6, k
		end
	end
end

local labels = {}

for _, label in pairs(script.Parent:GetDescendants()) do
	if label.Name == "ExpireTimer" and label:IsA("TextLabel") then
		labels[#labels + 1] = label
	end
end

if #labels > 0 then
	local _, v6 = SpinWheelRewards:GetActiveEvent()

	if v6 then
		Utils.Thread.Every(1, function()
			if not parent.Enabled then
				return
			end

			local v7 = v6 - os.time()

			for _, v8 in pairs(labels) do
				v8.Text = Utils.ValueConvertor:FormatTimeWithDaysFull(v7)
			end
		end)
	end
end

local updateSpinWheelRewards

updateSpinWheelRewards = function()
	local v6 = ReplicatedStorage.Remotes.GetSpinWheelRewards:InvokeServer()

	if not v6 then
		return task.delay(2.5, updateSpinWheelRewards)
	end

	for k in v6 do
		local spinWheelRewardInfo, v7 = getSpinWheelRewardInfo(k)

		if not spinWheelRewardInfo then
			continue
		end

		local formatted = `Reward_{v7}`
		local child = script.Parent.Rewards.Rewards.RewardList:FindFirstChild(formatted)

		if child then
			child.Chance.Text = `{spinWheelRewardInfo.chance}%`
			child.LayoutOrder = spinWheelRewardInfo.chance * 1000
			local rewardText

			if spinWheelRewardInfo.rewardText then
				rewardText = spinWheelRewardInfo.rewardText
			elseif spinWheelRewardInfo.displayText then
				rewardText = spinWheelRewardInfo.displayText
			else
				rewardText = spinWheelRewardInfo.name
			end

			child.ItemName.Text = rewardText
			child.ItemName.Icon.Image = spinWheelRewardInfo.icon or ""
		end

		local child2 = script.Parent.WheelMenu.Wheel.WheelTemplates:FindFirstChild(formatted)

		if child2 then
			child2.BottomText.Text = spinWheelRewardInfo.bottomText or ""
			child2.ItemName.Text = spinWheelRewardInfo.wheelText or spinWheelRewardInfo.displayText
			child2.Image = spinWheelRewardInfo.icon
		end

		spinnyy.Color = wheelMenu.Wheel.BackgroundColor3
		spinnyy.surfac.ImageLabel.Image = wheelMenu.Wheel.Image

		for _, child3 in pairs(spinnyy.surfac.WheelTemplates:GetChildren()) do
			local child4 = wheelMenu.Wheel.WheelTemplates:FindFirstChild(child3.Name)

			if not child4 then
				continue
			end

			child3.Rotation = child4.Rotation
			child3.Position = child4.Position
			child3.Size = child4.Size
			child3.AnchorPoint = child4.AnchorPoint
			child3:ClearAllChildren()

			for _, child5 in pairs(child4:GetChildren()) do
				local clone = child5:Clone()
				clone.Parent = child3
			end
		end

		spinnyy.surfac.WheelTemplates.Size = wheelMenu.Wheel.WheelTemplates.Size
		spinnyy.surfac.WheelTemplates.Position = wheelMenu.Wheel.WheelTemplates.Position
		local child3 = spinnyy.surfac.WheelTemplates:FindFirstChild(formatted)

		if not child3 then
			continue
		end

		child3.BottomText.Text = spinWheelRewardInfo.bottomText or ""
		child3.ItemName.Text = spinWheelRewardInfo.wheelText or spinWheelRewardInfo.displayText
		child3.Image = spinWheelRewardInfo.icon
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getMiddlePointOfGuiObject(p)
	local absolutePosition = p.AbsolutePosition
	local absoluteSize = p.AbsoluteSize
	local v6 = absolutePosition.X + absoluteSize.X / 2
	local v7 = absolutePosition.Y + absoluteSize.Y / 2
	return Vector2.new(v6, v7)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getAngle(middlePointOfGuiObject: Vector2, point: Vector2)
	local v6 = point - middlePointOfGuiObject
	return (450 - math.deg((math.atan2(v6.Y, v6.X)))) % 360 - 180
end

local function wheelSpin(p, value)
	parent.WheelMenu.Wheel.Rotation = 0
	local wheelTemplates = wheelMenu.Wheel.WheelTemplates
	local v7 = 360 / #wheelTemplates:GetChildren()
	local child = wheelTemplates:FindFirstChild("Reward_" .. p)

	if not child then
		warn("[SpinWheelClient] Could not find `Reward_" .. p .. "` in " .. wheelTemplates:GetFullName())
		return
	end

	local middlePointOfGuiObject = getMiddlePointOfGuiObject(wheelMenu.Wheel) -- equivalent call inferred; original call site unknown
	local angle = getAngle(middlePointOfGuiObject, getMiddlePointOfGuiObject(child)) -- equivalent call inferred; original call site unknown
	BoatTween:Create(parent.WheelMenu.Wheel, {
		Time = math.ceil(7 / (value or 1)),
		EasingStyle = "FabricDecelerate",
		EasingDirection = "In",
		StepType = "Heartbeat",
		Goal = {
			Rotation = -(-(angle + -10800)) - ((math.random() * 0.8 + 0.1) * v7 - v7 / 2)
		}
	}):Play()
end

parent.WheelMenu.Button.FirstDayButton.Activated:Connect(function()
	visible = ReplicatedStorage.Remotes.canUseDailySpin:InvokeServer()

	if not Policy:GetPolicyInfo().ArePaidRandomItemsRestricted then
		TradeTokensController:PromptPurchase(1640089100, Enum.InfoType.Product)
		return
	end

	Utils.Sounds:Play("error")
	NotificationController:SendNotification("Unavailable in your region")
end)
local flag = false
parent.WheelMenu.Button.SpinButton.SpinTenButton.Activated:Connect(function()
	if flag then
		return
	end

	local policyInfo = Policy:GetPolicyInfo()
	local rolls2 = v5:Get("rolls") or 0

	if policyInfo and policyInfo.ArePaidRandomItemsRestricted and rolls2 <= 0 then
		Utils.Sounds:Play("error")
		NotificationController:SendNotification("Unavailable in your region")
	else
		flag = true
		parent:SetAttribute("Spinning", true)

		for _ = 1, 10 do
			local rolls3 = v5:Get("rolls") or 0

			if not rolls3 or rolls3 <= 0 then
				break
			end

			local spinWheel, v6 = SpinWheelRewards:GetSpinWheel(localPlayer)
			local v7, v8, v9, v10 = unpack(Utils.Network:Invoke("SpinWheel"))

			if v7 and v8 then
				local spinWheelRewardInfo, v11 = getSpinWheelRewardInfo(v8, spinWheel)
				wheelSpin(v11, 2)
				UpdateRolls(v9) -- equivalent call inferred; original call site unknown
				task.spawn(function()
					ReplicatedStorage.Misc.spinwheelFast.TimePosition = 2
					ReplicatedStorage.Misc.spinwheelFast:Play()
					task.wait(4.055555555555555)
					ReplicatedStorage.Misc.spinwheelFast:Stop()
					ReplicatedStorage.Misc.reward:Play()
				end)
				task.wait(4.055555555555555)
				task.spawn(updateSpinWheelRewards)

				if v10 then
					wheelMenu.Win.Text = "You won a dupe! (coins)"
				else
					wheelMenu.Win.Text = `You won {spinWheelRewardInfo.displayText or spinWheelRewardInfo.name}!`
				end

				TweenService:Create(wheelMenu.Win, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
					TextTransparency = 0
				}):Play()
				TweenService:Create(wheelMenu.Win.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
					Transparency = 0
				}):Play()
				task.wait(2)
				TweenService:Create(wheelMenu.Win, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
					TextTransparency = 1
				}):Play()
				TweenService:Create(wheelMenu.Win.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
					Transparency = 1
				}):Play()
			end

			local _, v11 = SpinWheelRewards:GetSpinWheel(localPlayer)

			if v6 ~= v11 then
				break
			end
		end

		parent:SetAttribute("Spinning")
		flag = false
	end
end)
parent.WheelMenu.Button.SpinButton.Activated:Connect(function()
	if flag then
		return
	end

	local policyInfo = Policy:GetPolicyInfo()
	local rolls2 = v5:Get("rolls") or 0

	if policyInfo and policyInfo.ArePaidRandomItemsRestricted and rolls2 <= 0 then
		Utils.Sounds:Play("error")
		NotificationController:SendNotification("Unavailable in your region")
	else
		flag = true
		parent:SetAttribute("Spinning", true)
		local spinWheel = SpinWheelRewards:GetSpinWheel(localPlayer)
		local v6, v7, v8, v9 = unpack(Utils.Network:Invoke("SpinWheel"))

		if v6 then
			local spinWheelRewardInfo, v10 = getSpinWheelRewardInfo(v7, spinWheel)
			wheelSpin(v10)
			UpdateRolls(v8) -- equivalent call inferred; original call site unknown
			task.spawn(function()
				ReplicatedStorage.Misc.spinwheel.TimePosition = 2
				ReplicatedStorage.Misc.spinwheel:Play()
				task.wait(7.3)
				ReplicatedStorage.Misc.spinwheel:Stop()
				ReplicatedStorage.Misc.reward:Play()
			end)
			task.wait(7.3)
			task.spawn(updateSpinWheelRewards)

			if v9 then
				wheelMenu.Win.Text = "You won a dupe! (coins)"
			else
				wheelMenu.Win.Text = `You won {spinWheelRewardInfo.displayText or spinWheelRewardInfo.name}!`
			end

			TweenService:Create(wheelMenu.Win, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
				TextTransparency = 0
			}):Play()
			TweenService:Create(wheelMenu.Win.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
				Transparency = 0
			}):Play()
			task.wait(2)
			TweenService:Create(wheelMenu.Win, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
				TextTransparency = 1
			}):Play()
			TweenService:Create(wheelMenu.Win.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
				Transparency = 1
			}):Play()
		end

		flag = false
		parent:SetAttribute("Spinning")
	end
end)
wheelMenu.BuySpinsFrame.BuyOne.Activated:Connect(function()
	if not Policy:GetPolicyInfo().ArePaidRandomItemsRestricted then
		TradeTokensController:PromptPurchase(1640151820, Enum.InfoType.Product)
		return
	end

	Utils.Sounds:Play("error")
	NotificationController:SendNotification("Unavailable in your region")
end)
CreatePriceLabel(wheelMenu.BuySpinsFrame.BuyOne.TextLabel, 1640151820, "DevProduct", "Buy 1 Spin :robux:%s")
CreatePriceLabel(wheelMenu.Button.FirstDayButton.Frame.Main.PreviousPrice, 1640151820)
wheelMenu.BuySpinsFrame.BuyOne.GiftButton.Activated:Connect(function()
	if not Policy:GetPolicyInfo().ArePaidRandomItemsRestricted then
		GiftingController:SetGift("GiftSpin1")
		return
	end

	Utils.Sounds:Play("error")
	NotificationController:SendNotification("Unavailable in your region")
end)
wheelMenu.BuySpinsFrame.BuyFive.Activated:Connect(function()
	if not Policy:GetPolicyInfo().ArePaidRandomItemsRestricted then
		TradeTokensController:PromptPurchase(1640151943, Enum.InfoType.Product)
		return
	end

	Utils.Sounds:Play("error")
	NotificationController:SendNotification("Unavailable in your region")
end)
CreatePriceLabel(wheelMenu.BuySpinsFrame.BuyFive.TextLabel, 1640151943, "DevProduct", "Buy 5 Spins :robux:%s")
wheelMenu.BuySpinsFrame.BuyFive.GiftButton.Activated:Connect(function()
	if not Policy:GetPolicyInfo().ArePaidRandomItemsRestricted then
		GiftingController:SetGift("GiftSpin2")
		return
	end

	Utils.Sounds:Play("error")
	NotificationController:SendNotification("Unavailable in your region")
end)
wheelMenu.BuySpinsFrame.BuyTen.Activated:Connect(function()
	if not Policy:GetPolicyInfo().ArePaidRandomItemsRestricted then
		TradeTokensController:PromptPurchase(1640152060, Enum.InfoType.Product)
		return
	end

	Utils.Sounds:Play("error")
	NotificationController:SendNotification("Unavailable in your region")
end)
CreatePriceLabel(wheelMenu.BuySpinsFrame.BuyTen.TextLabel, 1640152060, "DevProduct", "Buy 10 Spins :robux:%s")
wheelMenu.BuySpinsFrame.BuyTen.GiftButton.Activated:Connect(function()
	if not Policy:GetPolicyInfo().ArePaidRandomItemsRestricted then
		GiftingController:SetGift("GiftSpin3")
		return
	end

	Utils.Sounds:Play("error")
	NotificationController:SendNotification("Unavailable in your region")
end)
local PlaytimeRewardsInfo = require(ReplicatedStorage.Common.PlaytimeRewardsInfo)

-- equivalent calls inferred from this helper; original call sites unknown
local function updatePurchasedSpins(p)
	wheelMenu.BuySpinsFrame.BuyFive.Visible = p > 0
	wheelMenu.BuySpinsFrame.BuyTen.Visible = p > 0
	task.spawn(function()
		local extra = script.Parent:FindFirstChild("Extra")
		local offers = extra and extra:FindFirstChild("Offers")

		if not offers then
			return
		end

		offers.Ten.Visible = p > 0
		offers.OneHundred.Visible = p > 0
	end)
end

v5:OnChange("PurchasedProducts.WheelSpins", updatePurchasedSpins)
updatePurchasedSpins(v5:Get("PurchasedProducts.WheelSpins")) -- equivalent call inferred; original call site unknown

-- equivalent calls inferred from this helper; original call sites unknown
local function updateVisibleCoins(credits)
	wheelMenu.BuySpinsFrame.BuyOneCoins.Visible = credits >= 3000 or v5:Get("PurchasedProducts.WheelSpinsCoins") > 0
end

v5:OnChange("Credits", updateVisibleCoins)
v5:OnChange("PurchasedProducts.WheelSpinsCoins", function()
	updateVisibleCoins(v5:Get("Credits")) -- equivalent call inferred; original call site unknown
end)
updateVisibleCoins(v5:Get("Credits")) -- equivalent call inferred; original call site unknown
local maid = Utils.Maid.new()

local function updateRolls(rolls2)
	if rolls2 > 0 then
		if not maid.Active then
			return
		end

		maid:Destroy()
	elseif not maid.Active then
		maid.Active = true
		maid:GiveTask(function()
			wheelMenu.Button.SpinButton.ProgressTimer.Visible = false
			wheelMenu.Button.SpinButton.ProgressGradient.Enabled = false
		end)
		maid.UpdateTimer = Utils.Thread.Every(1.5, function()
			if not parent.Enabled then
				return
			end

			local duration = nil

			for k, reward in pairs(PlaytimeRewardsInfo.Rewards) do
				if reward.Reward.Type ~= "WheelSpin" or v5:Get({
					"PlaytimeRewardsData",
					"ClaimedRewards",
					(tostring(k))
				}) then
					continue
				end

				duration = reward.Duration
				break
			end

			if duration then
				wheelMenu.Button.SpinButton.ProgressTimer.Visible = true
				wheelMenu.Button.SpinButton.ProgressGradient.Enabled = true
				local v8 = os.time() - (v5:Get("PlaytimeRewardsData.TimerStart") or 0)
				local v9 = math.min(1, v8 / duration)
				wheelMenu.Button.SpinButton.ProgressTimer.Text = v9 < 1 and Utils.ValueConvertor:FormatTime(duration - v8) or ""
				wheelMenu.Button.SpinButton.ProgressGradient.Color = Utils.ValueConvertor:GetColorSequenceFromPercentage(
					v9,
					0.025,
					Color3.new(1, 1, 1),
					Color3.new(0.2, 0.2, 0.2)
				)
			else
				wheelMenu.Button.SpinButton.ProgressTimer.Visible = false
				wheelMenu.Button.SpinButton.ProgressGradient.Enabled = false
			end
		end)
	end
end

v5:OnChange("rolls", updateRolls)
updateRolls(v5:Get("rolls"))
wheelMenu.BuySpinsFrame.BuyOneCoins.Activated:Connect(function()
	local policyInfo = Policy:GetPolicyInfo()

	if policyInfo and policyInfo.ArePaidRandomItemsRestricted then
		Utils.Sounds:Play("error")
		NotificationController:SendNotification("Unavailable in your region")
	else
		ReplicatedStorage.Remotes.BuySpinCoins:FireServer()
	end
end)
ReplicatedStorage.Remotes.BoughtASpin.OnClientEvent:Connect(function(p, p2)
	local _, v7 = getSpinWheelRewardInfo(p)
	wheelSpin(v7)
	script.Parent.WheelMenu.Button.FirstDayButton.Visible = false
	script.Parent.WheelMenu.Button.SpinButton.Visible = true
	task.spawn(function()
		ReplicatedStorage.Misc.spinwheel.TimePosition = 2
		ReplicatedStorage.Misc.spinwheel:Play()
		task.wait(7.3)
		ReplicatedStorage.Misc.spinwheel:Stop()
		ReplicatedStorage.Misc.reward:Play()
		updateSpinWheelRewards()
	end)

	if p2 then
		wheelMenu.Win.Text = "You won a dupe! (coins)"
		TweenService:Create(wheelMenu.Win, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
			TextTransparency = 0
		}):Play()
		TweenService:Create(wheelMenu.Win.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
			Transparency = 0
		}):Play()
		task.wait(2)
		TweenService:Create(wheelMenu.Win, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
			TextTransparency = 1
		}):Play()
		TweenService:Create(wheelMenu.Win.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
			Transparency = 1
		}):Play()
	end
end)
wheelMenu.Info.Activated:Connect(function()
	script.Parent.Rewards.Visible = true
	table.find(v3, countryRegionForPlayerAsync)
	script.Parent.Rewards.Home.Visible = false
	script.Parent.Rewards.Rewards.Visible = true
end)
script.Parent.Rewards.Home.Close.Activated:Connect(function()
	script.Parent.Rewards.Visible = false
end)
script.Parent.Rewards.Home.RewardsButton.Activated:Connect(function()
	script.Parent.Rewards.Home.Visible = false
	script.Parent.Rewards.Rewards.Visible = true
end)
script.Parent.Rewards.Rewards.Close.Activated:Connect(function()
	script.Parent.Rewards.Visible = false
end)
script.Parent.Event.Event:Connect(function()
	script.Parent.Rewards.Visible = true
	script.Parent.WheelMenu.Visible = true
end)
ClientPackManager:onChange(function(p)
	if not p then
		return
	end

	updateSpinWheelRewards()
end)
ReplicatedStorage.Remotes.UpdateSpinData.OnClientEvent:Connect(function(p)
	v4 = p
	updateDailyCoinSpin()
end)
task.spawn(function()
	local extra = script.Parent:FindFirstChild("Extra")
	local offers = extra and extra:FindFirstChild("Offers")

	if not offers then
		return
	end

	offers.Ten.Activated:Connect(function()
		if not Policy:GetPolicyInfo().ArePaidRandomItemsRestricted then
			TradeTokensController:PromptPurchase(1711304153, Enum.InfoType.Product)
			return
		end

		Utils.Sounds:Play("error")
		NotificationController:SendNotification("Unavailable in your region")
	end)
	offers.OneHundred.Activated:Connect(function()
		if not Policy:GetPolicyInfo().ArePaidRandomItemsRestricted then
			TradeTokensController:PromptPurchase(1711304266, Enum.InfoType.Product)
			return
		end

		Utils.Sounds:Play("error")
		NotificationController:SendNotification("Unavailable in your region")
	end)
end)

if v then
	local position = wheelMenu.Position
	local size = wheelMenu.Size
	wheelMenu.Position = UDim2.new(position.X.Scale, position.X.Offset, position.Y.Scale + 0.093, position.Y.Offset)
	wheelMenu.Size = UDim2.new(size.X.Scale, size.X.Offset, size.Y.Scale + 0.05, size.Y.Offset)
	localPlayer:WaitForChild("PlayerGui"):WaitForChild("Hotbar")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateVisibility()
		local UIStateController = require(ReplicatedStorage.Controllers.UI.UIStateController)
		UIStateController.HideHotbar:SetTag("SpinWheel", parent.Enabled)
	end

	parent:GetPropertyChangedSignal("Enabled"):Connect(updateVisibility)
	updateVisibility() -- equivalent call inferred; original call site unknown
end