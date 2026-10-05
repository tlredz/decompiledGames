local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local HighlightController = require(ReplicatedStorage.Modules.Client.UI.Effects.HighlightController)
local v = Component.new({
	Tag = "HighlightEffect"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self.Instance.Visible = false
	self.tag = self.Instance:GetAttribute("HighlightTag")
end

function v:Start()
	self._Janitor:Add(HighlightController.OnHighlightEnabled:Connect(function(p: string)
		self:OnEnableHighlight(p)
	end))
end

function v:OnEnableHighlight(p: string)
	if p ~= self.tag or self.Instance.Visible then
		return
	end

	self.Instance.Visible = true
	local lightRay = self.Instance:FindFirstChild("LightRay")

	if lightRay and lightRay:IsA("ImageLabel") then
		self.tween = TweenService:Create(
			lightRay,
			TweenInfo.new(0.65, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, -1, true, 0),
			{
				ImageTransparency = 0.65
			}
		)
		self.tween:Play()
		self._Janitor:Add(self.tween)
	end

	local parent = self.Instance.Parent

	if parent:IsA("ImageButton") then
		self._Janitor:Add(parent.MouseButton1Click:Connect(function()
			if self.tween then
				self.tween:Cancel()
				self.tween = nil
			end

			self.tweenHide = TweenService:Create(
				lightRay,
				TweenInfo.new(0.65, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0),
				{
					ImageTransparency = 1
				}
			)
			self.tweenHide:Play()
			self._Janitor:Add(self.tweenHide)
		end))
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v