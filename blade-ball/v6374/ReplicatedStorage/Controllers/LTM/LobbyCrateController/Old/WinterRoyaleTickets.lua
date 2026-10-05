local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.ServerInfo)
local v2 = require3(ReplicatedStorage2.Shared.LTM)

if not (v.isLTMServer() and table.find(v2.serverProfiles, "WinterRoyale")) then
	return {}
end

local activeLTM = v2.getActiveLTM("WinterRoyale")
local v3 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v4 = require3(ReplicatedStorage2.Packages.Replion)
require3(ReplicatedStorage2.ClientGameModules.FFlagClient)
require3(ReplicatedStorage2.Common.MarketplaceService)
local v5 = require3(ReplicatedStorage2.Common.Utils)
local v6 = require3(ReplicatedStorage2.ClientGameModules.CreatePriceLabel)
require3(ReplicatedStorage2.Common.Utils.Utilities.ValueConvertor)
local v7 = require3(ReplicatedStorage2.Controllers.Trading.TradeTokensController)
local playerGui = Players.LocalPlayer.PlayerGui
local ticketName = activeLTM.TicketName
local lTMTickets = nil
return {
	Start = function(_)
		lTMTickets = playerGui:WaitForChild("LTMTickets")
		lTMTickets.Enabled = false
		lTMTickets.Tickets.CloseButton.Activated:Connect(function()
			v3:Open("LTMCrate")
		end)

		for _, button in lTMTickets.Tickets.Frame:GetChildren() do
			if not button:IsA("ImageButton") then
				continue
			end

			local match = button.Name:match("^%d+$")

			if not match then
				continue
			end

			local v8 = match

			local function hookupButton()
				v7:PromptPurchase(v8, Enum.InfoType.Product)
			end

			local buyButton = button:WaitForChild("BuyButton")
			button.MouseButton1Click:Connect(hookupButton)
			buyButton.MouseButton1Click:Connect(hookupButton)
			v6(buyButton.Price, match, "DevProduct", "%s")
		end

		task.spawn(function()
			while true do
				lTMTickets.Tickets.Timer.Text = activeLTM.getTimeLeftDHMS()
				task.wait(1)
			end
		end)
		task.spawn(function()
			local v8 = v4.Client:WaitReplion("Data")

			-- equivalent calls inferred from this helper; original call sites unknown
			local function update()
				local v9 = v8:Get(ticketName) or 0
				lTMTickets.Tickets.Counter.Amount.Text = v5.ValueConvertor:AddCommas(v9)
			end

			update() -- equivalent call inferred; original call site unknown
			v8:OnChange(ticketName, update)
		end)
	end
}