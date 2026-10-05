local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Gradients = require(packages.Gradients)
local Observers = require(packages.Observers)
local Replion = require(packages.Replion)
require(packages.Signal)
local Net = require(packages.Net)
local vide = require(packages.vide)
local InterfaceController = require(ReplicatedStorage.Controllers.InterfaceController)
local Marketplace = require(ReplicatedStorage.Shared.Marketplace)
local TimeUtils = require(ReplicatedStorage.Utils.TimeUtils)
local ServerLuck = require(ReplicatedStorage.Datas.ServerLuck)
local Cards = require(script.Parent.Cards)
local Featured = require(script.Parent.Featured)
local Gifting = require(script.Parent.Gifting)
local Header = require(script.Parent.Header)
local Layout = require(script.Parent.Layout)
local LuckyBlocks = require(script.Parent.LuckyBlocks)
local Merch = require(script.Parent.Merch)
local Reactive = require(script.Parent.Reactive)
local ServerLuck2 = require(script.Parent.ServerLuck)
local Sorting = require(script.Parent.Sorting)
local State = require(script.Parent.State)
local root = vide.root
local effect = vide.effect
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local remoteEvent = Net:RemoteEvent("ShopService/ShopOpened")

local function mountBlackFriday(screenGui, resolved, p)
	local descendants = screenGui:QueryDescendants(".Shop_BlackFridaySale")
	local v2 = Reactive.FromFlag("BlackfridaySale/EndTimestamp", 0)
	local txt1 = resolved:FindFirstChild("Txt1")
	effect(function()
		local v3 = v2()
		local clock = p.Clock()
		local v4 = v3 - clock
		local visible = clock <= v3

		if txt1 and txt1:IsA("TextLabel") then
			txt1.Text = `<font color="rgb(255,255,255)">BLACK FRIDAY SALE: </font>{TimeUtils:E((math.max(v4, 0)))} left`
		end

		for _, guiObject in descendants do
			if guiObject:IsA("GuiObject") then
				guiObject.Visible = visible
			end
		end
	end)
end

local function mountGradientTags()
	local maid = Reactive.Trove()
	maid:Add(Observers.observeTag("RainbowText", function(p)
		return Gradients.apply(p, "Rainbow")
	end))
	maid:Add(Observers.observeTag("ZebraText", function(p)
		return Gradients.apply(p, "Zebra")
	end))
end

local function mountABTests(screenGui, data, guiObject, p, p2)
	local size = p.Defaults.Size
	local v2 = Featured.FromABTest("Shop.Scale", 1)
	effect(function()
		local v3 = v2()
		local uDim = UDim2.new(size.X.Scale * v3, size.X.Offset, size.Y.Scale * v3, size.Y.Offset)

		if uDim.X.Scale == p.Defaults.Size.X.Scale and uDim.Y.Scale == p.Defaults.Size.Y.Scale then
			return
		end

		if guiObject:IsA("GuiObject") then
			guiObject.Size = uDim
		end

		p.Defaults.Size = uDim
	end)
	local resolved = Layout.Resolve(screenGui, data.List)

	if not resolved then
		return
	end

	local title = data.LuckyBlocks.Title
	local resolved2

	if title then
		resolved2 = Layout.Resolve(screenGui, title)
	end

	if resolved2 and resolved2:IsA("GuiObject") then
		local v3 = Featured.FromABTest("Shop.HideLuckyBlocksTitle", false)
		Reactive.Hydrate(resolved2, {
			Visible = function()
				return not (v3() or State.PaidRandomRestricted(p2))
			end
		})
	end

	local promoTitle = resolved:FindFirstChild("PromoTitle")

	if promoTitle and promoTitle:IsA("TextLabel") then
		local v3 = Featured.FromABTest("Shop.PromoTitle", nil)
		Reactive.Hydrate(promoTitle, {
			Visible = function()
				return v3() ~= nil
			end,
			Text = function()
				return v3() or promoTitle.Text
			end
		})
	end
end

local function preloadProducts()
	for _, v2 in { ServerLuck[3].ProductId, ServerLuck[2].ProductId } do
		task.defer(Marketplace.GetProductInfo, Marketplace, v2, "Product")
	end
end

return table.freeze({
	Mount = function(data, p)
		local screenGui = playerGui:WaitForChild(data.GuiName, 10)

		if not screenGui then
			warn((`ShopUI.App: {data.GuiName} is not in PlayerGui`))
			return nil
		end

		local resolved = Layout.Resolve(screenGui, data.Root)
		local resolved2 = Layout.Resolve(screenGui, data.Close)

		if not (resolved and resolved2) then
			warn((`ShopUI.App: {data.GuiName} is missing its root frame or close button`))
			return nil
		end

		if screenGui:IsA("ScreenGui") then
			screenGui.Enabled = true
		end

		local interface = InterfaceController:Register("Shop", resolved, "TopQuint")
		interface:AttachCloseButton(resolved2)
		interface:Close()
		local giftPlayer = playerGui:WaitForChild("GiftPlayer", 10)
		local giftPlayer2 = giftPlayer and giftPlayer:FindFirstChild("GiftPlayer")
		local state = nil
		local v4 = nil
		local v5 = root(function()
			state = State.new(interface, p)
			v4 = Cards.Mount(state, screenGui)
			Header.Mount(screenGui, data, state)
			LuckyBlocks.Mount(screenGui, data, state)
			ServerLuck2.Mount(screenGui, data, state)
			Merch.Mount(screenGui, data, state)
			Featured.Mount(screenGui, data, state)

			if giftPlayer2 then
				Gifting.MountPlayerList(giftPlayer2, state)
				Gifting.MountSelect(screenGui, data, giftPlayer2, state)
			end

			if data.Promos then
				Featured.MountLegacy(screenGui, data, state)
			end

			mountBlackFriday(screenGui, resolved, state)
			mountABTests(screenGui, data, resolved, interface, state)
			mountGradientTags()
			local maid = Reactive.Trove()
			maid:Add(interface.OnClose:Connect(function()
				state:SetGiftTarget(nil)
			end))
			maid:Add(interface.OnOpen:Connect(function()
				remoteEvent:FireServer()
			end))
		end)
		task.spawn(preloadProducts)
		local flag = true
		task.spawn(function()
			local v6 = Replion.Client:WaitReplion(`{localPlayer.Name}_Configs`, 60)

			if v6 and flag then
				Sorting.RunExperiments(screenGui, data, v6)
			end
		end)
		local connection = Replion.Client:OnReplionAddedWithTag("PlayerConfigs", function(p2)
			if flag then
				Sorting.RunExperiments(screenGui, data, p2)
			end
		end)
		return {
			State = state,
			Interface = interface,
			GiftFrame = giftPlayer2 or screenGui,
			Destroy = function()
				flag = false
				connection:Disconnect()
				v4()
				v5()
				InterfaceController:Unregister("Shop", interface)
			end
		}
	end
})