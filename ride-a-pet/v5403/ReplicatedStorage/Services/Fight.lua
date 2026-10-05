local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
return {
	IndicateDamage = function(_, parent, text, p)
		local clone = script:WaitForChild("DamageOverhead"):Clone()
		local humanoidRootPart = parent:WaitForChild("HumanoidRootPart")
		local damageOverhead = humanoidRootPart:FindFirstChild("DamageOverhead")

		if damageOverhead then
			damageOverhead.Enabled = false
		end

		local v = { -1, 1 }
		local v2 = { 2, 3 }
		local v3 = v2[math.random(1, #v2)]
		local v4 = v[math.random(1, #v)]
		clone.StudsOffset = Vector3.new(v3 * v4, 0, 0)
		local damage = clone:WaitForChild("Damage")
		local uIStroke = damage:WaitForChild("UIStroke")
		damage.Text = text

		if p == true then
			uIStroke.Enabled = true
			damage.TextColor3 = Color3.fromRGB(255, 0, 0)
			uIStroke.Thickness = 2
			clone.Size = UDim2.new(5, 50, 5, 50)
		end

		local _ = damage.Position
		local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 0.05)
		local tween = TweenService:Create(clone, tweenInfo, {
			StudsOffset = Vector3.new(clone.StudsOffset.X + v4 * 2, -6, 2)
		})
		local tween2 = TweenService:Create(clone, tweenInfo, {
			Size = UDim2.new(0, 0, 0, 0)
		})
		local tween3 = TweenService:Create(uIStroke, tweenInfo, {
			Transparency = 1
		})
		local tween4 = TweenService:Create(damage, tweenInfo, {
			Rotation = v4 * 210
		})
		local part = Instance.new("Part")
		part.Transparency = 1
		part.CanCollide = false
		part.CanQuery = false
		part.Size = humanoidRootPart.Size
		part.Position = humanoidRootPart.Position
		part.Anchored = true
		part.Parent = workspace
		clone.Parent = part
		tween3:Play()
		tween:Play()
		tween2:Play()
		tween4:Play()
		tween3:Play()
		Debris:AddItem(clone, 1)
		Debris:AddItem(part, 1)
		local clone2 = script:WaitForChild("DamageHighlight"):Clone()
		clone2.Parent = parent
		TweenService:Create(clone2, TweenInfo.new(0.2), {
			FillTransparency = 1
		}):Play()
		Debris:AddItem(clone2, 1)
	end
}