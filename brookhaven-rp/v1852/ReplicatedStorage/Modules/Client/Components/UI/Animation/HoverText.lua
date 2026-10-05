local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local UIAnimationEffects = require(ReplicatedStorage.Modules.Client.UI.UIAnimationEffects)
local v = Component.new({
	Tag = "HoverText"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local hoverText = self.Instance:FindFirstChild("HoverText")

	if not hoverText then
		error("HoverText component must be used on a GuiObject with a HoverText child")
	end

	local function hoverTweenDesc()
		TweenService:Create(hoverText, TweenInfo.new(0.2), {
			Position = UDim2.fromScale(0.5, -0.2),
			TextTransparency = 0
		}):Play()

		if hoverText:FindFirstChild("UIStroke") then
			TweenService:Create(hoverText:FindFirstChild("UIStroke"), TweenInfo.new(0.2), {
				Transparency = 0
			}):Play()
		end
	end

	local function hoverEndTweenDesc()
		TweenService:Create(hoverText, TweenInfo.new(0.2), {
			Position = UDim2.fromScale(0.5, 0.2),
			TextTransparency = 1
		}):Play()

		if hoverText:FindFirstChild("UIStroke") then
			TweenService:Create(hoverText:FindFirstChild("UIStroke"), TweenInfo.new(0.2), {
				Transparency = 1
			}):Play()
		end
	end

	hoverEndTweenDesc()
	local v2 = UIAnimationEffects.ConnectButtonHoverAndActivationFX(self.Instance, hoverText, {
		Hover = hoverTweenDesc,
		HoverEnd = hoverEndTweenDesc
	})

	for _, v3 in v2 do
		self._Janitor:Add(v3)
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v