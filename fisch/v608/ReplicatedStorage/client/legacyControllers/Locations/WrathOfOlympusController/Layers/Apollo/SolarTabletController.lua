local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage.packages.Net)
local Component = require(ReplicatedStorage.packages.Component)
local Trove = require(ReplicatedStorage.packages.Trove)
local fx = require(ReplicatedStorage.shared.modules.fx)
require(ReplicatedStorage.shared.utils.GeneralUtils)
local solarTablet = Component.new({
	Tag = "ApolloSolarTablet"
})
local SolarTabletController = {
	SolarTablet = solarTablet
}
local _ = {
	Inactive = 0,
	Chorus = 1,
	Activated = 2
}
local cframe = CFrame.new(
	1.41101074,
	1.02441406,
	-0.489746094,
	0.364467293,
	1.49011612e-8,
	0.931215227,
	-9.23871994e-7,
	1.00000167,
	-1.88499689e-6,
	-0.931215763,
	1.49011612e-7,
	0.364467889
)
local cframe2 = CFrame.new(
	-0.403320312,
	-2.22387695,
	-2.07769775,
	1.00000203,
	-1.49102914e-6,
	-1.7285347e-6,
	-1.49102914e-6,
	0.999996245,
	3.91697597e-7,
	-1.7285347e-6,
	3.91697597e-7,
	1.00000262
)
local v2 = {
	[0] = Color3.fromRGB(71, 71, 71),
	[1] = Color3.fromRGB(71, 57, 41),
	[2] = Color3.fromRGB(191, 154, 109)
}
local v3 = {
	[0] = 5,
	[1] = 5,
	[2] = 0.25
}

function solarTablet:Construct()
	self.Trove = Trove.new()
end

function solarTablet:Flash()
	if self.Instance:FindFirstChild("FlashHighlight") then
		return
	end

	local highlight = Instance.new("Highlight")
	highlight.FillColor = Color3.fromRGB(0, 34, 255)
	highlight.FillTransparency = 10
	highlight.OutlineColor = Color3.fromRGB(255, 235, 176)
	highlight.OutlineTransparency = 0.99
	highlight.Enabled = true
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.Name = "FlashHighlight"
	highlight.Parent = self.Instance
	local tween = TweenService:Create(highlight, TweenInfo.new(2, Enum.EasingStyle.Linear), {
		FillTransparency = 1
	})
	tween.Completed:Once(function()
		highlight:Destroy()
		tween:Destroy()
	end)
	tween:Play()
end

function solarTablet:UpdateState(flag: boolean)
	local state = self.Instance:GetAttribute("State") or 0
	local primaryPart = self.Instance.PrimaryPart
	local cFrame

	if state >= 1 then
		cFrame = primaryPart.CFrame * cframe2
	else
		cFrame = primaryPart.CFrame * cframe
	end

	local color = v2[state]
	local v6 = v3[state]

	for _, child in self.Instance:GetChildren() do
		if child.Name == "MoonPart" then
			if flag then
				child.CFrame = cFrame
			else
				TweenService:Create(child, TweenInfo.new(v6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
					CFrame = cFrame
				}):Play()
			end
		elseif child.Name == "SunPart" or child.Name == "Cracks" then
			if flag then
				child.Color = color
			else
				TweenService:Create(child, TweenInfo.new(v6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
					Color = color
				}):Play()
			end
		end
	end

	if state == 2 and not flag then
		fx:PlaySound(script.Activate, primaryPart)
		self:Flash()
	end
end

function solarTablet:Start()
	self.Trove:Add(self.Instance:GetAttributeChangedSignal("State"):Connect(function()
		self:UpdateState(false)
	end))
	self:UpdateState(true)
end

function solarTablet.Stop(p)
	if p.Trove then
		p.Trove:Destroy()
	end
end

function SolarTabletController.Start(_) end

return SolarTabletController