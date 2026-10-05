local Button = {}
Button.__index = Button

function Button.Init(_, helpers)
	local self = setmetatable({}, Button)
	self.helpers = helpers
	self.tweens = helpers.tweens
	self:LoadStylesheet()
	return self
end

function Button:LoadStylesheet()
	local tweens = self.tweens
	local _ = self.helpers.isState
	local _ = self.helpers.getState
	local _ = self.helpers.addConnection
	local _ = self.helpers.clearConnections
	local SoundService = game:GetService("SoundService")
	local Debris = game:GetService("Debris")

	local function playRandomSound(instance)
		local children = instance:GetChildren()

		if #children == 0 then
			return
		end

		local v = children[math.random(1, #children)]
		local clone = v:Clone()
		clone.Parent = v.Parent
		clone:Play()
		Debris:AddItem(clone, v.TimeLength + 1)
	end

	function Button.base(button, object)
		tweens.saveInitials(button)
		local MouseOver = require(game.ReplicatedStorage.SharedUtils.MouseOver)
		local mouseEnterLeaveEvent, v = MouseOver.MouseEnterLeaveEvent(button)
		button:SetAttribute("Hovered", false)
		object:AddConnection(button, "mouse", mouseEnterLeaveEvent:Connect(function()
			button:SetAttribute("Hovered", true)
		end))
		object:AddConnection(button, "mouse", v:Connect(function()
			button:SetAttribute("Hovered", false)
		end))

		if button:IsA("GuiButton") then
			object:AddConnection(button, "click", button.Activated:Connect(function()
				playRandomSound(SoundService.UI.Clicks)
			end))
		end
	end

	Button.states = {}
	Button.flags = {
		Hovered = function(instance, p2, _)
			local uIScale = instance:FindFirstChildWhichIsA("UIScale")

			if not uIScale then
				for _, child in ipairs(instance:GetChildren()) do
					local uIScale2 = child:FindFirstChildWhichIsA("UIScale")

					if not uIScale2 then
						continue
					end

					uIScale = uIScale2
					break
				end
			end

			if p2 then
				playRandomSound(SoundService.UI.Hover)

				if uIScale then
					tweens.playTween(uIScale, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {
						Scale = 1.15
					})
				end
			elseif uIScale then
				tweens.playTween(uIScale, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {
					Scale = 1
				})
			end
		end,
		Selected = function(_, _, _) end
	}
end

return Button