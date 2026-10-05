local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DevProducts = require(ReplicatedStorage.Modules.Shared.PlayerData.DevProducts)
local GetProductInfo = require(ReplicatedStorage.Modules.Shared.Utils.GetProductInfo)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "ProductPriceLabel"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v.Start(p)
	local v2 = DevProducts.All[p.Instance:GetAttribute("ProductName")]
	local v3, v4 = GetProductInfo(DevProducts.GetId(v2), Enum.InfoType.Product)

	if v3 and v4 ~= nil then
		p.Instance.Text = "" .. v4.PriceInRobux
	else
		p.Instance.Text = "Purchase Now!"
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v