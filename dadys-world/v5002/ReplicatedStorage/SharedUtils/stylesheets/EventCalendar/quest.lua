local Quest = {}
Quest.__index = Quest

function Quest.Init(_, helpers)
	local self = setmetatable({}, Quest)
	self.helpers = helpers
	self.tweens = helpers.tweens
	self:LoadStylesheet()
	return self
end

function Quest:LoadStylesheet()
	local tweens = self.tweens

	function Quest.base(p2)
		tweens.saveInitials(p2)
	end

	Quest.states = {
		incomplete = function(p2)
			p2.Background.ImageColor3 = Color3.fromRGB(184, 172, 135)
			p2.Completed.Visible = false
		end,
		complete = function(data)
			data.Background.ImageColor3 = Color3.fromRGB(145, 184, 95)
			data.Completed.Visible = true
			data.Completed.ImageTransparency = 1
			data.Completed.UIScale.Scale = 1.3
			data.UIScale.Scale = 1
			tweens.playTween(
				data.UIScale,
				TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut, 0, true),
				{
					Scale = 0.95
				}
			)
			tweens.playTween(data.Completed, TweenInfo.new(0.15, Enum.EasingStyle.Exponential), {
				ImageTransparency = 0
			})
			tweens.playTween(data.Completed.UIScale, TweenInfo.new(0.15, Enum.EasingStyle.Exponential), {
				Scale = 1
			})
		end
	}
	Quest.flags = {}
end

return Quest