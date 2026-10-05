local MissedEaster = {}
MissedEaster.__index = MissedEaster
local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Circular)
local object = setmetatable({}, {
	__mode = "k"
})

function MissedEaster.Init(_, helpers)
	local self = setmetatable({}, MissedEaster)
	self.helpers = helpers
	self.tweens = helpers.tweens
	self:LoadStylesheet()
	return self
end

function MissedEaster:LoadStylesheet()
	local tweens = self.tweens

	function MissedEaster.base(p2)
		tweens.saveInitials(p2)
	end

	MissedEaster.states = {}
	MissedEaster.flags = {
		missed = function(instance, p2, object2)
			object2:ClearConnections(instance, "missed")

			if object[instance] then
				object[instance]:Cancel()
				object[instance] = nil
			end

			if not p2 then
				return
			end

			local parent = instance.Parent.Parent
			local uIScale = instance.Retry.UIScale
			object2:AddConnection(instance, "missed", parent.TextButton.MouseEnter:Connect(function()
				tweens.playTween(uIScale, tweenInfo, {
					Scale = 1.2
				})
			end))
			object2:AddConnection(instance, "missed", parent.TextButton.MouseLeave:Connect(function()
				tweens.playTween(uIScale, tweenInfo, {
					Scale = 1
				})
			end))
			local random = Random.new(parent.LayoutOrder)
			instance.Background.Rotation = (random:NextInteger(1, 4) - 1) * 90
			local pollen = instance:FindFirstChild("Pollen")

			if pollen then
				pollen.BackgroundTransparency = random:NextNumber(0.3, 0.5)
				object[instance] = tweens.playTween(
					pollen,
					TweenInfo.new(random:NextNumber(2, 3), Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
					{
						BackgroundTransparency = 0
					}
				)
			end
		end
	}
end

return MissedEaster