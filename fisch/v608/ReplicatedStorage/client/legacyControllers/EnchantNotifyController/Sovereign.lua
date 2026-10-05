local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
game:GetService("Lighting")
local ContentProvider = game:GetService("ContentProvider")
local enchants = require(ReplicatedStorage.shared.modules.library.rods.enchants)
require(ReplicatedStorage.shared.modules.library.SharedEnchants)
local fish = require(ReplicatedStorage.shared.modules.library.fish)
local GeneralUtils = require(ReplicatedStorage.shared.utils.GeneralUtils)
local module = require("../HudController")
local module2 = require("../SettingsController")
local color = Color3.fromRGB(255, 255, 255)
local Sovereign = {
	CreateAffix = function(name: string, layoutOrder: number, p)
		local enchant = p.Enchants[name]

		if not enchant then
			warn((`Unknown affix "{name}"`))
			return nil
		end

		local icon = ""

		for _, v2 in fish do
			if not (typeof(v2) == "table" and v2.RelicGroup == enchant.RelicGroup) then
				continue
			end

			icon = v2.Icon or ""
			break
		end

		local clone = script.affixTemplate:Clone()
		clone.Name = name
		clone.LayoutOrder = layoutOrder
		clone.glow1.ImageColor3 = enchant.StrokeColor
		clone.glow2.ImageColor3 = enchant.StrokeColor
		clone.affixName.TextColor3 = enchant.Color
		clone.affixName.UIStroke.Color = enchant.StrokeColor
		clone.desc.TextColor3 = enchant.Color
		clone.desc.UIStroke.Color = enchant.StrokeColor
		clone.affixName.Text = enchant.Display
		clone.desc.Text = enchant.Description
		clone.relicIcon.Image = icon
		clone.glow1.ImageTransparency = 1
		clone.glow2.ImageTransparency = 1
		clone.affixName.Visible = false
		clone.desc.Visible = false
		clone.relicIcon.ImageTransparency = 1
		clone.relicIcon.Position = UDim2.fromScale(0.5, 1.25)
		clone.relicIcon.Size = UDim2.fromScale(0.5, 0.5)
		task.delay(layoutOrder * 0.25 + 0, function()
			if not clone.Parent then
				return
			end

			clone.relicIcon.Visible = true

			if not module2:GetSettingValue("photosensitiveMode") then
				clone.glow1.ImageColor3 = color
				clone.glow2.ImageColor3 = color
			end

			TweenService:Create(clone.relicIcon, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1, 1),
				ImageTransparency = 0
			}):Play()
			clone.glow1.Visible = true
			clone.glow2.Visible = true
			TweenService:Create(clone.glow1, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
				ImageTransparency = 0
			}):Play()
			TweenService:Create(clone.glow2, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
				ImageTransparency = 0.65
			}):Play()
			task.wait(0.5)

			if not clone.Parent then
				return
			end

			clone.relicIcon.Visible = false
			clone.glow1.ImageTransparency = 0
			clone.glow1.Visible = true
			clone.glow2.ImageTransparency = 0.65
			clone.glow2.Visible = true
			TweenService:Create(clone.glow1, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
				ImageColor3 = enchant.StrokeColor
			}):Play()
			TweenService:Create(clone.glow2, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
				ImageColor3 = enchant.StrokeColor
			}):Play()
			clone.affixName.TextColor3 = enchant.StrokeColor
			clone.affixName.Visible = true
			clone.affixName.UIStroke.Color = color
			clone.desc.TextColor3 = enchant.StrokeColor
			clone.desc.UIStroke.Color = color
			clone.desc.Visible = true
			TweenService:Create(clone.affixName, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
				TextColor3 = enchant.Color
			}):Play()
			TweenService:Create(clone.affixName.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
				Color = enchant.StrokeColor
			}):Play()
			TweenService:Create(clone.desc, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
				TextColor3 = enchant.Color
			}):Play()
			TweenService:Create(clone.desc.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
				Color = enchant.StrokeColor
			}):Play()
		end)
		return clone
	end
}

function Sovereign:Play(p2)
	local v = p2 or enchants
	local playerGui = module:GetPlayerGui()
	local hud = module:GetHud()
	hud.Enabled = false
	local backpackGui = module:GetBackpackGui()
	backpackGui.Enabled = false
	local deviceInsetGui = module:GetDeviceInsetGui()
	deviceInsetGui.Enabled = false

	if playerGui:FindFirstChild("sovereignEnchant") then
		playerGui.sovereignEnchant:Destroy()
	end

	local enchant = v.Enchants[self.mainEnchant]

	if not enchant then
		warn((`Unknown enchantment "{self.mainEnchant}"`))
		return
	end

	local clone = script.sovereignEnchant:Clone()
	local uiContent = clone.sovContainer.uiContent
	local mainEnchant = uiContent.mainEnchant
	local lastTime = tick()
	local v2 = {}
	local icons = {}

	for _, affix in self.affixes do
		local enchant2 = v.Enchants[affix]

		if enchant2 then
			v2[enchant2.RelicGroup] = true
		end
	end

	for _, v3 in fish do
		if typeof(v3) == "table" and v3.RelicGroup and v2[v3.RelicGroup] then
			table.insert(icons, v3.Icon)
		end
	end

	ContentProvider:PreloadAsync(icons)
	ContentProvider:PreloadAsync({ clone, script.affixTemplate })
	task.wait(1 - (tick() - lastTime))
	local colorGradient = enchant.ColorGradient or ColorSequence.new(enchant.Color)
	mainEnchant.enchantName.Text = enchant.Display
	mainEnchant.desc.Text = enchant.Description
	local colorSequenceKeypoints = table.create(#colorGradient.Keypoints)

	for k, keypoint in colorGradient.Keypoints do
		colorSequenceKeypoints[k] = ColorSequenceKeypoint.new(keypoint.Time, keypoint.Value:Lerp(color, 0.6))
	end

	uiContent.bg.UIGradient.Color = ColorSequence.new(colorSequenceKeypoints)
	mainEnchant.flare.Rotation = -20
	TweenService:Create(mainEnchant.flare, TweenInfo.new(2, Enum.EasingStyle.Quint), {
		Rotation = -8
	}):Play()
	uiContent.confirmButton.UIGradient.Color = colorGradient
	uiContent.confirmButton.glow1.UIGradient.Color = colorGradient
	uiContent.confirmButton.UIStroke.UIGradient.Color = colorGradient

	if module2:GetSettingValue("photosensitiveMode") then
		mainEnchant.glow1.UIGradient.Color = colorGradient
		mainEnchant.flare.UIGradient.Color = colorGradient
		mainEnchant.enchantName.UIGradient.Color = colorGradient
		mainEnchant.desc.UIGradient.Color = colorGradient
		mainEnchant.flare.ImageTransparency = 1
		TweenService:Create(mainEnchant.flare, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
			ImageTransparency = 0
		}):Play()
	else
		local colorSequence = ColorSequence.new(color)
		mainEnchant.glow1.UIGradient.Color = colorSequence
		mainEnchant.flare.UIGradient.Color = colorSequence
		mainEnchant.enchantName.UIGradient.Color = colorSequence
		mainEnchant.desc.UIGradient.Color = colorSequence
		local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quart)
		local v3 = {
			Color = colorGradient
		}
		GeneralUtils.gradientTween(mainEnchant.glow1.UIGradient, tweenInfo, v3)
		GeneralUtils.gradientTween(mainEnchant.flare.UIGradient, tweenInfo, v3)
		GeneralUtils.gradientTween(mainEnchant.enchantName.UIGradient, tweenInfo, v3)
		GeneralUtils.gradientTween(mainEnchant.desc.UIGradient, tweenInfo, v3)
		clone.sovContainer.overlay.UIGradient.Color = colorGradient
		clone.sovContainer.overlay.ImageTransparency = 0
		TweenService:Create(clone.sovContainer.overlay, tweenInfo, {
			ImageTransparency = 1
		}):Play()
	end

	for k, affix in self.affixes do
		local affix2 = Sovereign.CreateAffix(affix, k, v)

		if affix2 then
			affix2.Parent = uiContent.affixes
		end
	end

	clone:GetPropertyChangedSignal("Enabled"):Connect(function()
		if not clone.Enabled then
			local hud = module:GetHud()
			hud.Enabled = true
			local backpackGui = module:GetBackpackGui()
			backpackGui.Enabled = true
			local deviceInsetGui = module:GetDeviceInsetGui()
			deviceInsetGui.Enabled = true
			task.wait()
			clone:Destroy()
		end
	end)
	uiContent.confirmButton.Activated:Once(function()
		local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear)

		for _, descendant in clone:GetDescendants() do
			if descendant:IsA("ImageLabel") or descendant:IsA("ImageButton") or descendant:IsA("ViewportFrame") then
				TweenService:Create(descendant, tweenInfo, {
					ImageTransparency = 1,
					BackgroundTransparency = 1
				}):Play()
			elseif descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
				TweenService:Create(descendant, tweenInfo, {
					TextTransparency = 1,
					BackgroundTransparency = 1
				}):Play()
			elseif descendant:IsA("GuiObject") then
				TweenService:Create(descendant, tweenInfo, {
					BackgroundTransparency = 1
				}):Play()
			elseif descendant:IsA("UIStroke") then
				TweenService:Create(descendant, tweenInfo, {
					Transparency = 1
				}):Play()
			end
		end

		task.wait(tweenInfo.Time)
		clone.Enabled = false
	end)
	clone:AddTag("Window")
	clone.Enabled = true
	clone.Parent = playerGui
end

return Sovereign