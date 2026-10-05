local Tab = {}
Tab.__index = Tab
local v = {
	Volume = 0.3,
	PlaybackSpeed = 0.95
}

local function playTabClick()
	task.spawn(function()
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		require(ReplicatedStorage.SharedUtils.Audio):Play("Sounds.UI.EventCalendar.paper3", v)
	end)
end

function Tab.Init(_, helpers)
	local self = setmetatable({}, Tab)
	self.helpers = helpers
	self.tweens = helpers.tweens
	self:LoadStylesheet()
	return self
end

function Tab:LoadStylesheet()
	local tweens = self.tweens

	function Tab.base(p2)
		tweens.saveInitials(p2)
		local nav = p2.Parent:FindFirstChild("Nav")

		if nav then
			for _, button in ipairs(nav:GetChildren()) do
				if button:IsA("GuiButton") then
					button.Activated:Connect(playTabClick)
				end
			end
		end
	end

	Tab.states = {
		active = function(p2, object)
			object:AddConnection(p2, "state", p2.Hover.MouseEnter:Connect(function()
				tweens.playTween(p2, TweenInfo.new(0.15, Enum.EasingStyle.Circular), {
					Position = tweens.getInitial(p2, "Position") - UDim2.fromScale(0, 0.02)
				})
				p2.Outline.Visible = true
				p2.Outline.ImageTransparency = 1
				p2.Outline.UIGradient.Offset = Vector2.new(0, 0)
				tweens.playTween(p2.Outline, TweenInfo.new(0.15, Enum.EasingStyle.Circular), {
					ImageTransparency = 0
				})
			end))
			object:AddConnection(p2, "state", p2.Hover.MouseLeave:Connect(function()
				tweens.playTween(p2, TweenInfo.new(0.15, Enum.EasingStyle.Circular), {
					Position = tweens.getInitial(p2, "Position")
				})
				tweens.playTween(p2.Outline, TweenInfo.new(0.15, Enum.EasingStyle.Circular), {
					ImageTransparency = 1
				})
			end))
		end,
		inactive = function(_, _) end
	}
	Tab.flags = {}
end

return Tab