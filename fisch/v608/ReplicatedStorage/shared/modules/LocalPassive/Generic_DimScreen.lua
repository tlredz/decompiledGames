local TweenService = game:GetService("TweenService")
game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local module = require("./PassiveHandler")
local HudController = require(ReplicatedStorage.client.legacyControllers.HudController)
local GenericDimScreen = {
	NoMock = true,
	MorphSpear = true,
	MorphHarpoon = true,
	Morph = function(p, _, object)
		local v = p.reelTrove:Add(script.darken:Clone())
		v.BackgroundTransparency = 1
		v.BackgroundColor3 = p.config.OverlayColor or Color3.fromRGB(0, 0, 0)
		v.Parent = HudController:GetOverlayGui()
		TweenService:Create(v, TweenInfo.new(p.config.FadeInTime), {
			BackgroundTransparency = p.config.OverlayTransprency
		}):Play()
		object:AddCleanupDelay(p.config.FadeOutTime)
		object.OnMinigameEnd:Connect(function()
			local tween = TweenService:Create(v, TweenInfo.new(p.config.FadeOutTime), {
				BackgroundTransparency = 1
			})
			tween.Completed:Once(function()
				v:Destroy()
				tween:Destroy()
			end)
			tween:Play()
		end)
	end
}
setmetatable(GenericDimScreen, module)
return GenericDimScreen