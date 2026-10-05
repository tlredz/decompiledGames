local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BossMastery = require(ReplicatedStorage.Data.BossMastery)
local ButtonFX = require(ReplicatedStorage.Client.UI.VFX.ButtonFX)
local Simple = require(ReplicatedStorage.Packages.FormatNumber.Simple)
return table.freeze({
	New = function(instance, parent, p, layoutOrder: number, callback)
		local clone = instance:Clone()
		clone.Name = p.Id
		clone.LayoutOrder = layoutOrder
		clone.Visible = true
		clone.Parent = parent
		local frame = clone.Frame
		local eggName = frame.EggName
		local outputEgg = frame.OutputEgg
		local quantityLabel = frame.Quantity.QuantityLabel
		local buy = frame.Buy
		local price = buy.PriceHolder.Price
		local v = false
		outputEgg.Image = p.Icon
		local v2 = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function refresh()
			eggName.Text = BossMastery.GetShopDisplayName(p)
			price.Text = Simple.FormatCompact(BossMastery.GetShopPrice(p), ".#")
			quantityLabel.Text = BossMastery.GetShopQuantityText(p)
		end

		local function setPending(flag: boolean)
			v = flag
			buy.Active = not flag
			buy.Interactable = not flag
			buy.AutoButtonColor = not flag
		end

		local buttonFX = ButtonFX(buy, 1.05, function()
			if not v then
				callback(p, v2)
			end
		end)
		v2 = {
			Refresh = refresh,
			SetPending = setPending,
			Destroy = function()
				buttonFX()
				clone:Destroy()
			end
		}
		refresh() -- equivalent call inferred; original call site unknown
		return v2
	end
})