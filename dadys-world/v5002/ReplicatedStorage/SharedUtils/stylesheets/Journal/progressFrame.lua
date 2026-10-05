local ProgressFrame = {}
ProgressFrame.__index = ProgressFrame

function ProgressFrame.Init(_, helpers)
	local self = setmetatable({}, ProgressFrame)
	self.helpers = helpers
	self.tweens = helpers.tweens
	self:LoadStylesheet()
	return self
end

function ProgressFrame:LoadStylesheet()
	local tweens = self.tweens
	local _ = self.helpers.isState
	local _ = self.helpers.getState
	local _ = self.helpers.addConnection
	local _ = self.helpers.clearConnections

	function ProgressFrame.base(instance, _)
		tweens.saveInitials(instance)
		local fill = instance.fill
		local empty = instance.empty

		local function lerpVector2(p2, p3, p4)
			local v = p4 / 100
			return p2 + (p3 - p2) * v
		end

		local function updateProgressBar(instance2, progress, p2)
			local v = math.ceil(progress == nil and 0 or progress)
			local progressStart = instance2.UIGradient:GetAttribute("progressStart")
			local progressEnd = instance2.UIGradient:GetAttribute("progressEnd")
			local v2 = v / 100
			local offset = progressStart + (progressEnd - progressStart) * v2
			instance2:GetFullName():find("Ginger")

			if v == 0 or not p2 then
				tweens.playTween(
					instance2.UIGradient,
					TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
					{
						Offset = offset
					}
				)
			else
				tweens.playTween(
					instance2.UIGradient,
					TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
					{
						Offset = offset
					}
				)
			end
		end

		local function update(p2)
			local progress = instance:GetAttribute("Progress") or 0
			local v = not p2
			updateProgressBar(fill, progress, v)
			updateProgressBar(empty, progress, v)

			if string.find(instance.TextLabel.Text, "%%") then
				instance.TextLabel.Text = math.ceil(progress) .. "%"
			end
		end

		task.delay(1, update, true)
		instance:GetAttributeChangedSignal("Progress"):Connect(function()
			update()
		end)
	end

	ProgressFrame.states = {
		animate = function(instance, object)
			local fill = instance.fill
			local empty = instance.empty

			local function lerpVector2(p2, p3, p4)
				local v = p4 / 100
				return p2 + (p3 - p2) * v
			end

			local function updateProgressBar(p2, p3)
				local v = math.ceil(p3 == nil and 0 or p3)
				local progressStart = p2.UIGradient:GetAttribute("progressStart")
				local progressEnd = p2.UIGradient:GetAttribute("progressEnd")
				local v2 = v / 100
				local offset = progressStart + (progressEnd - progressStart) * v2

				if v == 0 then
					tweens.playTween(
						p2.UIGradient,
						TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
						{
							Offset = offset
						}
					)
				else
					tweens.playTween(
						p2.UIGradient,
						TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
						{
							Offset = offset
						}
					)
				end
			end

			updateProgressBar(fill, 0)
			updateProgressBar(empty, 0)
			task.wait(0.1)
			updateProgressBar(fill, instance:GetAttribute("Progress"))
			updateProgressBar(empty, instance:GetAttribute("Progress"))
			task.wait(0.5)
			object:SetState(instance, "idle")
		end,
		idle = function(_, _) end
	}
	ProgressFrame.flags = {
		templateFlag = function(_, _, _) end
	}
end

return ProgressFrame