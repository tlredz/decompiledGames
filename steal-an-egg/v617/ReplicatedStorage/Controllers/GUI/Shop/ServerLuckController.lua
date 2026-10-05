local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ButtonFX = require(ReplicatedStorage.Client.UI.VFX.ButtonFX)
local Constants = require(ReplicatedStorage.Shared.Globals.Constants)
local Time = require(ReplicatedStorage.Shared.Utils.Time)
local timecode = Time.Timecode
local GUI = require(ReplicatedStorage.Client.GUI)
local Marketplace = require(ReplicatedStorage.Shared.Utils.Marketplace)
local price = Marketplace.Price
local Products = require(ReplicatedStorage.Data.Products)
local Storefront = require(ReplicatedStorage.Client.Functions.Storefront)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local ServerLuck = require(ReplicatedStorage.Shared.Types.ServerLuck)
return {
	Start = function()
		if Constants.IS_STUDIO then
			assert(Products.Directory.ServerLuck_X2, "ServerLuck_X2 product not found in Products directory")
			assert(Products.Directory.ServerLuck_X4, "ServerLuck_X4 product not found in Products directory")
			assert(Products.Directory.ServerLuck_X8, "ServerLuck_X8 product not found in Products directory")
		end

		local serverLuck = GUI.Shop():FindFirstChild("ServerLuck", true)

		if serverLuck == nil then
			return
		end

		local serverLuckMain = serverLuck:FindFirstChild("Main") or serverLuck
		local expiresIn = serverLuckMain:WaitForChild("ExpiresIn")
		local buyButton = serverLuckMain:WaitForChild("BuyButton")
		local price2 = buyButton:WaitForChild("Price")
		local available = serverLuckMain:WaitForChild("Available")
		local _1 = available:WaitForChild("1")
		local _2 = available:WaitForChild("2")
		local buttonsWithExtension = serverLuckMain:WaitForChild("ButtonsWithExtension")
		local list = buttonsWithExtension:WaitForChild("List")
		local _15Min = list:WaitForChild("15Min")
		local _30Min = list:WaitForChild("30Min")
		local v = {
			Multiplier = 1
		}

		-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
		local function getNextMultiplier(multiplier: number)
			if multiplier < 2 then
				return 2
			end

			if multiplier < 4 then
				return 4
			end

			return 8
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateLuckTimer(p: number)
			expiresIn.Text = not (p > 0) and "<font color=\"rgb(255, 0, 0)\">15 mins</font>" or `<stroke color="rgb(0,0,0)" joins="round" thickness="2"><font color="rgb(255, 0, 0)">{timecode(p)}</font></stroke>`
		end

		local function updateUI()
			updateLuckTimer(not v.ExpiresAt and 0 or math.max(0, v.ExpiresAt - workspace:GetServerTimeNow())) -- equivalent call inferred; original call site unknown
			serverLuckMain.Available.Visible = v.Multiplier ~= 8
			serverLuckMain.MaxedOut.Visible = v.Multiplier == 8
			buttonsWithExtension.Visible = v.Multiplier > 1

			if v.Multiplier < 8 then
				local nextMultiplier = getNextMultiplier(v.Multiplier)
				_1.Text = `<stroke color="rgb(0,0,0)" joins="round" thickness="2">{v.Multiplier}<font color="rgb(56, 232, 57)"></font></stroke>x`
				_2.Text = `<stroke color="rgb(0,0,0)" joins="round" thickness="2"><font color="rgb(56, 232, 57)">{nextMultiplier}</font></stroke>x`
				local v3 = Products.Directory[`ServerLuck_X{nextMultiplier}`]

				if v3 then
					price2.Text = `{price(v3.ProductId, Enum.InfoType.Product) or 0}`
				end

				if buttonsWithExtension.Visible then
					local serverLuck_Extend15 = Products.Directory.ServerLuck_Extend15

					if serverLuck_Extend15 then
						_15Min.Text = `{price(serverLuck_Extend15.ProductId, Enum.InfoType.Product) or 0}`
					end

					local serverLuck_Extend30 = Products.Directory.ServerLuck_Extend30

					if serverLuck_Extend30 then
						_30Min.Text = `{price(serverLuck_Extend30.ProductId, Enum.InfoType.Product) or 0}`
					end
				end
			else
				price2.Text = "Maxed"
			end
		end

		ButtonFX(buyButton, nil, function()
			if v.Multiplier < 8 then
				local nextMultiplier = getNextMultiplier(v.Multiplier)
				local v2 = Products.Directory[`ServerLuck_X{nextMultiplier}`]

				if v2 then
					Storefront.Prompt(v2.ProductId, true)
				end
			end
		end)
		ButtonFX(_15Min, nil, function()
			local serverLuck_Extend15 = v.Multiplier > 1 and Products.Directory.ServerLuck_Extend15

			if serverLuck_Extend15 then
				Storefront.Prompt(serverLuck_Extend15.ProductId, true)
			end
		end)
		ButtonFX(_30Min, nil, function()
			local serverLuck_Extend30 = v.Multiplier > 1 and Products.Directory.ServerLuck_Extend30

			if serverLuck_Extend30 then
				Storefront.Prompt(serverLuck_Extend30.ProductId, true)
			end
		end)
		Remotes.LuckWindow.StateRefreshed.OnClientEvent:Connect(function(p)
			if ServerLuck.State(p) then
				v = p
				updateUI()
			end
		end)
		local success, result = pcall(function()
			return Remotes.LuckWindow.FetchState:InvokeServer()
		end)

		if success and type(result) == "table" and ServerLuck.State(result) then
			v = result
			updateUI()
		end

		RunService.Heartbeat:Connect(function()
			if v.ExpiresAt then
				updateUI()
			end
		end)
	end
}