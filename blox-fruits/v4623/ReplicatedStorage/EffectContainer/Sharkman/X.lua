local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local sound = Util.Sound
local masterClock = Util.MasterClock
local RayCastWhitelist = require(game.ReplicatedStorage.Util.RayCastWhitelist)
local SpikyFlare = require(game.ReplicatedStorage.Util.Particles.SpikyFlare)
require(game.ReplicatedStorage.Util.Particles.Rock)
require(game.ReplicatedStorage.Util.Particles.Dust)
local Rock = require(game.ReplicatedStorage.Util.Rock)

local function alignCF(data, p, _)
	local p2 = data.p
	local unit = data.LookVector:Cross(p).Unit
	local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
	local unit3 = unit2:Cross(p).Unit.Unit
	return CFrame.fromMatrix(p2, unit2, p, unit3)
end

local _WorldOrigin = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
return function(data)
	local direction = data.Direction

	if (direction.p - workspace.CurrentCamera.CFrame.p).magnitude > 500 then
		return
	end

	local explodes = data.Explodes
	local endPos = data.EndPos
	local cframe = CFrame.Angles(1.5707963267948966, 0, 0)
	local v = Util.Sound:Play("SharkmanX", direction)
	local clone = script.FishmanZ:Clone()
	clone:SetPrimaryPartCFrame(direction * cframe)
	clone.Parent = _WorldOrigin
	Effect.new("ExpandRing"):replicate({
		Origin = direction,
		Size = { Vector3.new(), createVector(42, 42, 3) },
		Duration = 0.25
	})
	local v2 = masterClock:GetTime() - data.Timestamp
	local v3 = data.Duration - v2
	local lastTime = tick()
	local count = 0

	while tick() - lastTime < v3 do
		local v4 = tick() - lastTime
		clone:SetPrimaryPartCFrame(direction * CFrame.new(0, 0, -270 * v4) * cframe * CFrame.Angles(0, -v4 * 20, 0))
		count += 1

		if count % 3 == 0 then
			for _, child in pairs(clone:GetChildren()) do
				if child.Name ~= "Clone" then
					continue
				end

				local clone2 = child:Clone()
				clone2.Parent = _WorldOrigin
				local tween = TweenService:Create(
					clone2,
					TweenInfo.new(0.175 + math.random() * 0.175, Enum.EasingStyle.Quad),
					{
						Size = clone2.Size * createVector(2, 0, 2),
						CFrame = clone2.CFrame * CFrame.Angles(0, 3.141592653589793 * math.sign(math.random() - 0.5), 0),
						Transparency = 1
					}
				)
				tween.Completed:Connect(function()
					clone2:Destroy()
				end)
				tween:Play()
			end

			local v5, v6, v7 = RayCastWhitelist(
				clone.Root.Position,
				-direction.UpVector * 11.5 * 1.05,
				{ workspace.Map }
			)

			if v5 then
				local v8 = alignCF(CFrame.new(Vector3.new(), direction.LookVector), v7 or createVector(0, 1, 0)) + v6

				if count % 6 == 0 then
					for i = -1, 1, 2 do
						local color = Color3.new(0, 0.3, 1)
						local color2 = Color3.new(0, 0.5, 1)
						SpikyFlare.new({
							InnerColor = color,
							OuterColor = color2,
							TransparencyInfluence = 0.15,
							AngleInfluence = { Vector3.new(), (Vector3.new(0, 0, -i * 3.141592653589793 / 3)) },
							PulseSpeed = 1,
							FadeIn = 0.1,
							FadeOut = 0.3,
							Lifetime = 0.05,
							CFrame = v8 * CFrame.new(i * 11.5 / 2, 0, 0) * CFrame.Angles(0.5235987755982988, 0, 0),
							Scale = { 20.7, 5.175 * Random.new():NextNumber(4, 4.2) }
						})
						SpikyFlare.new({
							InnerColor = color,
							OuterColor = color2,
							TransparencyInfluence = 0.15,
							AngleInfluence = { Vector3.new(), (Vector3.new(0, 0, -i * 3.141592653589793 / 3)) },
							PulseSpeed = 1,
							FadeIn = 0.1,
							FadeOut = 0.3,
							Lifetime = 0.05,
							CFrame = v8 * CFrame.new(i * 11.5 / 2, 0, 0) * CFrame.Angles(0.5235987755982988, 0, 0),
							Scale = { 20.7, 5.175 * Random.new():NextNumber(4, 4.2) }
						})
					end
				end

				for i = -1, 1, 2 do
					local v9 = v8 * Vector3.new(i * 11.5 * Random.new():NextNumber(0.9, 1.1), 0, 0) - v8.p
					local ground = Rock.new("Ground", {
						Scale = { 6.325, 6.6125 },
						FadeIn = 0.1,
						FadeOut = 0.2,
						Lifetime = { 0.1, 0.15 }
					})
					ground:Spawn(v8)
					ground:TweenShift(v9, 0.25)

					if not (math.random() < 0.3) then
						continue
					end

					local flying = Rock.new("Flying", {
						Scale = { 2.875, 3.8333333333333335 },
						FadeIn = 0.1,
						FadeOut = 0.2,
						Lifetime = { 0.25, 0.5 }
					})
					flying:Spawn(v8 * CFrame.new(i * 11.5, 0, 0))
					flying:Eject({
						RotVelocity = Vector3.new(
							math.random() * 2 * 3.141592653589793,
							math.random() * 2 * 3.141592653589793,
							math.random() * 2 * 3.141592653589793
						) * 2,
						Velocity = (v8 * CFrame.Angles(0, 0, -i * 3.141592653589793 / 6)).UpVector * createVector(
							1,
							0.1,
							0
						) * Random.new():NextNumber(10, 30) * 5.75 + createVector(0, 1, 0) * Random.new():NextNumber(
							30,
							60
						) * 5 * 0.5
					})
				end
			end
		end

		RunService.RenderStepped:Wait()
	end

	Util.Sound:FadeOut(v, 0.65)

	for _, child in pairs(clone:GetChildren()) do
		local tween = TweenService:Create(child, TweenInfo.new(0.1 + math.random() * 0.2, Enum.EasingStyle.Quad), {
			Size = child.Size * Vector3.new(),
			CFrame = child.CFrame * CFrame.new(0, 0, -10),
			Transparency = 1
		})
		local v4 = child
		tween.Completed:Connect(function()
			v4:Destroy()
		end)
		tween:Play()
	end

	if explodes then
		sound:Play("SharkmanExplosion", endPos)

		for _, child in pairs(clone:GetChildren()) do
			local clone2 = child:Clone()
			clone2.CFrame = CFrame.new(endPos) * CFrame.Angles(
				3.141592653589793 * (math.random() - 0.5) * 2,
				3.141592653589793 * (math.random() - 0.5) * 2,
				3.141592653589793 * (math.random() - 0.5) * 2
			)
			clone2.Parent = _WorldOrigin
			local tween = TweenService:Create(
				clone2,
				TweenInfo.new(0.1 + math.random() * 0.25, Enum.EasingStyle.Quad),
				{
					Size = child.Size * 4,
					CFrame = clone2.CFrame * CFrame.Angles(
						0,
						math.sign(math.random() - 0.5) * 3.141592653589793 * 0.66,
						0
					),
					Transparency = 1
				}
			)
			tween.Completed:Connect(function()
				clone2:Destroy()
			end)
			tween:Play()
		end

		for i = 1, 8 do
			local color = (math.random() > 0.5 or i == 1) and Color3.fromRGB(110, 153, 202) or Color3.fromRGB(
				82,
				124,
				174
			)
			local v4 = 20 + math.random() * 14
			local v5 = 0.2 + math.random() * 0.2
			local v6 = math.random(45, 65)

			if i == 1 then
				v4 = 0
				v5 = 0.2
				v6 = 0
			end

			local part = Instance.new("Part")
			part.Anchored = true
			part.CanCollide = false
			part.CFrame = CFrame.new(endPos) * CFrame.Angles(
				3.141592653589793 * (math.random() - 0.5) * 2,
				3.141592653589793 * (math.random() - 0.5) * 2,
				3.141592653589793 * (math.random() - 0.5) * 2
			)
			part.Size = createVector(1, 1, 1)
			part.Color = color
			part.Transparency = 0
			part.Material = "Neon"
			local specialMesh = Instance.new("SpecialMesh")
			specialMesh.MeshType = "Sphere"
			specialMesh.Scale = createVector(0.2, 0.2, 1) * v4
			specialMesh.Parent = part
			part.Parent = _WorldOrigin
			TweenService:Create(part, TweenInfo.new(v5, Enum.EasingStyle.Quad), {
				Transparency = 1
			}):Play()
			local tween = TweenService:Create(specialMesh, TweenInfo.new(v5, Enum.EasingStyle.Quad), {
				Scale = i == 1 and createVector(60, 60, 60) or Vector3.new(),
				Offset = Vector3.new(0, 0, v6)
			})
			tween.Completed:Connect(function()
				part:Destroy()
			end)
			tween:Play()
		end
	end

	wait(1)
	clone:Destroy()
end