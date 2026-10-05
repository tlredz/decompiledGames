local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

if not require3(ReplicatedStorage2.ServerInfo).isLTMServer() then
	return {}
end

local v = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v2 = require3(ReplicatedStorage2.Packages.Replion)
require3(ReplicatedStorage2.ClientGameModules.FFlagClient)
require3(ReplicatedStorage2.Common.MarketplaceService)
local v3 = require3(game.ReplicatedStorage.Shared.LTM)
local v4 = require3(ReplicatedStorage2.Common.Utils)
local v5 = require3(ReplicatedStorage2.ClientGameModules.CreatePriceLabel)
require3(ReplicatedStorage2.Common.Utils.Utilities.ValueConvertor)
local v6 = require3(ReplicatedStorage2.Controllers.Trading.TradeTokensController)
local playerGui = Players.LocalPlayer.PlayerGui
local currentLTM = v3.getCurrentLTM()
local ticketName = currentLTM and currentLTM.TicketName
local lTMTickets = nil
return {
	Start = function(_)
		lTMTickets = playerGui:WaitForChild("LTMTickets")
		lTMTickets.Enabled = false
		lTMTickets.Tickets.CloseButton.Activated:Connect(function()
			v:Open("LTMCrate")
		end)

		for _, button in lTMTickets.Tickets.Frame:GetChildren() do
			if not button:IsA("ImageButton") then
				continue
			end

			local match = button.Name:match("^%d+$")

			if not match then
				continue
			end

			local v7 = match

			local function hookupButton()
				v6:PromptPurchase(v7, Enum.InfoType.Product)
			end

			local buyButton = button:WaitForChild("BuyButton")
			button.MouseButton1Click:Connect(hookupButton)
			buyButton.MouseButton1Click:Connect(hookupButton)
			v5(buyButton.Price, match, "DevProduct", "%s")
		end

		task.spawn(function()
			while true do
				lTMTickets.Tickets.Timer.Text = currentLTM and currentLTM.getTimeLeftDHMS() or ""
				task.wait(1)
			end
		end)
		task.spawn(function()
			local v7 = v2.Client:WaitReplion("Data")

			-- equivalent calls inferred from this helper; original call sites unknown
			local function update()
				local v8 = v7:Get(ticketName) or 0
				lTMTickets.Tickets.Counter.Amount.Text = v4.ValueConvertor:AddCommas(v8)
			end

			update() -- equivalent call inferred; original call site unknown
			v7:OnChange(ticketName, update)
		end)
	end
}