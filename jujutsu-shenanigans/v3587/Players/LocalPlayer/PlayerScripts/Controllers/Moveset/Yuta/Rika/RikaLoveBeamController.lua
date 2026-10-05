local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local _ = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local _ = replicatedStorage.Animations
local utils = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
local CameraShaker = require(replicatedStorage.Modules.CameraShaker)
require(replicatedStorage.Modules.BloodyZee)
local StaticLightning = require(replicatedStorage.Modules.StaticLightning)
local v = nil
local v2 = nil
local controller = Knit.CreateController({
	Name = "RikaLoveBeamController"
})
local random = Random.new()
local currentCamera = workspace.CurrentCamera

local function drawBeam(folder, p, data)
	local X = folder.BlackStart.Size.X
	local v3 = data.X / 2
	local v4

	if data.Z < 65 then
		v4 = 0.6923076923076923 * data.Z
		v3 = 0.3076923076923077 * data.Z
	else
		v4 = 45
	end

	local v5 = math.max(data.Z - v4 - v3, 0)
	folder.BlackStart.CFrame = p * CFrame.new(0, 0, -v4 / 2) * CFrame.Angles(-1.5707963267948966, 0, 0)
	folder.BlackStart.Size = Vector3.new(data.X, v4, data.Y)
	folder.PinkStart.CFrame = folder.BlackStart.CFrame
	folder.PinkStart.Size = folder.BlackStart.Size * createVector(0.875, 1, 0.875)
	folder.BlackMiddle.CFrame = p * CFrame.new(0, 0, -(v4 + v5 / 2)) * CFrame.Angles(-1.5707963267948966, 0, 0)
	folder.BlackMiddle.Size = Vector3.new(data.X, v5, data.Y)
	folder.PinkMiddle.CFrame = folder.BlackMiddle.CFrame
	folder.PinkMiddle.Size = folder.BlackMiddle.Size * createVector(0.875, 1, 0.875)
	folder.BlackEnd.CFrame = p * CFrame.new(0, 0, -(v4 + v5 + v3 / 2)) * CFrame.Angles(1.5707963267948966, 0, 0)
	folder.BlackEnd.Size = Vector3.new(data.X, v3, data.X)
	folder.PinkEnd.CFrame = folder.BlackEnd.CFrame
	folder.PinkEnd.Size = folder.BlackEnd.Size * createVector(0.875, 1, 0.875)

	for _, beam in folder:GetDescendants() do
		if not beam:IsA("Beam") then
			continue
		end

		local v6 = X / beam.CurveSize0
		beam.CurveSize0 = data.X / v6
	end
end

local function shootSpec(parent)
	local clone = utils.Yuta.LoveBeam.BlackSpec:Clone()
	clone.CFrame = parent.PinkStart.CFrame * CFrame.new(0, -10, 0)
	clone.Parent = parent
	local X = parent.BlackMiddle.Size.X
	local Y = parent.BlackMiddle.Size.Y
	TweenService:Create(clone, TweenInfo.new(0.3), {
		Size = Vector3.new(X, 20, X),
		CFrame = clone.CFrame * CFrame.new(0, Y / 2, 0)
	}):Play()
	task.wait(0.2)
	TweenService:Create(clone, TweenInfo.new(0.3), {
		Size = Vector3.new(X, 0, X),
		CFrame = parent.PinkStart.CFrame * CFrame.new(0, Y, 0)
	}):Play()
	task.wait(0.3)
	clone:Destroy()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isCameraInBeam(clone)
	local boundingBox, v3 = clone:GetBoundingBox()
	local v4 = v3 / 2
	local pointToObjectSpace = boundingBox:PointToObjectSpace(currentCamera.CFrame.Position)

	if pointToObjectSpace.Z > v4.Z or pointToObjectSpace.Z < -v4.Z then
		return
	end

	if (pointToObjectSpace * createVector(1, 1, 0)).Magnitude > v4.X then
		return
	else
		return true
	end
end

function controller.KnitStart(_)
	local v3 = {
		ScaleTo = function(self, value)
			local rootPart = self:FindFirstChild("RootPart")

			if not rootPart then
				return
			end

			v2:PlaySound(sounds.Yuta.LoveBeam.RikaMovement, rootPart, game.SoundService.Effect)
			local scale = self:GetScale()
			local v4 = value or 1.7
			local _ = v4 - scale
			local lastTime = tick()

			local function lerp(p, p2, p3)
				return p + p3 * (p2 - p)
			end

			repeat
				task.wait()
				self:ScaleTo(scale + math.clamp((tick() - lastTime) / 0.2, 0, 1) * (v4 - scale))
			until tick() - lastTime >= 0.2

			self:ScaleTo(v4)
		end,
		Charge = function(parent)
			TweenService:Create(parent, TweenInfo.new(0.5), {
				Size = createVector(1.5, 1.5, 1.5)
			}):Play()
			TweenService:Create(parent.Outline, TweenInfo.new(0.5), {
				Size = createVector(1.57, 1.57, 1.57)
			}):Play()
			parent.Attachment.Charge.Enabled = false
			parent.Attachment.Circles.Enabled = false
			local clone = utils.Yuta.LoveBeam.ChargeBallEffects.Attachment:Clone()
			clone.Parent = parent
			clone.EnergyBits1.Enabled = true
			task.wait(0.1)
			clone.EnergyBits2.Enabled = true
			clone.EnergyGlow1.Enabled = true
			task.wait(0.2)
			clone.EnergyBits3.Enabled = true
			clone.EnergyGlow2.Enabled = true
			task.wait(0.2)
			parent.Outline:Destroy()
			TweenService:Create(
				parent,
				TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true),
				{
					Size = createVector(2.25, 2.25, 2.25)
				}
			):Play()
			task.wait(0.1)
			TweenService:Create(parent, TweenInfo.new(0.1), {
				Size = createVector(3.25, 3.25, 3.25)
			}):Play()

			for _, child in clone:GetChildren() do
				child.Enabled = true
			end

			local cFrame = parent.CFrame

			repeat
				task.wait()
				parent.CFrame = cFrame + random:NextUnitVector() * 0.3
			until not parent.Parent
		end,
		StartBeamSound = function(parent)
			if not (parent and parent.Parent) then
				return
			end

			local trueLove = parent.TrueLove
			local clone = trueLove:Clone()
			clone.Parent = parent
			trueLove:Destroy()
			parent.TrueLove.EmitterSize = 100
			parent.TrueLove:Play()
		end,
		StartBeam = function(instance, instance2)
			local WAIT_INTERVAL = 0.04
			local beamStartCFrame = instance:GetAttribute("BeamStartCFrame")
			local trueLove = instance2:FindFirstChild("TrueLove")
			local model = Instance.new("Model", workspace.Effects)
			model.Name = "WhiteHighlight"
			local highlight = Instance.new("Highlight", model)
			highlight.OutlineTransparency = 1
			highlight.FillTransparency = 0.2
			highlight.FillColor = Color3.new(1, 1, 1)
			highlight.Adornee = model
			highlight.DepthMode = Enum.HighlightDepthMode.Occluded
			local clone = utils.Yuta.LoveBeam.ChargeBall2:Clone()
			clone.CFrame = beamStartCFrame * CFrame.new(0, 0, 3)
			clone.Transparency = 1
			clone.Parent = highlight
			v2:PlayParticles(clone.Attachment1)
			local cFrame = currentCamera.CFrame
			local v4 = beamStartCFrame.Position - cFrame.Position

			if v4.Unit:Dot(cFrame.LookVector) >= 0.7 and v4.Magnitude < 70 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)

				if _G.Settings.Flash == true then
					local clone2 = utils.Itadori.DivergentFist.BlackFlashCC:Clone()
					clone2.TintColor = Color3.new(1, 0.3, 1)
					clone2.Parent = game.Lighting
					task.wait(WAIT_INTERVAL)
					clone2.TintColor = Color3.new(1, 1, 1)
					task.wait(WAIT_INTERVAL)
					clone2.Brightness = 200
					clone2.Contrast = -1000
					task.wait(WAIT_INTERVAL)
					clone2:Destroy()
				end
			else
				task.wait(0.12)
			end

			local clone2 = utils.Yuta.LoveBeam.Beam:Clone()
			local part = Instance.new("Part", workspace.Effects)
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			part.Transparency = 1
			part.CastShadow = false
			part.Anchored = true
			part.CFrame = clone2.BlackMiddle.CFrame

			if trueLove then
				trueLove.Parent = part
				trueLove.RollOffMinDistance = 180
			end

			instance2:Destroy()
			local vector3Value = Instance.new("Vector3Value")
			vector3Value.Value = createVector(30, 30, 180)
			drawBeam(
				clone2,
				beamStartCFrame * CFrame.new(0, 0, -5),
				Vector3.new(30, 30, instance:GetAttribute("BeamLength"))
			)
			clone2.Parent = workspace.Effects
			clone.Transparency = 0
			local v5 = true
			local position = clone.Position
			task.spawn(function()
				local thicknessFade = StaticLightning.ThicknessFade(
					0.1,
					0.5,
					Enum.EasingStyle.Linear,
					Enum.EasingDirection.InOut
				)
				local v6 = {
					{},
					{},
					{}
				}

				while true do
					task.wait(0.06)
					local cFrame2 = clone.CFrame
					local position2 = cFrame2.Position

					for k, partPool in v6 do
						local unitVector = random:NextUnitVector()
						local position3 = position2 + cFrame2.LookVector * random:NextNumber(5, 30) + unitVector * 20
						local v12 = k
						local curveCenter = (position2 + position3) / 2 + unitVector * 30
						task.spawn(function()
							for i = 1, 3 do
								if not v5 then
									break
								end

								partPool = v6[v12]
								v6[v12] = StaticLightning.CreateBolt({
									Position1 = position2,
									Position2 = position3,
									CurveCenter = curveCenter,
									Color = clone.Color,
									Thickness = thicknessFade,
									PartPool = partPool,
									Parent = model
								})
								clone.Position = position + random:NextUnitVector() * 0.3
								position2 = clone.Position
								task.wait(0.02)
							end
						end)
					end

					if clone2.Parent and v5 then
						continue
					end

					model:Destroy()
					break
				end
			end)
			local v6 = true
			task.spawn(function()
				local clone3 = utils.Yuta.LoveBeam.CameraFX:Clone()
				local v7

				if (currentCamera.CFrame.Position - beamStartCFrame.Position).Magnitude < 180 then
					v7 = CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.HeavyHit)
				end

				while true do
					beamStartCFrame = instance:GetAttribute("BeamStartCFrame")
					local v8 = v6 and createVector(1, 1, 0) * random:NextNumber(1, 5) or createVector(0, 0, 0)
					drawBeam(
						clone2,
						beamStartCFrame,
						vector3Value.Value * createVector(1, 1, 0) + v8 + Vector3.new(
							0,
							0,
							instance:GetAttribute("BeamLength")
						)
					)
					part.CFrame = beamStartCFrame

					-- equivalent call inferred; original call site unknown
					if isCameraInBeam(clone2) then
						clone3.Parent = game.Lighting
					else
						clone3.Parent = nil
					end

					task.wait()

					if clone2.Parent then
						continue
					end

					if v7 then
						v7:StartFadeOut(0.5)
					end

					clone3:Destroy()
					break
				end
			end)
			local v7 = true
			task.spawn(function()
				repeat
					task.spawn(shootSpec, clone2)
					task.wait(0.3)
				until not (clone2.Parent and v7)
			end)
			TweenService:Create(vector3Value, TweenInfo.new(0.3), {
				Value = createVector(60, 60, 180)
			}):Play()
			task.wait(0.3)
			TweenService:Create(vector3Value, TweenInfo.new(0.1), {
				Value = createVector(40, 40, 180)
			}):Play()
			task.wait(0.1)
			TweenService:Create(vector3Value, TweenInfo.new(1), {
				Value = createVector(30, 30, 180)
			}):Play()
			TweenService:Create(clone2.PinkStart, TweenInfo.new(1), {
				Color = Color3.fromRGB(255, 100, 255)
			}):Play()
			TweenService:Create(clone2.PinkMiddle, TweenInfo.new(1), {
				Color = Color3.fromRGB(255, 100, 255)
			}):Play()
			TweenService:Create(clone2.PinkEnd, TweenInfo.new(1), {
				Color = Color3.fromRGB(255, 100, 255)
			}):Play()

			local function updateWidth()
				local width = instance:GetAttribute("Width")
				TweenService:Create(vector3Value, TweenInfo.new(0.2), {
					Value = Vector3.new(width.X - 5, width.Y - 5, 180)
				}):Play()
			end

			updateWidth()
			instance:GetAttributeChangedSignal("Width"):Connect(updateWidth)

			repeat
				task.wait()
			until not instance.Parent

			v7 = false
			TweenService:Create(vector3Value, TweenInfo.new(0.5), {
				Value = createVector(0, 0, 180)
			}):Play()

			for _, effect in clone2:GetDescendants() do
				if effect:IsA("Beam") then
					TweenService:Create(effect, TweenInfo.new(0.25), {
						Width0 = 0,
						Width1 = 0
					}):Play()
				elseif effect:IsA("ParticleEmitter") then
					effect.Enabled = false
				end
			end

			task.wait(0.25)
			v5 = false
			v6 = false
			task.wait(0.25)
			clone2:Destroy()
			Debris:AddItem(part, 10)
		end,
		Hit = function(p)
			v2:Flash(p, Color3.fromRGB(255, 170, 255))
		end,
		Finisher = function(folder)
			local smoke = utils.Yuta.LoveBeam.Smoke

			for _, descendant in folder:GetDescendants() do
				if descendant:IsA("BasePart") or descendant:IsA("Decal") then
					descendant.Transparency = 1
				end

				if descendant:IsA("BasePart") then
					descendant.CollisionGroup = "NoPlayerCollision"
				end

				if not (descendant.Name ~= "HumanoidRootPart" and descendant.Parent == folder) then
					continue
				end

				local clone = smoke:Clone()
				clone.Parent = descendant
				clone:Emit(20)
			end
		end
	}
	RikaLoveBeamService.Effects:Connect(function(p, ...)
		local v4 = v3[p]

		if not v4 then
			return
		end

		v4(...)
	end)
end

function controller.KnitInit(_)
	RikaLoveBeamService = Knit.GetService("RikaLoveBeamService")
	v = Knit.GetController("HitboxController")
	v2 = Knit.GetController("FXController")
end

return controller