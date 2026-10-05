local createVector = vector.create
game:GetService("Players")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("Lighting")
local CAM = ReplicatedStorage.CAM
local modules = CAM.Client.Modules
local debree = workspace.Debree
local assets = script:FindFirstChild("Assets")
script:FindFirstChild("Sounds")
local token = modules.Effects.Token
local DebrisModule = require(CAM.DebrisModule)
local Cam_Shaker = require(modules.Effects.Cam_Shaker)
local CraterExtension = require(modules.Effects.Craters.CraterExtension)
local vfxUtility = require(game.ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
require(modules.Effects.BoatTween)
require(token.BezierCurve)
local TokenKit = require(token.TokenKit)
local _ = game.Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = { workspace.Map }
raycastParams.FilterType = Enum.RaycastFilterType.Include

function BlurEffect(value)
	local blurEffect = Instance.new("BlurEffect")
	local lighting = game.Lighting
	blurEffect.Size = 5
	blurEffect.Parent = lighting
	DebrisModule:AddItem(blurEffect, value or 0.08333333333333333)
end

TweenInfo.new(0.4)
local object = setmetatable({}, {
	__mode = "k"
})
return function(instance, p: string, cFrame, vectorVelocity, vector2: Vector3?)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart
	local position

	if p == "RideRockExplode" and typeof(cFrame) == "Vector3" then
		position = cFrame
	elseif humanoidRootPart ~= nil then
		position = humanoidRootPart.Position or nil
	end

	if position == nil or p ~= "Cancel" and (position - currentCamera.CFrame.Position).Magnitude > 250 then
		return
	end

	instance:FindFirstChild("UpperTorso")
	local name = string.format("%s Arrow_Flight_Effects", instance.Name)
	local parent2 = debree:FindFirstChild(name)

	if p == "rockup" or p == "RideRock" then
		if parent2 ~= nil then
			parent2:Destroy()
		end

		parent2 = Instance.new("Folder")
		parent2.Name = name
		parent2.Parent = debree
		DebrisModule:AddItem(parent2, 10)
	end

	if p == "RideRockExplode" then
		local v3 = object[instance]

		if v3 ~= nil then
			v3(cFrame, vectorVelocity, vector2)
		end
	else
		if parent2 == nil then
			return
		end

		if p == "RideRock" then
			local raycastResult = workspace:Raycast(
				humanoidRootPart.Position + createVector(0, 5, 0),
				createVector(0, -60, 0),
				raycastParams
			)
			local clone = assets.RockUp:Clone()
			clone.Parent = parent2
			local clone2 = script.Sounds.PS2arrowFLYlift:Clone()
			clone2.Parent = clone
			clone2:Play()
			clone.CFrame = CFrame.new(raycastResult ~= nil and raycastResult.Position or humanoidRootPart.Position - createVector(
				0,
				15,
				0
			))
			local raycastResult2 = workspace:Raycast(
				clone.Position + createVector(0, 1, 0),
				createVector(-0, -12, -0),
				raycastParams
			)

			if raycastResult2 then
				vfxUtility.EmitAll(clone, vfxUtility.Owned(instance, {
					Color = raycastResult2.Instance.Color,
					ColorBlacklist = "Smoke"
				}))
			else
				vfxUtility.EmitAll(clone, vfxUtility.Owned(instance))
			end

			DebrisModule:AddItem(clone, 6)
			local clone3 = assets.RockFlight:Clone()
			clone3.Parent = parent2
			local clone4 = script.Sounds.PS2arrowFLYloop:Clone()
			clone4.Parent = clone3.PrimaryPart
			clone4:Play()
			local flag = true
			clone3:PivotTo(humanoidRootPart.CFrame * CFrame.new(-0.17584228515625, -2, -0.12823486328125) * CFrame.fromEulerAnglesYXZ(
				-0.02112133428454399,
				0.00011834411270683631,
				0.02339940518140793
			))
			DebrisModule:AddItem(clone3, 20)
			local part = Instance.new("Part", parent2)
			part.Name = "waitpart"

			if raycastResult ~= nil and raycastResult.Instance ~= nil then
				clone3.Rock.Color = raycastResult.Instance.Color
				clone3.Rock.Material = raycastResult.Material
				clone3.Rock.MaterialVariant = raycastResult.Instance.MaterialVariant
			end

			local weld = Instance.new("Weld")
			weld.Part0 = humanoidRootPart
			weld.Part1 = clone3.PrimaryPart
			weld.Parent = clone3.PrimaryPart
			weld.C0 = CFrame.new(0, -5, 0)
			part.AncestryChanged:Connect(function(_, parent)
				if not parent then
					flag = false
				end
			end)

			while flag do
				task.wait()
			end

			weld.Part0 = nil
			DebrisModule:AddItem(weld, 0.01)
		elseif p == "PickupVfx" then
			if cFrame == nil then
				return
			end

			local clone = script.Assets.PickedUpVfx:Clone()
			clone.CFrame = cFrame.CFrame
			clone.Parent = parent2
			local clone2 = script.Sounds["PS2arrowFLYhit (1)"]:Clone()
			clone2.Parent = clone
			clone2:Play()
			Cam_Shaker(clone.Position, "tinyshake_preset")
			vfxUtility.EmitAll(clone, vfxUtility.Owned(instance))
			os.clock()
			DebrisModule:AddItem(clone, 2)
		elseif p == "RideRockThrow" then
			local rockFlight = parent2:FindFirstChild("RockFlight")

			if rockFlight == nil then
				return
			end

			parent2.Name = "--"
			DebrisModule:AddItem(rockFlight, 3)
			local weld = rockFlight.PrimaryPart:FindFirstChild("Weld")

			if weld ~= nil then
				weld:Destroy()
			end

			rockFlight.PrimaryPart.Anchored = false
			local pS2arrowFLYloop = rockFlight.PrimaryPart:FindFirstChild("PS2arrowFLYloop")

			if pS2arrowFLYloop ~= nil then
				pS2arrowFLYloop:Destroy()
			end

			local part = Instance.new("Part")
			part.Name = "Shoot"
			part.Anchored = true
			part.CanCollide = false
			part.CanTouch = false
			part.Transparency = 1
			part.Position = rockFlight.PrimaryPart.Position
			part.Parent = parent2
			local clone = script.Sounds.PS2arrowFLYshoot:Clone()
			clone.Parent = part
			clone:Play()
			DebrisModule:AddItem(part, (math.max(clone.TimeLength, 3)))
			local part2 = Instance.new("Part")
			part2.TopSurface = Enum.SurfaceType.Smooth
			part2.BottomSurface = Enum.SurfaceType.Smooth
			part2.CanCollide = false
			part2.Transparency = 1
			local cframe = CFrame.new(cFrame.Position, cFrame.Position + vectorVelocity)
			part2.CFrame = CFrame.new(cFrame.Position) * rockFlight.PrimaryPart.CFrame.Rotation
			part2.Anchored = false
			part2.Size = createVector(5, 5, 4)
			local weld2 = Instance.new("Weld", rockFlight.PrimaryPart)
			weld2.Part0 = part2
			weld2.Part1 = rockFlight.PrimaryPart
			local attachment = Instance.new("Attachment", part2)
			local linearVelocity = Instance.new("LinearVelocity", part2)
			linearVelocity.MaxForce = 10000000
			linearVelocity.Attachment0 = attachment
			linearVelocity.VectorVelocity = vectorVelocity
			local alignOrientation = Instance.new("AlignOrientation")
			alignOrientation.Mode = "OneAttachment"
			alignOrientation.Attachment0 = attachment
			alignOrientation.MaxTorque = 400000
			alignOrientation.CFrame = cframe
			alignOrientation.Parent = attachment

			local function explode(vector3: Vector3, vector4: Vector3, p2)
				if object[instance] == nil then
					return
				end

				object[instance] = nil
				local v3 = CFrame.new(vector3, vector3 + (vector4 or createVector(0, 1, 0))) * CFrame.Angles(
					-1.5707963267948966,
					0,
					0
				)
				parent2.Name = "--"
				local clone2 = assets.HitFloor:Clone()
				clone2.Parent = parent2
				local clone3 = script.Sounds.PS2arrowFLYexplo:Clone()
				clone3.Parent = clone2
				clone3:Play()
				clone2.CFrame = v3

				if rockFlight ~= nil and rockFlight.Parent ~= nil then
					rockFlight.Rock.Transparency = 1
					vfxUtility.EnableAll(rockFlight, false)
					DebrisModule:AddItem(rockFlight, 0.5)
				end

				vfxUtility.EmitAll(clone2, vfxUtility.Owned(instance, vfxUtility.GetDustColorSettings(p2)))
				DebrisModule:AddItem(clone2, 6)
				CraterExtension.Ground(v3, 11, createVector(2.5, 3.5, 2), nil, 2, false, 2)
				CraterExtension.Ground(v3, 12, createVector(2.5, 3.5, 2), nil, 5, false, 2)
				task.spawn(TokenKit.GroundRocks, {
					CF = v3,
					InnerRadius = 19,
					OuterRadius = 21,
					Velocity = {
						Min = 20,
						Max = 40
					},
					Size = {
						Min = 1,
						Max = 3
					}
				})
				Cam_Shaker(v3.Position, {
					FadeInTime = 0,
					Frequency = 0.2,
					Amplitude = 0.5,
					SustainTime = 0.3,
					FadeOutTime = 0.4,
					RotationInfluence = createVector(0.25, 0.25, 0.25),
					PositionInfluence = createVector(3.5, 3.5, 3.5)
				})
				DebrisModule:AddItem(parent2, 4)
			end

			object[instance] = explode
			task.delay(3.5, function()
				if object[instance] ~= explode then
					return
				end

				local normalized = vector.normalize(vectorVelocity)
				explode(part2.Position + normalized * vector.magnitude(part2.Size) / 2, normalized * -1)
			end)
			part2.Name = "TouchPart"
			part2.Parent = parent2
		elseif p == "rockup" then
			if cFrame == nil then
				return
			end

			local rightHand = instance:FindFirstChild("RightHand")

			if rightHand then
				local clone = assets.Part.SummonPurp:Clone()
				clone.Parent = rightHand
				DebrisModule:AddItem(clone, 3)
				vfxUtility.EmitAll(clone, vfxUtility.Owned(instance))
			end

			local clone = assets.RockUp:Clone()
			clone.Parent = parent2
			local clone2 = script.Sounds.Flight.PS2arrowROCKTHROWlift:Clone()
			clone2.Parent = clone
			clone2:Play()
			clone.CFrame = cFrame
			vfxUtility.EmitAll(clone, vfxUtility.Owned(instance, vfxUtility.GetDustColorSettings(vectorVelocity)))
			DebrisModule:AddItem(clone, 6)
			Cam_Shaker(humanoidRootPart.Position, {
				FadeInTime = 0,
				Frequency = 0.1,
				Amplitude = 0.3,
				SustainTime = 0.1,
				FadeOutTime = 0.5,
				RotationInfluence = createVector(0.25, 0.25, 0.25),
				PositionInfluence = createVector(3.5, 3.5, 3.5)
			})
			local clone3 = assets.RockModel:Clone()
			clone3.Parent = parent2
			local rock = clone3.Rock
			local headUp = clone3.HeadUp
			clone3:PivotTo(cFrame)

			if vectorVelocity ~= nil then
				rock.Color = vectorVelocity.Color
				rock.Material = vectorVelocity.Material
				rock.MaterialVariant = vectorVelocity.MaterialVariant
			end

			TweenService:Create(clone3.PrimaryPart, TweenInfo.new(0.5), {
				CFrame = cFrame * CFrame.new(0, 7, 0)
			}):Play()
			vfxUtility.EnableAll(headUp, true, vfxUtility.Owned(instance))

			for _, child in rock:GetChildren() do
				if child.ClassName ~= "ParticleEmitter" then
					continue
				end

				child.Enabled = true
				local v3 = child
				task.delay(2, function()
					v3.Enabled = false
				end)
			end

			for _, descendant in headUp:GetDescendants() do
				if descendant.ClassName == "ParticleEmitter" then
					descendant:Emit(descendant:GetAttribute("EmitCount"))
				end

				if descendant.ClassName == "Trail" then
					descendant.Enabled = true
				end

				if descendant.ClassName == "Decal" then
					descendant.Transparency = 0
				end
			end

			task.wait(2)

			if headUp == nil or headUp.Parent == nil then
				return
			end

			for _, descendant in headUp:GetDescendants() do
				if descendant.ClassName == "ParticleEmitter" then
					descendant.Enabled = false
				end

				if descendant.ClassName == "Trail" then
					descendant.Enabled = false
				end

				if descendant.ClassName == "Decal" then
					TweenService:Create(descendant, TweenInfo.new(0.2), {
						Transparency = 1
					}):Play()
				end
			end
		elseif p == "expired" then
			local rockModel = parent2:WaitForChild("RockModel", 0.25)

			if rockModel == nil then
				return
			end

			TweenService:Create(rockModel.Rock, TweenInfo.new(0.5), {
				Transparency = 1
			}):Play()
			local clone = script.Assets.Explode:Clone()
			clone.Parent = parent2
			clone.Position = rockModel.Rock.Position
			vfxUtility.EmitAll(clone, vfxUtility.Owned(instance, rockModel.Rock.Color))
			local clone2 = script.Sounds.PS2arrowROCKTHROWdisperseTRUE:Clone()
			clone2.Parent = clone
			clone2:Play()
			Cam_Shaker(rockModel.Rock.Position, "tinyshake_less_aggresive_preset")
		elseif p == "RockThrow" then
			local rockModel = parent2:WaitForChild("RockModel", 0.25)

			if rockModel == nil then
				return
			end

			rockModel.PrimaryPart.Anchored = false
			local rightHand = instance:FindFirstChild("RightHand")
			local clone = assets.Part.SummonPurp:Clone()
			clone.Parent = rightHand
			DebrisModule:AddItem(clone, 3)
			vfxUtility.EmitAll(clone, vfxUtility.Owned(instance))
			rockModel.HeadUp:Destroy()
			local headForward = rockModel.HeadForward

			for _, descendant in headForward:GetDescendants() do
				if descendant.ClassName == "Trail" then
					descendant.Enabled = true
				end

				if descendant.ClassName == "Decal" then
					descendant.Transparency = 0
				end
			end

			local clone2 = assets.ShootRock:Clone()
			clone2.Parent = parent2
			local clone3 = script.Sounds.Flight.PS2arrowROCKTHROWshoot:Clone()
			clone3.Parent = clone2
			clone3:Play()
			local clone4 = script.Sounds.Flight.PS2arrowROCKTHROWloop:Clone()
			clone4.Parent = clone2
			clone4:Play()
			clone2.CFrame = CFrame.lookAt(rockModel.PrimaryPart.Position, cFrame + vectorVelocity) * CFrame.Angles(
				0,
				3.141592653589793,
				0
			)
			vfxUtility.EmitAll(clone2, vfxUtility.Owned(instance))
			DebrisModule:AddItem(clone2, 3)
			local part = Instance.new("Part")
			part.TopSurface = Enum.SurfaceType.Smooth
			part.BottomSurface = Enum.SurfaceType.Smooth
			part.CanCollide = false
			part.Transparency = 1
			local cframe = CFrame.new(cFrame, cFrame + vectorVelocity)
			part.CFrame = CFrame.new(cFrame) * rockModel.PrimaryPart.CFrame.Rotation
			part.Anchored = false
			part.Size = createVector(3, 3, 3)
			local weld = Instance.new("Weld", rockModel.PrimaryPart)
			weld.Part0 = part
			weld.Part1 = rockModel.PrimaryPart
			local attachment = Instance.new("Attachment", part)
			local linearVelocity = Instance.new("LinearVelocity", part)
			linearVelocity.MaxForce = 10000000
			linearVelocity.Attachment0 = attachment
			linearVelocity.VectorVelocity = vectorVelocity
			local alignOrientation = Instance.new("AlignOrientation")
			alignOrientation.Mode = "OneAttachment"
			alignOrientation.Attachment0 = attachment
			alignOrientation.MaxTorque = 400000
			alignOrientation.CFrame = cframe
			alignOrientation.Responsiveness = 50
			alignOrientation.Parent = attachment
			local touchedConnection = nil

			local function explode(vector3: Vector3, vector4: Vector3, p2)
				if touchedConnection ~= nil then
					touchedConnection:Disconnect()
					touchedConnection = nil
				end

				parent2.Name = "--"
				local cFrame2 = CFrame.new(vector3, vector3 + (vector4 or createVector(0, 1, 0))) * CFrame.Angles(
					-1.5707963267948966,
					0,
					0
				)

				if clone4 ~= nil then
					clone4:Destroy()
					clone4 = nil
				end

				if rockModel ~= nil and rockModel.Parent ~= nil then
					TweenService:Create(rockModel.Rock, TweenInfo.new(0.1), {
						Transparency = 1
					}):Play()
					vfxUtility.EnableAll(rockModel, false)
					DebrisModule:AddItem(rockModel, 0.5)
				end

				local clone5 = assets.RockImpact:Clone()
				clone5.Parent = parent2
				local clone6 = script.Sounds.Flight.PS2arrowROCKTHROWexplo:Clone()
				clone6.Parent = clone5
				clone6:Play()
				clone5.CFrame = cFrame2
				vfxUtility.EmitAll(clone5, vfxUtility.Owned(instance, vfxUtility.GetDustColorSettings(p2)))
				CraterExtension.Ground(clone5.Position, 5, createVector(2.5, 3.5, 2), nil, 2, false, 2)
				CraterExtension.Ground(clone5.Position, 9, createVector(2.5, 3.5, 2), nil, 5, false, 2)
				task.spawn(TokenKit.GroundRocks, {
					CF = clone5.CFrame,
					InnerRadius = 5,
					OuterRadius = 10,
					Velocity = {
						Min = 20,
						Max = 40
					},
					Size = {
						Min = 1,
						Max = 3
					}
				})
				Cam_Shaker(clone5.Position, {
					FadeInTime = 0,
					Frequency = 0.2,
					Amplitude = 0.3,
					SustainTime = 0.3,
					FadeOutTime = 0.4,
					RotationInfluence = createVector(0.25, 0.25, 0.25),
					PositionInfluence = createVector(3.5, 3.5, 3.5)
				})

				for _, descendant in headForward:GetDescendants() do
					if descendant.ClassName == "Trail" then
						descendant.Enabled = false
					end

					if descendant.ClassName == "Decal" then
						descendant.Transparency = 1
					end
				end

				DebrisModule:AddItem(parent2, 4)

				if part ~= nil and part.Parent ~= nil then
					part:Destroy()
				end
			end

			local _ = part.Position
			local thread = task.delay(3, function()
				local normalized = vector.normalize(vectorVelocity)
				local v3 = normalized * -1
				explode(part.Position + normalized * vector.magnitude(part.Size) / 2, v3)
			end)
			touchedConnection = part.Touched:Connect(function(otherPart)
				if not (otherPart:IsDescendantOf(workspace.Debree) or otherPart:IsDescendantOf(instance)) then
					local position2 = part.Position
					local normalized = vector.normalize(vectorVelocity)
					local v3 = normalized * 15
					local v4 = position2 + normalized * -5
					local raycastResult = workspace:Raycast(v4, v3, raycastParams)
					local v5 = position2 + normalized * vector.magnitude(part.Size) / 2

					if thread ~= nil then
						task.cancel(thread)
						thread = nil
					end

					if raycastResult ~= nil and raycastResult.Instance ~= nil then
						explode(raycastResult.Position, raycastResult.Normal, raycastResult.Instance)
						return
					end

					local raycastResult2 = workspace:Raycast(v4, createVector(0, -15, 0), raycastParams)

					if raycastResult2 == nil or raycastResult2.Instance == nil then
						explode(v5)
					else
						explode(raycastResult2.Position, raycastResult2.Normal, raycastResult2.Instance)
					end
				end
			end)
			part.Name = "TouchPart"
			part.Parent = parent2
		elseif p == "Cancel" then
			parent2:Destroy()
		end
	end
end