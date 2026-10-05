local TextButton = {}
TextButton.__index = TextButton

function TextButton.Init(_, helpers)
	local self = setmetatable({}, TextButton)
	self.helpers = helpers
	self.tweens = helpers.tweens
	self:LoadStylesheet()
	return self
end

function TextButton:LoadStylesheet()
	local tweens = self.tweens
	local _ = self.helpers.isState
	local _ = self.helpers.getState
	local _ = self.helpers.addConnection
	local _ = self.helpers.clearConnections

	function TextButton.base(p2)
		tweens.saveInitials(p2)
	end

	TextButton.states = {
		active = function(data, object)
			data.UIScale.Scale = 1
			data.Inactive.Visible = false
			data.Title.UIStroke.Color = Color3.fromRGB(0, 0, 0)
			data.Title.TextTransparency = 0
			object:AddConnection(data, "state", data.MouseEnter:Connect(function()
				tweens.playTween(data.UIScale, TweenInfo.new(0.15, Enum.EasingStyle.Circular), {
					Scale = 1.1
				})
			end))
			object:AddConnection(data, "state", data.MouseLeave:Connect(function()
				tweens.playTween(data.UIScale, TweenInfo.new(0.15, Enum.EasingStyle.Circular), {
					Scale = 1
				})
			end))
			object:AddConnection(data, "state", data.MouseButton1Click:Connect(function()
				task.spawn(function()
					tweens.playTween(data, TweenInfo.new(0.15, Enum.EasingStyle.Circular), {
						AnchorPoint = Vector2.new(0.5, 0.4)
					})
					task.wait(0.15)
					tweens.playTween(data, TweenInfo.new(0.15, Enum.EasingStyle.Circular), {
						AnchorPoint = Vector2.new(0.5, 0.5)
					})
				end)
			end))
		end,
		inactive = function(data, object)
			object:ClearConnections(data, "state")
			data.UIScale.Scale = 1
			data.Inactive.Visible = true

			if data.Background.ImageColor3 == Color3.fromRGB(255, 255, 255) then
				data.Title.UIStroke.Color = Color3.fromRGB(143, 143, 143)
				data.Title.TextTransparency = 0.5
			end
		end
	}
	TextButton.flags = {
		glowing = function(instance, p2, _)
			if not p2 then
				instance.Glow.Visible = false
				return
			end

			instance.Glow.ImageTransparency = 1
			instance.Glow.Visible = true
			local v = tweens.playTween(
				instance.Glow,
				TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
				{
					ImageTransparency = 0
				}
			)

			while instance:GetAttribute("glowing") do
				wait(1)
			end

			v:Cancel()
		end,
		hovered = function(instance, p2, _)
			if p2 then
				if not instance:FindFirstChild("UIScale") then
					return
				end

				tweens.playTween(instance.UIScale, TweenInfo.new(0.25, Enum.EasingStyle.Circular), {
					Scale = 1.1
				})
			else
				if not instance:FindFirstChild("UIScale") then
					return
				end

				tweens.playTween(instance.UIScale, TweenInfo.new(0.25, Enum.EasingStyle.Circular), {
					Scale = 1
				})
			end
		end
	}
end

return TextButton