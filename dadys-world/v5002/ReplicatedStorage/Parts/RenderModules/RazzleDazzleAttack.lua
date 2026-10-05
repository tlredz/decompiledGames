local RazzleDazzleAttack = {}
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local function renderlerp(clone, p, instance, p2, quad, out, p3, p4, instance2)
	local renderSteppedConnection = nil
	local total = 0
	local v = false
	renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
		if clone and p and instance then
			if p4 == true and instance2 then
				local _, v2, _ = CFrame.lookAt(instance2.PrimaryPart.Position, instance.CFrame.Position):ToOrientation()
				local X = instance.CFrame.Position.X
				local Y = instance.CFrame.Position.Y
				local Z = instance.CFrame.Position.Z
				local cFrame = instance2.PrimaryPart.CFrame
				local v3 = CFrame.new(X, Y, Z) * CFrame.fromOrientation(0, v2, 0)
				total += dt
				local v4 = total / 0.5
				local value = TweenService:GetValue(math.min(total / 0.5, 1), quad, out)
				local lerped = cFrame.Position:Lerp(v3.Position, value)
				local lerped2 = cFrame.Rotation:Lerp(v3.Rotation, value)
				clone:PivotTo(CFrame.new(lerped) * lerped2)

				if v4 >= 1 then
					v = true
					renderSteppedConnection:Disconnect()
				end
			else
				total += dt
				local v2 = total / p2
				local value = TweenService:GetValue(math.min(total / p2, 1), quad, out)
				local lerped = p.Position:Lerp(instance.Position, value)
				local lerped2 = p.Rotation:Lerp(instance.Rotation, value)
				clone:PivotTo(CFrame.new(lerped) * lerped2)

				if v2 >= 1 then
					v = true
					renderSteppedConnection:Disconnect()
				end
			end
		else
			v = true
			renderSteppedConnection:Disconnect()
		end
	end)

	if p3 then
		while not v do
			task.wait()
		end
	end
end

function RazzleDazzleAttack.RenderObject(list)
	local v = list[1]

	if v and v.Parent ~= nil then
		local humanoid = v:WaitForChild("Humanoid")
		local v2 = v.PrimaryPart.Size.Y / 2 + humanoid.HipHeight
		local cframe = CFrame.new(0, -v2, 0)
		TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local clone = script.Vine:Clone()
		local _ = clone.Size.Y / 2
		local cframe2 = CFrame.new(0, v2, 0)
		clone.Parent = workspace
		Debris:AddItem(clone, 0.5)
		local v3 = v.PrimaryPart.CFrame * cframe * cframe2 * CFrame.new(0, -0.25, 0)
		local v4 = v.PrimaryPart.CFrame * cframe * cframe2 * CFrame.new(0, -0.25, 0) * CFrame.Angles(
			0,
			math.rad((math.random(1, 360))),
			0
		)
		renderlerp(clone, v3 * CFrame.new(0, -6, 0), v4, 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, true)
		local v6 = v3 * CFrame.new(0, -6, 0)
		local quad = Enum.EasingStyle.Quad
		local out = Enum.EasingDirection.Out
		local renderSteppedConnection = nil
		local total = 0
		local v7 = false
		local v8 = nil
		local v9 = nil
		local v10 = 0.25
		renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
			if clone and v4 and v6 then
				if v8 == true and v9 then
					local _, v11, _ = CFrame.lookAt(v9.PrimaryPart.Position, v6.CFrame.Position):ToOrientation()
					local X = v6.CFrame.Position.X
					local Y = v6.CFrame.Position.Y
					local Z = v6.CFrame.Position.Z
					local cFrame = v9.PrimaryPart.CFrame
					local v12 = CFrame.new(X, Y, Z) * CFrame.fromOrientation(0, v11, 0)
					total += dt
					local v13 = total / 0.5
					local value = TweenService:GetValue(math.min(total / 0.5, 1), quad, out)
					local lerped = cFrame.Position:Lerp(v12.Position, value)
					local lerped2 = cFrame.Rotation:Lerp(v12.Rotation, value)
					clone:PivotTo(CFrame.new(lerped) * lerped2)

					if v13 >= 1 then
						v7 = true
						renderSteppedConnection:Disconnect()
					end
				else
					total += dt
					local v11 = total / v10
					local value = TweenService:GetValue(math.min(total / v10, 1), quad, out)
					local lerped = v4.Position:Lerp(v6.Position, value)
					local lerped2 = v4.Rotation:Lerp(v6.Rotation, value)
					clone:PivotTo(CFrame.new(lerped) * lerped2)

					if v11 >= 1 then
						v7 = true
						renderSteppedConnection:Disconnect()
					end
				end
			else
				v7 = true
				renderSteppedConnection:Disconnect()
			end
		end)
	end
end

return RazzleDazzleAttack