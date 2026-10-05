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

	function Button.base(instance, object)
		tweens.saveInitials(instance)
		local MouseOver = require(game.ReplicatedStorage.SharedUtils.MouseOver)
		local mouseEnterLeaveEvent, v = MouseOver.MouseEnterLeaveEvent(instance)
		instance:SetAttribute("Hovered", false)
		object:AddConnection(instance, "mouse", mouseEnterLeaveEvent:Connect(function()
			instance:SetAttribute("Hovered", true)
		end))
		object:AddConnection(instance, "mouse", v:Connect(function()
			instance:SetAttribute("Hovered", false)
		end))
	end

	Button.states = {}
	Button.flags = {
		Hovered = function(instance, p2, _)
			if instance:GetAttribute("Selected") == true then
				return
			end

			if p2 then
				tweens.playTween(instance, TweenInfo.new(0.25), {
					BackgroundTransparency = 0.4
				})
				local uIStroke = instance:FindFirstChild("UIStroke")

				if uIStroke then
					uIStroke.Enabled = false
				end

				for _, label in pairs(instance:GetChildren()) do
					if label:IsA("TextLabel") then
						tweens.playTween(label, TweenInfo.new(0.25), {
							TextColor3 = Color3.fromRGB(1, 12, 6)
						})
					end
				end
			else
				tweens.playTween(instance, TweenInfo.new(0.25), {
					BackgroundTransparency = 1
				})
				local uIStroke = instance:FindFirstChild("UIStroke")

				if uIStroke then
					uIStroke.Enabled = true
				end

				for _, label in pairs(instance:GetChildren()) do
					if label:IsA("TextLabel") then
						tweens.playTween(label, TweenInfo.new(0.25), {
							TextColor3 = Color3.fromRGB(13, 204, 71)
						})
					end
				end
			end
		end,
		Selected = function(instance, p2, _)
			tweens.playTween(instance, TweenInfo.new(0.25), {
				BackgroundTransparency = p2 and 0.4 or 1
			})
			local uIStroke = instance:FindFirstChild("UIStroke")

			if uIStroke then
				uIStroke.Enabled = true
			end

			for _, label in pairs(instance:GetChildren()) do
				if label:IsA("TextLabel") then
					tweens.playTween(label, TweenInfo.new(0.25), {
						TextColor3 = p2 and Color3.fromRGB(1, 12, 6) or Color3.fromRGB(13, 204, 71)
					})
				end
			end
		end
	}
end

return Button