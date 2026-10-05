local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local masterClock = Util.MasterClock
local _WorldOrigin2 = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
return function(data)
	local root = data.Root

	if not root or (root.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 1000 then
		return
	end

	local stage = data.Stage or 1

	if stage == 1 then
		local holding = data.Holding
		local v = root.CFrame * CFrame.new(1, 1, -5.5)
		local clone = script.RigHeart:Clone()
		clone:SetPrimaryPartCFrame(v * CFrame.Angles(0, 3.141592653589793, 0))
		clone.PrimaryPart.Size = createVector(0.05, 0.05, 0.05)
		clone.Parent = workspace._WorldOrigin
		TweenService:Create(clone.PrimaryPart, TweenInfo.new(0.3, Enum.EasingStyle.Bounce), {
			Size = createVector(7.86, 6.817, 3.684)
		}):Play()
		local lastTime = tick()

		while tick() - lastTime < 0.1 do
			clone:SetPrimaryPartCFrame(root.CFrame * CFrame.new(1, 1, -5.5) * CFrame.Angles(0, 3.141592653589793, 0))
			RunService.RenderStepped:Wait()
		end

		TweenService:Create(clone.PrimaryPart["Bone.001"], TweenInfo.new(0.2, Enum.EasingStyle.Bounce), {
			Position = createVector(-0, 0.152, -5.75)
		}):Play()
		local lastTime2 = tick()

		while tick() - lastTime2 < 0.2 do
			clone:SetPrimaryPartCFrame(root.CFrame * CFrame.new(1, 1, -5.5) * CFrame.Angles(0, 3.141592653589793, 0))
			RunService.RenderStepped:Wait()
		end

		while holding and holding.Value and holding:IsDescendantOf(workspace) do
			clone:SetPrimaryPartCFrame(root.CFrame * CFrame.new(1, 1, -5.5) * CFrame.Angles(0, 3.141592653589793, 0))
			RunService.RenderStepped:Wait()
		end

		wait(0.1)
		TweenService:Create(clone.PrimaryPart["Bone.001"], TweenInfo.new(0.2, Enum.EasingStyle.Bounce), {
			Position = createVector(-0, 0.152, -1.868)
		}):Play()
		wait(0.2)

		for _, bone in pairs(clone.PrimaryPart:GetDescendants()) do
			if bone:IsA("Bone") then
				TweenService:Create(bone, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
					Position = Vector3.new()
				}):Play()
			end
		end

		local tween = TweenService:Create(clone.PrimaryPart, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
			Size = createVector(0, 0, 0)
		})
		tween.Completed:Connect(function()
			clone:Destroy()
		end)
		tween:Play()
	elseif stage == 2 then
		local _ = data.MouseP
		local timestamp = data.Timestamp
		local distance = data.Distance
		local lifetime = data.Lifetime
		local cFrame = data.CFrame
		local cframe = CFrame.Angles(0, 0, math.random() * 3.141592653589793 * 2)
		local v = 0.25 * (masterClock:GetTime() - timestamp)
		local _ = cFrame.lookVector
		local clone = script.Projectile:Clone()
		Util.Debris:AddItem(clone, lifetime + 3)
		local root2 = clone.Root
		clone:SetPrimaryPartCFrame(cFrame * cframe)
		clone.Parent = _WorldOrigin
		local lastTime = tick()
		local v2 = lifetime - v
		local _ = root2.CFrame

		while tick() - lastTime < v2 do
			local _ = (tick() - lastTime) / v2
			local v3 = (tick() - lastTime) / 100 / (v2 / 100)
			local cFrame2 = root2.CFrame
			clone:SetPrimaryPartCFrame(cFrame:Lerp(cFrame * CFrame.new(0, 0, -distance), v3) * cframe)
			local magnitude = (cFrame2.p - root2.Position).Magnitude
			local ray, v4, _ = Util.Ray(cFrame2.p, cFrame2.lookVector.Unit * magnitude, { root.Parent }, false)

			if ray then
				Util.Debris:AddItem(clone, 3)
				clone:SetPrimaryPartCFrame(CFrame.new(v4, v4 + cFrame2.LookVector) * cframe)
				local part = Instance.new("Part")
				part.Anchored = true
				part.CanCollide = false
				part.CFrame = CFrame.new(v4)
				part.Size = createVector(1, 1, 1)
				part.Color = clone.Outer.Color
				part.Transparency = 0.1
				part.Material = "Neon"
				local specialMesh = Instance.new("SpecialMesh")
				specialMesh.MeshType = "Sphere"
				specialMesh.Scale = Vector3.new()
				specialMesh.Parent = part
				part.Parent = _WorldOrigin2
				local tweenInfo = TweenInfo.new(0.12 + math.random() * 0.08, Enum.EasingStyle.Exponential)
				TweenService:Create(part, tweenInfo, {
					Transparency = 1
				}):Play()
				local tween = TweenService:Create(specialMesh, tweenInfo, {
					Scale = createVector(36, 36, 36)
				})
				tween.Completed:Connect(function()
					part:Destroy()
				end)
				tween:Play()
				clone = nil
				break
			else
				RunService.RenderStepped:Wait()
			end
		end

		if clone then
			clone:Destroy()
		end
	end
end