local BookmarkButton = {}
BookmarkButton.__index = BookmarkButton

function BookmarkButton.Init(_, helpers)
	local self = setmetatable({}, BookmarkButton)
	self.helpers = helpers
	self.tweens = helpers.tweens
	self:LoadStylesheet()
	return self
end

function BookmarkButton:LoadStylesheet()
	local tweens = self.tweens
	local _ = self.helpers.isState
	local _ = self.helpers.getState
	local _ = self.helpers.addConnection
	local _ = self.helpers.clearConnections

	function BookmarkButton.base(instance, object)
		tweens.saveInitials(instance)
		instance:SetAttribute("save_ZIndex", instance.ZIndex)
		object:AddConnection(instance, "state", instance.MouseEnter:Connect(function()
			tweens.playTween(instance.Background, TweenInfo.new(0.15, Enum.EasingStyle.Circular), {
				Position = instance.Background:GetAttribute("start_Position") - UDim2.fromScale(0.1, 0)
			})
		end))
		object:AddConnection(instance, "state", instance.MouseLeave:Connect(function()
			tweens.playTween(instance.Background, TweenInfo.new(0.15, Enum.EasingStyle.Circular), {
				Position = instance.Background:GetAttribute("start_Position")
			})
		end))
	end

	BookmarkButton.states = {
		selected = function(state, object)
			tweens.playTween(state.Background, TweenInfo.new(0.15, Enum.EasingStyle.Circular), {
				Position = state.Background:GetAttribute("start_Position") - UDim2.fromScale(0.5, 0)
			})
			tweens.playTween(state.UIScale, TweenInfo.new(0.15, Enum.EasingStyle.Circular), {
				Scale = 1.2
			})
			task.spawn(function()
				local _ = state.Parent.Display
				task.wait(0.15)
			end)
			task.wait(0.15)

			for _, button in pairs(state.Parent:GetChildren()) do
				if not (button:IsA("TextButton") and button:GetAttribute("save_ZIndex") and button ~= state) then
					continue
				end

				object:SetState(button, "unSelected")
			end

			state.ZIndex = 22
			tweens.playTween(state.Background, TweenInfo.new(0.15, Enum.EasingStyle.Circular), {
				Position = state.Background:GetAttribute("start_Position")
			})
		end,
		unSelected = function(instance, _)
			tweens.playTween(instance.UIScale, TweenInfo.new(0.15, Enum.EasingStyle.Circular), {
				Scale = 1
			})

			if instance.ZIndex ~= instance:GetAttribute("save_ZIndex") then
				tweens.playTween(instance.Background, TweenInfo.new(0.15, Enum.EasingStyle.Cubic), {
					Position = instance.Background:GetAttribute("start_Position") - UDim2.fromScale(0.5, -0.2)
				})
				task.wait(0.15)
				instance.ZIndex = instance:GetAttribute("save_ZIndex")
				tweens.playTween(instance.Background, TweenInfo.new(0.25, Enum.EasingStyle.Cubic), {
					Position = instance.Background:GetAttribute("start_Position")
				})
			end
		end
	}
	BookmarkButton.flags = {
		templateFlag = function(_, _, _) end
	}
end

return BookmarkButton