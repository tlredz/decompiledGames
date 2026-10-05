local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require3(ReplicatedStorage2.Shared.PlayerUtility)
require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v = require3(ReplicatedStorage2.Shared.Statable)
require3(ReplicatedStorage2.Packages.Charm)
require3(ReplicatedStorage2.Packages.Freeze)
require3(ReplicatedStorage2.Shared.Action)
local v2 = require3(ReplicatedStorage2.Packages.Trove)
require3(ReplicatedStorage2.Packages.Net)
require3(ReplicatedStorage2.Packages.Replion)
local v3 = require3(ReplicatedStorage2.Common.Utils)
local v4 = require3(ReplicatedStorage2.Shared.VirtualGridScroll)
local v5 = require3(ReplicatedStorage2.Common.MarketplaceService)
require3(ReplicatedStorage2.Shared.StatableCleaner)
require3(ReplicatedStorage2.Controllers.Trading.IndexController)
require3(ReplicatedStorage2.Shared.Inventory.InventoryTypes)
local _ = require3(ReplicatedStorage2.Shared.Inventory).Client
require3(ReplicatedStorage2.Shared.DataViewer)
local v6 = require3(ReplicatedStorage2.Shared.StatableCleaner)
local v7 = require3(ReplicatedStorage2.Controllers.AdminPanel.AdminPanelUIController)
local transactions = v7.AdminPanelUI.Window.Content.Pages.Transactions
local scrollingFrame = transactions.Pages.RobuxPurchases.ScrollingFrame
local scrollingFrame2 = transactions.Pages.GiftHistory.ScrollingFrame
local color = Color3.fromRGB(0, 85, 127)
local color2 = Color3.fromRGB(170, 85, 0)
return {
	Start = function(_)
		v7.LoadUserAction.Signal:Connect(function(p)
			local replion = p.Replion
			local maid = v7.UserTrove:Extend()
			local v8 = maid:Add(v4({
				Template = scrollingFrame.UIGridLayout.Template,
				Container = scrollingFrame,
				Constructor = function(data, p2, _)
					local granted = data.Granted or data.Tokens
					local receiptId

					if data.ReceiptId then
						receiptId = data.ReceiptId
					else
						receiptId = data.Tokens and "Token Purchase" or "Unknown"
					end

					local v9 = maid:Add(v2.new())
					p2.Frame.Date.Text = DateTime.fromUnixTimestamp(data.Time):FormatLocalTime("LLL", "en-us")
					p2.Frame.ID.Text = `Product ID: {data.ProductId}`
					p2.Frame.Amount.Text = not data.Price and "Free" or `{data.Tokens and "💰" or utf8.char(57346)} {v3.ValueConvertor:AddCommas(data.Price)}` or "Free"
					p2.Frame.TransactionID.Text = `Transaction ID: {receiptId}`
					p2.Frame.Pending.Text = `{granted and "Granted" or data.Price and "Pending" or "Granted?"} {not data.Attempts and "" or "[" .. data.Attempts .. "]" or ""}`
					p2.Frame.Pending.TextColor3 = granted and Color3.new(0, 1, 0) or data.Price and Color3.new(1, 0, 0) or Color3.new(
						1,
						1,
						0
					)
					p2.Frame.ProductName.Text = "Loading..."
					local product

					if data.Type == "DevProduct" then
						product = Enum.InfoType.Product
					elseif data.Type == "GamePass" then
						product = Enum.InfoType.GamePass
					else
						product = data.Type
					end

					v9:AddPromise(v5:GetProductInfoAsync(data.ProductId, product):andThen(function(p3)
						p2.Frame.ProductName.Text = p3.Name
						p2.ProfileImage.Icon.Image = `rbxassetid://{p3.IconImageAssetId}`
					end):catch(warn))
					return function()
						v9:Destroy()
					end
				end,
				Sort = function(p2, p3)
					return p2.Time > p3.Time
				end
			}))
			local v9 = maid:Add(v4({
				Template = scrollingFrame2.UIGridLayout.Template,
				Container = scrollingFrame2,
				Constructor = function(data, p2, _)
					local sender = data.Sender or data.Receiver or "Unknown"
					local v10 = maid:Add(v2.new())
					local frame = p2.Frame
					local backgroundColor

					if data.WasSent then
						backgroundColor = color
					else
						backgroundColor = color2
					end

					frame.BackgroundColor3 = backgroundColor
					p2.Frame.Date.Text = DateTime.fromUnixTimestamp(data.Time):FormatLocalTime("LLL", "en-us")
					p2.Frame.ID.Text = `Product ID: {data.ProductId}`
					p2.Frame.UserId.Text = `{data.WasSent and "Sent to: " or "Received from: "} {sender}`
					p2.Frame.TransactionID.Text = `Transaction ID: {data.ReceiptId or "Unknown"}`
					p2.Frame.ProductName.Text = "Loading..."
					p2.Frame.Amount.Text = "Loading..."
					v10:AddPromise(v5:GetProductInfoAsync(data.ProductId, Enum.InfoType.Product):andThen(function(data2)
						p2.Frame.ProductName.Text = data2.Name
						p2.ProfileImage.Icon.Image = `rbxassetid://{data2.IconImageAssetId}`
						p2.Frame.Amount.Text = `{utf8.char(57346)} {v3.ValueConvertor:AddCommas(data2.PriceInRobux)}`
					end):catch(warn))
					return function()
						v10:Destroy()
					end
				end,
				Sort = function(p2, p3)
					return p2.Time > p3.Time
				end
			}))

			local function onLoad()
				local maid2 = maid:Add(v6.new())
				local v10 = maid2:Add(v.State("RobuxPurchases"))
				local _ = {
					1927019289,
					1927019288,
					1927019290,
					1927019291,
					1599945740,
					1599946040,
					1599944759,
					1599946789,
					1599946917
				}

				for _, v11 in replion:Get("Data.RobuxPurchases") or {} do
					v8.AddInstance(v11)
				end

				local v11 = replion:Get("Data.GiftHistory") or {
					Received = {},
					Sent = {}
				}

				for _, v12 in v11.Received do
					v9.AddInstance(v12)
				end

				for _, v12 in v11.Sent do
					v12.WasSent = true
					v9.AddInstance(v12)
				end

				maid2:Add(v.Computed(function(callback)
					local v12 = callback(v10)

					for _, guiObject in transactions.Tabs:GetChildren() do
						if not guiObject:IsA("GuiObject") then
							continue
						end

						local backgroundColor

						if guiObject.Name == v12 then
							backgroundColor = Color3.fromRGB(33, 107, 226)
						else
							backgroundColor = Color3.fromRGB(74, 74, 74)
						end

						guiObject.BackgroundColor3 = backgroundColor
					end

					for _, guiObject in transactions.Pages:GetChildren() do
						if guiObject:IsA("GuiObject") then
							guiObject.Visible = guiObject.Name == v12
						end
					end

					return nil
				end))

				for _, button in transactions.Tabs:GetChildren() do
					if not button:IsA("GuiButton") then
						continue
					end

					local v12 = button
					maid:Add(button.Activated:Connect(function()
						v10:Set(v12.Name)
					end))
				end
			end

			if replion:Get("Loaded") then
				maid:Add(task.spawn(onLoad))
			else
				maid:Add(replion:OnChange("Loaded", onLoad))
			end
		end)
	end
}