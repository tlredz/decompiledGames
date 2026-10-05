local TweenService = game:GetService("TweenService")
local color = BrickColor.new("Bright red").Color
local color2 = BrickColor.new("Bright green").Color
local tweenInfo = TweenInfo.new(0.2)

local function changePartColors(right, color3)
	right:GetChildren()

	for i = 1, 5 do
		local child = right:FindFirstChild((tostring(i)))

		if not child then
			continue
		end

		TweenService:Create(child, tweenInfo, {
			Color = color3
		}):Play()
		task.wait(tweenInfo.Time)

		if i ~= 5 then
			continue
		end

		local particleEmitter = child:FindFirstChild("ParticleEmitter")

		if particleEmitter then
			particleEmitter:Emit(10)
		end
	end
end

return {
	AnimationSequence = {
		{
			Animate = function(instance)
				changePartColors(instance:WaitForChild("Right"), color)
			end
		},
		{
			Animate = function(instance)
				changePartColors(instance:WaitForChild("Right"), color2)
			end
		}
	},
	ApplyEndState = function(instance)
		for _, child in instance:WaitForChild("Right"):GetChildren() do
			TweenService:Create(child, TweenInfo.new(0), {
				Color = color2
			}):Play()
		end
	end
}