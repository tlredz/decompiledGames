local Pin = {}
Pin.__index = Pin

function Pin.Init(_, helpers)
	local self = setmetatable({}, Pin)
	self.helpers = helpers
	self.tweens = helpers.tweens
	self:LoadStylesheet()
	return self
end

function Pin:LoadStylesheet()
	local tweens = self.tweens
	local _ = self.helpers.isState
	local _ = self.helpers.getState
	local _ = self.helpers.addConnection
	local _ = self.helpers.clearConnections

	function Pin.base(p2)
		tweens.saveInitials(p2)
	end

	Pin.states = {
		open = function(state, _)
			state.Background.ImageTransparency = 1
			state.UIScale.Scale = 2.5
			state.Visible = true
			tweens.playTween(state.Background, TweenInfo.new(1, Enum.EasingStyle.Elastic), {
				ImageTransparency = 0
			})
			tweens.playTween(state.UIScale, TweenInfo.new(1, Enum.EasingStyle.Elastic), {
				Scale = 1
			})

			local function shiver(duration, p2)
				tweens.playTween(state.Background, TweenInfo.new(duration, Enum.EasingStyle.Exponential), {
					Position = UDim2.fromScale(0.5 + p2, 0.5)
				})
				task.wait(duration)
				tweens.playTween(state.Background, TweenInfo.new(duration * 2, Enum.EasingStyle.Exponential), {
					Position = UDim2.fromScale(0.5 - p2, 0.5)
				})
				task.wait(duration * 2)
				tweens.playTween(state.Background, TweenInfo.new(duration, Enum.EasingStyle.Exponential), {
					Position = state.Background:GetAttribute("start_Position")
				})
			end

			shiver(0.025, 0.1)
		end,
		closed = function(p2, _)
			p2.Visible = false
		end
	}
	Pin.flags = {
		templateFlag = function(_, _, _) end
	}
end

return Pin