local createVector = vector.create
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
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

return {
	RenderObject = function(list)
		local v = list[1]
		local humanoid = v:WaitForChild("Humanoid")
		local humanoidRootPart = v:WaitForChild("HumanoidRootPart")
		local skin = v:WaitForChild("Stats"):WaitForChild("Skin")
		local TowerLUT = require(ReplicatedStorage.SharedUtils.TowerLUT)
		local skinAbilityModule = TowerLUT:GetSkinAbilityModule("Pebble", skin.Value)

		if skinAbilityModule and skinAbilityModule.UseAbility then
			skinAbilityModule.UseAbility(v)
			return
		end

		local v2 = humanoidRootPart.Size.Y / 2 + humanoid.HipHeight
		local clone = game.ReplicatedStorage:WaitForChild("Parts"):WaitForChild("PoofDefault"):Clone()
		TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false)
		local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out, 0, false)
		local tweenInfo2 = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
		clone.Parent = workspace
		clone.Anchored = true
		clone.CanCollide = false
		clone.CanQuery = false
		clone.CastShadow = false
		clone.CanTouch = false
		clone.Size = createVector(0, 0.25, 0)
		clone.Position = v.PrimaryPart.Position + Vector3.new(0, -v2, 0)
		Debris:AddItem(clone, 5)
		TweenService:Create(clone, tweenInfo, {
			Size = createVector(45, 0.25, 45)
		}):Play()
		TweenService:Create(clone, tweenInfo2, {
			Transparency = 1,
			Rotation = createVector(0, 2.740167, 0)
		}):Play()
	end
}