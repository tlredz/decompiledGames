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
		local v2 = list[3]
		local v3 = list[2]
		local humanoid = v:WaitForChild("Humanoid")
		local humanoidRootPart = v:WaitForChild("HumanoidRootPart")
		local skin = v:WaitForChild("Stats"):WaitForChild("Skin")
		local v4 = humanoidRootPart.Size.Y / 2 + humanoid.HipHeight
		local v5 = v3.Size.Y / 2 + humanoid.HipHeight
		local TowerLUT = require(ReplicatedStorage.SharedUtils.TowerLUT)
		local skinModuleFolder = TowerLUT:GetSkinModuleFolder()

		if skin.Value == "Default" then
			local function CreateMirror(p, _)
				local clone = script.GlistenMirror:Clone()
				clone.Transparency = 1
				TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false)
				local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false)
				local size = clone.Size
				clone.Size = Vector3.new(size.X * 0.8, size.Y * 0.8, size.Z * 0.8)
				clone.Parent = workspace
				clone.Anchored = true
				clone.CanCollide = false
				clone.CanQuery = false
				clone.CastShadow = false
				clone.CanTouch = false
				clone.Position = p.Position + Vector3.new(0, -v4 + clone.Size.Y / 2 + 0.25, 0)
				task.spawn(function()
					local v6 = {
						CFrame = clone.CFrame * CFrame.Angles(0, 2.7401669256310974, 0)
					}
					clone.ParticleEmitter:Emit(10)
					TweenService:Create(
						clone,
						TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out, 0, false),
						{
							Size = size,
							Transparency = 0
						}
					):Play()
					local tween = TweenService:Create(
						clone,
						TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 0),
						v6
					)
					tween:Play()
					tween.Completed:Wait()
					local tween2 = TweenService:Create(clone, tweenInfo, {
						Size = createVector(0, 0, 0),
						Transparency = 1
					})
					tween2:Play()
					TweenService:Create(
						clone,
						TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, false, 0),
						{
							CFrame = clone.CFrame * CFrame.Angles(0, 3.12413936106985, 0)
						}
					):Play()
					task.wait(1)
					tween2:Pause()
					tween2:Destroy()
				end)
				Debris:AddItem(clone, 2)
			end

			local clone = script.GlistenPoof:Clone()
			TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false)
			local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
			CreateMirror(v2)
			CreateMirror(v3.CFrame)
			clone.Parent = workspace
			clone.Anchored = true
			clone.CanCollide = false
			clone.CanQuery = false
			clone.CastShadow = false
			clone.CanTouch = false
			clone.Size = createVector(0, 0.25, 0)
			clone.Position = v2.Position + Vector3.new(0, -v4 + 0.25, 0)
			Debris:AddItem(clone, 3)
			local clone2 = script.GlistenDash:Clone()
			clone2.Parent = workspace
			local _ = v3.Position
			clone2.Size = Vector3.new(clone2.Size.X, clone2.Size.Y, (v3.Position - v2.Position).Magnitude)
			local cframe = CFrame.new(0, 0, -(v3.Position - v2.Position).Magnitude / 2)
			clone2.CFrame = CFrame.new(v2.Position, v3.Position) * cframe
			clone2.Anchored = true
			clone2.CanCollide = false
			clone2.CanQuery = false
			clone2.CanTouch = false
			TweenService:Create(
				clone2,
				TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0),
				{
					Size = Vector3.new(clone2.Size.X, clone2.Size.Y * 1.5, (v3.Position - v2.Position).Magnitude),
					Transparency = 1
				}
			):Play()
			Debris:AddItem(clone2, 3)
			TweenService:Create(clone, tweenInfo, {
				Size = createVector(25, 0.25, 25),
				Transparency = 1,
				CFrame = clone.CFrame * CFrame.new(0, 0.25, 0) * CFrame.Angles(0, 2.7401669256310974, 0)
			}):Play()
			local clone3 = script.GlistenPoof:Clone()
			TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false)
			local tweenInfo3 = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
			clone3.Parent = workspace
			clone3.Anchored = true
			clone3.CanCollide = false
			clone3.CanQuery = false
			clone3.CastShadow = false
			clone3.CanTouch = false
			clone3.Size = createVector(0, 0.25, 0)
			clone3.Position = v3.CFrame.Position + Vector3.new(0, -v5 + 0.25, 0)
			Debris:AddItem(clone3, 3)
			TweenService:Create(clone3, tweenInfo3, {
				Size = createVector(25, 0.25, 25),
				Transparency = 1,
				CFrame = clone3.CFrame * CFrame.new(0, 0.25, 0) * CFrame.Angles(0, 2.7401669256310974, 0)
			}):Play()
		else
			local module = require(skinModuleFolder.Glisten[skin.Value])
			module.UseAbility(v, humanoidRootPart, v3, v2, humanoid, v4, v5)
		end
	end
}