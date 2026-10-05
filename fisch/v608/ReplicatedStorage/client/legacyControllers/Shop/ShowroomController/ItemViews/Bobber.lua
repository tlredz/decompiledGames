local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ContentProvider")
local emit = require(ReplicatedStorage.packages.emit)
local bobbers = require(ReplicatedStorage.shared.modules.fishing.bobbers)
local NumberUtils = require(ReplicatedStorage.shared.utils.NumberUtils)
local assets = require(ReplicatedStorage.shared.utils.assets)
local UI = script.Parent.Parent.UI
require("../Types")
local Bobber = {}

function Bobber.GetBoothButton(_, data)
	local clone = UI.boothEntry:Clone()
	local bobber = bobbers.Bobbers[data.Name]
	clone.Name = data.Name
	clone.detail.itemName.Text = data.Name
	clone.detail.itemType.Text = "Bobber"
	clone.icon.Image = data.Icon or bobber.Icon or ""

	if data.Price == -1 then
		clone.price.Text = "Trading Only"
		return clone
	end

	clone.price.Text = `S$ {NumberUtils:ToString(data.Price, 1)}`
	return clone
end

function Bobber.LoadScene(object, p, p2)
	local _ = bobbers.Bobbers[p.Name]
	local clone = assets.getAsync("bobber", p.Name):Clone()
	local VFX = clone:FindFirstChild("VFX")
	object:IgnorePerformance(clone)
	object:CreatePodium(clone, p2)

	if not p2 then
		object:SetInfo({
			Description = nil,
			VfxButtonName = VFX and "Play Cast Effect" or nil,
			TriggerVfx = function()
				emit.emit(VFX)

				for _, sound in VFX:GetDescendants() do
					if sound:IsA("Sound") then
						sound:Play()
					end
				end
			end
		})
	end
end

return Bobber