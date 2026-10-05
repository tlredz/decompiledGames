local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local enchants = require(ReplicatedStorage.shared.modules.library.rods.enchants)
require(ReplicatedStorage.shared.modules.library.SharedEnchants)
local module = require("../HudController")
local module2 = require("../SettingsController")
local Default = {
	Shake = function(instance)
		local position = instance.Position
		local v = 1
		local renderSteppedConnection = nil
		renderSteppedConnection = RunService.RenderStepped:Connect(function(dt: number)
			instance.Position = position + UDim2.fromOffset(math.random(-35, 35) * v, math.random(-35, 35) * v)
			v -= dt * 60 * 0.025

			if v <= 0.05 or not instance.Parent then
				instance.Position = position

				if renderSteppedConnection then
					renderSteppedConnection:Disconnect()
					renderSteppedConnection = nil
				end
			end
		end)
	end
}

local function playExaltedTitle(clone, enchant)
	clone.Text = ""
	clone.exalted1.Text = enchant.Display:upper()
	clone.exalted1.TextColor3 = enchant.Color
	clone.exalted1.TextStrokeColor3 = enchant.StrokeColor
	clone.exalted1.Visible = true
	clone.exalted2.Text = enchant.Display:upper()
	clone.exalted2.TextColor3 = enchant.Color
	clone.exalted2.TextStrokeColor3 = enchant.StrokeColor
	clone.exalted2.Visible = true
	clone.exalted3.Visible = true
	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Circular, Enum.EasingDirection.Out)
	local tweenInfo2 = TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
	local tweenInfo3 = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
	task.delay(0.5, function()
		if not clone.Parent then
			return
		end

		TweenService:Create(clone.exalted3.UIScale, tweenInfo2, {
			Scale = 2
		}):Play()
		TweenService:Create(clone.exalted3, tweenInfo2, {
			ImageTransparency = 1
		}):Play()
	end)
	task.delay(10 - tweenInfo.Time, function()
		if not clone.Parent then
			return
		end

		clone.exalted1.UIGradient.Enabled = true
		clone.exalted2.UIGradient.Enabled = true
		TweenService:Create(clone.exalted1, tweenInfo, {
			Position = UDim2.fromScale(0.8, 0.4),
			Rotation = 5
		}):Play()
		TweenService:Create(clone.exalted2, tweenInfo, {
			Position = UDim2.fromScale(0.2, 0.6),
			Rotation = -5
		}):Play()
		task.wait(tweenInfo.Time - tweenInfo3.Time)
		TweenService:Create(clone.exalted1, tweenInfo3, {
			TextTransparency = 1,
			TextStrokeTransparency = 1
		}):Play()
		TweenService:Create(clone.exalted2, tweenInfo3, {
			TextTransparency = 1,
			TextStrokeTransparency = 1
		}):Play()
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyStandardTitle(clone, enchant)
	clone.Text = enchant.Display

	if enchant.ColorGradient then
		clone.TextColor3 = Color3.fromRGB(255, 255, 255)
		clone.UIGradient.Color = enchant.ColorGradient
	else
		clone.TextColor3 = enchant.Color
	end

	clone.TextStrokeColor3 = enchant.StrokeColor
end

function Default:Play(p2)
	local hud = module:GetHud()

	if hud:FindFirstChild("NewEnchantNotify") then
		hud.NewEnchantNotify:Destroy()
	end

	local chosenEnchant = self.chosenEnchant
	local enchant = (p2 or enchants).Enchants[chosenEnchant]

	if not enchant then
		warn((`Unknown enchantment "{chosenEnchant}"`))
		return
	end

	local isExalted = self.isExalted
	local clone = script.ui:Clone()
	clone.Name = "NewEnchantNotify"
	clone.desc.Text = enchant.Description
	clone.bg2.ImageColor3 = enchant.Color
	clone.bg.ImageColor3 = enchant.Color
	TweenService:Create(clone.bg2, TweenInfo.new(18, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, true), {
		Rotation = -365
	}):Play()

	if not module2:GetSettingValue("photosensitiveMode") then
		local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
		colorCorrectionEffect.Brightness = 0.3
		colorCorrectionEffect.Name = "EnchantFlash"
		colorCorrectionEffect.Parent = Lighting
		TweenService:Create(colorCorrectionEffect, TweenInfo.new(4, Enum.EasingStyle.Back), {
			Brightness = 0
		}):Play()
		task.delay(5, colorCorrectionEffect.Destroy, colorCorrectionEffect)
	end

	if isExalted and not enchant.ColorGradient then
		playExaltedTitle(clone, enchant)
	else
		applyStandardTitle(clone, enchant) -- equivalent call inferred; original call site unknown
	end

	local tweenInfo = TweenInfo.new(10, Enum.EasingStyle.Quint, Enum.EasingDirection.In)

	for _, v2 in { clone, clone.desc } do
		TweenService:Create(v2, tweenInfo, {
			TextTransparency = 1
		}):Play()
	end

	for _, v2 in { clone.bg, clone.bg2, clone.shine } do
		TweenService:Create(v2, tweenInfo, {
			ImageTransparency = 1
		}):Play()
	end

	clone.Parent = hud
	task.delay(10, clone.Destroy, clone)
	Default.Shake(clone)
end

return Default