local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local _ = replicatedStorage.Animations
local utils = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
local CameraShaker = require(replicatedStorage.Modules.CameraShaker)
require(replicatedStorage.Modules.BloodyZee)
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "FlowerBeamController"
})
local random = Random.new()
local currentCamera = workspace.CurrentCamera
Color3.fromRGB(128, 187, 219)
Color3.new(1, 1, 1)

local function drawBeam(folder, p, data)
	local v4 = math.max(data.Z - 45 - data.X / 2, 0)
	local X = folder.BlackStart.Size.X
	folder.BlackStart.CFrame = p * CFrame.new(0, 0, -22.5) * CFrame.Angles(-1.5707963267948966, 0, 0)
	folder.BlackStart.Size = Vector3.new(data.X, 45, data.Y)
	folder.PinkStart.CFrame = folder.BlackStart.CFrame
	folder.PinkStart.Size = folder.BlackStart.Size * createVector(0.6, 1, 0.6)
	folder.BlackMiddle.CFrame = p * CFrame.new(0, 0, -(v4 / 2 + 45)) * CFrame.Angles(-1.5707963267948966, 0, 0)
	folder.BlackMiddle.Size = Vector3.new(data.X, v4, data.Y)
	folder.PinkMiddle.CFrame = folder.BlackMiddle.CFrame
	folder.PinkMiddle.Size = folder.BlackMiddle.Size * createVector(0.6, 1, 0.6)
	folder.BlackEnd.CFrame = p * CFrame.new(0, 0, -(v4 + 45 + data.X / 4)) * CFrame.Angles(1.5707963267948966, 0, 0)
	folder.BlackEnd.Size = Vector3.new(data.X, data.X / 2, data.X)
	folder.PinkEnd.CFrame = folder.BlackEnd.CFrame
	folder.PinkEnd.Size = folder.BlackEnd.Size * createVector(0.6, 1, 0.6)

	for _, beam in folder:GetDescendants() do
		if not beam:IsA("Beam") then
			continue
		end

		local v5 = X / beam.CurveSize0
		beam.CurveSize0 = data.X / v5
	end
end

local function shootSpec(parent)
	local clone = utils.Yuta.LoveBeam.BlackSpec:Clone()
	clone.Color = Color3.new(1, 1, 1)
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
	local boundingBox, v4 = clone:GetBoundingBox()
	local v5 = v4 / 2
	local pointToObjectSpace = boundingBox:PointToObjectSpace(currentCamera.CFrame.Position)

	if pointToObjectSpace.Z > v5.Z or pointToObjectSpace.Z < -v5.Z then
		return
	end

	if (pointToObjectSpace * createVector(1, 1, 0)).Magnitude > v5.X then
		return
	else
		return true
	end
end

function controller.KnitStart(_)
	local v4 = {
		Windup = function(instance)
			if not instance then
				return
			end

			local leftArm = instance:FindFirstChild("Left Arm")

			if not leftArm then
				return
			end

			local clone = utils.Hanami.Beam.Windup:Clone()
			clone.Parent = leftArm
			Debris:AddItem(clone, 0.8)
			v2:PlaySound(sounds.Hanami.FlowerBeam.Windup, leftArm, game.SoundService.Effect)

			if localPlayer:DistanceFromCharacter(leftArm.Position) < 40 then
				local tweenInfo = TweenInfo.new(1)
				TweenService:Create(clone.PointLight, tweenInfo, {
					Range = 12,
					Brightness = 2
				}):Play()
				TweenService:Create(game.Lighting, tweenInfo, {
					ExposureCompensation = -2
				}):Play()
				local shakeSustain = CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.LightHit)
				clone.AncestryChanged:Once(function()
					TweenService:Create(game.Lighting, TweenInfo.new(0.1), {
						ExposureCompensation = 0
					}):Play()
					shakeSustain:StartFadeOut(0.2)
				end)
			end

			for _ = 1, 8 do
				clone.Spark2.Rate += 5
				clone.Spark.Rate += 5
				task.wait(0.05)
			end
		end,
		StartBeam = function(instance)
			local beamStartCFrame = instance:GetAttribute("BeamStartCFrame")
			local cFrame = currentCamera.CFrame
			local v5 = beamStartCFrame.Position - cFrame.Position

			if v5.Unit:Dot(cFrame.LookVector) >= 0.7 and v5.Magnitude < 70 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.SnapOh)
			end

			for _, child in utils.Misc.M.Awk.mokultMeh["3"]:GetChildren() do
				child:PivotTo(beamStartCFrame * CFrame.Angles(1.5707963267948966, 0, 0))
				Knit.GetController("MokouController"):ArcTween(child.Start, true)
			end

			for _, child in utils.Ryu.Launch:GetChildren() do
				child:PivotTo(beamStartCFrame * CFrame.Angles(1.5707963267948966, 0, 0))
				Knit.GetController("MokouController"):ArcTween(child.Start, true)
			end

			local clone = utils.Hanami.Beam.FlowerBeam:Clone()
			local vector3Value = Instance.new("Vector3Value")
			vector3Value.Value = createVector(30, 30, 180)
			drawBeam(
				clone,
				beamStartCFrame * CFrame.new(0, 0, -5),
				Vector3.new(30, 30, instance:GetAttribute("BeamLength"))
			)
			clone.Parent = workspace.Effects
			v2:PlaySound(sounds.Hanami.FlowerBeam.Shoot, clone.PinkStart, game.SoundService.Effect)
			local _ = beamStartCFrame * CFrame.new(0, 0, -3)
			local v6 = true
			task.spawn(function()
				local clone2 = utils.Yuta.LoveBeam.CameraFX:Clone()
				clone2.TintColor = Color3.fromRGB(170, 255, 255)
				local v7

				if (currentCamera.CFrame.Position - beamStartCFrame.Position).Magnitude < 180 then
					v7 = CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.HeavyHit)
				end

				while true do
					local v8 = v6 and createVector(1, 1, 0) * random:NextNumber(1, 5) or createVector(0, 0, 0)
					beamStartCFrame = instance:GetAttribute("BeamStartCFrame")
					drawBeam(
						clone,
						beamStartCFrame,
						vector3Value.Value * createVector(1, 1, 0) + v8 + Vector3.new(
							0,
							0,
							instance:GetAttribute("BeamLength")
						)
					)

					-- equivalent call inferred; original call site unknown
					if isCameraInBeam(clone) then
						clone2.Parent = game.Lighting
					else
						clone2.Parent = nil
					end

					task.wait()

					if clone.Parent then
						continue
					end

					if v7 then
						v7:StartFadeOut(0.5)
					end

					clone2:Destroy()
					break
				end
			end)
			local v7 = true
			task.spawn(function()
				repeat
					task.spawn(shootSpec, clone)
					task.wait(0.3)
				until not (clone.Parent and v7)
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
			TweenService:Create(clone.BlackStart.Glow.PointLight, TweenInfo.new(1), {
				Brightness = 0
			}):Play()
			TweenService:Create(vector3Value, TweenInfo.new(0.5), {
				Value = createVector(0, 0, 180)
			}):Play()

			for _, effect in clone:GetDescendants() do
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
			v6 = false
			task.wait(0.25)
			clone:Destroy()
		end
	}
	v.Effects:Connect(function(p, ...)
		local v5 = v4[p]

		if not v5 then
			return
		end

		v5(...)
	end)
end

function controller.KnitInit(_)
	v = Knit.GetService("FlowerBeamService")
	v2 = Knit.GetController("FXController")
	v3 = Knit.GetController("ToolController")
end

return controller