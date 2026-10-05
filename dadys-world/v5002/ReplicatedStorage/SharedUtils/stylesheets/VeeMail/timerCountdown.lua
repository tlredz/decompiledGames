local TimerCountdown = {}
TimerCountdown.__index = TimerCountdown

function TimerCountdown.Init(_, helpers)
	local self = setmetatable({}, TimerCountdown)
	self.helpers = helpers
	self.tweens = helpers.tweens
	self:LoadStylesheet()
	return self
end

function TimerCountdown:LoadStylesheet()
	local tweens = self.tweens
	local _ = self.helpers.isState
	local _ = self.helpers.getState
	local _ = self.helpers.addConnection
	local _ = self.helpers.clearConnections
	local copyLabel = nil
	local v = nil

	function TimerCountdown:base(object)
		tweens.saveInitials(self)
		self.Visible = false
		object:AddConnection(self, "visible", self:GetPropertyChangedSignal("Visible"):Connect(function()
			self:SetAttribute("Active", self.Visible)
		end))
		copyLabel = self:FindFirstChild("CopyLabel")

		if copyLabel then
			copyLabel.TextColor3 = Color3.fromRGB(0, 255, 47)
			v = tweens.playTween(
				copyLabel,
				TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
				{
					TextTransparency = 0.75
				}
			)
			v:Cancel()
		end
	end

	TimerCountdown.states = {}
	TimerCountdown.flags = {
		Active = function(_, p2, _)
			if not (v and copyLabel) then
				return
			end

			if not p2 then
				v:Cancel()
				return
			end

			copyLabel.TextTransparency = 0
			v:Play()
		end
	}
end

return TimerCountdown