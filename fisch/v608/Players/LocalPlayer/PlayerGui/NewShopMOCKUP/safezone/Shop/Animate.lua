local TweenService = game:GetService("TweenService")
local parent = script.Parent
local _ = parent.Categories
local products = parent.Products
local fish = parent.Fish
local clover = products.Main.Luck.Clover
local luck = products.Main.Luck
task.spawn(function()
	while true do
		local tween = TweenService:Create(fish, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Rotation = fish.Rotation - 15
		})
		tween:Play()
		tween.Completed:Wait()
		local tween2 = TweenService:Create(fish, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Rotation = fish.Rotation + 15
		})
		tween2:Play()
		tween2.Completed:Wait()
	end
end)
local v = nil
task.spawn(function()
	while true do
		task.wait(0.4)
		local clone = clover:Clone()
		clone.Visible = true
		clone.Parent = luck
		clone.ImageTransparency = 1
		local v2 = math.random() * 0.1 + 0.1
		clone.Size = UDim2.fromScale(v2, v2)
		local v3 = 1.1 - v2
		local v4 = nil

		for _ = 1, 10 do
			local v5 = math.random() * v3

			if not (not v or math.abs(v5 - v) >= 0.1) then
				continue
			end

			v4 = v5
			break
		end

		local v5 = v4 or math.random() * v3
		v = v5
		clone.Position = UDim2.new(v5, 0, 0, -luck.AbsoluteSize.Y * v2)
		clone.Rotation = math.random(0, 360)
		local v7 = TweenService:Create(clone, TweenInfo.new(0.5), {
			ImageTransparency = 0.3
		})
		task.delay(1.2000000000000002, function()
			if clone then
				v7:Play()
			end
		end)
		local v8 = clone
		local v9 = TweenService:Create(clone, TweenInfo.new(0.5), {
			ImageTransparency = 1
		})
		task.delay(4.199999999999999, function()
			if v8 then
				v9:Play()
			end
		end)
		TweenService:Create(clone, TweenInfo.new(6, Enum.EasingStyle.Linear), {
			Position = UDim2.new(v5, 0, 1 + v2, 0),
			Rotation = clone.Rotation + math.random(-90, 90)
		}):Play()
		local v10 = clone
		task.delay(7, function()
			if v10 then
				v10:Destroy()
			end
		end)
	end
end)