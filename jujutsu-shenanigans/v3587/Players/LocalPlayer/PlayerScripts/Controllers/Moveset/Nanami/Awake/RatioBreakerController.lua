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
local SraikoVFX = require(replicatedStorage.Modules.SraikoVFX)
local LightningBeams = require(replicatedStorage.Modules.LightningBeams)
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map, workspace.Domains }
local random = Random.new()
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "RatioBreakerController"
})
local v4 = {
	"rbxassetid://74285508054294",
	"rbxassetid://99132465087026",
	"rbxassetid://114891301322696",
	"rbxassetid://85813887517647",
	"rbxassetid://76321503224643",
	"rbxassetid://78626248888940",
	"rbxassetid://115760318978716",
	"rbxassetid://103659957620708",
	"rbxassetid://129941782677974",
	"rbxassetid://72590467800262",
	"rbxassetid://115486948939199",
	"rbxassetid://120088088651914",
	"rbxassetid://76659571940765",
	"rbxassetid://135487679567493",
	"rbxassetid://105922249024859",
	"rbxassetid://127194758766478"
}

function controller.KnitStart(_)
	task.spawn(function()
		local v5 = {}

		for _, v6 in pairs(v4) do
			table.insert(v5, v6)
		end

		game.ContentProvider:PreloadAsync(v5)
	end)
	local v5 = {
		Start = function(instance, instance2, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local v6

			if p == 1 then
				v6 = v2:PlaySound(sounds.Nanami.RatioBreaker.RB1.Whoosh, humanoidRootPart, game.SoundService.Effect)
			else
				if p == 2 then
					v2:PlaySound(sounds.Nanami.RatioBreaker.RB2.Whoosh, humanoidRootPart, game.SoundService.Effect)
					return
				end

				if p ~= 4 then
					return
				end

				v6 = v2:PlaySound(sounds.Nanami.RatioBreaker.RB4.Start, humanoidRootPart, game.SoundService.Effect)
			end

			instance2.AncestryChanged:Once(function()
				if v6 then
					v6:Destroy()
				end
			end)
		end,
		Slash = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Nanami.RatioBreaker.Attack1.SlashEmit:Clone()
			clone.Weld.Part0 = humanoidRootPart
			clone.Parent = workspace.Effects

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			Debris:AddItem(clone, 1.5)
			local clone2 = utils.Nanami.RatioBreaker.Attack1.SlashBeam:Clone()
			clone2.Weld.Part0 = humanoidRootPart
			clone2.Parent = workspace.Effects
			Debris:AddItem(clone2, 1.5)

			for _, beam in pairs(clone2:GetDescendants()) do
				if beam:IsA("Beam") then
					beam.Enabled = true
				end
			end

			for _, beam in pairs(clone2:GetDescendants()) do
				if not beam:IsA("Beam") then
					continue
				end

				TweenService:Create(beam, TweenInfo.new(0.19), {
					Width0 = 0,
					Width1 = 0
				}):Play()
				local v6 = beam
				task.delay(0.29000000000000004, function()
					v6.Enabled = false
					v6.Width0 = 17
					v6.Width1 = 17
				end)
			end
		end,
		SlashHit = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			local clone = utils.Nanami.RatioBreaker.Attack1.SlashHit:Clone()
			clone.Parent = humanoidRootPart2
			clone.WorldCFrame = CFrame.lookAt(
				humanoidRootPart2.Position,
				(Vector3.new(humanoidRootPart.Position.X, humanoidRootPart2.Position.Y, humanoidRootPart.Position.Z))
			)

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			Debris:AddItem(clone, 1)
			v2:PlaySound(sounds.Nanami.RatioBreaker.RB1.SlashHit, humanoidRootPart, game.SoundService.Effect)
		end,
		WindCharge = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local raycastResult = workspace:Raycast(
				humanoidRootPart.Position,
				createVector(-0, -7.5, -0),
				raycastParams
			)

			if raycastResult then
				for _, model in pairs(utils.Nanami.BluntCut.Charge:GetChildren()) do
					if not model:IsA("Model") then
						continue
					end

					local clone = model:Clone()
					local v6 = SraikoVFX.HandleMesh(
						clone,
						CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
							-1.5707963267948966,
							0,
							0
						)
					)
					clone.Parent = workspace.Effects
					Debris:AddItem(clone, v6)
				end
			end
		end,
		ArmEmit = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			SraikoVFX.Emit(utils.Nanami.RatioBreaker.Attack1.ArmEmit, humanoidRootPart.CFrame)
			v2:PlaySound(sounds.Nanami.RatioBreaker.RB1.Charge, humanoidRootPart, game.SoundService.Effect)
		end,
		Whoosh1 = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Nanami.RatioBreaker.Attack1.BlackFlash.BlackFlash:Clone()
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -8)
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 4)

			for _, emitter in pairs(clone.Black:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") and emitter:GetAttribute("Whiff") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			for _, model in pairs(utils.Nanami.RatioBreaker.Attack1.BlackFlash.Meshes:GetChildren()) do
				if not model:IsA("Model") then
					continue
				end

				local clone2 = model:Clone()
				local v6 = SraikoVFX.HandleMesh(
					clone2,
					humanoidRootPart.CFrame * CFrame.new(0, 0, -6) * CFrame.Angles(0.2617993877991494, 0, 0)
				)
				clone2.Parent = workspace.Effects
				Debris:AddItem(clone2, v6)
			end
		end,
		WhooshUlt = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Nanami.RatioBreaker.Attack1.BlackFlash.BlackFlash:Clone()
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -2.95)
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 4)

			for _, emitter in pairs(clone.Black:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") and emitter:GetAttribute("Whiff") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			for _, model in pairs(utils.Nanami.RatioBreaker.Attack1.BlackFlash.Meshes:GetChildren()) do
				if not model:IsA("Model") then
					continue
				end

				local clone2 = model:Clone()
				local v6 = SraikoVFX.HandleMesh(
					clone2,
					humanoidRootPart.CFrame * CFrame.new(0, 0, -1.25) * CFrame.Angles(0.2617993877991494, 0, 0)
				)
				clone2.Parent = workspace.Effects
				Debris:AddItem(clone2, v6)
			end
		end,
		BlackFlashHit = function(instance, instance2, p)
			local WAIT_INTERVAL = 0.04
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			local raycastResult = workspace:Raycast(
				humanoidRootPart.Position,
				CFrame.lookAt(humanoidRootPart.Position, humanoidRootPart2.Position).LookVector * 11,
				raycastParams
			)
			local distance = raycastResult and raycastResult.Distance or 11
			local clone = utils.Nanami.RatioBreaker.Attack1.BlackFlash.BlackFlash:Clone()
			clone.Position = (CFrame.lookAt(humanoidRootPart.Position, humanoidRootPart2.Position) * CFrame.new(
				0,
				0,
				-distance
			)).Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 2)

			for _, emitter in pairs(clone:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") or emitter:GetAttribute("Whiff") then
					continue
				end

				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end

			local clone2 = utils.Itadori.DivergentFist.BlackFlashHit:Clone()
			clone2.Position = (CFrame.lookAt(humanoidRootPart.Position, humanoidRootPart2.Position) * CFrame.new(
				0,
				0,
				-distance
			)).Position
			clone2.Parent = workspace.Effects
			Debris:AddItem(clone2, 2)
			v2:Flash(instance2, Color3.new(1, 0, 0))
			v2:PlaySound(
				p == 1 and sounds.Nanami.RatioBreaker.RB1.Hit or sounds.Nanami.RatioBreaker.RB2.Hit,
				humanoidRootPart,
				game.SoundService.Effect
			)
			TweenService:Create(clone2.PointLight, TweenInfo.new(1), {
				Brightness = 0
			}):Play()
			task.delay(0.1, function()
				clone2.Blast:Emit(8)
				clone2.Sparks:Emit(15)
				clone2.Lightning:Emit(6)
				clone2.Wind:Emit(7)
			end)
			task.spawn(function()
				local model = Instance.new("Model", workspace.Effects)
				local highlight = Instance.new("Highlight", model)
				highlight.DepthMode = Enum.HighlightDepthMode.Occluded
				highlight.OutlineColor = Color3.new(1, 0, 0)
				highlight.FillColor = Color3.new(0, 0, 0)
				highlight.FillTransparency = 0
				local bodyBackAttachment = instance2.Torso.BodyBackAttachment
				local lastTime = tick()

				repeat
					local attachment = Instance.new("Attachment", humanoidRootPart2)
					local raycastResult2 = workspace:Raycast(
						humanoidRootPart2.Position,
						random:NextUnitVector() * 30,
						raycastParams
					)

					if raycastResult2 then
						attachment.Position = raycastResult2.Position
					else
						attachment.Position = random:NextUnitVector() * 30
					end

					local v6 = LightningBeams.new(bodyBackAttachment, attachment, nil, model)
					v6.Color = Color3.new(1, 0, 0)
					v6.PulseSpeed = 300
					v6.FadeLength = 0.35
					v6.MaxRadius = 20
					v6.MinRadius = 0
					v6.AnimationSpeed = 75
					v6.MinThicknessMultiplier = 0.1
					v6.MaxThicknessMultiplier = 3
					task.delay(0.15, function()
						v6:Destroy()
					end)
					task.wait(0.02)
				until tick() - lastTime > 0.15
			end)

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.Snap):StartFadeOut(1.5)

				if _G.Settings.Flash ~= true then
					return
				end

				local clone3 = utils.Itadori.DivergentFist.BlackFlashCC:Clone()
				clone3.Parent = game.Lighting
				task.wait(WAIT_INTERVAL)
				clone3.TintColor = Color3.new(1, 1, 1)
				task.wait(WAIT_INTERVAL)
				clone3.Brightness = 200
				clone3.Contrast = -1000
				task.wait(WAIT_INTERVAL)
				clone3:Destroy()
			end
		end,
		ArmCharge = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local raycastResult = workspace:Raycast(
				humanoidRootPart.Position,
				createVector(-0, -7.5, -0),
				raycastParams
			)

			if raycastResult then
				local clone = utils.Nanami.RatioBreaker.Attack2.NewSlash:Clone()
				local v6 = SraikoVFX.HandleMesh(
					clone,
					CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
						-1.5707963267948966,
						0,
						0
					)
				)
				clone.Parent = workspace.Effects
				Debris:AddItem(clone, v6)
			end

			SraikoVFX.Emit(utils.Nanami.RatioBreaker.Attack2.ArmEmit, humanoidRootPart.CFrame)
		end,
		Whoosh2 = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Nanami.RatioBreaker.Attack1.BlackFlash.BlackFlash:Clone()
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -1.5)
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 4)

			for _, emitter in pairs(clone.Black:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") and emitter:GetAttribute("Whiff") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			for _, model in pairs(utils.Nanami.RatioBreaker.Attack1.BlackFlash.Meshes:GetChildren()) do
				if not model:IsA("Model") then
					continue
				end

				local clone2 = model:Clone()
				local v6 = SraikoVFX.HandleMesh(
					clone2,
					humanoidRootPart.CFrame * CFrame.new(0, 0, -1) * CFrame.Angles(0.2617993877991494, 0, 0)
				)
				clone2.Parent = workspace.Effects
				Debris:AddItem(clone2, v6)
			end

			CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.MediumHit)
		end,
		Jump = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local raycastResult = workspace:Raycast(
				humanoidRootPart.Position,
				createVector(-0, -7.5, -0),
				raycastParams
			)

			if raycastResult then
				for _, child in pairs(utils.Nanami.RatioBreaker.Attack3.Jump.Meshes:GetChildren()) do
					local clone = child:Clone()
					local v6 = SraikoVFX.HandleMesh(
						clone,
						CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
							-1.5707963267948966,
							0,
							0
						)
					)
					clone.Parent = workspace.Effects
					Debris:AddItem(clone, v6)
				end

				SraikoVFX.Emit(utils.Nanami.RatioBreaker.Attack3.Jump.Whoosh, humanoidRootPart.CFrame)
			end

			v2:PlaySound(sounds.Nanami.RatioBreaker.RB3.Jump, humanoidRootPart, game.SoundService.Effect)

			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < 80 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		JumpHitbox = function(instance, instance2, object)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			if instance == localPlayer.Character then
				repeat
					local raycastResult = workspace:Raycast(
						(humanoidRootPart.CFrame * CFrame.new(0, 0, -2)).Position,
						instance2.Velocity.Unit * math.clamp(instance2.Velocity.Magnitude, 3, 10),
						raycastParams
					)

					if raycastResult then
						object:FireServer(raycastResult.Position, raycastResult.Normal)
						instance2:Destroy()
					end

					task.wait(0.025)
				until not instance2.Parent
			end
		end,
		Slam = function(instance, p, list)
			local WAIT_INTERVAL = 0.04
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Nanami.RatioBreaker.Attack3.Slam.Slam:Clone()
			local model = Instance.new("Model")
			clone.Parent = model
			model:ScaleTo(1.5)
			Debris:AddItem(model, 0.1)
			clone:PivotTo(p * CFrame.Angles(-1.5707963267948966, 0, 0))
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 4)

			for _, emitter in pairs(clone.Black:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") and emitter:GetAttribute("Whiff") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			local clone2 = utils.Megumi.Mahoraga.Earthquake:Clone()
			clone2.CFrame = p * CFrame.Angles(-1.5707963267948966, 0, 0)
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
			clone3.CFrame = p * CFrame.Angles(-1.5707963267948966, 0, 0)
			clone3.Decal.Transparency = 0
			clone3.Mesh.Scale = createVector(2, 50, 2)
			clone3.Parent = clone2
			TweenService:Create(clone3, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
				Size = createVector(80, 40, 80),
				CFrame = clone3.CFrame * CFrame.Angles(0, -3.12413936106985, 0)
			}):Play()
			TweenService:Create(clone3.Mesh, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
				Scale = createVector(60, 10, 60)
			}):Play()
			TweenService:Create(clone3.Decal, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
				Transparency = 1
			}):Play()
			Debris:AddItem(clone3, 1)
			v2:PlaySound(sounds.Nanami.RatioBreaker.RB3.Slam, humanoidRootPart, game.SoundService.Effect)

			for _, child in pairs(utils.Nanami.RatioBreaker.Attack3.Slam.Meshes:GetChildren()) do
				local clone4 = child:Clone()
				local v6 = SraikoVFX.HandleMesh(clone4, p * CFrame.Angles(-1.5707963267948966, 0, 0))
				clone4.Parent = workspace.Effects
				Debris:AddItem(clone4, v6)
			end

			if #list > 0 then
				if (workspace.CurrentCamera.CFrame.Position - p.Position).Magnitude < 150 then
					CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.Snap):StartFadeOut(1.5)
				end

				v2:PlaySound(sounds.Nanami.RatioBreaker.RB3.Hit, humanoidRootPart, game.SoundService.Effect)

				if localPlayer.Character == instance and _G.Settings.Flash == true then
					local clone4 = utils.Itadori.DivergentFist.BlackFlashCC:Clone()
					clone4.Parent = game.Lighting
					task.wait(WAIT_INTERVAL)
					clone4.TintColor = Color3.new(1, 1, 1)
					task.wait(WAIT_INTERVAL)
					clone4.Brightness = 200
					clone4.Contrast = -1000
					task.wait(WAIT_INTERVAL)
					clone4:Destroy()
				end

				for _, emitter in pairs(clone.Black:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") or emitter:GetAttribute("Whiff") then
						continue
					end

					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end

				for _, v6 in pairs(list) do
					if v6 == localPlayer.Character then
						CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.Snap):StartFadeOut(1.5)

						if _G.Settings.Flash == true then
							local clone4 = utils.Itadori.DivergentFist.BlackFlashCC:Clone()
							clone4.Parent = game.Lighting
							task.wait(WAIT_INTERVAL)
							clone4.TintColor = Color3.new(1, 1, 1)
							task.wait(WAIT_INTERVAL)
							clone4.Brightness = 200
							clone4.Contrast = -1000
							task.wait(WAIT_INTERVAL)
							clone4:Destroy()
						end
					end

					local humanoidRootPart2 = v6:FindFirstChild("HumanoidRootPart")
					local clone4 = utils.Itadori.DivergentFist.BlackFlashHit:Clone()
					clone4.Position = humanoidRootPart2.Position
					clone4.Parent = workspace.Effects
					Debris:AddItem(clone4, 2)
					v2:Flash(v6, Color3.new(1, 0, 0))
					TweenService:Create(clone4.PointLight, TweenInfo.new(1), {
						Brightness = 0
					}):Play()
					task.delay(0.1, function()
						clone4.Blast:Emit(8)
						clone4.Sparks:Emit(15)
						clone4.Lightning:Emit(6)
						clone4.Wind:Emit(7)
					end)
				end

				local model2 = Instance.new("Model", workspace.Effects)
				local highlight = Instance.new("Highlight", model2)
				highlight.DepthMode = Enum.HighlightDepthMode.Occluded
				highlight.OutlineColor = Color3.new(1, 0, 0)
				highlight.FillColor = Color3.new(0, 0, 0)
				highlight.FillTransparency = 0
				local rightGripAttachment = instance["Right Arm"].RightGripAttachment
				local lastTime = tick()

				repeat
					local attachment = Instance.new("Attachment", humanoidRootPart)
					local raycastResult = workspace:Raycast(
						humanoidRootPart.Position,
						(random:NextUnitVector() * createVector(1, 0, 1)).Unit * 50,
						raycastParams
					)

					if raycastResult then
						attachment.Position = raycastResult.Position
					else
						attachment.Position = (random:NextUnitVector() * createVector(1, 0, 1)).Unit * 50
					end

					local v6 = LightningBeams.new(rightGripAttachment, attachment, nil, model2)
					v6.Color = Color3.new(1, 0, 0)
					v6.PulseSpeed = 300
					v6.FadeLength = 0.35
					v6.MaxRadius = 10
					v6.MinRadius = 0
					v6.AnimationSpeed = 75
					v6.MinThicknessMultiplier = 0.1
					v6.MaxThicknessMultiplier = 3
					task.delay(0.125, function()
						v6:Destroy()
					end)
					task.wait(0.01)
				until tick() - lastTime > 0.2
			elseif (workspace.CurrentCamera.CFrame.Position - p.Position).Magnitude < 150 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end,
		ArmCharge2 = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			SraikoVFX.Emit(utils.Nanami.RatioBreaker.Attack3.ArmEmit, humanoidRootPart, true)
			v2:PlaySound(sounds.Nanami.RatioBreaker.RB3.Charge, humanoidRootPart, game.SoundService.Effect)
		end,
		RatioBreakerBlackFlash = function(p, instance, position)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Nanami.RatioBreaker.Attack4.BlackFlash:Clone()
			local model = Instance.new("Model")
			clone.Parent = model
			model:ScaleTo(1.6)
			Debris:AddItem(model, 0.1)
			clone.CFrame = CFrame.new(position)
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 10)

			for _, emitter in pairs(clone:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") or emitter:GetAttribute("Whiff") then
					continue
				end

				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end

			if localPlayer.Character == p or instance == localPlayer.Character then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end

			task.spawn(function()
				local model2 = Instance.new("Model", workspace.Effects)
				local highlight = Instance.new("Highlight", model2)
				highlight.DepthMode = Enum.HighlightDepthMode.Occluded
				highlight.OutlineColor = Color3.new(1, 0, 0)
				highlight.FillColor = Color3.new(0, 0, 0)
				highlight.FillTransparency = 0
				local bodyBackAttachment = instance.Torso.BodyBackAttachment
				local lastTime = tick()

				repeat
					local attachment = Instance.new("Attachment", humanoidRootPart)
					local raycastResult = workspace:Raycast(
						humanoidRootPart.Position,
						random:NextUnitVector() * 30,
						raycastParams
					)

					if raycastResult then
						attachment.Position = raycastResult.Position
					else
						attachment.Position = random:NextUnitVector() * 30
					end

					local v6 = LightningBeams.new(bodyBackAttachment, attachment, nil, model2)
					v6.Color = Color3.new(1, 0, 0)
					v6.PulseSpeed = 10
					v6.FadeLength = 0.35
					v6.MaxRadius = 20
					v6.MinRadius = 0
					v6.AnimationSpeed = 5
					v6.MinThicknessMultiplier = 0.1
					v6.MaxThicknessMultiplier = 2
					task.delay(0.1, function()
						v6.AnimationSpeed = 0.5
						v6.PulseSpeed = 5
					end)
					local v8 = v6
					task.delay(1.4500000000000002, function()
						v8.AnimationSpeed = 75
						v8.PulseSpeed = 300
						task.delay(0.125, function()
							v8:Destroy()
						end)
					end)
					task.wait(0.025)
				until tick() - lastTime > 0.15
			end)
			task.wait(0.1)

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.TimeScale = 0.01
				end
			end

			task.wait(1.35)

			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < 80 then
				CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.Snap):StartFadeOut(1.5)
			end

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.TimeScale = 0.7
				end
			end
		end,
		Dash = function(instance, p, p2, _)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local cframe = CFrame.new(p, p2)
			local magnitude = (p - p2).Magnitude
			local clone = utils.Mahito.Dash:Clone()
			clone.CFrame = cframe + cframe.LookVector * magnitude / 2
			clone.Size = Vector3.new(5, 5, magnitude)
			clone.Color = Color3.fromRGB(255, 0, 0)
			clone.Parent = workspace.Effects
			TweenService:Create(clone, TweenInfo.new(0.2), {
				Size = Vector3.new(0, 0, magnitude),
				CFrame = clone.CFrame * CFrame.Angles(0, 0, 3.141592653589793)
			}):Play()
			Debris:AddItem(clone, 0.2)
			local highlight = Instance.new("Highlight", clone)
			highlight.DepthMode = Enum.HighlightDepthMode.Occluded
			highlight.OutlineColor = Color3.new(1, 0, 0)
			highlight.FillColor = Color3.new(0, 0, 0)
			highlight.FillTransparency = 0
			local model = Instance.new("Model")
			local clone2 = replicatedStorage.Utils.Itadori.RushWind:Clone()
			clone2.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -1, 0)
			clone2.Parent = model
			model.Parent = workspace.Effects
			model:ScaleTo(0.6)
			clone2.Ring:Emit(7)
			clone2.Dash1.Dash:Emit(1)
			clone2.Dash2.Dash:Emit(1)
			Debris:AddItem(model, 2)
			local clone3 = utils.Itadori.Shock:Clone()
			clone3.CFrame = cframe * CFrame.Angles(1.5707963267948966, 0, 0)
			clone3.Parent = workspace.Effects
			TweenService:Create(clone3, TweenInfo.new(0.3), {
				Size = createVector(10, 0, 10),
				Transparency = 1
			}):Play()
			Debris:AddItem(clone3, 0.3)
			task.delay(0.075, function()
				local clone4 = utils.Itadori.Shock:Clone()
				clone4.CFrame = cframe * CFrame.Angles(1.5707963267948966, 0, 0) + cframe.LookVector * 3
				clone4.Parent = workspace.Effects
				TweenService:Create(clone4, TweenInfo.new(0.2), {
					Size = createVector(8, 0, 8),
					Transparency = 1
				}):Play()
				Debris:AddItem(clone4, 0.2)
				task.wait(0.075)
				local clone5 = utils.Itadori.Shock:Clone()
				clone5.CFrame = humanoidRootPart.CFrame * CFrame.Angles(1.5707963267948966, 0, 0)
				clone5.Parent = workspace.Effects
				TweenService:Create(clone5, TweenInfo.new(0.2), {
					Size = createVector(8, 0, 8),
					Transparency = 1
				}):Play()
				Debris:AddItem(clone5, 0.2)
			end)
			local model2 = Instance.new("Model", workspace.Effects)
			Debris:AddItem(model2, 5)
			local highlight2 = Instance.new("Highlight", model2)
			highlight2.DepthMode = Enum.HighlightDepthMode.Occluded
			highlight2.OutlineColor = Color3.new(1, 0, 0)
			highlight2.FillColor = Color3.new(0, 0, 0)
			highlight2.FillTransparency = 0
			tick()

			for _ = 1, 5 do
				task.spawn(function()
					local attachment = Instance.new("Attachment", workspace.Terrain)
					attachment.WorldPosition = p + random:NextUnitVector() * 5
					local attachment2 = Instance.new("Attachment", workspace.Terrain)
					attachment2.WorldPosition = p2 + random:NextUnitVector() * 5
					Debris:AddItem(attachment, 5)
					Debris:AddItem(attachment2, 5)
					local v6 = LightningBeams.new(attachment2, attachment, nil, model2)
					v6.Color = Color3.new(1, 0, 0)
					v6.PulseSpeed = 5
					v6.FadeLength = 0.35
					v6.MaxRadius = 10
					v6.MinRadius = 0
					v6.AnimationSpeed = 1
					v6.MinThicknessMultiplier = 0.1
					v6.MaxThicknessMultiplier = 1.5
					task.wait(0.1)
					v6.PulseSpeed = 25
					v6.AnimationSpeed = 5

					for _ = 1, 12 do
						v6.Thickness *= 0.85
						v6.PulseSpeed *= 0.85
						v6.MaxRadius *= 0.85
						task.wait(0.020833333333333332)
					end

					v6:Destroy()
				end)
			end

			if instance == localPlayer.Character then
				CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.Snap):StartFadeOut(1)
			end

			v2:PlaySound(sounds.Nanami.RatioBreaker.RB4.Dash, humanoidRootPart, game.SoundService.Effect)
		end,
		RatioBreakerHit = function(instance, instance2, _)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			if instance ~= localPlayer.Character and instance2 ~= localPlayer.Character then
				v2:PlaySound(sounds.Nanami.RatioBreaker.RB4.Hit, humanoidRootPart2, game.SoundService.Effect)
				return
			end

			v2:PlaySound(sounds.Nanami.RatioBreaker.RB4.Hit, workspace, game.SoundService.Effect)
			local currentCamera = workspace.CurrentCamera
			task.spawn(function()
				local WAIT_INTERVAL = 0.04
				local screenGui = Instance.new("ScreenGui")
				screenGui.IgnoreGuiInset = true
				screenGui.Parent = localPlayer.PlayerGui
				local frame = Instance.new("Frame")
				frame.BackgroundTransparency = 0
				frame.BackgroundColor3 = Color3.new(0, 0, 0)
				frame.AnchorPoint = Vector2.new(0.5, 0.5)
				frame.Size = UDim2.fromScale(1, 1)
				frame.Position = UDim2.fromScale(0.5, 0.5)
				frame.Parent = screenGui
				local clone = game.ReplicatedStorage.Utils.Nanami.Ratio.Bar:Clone()
				clone.Parent = frame
				local _ = clone.Cursor
				clone.Rotation = -140
				clone.Size = UDim2.fromScale(0.24, 3.5999999999999996)
				TweenService:Create(
					clone,
					TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Rotation = 80,
						Size = UDim2.fromScale(0.16, 2.4),
						Position = UDim2.fromScale(0.6, 0.45)
					}
				):Play()
				task.wait(0.2)
				frame.BackgroundColor3 = Color3.new(1, 1, 1)
				clone.Bar.ImageColor3 = Color3.new(0, 0, 0)
				clone.Cursor.Visible = false
				clone.Hit2.Visible = true
				task.wait(0.15)
				local lastTime = tick()
				local screenGui2 = Instance.new("ScreenGui")
				screenGui2.ResetOnSpawn = false
				screenGui2.IgnoreGuiInset = true

				for i = 1, #v4, 2 do
					local imageLabel = Instance.new("ImageLabel")
					imageLabel.Name = tostring(i)
					imageLabel.Image = v4[i]
					imageLabel.Size = UDim2.new(0, 1, 0, 1)
					imageLabel.BackgroundColor3 = Color3.new(0, 0, 0)
					imageLabel.Parent = screenGui2
				end

				screenGui2.Parent = localPlayer.PlayerGui

				for i = 1, #v4, 2 do
					screenGui2[tostring(i)].Size = UDim2.new(1, 0, 1, 0)

					if i ~= 1 then
						screenGui2[tostring(i - 2)]:Destroy()
					end

					repeat
						task.wait()
					until tick() - lastTime >= 0.041666666666666664

					lastTime = tick()
				end

				CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.HeavyHit):StartFadeOut(3)
				screenGui2:Destroy()
				screenGui:Destroy()
				local clone2 = utils.Nanami.RatioBreaker.Attack4.HitEnd:Clone()
				clone2.CFrame = humanoidRootPart2.CFrame
				clone2.Parent = workspace.Effects
				clone2.BloodParticle:Emit(70)
				Debris:AddItem(clone2, 2)

				if _G.Settings.Flash == true then
					local clone3 = utils.Itadori.DivergentFist.BlackFlashCC:Clone()
					clone3.Parent = game.Lighting
					task.wait(WAIT_INTERVAL)
					clone3.TintColor = Color3.new(1, 1, 1)
					task.wait(WAIT_INTERVAL)
					clone3.Brightness = 200
					clone3.Contrast = -1000
					task.wait(WAIT_INTERVAL)
					clone3:Destroy()
				end

				clone2.BloodParticle.TimeScale = 0.075
				local tweenInfo = TweenInfo.new(1.6, Enum.EasingStyle.Circular, Enum.EasingDirection.In)

				for _, effect in clone2:GetDescendants() do
					if effect:IsA("ParticleEmitter") then
						TweenService:Create(effect, tweenInfo, {
							TimeScale = 1
						}):Play()
					elseif effect:IsA("Beam") then
						TweenService:Create(effect, tweenInfo, {
							Width0 = 0,
							Width1 = 0,
							TextureSpeed = effect.TextureSpeed * 5
						}):Play()
					end
				end
			end)

			if localPlayer.Character == instance2 then
				local clone = utils.Nanami.OvertimeAura.Music:Clone()
				clone.Parent = humanoidRootPart
				clone.SoundGroup = game.SoundService.Music
				clone.TimePosition = 38.3
				clone:Play()
				task.delay(2, function()
					TweenService:Create(clone, TweenInfo.new(1), {
						Volume = 0
					}):Play()
				end)
			end

			task.wait(0.6)
			local total = 0
			local renderSteppedConnection = nil
			tick()
			local cutsceneFrames = utils.Nanami.RatioBreaker.Attack4.CutsceneFrames
			renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
				local WAIT_INTERVAL = 0.04
				local v6 = dt * 60
				total += v6
				local child = cutsceneFrames.Frames:FindFirstChild((tonumber((math.ceil(total)))))
				local child2 = cutsceneFrames.FOV:FindFirstChild((tonumber((math.ceil(total)))))

				if child and child2 and instance.Parent and humanoidRootPart then
					currentCamera.CFrame = humanoidRootPart.CFrame * child.Value
					currentCamera.FieldOfView = child2.Value
					currentCamera.CameraType = Enum.CameraType.Scriptable
				else
					renderSteppedConnection:Disconnect()
					currentCamera.CameraType = Enum.CameraType.Custom
					currentCamera.FieldOfView = 70
					currentCamera.CameraSubject = (localPlayer.Character or localPlayer.CharacterAdded:Wait()):WaitForChild("Humanoid")
					currentCamera.FieldOfView = 70
					game.Lighting.ExposureCompensation = 2
					TweenService:Create(game.Lighting, TweenInfo.new(1), {
						ExposureCompensation = 0
					}):Play()
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)

					if _G.Settings.Flash == true then
						local clone = utils.Itadori.DivergentFist.BlackFlashCC:Clone()
						clone.Parent = game.Lighting
						task.wait(WAIT_INTERVAL)
						clone.TintColor = Color3.new(1, 1, 1)
						task.wait(WAIT_INTERVAL)
						clone.Brightness = 200
						clone.Contrast = -1000
						task.wait(WAIT_INTERVAL)
						clone:Destroy()
					end
				end
			end)
		end,
		RatioBreakerFinisher = function(instance)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			v2:Bleed(instance)
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
	v = Knit.GetService("RatioBreakerService")
	v3 = Knit.GetController("HitboxController")
	v2 = Knit.GetController("FXController")
end

return controller