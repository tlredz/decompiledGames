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
local v3 = require3(ReplicatedStorage2.Shared.LTM)
local v4 = require3(ReplicatedStorage2.Common.Utils)
local v5 = require3(ReplicatedStorage2.ClientGameModules.CreatePriceLabel)
require3(ReplicatedStorage2.Common.Utils.Utilities.ValueConvertor)
local v6 = require3(ReplicatedStorage2.Controllers.Trading.TradeTokensController)
local v7 = require3(ReplicatedStorage2.Packages.Trove)
local playerGui = Players.LocalPlayer.PlayerGui
return {
	Start = function(_)
		local id = nil
		local maid = v7.new()

		local function UpdateMode()
			local currentLTM = v3.getCurrentLTM()

			if not currentLTM or id ~= nil and id == currentLTM.Id then
				return
			end

			maid:Clean()
			local lobbyCrateWindow = currentLTM.LobbyCrateWindow or "LobbyCrate"
			local lobbyTicketsWindow = currentLTM.LobbyTicketsWindow or "LobbyTickets"
			id = currentLTM.Id
			local child = playerGui:WaitForChild(lobbyTicketsWindow)
			child.Enabled = false
			child.Main.Tickets.Header.Text = string.upper((`{currentLTM.getModeName()} ltm`))

			for _, button in child.Main.Tickets.Frame:GetChildren() do
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
				maid:Connect(buyButton.MouseButton1Click, hookupButton)
				v5(buyButton.Price, match, "DevProduct", "%s")
			end

			maid:Connect(child.Main.Tickets.CloseButton.Activated, function()
				if lobbyCrateWindow then
					v:Open(lobbyCrateWindow)
				end
			end)
			local v8 = v2.Client:WaitReplion("Data")

			-- equivalent calls inferred from this helper; original call sites unknown
			local function update()
				local v9 = v8:Get(currentLTM.TicketName) or 0
				child.Main.Tickets.Counter.Amount.Text = v4.ValueConvertor:AddCommas(v9)
			end

			maid:Add(v8:OnChange(currentLTM.TicketName, update))
			update() -- equivalent call inferred; original call site unknown
		end

		UpdateMode()
		v3.OnModeChange(function()
			UpdateMode()
		end)
	end
}