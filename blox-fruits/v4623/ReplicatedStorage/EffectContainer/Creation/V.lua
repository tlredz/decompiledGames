local createVector = vector.create
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local TweenService = game:GetService("TweenService")
local CustomCollisions = require(ReplicatedStorage:WaitForChild("CustomCollisions"))
local rocks = CustomCollisions.new("Rocks")
local _ = Util.Sound
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local V = FX:WaitForChild("Creation").V
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local v = {
	"rbxassetid://89597371734260",
	"rbxassetid://71085425555113",
	"rbxassetid://127033087282795",
	"rbxassetid://84521437474990",
	"rbxassetid://94451837589678"
}

-- equivalent calls inferred from this helper; original call sites unknown
local function DeleteImpactAfterDuration(folder)
	task.spawn(function()
		local v2 = 0

		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				v2 = math.max(v2, emitter.Lifetime.Max)
			end
		end

		task.wait(v2)
		folder:Destroy()
	end)
end

local function GetCFramePlane(cframe, p)
	local function ProjectToPlane2D(p2, cframe2)
		local _ = cframe2.UpVector
		local pointToObjectSpace = cframe2:PointToObjectSpace(p2)
		local pointToWorldSpace = cframe2:PointToWorldSpace((Vector3.new(pointToObjectSpace.X, pointToObjectSpace.Y, 0)))
		return CFrame.lookAt(pointToWorldSpace, pointToWorldSpace + cframe2.LookVector)
	end

	local position = p.Position
	local _ = cframe.UpVector
	local pointToObjectSpace = cframe:PointToObjectSpace(position)
	local pointToWorldSpace = cframe:PointToWorldSpace((Vector3.new(pointToObjectSpace.X, pointToObjectSpace.Y, 0)))
	return (CFrame.lookAt(pointToWorldSpace, pointToWorldSpace + cframe.LookVector))
end

local function SurfaceHit(p, parent)
	local v2 = {
		Color3.fromRGB(255, 58, 127),
		Color3.fromRGB(87, 255, 185),
		Color3.fromRGB(84, 69, 255),
		Color3.fromRGB(142, 49, 255),
		Color3.fromRGB(85, 167, 255)
	}
	local clone = V.Phase3.ObjectHitImpact:Clone()
	clone.CFrame = p * CFrame.new(0, 0, 1.5)
	clone.Parent = parent

	for _, emitter in pairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter:Emit(emitter:GetAttribute("EmitCount"))
		local v3 = v2[math.random(1, #v2)]
		emitter.Color = ColorSequence.new(v3, v3)
	end

	DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
end

local function CreateCube(p, cFrame, model)
	local clone = V.Phase4.CubePart:Clone()
	clone.Size = p + Vector3.new(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10))
	clone.CFrame = cFrame
	clone.Parent = model
	clone.Color = Color3.fromRGB(math.random(200, 250), math.random(35, 70), math.random(60, 100)):Lerp(
		Color3.fromRGB(0, 0, 0),
		0.9
	)
	clone.Transparency = 0
	rocks:ApplyCollision(clone, nil, true)
	local v2 = math.random(5, 10) / 100
	TweenService:Create(clone, TweenInfo.new(0.325 - v2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		CFrame = clone.CFrame * CFrame.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
	})
	clone.CFrame *= CFrame.new(math.random(-5, 5) * 2, math.random(-5, 5) * 2, math.random(-5, 5) * 2)
	clone.CFrame *= CFrame.Angles(
		math.rad(math.random(-5, 5) * 10),
		math.rad(math.random(-5, 5) * 10),
		(math.rad(math.random(-5, 5) * 10))
	)
	local v3 = {
		Color3.fromRGB(150, 200, 400),
		Color3.fromRGB(480, 50, 100),
		Color3.fromRGB(450, 200, 150),
		Color3.fromRGB(250, 380, 500),
		Color3.fromRGB(250, 480, 250),
		Color3.fromRGB(500, 100, 250),
		Color3.fromRGB(500, 200, 250),
		Color3.fromRGB(200, 100, 450)
	}
	local selectionBox = clone.SelectionBox
	selectionBox.Color3 = v3[math.random(1, 8)]
	selectionBox.Parent = clone
	selectionBox.Adornee = clone
	return clone
end

local function CreateBuilding(cubeCFrame, folder, multiplier, proxy, canCollide)
	local clone = V.Phase1.CubeModel:Clone()
	clone:SetPrimaryPartCFrame(cubeCFrame)
	clone:ScaleTo(multiplier)
	local Y = clone.Cube.Size.Y
	local X = clone.Cube.Size.X
	local halfX = X / 2
	clone.Cube.CFrame = clone.Cube.CFrame * CFrame.new(0, Y / 2, 0) * CFrame.Angles(
		0,
		math.rad(90 * math.random(1, 4)),
		0
	)
	clone.Cube.CanCollide = false

	if canCollide then
		proxy.CanCollide = true
		clone.Cube.CanCollide = true
	else
		local character = game.Players.LocalPlayer.Character

		if character then
			character:GetAttributeChangedSignal("LastDamageTick"):Once(function()
				if clone:FindFirstChild("Cube") then
					clone.Cube.CanCollide = true
					proxy.CanCollide = true
				end
			end)
		end
	end

	task.spawn(function()
		for i = 1, 4 do
			local clone2 = V.Phase1.CubeAura:Clone()
			clone2.Size = Vector3.new(X, Y / 100, clone2.Size.Z)
			clone2.CFrame = cubeCFrame * CFrame.Angles(0, math.rad(i * 90), 0)
			clone2.Parent = folder
			clone2.CFrame *= CFrame.new(0, 0, -halfX)
			TweenService:Create(clone2, TweenInfo.new(0.5), {
				CFrame = clone2.CFrame * CFrame.new(0, Y / 2, 0),
				Size = Vector3.new(X + 25, Y, clone2.Size.Z)
			}):Play()
			local folder2 = clone2
			task.delay(0.5, function()
				for i2, emitter in pairs(folder2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end)
		end
	end)
	task.spawn(function()
		local v3 = halfX * 1.15

		for i = 1, 4 do
			local clone2 = V.Phase1.BeamWall:Clone()
			clone2.CFrame = cubeCFrame * CFrame.Angles(0, math.rad(i * 90), 0)
			clone2.Parent = folder
			clone2.CFrame *= CFrame.new(0, 0, -v3)

			for _, beam in pairs(clone2:GetDescendants()) do
				if beam.Name == "Attach1" then
					local tween = TweenService:Create(
						beam,
						TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
						{
							Position = Vector3.new(0, Y, 0)
						}
					)
					beam.Position = createVector(0, 0, 0)
					tween:Play()
					local v4 = beam
					task.delay(0.35, function()
						TweenService:Create(
							v4.Parent.Attach0,
							TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
							{
								Position = v4.Position
							}
						):Play()
					end)
				elseif beam:IsA("Beam") then
					beam.Color = ColorSequence.new(Color3.fromRGB(176, 197, 255), Color3.fromRGB(176, 197, 255))
					beam.Width0 = v3 * 2
					beam.Width1 = v3 * 2
					TweenService:Create(
						beam,
						TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0, false, 0.25),
						{
							LightEmission = 1
						}
					):Play()
				end
			end

			task.delay(1, function()
				clone2:Destroy()
			end)
		end
	end)
	task.spawn(function()
		local clone2 = V.Phase1.BeamStartBeams:Clone()
		clone2.CFrame = cubeCFrame * CFrame.new(0, 0, 0)
		clone2.Parent = folder

		for _, descendant in pairs(clone2:GetDescendants()) do
			if descendant:IsA("ParticleEmitter") then
				descendant.Enabled = true
				local v3 = descendant
				task.spawn(function()
					task.wait(0.5)
					v3.Enabled = false
				end)
			elseif descendant:IsA("Attachment") then
				if descendant.Name == "Attach1" then
					local tween = TweenService:Create(descendant, TweenInfo.new(0.15), {
						Position = Vector3.new(0, Y, 0)
					})
					descendant.Position = createVector(0, 0, 0)
					tween:Play()
				elseif descendant.Name == "Attach2" then
					local tween = TweenService:Create(descendant, TweenInfo.new(0.25), {
						Position = descendant.Position
					})

					if descendant.Parent.Parent.Name == "A" then
						descendant.Position = Vector3.new(-halfX, 0, -halfX)
					elseif descendant.Parent.Parent.Name == "B" then
						descendant.Position = Vector3.new(-halfX, 0, halfX)
					elseif descendant.Parent.Parent.Name == "C" then
						descendant.Position = Vector3.new(halfX, 0, halfX)
					elseif descendant.Parent.Parent.Name == "D" then
						descendant.Position = Vector3.new(halfX, 0, -halfX)
					end

					tween:Play()
				end
			elseif descendant:IsA("Beam") then
				descendant.Color = ColorSequence.new(Color3.fromRGB(112, 126, 255), Color3.fromRGB(112, 126, 255))
				descendant.Width0 = 3
				descendant.Width1 = 3
				local v3 = descendant
				task.spawn(function()
					task.wait(0.125)
					TweenService:Create(
						v3,
						TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0, false, 0.25),
						{
							LightEmission = 1
						}
					):Play()
					task.wait(0.4)
					local tween = TweenService:Create(
						v3,
						TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Width0 = 0,
							Width1 = 0
						}
					)
					tween:Play()
					tween.Completed:Wait()
					v3:Destroy()
				end)
			elseif descendant:IsA("BasePart") then
				local v3 = halfX * 1.25

				if descendant.Name == "A" then
					descendant.WeldConstraint.Enabled = false
					descendant.CFrame = clone2.CFrame * CFrame.new(v3, 0, v3)
					descendant.WeldConstraint.Enabled = true
				elseif descendant.Name == "B" then
					descendant.WeldConstraint.Enabled = false
					descendant.CFrame = clone2.CFrame * CFrame.new(v3, 0, -v3)
					descendant.WeldConstraint.Enabled = true
				elseif descendant.Name == "C" then
					descendant.WeldConstraint.Enabled = false
					descendant.CFrame = clone2.CFrame * CFrame.new(-v3, 0, -v3)
					descendant.WeldConstraint.Enabled = true
				elseif descendant.Name == "D" then
					descendant.WeldConstraint.Enabled = false
					descendant.CFrame = clone2.CFrame * CFrame.new(-v3, 0, v3)
					descendant.WeldConstraint.Enabled = true
				end
			elseif descendant:IsA("Weld") then
				descendant.C1 = CFrame.new(0, Y, 0)
			end
		end

		TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			CFrame = clone2.CFrame * CFrame.Angles(3.141592653589793, 3.141592653589793, 3.141592653589793)
		}):Play()
	end)
	task.wait(0.35)
	clone.Parent = folder
	local v3 = {
		Color3.fromRGB(150, 200, 400),
		Color3.fromRGB(480, 50, 100),
		Color3.fromRGB(450, 200, 150),
		Color3.fromRGB(250, 380, 500),
		Color3.fromRGB(250, 480, 250),
		Color3.fromRGB(500, 100, 250),
		Color3.fromRGB(500, 200, 250),
		Color3.fromRGB(200, 100, 450)
	}

	for _, descendant in pairs(clone:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.CanCollide = false
			descendant.Color = Color3.fromRGB(math.random(200, 250), math.random(35, 70), math.random(60, 100)):Lerp(
				Color3.fromRGB(0, 0, 0),
				0.9
			)
			local tween = TweenService:Create(
				descendant,
				TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Size = descendant.Size,
					CFrame = descendant.CFrame
				}
			)
			descendant.Size = Vector3.new(math.random(0, 5), descendant.Size.Y, math.random(0, 5))
			descendant.CFrame *= CFrame.Angles(0, 1.7453292519943295, 0)
			tween:Play()
			descendant.Transparency = 0
			local v4 = descendant
			task.spawn(function()
				task.wait(0.25)

				if v4.Name == "Surface" then
					TweenService:Create(
						v4,
						TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.InOut, 0, true),
						{
							CFrame = v4.CFrame * CFrame.new(0, 25, 0)
						}
					):Play()
				elseif v4.Name == "Leg" then
					TweenService:Create(
						v4,
						TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.InOut, 0, true),
						{
							CFrame = v4.CFrame * CFrame.new(0, 15, 0),
							Size = Vector3.new(v4.Size.X, v4.Size.Y * 6.5, v4.Size.Z)
						}
					):Play()
				end
			end)
		elseif descendant:IsA("SelectionBox") then
			local v4 = descendant
			task.spawn(function()
				v4.Color3 = v3[math.random(1, 8)]
				v4.SurfaceColor3 = v4.Color3
				v4.LineThickness = 5
				TweenService:Create(v4, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), {
					LineThickness = 0.5
				}):Play()
			end)
		elseif descendant:IsA("Decal") then
			descendant.Texture = v[math.random(1, #v)]
		end
	end

	task.wait(0.35)
	local cFrame = clone.PrimaryPart.CFrame
	task.spawn(function()
		local clone2 = V.Phase2.DropAura:Clone()
		clone2.CFrame = cFrame
		clone2.Size = clone.PrimaryPart.Size * 1.5
		clone2.Parent = folder
		clone2.WeldConstraint.Part1 = clone.PrimaryPart
		clone2.Anchored = false
		clone2.DropAura2.Size = Vector3.new(X * 1.25, Y / 5, X * 1.25)
		clone2.DropAura2.CFrame = cFrame * CFrame.new(0, -Y / 3, 0)
		clone2.DropAura2.WeldConstraint.Enabled = true
		clone2.DropAura2.Anchored = false
		local emittersByEmitter = {}

		for _, emitter in pairs(clone2:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			if emitter:GetAttribute("EMIT") then
				emittersByEmitter[emitter] = emitter
			end

			emitter.Enabled = true
		end

		local lastTime = tick()

		while true do
			for _, v4 in pairs(emittersByEmitter) do
				v4:Emit(1)
			end

			task.wait(0.005)

			if not (tick() - lastTime >= 0.15) then
				continue
			end

			for _, emitter in pairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			break
		end
	end)
	local v4 = Y + 150
	local ray = Ray.new(cFrame.Position, cFrame.UpVector * -v4)
	local part, v5 = workspace:FindPartOnRayWithIgnoreList(ray, { folder })
	v5 += Vector3.new(0, Y / 2, 0)
	local cFrame2 = proxy.CFrame
	TweenService:Create(clone.PrimaryPart, TweenInfo.new(0.15), {
		CFrame = proxy.CFrame
	}):Play()
	clone.PrimaryPart.CanTouch = false
	task.delay(0.15, function()
		if part then
			local clone2 = V.Phase2.HitImpactModel:Clone()
			clone2:ScaleTo(multiplier)
			local primaryPart = clone2.PrimaryPart
			primaryPart.CFrame = cFrame2 * CFrame.new(0, -Y / 2, 0)
			clone2.Parent = folder
			Util.Sound:Play(
				"CreationFruit_V1_V_SkyscraperSlamImpact_0" .. tostring(math.random(1, 8)),
				primaryPart.Position
			)

			for _, emitter in pairs(primaryPart:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v6 = emitter
				task.spawn(function()
					if v6:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v6:GetAttribute("EmitDelay"))
					end

					v6:Emit(v6:GetAttribute("EmitCount"))
				end)
			end

			DeleteImpactAfterDuration(clone2) -- equivalent call inferred; original call site unknown
		end

		clone.PrimaryPart.CanCollide = canCollide
		clone.PrimaryPart.CanTouch = false
	end)

	local function snapToSurface(p, p2, p3)
		local pointToObjectSpace = p2.CFrame:PointToObjectSpace(p3)
		local vector2 = Vector3.new(
			not (math.abs(pointToObjectSpace.X) > math.abs(pointToObjectSpace.Z)) and 0 or math.sign(pointToObjectSpace.X) or 0,
			0,
			math.abs(pointToObjectSpace.Z) > math.abs(pointToObjectSpace.X) and math.sign(pointToObjectSpace.Z) or 0
		)

		if vector2 == createVector(0, 0, 0) then
			return
		end

		local vectorToWorldSpace = p2.CFrame:VectorToWorldSpace(vector2)
		local v6 = p3 + vectorToWorldSpace * (p.Size / 2).X
		p.CFrame = CFrame.new(v6, v6 + vectorToWorldSpace)
	end

	local primaryPart = clone.PrimaryPart
	task.wait(10)
	local selectionBox = primaryPart.SelectionBox
	task.spawn(function()
		task.wait(0.5)
		Util.Sound:Play("CreationFruit_V1_V_SkyscraperDisappear_0" .. tostring(math.random(1, 8)), primaryPart.Position)
		TweenService:Create(selectionBox, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			LineThickness = 1,
			SurfaceTransparency = 0,
			SurfaceColor3 = Color3.fromRGB(math.random(400, 600), math.random(400, 600), math.random(400, 600))
		}):Play()
		task.wait(0.5)
		TweenService:Create(primaryPart, TweenInfo.new(0.125, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			CFrame = primaryPart.CFrame * CFrame.Angles(0, 2.9670597283903604, 0)
		}):Play()
	end)
	task.wait(1)
	task.wait(0.05)
	local clone2 = V.Phase4.EndImpact:Clone()
	clone2.CFrame = primaryPart.CFrame
	clone2.Parent = folder

	for _, emitter in pairs(clone2:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v6 = emitter
		task.spawn(function()
			if v6:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v6:GetAttribute("EmitDelay"))
			end

			v6:Emit((math.clamp(v6:GetAttribute("EmitCount") / 3, 1, v6:GetAttribute("EmitCount"))))
		end)
	end

	DeleteImpactAfterDuration(clone2) -- equivalent call inferred; original call site unknown
	local clone3 = V.Phase4.Explosion:Clone()
	clone3.CFrame = clone2.CFrame
	clone3.Parent = folder

	for _, emitter in pairs(clone3:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v6 = emitter
		task.spawn(function()
			if v6:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v6:GetAttribute("EmitDelay"))
			end

			v6:Emit((math.clamp(v6:GetAttribute("EmitCount") / 3, 1, v6:GetAttribute("EmitCount"))))
		end)
	end

	DeleteImpactAfterDuration(clone3) -- equivalent call inferred; original call site unknown
	task.spawn(function()
		local model = Instance.new("Model")
		model.Parent = folder

		for _ = 1, 10 do
			local cFrame3 = primaryPart.CFrame * CFrame.new(
				math.random(-30, 30),
				math.random(-50, 50),
				math.random(-30, 30)
			)
			CreateCube(createVector(10, 10, 10), cFrame3, model)
		end

		for _, part2 in pairs(model:GetChildren()) do
			if not part2:IsA("BasePart") then
				continue
			end

			local v6 = part2
			task.spawn(function()
				v6.CanCollide = false
				v6.Anchored = false
				v6.Massless = false
				local v7 = 0.1 * math.random() + 0.01
				local tween = TweenService:Create(
					v6,
					TweenInfo.new(v7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Orientation = Vector3.new(math.random(-50, 50), math.random(-50, 50), math.random(-50, 50))
					}
				)
				tween:Play()
				task.spawn(function()
					task.wait(v7 * 0.8)
					tween:Pause()
					tween:Destroy()
					v6.Velocity = CFrame.new(v6.Position, cubeCFrame.Position).LookVector * -math.random(50, 100)
				end)
				local selectionBox2 = v6.SelectionBox
				task.spawn(function()
					selectionBox2.LineThickness = 3
					TweenService:Create(
						selectionBox2,
						TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
						{
							LineThickness = 0.25
						}
					):Play()
				end)
				task.wait(1)
				task.wait(0.5 * math.random())
				local tween2 = TweenService:Create(v6, TweenInfo.new(0.225), {
					Size = createVector(0, 0, 0),
					Orientation = Vector3.new(math.random(-50, 50), math.random(-50, 50), math.random(-50, 50))
				})
				tween2:Play()
				tween2.Completed:Wait()
				v6.SelectionBox.Transparency = 1
			end)
		end
	end)
	clone:Destroy()
end

return function(data)
	local origin = data.origin

	if (currentCamera.CFrame.p - origin).Magnitude > 2000 then
		return
	end

	local stage = data.Stage

	if stage == 1 then
		local root = data.Root
		local holding = data.Holding

		if not (holding and holding.Value) then
			return
		end

		local folder = Instance.new("Folder")
		folder.Parent = _WorldOrigin
		local _ = root.CFrame
		Util.Sound:Play("CreationFruit_V1_V_Start_01", root.Position)
		local v2 = Util.Sound:Play("CreationFruit_V1_V_Hold_01", root)
		TweenService:Create(v2, TweenInfo.new(0.5), {
			Volume = 1
		}):Play()
		local clone = V.Phase0.HoldAura:Clone()
		clone.CFrame = root.CFrame
		clone.Parent = folder
		clone.Weld.Part1 = root
		clone.Anchored = false
		clone.Massless = true

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter:Emit(1)
			emitter.Enabled = true
		end

		local v3 = {
			Color3.fromRGB(150, 200, 400),
			Color3.fromRGB(480, 50, 100),
			Color3.fromRGB(450, 200, 150),
			Color3.fromRGB(250, 380, 500),
			Color3.fromRGB(250, 480, 250),
			Color3.fromRGB(500, 100, 250),
			Color3.fromRGB(500, 200, 250),
			Color3.fromRGB(200, 100, 450)
		}
		local v4 = {}

		for i = 1, 3 do
			for i2 = 1, 3 do
				local clone2 = V.Phase0.Box:Clone()
				local cframe

				if i == 1 then
					cframe = CFrame.new(-3, i2 / 3, i2 * -2)
				elseif i == 2 then
					cframe = CFrame.new(3, i2 / 3, i2 * -2)
				else
					cframe = CFrame.new(0, i2 / 3, i2 * -2)
				end

				local cFrameOffset = cframe * CFrame.new(
					math.random(-10, 10) / 20,
					math.random(-1, 1) / 10,
					math.random(-1, 1) / 10
				)
				clone2.CFrame = root.CFrame * cFrameOffset
				clone2.Parent = folder
				clone2.CanCollide = false
				clone2.CanTouch = true
				local outline = clone2.Outline
				outline.CFrame = clone2.CFrame
				v4[clone2] = {
					Outline = outline,
					CFrameOffset = cFrameOffset,
					BoxRotation = Vector3.new(0, math.random(-180, 180), 0),
					OutlineRotation = Vector3.new(0, math.random(-180, 180), 0),
					Reverse = false,
					YDifference = 0
				}
			end
		end

		for folder2, _ in pairs(v4) do
			for _, descendant in pairs(folder2:GetDescendants()) do
				if descendant:IsA("SelectionBox") then
					descendant.Color3 = v3[math.random(1, 8)]
					descendant.SurfaceColor3 = descendant.Color3
					TweenService:Create(
						descendant,
						TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
						{
							LineThickness = descendant.LineThickness
						}
					):Play()
					descendant.LineThickness = 1
				elseif descendant:IsA("Decal") then
					descendant.Texture = v[math.random(1, #v)]
				end
			end
		end

		while true do
			for k, v5 in pairs(v4) do
				local outline = v5.Outline
				local boxRotation = v5.BoxRotation
				local outlineRotation = v5.OutlineRotation
				local cFrameOffset = v5.CFrameOffset
				k.Position = root.CFrame * cFrameOffset.Position
				local _ = v5.YDifference

				if v5.Reverse == false then
					v5.YDifference += 0.025 * math.random()

					if v5.YDifference >= 1 then
						v5.Reverse = true
					end
				elseif v5.Reverse == true then
					v5.YDifference -= 0.025 * math.random()

					if v5.YDifference <= -1 then
						v5.Reverse = false
					end
				end

				k.Position += Vector3.new(0, v5.YDifference, 0)
				k.Orientation = boxRotation
				outline.Position = k.Position
				outline.Orientation = outlineRotation
				v5.BoxRotation += createVector(0, -1, 0)
				v5.OutlineRotation += createVector(0, 1, 0)
			end

			task.wait()

			if holding:IsDescendantOf(workspace) and holding.Value then
				continue
			end

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			if v2 then
				Util.Sound:FadeOut(v2, 0.2)
			end

			for folder2, _ in pairs(v4) do
				TweenService:Create(folder2, TweenInfo.new(0.15), {
					Size = createVector(0, 0, 0),
					Orientation = Vector3.new(math.random(-90, 90), math.random(-90, 90), math.random(-90, 90))
				}):Play()

				for _, descendant in pairs(folder2:GetDescendants()) do
					if descendant:IsA("SelectionBox") then
						TweenService:Create(descendant, TweenInfo.new(0.15), {
							LineThickness = 0,
							Transparency = 1
						}):Play()
					elseif descendant:IsA("BasePart") then
						TweenService:Create(descendant, TweenInfo.new(0.15), {
							Size = createVector(0, 0, 0)
						}):Play()
					end
				end
			end

			task.wait(5)
			folder:Destroy()
			return
		end
	elseif stage == 2 then
		local root = data.Root
		local folder = Instance.new("Folder")
		folder.Parent = _WorldOrigin
		Util.Debris:AddItem(folder, 25)
		Util.Sound:Play("CreationFruit_V1_V_Release_01", root)
		local clone = V.Phase1.StartImpact:Clone()
		clone.CFrame = root.CFrame * CFrame.new(0, 0, -1)
		clone.Parent = folder

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v2 = emitter
			task.spawn(function()
				if v2:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v2:GetAttribute("EmitDelay"))
				end

				v2:Emit(v2:GetAttribute("EmitCount"))
			end)
		end

		DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
		local _ = data.StartCFrame
		local clone_2 = V.Phase3.PortalImpact:Clone()
		clone_2.Parent = folder
		local count = 0

		for _ = 1, 3 do
			for _ = 1, 5 do
				task.spawn(function()
					count += 1
					local v2 = data.BuildingData[count]

					if v2 then
						CreateBuilding(
							v2.CubeCFrame,
							folder,
							v2.Multiplier,
							v2.Proxy,
							root.Parent == game.Players.LocalPlayer.Character
						)
					else
						warn("Creation: Building is missing from Data")
					end
				end)
			end

			task.wait(0.05)
		end
	end
end