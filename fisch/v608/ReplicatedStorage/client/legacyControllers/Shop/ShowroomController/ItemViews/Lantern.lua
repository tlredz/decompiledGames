local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ContentProvider")
local lanterns = require(ReplicatedStorage.shared.modules.library.lanterns)
local NumberUtils = require(ReplicatedStorage.shared.utils.NumberUtils)
local assets = require(ReplicatedStorage.shared.utils.assets)
local UI = script.Parent.Parent.UI
require("../Types")
local Lantern = {}

function Lantern.GetBoothButton(_, data)
	local clone = UI.boothEntry:Clone()
	local lantern = lanterns[data.Name]
	clone.Name = data.Name
	clone.detail.itemName.Text = data.Name
	clone.detail.itemType.Text = "Lantern"
	clone.icon.Image = data.Icon or lantern.Icon or ""

	if data.Price == -1 then
		clone.price.Text = "Trading Only"
		return clone
	end

	clone.price.Text = `S$ {NumberUtils:ToString(data.Price, 1)}`
	return clone
end

function Lantern.LoadScene(object, p, p2)
	local _ = lanterns[p.Name]
	local clone = assets.getAsync("lantern", p.Name):Clone()
	object:IgnorePerformance(clone)

	if not p2 then
		local v = 0
		local v2 = 0
		local color = nil

		for _, v3 in clone:QueryDescendants("Light") do
			v = math.max(v, v3.Brightness)
			v2 = math.max(v2, v3.Range)

			if color then
				color = color:Lerp(v3.Color, 0.5)
			else
				color = v3.Color
			end
		end

		local stats = { `Brightness: {math.round(v * 100)}%`, (`Light Range: {math.round(v2)}m`) }

		if color then
			table.insert(stats, (`Light Color: <font color="#{color:ToHex()}">#{color:ToHex()}</font>`))
		end

		if clone:HasTag("FloatingLantern") then
			table.insert(stats, "Animated Movement")
		end

		object:SetInfo({
			Description = nil,
			Stats = stats
		})
	end

	object:CreatePodium(clone, p2)
end

return Lantern