local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("SoundService")
local v = require3(ReplicatedStorage2.Shared.FastUtils)
local v2 = require3(script.Parent["Sprinkles.story"])
local v3 = {
	Common = {
		{
			Bottom = "rbxassetid://16893271298",
			Top = "rbxassetid://16893277445"
		},
		{
			Bottom = "rbxassetid://16895281297",
			Top = "rbxassetid://16895277516"
		},
		{
			Bottom = "rbxassetid://16895285586",
			Top = "rbxassetid://16895292021"
		}
	},
	Golden = {
		{
			Bottom = "rbxassetid://16895274554",
			Top = "rbxassetid://16895263948"
		}
	}
}
local currentCamera = workspace.CurrentCamera
local v4 = {
	{ Vector2.zero },
	{ Vector2.new(-0.25, 0), Vector2.new(0.25, 0) },
	{ Vector2.new(-0.5, 0), Vector2.zero, Vector2.new(0.5, 0) },
	{
		Vector2.new(-0.75, 0),
		Vector2.new(-0.25, 0),
		Vector2.new(0.25, 0),
		Vector2.new(0.75, 0)
	},
	{
		Vector2.new(-0.85, 0),
		Vector2.new(-0.425, 0),
		Vector2.zero,
		Vector2.new(0.425, 0),
		Vector2.new(0.85, 0)
	},
	{
		Vector2.new(-0.85, 0),
		Vector2.new(-0.375, 0),
		Vector2.zero,
		Vector2.new(0.375, 0),
		Vector2.new(0.85, 0),
		Vector2.new(0, 0.5)
	},
	{
		Vector2.new(-0.85, -0.5),
		Vector2.new(-0.425, -0.5),
		Vector2.new(0, -0.5),
		Vector2.new(0.425, -0.5),
		Vector2.new(0.85, -0.5),
		Vector2.new(-0.25, 0.5),
		Vector2.new(0.25, 0.5)
	},
	{
		Vector2.new(-0.85, -0.5),
		Vector2.new(-0.425, -0.5),
		Vector2.zero,
		Vector2.new(0.425, -0.5),
		Vector2.new(0.85, -0.5),
		Vector2.new(-0.5, 0.5),
		Vector2.new(0, 0.5),
		Vector2.new(0.5, 0.5)
	},
	{
		Vector2.new(-0.85, -0.5),
		Vector2.new(-0.425, -0.5),
		Vector2.new(0, -0.5),
		Vector2.new(0.425, -0.5),
		Vector2.new(0.85, -0.5),
		Vector2.new(-0.75, 0.5),
		Vector2.new(-0.375, 0.5),
		Vector2.new(0.375, 0.5),
		Vector2.new(0.75, 0.5)
	},
	{
		Vector2.new(-0.85, -0.5),
		Vector2.new(-0.425, -0.5),
		Vector2.new(0, -0.5),
		Vector2.new(0.425, -0.5),
		Vector2.new(0.85, -0.5),
		Vector2.new(-0.85, 0.5),
		Vector2.new(-0.425, 0.5),
		Vector2.new(0, 0.5),
		Vector2.new(0.425, 0.5),
		Vector2.new(0.85, 0.5)
	}
}

local function shakeSync(parent, parent2, flag: boolean, p, flag2: boolean, _: number, p2: number, _: number, p3: number)
	local holder = parent.Holder
	holder.Reward.ZIndex = 0

	if p.IsGolden and flag2 then
		local absoluteSize = parent.AbsoluteSize
		local absolutePosition = parent.AbsolutePosition
		parent.Parent = parent:FindFirstAncestorWhichIsA("ScreenGui") or parent.Parent
		parent.Size = UDim2.fromOffset(absoluteSize.X, absoluteSize.Y)
		parent.Position = UDim2.fromOffset(
			absolutePosition.X + absoluteSize.X * parent.AnchorPoint.X,
			absolutePosition.Y + absoluteSize.Y * parent.AnchorPoint.Y
		)
		task.wait(3)
		local clone = script.OpenGold:Clone()
		clone.Parent = parent
		clone:Play()
		local v5 = v4[p3][p2]
		v.fastTween(parent, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
			Position = UDim2.fromScale(0.5, 0.5) + UDim2.fromScale(v5.X * 0.5, v5.Y * 0.5),
			Size = UDim2.fromScale(
				absoluteSize.X * 2 / currentCamera.ViewportSize.X * 0.666,
				absoluteSize.Y * 2 / currentCamera.ViewportSize.Y * 0.666
			)
		}).Completed:Wait()
	end

	v.fastTween(holder, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {
		Size = UDim2.fromScale(0.85, 0.85)
	}).Completed:Wait()
	v.fastTween(holder, TweenInfo.new(0.75, Enum.EasingStyle.Linear), {
		Size = UDim2.fromScale(0.666, 0.666)
	})

	if not flag or p.IsGolden then
		for i = p.IsGolden and 60 or 30, 0, -7.5 do
			v.fastTween(holder, TweenInfo.new(0.075, Enum.EasingStyle.Sine), {
				Rotation = i
			}).Completed:Wait()
			v.fastTween(holder, TweenInfo.new(0.075, Enum.EasingStyle.Sine), {
				Rotation = -i
			}).Completed:Wait()
		end
	end

	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.Parent = parent2
	frame.BackgroundColor3 = Color3.new(1, 1, 1)
	frame.BackgroundTransparency = 0
	v.fastTween(frame, TweenInfo.new(0.25), {
		BackgroundTransparency = 1
	})
	local wheel = parent.Wheel
	wheel.Size = UDim2.fromScale(0, 0)
	wheel.ImageTransparency = 0
	holder.Reward.ZIndex = 3
	holder.Reward.ImageTransparency = 0
	holder.Reward.DuplicatedText.Visible = p.IsDuplicated
	holder.Reward.RewardText.TextTransparency = 0
	holder.Reward.RewardText.UIStroke.Transparency = 0
	local v5

	if p.IsGolden then
		v5 = script.RevealGold
	else
		v5 = script.RevealNormal
	end

	local clone = v5:Clone()
	clone.Parent = holder
	clone:Play()
	v.fastTween(wheel, TweenInfo.new(1, Enum.EasingStyle.Quint), {
		Size = UDim2.fromScale(5, 5),
		ImageTransparency = 1
	})
	holder.Bottom.Position = UDim2.fromScale(0.5, 0.5)
	holder.Bottom.ImageTransparency = 0
	v.fastTween(holder.Bottom, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {
		Position = UDim2.fromScale(0.5, 0.75)
	})
	holder.Top.Position = UDim2.fromScale(0.5, 0.5)
	holder.Top.ImageTransparency = 0
	v.fastTween(holder.Top, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {
		Position = UDim2.fromScale(0.5, 0.25)
	})
	v.fastTween(holder, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {
		Size = UDim2.fromScale(0.85, 0.85)
	}).Completed:Wait()
	task.wait(0.5)
	v.fastTween(holder.Bottom, TweenInfo.new(1, Enum.EasingStyle.Sine), {
		ImageTransparency = 1
	})
	v.fastTween(holder.Top, TweenInfo.new(1, Enum.EasingStyle.Sine), {
		ImageTransparency = 1
	})
	clone:Destroy()
end

return function(parent, p, flag: boolean, flag2: boolean, p2: number, p3: number, p4: number, p5: number)
	local clone = script.Cell:Clone()
	clone.Parent = parent
	local v5 = v3[p.IsGolden and "Golden" or "Common"]
	local v6 = v5[math.random(#v5)]
	clone.Holder.Bottom.Image = v6.Bottom
	clone.Holder.Top.Image = v6.Top
	clone.Holder.Reward.Image = p.Reward.Icon or ""
	clone.Holder.Reward.RewardText.Text = p.Reward.DisplayName or ""
	local v7

	if p.IsGolden then
		v7 = v2(clone.Holder.StarsHolder)
	else
		v7 = nil
	end

	local clone2

	if p.IsGolden or flag then
		clone2 = nil
	else
		clone2 = script.OpenNormal:Clone()
		clone2.Parent = clone
		clone2:Play()
	end

	local thread = task.delay(1, shakeSync, clone, parent, flag, p, flag2, p2, p3, p4, p5)
	return function()
		if coroutine.status(thread) == "suspended" then
			pcall(task.cancel, thread)
		end

		if clone2 then
			clone2:Stop()
			clone2:Destroy()
		end

		clone:Destroy()

		if v7 then
			v7()
		end
	end
end