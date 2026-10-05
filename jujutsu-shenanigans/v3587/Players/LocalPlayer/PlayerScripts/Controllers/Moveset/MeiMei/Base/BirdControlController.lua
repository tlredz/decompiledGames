local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local _ = replicatedStorage.Animations
local utils = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
require(replicatedStorage.Modules.CameraShaker)
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "BirdControlController"
})
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map, workspace.Domains }

local function cubicBezier(p, p2, p3, p4, p5)
	local v4 = 1 - p5
	return v4 ^ 3 * p + 3 * v4 ^ 2 * p5 * p2 + 3 * v4 * p5 ^ 2 * p3 + p5 ^ 3 * p4
end

local function cubicBezierTangent(p, p2, p3, p4, p5)
	local v4 = 1 - p5
	return 3 * v4 ^ 2 * (p2 - p) + 6 * v4 * p5 * (p3 - p2) + 3 * p5 ^ 2 * (p4 - p3)
end

function controller.KnitStart(_)
	local v4 = {
		Eye = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.MeiMei.CrowEye:Clone()
			clone.Parent = instance.Head
			v2:PlayParticles(clone)
			Debris:AddItem(clone, 1)
			local playSound = v2:PlaySound(
				sounds.MeiMei.BirdControl.CrowEye,
				humanoidRootPart,
				game.SoundService.Effect
			)
			playSound.Volume = 2

			if instance2 then
				local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

				if not humanoidRootPart2 then
					return
				end

				v2:PlaySound(sounds.Hiromi.Grapple.Start, humanoidRootPart, game.SoundService.Effect)
				local clone2 = utils.Itadori.CounterHit.Feint:Clone()

				for _, child in clone2:GetChildren() do
					child.Color = ColorSequence.new(Color3.fromRGB(30, 40, 80))
					child.TimeScale = 0.75
				end

				clone2.Parent = humanoidRootPart2
				clone2.Sparks:Emit(30)
				clone2.Ring:Emit(6)
				Debris:AddItem(clone2, 1)
			end
		end,
		Hit = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.MeiMei.BirdControl.Hit, humanoidRootPart, game.SoundService.Effect)
		end,
		Explode = function(_, position)
			local clone = utils.Damage.CrowExplode:Clone()
			clone.Parent = workspace.Effects
			clone.Position = position
			Debris:AddItem(clone, 4)
			v2:PlaySound(sounds.MeiMei.BirdControl.Impact, clone, game.SoundService.Effect)

			for _, emitter in clone:GetDescendants() do
				if emitter:IsA("ParticleEmitter") and emitter.Name ~= "Sparks" then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end
		end,
		Interp = function(part, p, p2)
			if p then
				local playSound = v2:PlaySound(
					sounds.Misc.Crow["Caw" .. math.random(1, 3)],
					part,
					game.SoundService.Effect
				)
				playSound.RollOffMaxDistance = 250
			end

			local v5 = v2:PlaySound(sounds.MeiMei.BirdControl.Fly, part, game.SoundService.Effect)
			v5.PlaybackSpeed = 2
			part:GetAttributeChangedSignal("Speed"):Connect(function()
				v5.PlaybackSpeed = 1
			end)

			if p2 then
				local clone = replicatedStorage.Utils.MeiMei.CrowWind:Clone()
				clone.Weld.Part0 = part
				clone.Parent = part.Parent
				v2:PlaySound(sounds.MeiMei.CrowLaunch, part, game.SoundService.Effect)
			end

			local cFrame = part.CFrame
			local lastTime = tick()
			local positionChangedConnection = part:GetPropertyChangedSignal("Position"):Connect(function()
				cFrame = part.CFrame
				lastTime = tick()
			end)
			local steppedConnection = nil
			steppedConnection = RunService.Stepped:Connect(function()
				if part.Parent and part:GetAttribute("Speed") then
					workspace:BulkMoveTo(
						{ part },
						{ cFrame + cFrame.LookVector * (part:GetAttribute("Speed") * (tick() - lastTime)) },
						Enum.BulkMoveMode.FireCFrameChanged
					)
					return
				end

				steppedConnection:Disconnect()
				positionChangedConnection:Disconnect()
				v5:Destroy()
			end)
		end,
		Flight = function(instance, instance2, instance3, instance4)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoid = instance:FindFirstChild("Humanoid")
			local primaryPart = instance4.PrimaryPart
			local v5 = primaryPart.CFrame - primaryPart.Position
			v2:PlaySound(sounds.MeiMei.BirdControl.Grab, humanoidRootPart, game.SoundService.Effect)
			instance3:Destroy()
			primaryPart.Anchored = true
			local bodyGyro = nil

			while true do
				local v6 = task.wait()
				local unit = instance2.Velocity.Magnitude > 0 and instance2.Velocity.Unit or primaryPart.CFrame.LookVector
				v5 = v5:Lerp(CFrame.lookAt(createVector(0, 0, 0), unit), 0.2 * v6 * 60)
				local vectorToWorldSpace = instance["Left Arm"].CFrame:VectorToWorldSpace(createVector(0, -1.5, 0))
				local v7 = instance["Left Arm"].Position + vectorToWorldSpace
				instance4:PivotTo(CFrame.new(v7) * v5 * CFrame.new(0, 0, -1.4))

				if instance == localPlayer.Character then
					local ControlModule = require(localPlayer.PlayerScripts.PlayerModule.ControlModule)
					local moveVector = ControlModule:GetMoveVector()
					local lookVector = workspace.CurrentCamera.CFrame.LookVector
					local cframe = CFrame.lookAt(createVector(0, 0, 0), Vector3.new(lookVector.X, 0, lookVector.Z).Unit)
					local vectorToWorldSpace2 = cframe:VectorToWorldSpace(moveVector)

					if bodyGyro == nil then
						bodyGyro = Instance.new("BodyGyro")
						bodyGyro.P = 10000
						bodyGyro.MaxTorque = createVector(40000, 40000, 40000)
						bodyGyro.CFrame = cframe
						bodyGyro.Parent = humanoidRootPart
						humanoid.PlatformStand = true
					end

					local vector2 = Vector3.new(vectorToWorldSpace2.X, 0, vectorToWorldSpace2.Z)

					if vector2.Magnitude > 1 then
						vector2 = vector2.Unit
					end

					instance2.Velocity = instance2.Velocity:Lerp(vector2 * 25 * 1.3, 0.05 * v6 * 60)

					if instance2.Velocity.Magnitude < 0.5 then
						instance2.Velocity = instance2.Velocity.Unit * 0.5
					end

					bodyGyro.CFrame = cframe
				end

				if not (humanoidRootPart.Parent == nil or instance2.Parent == nil or instance.Parent == nil) then
					continue
				end

				humanoid.PlatformStand = false

				if instance2 then
					instance2:Destroy()
				end

				if bodyGyro then
					bodyGyro:Destroy()
				end

				break
			end
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
	v = Knit.GetService("BirdControlService")
	v2 = Knit.GetController("FXController")
	v3 = Knit.GetController("ToolController")
end

return controller