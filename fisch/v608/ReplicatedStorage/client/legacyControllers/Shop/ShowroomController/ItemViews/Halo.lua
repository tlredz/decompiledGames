local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ContentProvider")
local halos = require(ReplicatedStorage.shared.modules.library.halos)
local NumberUtils = require(ReplicatedStorage.shared.utils.NumberUtils)
local assets = require(ReplicatedStorage.shared.utils.assets)
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)
local UI = script.Parent.Parent.UI
require("../Types")
local Halo = {}

function Halo.GetBoothButton(_, data)
	local clone = UI.boothEntry:Clone()
	local halo = halos[data.Name]
	clone.Name = data.Name
	clone.detail.itemName.Text = data.Name
	clone.detail.itemType.Text = "Halo"
	clone.icon.Image = data.Icon or halo.Icon or ""

	if data.Price == -1 then
		clone.price.Text = "Trading Only"
		return clone
	end

	clone.price.Text = `S$ {NumberUtils:ToString(data.Price, 1)}`
	return clone
end

function Halo.LoadScene(object, p, p2)
	local halo = halos[p.Name]
	local clone = assets.getAsync("halo", p.Name):Clone()
	object:IgnorePerformance(clone)

	if not p2 then
		if halo.AllowColorCustomization then
			local settingValue = SettingsController:GetSettingValue("haloColor")
			local color = Color3.fromRGB(settingValue.r, settingValue.g, settingValue.b)

			for _, instance in clone:QueryDescendants(".HaloColorablePart") do
				if instance:IsA("BasePart") then
					instance.Color = color
				elseif instance:IsA("ParticleEmitter") or instance:IsA("Beam") then
					instance.Color = ColorSequence.new(color)
				elseif instance:IsA("SurfaceAppearance") then
					instance.EmissiveTint = color
				end
			end
		end

		object:SetInfo({
			Description = nil,
			Stats = { (`Color: {halo.AllowColorCustomization and "Custom" or "Fixed"}`) }
		})
	end

	object:CreatePodium(clone, p2)
	clone:PivotTo(clone:GetPivot() * CFrame.new(0, 5, 0) * CFrame.fromOrientation(0, 3.141592653589793, 0))
end

return Halo