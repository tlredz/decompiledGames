local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local _ = ReplicatedStorage2.Packages
local v = require3(ReplicatedStorage2.Packages.Replion)
local clientGameModules = ReplicatedStorage2.ClientGameModules
require3(ReplicatedStorage2.Common.MarketplaceService)
local v2 = require3(ReplicatedStorage2.ClientGameModules.CreatePriceLabel)
require3(clientGameModules.GuiHandler)
local v3 = require3(ReplicatedStorage2.Shared.HourlyWheelData)
local v4 = require3(ReplicatedStorage2.Packages.Net)
local v5 = require3(ReplicatedStorage2.Controllers.Trading.TradeTokensController)
local v6 = require3(script.Parent.Parent)
local v7 = nil
local v8 = nil
local wrappedChildSingle = nil
local PurchaseSpin = {
	Update = function(self)
		local visible = v8:Get((`{v3.ReplionPath}.SpinPurchases`)) <= 0
		self.Object.Amount2.Position = visible and UDim2.fromScale(0.642, 0.5) or UDim2.fromScale(0.48, 0.5)
		self.Object.Amount2.Slash.Visible = visible
		self.Object.Amount.Visible = visible
		self.Object.Fade.Visible = visible
	end,
	Hook = function(self, p)
		v7 = v4:RemoteEvent("HourlyWheel/ProcessRoll")
		v8 = v.Client:WaitReplion("Data")
		wrappedChildSingle = v6:GetWrappedChildSingle("Spinner")
		p.Container.Activated:Connect(function()
			if not wrappedChildSingle then
				wrappedChildSingle = v6:GetWrappedChildSingle("Spinner")
			end

			if wrappedChildSingle.IsSpinning then
				return
			end

			if v8:Get((`{v3.ReplionPath}.SpinPurchases`)) <= 0 then
				v5:PromptPurchase(v3.Products.Spinx1First, Enum.InfoType.Product)
			else
				v5:PromptPurchase(v3.Products.Spinx1, Enum.InfoType.Product)
			end
		end)
		v8:OnChange(`{v3.ReplionPath}.SpinPurchases`, function()
			self:Update()
		end)
		self:Update()
		v2(self.Object.Amount, v3.Products.Spinx1First, "DevProduct", "%s")
		v2(self.Object.Amount2, v3.Products.Spinx1, "DevProduct", "%s")
	end
}

function PurchaseSpin:Init(object)
	local v9 = {
		Container = object
	}
	self.Object = object
	PurchaseSpin:Hook(v9)
	return v9
end

return PurchaseSpin