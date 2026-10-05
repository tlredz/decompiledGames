local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommerceService = game:GetService("CommerceService")
local Players = game:GetService("Players")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Gradients = require(packages.Gradients)
local Spr = require(packages.Spr)
local Net = require(packages.Net)
local vide = require(packages.vide)
local NotificationController = require(ReplicatedStorage.Controllers.NotificationController)
local ClientAPI = require(ReplicatedStorage.Controllers.StockEventController.ClientAPI)
local Animals = require(ReplicatedStorage.Shared.Animals)
local NumberUtils = require(ReplicatedStorage.Utils.NumberUtils)
local MerchShopData = require(ReplicatedStorage.Datas.MerchShopData)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local Layout = require(script.Parent.Layout)
local Reactive = require(script.Parent.Reactive)
require(script.Parent.State)
local source = vide.source
local derive = vide.derive
local effect = vide.effect
local localPlayer = Players.LocalPlayer
local color = Color3.fromRGB(122, 122, 122)
local color2 = Color3.fromRGB(81, 158, 86)
local v = {
	MountRedeem = function(instance)
		local v2 = false

		local function submitCode()
			if v2 or not instance.Active then
				return
			end

			local text = instance.Text

			if #text ~= MerchShopData.CodeLength then
				NotificationController:Error("Invalid code")
				return
			end

			v2 = true
			instance.Text = ""
			instance.PlaceholderText = "Redeeming..."
			instance.Selectable = false
			instance.Active = false
			instance:ReleaseFocus()
			local success, result, v3 = pcall(function()
				return Net:RemoteFunction("d193b9bf-8b44-42af-b4b2-9c77847ce1e9"):InvokeServer(text)
			end)

			if success then
				if result then
					NotificationController:Success(typeof(v3) ~= "string" and "Code redeemed!" or v3)
				else
					NotificationController:Error(typeof(v3) ~= "string" and "Request failed" or v3)
				end
			else
				NotificationController:Error("Unexpected error")
				warn(result)
			end

			instance.Text = ""
			instance.PlaceholderText = "Code Here..."
			task.wait(0.5)
			instance.Selectable = true
			instance.Active = true
			v2 = false
		end

		local maid = Reactive.Trove()
		maid:Add(instance.FocusLost:Connect(function(flag: boolean)
			if flag then
				submitCode()
			end
		end))
		maid:Add(instance:GetPropertyChangedSignal("Text"):Connect(function()
			local text = instance.Text
			local text2 = string.sub(string.upper(string.gsub(text, "[^%w]", "")), 1, MerchShopData.CodeLength)

			if text2 ~= text then
				instance.Text = text2
			end

			if #text2 == MerchShopData.CodeLength then
				submitCode()
			end
		end))
	end
}

local function commerceAllowed(p)
	local policy = p.Policy()
	return policy ~= nil and policy.IsEligibleToPurchaseCommerceProduct == true
end

local function mountCard(resolved, callback, p)
	local frame = resolved:FindFirstChild("Frame")

	if not frame then
		callback(true)
		return
	end

	local item = frame:FindFirstChild("Item")

	if item then
		local viewportFrame = item:FindFirstChild("ViewportFrame")

		if viewportFrame then
			Animals:AttachOnViewportWithOptimizations("Boppin Bunny", viewportFrame)
		end

		local uIStroke = item:FindFirstChild("UIStroke")
		local title = item:FindFirstChild("Title")

		if uIStroke then
			Gradients.apply(uIStroke, "Zebra")
		end

		if title then
			Gradients.apply(title, "Zebra")
		end
	end

	local buy = frame:FindFirstChild("Buy")
	local price = buy and buy:FindFirstChild("Price")
	local stock = frame:FindFirstChild("Stock")
	local websiteLink = frame:FindFirstChild("WebsiteLink")
	local codeRedeem = frame:FindFirstChild("CodeRedeem")
	local visible = derive(function()
		local policy = p.Policy()
		return policy ~= nil and policy.IsEligibleToPurchaseCommerceProduct == true
	end)

	if buy and buy:IsA("GuiObject") then
		Reactive.Hydrate(buy, {
			Visible = visible
		})
	end

	if codeRedeem and codeRedeem:IsA("GuiObject") then
		Reactive.Hydrate(codeRedeem, {
			Visible = function()
				return not visible()
			end
		})
	end

	if websiteLink and websiteLink:IsA("GuiObject") then
		Reactive.Hydrate(websiteLink, {
			Visible = function()
				return not visible()
			end
		})
	end

	if codeRedeem then
		local textBox = codeRedeem:FindFirstChild("TextBox")

		if textBox and textBox:IsA("TextBox") then
			v.MountRedeem(textBox)
		end
	end

	local currentItem = MerchShopData.CurrentItem

	if not currentItem then
		callback(true)
		return
	end

	local v3 = source(false)
	local v4 = ClientAPI.create("Boppin Bunny")

	local function updateStock()
		local stock2 = v4:GetStock("Boppin Bunny")

		if typeof(stock2) == "number" then
			v3(stock2 <= 0)

			if stock and stock:IsA("TextLabel") then
				stock.Text = stock2 <= 0 and "SOLD OUT" or `{NumberUtils:Comma(stock2)} LEFT`
			end
		elseif stock and stock:IsA("TextLabel") then
			stock.Text = "??? LEFT"
		end
	end

	v4:OnStockChange("Boppin Bunny", updateStock)
	task.spawn(updateStock)

	if buy and buy:IsA("GuiObject") then
		effect(function()
			local target = Spr.target
			local backgroundColor

			if v3() then
				backgroundColor = color
			else
				backgroundColor = color2
			end

			target(buy, 1, 5, {
				BackgroundColor3 = backgroundColor
			})
		end)
	end

	if price and price:IsA("TextLabel") then
		price.Text = "???"
	end

	task.spawn(function()
		local success, result = pcall(function()
			return CommerceService:GetCommerceProductInfoAsync(currentItem.CommerceProductId)
		end)

		if ServerData.IsDevGame() and not success then
			result = {
				Item = MerchShopData.TestProductInfo
			}
		elseif not success or typeof(result) ~= "table" or typeof(result.Item) ~= "table" then
			callback(true)
			return
		end

		if price and price:IsA("TextLabel") then
			price.Text = result.Item.DisplayPrice or "$29.99"
		end
	end)

	if buy and buy:IsA("GuiButton") then
		Reactive.Trove():Add(buy.Activated:Connect(function()
			if v3() then
				return
			end

			CommerceService:PromptCommerceProductPurchase(localPlayer, currentItem.CommerceProductId)
		end))
	end
end

function v.Mount(p, data, p2)
	local resolved = Layout.Resolve(p, data.List)
	local resolved2 = Layout.Resolve(p, data.CodesTextBox)

	if resolved2 and resolved2:IsA("TextBox") then
		v.MountRedeem(resolved2)
	end

	local v2 = source(false)
	local resolved3

	if data.Merch then
		resolved3 = Layout.Resolve(p, data.Merch)
	end

	if resolved3 then
		mountCard(resolved3, v2, p2)
	end

	local v3 = Reactive.FromFlag("MerchShopHideAllFrontend", false)
	local v4 = Reactive.FromFlag("MerchShopHideIfPolicyDisabledV2", false)
	local v5 = Reactive.FromFlag("MerchShopOnlyShowRedeemCode", false)
	local visible = derive(function()
		p2.UpdatesRevision()

		if v2() or v3() then
			return false
		end

		local policy = p2.Policy()
		local v7

		if policy == nil then
			v7 = false
		else
			v7 = policy.IsEligibleToPurchaseCommerceProduct == true
		end

		if v7 or not v4() then
			return MerchShopData.IsEnabled()
		end

		return false
	end)
	local codes = data.Sections.Codes
	local resolved4

	if resolved and codes then
		resolved4 = Layout.Resolve(resolved, codes.Frame)
	end

	local v7

	if resolved and codes and codes.Title then
		v7 = Layout.Resolve(resolved, codes.Title)
	end

	for _, guiObject in { resolved4, v7 } do
		if guiObject and guiObject:IsA("GuiObject") then
			Reactive.Hydrate(guiObject, {
				Visible = visible
			})
		end
	end

	if resolved3 and resolved3:IsA("GuiObject") then
		local visible2 = derive(function()
			return visible() and not v5()
		end)
		Reactive.Hydrate(resolved3, {
			Visible = visible2
		})
		local plushSpacer = resolved3.Parent and resolved3.Parent:FindFirstChild("PlushSpacer")

		if plushSpacer and plushSpacer:IsA("GuiObject") then
			Reactive.Hydrate(plushSpacer, {
				Visible = visible2
			})
		end
	end
end

return table.freeze(v)