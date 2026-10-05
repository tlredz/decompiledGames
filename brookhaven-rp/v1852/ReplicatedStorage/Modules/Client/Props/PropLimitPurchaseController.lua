local PropLimitPurchaseController = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CountableDevProductController = require(ReplicatedStorage.Modules.Client.Monetization.CountableDevProductController)
local CountableDevProducts = require(ReplicatedStorage.Modules.Shared.PlayerData.CountableDevProducts)
local GameUtil = require(ReplicatedStorage.Modules.Shared.Game.GameUtil)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
local GetProductInfo = require(ReplicatedStorage.Modules.Shared.Utils.GetProductInfo)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local PrivateServerPropLimits = require(ReplicatedStorage.Modules.Shared.PrivateServer.PrivateServerPropLimits)
local PropsLimitClient = require(ReplicatedStorage.Modules.Client.Props.PropsLimitClient)
local PropsUtil = require(ReplicatedStorage.Modules.Shared.Housing.PropsUtil)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local PUBLIC_SERVER_PROP_LIMIT = CountableDevProducts.PUBLIC_SERVER_PROP_LIMIT
local PRIVATE_SERVER_PROP_LIMIT = CountableDevProducts.PRIVATE_SERVER_PROP_LIMIT
local localPlayer = Players.LocalPlayer
local flag = false
local maid = nil

local function hideVideoAds(buttons)
	for _, childName in { "VideoAdAvailable", "VideoAdLoading", "VideoAdUnavailable" } do
		local guiObject = buttons:FindFirstChild(childName)

		if guiObject ~= nil and guiObject:IsA("GuiObject") then
			guiObject.Visible = false
		end
	end
end

local function notifyPurchaseResult(p: string, p2: string)
	if p == "BACKEND_ERROR" or p == "NOT_PRIVATE_SERVER" then
		task.spawn(NotificationController.Notify, "Something went wrong, please try again.")
	elseif p == "AT_CAP" then
		task.spawn(NotificationController.Notify, p2)
	elseif p == "NOT_OWNER" then
		task.spawn(NotificationController.Notify, "Only the private server owner can purchase this.")
	end
end

local function showUpsell(text: string, text2: string, p: number, image: string, fn)
	if Janitor.Is(maid) then
		maid:Destroy()
	end

	maid = Janitor.new()
	local v = PanelController.WaitForPanel("NoResetGUIHandler", "ProductUnlock")

	if v == nil then
		return
	end

	v:RegisterListener(v, v.Events.Closing, function()
		if Janitor.Is(maid) then
			maid:Destroy()
		end

		maid = nil
	end)
	local outerBox = v:GetInstance():WaitForChild("OuterBox")
	local contentBox = outerBox:WaitForChild("ContentBox")
	local gamepassOuterBox = contentBox:WaitForChild("GamepassPaddingBox"):WaitForChild("GamepassOuterBox")
	local title = contentBox:WaitForChild("Title")
	local textLabel = gamepassOuterBox:WaitForChild("TextBox"):WaitForChild("TextLabel")
	local icon = gamepassOuterBox:WaitForChild("IconBox"):WaitForChild("Icon")
	local imageLabel = outerBox:WaitForChild("ItemIcon"):WaitForChild("ImageLabel")
	local buttons = contentBox:WaitForChild("Buttons")
	local unlockButton = buttons:WaitForChild("UnlockButton")
	hideVideoAds(buttons)
	icon.Image = image
	imageLabel.Image = "rbxassetid://14240155280"
	title.Text = text
	textLabel.Text = text2
	unlockButton.Text = ""
	maid:Add(task.spawn(function()
		local v2, v3 = GetProductInfo(p, Enum.InfoType.Product, 0)

		if v2 and v3.PriceInRobux ~= nil then
			unlockButton.Text = "" .. tostring(v3.PriceInRobux)
		end
	end))
	maid:Add(unlockButton.Activated:Connect(function()
		PanelController.Close("NoResetGUIHandler", "ProductUnlock")
		fn()
	end))
	PanelController.Open("NoResetGUIHandler", "ProductUnlock")
end

function PropLimitPurchaseController.PromptIncrease(value: string)
	local v

	if typeof(value) == "string" then
		v = string.len(value) <= 100
	else
		v = false
	end

	assert(v, "source must be a string up to 100 chars")

	if GameUtil.IsPrivateServer() then
		if not GameUtil.IsPrivateServerOwner(localPlayer) then
			return "NOT_OWNER"
		end

		if PropsLimitClient.IsAtPrivateServerMax() then
			return "AT_CAP"
		end

		local count = CountableDevProductController.GetCount(PRIVATE_SERVER_PROP_LIMIT)
		local propLimit = PropsLimitClient.GetPropLimit(false)
		local limit = PrivateServerPropLimits.ResolveLimit(count + 1)
		showUpsell(
			string.format("Increase your server prop limit from %d to %d?", propLimit, limit),
			"This increase applies to all of your private servers!",
			CountableDevProducts.GetId(PRIVATE_SERVER_PROP_LIMIT),
			PrivateServerPropLimits.UNLOCK_ICON,
			function()
				notifyPurchaseResult(
					CountableDevProductController.PromptPurchase(PRIVATE_SERVER_PROP_LIMIT, value),
					"Max Server Prop Limit Reached!"
				)
			end
		)
		return "OK"
	else
		local isOwned = GamepassController.IsOwned(Gamepasses.VIP)

		if PropsLimitClient.IsAtPublicMax() then
			return "AT_CAP"
		end

		local count = CountableDevProductController.GetCount(PUBLIC_SERVER_PROP_LIMIT)
		local publicLimit = PropsLimitClient.GetPublicLimit(isOwned)
		local publicLimit2 = PropsUtil.ComputePublicLimit(count + 1, isOwned)
		showUpsell(
			string.format("Increase your server prop limit from %d to %d?", publicLimit, publicLimit2),
			"This increase only applies to public servers!",
			CountableDevProducts.GetId(PUBLIC_SERVER_PROP_LIMIT),
			PropsUtil.PUBLIC_PROP_LIMIT_UNLOCK_ICON,
			function()
				notifyPurchaseResult(
					CountableDevProductController.PromptPurchase(PUBLIC_SERVER_PROP_LIMIT, value),
					"Max Public Server Prop Limit Reached!"
				)
			end
		)
		return "OK"
	end
end

function PropLimitPurchaseController.PromptIncreaseOnLimitHit(p: string)
	if flag or GameUtil.IsPrivateServer() and not GameUtil.IsPrivateServerOwner(localPlayer) then
		return
	end

	flag = true
	PropLimitPurchaseController.PromptIncrease(p)
end

function PropLimitPurchaseController.FrameworkInit() end

function PropLimitPurchaseController.FrameworkStart()
	Remotes.connect("PropLimitHit", function()
		PropLimitPurchaseController.PromptIncreaseOnLimitHit("PropLimit:LimitHit")
	end)
end

return PropLimitPurchaseController