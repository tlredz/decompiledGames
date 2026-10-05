local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(game.ReplicatedStorage.FX)
local _ = Util.Sound
local _ = Util.MasterClock
local _ = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
game:GetService("RunService")

local function distanceCK(p, p2, callback)
	local character = game.Players.LocalPlayer.Character

	if character then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - p).magnitude <= p2 then
			callback()
		end
	end
end

return function(data)
	local character_to_send = data.character_to_send
	local humanoidRootPart

	if character_to_send then
		humanoidRootPart = character_to_send:WaitForChild("HumanoidRootPart")
	else
		humanoidRootPart = nil
	end

	local part_to_send = data.part_to_send
	local cframe_to_send = data.cframe_to_send

	if (cframe_to_send.p - workspace.CurrentCamera.CFrame.p).Magnitude >= 1500 then
		return
	end

	local scale_to_send = data.scale_to_send or 1
	local ultimate_ko_to_send = data.ultimate_ko_to_send

	if not part_to_send and ultimate_ko_to_send then
		return
	end

	if ultimate_ko_to_send then
		local p = cframe_to_send.p
		local character = game.Players.LocalPlayer.Character

		if character then
			local humanoidRootPart2 = character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart2 and (humanoidRootPart2.Position - p).magnitude <= 100 then
				Util.CameraShaker:ShakeOnce(15, 10, 0.1, 1, createVector(1, 1, 1), createVector(1, 1, 1))
			end
		end
	elseif not ultimate_ko_to_send then
		local p = cframe_to_send.p
		local character = game.Players.LocalPlayer.Character

		if character then
			local humanoidRootPart2 = character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart2 and (humanoidRootPart2.Position - p).magnitude <= 100 then
				Util.CameraShaker:ShakeOnce(2.5, 10, 0.1, 1, createVector(1, 1, 1), createVector(1, 1, 1))
			end
		end
	end

	local v = math.random(20, 25) / 100
	local v2 = math.random(35, 50) / 100
	local v3 = math.random(50, 75) / 100

	if ultimate_ko_to_send and character_to_send and humanoidRootPart then
		v /= 0.5
		v2 /= 0.5
		v3 /= 0.5

		if not part_to_send then
			return
		end

		local v4 = {
			side = 0,
			rotation_y = 0,
			rotation_z = 0
		}
		coroutine.resume(coroutine.create(function()
			for i = 1, 2 do
				if i == 1 then
					v4.side = -humanoidRootPart.Size.X * 10
					v4.rotation_y = -25
					v4.rotation_z = 15
				elseif i == 2 then
					v4.side = humanoidRootPart.Size.X * 10
					v4.rotation_y = 25
					v4.rotation_z = -15
				end

				local ray, _, _ = Util.Ray(
					humanoidRootPart.CFrame.p + Vector3.new(v4.side, 5, 0),
					humanoidRootPart.CFrame.UpVector * -10,
					{ workspace.Characters, workspace.Enemies },
					false
				)

				if not ray then
					continue
				end

				local clone = FX:WaitForChild("MagmaEffects"):WaitForChild("wind"):Clone()
				local mesh = clone:WaitForChild("Mesh")
				mesh.Scale = mesh.Scale * scale_to_send * 3
				mesh.VertexColor = createVector(5, 0, 0)
				clone.CFrame = humanoidRootPart.CFrame * CFrame.new(
					v4.side,
					-mesh.Scale.Y + scale_to_send / 1.5,
					mesh.Scale.X * 5
				)
				clone.CFrame *= CFrame.Angles(0, math.rad(v4.rotation_y), (math.rad(v4.rotation_z)))
				clone.Parent = workspace
				TweenService:Create(clone, TweenInfo.new(v / 2), {
					CFrame = clone.CFrame * CFrame.new(0, scale_to_send, scale_to_send * 3)
				}):Play()
				TweenService:Create(mesh, TweenInfo.new(v / 2), {
					Scale = mesh.Scale + Vector3.new(0, scale_to_send / 2, scale_to_send / 3)
				}):Play()
				coroutine.resume(coroutine.create(function()
					wait(v / 5)
					local tween = TweenService:Create(clone, TweenInfo.new(v3), {
						CFrame = clone.CFrame * CFrame.new(0, 0, scale_to_send * 2),
						Transparency = 1
					})
					tween:Play()
					tween.Completed:Connect(function()
						clone:Destroy()
					end)
					TweenService:Create(mesh, TweenInfo.new(v3), {
						Scale = mesh.Scale + Vector3.new(0, 0, scale_to_send / 10),
						VertexColor = createVector(0, 0, 0)
					}):Play()
				end))
			end
		end))
		coroutine.resume(coroutine.create(function()
			for i = 1, 3 do
				local clone = FX:WaitForChild("MagmaEffects"):WaitForChild("Swoosher"):Clone()
				clone.CFrame = part_to_send.CFrame * CFrame.Angles(-1.5707963267948966, 0, 0)
				clone.Size = Vector3.new(math.random(50, 100) / 10, 5, math.random(50, 100) / 10) * scale_to_send * 2

				if i == 1 then
					clone.CFrame = clone.CFrame * CFrame.new(0, 2.5, 0) * CFrame.Angles(0, 0.4363323129985824, 0)
					clone.Color = Color3.fromRGB(170, 85, 0)
				elseif i == 2 then
					clone.CFrame = clone.CFrame * CFrame.new(0, 2.5, 0) * CFrame.Angles(0, 0.8726646259971648, 0)
					clone.Color = Color3.fromRGB(17, 17, 17)
				elseif i == 3 then
					clone.CFrame = clone.CFrame * CFrame.new(0, 2.5, 0) * CFrame.Angles(0, 1.3089969389957472, 0)
					clone.Color = Color3.fromRGB(255, 0, 0)
				end

				clone.Parent = workspace:WaitForChild("_WorldOrigin")
				local v5 = math.random(15, 20) / 10
				local v6 = math.random(35, 75) / 100
				local tween = TweenService:Create(clone, TweenInfo.new(v6), {
					CFrame = clone.CFrame * CFrame.new(0, clone.Size.Y * v5 / math.random(15, 20) / 10, 0) * CFrame.Angles(
						0,
						2.792526803190927,
						0
					),
					Size = clone.Size * v5,
					Transparency = 1
				})
				tween:Play()
				tween.Completed:Connect(function()
					clone:Destroy()
				end)
			end
		end))
		local clone = FX:WaitForChild("MagmaEffects"):WaitForChild("MagmaBeam"):Clone()

		for _, part in pairs(clone:GetChildren()) do
			if part:IsA("BasePart") then
				part.Size = part.Size * scale_to_send / 1.25
			end
		end

		clone:SetPrimaryPartCFrame(part_to_send.CFrame * CFrame.new(0, 0, clone.PrimaryPart.Size.Z / 2) * CFrame.Angles(
			0,
			3.141592653589793,
			0
		))
		clone.Parent = workspace:WaitForChild("_WorldOrigin")
		local v5 = math.random(35, 75) / 100

		for _, part in pairs(clone:GetChildren()) do
			if not part:IsA("BasePart") then
				continue
			end

			if part.Name == "dash" then
				TweenService:Create(part, TweenInfo.new(v5), {
					CFrame = part.CFrame * CFrame.new(0, 0, -part.Size.Z * 2 / 2),
					Size = Vector3.new(0, 0, part.Size.Z * 2)
				}):Play()
				local v6 = part
				coroutine.resume(coroutine.create(function()
					wait(v5)
					v6.Transparency = 1
				end))
			elseif part.Name == "swirl" then
				TweenService:Create(part, TweenInfo.new(v5), {
					CFrame = part.CFrame * CFrame.new(0, -part.Size.Y * 2 / 2, 0) * CFrame.Angles(
						0,
						2.792526803190927,
						0
					),
					Size = Vector3.new(0, part.Size.Y * 2, 0)
				}):Play()
				local v6 = part
				coroutine.resume(coroutine.create(function()
					wait(v5)
					v6.Transparency = 1
				end))
			end
		end

		Util.Debris:AddItem(clone, 5)
	end

	local clone = FX:WaitForChild("MagmaEffects"):WaitForChild("ShockwaveNeon"):Clone()
	clone.CanTouch = false
	clone.CFrame = cframe_to_send * CFrame.Angles(1.5707963267948966, 0, 0)
	clone.CFrame *= CFrame.Angles(
		math.rad(math.random(-100, 100) / 10),
		math.rad(math.random(-100, 100) / 10),
		(math.rad(math.random(-100, 100) / 10))
	)
	clone.Size = createVector(35, 15, 35) * scale_to_send / 2
	clone.Parent = workspace:WaitForChild("_WorldOrigin")
	local tween = TweenService:Create(clone, TweenInfo.new(v, Enum.EasingStyle.Quart), {
		Size = clone.Size * math.random(20, 25) / 10,
		Transparency = 1
	})
	tween:Play()
	tween.Completed:Connect(function()
		clone:Destroy()
	end)
	local clone2 = FX:WaitForChild("MagmaEffects"):WaitForChild("Innerswirl"):Clone()
	clone2.CanTouch = false
	clone2.CFrame = clone.CFrame * CFrame.Angles(3.141592653589793, 0, 0)
	clone2.CFrame *= CFrame.Angles(
		math.rad(math.random(-100, 100) / 10),
		math.rad(math.random(-100, 100) / 10),
		(math.rad(math.random(-100, 100) / 10))
	)
	clone2.Size = createVector(25, 10, 25) * scale_to_send / 2
	clone2.Parent = workspace:WaitForChild("_WorldOrigin")
	local tween2 = TweenService:Create(clone2, TweenInfo.new(v2, Enum.EasingStyle.Quart), {
		CFrame = clone2.CFrame * CFrame.Angles(0, math.rad(math.random(-3600, 3600) / 10), 0),
		Size = clone2.Size * math.random(12, 15) / 10,
		Transparency = 1,
		Color = Color3.fromRGB(0, 0, 0)
	})
	tween2:Play()
	tween2.Completed:Connect(function()
		clone2:Destroy()
	end)
	local v4 = not ultimate_ko_to_send and 1 or math.random(3, 6)
	coroutine.resume(coroutine.create(function()
		for _ = 1, v4 do
			local clone3 = FX:WaitForChild("MagmaEffects"):WaitForChild("MagmaBall"):Clone()

			for _, part in pairs(clone3:GetDescendants()) do
				if not (part:IsA("BasePart") and part.Name ~= "Sphere" and part.Name ~= "old" and part.Name ~= "root") then
					continue
				end

				part:Destroy()
			end

			clone3:SetPrimaryPartCFrame(cframe_to_send * CFrame.new(0, 0, -10) * CFrame.Angles(1.5707963267948966, 0, 0))
			clone3.Parent = workspace:WaitForChild("_WorldOrigin")
			local sphere = clone3:WaitForChild("Sphere")
			sphere.Size = createVector(35, 20, 35)
			local tween3 = TweenService:Create(sphere, TweenInfo.new(v3, Enum.EasingStyle.Quart), {
				CFrame = sphere.CFrame * CFrame.new(0, math.random(200, 250) / 10, 0) * CFrame.Angles(
					0,
					math.rad(math.random(-3600, 3600) / 10),
					0
				),
				Size = sphere.Size * math.random(15, 20) / 10,
				Transparency = 1,
				Color = Color3.fromRGB(255, 0, 0)
			})
			tween3:Play()
			tween3.Completed:Connect(function()
				clone3:Destroy()
			end)
			wait()
		end
	end))
end