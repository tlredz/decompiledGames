local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local v = require3(ReplicatedStorage2.Packages.Trove)
local v2 = require3(ReplicatedStorage2.Shared.FastUtils)
local v3 = require3(ReplicatedStorage2.Packages.Observers)
local random = Random.new()
return function(p)
	local maid = v.new()
	local center = p.Background.Spin.Center
	local v4 = maid:Add(v2.createCacheBank(function()
		local poly = maid:Add(script.PolyTemplate:Clone())
		return {
			Poly = poly,
			Tween = maid:Add(TweenService:Create(poly, TweenInfo.new(4, Enum.EasingStyle.Linear), {
				Size = UDim2.fromScale(0.75, 0.75),
				ImageTransparency = 1
			}))
		}
	end, function(p2)
		p2.Tween:Destroy()
		p2.Poly:Destroy()
	end))
	maid:Add(task.spawn(function()
		while true do
			task.spawn(function()
				local v5 = v4:Get()
				local poly = v5.Poly
				local tween = v5.Tween
				poly.Parent = center
				poly.Size = UDim2.fromScale(0, 0)
				poly.ImageTransparency = 0
				tween:Play()
				tween.Completed:Wait()
				poly.Parent = nil
				v4:Return(v5)
			end)
			task.wait(1.6)
		end
	end))
	local v5 = {
		"rbxassetid://17119339675",
		"rbxassetid://17119339892",
		"rbxassetid://17119340041",
		"rbxassetid://17119340227",
		"rbxassetid://17119340345",
		"rbxassetid://17119340460"
	}
	local v6 = maid:Add(v2.createCacheBank(function()
		local object = maid:Add(script.Cloud:Clone())
		local number = random:NextNumber(0.2, 0.7)
		local number2 = random:NextNumber()
		return {
			Object = object,
			Tween = maid:Add(TweenService:Create(object, TweenInfo.new(number2 * 60 + 60, Enum.EasingStyle.Linear), {
				Position = UDim2.fromScale(1.1, number)
			})),
			Height = number,
			Scale = number2
		}
	end, function(p2)
		p2.Tween:Destroy()
		p2.Object:Destroy()
	end))
	maid:Add(task.spawn(function()
		while true do
			task.spawn(function()
				local v7 = v6:Get()
				local object = v7.Object
				local tween = v7.Tween
				object.Image = v5[random:NextInteger(1, #v5)]
				object.Parent = p.Clouds
				object.Size = UDim2.fromScale(1, v7.Scale * 0.2 + 0.1)
				object.Position = UDim2.fromScale(-0.1, v7.Height)
				tween:Play()
				tween.Completed:Wait()
				object.Parent = nil
				v6:Return(v7)
			end)
			task.wait(random:NextNumber(3, 4))
		end
	end))
	v3.observeDescendants(p, function(instance)
		local v7

		if instance:HasTag("ImageSlider") then
			v7 = TweenService:Create(
				instance,
				TweenInfo.new(
					instance:GetAttribute("Duration") or 1,
					Enum.EasingStyle.Linear,
					Enum.EasingDirection.Out,
					-1
				),
				{
					Position = UDim2.fromScale(0, 0.5)
				}
			)
			v7:Play()
		else
			v7 = nil
		end

		return function()
			if v7 then
				v7:Destroy()
			end
		end
	end)
	return function()
		maid:Destroy()
	end
end