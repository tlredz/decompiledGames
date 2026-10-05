local GoobGrab = {}
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local function renderlerp(clone, cFrame, primaryPart, p, quad, out, p2, p3, instance)
	local renderSteppedConnection = nil
	local total = 0
	local v = false
	renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
		if clone and cFrame and primaryPart then
			if p3 == true and instance then
				if instance.Parent == nil then
					v = true
					renderSteppedConnection:Disconnect()
				else
					local _, v2, _ = CFrame.lookAt(instance.PrimaryPart.Position, primaryPart.CFrame.Position):ToOrientation()
					local X = primaryPart.CFrame.Position.X
					local Y = primaryPart.CFrame.Position.Y
					local Z = primaryPart.CFrame.Position.Z
					local cFrame2 = instance.PrimaryPart.CFrame
					local v3 = CFrame.new(X, Y, Z) * CFrame.fromOrientation(0, v2, 0)
					total += dt
					local v4 = total / 0.5
					local value = TweenService:GetValue(math.min(total / 0.5, 1), quad, out)
					local lerped = cFrame2.Position:Lerp(v3.Position, value)
					local lerped2 = cFrame2.Rotation:Lerp(v3.Rotation, value)
					clone:PivotTo(CFrame.new(lerped) * lerped2)

					if v4 >= 1 then
						v = true
						renderSteppedConnection:Disconnect()
					end
				end
			else
				total += dt
				local v2 = total / p
				local value = TweenService:GetValue(math.min(total / p, 1), quad, out)
				local lerped = cFrame.Position:Lerp(primaryPart.Position, value)
				local lerped2 = cFrame.Rotation:Lerp(primaryPart.Rotation, value)
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

	if p2 then
		while not v do
			task.wait()
		end
	end
end

function GoobGrab.RenderObject(list)
	local v = list[1]
	local v2 = list[2]

	if v and v.Parent ~= nil then
		TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local clone = game.ReplicatedStorage.Parts.MonsterGoobGrab:Clone()
		local shoulderl, shoulderr

		repeat
			shoulderl = v.RootPart:FindFirstChild("shoulder.l", true)
			shoulderr = v.RootPart:FindFirstChild("shoulder.r", true)
		until shoulderl and shoulderr

		clone.Parent = workspace
		clone.PrimaryPart.CFrame = v.PrimaryPart.CFrame
		clone.Base.ArmR.RopeConstraint.Attachment0 = shoulderr
		clone.Base.ArmL.RopeConstraint.Attachment0 = shoulderl
		Debris:AddItem(clone, 1)
		local _, _, _ = CFrame.lookAt(v.PrimaryPart.Position, v2.PrimaryPart.Position):ToOrientation()
		local _ = v2.PrimaryPart.Position.X
		local _ = v2.PrimaryPart.Position.Y
		local _ = v2.PrimaryPart.Position.Z
		renderlerp(
			clone,
			v.PrimaryPart.CFrame,
			v2.PrimaryPart,
			0.5,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out,
			true,
			true,
			v
		)
		local _, _, _ = CFrame.lookAt(v.PrimaryPart.Position, v2.PrimaryPart.Position):ToOrientation()
		local _ = v.PrimaryPart.Position.X
		local _ = v.PrimaryPart.Position.Y
		local _ = v.PrimaryPart.Position.Z
		local cFrame2 = v2.PrimaryPart.CFrame
		local cFrame3 = v.PrimaryPart.CFrame
		local quad = Enum.EasingStyle.Quad
		local out = Enum.EasingDirection.Out
		local renderSteppedConnection = nil
		local total = 0
		local v3 = false
		local v4 = nil
		local v5 = nil
		local v6 = 0.5
		renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
			if clone and cFrame2 and cFrame3 then
				if v4 == true and v5 then
					if v5.Parent == nil then
						v3 = true
						renderSteppedConnection:Disconnect()
					else
						local _, v7, _ = CFrame.lookAt(v5.PrimaryPart.Position, cFrame3.CFrame.Position):ToOrientation()
						local X = cFrame3.CFrame.Position.X
						local Y = cFrame3.CFrame.Position.Y
						local Z = cFrame3.CFrame.Position.Z
						local cFrame4 = v5.PrimaryPart.CFrame
						local v8 = CFrame.new(X, Y, Z) * CFrame.fromOrientation(0, v7, 0)
						total += dt
						local v9 = total / 0.5
						local value = TweenService:GetValue(math.min(total / 0.5, 1), quad, out)
						local lerped = cFrame4.Position:Lerp(v8.Position, value)
						local lerped2 = cFrame4.Rotation:Lerp(v8.Rotation, value)
						clone:PivotTo(CFrame.new(lerped) * lerped2)

						if v9 >= 1 then
							v3 = true
							renderSteppedConnection:Disconnect()
						end
					end
				else
					total += dt
					local v7 = total / v6
					local value = TweenService:GetValue(math.min(total / v6, 1), quad, out)
					local lerped = cFrame2.Position:Lerp(cFrame3.Position, value)
					local lerped2 = cFrame2.Rotation:Lerp(cFrame3.Rotation, value)
					clone:PivotTo(CFrame.new(lerped) * lerped2)

					if v7 >= 1 then
						v3 = true
						renderSteppedConnection:Disconnect()
					end
				end
			else
				v3 = true
				renderSteppedConnection:Disconnect()
			end
		end)
	end
end

return GoobGrab