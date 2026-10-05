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
local v = nil
local v2 = nil
local v3 = nil
local v4 = nil
local controller = Knit.CreateController({
	Name = "PianoDropController"
})

function controller.ToolDeactivate(_)
	return (v4:GetMouseTarget(75))
end

function controller.KnitStart(_)
	local v5 = {
		Hitbox = function(p, p2)
			local clone = utils.Megumi.HitArea:Clone()
			clone.Size = createVector(15, 0, 15)

			for _, child in clone:GetChildren() do
				local transparency = child.Transparency
				child.Transparency = 1
				TweenService:Create(child, TweenInfo.new(0.4), {
					Transparency = transparency
				}):Play()
			end

			clone.Parent = workspace.Effects
			local clone2

			if p2 then
				clone2 = utils.Megumi.HitArea:Clone()
				clone2.Size = createVector(30, 0, 30)

				for _, child in clone2:GetChildren() do
					child.Color3 = Color3.fromRGB(255, 150, 150)
					local transparency = child.Transparency
					child.Transparency = 1
					TweenService:Create(child, TweenInfo.new(0.4), {
						Transparency = transparency
					}):Play()
				end

				clone2.Parent = workspace.Effects
			end

			while true do
				local mouseTarget = v4:GetMouseTarget(75)
				local raycastResult = workspace:Raycast(
					mouseTarget + createVector(0, 1, 0),
					createVector(0, -300, 0),
					_G.MapParams
				)

				if raycastResult then
					mouseTarget = raycastResult.Position
				end

				clone.Position = mouseTarget + createVector(0, 0.01, 0)

				if clone2 then
					clone2.Position = mouseTarget
				end

				task.wait()

				if not (not p or not p.Parent or p.Value) then
					continue
				end

				clone:Destroy()

				if clone2 then
					clone2:Destroy()
				end

				break
			end
		end,
		Spawn = function(_, instance)
			local clone = instance.Root:Clone()
			clone.Parent = workspace.Effects
			local clone2 = utils.Reggie.PianoDrop.Wind1:Clone()
			clone2.Parent = clone
			local clone3 = utils.Reggie.PianoDrop.Wind2:Clone()
			clone3.Parent = clone
			local clone4 = utils.Reggie.PianoDrop.Stage2:Clone()
			clone4.Parent = clone
			local v6 = v3:PlaySound(sounds.Reggie.PianoFall, clone, game.SoundService.Effect)

			while true do
				task.wait()

				if not instance:FindFirstChild("Root") then
					break
				end

				if instance:GetAttribute("Speed") > 1 and clone2.Enabled == false then
					clone2.Enabled = true
					clone3.Enabled = true

					for _, child in clone4:GetChildren() do
						child.Enabled = true
					end
				end

				clone.CFrame = instance.Root.CFrame

				if instance.Parent == nil or instance:GetAttribute("Dropped") then
					break
				end
			end

			Debris:AddItem(clone, 3)
			v6:Stop()
			clone2.Enabled = false
			clone3.Enabled = false

			for _, child in clone4:GetChildren() do
				child.Enabled = false
			end
		end,
		Smash = function(position, p)
			local clone = utils.Megumi.Smash:Clone()
			clone.Position = position
			clone.Parent = workspace.Effects
			clone.Dust:Emit(10)
			clone.Ring:Emit(10)
			Debris:AddItem(clone, 4)

			if p then
				local clone2 = utils.Megumi.Mahoraga.Earthquake:Clone()
				clone2.Position = position
				clone2.Parent = workspace.Effects
				clone2.Air:Destroy()
				TweenService:Create(clone2.PointLight, TweenInfo.new(0.6), {
					Brightness = 0
				}):Play()
				TweenService:Create(clone2.Floor.Ring2, TweenInfo.new(0.4), {
					TimeScale = 0.5
				}):Play()
				clone2.Floor.Ring2:Emit(10)
				clone2.Floor.Wind2:Emit(15)
				clone2.Floor.Dust:Emit(100)
				Debris:AddItem(clone2, 3)
				local clone3 = utils.Megumi.Mahoraga.WorldSlash.mesh:Clone()
				clone3.Position = position
				clone3.Decal.Transparency = 0
				clone3.Mesh.Scale = createVector(2, 50, 2)
				clone3.Parent = clone2
				TweenService:Create(clone3, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
					Size = createVector(80, 40, 80),
					CFrame = clone3.CFrame * CFrame.Angles(0, -3.12413936106985, 0)
				}):Play()
				TweenService:Create(clone3.Mesh, TweenInfo.new(0.65, Enum.EasingStyle.Exponential), {
					Scale = createVector(35, 10, 35)
				}):Play()
				TweenService:Create(clone3.Decal, TweenInfo.new(0.65, Enum.EasingStyle.Exponential), {
					Transparency = 1
				}):Play()
				Debris:AddItem(clone3, 0.65)
			end

			v3:PlaySound(sounds.Reggie.PianoBreak, clone, game.SoundService.Effect)

			if (workspace.CurrentCamera.CFrame.Position - position).Magnitude < 100 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.SnapOh)
			end
		end
	}
	v.Effects:Connect(function(p, ...)
		local v6 = v5[p]

		if not v6 then
			return
		end

		v6(...)
	end)
end

function controller.KnitInit(_)
	v = Knit.GetService("PianoDropService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
	v4 = Knit.GetController("ToolController")
end

return controller