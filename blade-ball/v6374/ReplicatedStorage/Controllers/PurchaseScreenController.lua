local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local TweenService = game:GetService("TweenService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local playerGui = Players.LocalPlayer.PlayerGui
local v = require3(ReplicatedStorage2.Packages.Net)
local v2 = require3(ReplicatedStorage2.Packages.Signal)
local remoteEvent = v:RemoteEvent("ProductPurchaseFinished")
local v3 = v2.new()
local v4 = {}
local v5 = {}
local robloxPurchaseScreenBlackout = playerGui:WaitForChild("RobloxPurchaseScreenBlackout")

function onPurchaseUpdated()
	local v6 = v4[1]
	local _ = v6.ProductId
	local wasPurchased = v6.WasPurchased

	if #v5 > 0 then
		for _, v7 in ipairs(v5) do
			v7:Destroy()
		end

		table.clear(v5)
	end

	if wasPurchased then
		robloxPurchaseScreenBlackout.Blackout.BackgroundTransparency = 1
		robloxPurchaseScreenBlackout.Spinner.ImageTransparency = 0
		robloxPurchaseScreenBlackout.Spinner.Rotation = 0
		robloxPurchaseScreenBlackout.Enabled = true
		local tween = TweenService:Create(
			robloxPurchaseScreenBlackout.Blackout,
			TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
			{
				BackgroundTransparency = 0.2
			}
		)
		local tween2 = TweenService:Create(
			robloxPurchaseScreenBlackout.Spinner,
			TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
			{
				Rotation = 360
			}
		)
		tween:Play()
		tween2:Play()
		table.remove(v4, 1)
	else
		local tween = TweenService:Create(
			robloxPurchaseScreenBlackout.Blackout,
			TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
			{
				BackgroundTransparency = 1
			}
		)
		local tween2 = TweenService:Create(
			robloxPurchaseScreenBlackout.Spinner,
			TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
			{
				ImageTransparency = 1
			}
		)
		tween:Play()
		tween2:Play()
		tween2.Completed:Once(function()
			robloxPurchaseScreenBlackout.Enabled = false
		end)
		table.remove(v4, 1)
	end
end

function addPendingPurchase(productId: number, wasPurchased: boolean)
	table.insert(v4, {
		ProductId = productId,
		WasPurchased = wasPurchased
	})
	v3:Fire()
end

return {
	Start = function(_)
		v3:Connect(onPurchaseUpdated)
		remoteEvent.OnClientEvent:Connect(addPendingPurchase)
		_G.AddPendingPurchase = addPendingPurchase
	end
}