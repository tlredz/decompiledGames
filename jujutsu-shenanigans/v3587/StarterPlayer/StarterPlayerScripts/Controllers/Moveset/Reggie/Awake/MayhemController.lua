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
local CameraShaker = require(replicatedStorage.Modules.CameraShaker)
require(replicatedStorage.Modules.BloodyZee)
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "MayhemController"
})

function controller.KnitStart(_)
	local v4 = {
		Start = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Reggie.MayhemStart, humanoidRootPart, game.SoundService.Effect)
		end,
		Explosion = function(p, position)
			local clone = utils.Reggie.Explosion:Clone()
			clone.Parent = workspace.Effects
			clone.WorldCFrame = CFrame.new(position)

			for _, emitter in clone:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			Debris:AddItem(clone, 3)
			local playSound = v3:PlaySound(sounds.Reggie.DroneStrike.Explode, clone, game.SoundService.Effect)
			playSound.PlaybackSpeed = math.random(90, 110) / 100

			if (workspace.CurrentCamera.CFrame.Position - position).Magnitude < 45 or localPlayer.Character == p then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end,
		Interp = function(parent, p)
			if p then
				local clone = utils.Reggie.ReceiptGlow:Clone()
				clone.Parent = parent
			end

			local cFrame = parent.CFrame
			local lastTime = tick()
			local positionChangedConnection = parent:GetPropertyChangedSignal("Position"):Connect(function()
				cFrame = parent.CFrame
				lastTime = tick()
			end)
			local steppedConnection = nil
			steppedConnection = RunService.Stepped:Connect(function()
				if parent.Parent == workspace.Bullets and parent.Parent then
					workspace:BulkMoveTo(
						{ parent },
						{ cFrame + cFrame.LookVector * (parent:GetAttribute("Speed") * (tick() - lastTime)) },
						Enum.BulkMoveMode.FireCFrameChanged
					)
					return
				end

				steppedConnection:Disconnect()
				positionChangedConnection:Disconnect()
			end)
		end,
		Land = function(p, p2)
			v3:PlaySound(sounds.Reggie.Littering.Land, p, game.SoundService.Effect)

			for _, child in p.CE_Infuse:GetChildren() do
				child.Enabled = true
				child:Emit(1)
			end

			if p2 then
				return
			end

			local clone = utils.Reggie.ReceiptBurn:Clone()
			clone.Parent = workspace.Effects
			clone.Anchored = true
			clone.CFrame = p.CFrame
			v3:PlayParticles(clone)
			Debris:AddItem(clone, 3)
			v3:PlaySound(sounds.Reggie.CouponBurn2, p, game.SoundService.Effect)
		end,
		Heal = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Reggie.SpotlightQuick:Clone()
			clone.CFrame = humanoidRootPart.CFrame
			clone.Weld.Part0 = humanoidRootPart
			clone.Parent = workspace.Effects

			for _, emitter in clone:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			Debris:AddItem(clone, 1)
			v3:PlaySound(sounds.Reggie.Heal, humanoidRootPart, game.SoundService.Effect)
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
	v = Knit.GetService("MayhemService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller