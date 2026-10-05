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
local v = nil
local v2 = nil
local SraikoVFX = require(replicatedStorage.Modules.SraikoVFX)
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map, workspace.Domains }
local random = Random.new()
local controller = Knit.CreateController({
	Name = "CirclingController"
})

function controller.KnitStart(_)
	local v3 = nil
	v3 = {
		Crush = function(_, position, p)
			local v4 = 0.8 + 0.2 * p
			local clone = utils.Hiromi.Shockwave:Clone()
			local model = Instance.new("Model")
			clone.Parent = model
			model:ScaleTo(v4)
			Debris:AddItem(model, 0.1)
			clone.Position = position
			clone.Parent = workspace.Effects
			clone.CFrame *= CFrame.Angles(0, math.rad((math.random(-179, 179))), 0)
			TweenService:Create(clone.mesh.Mesh, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
				Scale = createVector(15, 0, 15) * v4
			}):Play()
			TweenService:Create(clone.mesh.Decal, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
				Transparency = 1
			}):Play()
			clone.Floor.Glow:Emit(1)
			clone.Floor.Ring:Emit(10)
			Debris:AddItem(clone, 1.5)
			local clone2 = utils.Choso.CounterSwing.Shock:Clone()
			local model2 = Instance.new("Model")
			clone2.Parent = model2
			model2:ScaleTo(v4)
			Debris:AddItem(model2, 0.1)
			clone2.Size = createVector(10, 30, 10) * v4
			clone2.CFrame = CFrame.new(position)
			clone2.Parent = workspace.Effects
			Debris:AddItem(clone2, 0.3)
			TweenService:Create(clone2, TweenInfo.new(0.3), {
				Size = createVector(36, 7, 36) * v4,
				Transparency = 1,
				Position = clone2.Position - createVector(0, 3, 0)
			}):Play()
			local clone3 = utils.Choso.CounterSwing.Shock:Clone()
			clone3.Size = createVector(20, 10, 20) * v4
			clone3.CFrame = CFrame.new(position)
			clone3.Parent = workspace.Effects
			Debris:AddItem(clone3, 0.2)
			TweenService:Create(clone3, TweenInfo.new(0.2), {
				Size = createVector(0, 36, 0),
				Transparency = 1,
				Position = clone3.Position + createVector(0, 10, 0)
			}):Play()
			v2:DustBreak(position + createVector(0, 2, 0), createVector(0, 1, 0), 6, 15, 0.4, 1)
			v2:PlaySound(sounds.MeiMei.Crush, clone, game.SoundService.Effect)

			if (workspace.CurrentCamera.CFrame.Position - position).Magnitude < 60 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end,
		DivebombWhoosh = function(p)
			local humanoidRootPart = p.HumanoidRootPart

			if not (humanoidRootPart and p.SetAssets:FindFirstChild("MeiMeiAxe")) then
				return
			end

			v2:PlaySound(sounds.MeiMei.Circling.AirSlash, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.MeiMei.Circling.MeiMeiWideSlash3:Clone()
			clone.Weld.Part0 = humanoidRootPart
			clone.Weld.C0 = CFrame.new(0, -1, 0) * CFrame.Angles(0, 0, 3.141592653589793)
			v2:PlayParticles(clone)
			clone.Parent = workspace.Effects
			task.delay(0.25, function()
				clone.Weld:Destroy()
				clone.Anchored = true
			end)
			Debris:AddItem(clone, 1.5)

			for i = 1, 2 do
				local v4 = i == 2 and 180 or 0
				local clone2 = utils.MeiMei.Circling.SwingMesh:Clone()
				clone2.Transparency = 0.05
				clone2.Mesh.Scale = createVector(0.15, 1, 0.15)
				clone2.Mesh.VertexColor = createVector(1.5, 1.5, 2.25)
				clone2.Weld.Part0 = humanoidRootPart
				clone2.Weld.C0 = CFrame.new(0, -1, 0) * CFrame.Angles(
					3.141592653589793,
					1.5707963267948966,
					3.141592653589793
				) * CFrame.Angles(0, 1.0471975511965976, 0) * CFrame.Angles(0, math.rad(v4), 0)
				TweenService:Create(clone2.Weld, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
					C0 = clone2.Weld.C0 * CFrame.Angles(0, 3.1066860685499065, 0)
				}):Play()
				TweenService:Create(clone2.Mesh, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Scale = createVector(0.5, 0.25, 0.5)
				}):Play()
				TweenService:Create(clone2.Mesh, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					VertexColor = createVector(0.5, 0.5, 0.75)
				}):Play()
				TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
					Transparency = 1
				}):Play()
				clone2.Parent = workspace.Effects
				Debris:AddItem(clone2, 0.25)
			end

			local clone2 = utils.MeiMei.Circling.WindMesh2:Clone()
			clone2.Weld.Part0 = humanoidRootPart
			clone2.Weld.C0 = CFrame.new(0, -2, 0) * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
			clone2.Transparency = 0.95
			clone2.Size = createVector(10, 2.5, 10)
			TweenService:Create(clone2, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = createVector(35, 15, 35),
				Transparency = 1
			}):Play()
			TweenService:Create(clone2.Weld, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				C0 = clone2.Weld.C0 * CFrame.new(0, -0.5, 0) * CFrame.Angles(0, -3.12413936106985, 0)
			}):Play()
			clone2.Parent = workspace.Effects
			Debris:AddItem(clone2, 0.15)
		end,
		DivebombFall = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local v4 = {}
			local Cleanup

			Cleanup = function(list)
				for i = #list, 1, -1 do
					local animationTrack = list[i]

					if not animationTrack then
						continue
					end

					table.remove(list, i)

					if typeof(animationTrack) == "RBXScriptConnection" then
						animationTrack:Disconnect()
					elseif type(animationTrack) == "function" then
						pcall(animationTrack)
					elseif animationTrack:IsA("AnimationTrack") then
						animationTrack:Stop()
					else
						animationTrack:Destroy()
					end
				end

				task.defer(function()
					if #list <= 0 then
						return
					end

					Cleanup(list)
				end)
			end

			instance2.AncestryChanged:Connect(function()
				Cleanup(v4)
			end)
			local v5 = v2:PlaySound(sounds.MeiMei.Fall, humanoidRootPart, game.SoundService.Effect)
			table.insert(v4, function()
				if v5 and v5.Parent then
					Debris:AddItem(v5, 0.5)
					TweenService:Create(v5, TweenInfo.new(0.5), {
						Volume = 0
					}):Play()
				end
			end)
			local clone = replicatedStorage.Utils.MeiMei.FallStage1:Clone()
			table.insert(v4, clone)
			clone.Weld.Part0 = humanoidRootPart
			clone.Weld.C0 = CFrame.new(0, -2, 0)

			for _, child in clone.Attachment:GetChildren() do
				child.Enabled = true
			end

			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 30)
			local clone2 = replicatedStorage.Utils.MeiMei.AxeWindTrail:Clone()
			table.insert(v4, clone2)
			clone2.Weld.Part0 = instance.SetAssets.MeiMeiAxe.Axe
			clone2.Parent = workspace.Effects
			Debris:AddItem(clone2, 30)
			clone2.Transparency = 0.9
			TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()

			repeat
				local number = random:NextNumber(0.85, 1.15)
				local v6 = 0.25 * number
				local clone3 = replicatedStorage.Utils.MeiMei.Circling.WindMesh1:Clone()
				table.insert(v4, clone3)
				clone3.Decal.Transparency = 0.9
				clone3.Mesh.Scale = createVector(0.15, 0.25, 0.25) * number
				clone3.CFrame = humanoidRootPart.CFrame * CFrame.Angles(0, 0, 1.5707963267948966) * CFrame.new(
					-2 * number,
					0,
					0
				) * CFrame.Angles(math.rad((math.random(-180, 180))), 0, 0)
				clone3.Parent = workspace.Effects
				TweenService:Create(clone3, TweenInfo.new(v6, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
					CFrame = clone3.CFrame * CFrame.new(-15 * number, 0, 0) * CFrame.Angles(-3.12413936106985, 0, 0)
				}):Play()
				TweenService:Create(clone3.Mesh, TweenInfo.new(v6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					Scale = createVector(0.5, 0.2, 0.2) * number
				}):Play()
				TweenService:Create(clone3.Decal, TweenInfo.new(v6, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
					Transparency = 1
				}):Play()
				Debris:AddItem(clone3, v6)
				task.wait(0.175)
			until instance2.Value ~= 1 or humanoidRootPart.Parent == nil or instance.Parent == nil or instance2.Parent == nil

			if humanoidRootPart.Parent == nil or instance.Parent == nil or instance2.Parent == nil then
				return
			end

			for _, child in clone.Attachment:GetChildren() do
				child.Enabled = false
			end

			clone.Weld:Destroy()
			Debris:AddItem(clone, 0.5)

			if instance2.Value == 2 then
				local clone3 = replicatedStorage.Utils.MeiMei.FallStage2:Clone()
				table.insert(v4, clone3)
				clone3.Weld.Part0 = humanoidRootPart
				clone3.Weld.C0 = CFrame.new(0, -2, 0)

				for _, child in clone3.Attachment:GetChildren() do
					child.Enabled = true
				end

				clone3.Parent = workspace.Effects
				clone2.Transparency = 0.8
				TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					Transparency = 1
				}):Play()
				clone2.Trail.Lifetime = 0.075
				clone2.Trail.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.8),
					NumberSequenceKeypoint.new(1, 1)
				})
				local clone4 = replicatedStorage.Utils.MeiMei.Circling.WindMesh1:Clone()
				table.insert(v4, clone4)
				clone4.Decal.Transparency = 0.5
				clone4.Mesh.Scale = createVector(0.15, 0.15, 0.15)
				clone4.CFrame = humanoidRootPart.CFrame * CFrame.Angles(0, 0, 1.5707963267948966) * CFrame.new(-4, 0, 0) * CFrame.Angles(
					math.rad((math.random(-180, 180))),
					0,
					0
				)
				clone4.Parent = workspace.Effects
				TweenService:Create(clone4, TweenInfo.new(0.35, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
					CFrame = clone4.CFrame * CFrame.new(-10, 0, 0) * CFrame.Angles(-3.12413936106985, 0, 0)
				}):Play()
				TweenService:Create(clone4.Mesh, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					Scale = createVector(0.1, 0.75, 0.75)
				}):Play()
				TweenService:Create(
					clone4.Decal,
					TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Transparency = 1
					}
				):Play()
				Debris:AddItem(clone4, 0.35)
				local clone5 = replicatedStorage.Utils.MeiMei.Circling.WindMesh1:Clone()
				table.insert(v4, clone5)
				clone5.Decal.Transparency = 0.5
				clone5.Mesh.Scale = createVector(1, 0.15, 0.15)
				clone5.CFrame = humanoidRootPart.CFrame * CFrame.Angles(0, 0, 1.5707963267948966) * CFrame.new(0, 0, 0) * CFrame.Angles(
					math.rad((math.random(-180, 180))),
					0,
					0
				)
				clone5.Parent = workspace.Effects
				TweenService:Create(clone5, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					CFrame = clone5.CFrame * CFrame.new(-10, 0, 0) * CFrame.Angles(-3.12413936106985, 0, 0)
				}):Play()
				TweenService:Create(clone5.Mesh, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					Scale = createVector(0.05, 0.75, 0.75)
				}):Play()
				TweenService:Create(
					clone5.Decal,
					TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Transparency = 1
					}
				):Play()
				Debris:AddItem(clone5, 0.35)

				repeat
					local number = random:NextNumber(0.85, 1.15)
					local v6 = 0.25 * number
					local clone6 = replicatedStorage.Utils.MeiMei.Circling.WindMesh3:Clone()
					table.insert(v4, clone6)
					clone6.Decal.Transparency = 0.9
					clone6.Mesh.Scale = createVector(0.15, 0.25, 0.25) * number
					clone6.CFrame = humanoidRootPart.CFrame * CFrame.Angles(0, 0, 1.5707963267948966) * CFrame.new(
						-2 * number,
						0,
						0
					) * CFrame.Angles(math.rad((math.random(-180, 180))), 0, 0)
					clone6.Parent = workspace.Effects
					TweenService:Create(clone6, TweenInfo.new(v6, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
						CFrame = clone6.CFrame * CFrame.new(-15 * number, 0, 0) * CFrame.Angles(-3.12413936106985, 0, 0)
					}):Play()
					TweenService:Create(
						clone6.Mesh,
						TweenInfo.new(v6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
						{
							Scale = createVector(0.35, 0.3, 0.3) * number
						}
					):Play()
					TweenService:Create(
						clone6.Decal,
						TweenInfo.new(v6, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					):Play()
					Debris:AddItem(clone6, v6)
					local number2 = random:NextNumber(0.85, 1.15)
					local clone7 = replicatedStorage.Utils.MeiMei.Circling.WindMesh1:Clone()
					table.insert(v4, clone7)
					clone7.Decal.Transparency = 0.9
					clone7.Mesh.Scale = createVector(0.25, 0.25, 0.25) * number2
					clone7.CFrame = humanoidRootPart.CFrame * CFrame.Angles(0, 0, 1.5707963267948966) * CFrame.new(
						-5 * number2,
						0,
						0
					) * CFrame.Angles(math.rad((math.random(-180, 180))), 0, 0)
					clone7.Parent = workspace.Effects
					TweenService:Create(
						clone7,
						TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							CFrame = clone7.CFrame * CFrame.new(2 * number2, 0, 0) * CFrame.Angles(
								-3.12413936106985,
								0,
								0
							)
						}
					):Play()
					TweenService:Create(
						clone7.Mesh,
						TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Scale = createVector(0.2, 0.4, 0.4) * number2
						}
					):Play()
					TweenService:Create(
						clone7.Decal,
						TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					):Play()
					Debris:AddItem(clone7, 0.15)
					task.wait(0.1)
				until instance2.Value ~= 2 or humanoidRootPart.Parent == nil or instance.Parent == nil or instance2.Parent == nil

				if humanoidRootPart.Parent == nil or instance.Parent == nil or instance2.Parent == nil then
					return
				end

				for _, child in clone3.Attachment:GetChildren() do
					child.Enabled = false
				end

				clone3.Weld:Destroy()
				Debris:AddItem(clone3, 0.75)

				if instance2.Value == 3 then
					local clone6 = replicatedStorage.Utils.MeiMei.FallStage3:Clone()
					table.insert(v4, clone6)
					clone6.Weld.Part0 = humanoidRootPart
					clone6.Weld.C0 = CFrame.new(0, -2, 0)

					for _, child in clone6.Attachment:GetChildren() do
						child.Enabled = true
					end

					clone6.Parent = workspace.Effects
					clone2.Transparency = 0.25
					TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
						Transparency = 1
					}):Play()
					clone2.Trail.Lifetime = 0.1
					clone2.Trail.Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0.75),
						NumberSequenceKeypoint.new(1, 1)
					})
					local clone7 = replicatedStorage.Utils.MeiMei.Circling.WindMesh3:Clone()
					table.insert(v4, clone7)
					clone7.Decal.Transparency = 0.5
					clone7.Mesh.Scale = createVector(0.15, 0.25, 0.25)
					clone7.CFrame = humanoidRootPart.CFrame * CFrame.Angles(0, 0, 1.5707963267948966) * CFrame.new(
						-2,
						0,
						0
					) * CFrame.Angles(math.rad((math.random(-180, 180))), 0, 0)
					clone7.Parent = workspace.Effects
					TweenService:Create(
						clone7,
						TweenInfo.new(0.35, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							CFrame = clone7.CFrame * CFrame.new(-15, 0, 0) * CFrame.Angles(-3.12413936106985, 0, 0)
						}
					):Play()
					TweenService:Create(
						clone7.Mesh,
						TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
						{
							Scale = createVector(0.5, 0.35, 0.35)
						}
					):Play()
					TweenService:Create(
						clone7.Decal,
						TweenInfo.new(0.35, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					):Play()
					Debris:AddItem(clone7, 0.35)
					local clone8 = replicatedStorage.Utils.MeiMei.Circling.WindMesh1:Clone()
					table.insert(v4, clone8)
					clone8.Decal.Transparency = 0.5
					clone8.Mesh.Scale = createVector(0.35, 0.35, 0.35)
					clone8.CFrame = humanoidRootPart.CFrame * CFrame.Angles(0, 0, 1.5707963267948966) * CFrame.new(
						-5,
						0,
						0
					) * CFrame.Angles(math.rad((math.random(-180, 180))), 0, 0)
					clone8.Parent = workspace.Effects
					TweenService:Create(
						clone8,
						TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							CFrame = clone8.CFrame * CFrame.new(2, 0, 0) * CFrame.Angles(-3.12413936106985, 0, 0)
						}
					):Play()
					TweenService:Create(
						clone8.Mesh,
						TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Scale = createVector(0.15, 0.5, 0.5)
						}
					):Play()
					TweenService:Create(
						clone8.Decal,
						TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					):Play()
					Debris:AddItem(clone8, 0.25)

					repeat
						local number = Random.new():NextNumber(0.85, 1.15)
						local v6 = 0.15 * number
						local clone9 = replicatedStorage.Utils.MeiMei.Shock:Clone()
						table.insert(v4, clone9)
						clone9.Transparency = 0.95
						clone9.Size = vector.create(10, 10 * number, 10)
						clone9.CFrame = humanoidRootPart.CFrame * CFrame.Angles(0, 0, 0) * CFrame.new(0, -5 * number, 0) * CFrame.Angles(
							0,
							math.rad((math.random(-180, 180))),
							0
						)
						clone9.Parent = workspace.Effects
						TweenService:Create(
							clone9,
							TweenInfo.new(v6, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
							{
								CFrame = clone9.CFrame * CFrame.new(2 * number, 0, 0) * CFrame.Angles(
									0,
									-3.12413936106985,
									0
								),
								Size = vector.create(30, 20 * number, 30),
								Transparency = 1
							}
						):Play()
						Debris:AddItem(clone9, v6)
						local v7 = 0.25 * number
						local clone10 = replicatedStorage.Utils.MeiMei.Circling.WindMesh3:Clone()
						table.insert(v4, clone10)
						clone10.Decal.Transparency = 0.9
						clone10.Mesh.Scale = createVector(0.15, 0.25, 0.25) * number
						clone10.CFrame = humanoidRootPart.CFrame * CFrame.Angles(0, 0, 1.5707963267948966) * CFrame.new(
							-2 * number,
							0,
							0
						) * CFrame.Angles(math.rad((math.random(-180, 180))), 0, 0)
						clone10.Parent = workspace.Effects
						TweenService:Create(
							clone10,
							TweenInfo.new(v7, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
							{
								CFrame = clone10.CFrame * CFrame.new(-15 * number, 0, 0) * CFrame.Angles(
									-3.12413936106985,
									0,
									0
								)
							}
						):Play()
						TweenService:Create(
							clone10.Mesh,
							TweenInfo.new(v7, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
							{
								Scale = createVector(0.5, 0.35, 0.35) * number
							}
						):Play()
						TweenService:Create(
							clone10.Decal,
							TweenInfo.new(v7, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
							{
								Transparency = 1
							}
						):Play()
						Debris:AddItem(clone10, v7)
						local number2 = Random.new():NextNumber(0.85, 1.15)
						local clone11 = replicatedStorage.Utils.MeiMei.Circling.WindMesh1:Clone()
						table.insert(v4, clone10)
						clone11.Decal.Transparency = 0.9
						clone11.Mesh.Scale = createVector(0.35, 0.35, 0.35) * number2
						clone11.CFrame = humanoidRootPart.CFrame * CFrame.Angles(0, 0, 1.5707963267948966) * CFrame.new(
							-5 * number2,
							0,
							0
						) * CFrame.Angles(math.rad((math.random(-180, 180))), 0, 0)
						clone11.Parent = workspace.Effects
						TweenService:Create(
							clone11,
							TweenInfo.new(0.35, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
							{
								CFrame = clone11.CFrame * CFrame.new(6, 0, 0) * CFrame.Angles(-3.12413936106985, 0, 0)
							}
						):Play()
						TweenService:Create(
							clone11.Mesh,
							TweenInfo.new(0.35, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
							{
								Scale = createVector(0.15, 0.6, 0.6) * number2
							}
						):Play()
						TweenService:Create(
							clone11.Decal,
							TweenInfo.new(0.35, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
							{
								Transparency = 1
							}
						):Play()
						Debris:AddItem(clone11, 0.35)
						task.wait(0.05)
					until instance2.Value ~= 3 or humanoidRootPart.Parent == nil or instance.Parent == nil or instance2.Parent == nil

					if humanoidRootPart.Parent == nil or instance.Parent == nil or instance2.Parent == nil then
						return
					end

					for _, child in clone6.Attachment:GetChildren() do
						child.Enabled = false
					end

					clone6.Weld:Destroy()
					Debris:AddItem(clone6, 0.5)
				end
			end

			clone2:Destroy()
		end,
		Start = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.MeiMei.Circling.Start, humanoidRootPart, game.SoundService.Effect)
		end,
		Charge = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local v4 = 0

			if p == 1 then
				v2:PlaySound(sounds.MeiMei.Circling.Charge1, humanoidRootPart, game.SoundService.Effect)
				v2:Flash(instance, Color3.new(1, 0.666667, 0), 0.45)
				v4 = 0.9
			elseif p == 2 then
				v2:PlaySound(sounds.MeiMei.Circling.Charge2, humanoidRootPart, game.SoundService.Effect)
				v2:Flash(instance, Color3.new(1, 0, 0), 0.45)
				v4 = 1.15
			end

			local raycastResult = workspace:Raycast(
				(humanoidRootPart.CFrame * CFrame.new(0, 0, 1)).Position,
				createVector(-0, -8, -0),
				raycastParams
			)

			if raycastResult then
				for _, model in pairs(utils.Nanami.BluntCut.Charge:GetChildren()) do
					if not model:IsA("Model") then
						continue
					end

					local clone = model:Clone()
					clone:ScaleTo(v4)
					local v5 = SraikoVFX.HandleMesh(
						clone,
						CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
							-1.5707963267948966,
							0,
							0
						)
					)
					clone.Parent = workspace.Effects
					Debris:AddItem(clone, v5)
				end
			end
		end,
		Slash = function(p)
			local humanoidRootPart = p.HumanoidRootPart

			if not (humanoidRootPart and p.SetAssets:FindFirstChild("MeiMeiAxe")) then
				return
			end

			v2:PlaySound(sounds.MeiMei.Circling.Slash1, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.MeiMei.Circling.MeiMeiWideSlash1:Clone()
			clone.Weld.Part0 = humanoidRootPart
			clone.Weld.C0 = CFrame.Angles(0, 0, 3.141592653589793)
			v2:PlayParticles(clone)
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1.5)
			local clone2 = utils.MeiMei.Circling.SwingMesh:Clone()
			clone2.Transparency = 0.05
			clone2.Mesh.Scale = createVector(0.15, 1, 0.15)
			clone2.Mesh.VertexColor = createVector(1.5, 1.5, 2.25)
			clone2.Weld.Part0 = humanoidRootPart
			clone2.Weld.C0 = CFrame.Angles(3.141592653589793, 1.5707963267948966, 3.141592653589793) * CFrame.Angles(
				0,
				1.0471975511965976,
				0
			)
			TweenService:Create(clone2.Weld, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
				C0 = clone2.Weld.C0 * CFrame.Angles(0, 3.1066860685499065, 0)
			}):Play()
			TweenService:Create(clone2.Mesh, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Scale = createVector(0.5, 0.25, 0.5)
			}):Play()
			TweenService:Create(
				clone2.Mesh,
				TweenInfo.new(0.16666666666666666, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
				{
					VertexColor = createVector(0.5, 0.5, 0.75)
				}
			):Play()
			TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
				Transparency = 1
			}):Play()
			clone2.Parent = workspace.Effects
			Debris:AddItem(clone2, 0.25)
			local clone3 = utils.MeiMei.Circling.WindMesh2:Clone()
			clone3.Weld.Part0 = humanoidRootPart
			clone3.Weld.C0 = CFrame.new(0, -2, 0) * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
			clone3.Transparency = 0.95
			clone3.Size = createVector(10, 2.5, 10)
			TweenService:Create(clone3, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = createVector(35, 15, 35),
				Transparency = 1
			}):Play()
			TweenService:Create(clone3.Weld, TweenInfo.new(0.35, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				C0 = clone3.Weld.C0 * CFrame.new(0, 0.5, 0) * CFrame.Angles(0, 3.12413936106985, 0)
			}):Play()
			clone3.Parent = workspace.Effects
		end,
		Slash2 = function(p, p2)
			local humanoidRootPart = p.HumanoidRootPart

			if not humanoidRootPart then
				return
			end

			if p2 == nil then
				v2:PlaySound(sounds.MeiMei.Circling.Slash2, humanoidRootPart, game.SoundService.Effect)
			end

			if not p.SetAssets:FindFirstChild("MeiMeiAxe") then
				return
			end

			local clone = utils.MeiMei.Circling.MeiMeiWideSlash2:Clone()
			clone.Weld.Part0 = humanoidRootPart
			clone.Weld.C0 = CFrame.Angles(0, 0, 2.792526803190927) * CFrame.Angles(0, 3.141592653589793, 0)
			clone.Weld.C1 *= CFrame.Angles(-0.17453292519943295, 0, 0)
			v2:PlayParticles(clone)
			clone.Parent = workspace.Effects
			Debris:AddItem(clone.Weld, 0.5)
			Debris:AddItem(clone, 2)
			local clone2 = utils.MeiMei.Circling.SwingMesh:Clone()
			clone2.Transparency = 0.75
			clone2.Mesh.Scale = createVector(0.25, 2.5, 0.25)
			clone2.Mesh.VertexColor = createVector(1, 1, 1.5)
			clone2.Weld.Part0 = humanoidRootPart
			clone2.Weld.C1 *= CFrame.Angles(0.08726646259971647, 0, 0)
			clone2.Weld.C0 = CFrame.Angles(3.141592653589793, 1.5707963267948966, 3.141592653589793) * CFrame.Angles(
				0.3490658503988659,
				0,
				0
			)
			TweenService:Create(clone2.Weld, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
				C0 = clone2.Weld.C0 * CFrame.Angles(0, 3.1066860685499065, 0)
			}):Play()
			TweenService:Create(clone2.Mesh, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Scale = createVector(0.5175, 0.575, 0.5175)
			}):Play()
			TweenService:Create(clone2, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
				Transparency = 1
			}):Play()
			clone2.Parent = workspace.Effects
			Debris:AddItem(clone2, 0.2)
			local clone3 = utils.MeiMei.Circling.WindMesh2:Clone()
			clone3.Weld.Part0 = humanoidRootPart
			clone3.Weld.C0 = CFrame.new(0, -1, 0) * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
			clone3.Transparency = 0.985
			clone3.Size = createVector(20, 7.5, 20)
			TweenService:Create(clone3, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				Size = createVector(45, 10, 45),
				Transparency = 1
			}):Play()
			TweenService:Create(clone3.Weld, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				C0 = clone3.Weld.C0 * CFrame.new(0, 0.5, 0) * CFrame.Angles(0, 3.12413936106985, 0)
			}):Play()
			clone3.Parent = workspace.Effects
			Debris:AddItem(clone3, 0.5)
			task.delay(0.25, function()
				clone.Weld:Destroy()
				clone.Anchored = true
				clone3.Weld:Destroy()
				clone3.Anchored = true
			end)
		end,
		Slash3 = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			if localPlayer.Character == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end

			v3.Slash2(p, true)
			v2:PlaySound(sounds.MeiMei.Circling.FinisherWhoosh, humanoidRootPart, game.SoundService.Effect)
		end,
		Hit1 = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.MeiMei.Circling.Hit1, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Hit2 = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.MeiMei.Circling.Hit2, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end,
		Hit3 = function(p, instance, p2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Mahito.CrushingRushdown.DrillImpact:Clone()
			clone.Position = humanoidRootPart.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			clone.Sparks.Color = ColorSequence.new(Color3.new(0.513725, 0.643137, 1))
			clone.Wind.Color = clone.Sparks.Color
			clone.Wind2.Color = clone.Sparks.Color
			clone.Sparks:Emit(30)
			clone.Wind2:Emit(7)
			v2:Flash(instance, Color3.new(1, 1, 1))

			if not p2 then
				v2:PlaySound(sounds.MeiMei.Circling.Hit2, humanoidRootPart, game.SoundService.Effect)
				return
			end

			v2:PlaySound(sounds.MeiMei.Circling.FinisherHit, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.SnapOh)
			end

			local attachment = Instance.new("Attachment", instance.Torso)
			local clone2 = utils.Itadori.CrushingBlow.Floor.Wind2:Clone()
			clone2.Color = ColorSequence.new(Color3.new(1, 1, 1))
			clone2.LockedToPart = true
			clone2.Parent = attachment
			clone2.EmissionDirection = Enum.NormalId.Left
			clone2:Emit(8)
			Debris:AddItem(attachment, 1.5)
		end,
		Finisher = function(instance)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			v2:Bleed(instance)
		end,
		Hit4 = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.MeiMei.Circling.FinisherSlash, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end
	}
	v.Effects:Connect(function(p, ...)
		local v4 = v3[p]

		if not v4 then
			return
		end

		v4(...)
	end)
end

function controller.KnitInit(_)
	v = Knit.GetService("CirclingService")
	v2 = Knit.GetController("FXController")
end

return controller