local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local masterClock = Util.MasterClock
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local clone = script.Air:Clone()
clone:TranslateBy(createVector(0, 999999, 0))
clone.Parent = workspace._WorldOrigin
return function(data)
	if data.Mode == "Preload" then
		local root = data.Root

		if not root then
			return
		end

		local cFrame = root.CFrame

		if (cFrame.p - workspace.CurrentCamera.CFrame.p).Magnitude > 800 then
			return
		end

		for _ = 1, 2 do
			local clone2 = script.RedSlash:Clone()
			clone2:SetPrimaryPartCFrame(cFrame * CFrame.Angles(
				3.141592653589793 * math.random() * 2,
				3.141592653589793 * math.random() * 2,
				3.141592653589793 * math.random() * 2
			))

			for _, child in pairs(clone2:GetChildren()) do
				child.Size *= (3 + math.random() * 2) * 2
				local tween = TweenService:Create(child, TweenInfo.new(0.15, Enum.EasingStyle.Bounce), {
					Size = createVector(0.05, 0.05, 0.05),
					CFrame = child.CFrame * CFrame.Angles(3.141592653589793, 3.141592653589793, 3.141592653589793)
				})

				if child == clone2.PrimaryPart then
					local v = clone2
					tween.Completed:Connect(function()
						v:Destroy()
					end)
				end

				tween:Play()
			end

			clone2.Parent = _WorldOrigin
		end
	elseif data.Mode == "Dash" then
		local root = data.Root

		if not root then
			return
		end

		local v = data.CFrame * CFrame.new(0, 3.3, 0)

		if (v.p - workspace.CurrentCamera.CFrame.p).Magnitude > 800 then
			return
		end

		local cFrame = data.FinalCFrame * CFrame.new(0, root.Size.Y * 1.6, 0)
		local v3 = 10 + (v.p - cFrame.p).Magnitude
		local v4 = 5 + (data.Stage == 3 and 60 or 30)
		TweenService:Create(root, TweenInfo.new(0.075), {
			CFrame = cFrame
		}):Play()
		local clone2 = script.Air:Clone()
		clone2:SetPrimaryPartCFrame(v * CFrame.new(0, 0, -v3 - 20) * CFrame.Angles(-1.57, 0, 0) * CFrame.Angles(
			0,
			math.random() * 3.141592653589793 * 2,
			0
		))

		for _, child in pairs(clone2:GetChildren()) do
			child.Transparency = 0.1
			local tween = TweenService:Create(
				child,
				TweenInfo.new(1 + (child == clone2.PrimaryPart and -0.15 or 0), Enum.EasingStyle.Exponential),
				{
					Size = child.Size * v4 * 0.12 * createVector(3, 9, 3) * (1 + math.random()),
					CFrame = child.CFrame * CFrame.Angles(0, 3.141592653589793, 0) * CFrame.new(0, -v3 - 20, 0),
					Transparency = 1
				}
			)

			if child == clone2.PrimaryPart then
				tween.Completed:Connect(function()
					clone2:Destroy()
				end)
			end

			tween:Play()
		end

		clone2.Parent = _WorldOrigin

		for i = 1, 9 do
			local part = Instance.new("Part")
			part.Material = "Neon"
			part.Anchored = true
			part.CastShadow = false
			part.CanCollide = false
			part.CFrame = v * CFrame.new(-40, -40, -v3 - 40) * CFrame.Angles(
				v4 * 0.01 * (math.random() - 0.5),
				v4 * 0.01 * (math.random() - 0.5),
				v4 * 0.01 * (math.random() - 0.5)
			) * CFrame.new(40, 40, 40)
			part.Size = createVector(1, 1, 1)
			part.Color = i % 2 == 0 and Color3.new(1, 0, 0) or Color3.new()
			local specialMesh = Instance.new("SpecialMesh", part)
			specialMesh.MeshType = "Sphere"
			specialMesh.Scale = Vector3.new(1, 1, v3 * 0.5) * 2
			local v5 = v3 * 0.1333 + v3 * 0.2 * math.random()
			part.Parent = _WorldOrigin
			local tween = TweenService:Create(
				specialMesh,
				TweenInfo.new(0.15 + math.random() * 0.1, Enum.EasingStyle.Quad),
				{
					Offset = Vector3.new(0, 0, v5 * 4),
					Scale = Vector3.new(0, 0, v5 / 2)
				}
			)
			tween.Completed:Connect(function()
				part:Destroy()
			end)
			tween:Play()
		end

		local clone3 = script.RedSpike:Clone()
		clone3:SetPrimaryPartCFrame(v * CFrame.new(0, 0, v3 * 0.5) * CFrame.Angles(0, 3.141592653589793, 0))

		for _, child in pairs(clone3:GetChildren()) do
			child.Size *= 2.5 * v4 * 0.04
			local tween = TweenService:Create(child, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {
				Size = createVector(0.05, 0.05, 0.05),
				CFrame = child.CFrame * CFrame.new(0, 0, v3 * 1.5)
			})

			if child == clone3.PrimaryPart then
				tween.Completed:Connect(function()
					clone3:Destroy()
				end)
			end

			tween:Play()
		end

		clone3.Parent = _WorldOrigin
		local stage = data.Stage or 1

		for i = 1, stage == 3 and 2 or 1 do
			local v5 = i ~= 1 and 0 or stage == 2 and 0 or 3.141592653589793
			local v6 = true
			local clone4 = script.RedSlash:Clone()
			clone4.Red.Electric.Enabled = false
			clone4:SetPrimaryPartCFrame(cFrame * CFrame.new(0, 0, -12) * CFrame.Angles(
				v5,
				v5,
				v5 + (v5 > 0 and 2.2 or -2.2)
			))

			for _, child in pairs(clone4:GetChildren()) do
				child.Size *= 1 + v4 * 0.05
				local tween = TweenService:Create(child, TweenInfo.new(0.15 + (data.Stage == 3 and 0.06 or 0)), {
					Size = child.Size * 2
				})

				if child == clone4.PrimaryPart then
					local v7 = clone4
					tween.Completed:Connect(function()
						v6 = false
						v7:Destroy()
					end)
				end

				tween:Play()
			end

			clone4.Parent = _WorldOrigin
			coroutine.resume(coroutine.create(function()
				while true do
					local v8 = RunService.RenderStepped:Wait()

					if not v6 or not clone4.Parent == _WorldOrigin or not clone4.PrimaryPart then
						break
					end

					clone4:SetPrimaryPartCFrame(clone4.PrimaryPart.CFrame * CFrame.Angles(
						-v8 * 3.141592653589793 * 5,
						0,
						0
					))
				end
			end))
		end
	elseif data.Mode == "Barrage" then
		local root = data.Root

		if not root or (root.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 1000 then
			return
		end

		local mousePos = data.MousePos
		local holding = data.Holding
		local length = data.Length
		local v = length * 0.8

		if not (holding and mousePos) then
			return
		end

		local cframe = CFrame.new(root.Position, mousePos.Value)

		if data.Stage == 2 then
			local clone2 = script.RedSpike:Clone()
			clone2:SetPrimaryPartCFrame(cframe * CFrame.Angles(0, 3.141592653589793, 0))

			for _, child in pairs(clone2:GetChildren()) do
				child.Size *= 4
				local tween = TweenService:Create(child, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
					Size = createVector(0.05, 0.05, 0.05),
					CFrame = child.CFrame * CFrame.new(0, 0, length * 2)
				})

				if child == clone2.PrimaryPart then
					tween.Completed:Connect(function()
						clone2:Destroy()
					end)
				end

				tween:Play()
			end

			clone2.Parent = _WorldOrigin
		else
			local v2 = tick() - (masterClock:GetTime() - data.Timestamp)
			local count = 0

			while tick() - v2 < 1.5 and holding.Parent and (not (tick() - v2 > 0.2) or holding.Value ~= false) do
				local v3 = v * ((math.min(1, (tick() - v2) / 0.5) ^ 1.1 * 0.75 + 0.25) * 0.9 + 0.01)
				local cframe2 = CFrame.new(root.Position, mousePos.Value)
				count += 1

				if count % 2 == 0 then
					Util.Sound:Play("QuickSlice", cframe2)
				end

				for _ = 1, 2 do
					local clone2 = script.SpinMesh:Clone()
					clone2.CFrame = cframe2 * CFrame.new(
						(math.random() - 0.5) * v3 * 0.5,
						(math.random() - 0.5) * v3 * 0.5,
						-length * 0.1 - (math.random() - 0.5) * v3 * 0.33
					) * CFrame.Angles(1.57, 0, 0)
					local v4 = clone2.Size * (0.8 + math.random() * 0.4) * v3 * 0.15 * createVector(1, 4, 1)
					clone2.Size = v4 * 0.5
					local tween = TweenService:Create(clone2, TweenInfo.new(0.175, Enum.EasingStyle.Quad), {
						Size = v4 * createVector(1, 0, 1),
						CFrame = clone2.CFrame * CFrame.new(0, length * 0.05, 0) * CFrame.Angles(
							0,
							3.141592653589793,
							0
						),
						Transparency = 1
					})
					tween.Completed:Connect(function()
						clone2:Destroy()
					end)
					tween:Play()
					clone2.Parent = _WorldOrigin
				end

				if not _G.FastMode and count % 6 == 0 then
					local clone2 = script.Air:Clone()
					clone2:SetPrimaryPartCFrame(cframe2 * CFrame.new(0, 0, -length - 20) * CFrame.Angles(-1.57, 0, 0) * CFrame.Angles(
						0,
						math.random() * 3.141592653589793 * 2,
						0
					))

					for _, child in pairs(clone2:GetChildren()) do
						child.Transparency = 0.1
						local tween = TweenService:Create(
							child,
							TweenInfo.new(
								1 + (child == clone2.PrimaryPart and -0.15 or 0),
								Enum.EasingStyle.Exponential
							),
							{
								Size = child.Size * v3 * 0.1 * createVector(3, 9, 3) * (1 + math.random()) * 0.8,
								CFrame = child.CFrame * CFrame.Angles(0, 3.141592653589793, 0) * CFrame.new(
									0,
									-length - 20,
									10
								),
								Transparency = 1
							}
						)

						if child == clone2.PrimaryPart then
							local v4 = clone2
							tween.Completed:Connect(function()
								v4:Destroy()
							end)
						end

						tween:Play()
					end

					clone2.Parent = _WorldOrigin
				end

				for _ = 1, math.random(6, 9) do
					local clone2 = script.RedSpike:Clone()
					clone2:SetPrimaryPartCFrame(cframe2 * CFrame.new(
						(math.random() - 0.5) * v3,
						(math.random() - 0.5) * v3,
						(math.random() - 0.5) * v3
					) * CFrame.Angles(0, 3.141592653589793, 0))

					for _, child in pairs(clone2:GetChildren()) do
						child.Size *= 0.8 + math.random() * 0.4
						local tween = TweenService:Create(
							child,
							TweenInfo.new(0.15 - math.random() * 0.1, Enum.EasingStyle.Quad),
							{
								Size = createVector(0.05, 0.05, 0.05),
								CFrame = child.CFrame * CFrame.new(0, 0, length - math.random() * 20)
							}
						)

						if child == clone2.PrimaryPart then
							local v4 = clone2
							tween.Completed:Connect(function()
								v4:Destroy()
							end)
						end

						tween:Play()
					end

					clone2.Parent = _WorldOrigin
				end

				for i = 1, 3 do
					local part = Instance.new("Part")
					part.Material = "Neon"
					part.Anchored = true
					part.CastShadow = false
					part.CanCollide = false
					part.CFrame = cframe2 * CFrame.new(-40, -40, -length - 40) * CFrame.Angles(
						v3 * 0.01 * (math.random() - 0.5),
						v3 * 0.01 * (math.random() - 0.5),
						v3 * 0.01 * (math.random() - 0.5)
					) * CFrame.new(40, 40, 40)
					part.Size = createVector(1, 1, 1)
					part.Color = i % 2 == 0 and Color3.new(1, 0, 0) or Color3.new()
					local specialMesh = Instance.new("SpecialMesh", part)
					specialMesh.MeshType = "Sphere"
					specialMesh.Scale = Vector3.new(0.5, 0.5, length * 0.25) * 2
					local v4 = length * 0.1333 + length * 0.2 * math.random()
					part.Parent = _WorldOrigin
					local tween = TweenService:Create(
						specialMesh,
						TweenInfo.new(0.1 + math.random() * 0.05, Enum.EasingStyle.Quad),
						{
							Offset = Vector3.new(0, 0, v4 * 4),
							Scale = Vector3.new(0, 0, v4 / 2)
						}
					)
					tween.Completed:Connect(function()
						part:Destroy()
					end)
					tween:Play()
				end

				wait()
			end
		end
	end
end