local SmokeBomb = {}
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local function renderlerp(instance, p, instance2, p2, p3, p4, p5, p6, instance3)
	local renderSteppedConnection = nil
	local total = 0
	local v = false
	renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
		if instance and p and instance2 then
			if p6 == true and instance3 then
				if instance3.Parent == nil then
					v = true
					renderSteppedConnection:Disconnect()
				else
					local _, v2, _ = CFrame.lookAt(instance3.PrimaryPart.Position, instance2.CFrame.Position):ToOrientation()
					local X = instance2.CFrame.Position.X
					local Y = instance2.CFrame.Position.Y
					local Z = instance2.CFrame.Position.Z
					local cFrame = instance3.PrimaryPart.CFrame
					local v3 = CFrame.new(X, Y, Z) * CFrame.fromOrientation(0, v2, 0)
					total += dt
					local v4 = total / 0.5
					local value = TweenService:GetValue(math.min(total / 0.5, 1), p3, p4)
					local lerped = cFrame.Position:Lerp(v3.Position, value)
					local lerped2 = cFrame.Rotation:Lerp(v3.Rotation, value)
					instance:PivotTo(CFrame.new(lerped) * lerped2)

					if v4 >= 1 then
						v = true
						renderSteppedConnection:Disconnect()
					end
				end
			else
				total += dt
				local v2 = total / p2
				local value = TweenService:GetValue(math.min(total / p2, 1), p3, p4)
				local lerped = p.Position:Lerp(instance2.Position, value)
				local lerped2 = p.Rotation:Lerp(instance2.Rotation, value)
				instance:PivotTo(CFrame.new(lerped) * lerped2)

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

	if p5 then
		while not v do
			task.wait()
		end
	end
end

function SmokeBomb.RenderObject(list)
	local v = list[1]
	local v2 = list[2]
	v:WaitForChild("Humanoid")
	local humanoidRootPart = v:WaitForChild("HumanoidRootPart")
	local clone = script.SmokeParticles:Clone()
	clone.Parent = workspace
	clone.Position = humanoidRootPart.Position
	Debris:AddItem(clone, v2 + 1)
	clone.SmokePart.Enabled = true
	clone.SmokeStar.Enabled = true
	task.delay(v2, function()
		clone.SmokePart.Enabled = false
		clone.SmokeStar.Enabled = false
	end)
end

return SmokeBomb