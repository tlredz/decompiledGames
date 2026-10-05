local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
require3(ReplicatedStorage2.Packages.Net)
local v = require3(ReplicatedStorage2.Common.Utils)
local v2 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v3 = require3(ReplicatedStorage2.Shared.TournamentData)
local v4 = require3(ReplicatedStorage2.Shared.MapData)
local tournaments = ReplicatedStorage2.Controllers.Tournaments
local v5 = require3(tournaments.TournamentsController)
local v6 = require3(tournaments.UI.TournamentsUIController)
require3(ReplicatedStorage2.ClientGameModules.FFlagClient)
local _ = Players.LocalPlayer
local play = v6.TabsFolder.Play
local coinsPopup = v6.TabsFolder.CoinsPopup
return {
	Start = function(_)
		local v7 = nil

		for k, coinTournament in v3.CoinTournaments do
			local child = play.List:FindFirstChild((`Option{k}`))

			if not child then
				continue
			end

			child.EntryFee.Amount.Text = v.ValueConvertor:AddCommas(coinTournament.EntryFee)
			child.Prize.Amount.Text = v.ValueConvertor:AddCommas(coinTournament.Reward)
			child.MapImage.Map.Image = v4[coinTournament.Map].Image
			local v8 = k
			local v9 = coinTournament
			child.Activated:Connect(function()
				if v7 then
					return
				end

				v7 = v8
				coinsPopup.Body.Text = `<stroke thickness="3" color="rgb(4,13,26)">The entry fee is <font color="rgb(254, 201, 43)">{v.ValueConvertor:AddCommas(v9.EntryFee)} Coins</font>. Would you like to proceed?</stroke>`
				v6:SwitchView("CoinsPopup")
			end)
		end

		coinsPopup.Close.Activated:Connect(function()
			v7 = nil
			v6:SwitchView("Play")
		end)
		coinsPopup.Buttons.Decline.Activated:Connect(function()
			v7 = nil
			v6:SwitchView("Play")
		end)
		local v8 = false
		coinsPopup.Buttons.Accept.Activated:Connect(function()
			if not v7 or v8 then
				return
			end

			v8 = true
			local success, result = pcall(function()
				return v5.Remotes.JoinGlobalTournament:InvokeServer({
					type = "Coin",
					index = v7
				})
			end)
			v8 = false

			if success and result then
				v7 = nil
				v2:Close("Tournaments")
				v6:SwitchView("Play")
				v6:PromptGlobal()
			end
		end)
		coinsPopup:GetPropertyChangedSignal("Visible"):Connect(function()
			if not coinsPopup.Visible and v7 then
				v7 = nil
			end
		end)
	end
}