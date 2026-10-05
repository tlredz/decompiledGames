local ReplicatedStorage = game:GetService("ReplicatedStorage")
local shared = ReplicatedStorage.shared
local GeneralUtils = require(shared.utils.GeneralUtils)
local thread = nil
script.Parent.Parent.Parent:GetPropertyChangedSignal("Visible"):Connect(function()
	if script.Parent.Parent.Parent.Visible and not thread then
		thread = task.defer(function()
			while true do
				GeneralUtils.fastTween(
					script.Parent,
					TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
					{
						Rotation = -5
					}
				)
				task.wait(0.2)
				GeneralUtils.fastTween(
					script.Parent,
					TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
					{
						Rotation = 5
					}
				)
				task.wait(0.3)
				GeneralUtils.fastTween(
					script.Parent,
					TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{
						Rotation = 0
					}
				)
				task.wait(3)
			end
		end)
	elseif thread then
		task.cancel(thread)
		thread = nil
	end
end)