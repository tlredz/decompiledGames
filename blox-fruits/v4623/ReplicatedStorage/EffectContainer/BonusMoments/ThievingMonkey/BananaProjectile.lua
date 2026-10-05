local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
return function(p)
	local collider = p.Collider

	if not (collider and collider:IsA("BasePart") and collider:IsDescendantOf(workspace)) then
		return
	end

	local clone = collider:Clone()
	local visualTransparency = collider:GetAttribute("VisualTransparency")
	clone.Name = "MonkeyBananaVisual"
	clone.Anchored = true
	clone.CanCollide = false
	clone.CanQuery = false
	clone.CanTouch = false
	clone.LocalTransparencyModifier = 0
	clone.Transparency = typeof(visualTransparency) ~= "number" and 0 or visualTransparency
	clone.CFrame = collider.CFrame
	clone.Parent = workspace:FindFirstChild("_WorldOrigin") or workspace
	local flag = false
	local preRenderConnection = nil
	local fadingChangedConnection = nil
	local destroyingConnection = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function cleanup()
		if preRenderConnection then
			preRenderConnection:Disconnect()
			preRenderConnection = nil
		end

		if fadingChangedConnection then
			fadingChangedConnection:Disconnect()
			fadingChangedConnection = nil
		end

		if destroyingConnection then
			destroyingConnection:Disconnect()
			destroyingConnection = nil
		end

		clone:Destroy()
	end

	local function fade()
		if flag then
			return
		end

		flag = true

		if preRenderConnection then
			preRenderConnection:Disconnect()
			preRenderConnection = nil
		end

		local v = typeof(p.FadeDuration) ~= "number" and 0.35 or p.FadeDuration
		local tween = TweenService:Create(clone, TweenInfo.new(v, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = 1
		})
		tween:Play()
		tween.Completed:Wait()
		tween:Destroy()
		cleanup() -- equivalent call inferred; original call site unknown
	end

	preRenderConnection = RunService.PreRender:Connect(function(dt: number)
		if not collider:IsDescendantOf(workspace) then
			task.spawn(fade)
			return
		end

		local v = 1 - math.exp(dt * -20)
		clone.CFrame = clone.CFrame:Lerp(collider.CFrame, v)
	end)
	fadingChangedConnection = collider:GetAttributeChangedSignal("Fading"):Connect(function()
		if collider:GetAttribute("Fading") == true then
			task.spawn(fade)
		end
	end)
	destroyingConnection = collider.Destroying:Connect(function()
		task.spawn(fade)
	end)

	if collider:GetAttribute("Fading") == true then
		task.spawn(fade)
	end
end