local parent = script.Parent
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Color = require(ReplicatedStorage.ClientGameModules.Color)
local mouse = game.Players.LocalPlayer:GetMouse()
local flag = false
local now = tick() - 15
local MarketplaceService = require(ReplicatedStorage.Common.MarketplaceService)
local v = ReplicatedStorage.Remotes.GetVIPInformation:InvokeServer()
local isVIP = v.IsVIP
local swordColor = v.SwordColor
game:GetService("RunService")
parent.Activated:Connect(function()
	if flag or tick() - now < (isVIP and 2.5 or 15) then
		return
	end

	now = tick()

	if isVIP then
		flag = true
		local v2 = Color.New(parent.Parent, mouse, {
			Position = UDim2.new(0.35, 0, 0.35, 0)
		})
		v2:SetColor(swordColor)
		v2.Finished:Connect(function(p)
			flag = false
			ReplicatedStorage.Remotes.ChangeSwordColor:FireServer(p)
			swordColor = ReplicatedStorage.Remotes.GetVIPInformation:InvokeServer().SwordColor
		end)
		v2.Canceled:Connect(function()
			flag = false
		end)
	else
		isVIP = ReplicatedStorage.Remotes.GetVIPInformation:InvokeServer().IsVIP

		if not isVIP then
			MarketplaceService:PromptGamePassPurchase(game.Players.LocalPlayer, 223367086)
		end
	end
end)