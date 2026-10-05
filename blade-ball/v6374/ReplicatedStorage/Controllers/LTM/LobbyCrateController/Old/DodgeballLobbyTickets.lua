local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

if require3(ReplicatedStorage2.ServerInfo).isLTMServer() then
	return {}
end

local v = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v2 = require3(ReplicatedStorage2.Packages.Replion)
require3(ReplicatedStorage2.ClientGameModules.FFlagClient)
local v3 = require3(ReplicatedStorage2.Shared.LTMCrateData)
require3(ReplicatedStorage2.Common.MarketplaceService)
local v4 = require3(ReplicatedStorage2.Common.Utils)
local v5 = require3(ReplicatedStorage2.ClientGameModules.CreatePriceLabel)
require3(ReplicatedStorage2.Common.Utils.Utilities.ValueConvertor)
local v6 = require3(ReplicatedStorage2.Controllers.Trading.TradeTokensController)
local v7 = ReplicatedStorage2.Shared.LTM.GetLTM:Invoke("Dodgeball")
local playerGui = Players.LocalPlayer.PlayerGui
local ticketName = v7.TicketName
local dodgeballLobbyTickets = nil
return {
	Start = function(_)
		dodgeballLobbyTickets = playerGui:WaitForChild("DodgeballLobbyTickets")
		dodgeballLobbyTickets.Enabled = false
		dodgeballLobbyTickets.Tickets.CloseButton.Activated:Connect(function()
			v:Open("DodgeballLobbyCrate")
		end)

		for _, button in dodgeballLobbyTickets.Tickets.Frame:GetChildren() do
			if not button:IsA("ImageButton") then
				continue
			end

			local match = button.Name:match("^%d+$")

			if not match then
				continue
			end

			local v8 = match

			local function hookupButton()
				v6:PromptPurchase(v8, Enum.InfoType.Product)
			end

			local buyButton = button:WaitForChild("BuyButton")
			buyButton.Activated:Connect(hookupButton)
			v5(buyButton.Price, match, "DevProduct", "%s")
		end

		task.spawn(function()
			local v8 = v2.Client:WaitReplion("Data")

			-- equivalent calls inferred from this helper; original call sites unknown
			local function update()
				local v9 = v8:Get(ticketName) or 0
				dodgeballLobbyTickets.Tickets.Counter.Amount.Text = v4.ValueConvertor:AddCommas(v9)
			end

			v8:OnChange(ticketName, update)
			update() -- equivalent call inferred; original call site unknown
		end)
		local v8 = v7.getGameMode() == "Storm" and 5 or 1
		v4.Thread.Every(v8, function()
			local dateTime = DateTime.fromUnixTimestamp(workspace:GetServerTimeNow())
			local formatTimeWithDaysFull = v4.ValueConvertor:FormatTimeWithDaysFull(v3.TimeLength.UnixTimestamp - dateTime.UnixTimestamp)
			dodgeballLobbyTickets.Tickets.Timer.Text = `{formatTimeWithDaysFull}`
		end)
	end
}