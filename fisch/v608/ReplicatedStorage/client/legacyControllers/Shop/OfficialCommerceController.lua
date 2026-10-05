local CommerceService = game:GetService("CommerceService")
game:GetService("Lighting")
local Players = game:GetService("Players")
game:GetService("PolicyService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local _ = ReplicatedStorage.client.legacyControllers
local localPlayer = Players.LocalPlayer
local packages = ReplicatedStorage.packages
local shared = ReplicatedStorage.shared
local safezone = localPlayer.PlayerGui:WaitForChild("hud"):WaitForChild("safezone")
local shop = safezone:WaitForChild("shop")
local officialMerch = safezone:WaitForChild("OfficialMerch")
local pufferfishPlushie = officialMerch:WaitForChild("Pufferfish Plushie")
local scrollingFrame = officialMerch:WaitForChild("List"):WaitForChild("ScrollingFrame")
local v = { pufferfishPlushie }

for _, button in scrollingFrame:GetChildren() do
	if button:IsA("GuiButton") then
		table.insert(v, button)
	end
end

local GeneralUtils = require(shared.utils.GeneralUtils)
local Net = require(packages.Net)
require(packages.Observers)
local Trove = require(packages.Trove)
local FFlags = require(shared.modules.FFlags)
local OfficialCommerceProducts = require(shared.modules.OfficialCommerceProducts)
local Replion = require(ReplicatedStorage.packages.Replion)
require(shared.FormatNumber)
Net:RemoteEvent("Commerce/OpenGui", -1)
local remoteEvent = Net:RemoteEvent("Commerce/TryBuy")
local OfficialCommerceController = {}
OfficialCommerceController._openTrove = Trove.new()

function OfficialCommerceController.ToggleVisibility(_, visible: boolean)
	officialMerch.Visible = visible
end

function OfficialCommerceController.OpenGui(_) end

function OfficialCommerceController.LoadInformation(guiObject)
	local v2 = guiObject and OfficialCommerceProducts[guiObject.Name]

	if not v2 then
		return
	end

	local commerceProductId = v2.CommerceProductId
	local success, result = pcall(function()
		return CommerceService:GetCommerceProductInfoAsync(commerceProductId)
	end)

	if not (success and result) then
		if RunService:IsStudio() then
			result = {
				IsForSale = true,
				Item = {
					DisplayPrice = "$9.99"
				}
			}
		else
			warn(`Failed to load CommerceProductInfo for {guiObject.Name}:`, result)
		end
	end

	if result.IsForSale then
		if guiObject:IsA("GuiButton") then
			guiObject.Visible = true
		elseif guiObject:IsA("Frame") then
			guiObject.Visible = true
		end

		if guiObject:IsA("ImageButton") then
			guiObject.Activated:Connect(function()
				remoteEvent:FireServer(commerceProductId)
			end)
		end

		local buyButton = guiObject:FindFirstChild("BuyButton")

		if buyButton then
			buyButton.Activated:Connect(function()
				remoteEvent:FireServer(commerceProductId)
			end)
			local label = buyButton:FindFirstChild("Label")

			if label and result.Item and result.Item.DisplayPrice then
				label.Text = result.Item.DisplayPrice
			else
				result.Item.DisplayPrice = ""
			end
		end

		local v3 = v2.LimitedStockKey ~= nil
		local v4 = v2.EndTimeFFlag and FFlags:Get(v2.EndTimeFFlag, v2.DefaultEndTime)

		if v3 then
			local v5 = Replion.Client:WaitReplion("LimitedStockItems")

			local function updateStock()
				local v6 = v5:Get({ "Stocks", v2.LimitedStockKey }) or 0
				local expect = v5:GetExpect({ "InitialStocks", v2.LimitedStockKey })
				local v7 = 100 * v6 / expect
				local limitedAmount = guiObject.LimitedAmount
				limitedAmount.Visible = v5:Get("Loaded") == true and v7 <= FFlags:GetInstant(
					"CommerceMinimumStockShowPercent",
					25
				)
				guiObject.LimitedAmount.Label.Text = `{v6}/{expect} Left`
			end

			v5:OnChange({ "Stocks", v2.LimitedStockKey }, updateStock)
			updateStock()
		else
			local maid = Trove.new()

			-- equivalent calls inferred from this helper; original call sites unknown
			local function startTimer()
				maid:Clean()
				maid:Add(task.spawn(function()
					while officialMerch.Visible do
						local v5 = v4 - workspace:GetServerTimeNow()
						guiObject.LimitedAmount.Label.Text = not (v5 > 0) and "SOLD OUT!" or GeneralUtils.secondsConverter(v5)
						task.wait(1)
					end
				end))
			end

			officialMerch:GetPropertyChangedSignal("Visible"):Connect(function()
				if officialMerch.Visible then
					startTimer() -- equivalent call inferred; original call site unknown
				end
			end)
		end
	else
		if guiObject:IsA("GuiButton") then
			guiObject.Visible = false
		elseif guiObject:IsA("Frame") then
			guiObject.Visible = false
		end

		if guiObject == pufferfishPlushie then
			scrollingFrame.Size = UDim2.fromScale(0.98, 0.955)
		end
	end
end

function OfficialCommerceController.Start(_)
	shop.Visible = false
end

return OfficialCommerceController