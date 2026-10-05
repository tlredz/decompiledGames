local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
require(ReplicatedStorage:WaitForChild("Effect"))
local currentCamera = workspace.CurrentCamera
local Util = require(ReplicatedStorage.Util)
local WrapColor3Constructor = require(ReplicatedStorage.Util.WrapColor3Constructor)
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local z_Attract = FX:WaitForChild("Magnet"):WaitForChild("Z_Attract")
local scraps = FX:WaitForChild("Magnet"):WaitForChild("Scraps")
local CustomCollisions = require(ReplicatedStorage:WaitForChild("CustomCollisions"))
local rocks = CustomCollisions.new("Rocks")
pcall(function()
	for _, child in scraps:FindFirstChild("ScrapModelA"):GetChildren() do
		rocks:ApplyCollision(child, nil, true)
	end

	for _, child in scraps:FindFirstChild("ScrapModelA2"):GetChildren() do
		rocks:ApplyCollision(child, nil, true)
	end

	for _, child in scraps:FindFirstChild("ScrapModelA3"):GetChildren() do
		rocks:ApplyCollision(child, nil, true)
	end

	for _, child in scraps:FindFirstChild("ArcsteelScrapModelA"):GetChildren() do
		rocks:ApplyCollision(child, nil, true)
	end

	for _, child in scraps:FindFirstChild("ArcsteelScrapModelB"):GetChildren() do
		rocks:ApplyCollision(child, nil, true)
	end
end)
local _WorldOrigin = workspace._WorldOrigin

local function GetMagnetColorOwner(data)
	local player = data.Player or data.player

	if typeof(player) == "Instance" and player.Parent then
		return player
	end

	local root = data.Root or data.hrp
	local parent = root and root.Parent

	if parent and parent:IsA("Model") then
		local playerFromCharacter = Players:GetPlayerFromCharacter(parent)

		if playerFromCharacter and playerFromCharacter.Parent then
			return playerFromCharacter
		end
	end

	return nil
end

local function RecolorMagnetColor(instance, p)
	if typeof(instance) == "Instance" and instance.Parent then
		return WrapColor3Constructor(p, instance, "MagnetFruitVFXColor")
	end

	return p
end

-- equivalent calls inferred from this helper; original call sites unknown
local function SetParentWithMagnetColor(clone, parent, p)
	if p then
		Util.SetParentOverrideWithColor(clone, parent, p, "MagnetFruitVFXColor")
	else
		clone.Parent = parent
	end
end

local function hasCrimsonGoldSkin(player)
	if typeof(player) ~= "Instance" then
		return false
	end

	local magnetFruitVFXColor = player:FindFirstChild("MagnetFruitVFXColor")

	if magnetFruitVFXColor and magnetFruitVFXColor:GetAttribute("SkinStorageKey") == "MAGNETSKINarksteel" then
		return true
	end

	local character = player.Character
	local primaryPart = character and character.PrimaryPart

	if primaryPart and primaryPart:GetAttribute("MagnetSkin") == "MAGNETSKINarksteel" then
		return true
	end

	return false
end

local v = {
	ScrapModelA = "ArcsteelScrapModelA",
	ScrapModelA2 = "ArcsteelScrapModelB"
}

local function resolveScrap(childName: string, flag: boolean)
	if not flag then
		return scraps:FindFirstChild(childName)
	end

	local v2 = v[childName]
	local child = v2 and scraps:FindFirstChild(v2)

	if child then
		return child
	end

	return scraps:FindFirstChild(childName)
end

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

-- equivalent calls inferred from this helper; original call sites unknown
local function QuadBezier(position, p, p2, p3)
	return position:Lerp(p, p3):Lerp(p:Lerp(p2, p3), p3)
end

local function EndOrbit(folder, position)
	for _, effect in pairs(folder:GetDescendants()) do
		if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
			effect.Enabled = false
		end
	end

	folder.Anchored = false
	folder.CanCollide = true
	local unit = (folder.Position - position).Unit
	local vector2 = Vector3.new(math.random(-30, 30), math.random(15, 40), math.random(-30, 30))
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = createVector(100000, 100000, 100000)
	bodyVelocity.Velocity = unit * math.random(30, 50) + vector2
	bodyVelocity.Parent = folder
	local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
	bodyAngularVelocity.MaxTorque = createVector(100000, 100000, 100000)
	bodyAngularVelocity.AngularVelocity = Vector3.new(math.random(-15, 15), math.random(-15, 15), math.random(-15, 15))
	bodyAngularVelocity.Parent = folder
	task.delay(0.25, function()
		if bodyVelocity then
			bodyVelocity:Destroy()
		end

		if bodyAngularVelocity then
			bodyAngularVelocity:Destroy()
		end

		if folder:FindFirstChild("Highlight") then
			folder.Highlight.Enabled = false
		end

		task.wait(1 + math.random() * 0.5)
		TweenService:Create(folder, TweenInfo.new(0.25), {
			Size = createVector(0, 0, 0)
		}):Play()
	end)
end

local function StartOrbit(parent, position, p2, p3, p4)
	local unit = Vector3.new(math.random(-100, 100), math.random(-100, 100), math.random(-100, 100)).Unit
	local v2 = math.random() * 3.141592653589793 * 2
	local v3 = p3 * (math.random(80, 140) / 100)

	if math.random() < 0.5 then
		v3 = -v3
	end

	local cross = unit:Cross(createVector(0, 1, 0))

	if cross.Magnitude < 0.1 then
		cross = unit:Cross(createVector(1, 0, 0))
	end

	local unit2 = cross.Unit
	local v4 = p2
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		if not (parent and parent.Parent) then
			heartbeatConnection:Disconnect()
			return
		end

		v2 += v3 * dt
		local model = p4 and p4.Model

		if model then
			if (model:GetAttribute("CurrTime") or 0) - tick() <= 0 then
				heartbeatConnection:Disconnect()
				EndOrbit(parent, position)
				return
			else
				position = model.PrimaryPart.Position
			end
		end

		local v6 = p2 * (not model and 1 or model:GetScale() or 1)
		v4 += (v6 - v4) * math.clamp(dt * 6, 0, 1)
		local vectorToWorldSpace = CFrame.fromAxisAngle(unit, v2):VectorToWorldSpace(unit2 * v4)
		local v7 = position + vectorToWorldSpace
		parent.CFrame = CFrame.new(v7, position)
	end)
end

local lightningBoltShafi = Util.LightningBoltShafi

local function ShafiBolt(...)
	local v2 = lightningBoltShafi.new(...)
	local curveSize = -math.random(5, 25)
	local curveSize2 = math.random(5, 25)
	v2.CurveSize0 = curveSize
	v2.CurveSize1 = curveSize2
	v2.MinRadius = 3
	v2.MaxRadius = 13
	v2.Frequency = 0.5
	v2.AnimationSpeed = 8
	local maxThicknessMultiplier = math.random(3, 4)
	v2.MinThicknessMultiplier = 0.2
	v2.MaxThicknessMultiplier = maxThicknessMultiplier
	v2.MinTransparency = 0
	v2.MaxTransparency = 1
	v2.PulseSpeed = 10
	v2.PulseLength = 1000000
	v2.FadeLength = 0.2
	v2.ContractFrom = 0.5
	v2.Color = Color3.new(1, 0.380392, 0.380392)
	v2.ColorOffsetSpeed = 3
	return v2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function FlyCurve(clone, cFrame, cFrame2, vector2, p, p2)
	local position = cFrame.Position
	local position2 = cFrame2.Position
	local v2 = (position + position2) / 2 + vector2
	local lastTime = os.clock()
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		local v3 = (os.clock() - lastTime) / p

		if v3 >= 1 then
			clone.CFrame = cFrame2
			StartOrbit(clone, position2, math.random(12, 15) * 1.5, math.random(7, 9), p2)
			heartbeatConnection:Disconnect()
		else
			local quadBezier = QuadBezier(position, v2, position2, v3) -- equivalent call inferred; original call site unknown
			clone.CFrame = CFrame.new(quadBezier)
		end
	end)
end

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

function cubicBezier(p, p2, p3, p4, p5)
	local v2 = p2 + (p3 - p2) * p
	local v3 = p3 + (p4 - p3) * p
	local v4 = p4 + (p5 - p4) * p
	local v5 = v2 + (v3 - v2) * p
	return v5 + (v3 + (v4 - v3) * p - v5) * p
end

local function TrailCurve(clone, cFrame, position, position2, cframe, cframe2, p)
	local magnitude = (position - position2).Magnitude
	local v2 = (position - position2) / 2
	local position3 = CFrame.new(CFrame.new(position) * (v2 / -1.5)).Position
	local position4 = CFrame.new(CFrame.new(position2) * (v2 / 1.5)).Position
	math.random(20, 30)
	local v3 = CFrame.new(position3, position3 + cFrame.LookVector) * cframe.Position
	local v4 = CFrame.new(position4, position4 + cFrame.LookVector) * cframe2.Position
	local lastTime = tick()
	local v5 = magnitude / p / 60
	local _ = (magnitude / p + p) / 60

	while tick() - lastTime < v5 do
		local v6 = (tick() - lastTime) / v5
		local v7 = cubicBezier(v6, position, v3, v4, position2)
		clone.CFrame = CFrame.new(clone.CFrame:Lerp(CFrame.new(v7, position2), v6).Position)
		RunService.Heartbeat:Wait()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getArmAnim(parent, p: string, p2: string)
	local magnetArms = parent:FindFirstChild("MagnetArms")

	if not magnetArms then
		warn("Magnet Arms Folder missing!")
		return
	end

	local child = magnetArms:FindFirstChild("Floating" .. p2 .. "Arm")
	local v2 = child and Util.Anims:Get(child, p)
	return v2 or nil
end

return function(data)
	local origin = data.Origin or data.Root and data.Root.Position or data.hrp and data.hrp.Position or data.Player and data.Player.Character.PrimaryPart.Position
	assert(origin, "Origin Vector3 missing in: ", script:GetFullName())

	if (currentCamera.CFrame.Position - origin).Magnitude > 1200 then
		return
	end

	local stage = data.Stage

	if stage == 1 then
		local holding = data.Holding

		if not (holding and holding.Value) then
			return
		end

		local root = data.Root
		local magnetArms = root.Parent:FindFirstChild("MagnetArms")
		local v2

		if magnetArms then
			local floatingLeftArm = magnetArms:FindFirstChild("FloatingLeftArm")
			v2 = floatingLeftArm and Util.Anims:Get(floatingLeftArm, "Untr_ Z Tap Held L") or nil
		else
			warn("Magnet Arms Folder missing!")
		end

		local magnetArms2 = root.Parent:FindFirstChild("MagnetArms")
		local v3

		if magnetArms2 then
			local floatingRightArm = magnetArms2:FindFirstChild("FloatingRightArm")
			v3 = floatingRightArm and Util.Anims:Get(floatingRightArm, "Untr_ Z Tap Held R") or nil
		else
			warn("Magnet Arms Folder missing!")
		end

		local magnetArms3 = root.Parent:FindFirstChild("MagnetArms")
		local v4

		if magnetArms3 then
			local floatingRightArm = magnetArms3:FindFirstChild("FloatingRightArm")
			v4 = floatingRightArm and Util.Anims:Get(floatingRightArm, "Untr_ Z Tap Start R") or nil
		else
			warn("Magnet Arms Folder missing!")
		end

		if v4 then
			v4.Priority = Enum.AnimationPriority.Action2
			v4.Looped = false
			v4:Play()
		end

		local magnetArms4 = root.Parent:FindFirstChild("MagnetArms")
		local v5

		if magnetArms4 then
			local floatingLeftArm = magnetArms4:FindFirstChild("FloatingLeftArm")
			v5 = floatingLeftArm and Util.Anims:Get(floatingLeftArm, "Untr_ Z Tap Start L") or nil
		else
			warn("Magnet Arms Folder missing!")
		end

		if v5 then
			v5.Priority = Enum.AnimationPriority.Action2
			v5.Looped = false
			v5:Play()
		end

		Util.Sound:Play("Magnet_Untransformed_Z_Gun_Mechanics_Activate_01", root.Position)

		if v2 and v3 then
			v2.Looped = true
			v3.Looped = true
			v2:Play()
			v3:Play()
		end

		repeat
			task.wait()
		until not (holding and holding.Value)

		if v2 and v3 then
			task.wait(0.05)
			v2:Stop()
			v3:Stop()
		end
	elseif stage == 2 then
		local folder = Instance.new("Folder")
		folder.Parent = _WorldOrigin
		Util.Debris:AddItem(folder, 5)
		local root = data.Root
		local magnetColorOwner = GetMagnetColorOwner(data)
		local startCFrame = data.StartCFrame
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.IgnoreWater = false
		raycastParams.FilterDescendantsInstances = { _WorldOrigin, workspace.Characters, workspace.Enemies }
		local v3 = {}

		local function MakeBullet(p, i)
			local v4 = {
				Model = nil
			}
			local v5 = startCFrame[i]
			local value = data.MousePos.Value
			local cFrame = CFrame.new(v5.Position, value) * CFrame.new(0, 0, -3)

			local function getTravelTime(p2)
				return p2 / 333.33333333333337
			end

			local _, v7, _ = Util.Ray(
				cFrame.Position,
				cFrame.LookVector * 200,
				{ workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
			)
			local magnitude = (v7 - cFrame.Position).Magnitude
			local v8 = magnitude / 333.33333333333337
			local scrapModelA

			if hasCrimsonGoldSkin(magnetColorOwner) then
				local scrapModelA2 = v.ScrapModelA
				scrapModelA = scrapModelA2 and scraps:FindFirstChild(scrapModelA2)

				if not scrapModelA then
					scrapModelA = scraps:FindFirstChild("ScrapModelA")
				end
			else
				scrapModelA = scraps:FindFirstChild("ScrapModelA")
			end

			scrapModelA:ScaleTo(2.5)
			local children = scrapModelA:GetChildren()
			local clonesByClone = {}

			for _ = 1, p do
				local clone = children[math.random(1, #children)]:Clone()
				clone.CFrame = cFrame * CFrame.new(math.random(-3, 3), math.random(-3, 3), math.random(-3, 3))
				SetParentWithMagnetColor(clone, folder, magnetColorOwner) -- equivalent call inferred; original call site unknown
				clonesByClone[clone] = clone
				local clone2 = z_Attract.Phase1.Highlight:Clone()
				SetParentWithMagnetColor(clone2, clone, magnetColorOwner) -- equivalent call inferred; original call site unknown
				clone2.Enabled = true
				local clone3 = children[math.random(1, #children)]:Clone()
				clone3.Size *= 0.7
				SetParentWithMagnetColor(clone3, folder, magnetColorOwner) -- equivalent call inferred; original call site unknown
				local clone4 = z_Attract.Phase1.Highlight:Clone()
				SetParentWithMagnetColor(clone4, clone3, magnetColorOwner) -- equivalent call inferred; original call site unknown
				clone4.Enabled = true
				local clone5 = z_Attract.Phase1.AuraModel:Clone()
				clone5.PrimaryPart.Anchored = false
				clone5.PrimaryPart.Weld.Part1 = clone3
				SetParentWithMagnetColor(clone5, clone3, magnetColorOwner) -- equivalent call inferred; original call site unknown
				local vector2 = Vector3.new(math.random(-6, 6), math.random(-3, 5), math.random(-6, 6))
				clone3.CFrame = cFrame * CFrame.new(vector2)
				local v16 = magnitude + math.random(-6, 6)
				local cFrame2 = cFrame * CFrame.new(vector2) * CFrame.new(0, 0, -v16)
				local vector3 = Vector3.new(math.random(-15, 15), math.random(-10, 15), math.random(-15, 15))
				FlyCurve(clone3, clone3.CFrame, cFrame2, vector3, v8 + math.random() * 0.15, v4) -- equivalent call inferred; original call site unknown
			end

			local time = v8

			for _, v9 in pairs(clonesByClone) do
				local v10 = magnitude + math.random(-5, 5)
				local tweenInfo = TweenInfo.new(
					v8 + math.random() * 0.15,
					Enum.EasingStyle.Linear,
					Enum.EasingDirection.Out
				)
				local cFrame2 = v9.CFrame * CFrame.new(0, 0, -v10) * CFrame.Angles(
					math.rad((math.random(-180, 180))),
					math.rad((math.random(-180, 180))),
					(math.rad((math.random(-180, 180))))
				)
				TweenService:Create(v9, tweenInfo, {
					CFrame = cFrame2
				}):Play()
				local parent = v9
				task.delay(tweenInfo.Time, function()
					StartOrbit(parent, cFrame2.Position, math.random(12, 15) * 1.25, math.random(7, 9), v4)
				end)

				if time < tweenInfo.Time then
					time = tweenInfo.Time
				end
			end

			local clone = z_Attract.Phase1.MainProjectile:Clone()
			clone:PivotTo(cFrame)
			SetParentWithMagnetColor(clone, folder, magnetColorOwner) -- equivalent call inferred; original call site unknown

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			local tweenInfo = TweenInfo.new(v8 + 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
			local tween = TweenService:Create(clone.PrimaryPart, tweenInfo, {
				CFrame = clone.PrimaryPart.CFrame * CFrame.new(0, 0, -magnitude)
			})
			tween:Play()
			local clone2 = z_Attract.Phase1.StartImpact:Clone()
			clone2.CFrame = cFrame
			SetParentWithMagnetColor(clone2, folder, magnetColorOwner) -- equivalent call inferred; original call site unknown
			DeleteImpactAfterDuration(clone2) -- equivalent call inferred; original call site unknown

			for _, emitter in pairs(clone2:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v13 = emitter
				task.spawn(function()
					if v13:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v13:GetAttribute("EmitDelay"))
					end

					v13:Emit(v13:GetAttribute("EmitCount"))
				end)
			end

			local v13 = false
			task.spawn(function()
				task.wait(0.1)

				local function AlignCFrame(data2, normal)
					local v14 = not (normal and normal.Magnitude > 0 and normal) and createVector(0, 1, 0) or normal
					local p2 = data2.p
					local unit = data2.LookVector:Cross(v14).Unit
					local unit2 = (unit.Magnitude > 0.001 and unit or data2.RightVector).Unit
					local unit3 = unit2:Cross(v14).Unit
					return CFrame.fromMatrix(p2, unit2, v14, unit3)
				end

				local clone3 = z_Attract.Phase1.GroundBurn:Clone()
				clone3.CFrame = cFrame
				SetParentWithMagnetColor(clone3, folder, magnetColorOwner) -- equivalent call inferred; original call site unknown

				for _, emitter in pairs(clone3:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				local emitters = {}
				local v16 = false

				for _, emitter in pairs(clone3:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						table.insert(emitters, emitter)
					end
				end

				tick()
				local total = 0.5

				while true do
					local v17 = clone.PrimaryPart.CFrame * CFrame.new(0, 5, 0)
					local raycastResult = workspace:Raycast(
						v17.Position,
						CFrame.new(v17.Position).UpVector * -25,
						raycastParams
					)

					if raycastResult then
						clone3.CFrame = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.01
						clone3.CFrame = CFrame.new(clone3.Position, clone3.Position + cFrame.LookVector)
						clone3.Orientation = Vector3.new(0, clone3.Orientation.Y, clone3.Orientation.Z)

						if v16 == false then
							v16 = true

							for _, v18 in pairs(emitters) do
								v18.Enabled = true
							end
						end
					elseif v16 == true then
						v16 = false

						for _, v18 in pairs(emitters) do
							v18.Enabled = false
						end
					end

					total += 0.1
					task.wait(0.1)

					if v13 ~= true then
						continue
					end

					for _, emitter in pairs(clone3:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end

					break
				end
			end)
			local v14 = cFrame * CFrame.new(0, 0, -magnitude)
			local child = data.Proxies and data.Proxies:FindFirstChild((tostring(i)))
			local flag = false

			local function Explode(p2)
				if flag then
					return
				end

				flag = true
				v13 = true
				local cframe = v14

				if p2 then
					cframe = CFrame.new(p2.Position, p2.Position + cFrame.LookVector)

					if tween then
						tween:Cancel()
					end

					if clone and clone.PrimaryPart then
						clone:PivotTo(cframe)
					end
				end

				local clone3 = z_Attract.Phase2.Explosion:Clone()
				clone3.CFrame = cframe
				SetParentWithMagnetColor(clone3, folder, magnetColorOwner) -- equivalent call inferred; original call site unknown
				DeleteImpactAfterDuration(clone3) -- equivalent call inferred; original call site unknown

				for _, emitter in pairs(clone3:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local v17 = emitter
					task.spawn(function()
						if v17:GetAttribute("EmitDelay") ~= 0 then
							task.wait(v17:GetAttribute("EmitDelay"))
						end

						v17:Emit(v17:GetAttribute("EmitCount") / 2)
					end)
				end

				for _, effect in pairs(clone:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = false
					end
				end

				if i ~= 1 and next(v3) then
					local v17 = 1e999
					local v18 = nil

					for k, v19 in pairs(v3) do
						if not (k ~= i and v19 and v19.endCF) then
							continue
						end

						local magnitude2 = (v19.endCF.Position - cframe.Position).Magnitude

						if not (magnitude2 < v17) then
							continue
						end

						v18 = k
						v17 = magnitude2
					end

					if v18 and v17 <= 30 then
						local aura = v3[v18].aura
						aura:ScaleTo(aura:GetScale() + 0.25)
						local ray, v19 = Util.Ray(
							cframe.Position + createVector(0, 1, 0),
							createVector(0, 1, 0) * -aura.PrimaryPart.Size.Y / 2,
							{ workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
						)

						if ray then
							local v20 = v19 + Vector3.new(0, aura.PrimaryPart.Size.Y / 2, 0)
							cframe = CFrame.new(v20, v20 + aura.PrimaryPart.CFrame.LookVector)
							aura:PivotTo(cframe)
						end

						aura:SetAttribute("CurrTime", tick() + 1)
						aura:SetAttribute("Tier", aura:GetAttribute("Tier") + 1)
						local sfx = v3[v18].sfx

						if sfx then
							sfx.RollOffMinDistance += 20
						end

						v3[i] = {
							aura = aura,
							endCF = cframe,
							sfx = sfx
						}
						v4.Model = aura
						return
					end
				end

				local clone4 = z_Attract.Phase3.MagnetAuraModel:Clone()
				local primaryPart = clone4.PrimaryPart
				local ray, v17 = Util.Ray(
					cframe.Position + createVector(0, 1, 0),
					createVector(0, 1, 0) * -primaryPart.Size.Y / 2,
					{ workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
				)

				if ray then
					local v18 = v17 + Vector3.new(0, primaryPart.Size.Y / 2, 0)
					cframe = CFrame.new(v18, v18 + cframe.LookVector)
				end

				primaryPart.CFrame = cframe
				SetParentWithMagnetColor(clone4, folder, magnetColorOwner) -- equivalent call inferred; original call site unknown
				clone4:SetAttribute("CurrTime", tick() + 1)
				clone4:SetAttribute("Tier", 1)
				v4.Model = clone4

				for _, emitter in pairs(primaryPart:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end

				local sfx2 = Util.Sound:Play("Magnet_Untransformed_Z_Projectile_Loop_SmallIndividual_01", primaryPart)
				v3[i] = {
					aura = clone4,
					endCF = cframe,
					sfx = sfx2
				}
				local now = tick()
				local now2 = tick()
				local now3 = tick()

				while true do
					if now - tick() <= 0 then
						now = tick() + 0.1

						for i2 = 1, math.random(1, 3) do
							local v21 = i2
							task.spawn(function()
								local Z = clone4.PrimaryPart.Size.Z
								local clone5 = script.Part:Clone()
								local cFrame2 = CFrame.new(clone4.PrimaryPart.Position) * CFrame.Angles(
									math.random(-180, 180),
									math.rad((math.random(-180, 180))),
									math.random(-180, 180)
								) * CFrame.new(0, 0, -Z)
								clone5.CFrame = cFrame2
								SetParentWithMagnetColor(clone5, folder, magnetColorOwner) -- equivalent call inferred; original call site unknown
								clone5.Attach1.WorldPosition = cFrame2 * CFrame.new(0, 0, Z).Position
								local shafiBolt = ShafiBolt(
									clone5.Attach0,
									clone5.Attach1,
									math.random(8, 12) / 2,
									0.5,
									folder
								)
								shafiBolt.CurveSize0 = math.random(-25, 25)
								shafiBolt.CurveSize1 = math.random(-25, 25)
								shafiBolt.Frequency = math.random(5, 10) * 2
								shafiBolt.MaxRadius = 5
								shafiBolt.AnimationSpeed = math.random(20, 50) / 10
								local v26 = magnetColorOwner
								local color = Color3.fromRGB(26, 60, 255)

								if typeof(v26) == "Instance" and v26.Parent then
									color = WrapColor3Constructor(color, v26, "MagnetFruitVFXColor")
								end

								shafiBolt.Color = color

								if v21 % 2 == 0 then
									local v27 = magnetColorOwner
									local color2 = Color3.fromRGB(48, 79, 255)

									if typeof(v27) == "Instance" and v27.Parent then
										color2 = WrapColor3Constructor(color2, v27, "MagnetFruitVFXColor")
									end

									shafiBolt.Color = color2
									shafiBolt.Thickness = 0.5
								end

								task.spawn(function()
									task.wait(0.1 + math.random() * 0.15)
									shafiBolt:Destroy()
								end)
							end)
						end
					end

					if now2 - tick() <= 0 then
						now2 = tick() + 0.1
					end

					if now3 - tick() <= 0 then
						now3 = tick() + 0.05
						task.spawn(function()
							if clone4:GetAttribute("CurrTime") - tick() <= 0.125 then
								return
							end

							local clone5 = z_Attract.Phase3.Trail:Clone()
							clone5.CFrame = clone4.PrimaryPart.CFrame
							SetParentWithMagnetColor(clone5, folder, magnetColorOwner) -- equivalent call inferred; original call site unknown
							local Z = clone4.PrimaryPart.Size.Z
							clone5.CFrame = clone5.CFrame * CFrame.Angles(
								math.rad((math.random(-180, 180))),
								math.rad((math.random(-180, 180))),
								(math.rad((math.random(-180, 180))))
							) * CFrame.new(0, 0, math.random(Z * 2 - 10, Z * 2) * 0.8)

							for _, effect in pairs(clone5:GetDescendants()) do
								if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
									effect.Enabled = true
								end
							end

							local position = clone5.Position
							local position2 = clone4.PrimaryPart.CFrame.Position
							local cframe2 = CFrame.new(
								math.random(-50, 50) / 2,
								math.random(-50, 50) / 2,
								math.random(-50, 50) / 2
							)
							local cframe3 = CFrame.new(
								math.random(-50, 50) / 2,
								math.random(-50, 50) / 2,
								math.random(-50, 50) / 2
							)
							local v23 = math.random(35, 40) / 12
							TrailCurve(
								clone5,
								clone4.PrimaryPart.CFrame,
								position,
								position2,
								cframe2,
								cframe3,
								v23,
								true
							)

							for _, effect in pairs(clone5:GetDescendants()) do
								if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
									effect.Enabled = false
								end
							end
						end)
					end

					task.wait()

					if not (clone4:GetAttribute("CurrTime") - tick() <= 0) then
						continue
					end

					for _, emitter in pairs(primaryPart:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end

					if sfx2 then
						Util.Sound:FadeOut(sfx2, 0.2)
					end

					local clone5 = z_Attract.Phase3.ExplosionFinalModel:Clone()
					clone5:ScaleTo(clone4:GetScale() - 0.1)
					local primaryPart2 = clone5.PrimaryPart
					primaryPart2.CFrame = cframe
					SetParentWithMagnetColor(clone5, folder, magnetColorOwner) -- equivalent call inferred; original call site unknown
					local tier = clone4:GetAttribute("Tier")

					if tier <= 2 then
						Util.Sound:Play(
							"Magnet_Untransformed_Z_Projectile_Explode_Small_0" .. tostring(math.random(1, 3)),
							primaryPart
						)

						if (workspace.CurrentCamera.CFrame.p - cframe.Position).Magnitude < 50 then
							Util.CameraShaker:ShakeOnce(6, 4, 0.2, 0.6)
						end
					elseif tier <= 3 then
						Util.Sound:Play("Magnet_Untransformed_Z_Projectile_Explode_Medium_02", primaryPart)

						if (workspace.CurrentCamera.CFrame.p - cframe.Position).Magnitude < 75 then
							Util.CameraShaker:ShakeOnce(8, 6, 0.2, 0.6)
						end
					else
						Util.Sound:Play("Magnet_Untransformed_Z_Projectile_Explode_Large_01", primaryPart)

						if (workspace.CurrentCamera.CFrame.p - cframe.Position).Magnitude < 100 then
							Util.CameraShaker:ShakeOnce(10, 8, 0.2, 0.6)
						end
					end

					DeleteImpactAfterDuration(primaryPart2) -- equivalent call inferred; original call site unknown

					for _, emitter in pairs(primaryPart2:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						local v23 = emitter
						task.spawn(function()
							if v23:GetAttribute("EmitDelay") ~= 0 then
								task.wait(v23:GetAttribute("EmitDelay"))
							end

							v23:Emit(v23:GetAttribute("EmitCount"))
						end)
					end

					break
				end
			end

			task.delay(time, function()
				Explode()
			end)

			if child then
				task.spawn(function()
					while not flag do
						local exploding = child:GetAttribute("Exploding")

						if exploding then
							Explode(exploding)
							break
						end

						if not child.Parent then
							break
						end

						task.wait()
					end
				end)
			end
		end

		local magnetArmFunctions = data.Root.Parent:FindFirstChild("MagnetArmFunctions")
		local v4 = "Left"

		for i = 1, 4 do
			if magnetArmFunctions and i < 3 then
				v4 = v4 == "Left" and "Right" or "Left"
				local armAnim = getArmAnim(
					root.Parent,
					v4 == "Right" and "Untr_ Z Tap Release R" or "Untr_ Z Tap Release L",
					v4
				) -- equivalent call inferred; original call site unknown

				if armAnim then
					armAnim:Play()
				end
			end

			Util.Sound:Play("Magnet_Untransformed_Z_Tap_Pistol_Fire_SingleShot_01", root.Position)
			task.wait(0.15)
			MakeBullet(i + 4, i)
		end
	end
end