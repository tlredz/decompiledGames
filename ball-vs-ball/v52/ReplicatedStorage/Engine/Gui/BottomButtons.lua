local Players = game:GetService("Players")
local QuickPlay = require(script.QuickPlay)
local TradingSignButton = require(script.TradingSignButton)
return {
	Init = function()
		local waitForChild = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("下方按钮区"):WaitForChild("区域")
		waitForChild.Visible = true
		QuickPlay.Init()
		TradingSignButton.Init()
	end
}