local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
local RunService = game:GetService("RunService")
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
	Name = "DroneStrikeController"
})

function controller.KnitStart(_)
	local v4 = {
		Start = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Reggie.DroneStrike.Whoosh, humanoidRootPart, game.SoundService.Effect)
		end,
		DroneStart = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Reggie.DroneStrike.DroneStart, humanoidRootPart, game.SoundService.Effect)
		end,
		Press = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Reggie.DroneStrike.Press, humanoidRootPart, game.SoundService.Effect)
		end,
		DroneLoop = function(p)
			v3:PlaySound(sounds.Reggie.DroneStrike.Loop, p.Rootpart, game.SoundService.Effect)
		end,
		Aim = function(instance, instance2, object)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Reggie.Crosshair:Clone()
			clone.Parent = workspace.Effects
			clone.CFrame = humanoidRootPart.CFrame

			while not instance2:GetAttribute("Fired") do
				local v5 = task.wait()
				local ControlModule = require(localPlayer.PlayerScripts.PlayerModule.ControlModule)
				object:FireServer((ControlModule:GetMoveVector()))
				local v6 = humanoidRootPart.CFrame * instance2:GetAttribute("Aim")
				local raycastResult = workspace:Raycast(
					humanoidRootPart.Position,
					v6.Position - humanoidRootPart.Position,
					_G.MapParams
				)

				if raycastResult then
					v6 = CFrame.new(raycastResult.Position) * v6.Rotation
				end

				clone.CFrame = clone.CFrame:Lerp(v6, v5 * 25)

				if instance2.Value == true or instance2.Parent == nil then
					break
				end
			end

			clone:Destroy()
		end,
		Break = function(instance)
			for _ = 1, 3 do
				local clone = utils.Hiromi.GavelShard:Clone()
				clone.Position = (instance.CFrame * CFrame.new((Vector3.new(
					(math.random() - 0.5) * instance.Size.X,
					(math.random() - 0.5) * instance.Size.Y,
					(math.random() - 0.5) * instance.Size.Z
				)))).Position
				clone.Size *= instance.Size.Magnitude / 6
				clone.Color = Color3.fromRGB(173, 193, 184)
				clone.Velocity = instance.CFrame.LookVector * math.random(10, 20) + Vector3.new(
					math.random(-50, 50),
					math.random(-50, 50),
					math.random(-50, 50)
				)
				clone.RotVelocity = Vector3.new(math.random(-50, 50), math.random(-50, 50), math.random(-50, 50))
				clone.Parent = workspace.Effects
				Debris:AddItem(clone, 2)
				task.delay(1, function()
					TweenService:Create(clone, TweenInfo.new(1), {
						Size = createVector(0, 0, 0)
					}):Play()
				end)
			end
		end,
		Explode = function(p, position, p2)
			local clone = utils.Reggie.BikeExplode:Clone()
			local model = Instance.new("Model")
			clone.Parent = model
			model:ScaleTo(p2 and 0.7 or 0.45)
			Debris:AddItem(model, 0.2)
			clone.Parent = workspace.Effects
			clone.Position = position
			Debris:AddItem(clone, 6)
			v3:PlayParticles(clone)
			v3:PlaySound(sounds.Reggie.DroneStrike.Explode, clone, game.SoundService.Effect)

			if (workspace.CurrentCamera.CFrame.Position - position).Magnitude < 29 or localPlayer.Character == p then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end,
		Interp = function(instance)
			local cFrame = instance.CFrame
			local lastTime = tick()
			local positionChangedConnection = instance:GetPropertyChangedSignal("Position"):Connect(function()
				cFrame = instance.CFrame
				lastTime = tick()
			end)
			local steppedConnection = nil
			steppedConnection = RunService.Stepped:Connect(function()
				if instance.Parent then
					workspace:BulkMoveTo(
						{ instance },
						{ cFrame + cFrame.LookVector * (instance:GetAttribute("Speed") * (tick() - lastTime)) },
						Enum.BulkMoveMode.FireCFrameChanged
					)
					return
				end

				steppedConnection:Disconnect()
				positionChangedConnection:Disconnect()
			end)
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
	v = Knit.GetService("DroneStrikeService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller