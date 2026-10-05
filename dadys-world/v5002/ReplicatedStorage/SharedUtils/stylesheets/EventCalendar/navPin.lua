local NavPin = {}
NavPin.__index = NavPin

function NavPin.Init(_, helpers)
	local self = setmetatable({}, NavPin)
	self.helpers = helpers
	self.tweens = helpers.tweens
	self:LoadStylesheet()
	return self
end

function NavPin:LoadStylesheet()
	local tweens = self.tweens

	function NavPin.base() end

	NavPin.states = {
		opening = function(state, object)
			local background = state.Background
			background.ImageTransparency = 1
			state.UIScale.Scale = 2.5
			state.Visible = true
			tweens.playTween(background, TweenInfo.new(1, Enum.EasingStyle.Elastic), {
				ImageTransparency = 0
			})
			tweens.playTween(state.UIScale, TweenInfo.new(1, Enum.EasingStyle.Elastic), {
				Scale = 1
			})

			local function shiver(duration: number, p2: number)
				tweens.playTween(background, TweenInfo.new(duration, Enum.EasingStyle.Exponential), {
					Position = UDim2.fromScale(p2 + 0.5, 0.5)
				})
				task.wait(duration)
				tweens.playTween(background, TweenInfo.new(duration * 2, Enum.EasingStyle.Exponential), {
					Position = UDim2.fromScale(0.5 - p2, 0.5)
				})
				task.wait(duration * 2)
				tweens.playTween(background, TweenInfo.new(duration, Enum.EasingStyle.Exponential), {
					Position = background:GetAttribute("start_Position")
				})
			end

			task.wait(1)
			shiver(0.025, 0.0025)
			task.wait(0.25)
			object:SetState(state, "active")
		end,
		active = function(data, object)
			object:ClearConnections(data, "state")
			data.Background.ImageColor3 = Color3.fromRGB(255, 255, 255)
			object:AddConnection(data, "state", data.MouseEnter:Connect(function()
				tweens.playTween(data.UIScale, TweenInfo.new(0.15, Enum.EasingStyle.Circular), {
					Scale = 1.2
				})
			end))
			object:AddConnection(data, "state", data.MouseLeave:Connect(function()
				tweens.playTween(data.UIScale, TweenInfo.new(0.15, Enum.EasingStyle.Circular), {
					Scale = 1
				})
			end))
		end,
		inactive = function(p2, object)
			object:ClearConnections(p2, "state")
			p2.Background.ImageColor3 = Color3.fromRGB(86, 86, 86)
		end
	}
	NavPin.flags = {}
end

return NavPin