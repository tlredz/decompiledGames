local TweenService = game:GetService("TweenService")
local v = {}
local random = Random.new()

local function sprinkle(parent)
	local v2 = table.remove(v)

	if not v2 then
		local clone = script.Star:Clone()
		local tween = TweenService:Create(clone, TweenInfo.new(0.25), {
			ImageTransparency = 0,
			Size = clone.Size
		})
		local tween2 = TweenService:Create(
			clone,
			TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, random:NextInteger(2, 5), true),
			{
				ImageTransparency = 0.5,
				Size = UDim2.new(
					clone.Size.X.Scale * 0.5,
					clone.Size.X.Offset * 0.5,
					clone.Size.Y.Scale * 0.5,
					clone.Size.Y.Offset * 0.5
				)
			}
		)
		local tween3 = TweenService:Create(clone, TweenInfo.new(0.25), {
			ImageTransparency = 1,
			Size = UDim2.new()
		})
		v2 = {
			Star = clone,
			OriginalSize = clone.Size,
			FadeInTween = tween,
			StayTween = tween2,
			FadeOutTween = tween3
		}
		tween.Completed:Connect(function(p)
			if p == Enum.PlaybackState.Completed then
				tween2:Play()
			elseif not table.find(v, v2) then
				table.insert(v, v2)
			end
		end)
		tween2.Completed:Connect(function(p)
			if p == Enum.PlaybackState.Completed then
				tween3:Play()
			elseif not table.find(v, v2) then
				table.insert(v, v2)
			end
		end)
		tween3.Completed:Connect(function()
			if not table.find(v, v2) then
				table.insert(v, v2)
			end
		end)
	end

	local star = v2.Star
	local v3 = math.random() * 3.141592653589793 * 2
	local v4 = Vector2.new(math.sin(v3), (math.cos(v3))) * random:NextNumber() / 2 + Vector2.new(0.5, 0.5)
	star.Position = UDim2.fromScale(v4.X, v4.Y)
	pcall(function()
		star.Parent = parent
	end)
	star.Rotation = random:NextNumber(0, 360)
	star.ImageTransparency = 1
	star.Size = UDim2.new()
	v2.FadeInTween:Play()
end

return function(parent)
	local threads = {}
	local flag = true

	for i = 1, 3 do
		table.insert(threads, task.delay(i / 2, function()
			while flag do
				sprinkle(parent)
				task.wait(random:NextNumber(0.75, 1.25))
			end
		end))
	end

	return function()
		flag = false

		for _, v2 in threads do
			task.cancel(v2)
		end
	end
end