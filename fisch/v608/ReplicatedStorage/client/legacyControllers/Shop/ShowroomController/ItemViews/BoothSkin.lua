local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ContentProvider")
local SalesBooth = require(ReplicatedStorage.shared.modules.SalesBooth)
local items = SalesBooth.Items
local NumberUtils = require(ReplicatedStorage.shared.utils.NumberUtils)
require(ReplicatedStorage.shared.utils.assets)
local UI = script.Parent.Parent.UI
require("../Types")
local BoothSkin = {}

function BoothSkin.GetBoothButton(_, data)
	local clone = UI.boothEntry:Clone()
	local item = items[data.Name]
	clone.Name = data.Name
	clone.detail.itemName.Text = data.Name
	clone.detail.itemType.Text = "Booth Skin"
	clone.icon.Image = data.Icon or item.Icon or ""

	if data.Price == -1 then
		clone.price.Text = "Trading Only"
		return clone
	end

	clone.price.Text = `S$ {NumberUtils:ToString(data.Price, 1)}`
	return clone
end

function BoothSkin.LoadScene(object, p, p2)
	local _ = items[p.Name]
	local clone = ReplicatedStorage.resources.models.SalesBoothSkins:FindFirstChild(p.Name):Clone()
	object:IgnorePerformance(clone)
	object:CreatePodium(clone, p2)
	clone:PivotTo(clone:GetPivot() * CFrame.fromOrientation(0, 3.141592653589793, 0))

	if not p2 then
		object:SetInfo({
			Description = nil,
			Stats = nil
		})
	end
end

return BoothSkin