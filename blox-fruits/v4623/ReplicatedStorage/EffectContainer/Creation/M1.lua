local createVector = vector.create
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local TweenService = game:GetService("TweenService")
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local M1 = FX:WaitForChild("Creation").M1
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local CustomCollisions = require(game.ReplicatedStorage:WaitForChild("CustomCollisions"))
local rocks = CustomCollisions.new("Rocks")

-- equivalent calls inferred from this helper; original call sites unknown
local function DeleteImpactAfterDuration(folder)
	task.spawn(function()
		local v = 0

		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				v = math.max(v, emitter.Lifetime.Max)
			end
		end

		task.wait(v)
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
	local v = p3 + vectorToWorldSpace * (p.Size / 2).X
	p.CFrame = CFrame.new(v, v + vectorToWorldSpace)
end

local function SurfaceHit(cFrame, folder, _)
	local clone = M1.Phase2.ObjectHitImpact:Clone()
	clone.CFrame = cFrame * CFrame.new(0, 0, 1.5) * CFrame.Angles(0, 3.141592653589793, 0)
	clone.Parent = folder

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
end

return function(player)
	local origin = player.Origin

	if (currentCamera.CFrame.p - origin).Magnitude > 1200 then
		return
	end

	local stage = player.Stage

	if stage ~= 1 then
		return
	end

	local proxy = player.Proxy
	local holding = player.Holding

	if not (holding and proxy and player.MousePos) then
		return
	end

	local startCFrame = player.StartCFrame
	local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local _ = player.Character == game.Players.LocalPlayer.Character
	local folder = Instance.new("Folder")
	folder.Name = player.Character.Name
	folder.Parent = _WorldOrigin
	local clone = M1.Phase1.HitBox:Clone()
	clone.Transparency = 1
	clone.CFrame = startCFrame
	clone.Size = createVector(30, 35, 5)
	clone.Parent = folder
	local card = M1.Phase1.Card
	local model = Instance.new("Model")
	model.Parent = folder
	local v = -(card.Size.Y * 5 / 2)
	local cframe = CFrame.new(0, card.Size.Y * 5 / 4, 0)
	Util.Sound:Play("CreationFruit_M1_CardCreation_03", clone)
	local v2 = {
		"rbxassetid://72244757208266",
		"rbxassetid://116409316223782",
		"rbxassetid://129032891890862",
		"rbxassetid://120687956915574"
	}
	local v3 = nil
	local v4 = false

	for i = 1, 5 do
		local v5 = -(card.Size.X * 8 / 2)
		v += card.Size.X

		for i2 = 1, 7 do
			v5 += card.Size.X

			if not (i ~= 1 and i ~= 5 or i2 ~= 1 and i2 ~= 7) then
				continue
			end

			local clone2 = card:Clone()
			clone2.CFrame = clone.CFrame * CFrame.new(v5 * 1.5, v * 2, 0) * cframe

			if i2 ~= 1 and i2 ~= 7 then
				if i2 % 2 == 0 then
					clone2.CFrame *= CFrame.new(0, 2, 0)
				else
					clone2.CFrame *= CFrame.new(0, -2, 0)
				end
			end

			local texture = v2[math.random(1, 4)]

			for _, decal in pairs(clone2:GetDescendants()) do
				if decal:IsA("Decal") then
					decal.Texture = texture
				end
			end

			local v9 = math.random(0, 15) / 100
			task.spawn(function()
				local selectionBox = clone2.SelectionBox
				selectionBox.LineThickness = 1
				selectionBox.Color3 = Color3.fromRGB(
					math.random(450, 600),
					math.random(150, 200),
					math.random(350, 430)
				)
				local objectSpace = clone2.CFrame:ToObjectSpace(clone.CFrame)
				clone2:SetAttribute("startPoint", objectSpace)
				task.wait(v9)
				local tween = TweenService:Create(clone2, TweenInfo.new(0.15), {
					CFrame = clone.CFrame:ToWorldSpace(objectSpace),
					Size = clone2.Size
				})
				clone2.CFrame *= CFrame.new(math.random(-5, 5) * 5, math.random(-5, 5) * 3, math.random(-5, 5))
				clone2.CFrame *= CFrame.Angles(
					math.rad(math.random(-5, 5) * 10),
					math.rad(math.random(-5, 5) * 10),
					(math.rad(math.random(-5, 5) * 10))
				)
				clone2.Size = Vector3.new(math.random(0, 5), math.random(0, 5), math.random(0, 1))
				clone2.Parent = model
				tween:Play()
				TweenService:Create(selectionBox, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
					LineThickness = 0.1
				}):Play()
			end)
			local v10 = i2
			local v11 = clone2
			task.spawn(function()
				local v12 = 1

				if v10 == 1 or v10 == 7 then
					task.wait(0.3)
					v12 = 1.5
				elseif v10 == 2 or v10 == 6 then
					task.wait(0.225)
					v12 = 1.25
				elseif v10 == 3 or v10 == 5 then
					task.wait(0.15)
				end

				repeat
					task.wait()
				until v3 == true

				v11:SetAttribute("Tweening", false)
				v11.AnchorPart.CFrame = v11.CFrame
				v11.Anchored = false
				v11.CanCollide = false
				v11.CanQuery = false
				v11.CanTouch = false
				v11.Weld.Enabled = true
				v11:SetAttribute("verticalOffset", 0)
				local numberValue = Instance.new("NumberValue")
				numberValue.Value = v11:GetAttribute("verticalOffset")
				numberValue.Changed:Connect(function()
					v11:SetAttribute("verticalOffset", numberValue.Value)
				end)
				local v13 = 1

				repeat
					v13 *= -1
					local tween = TweenService:Create(numberValue, TweenInfo.new(v12, Enum.EasingStyle.Linear), {
						Value = v13 * 1.5
					})
					tween:Play()
					tween.Completed:Wait()
					task.wait()
				until v4 == true

				numberValue:Destroy()
			end)
		end
	end

	local clone2 = M1.Phase1.WallAura:Clone()
	clone2.CFrame = clone.CFrame
	clone2.Size = clone.Size
	clone2.Parent = folder
	clone2.Anchored = false
	clone2.WeldConstraint.Part1 = clone
	clone2.Massless = true

	for _, emitter in pairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	local clone3 = M1.Phase2.HitImpact:Clone()
	clone3.Parent = folder
	model:SetAttribute("Hit", false)

	local function CardHit(part)
		clone3.CFrame = part.CFrame
		local _ = part.Position
		local cFrame = clone2.CFrame

		-- equivalent calls inferred from this helper; original call sites unknown
		local function ProjectToPlane2D(position, cFrame2)
			local _ = cFrame2.UpVector
			local pointToObjectSpace = cFrame2:PointToObjectSpace(position)
			local pointToWorldSpace = cFrame2:PointToWorldSpace((Vector3.new(
				pointToObjectSpace.X,
				pointToObjectSpace.Y,
				0
			)))
			return CFrame.lookAt(pointToWorldSpace, pointToWorldSpace + cFrame2.LookVector)
		end

		local cFrame3 = ProjectToPlane2D(part.Position, cFrame) -- equivalent call inferred; original call site unknown
		local v6 = cFrame3 * createVector(0, 0, -3)
		clone3.CFrame = cFrame3

		for _, emitter in pairs(clone3:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		SurfaceHit(clone3.CFrame, folder)
		Util.Sound:Play(
			"CreationFruit_V2_M1_CardHitNPC_BassyExplosion_0" .. tostring(math.random(1, 12)),
			clone3.Position
		)
		task.spawn(function()
			for _ = 1, 5 do
				local clone4 = M1.Phase2.HitCard:Clone()
				clone4.CFrame = cFrame3 * CFrame.Angles(
					math.rad((math.random(-70, 0))),
					math.rad((math.random(-50, 50))),
					0
				)
				local texture = v2[math.random(1, 4)]

				for _, decal in pairs(clone4:GetDescendants()) do
					if decal:IsA("Decal") then
						decal.Texture = texture
					end
				end

				clone4.Parent = folder
				clone4.CanCollide = true
				clone4.Anchored = false
				clone4.Velocity = clone4.CFrame.LookVector * -math.random(100, 150) / 2
				rocks:ApplyCollision(clone4, nil, true)
				task.delay(1.5, function()
					local tween = TweenService:Create(clone4, TweenInfo.new(0.225), {
						Size = createVector(0, 0, 0),
						Orientation = Vector3.new(math.random(-50, 50), math.random(-50, 50), math.random(-50, 50))
					})
					tween:Play()
					tween.Completed:Wait()
					clone4.DecalF.Transparency = 1
					clone4.DecalB.Transparency = 1
					clone4.SelectionBox.Transparency = 1
				end)
			end
		end)

		if model:GetAttribute("Hit") == false then
			model:SetAttribute("Hit", true)
			task.delay(0.5, function()
				model:SetAttribute("Hit", false)
			end)

			for _, part2 in pairs(model:GetChildren()) do
				if not part2:IsA("BasePart") then
					continue
				end

				local v7 = part2
				task.spawn(function()
					local lerped = v7.CFrame:Lerp(
						CFrame.new(v7.Position, v6) * CFrame.new(math.random(-5, 5) / 3, math.random(-5, 5) / 3, 5),
						0.9
					)
					local v8 = math.acos((v7.CFrame.LookVector:Dot((v6 - v7.Position).Unit)))
					local v9 = v8 < 1.5707963267948966
					local v10 = v8 < 1.9039955476301778

					if not v9 then
						lerped = v7.CFrame:Lerp(
							CFrame.new(v7.Position, v6) * CFrame.Angles(0, 3.141592653589793, 0) * CFrame.new(0, 0, -5),
							1
						)
					end

					if (v7.Position - v6).Magnitude <= 15 and v7:GetAttribute("Tweening") == false then
						task.spawn(function()
							v7:SetAttribute("Tweening", true)
							v7.Weld.Enabled = false
							v7.Anchored = true
							local tween = TweenService:Create(
								v7,
								TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true),
								{
									Size = v7.Size * 1.5,
									CFrame = lerped
								}
							)
							tween:Play()
							tween.Completed:Wait()

							if v4 == false then
								v7.Anchored = false
								v7.Weld.Enabled = true
								v7:SetAttribute("Tweening", false)
							end
						end)
					end
				end)
			end
		end
	end

	local childAddedConnection = proxy.ChildAdded:Connect(function(part)
		if part:IsA("BasePart") then
			CardHit(part)
		end
	end)
	task.wait(0.3)
	local clone4 = M1.Phase1.HoldAura:Clone()
	clone4.CFrame = humanoidRootPart.CFrame
	clone4.Parent = folder
	clone4.Weld.Part1 = humanoidRootPart
	clone4.Anchored = false
	clone4.Massless = true

	for _, emitter in pairs(clone4:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter:Emit(1)
		emitter.Enabled = true
	end

	v3 = true
	Util.Sound:Play("CreationFruit_M1_CardWhoosh_Release_03", startCFrame.Position)
	local v5 = Util.Sound:Play("CreationFruit_M1_CardIdle_Particles_01", clone)
	TweenService:Create(v5, TweenInfo.new(1), {
		Volume = 0.7
	}):Play()
	local v6 = clone.Size.Y / 2 - 4
	local rootHeight = player.RootHeight
	local v7 = tick() + 0.25
	local value = nil

	while true do
		local v8 = task.wait()

		if not proxy:IsDescendantOf(workspace) or tick() - v7 > 0 and not (holding and holding.Value) then
			break
		end

		if v4 then
			continue
		end

		if value == nil or holding and holding.Value then
			if typeof(player.MousePos) == "Instance" and player.MousePos:IsA("Vector3Value") then
				value = player.MousePos.Value
			else
				value = player.MousePos.Hit.p
			end
		end

		local v9 = CFrame.lookAt(humanoidRootPart.Position, value + Vector3.new(0, rootHeight, 0)) * CFrame.new(
			0,
			15,
			-math.min(70, (value - humanoidRootPart.Position).Magnitude)
		)
		local _, v10 = Util.Ray(
			humanoidRootPart.Position,
			v9.LookVector * math.min(70, (value - humanoidRootPart.Position).Magnitude),
			{ workspace.Characters, workspace.Enemies }
		)
		local _, v11 = Util.Ray(v10, createVector(0, 1, 0) * -v6, { workspace.Characters, workspace.Enemies })
		local v12 = v10 + Vector3.new(
			0,
			(5 + v6 - math.abs(v11.Y - v10.Y)) * (1 - math.abs(humanoidRootPart.CFrame.LookVector.Y)),
			0
		)
		local v13 = CFrame.lookAt(createVector(0, 0, 0), v9.LookVector) + v12
		clone.CFrame = clone.CFrame:Lerp(v13, v8 * 10)

		for _, part in pairs(model:GetChildren()) do
			if not part:IsA("BasePart") then
				continue
			end

			local v14 = part
			task.spawn(function()
				v14:SetAttribute("AnchorPartMoving", false)
				local startPoint = v14:GetAttribute("startPoint")
				v14.CFrame = clone.CFrame:ToWorldSpace(startPoint) * CFrame.new(
					0,
					v14:GetAttribute("verticalOffset") or 0,
					0
				)
			end)
		end
	end

	if v5 then
		Util.Sound:FadeOut(v5, 0.2)
	end

	for _, emitter in pairs(clone4:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	task.spawn(function()
		v4 = true
		Util.Sound:Play("CreationFruit_V2_M1_CardsDropRelease_04", clone.Position)

		if childAddedConnection then
			childAddedConnection:Disconnect()
		end

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		for _, part in pairs(model:GetChildren()) do
			if not part:IsA("BasePart") then
				continue
			end

			local v8 = part
			task.spawn(function()
				v8.Weld.Enabled = false
				v8.CanCollide = true
				v8.Anchored = false
				rocks:ApplyCollision(v8, nil, true)
				TweenService:Create(v8, TweenInfo.new(0.15), {
					Position = v8.Position + Vector3.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5)),
					Orientation = Vector3.new(math.random(-50, 50), math.random(-50, 50), math.random(-50, 50))
				}):Play()
				task.wait(1.5)
				task.wait(0.5 * math.random())
				Util.Sound:Play(
					"CreationFruit_V2_M1_CardsDisappear_0" .. tostring(math.random(1, 9)),
					v8.Position,
					nil,
					math.random(15, 20) / 10
				)
				local tween = TweenService:Create(v8, TweenInfo.new(0.225), {
					Size = createVector(0, 0, 0),
					Orientation = Vector3.new(math.random(-50, 50), math.random(-50, 50), math.random(-50, 50))
				})
				tween:Play()
				tween.Completed:Wait()
				v8.DecalF.Transparency = 1
				v8.DecalB.Transparency = 1
				v8.SelectionBox.Transparency = 1
			end)
		end

		task.wait(3)
		folder:Destroy()
	end)
end