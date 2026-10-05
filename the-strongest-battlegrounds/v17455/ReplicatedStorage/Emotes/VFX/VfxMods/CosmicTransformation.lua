local createVector = vector.create
local CosmicTransformation = {}
local libraryNew = require(script.Parent.libraryNew)
local playAttachment = libraryNew.PlayAttachment
local maid = libraryNew.Maid
local playTween = libraryNew.PlayTween
local _ = libraryNew.CamShake
local _ = libraryNew.PlayFlipBook
local dtwait = libraryNew.dtwait
local playMesh = libraryNew.PlayMesh
local _ = libraryNew.Impact
local _ = libraryNew.GlassLight
local raiseZIndex = libraryNew.RaiseZIndex
local able = libraryNew.Able
local lifeScale = libraryNew.LifeScale
local quickFX = libraryNew.QuickFX
local _ = libraryNew.QuickWeld
local _ = libraryNew.Yield
local _ = libraryNew.ProcessPart
local _ = libraryNew.WeldObject
local _ = libraryNew.Bezier
local class = {}
class.__index = class
local random = Random.new()
local TweenService = game:GetService("TweenService")
game:GetService("PhysicsService")
game:GetService("CollectionService")
local CosmicAura = require(game.ReplicatedStorage.Resources.CosmicMods.CosmicAura)
local MoonEmitter = require(game.ReplicatedStorage.Resources.MoonEmitter)
local BeamLightning = require(game.ReplicatedStorage.Resources.CosmicMods.BeamLightning)
local ObjectService = require(game.ReplicatedStorage.Resources.CosmicMods.ObjectService)
local LoopService = require(game.ReplicatedStorage.Resources.CosmicMods.LoopService)
local v = nil

function CosmicTransformation.Transform(p)
	local data = p.Data
	local char = data.Char
	local humanoidRootPart = char.HumanoidRootPart
	local humanoid = char.Humanoid
	local EFP = libraryNew.EFP
	local currentCamera = workspace.CurrentCamera or game.Workspace.Camera
	local v2 = false
	game:GetService("UserInputService")
	tick()
	local _ = currentCamera and currentCamera.CameraType

	local function diagPath(_) end

	local function diagCamera() end

	local function diag(_, _) end

	local function diagTraceback(_) end

	if char == game.Players.LocalPlayer.Character then
		local object = setmetatable({}, class)
		object._maid = maid.new()
		local v3 = false

		-- equivalent calls inferred from this helper; original call sites unknown
		local function Clean()
			if not v3 then
				v3 = true
				object._maid:doCleaning()
			end
		end

		task.delay(15, function()
			Clean() -- equivalent call inferred; original call site unknown
		end)
		tick()
		local clone = data.music:Clone()
		task.delay(120, function()
			if clone and clone.Parent then
				clone:Destroy()
			end
		end)
		local timePosition = data.music.TimePosition
		data.music:Destroy()
		humanoid.Died:Once(function()
			local TweenService2 = game:GetService("TweenService")
			TweenService2:Create(clone, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Volume = 0
			}):Play()
		end)
		clone.Parent = game.Players.LocalPlayer.PlayerGui
		clone.TimePosition = timePosition
		clone.RollOffMaxDistance = 200
		clone.RollOffMode = Enum.RollOffMode.LinearSquare
		clone:Play()
		local v4 = {}

		local function transformStillValid(p2)
			local parent = p2 and p2.Parent

			if parent then
				if humanoid.Health > 0 then
					parent = char == game.Players.LocalPlayer.Character
				else
					parent = false
				end
			end

			return parent
		end

		tick()

		local function check(_) end

		local function fn(p2)
			if p2 == 0 then
				for _, part in pairs(workspace.Map:GetDescendants()) do
					if part:IsA("BasePart") then
						part.LocalTransparencyModifier = 0
					end
				end
			else
				v2 = true

				for _, part in pairs(workspace.Thrown:GetDescendants()) do
					if not (tostring(part) == "Debris" and part:IsA("BasePart") and (char.PrimaryPart.Position - part.Position).Magnitude <= 170) then
						continue
					end

					part.CFrame = CFrame.new(40000, 40000, 40000)
				end

				for _, part in pairs(workspace.Map:GetDescendants()) do
					if part:IsA("BasePart") then
						part.LocalTransparencyModifier = 1
					end
				end
			end
		end

		local flag = nil
		local module = require(char.CharacterHandler:FindFirstChild("AnimationPlayer") or char.CharacterHandler:WaitForChild("AnimationPlayer"))

		local function fn2(p2)
			return module.playAnimation(game.FindFirstChild(char, "Humanoid"), p2)
		end

		local function Transform()
			local cosmic = game.ReplicatedStorage.Resources.Cosmic
			local TweenService2 = game:GetService("TweenService")
			local TweenService3 = game:GetService("TweenService")
			humanoidRootPart.Velocity = createVector(0, 0, 0)
			local vfx = cosmic.vfx
			local flag2 = true
			local folder = Instance.new("Folder")
			folder.Name = "CosmicRigs"
			folder.Parent = EFP
			local folder2 = Instance.new("Folder")
			folder2.Parent = EFP
			folder2.Name = "CosmicEffects"
			EFP = folder2
			task.delay(33, function()
				if EFP == folder2 then
					EFP = libraryNew.EFP
				end

				if folder2 and folder2.Parent then
					folder2:Destroy()
				end
			end)
			local clouds = game.Workspace.Terrain:FindFirstChild("Clouds")

			if clouds then
				clouds.Enabled = false
			end

			local clone2 = cosmic.Camrig:Clone()
			clone2.Parent = folder
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Include
			raycastParams.FilterDescendantsInstances = { game.Workspace.Map, game.Workspace.Built }
			local raycastResult = game.workspace:Raycast(
				humanoidRootPart.Position,
				createVector(0, -10000, 0),
				raycastParams
			)
			local Y = humanoidRootPart.Position.Y - humanoidRootPart.Size.Y * 1.5

			if raycastResult then
				Y = raycastResult.Position.Y
			end

			local cFrame = humanoidRootPart.CFrame
			local _, v5, _ = char:GetPivot():ToOrientation()
			char:PivotTo(CFrame.new(humanoidRootPart.Position.X, Y, humanoidRootPart.Position.Z) * CFrame.Angles(
				0,
				v5,
				0
			) * CFrame.new(-13, -1445.5, -883):Inverse())
			local clone3 = cosmic.SceneRig:Clone()
			clone3:PivotTo(humanoidRootPart.CFrame * clone3:GetAttribute("Offset"):Inverse())
			clone3.Parent = folder
			table.insert(v4, clone3)
			local clone4 = cosmic.GOD:Clone()
			local humanoid2 = clone4.Humanoid
			local _ = clone4.HumanoidRootPart
			clone4.Parent = folder
			clone4:PivotTo(humanoidRootPart.CFrame * clone4:GetAttribute("Offset"):Inverse())
			local FallSequence
			CosmicAura.Off({
				Char = char
			})
			local sfx = shared.sfx({
				Parent = workspace,
				SoundId = "rbxassetid://90822795706347",
				Volume = 2.5
			})
			sfx:Play()
			clone:Play()
			TweenService3:Create(clone, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Volume = 5
			}):Play()
			TweenService3:Create(sfx, TweenInfo.new(9.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Volume = 5
			}):Play()
			local track = clone2.AnimationController:LoadAnimation(script.FallSequence.SecondCamera)
			fn(1)
			workspace:SetAttribute("MapInvis", true)
			warn("HEYHEYERY")

			local function Sequence1()
				warn("YOG")
				local FOV = require(script["1st Sequence"].FOV)
				local cFrameValue = Instance.new("CFrameValue")
				local numberValue = Instance.new("NumberValue")
				numberValue.Value = 1
				warn("hello")
				local sequence1 = vfx.sequence1
				local v6 = MoonEmitter.new(sequence1.ohyea)
				warn("dzzd")
				v6:Play()
				v6:AddLighting()
				clone2:PivotTo(humanoidRootPart.CFrame * clone2:GetAttribute("Offset"):Inverse())
				local v7 = fn2(107114358965793)
				local track2 = clone2.AnimationController:LoadAnimation(script["1st Sequence"].Cam)
				local track3 = humanoid2:LoadAnimation(script["1st Sequence"].GOD)
				warn("d")
				task.delay(8, function()
					v6:Destroy()
				end)
				local flag3 = nil

				for _, child in pairs(sequence1.room:GetChildren()) do
					local clone5 = child:Clone()

					if child.Name == "auraLIGHT2" then
						local v8 = clone5
						local v9 = child
						task.delay(2, function()
							if not flag3 then
								v8:PivotTo(humanoidRootPart.CFrame * v9:GetAttribute("Offset"):Inverse())
								v8.Parent = EFP
							end
						end)
					else
						clone5:PivotTo(humanoidRootPart.CFrame * child:GetAttribute("Offset"):Inverse())
						clone5.Parent = EFP
					end

					table.insert(v4, clone5)
					local folder3 = clone5
					task.delay(4.2, function()
						for i, beam in pairs(folder3:GetDescendants()) do
							if not beam:IsA("Beam") then
								continue
							end

							playTween(beam, {
								Time = 1,
								EasingStyle = "Sine",
								Goal = {
									Transparency = NumberSequence.new(1)
								}
							})
							game.Debris:AddItem(beam, 1)
						end
					end)
				end

				local v8 = {}
				v7:Play()
				track2:Play()
				track3:Play()
				warn("dzzd")
				task.delay(1, function()
					warn(v7, v7.IsPlaying, v7.TimePosition)
				end)
				shared.SetCore(false, 3)
				table.insert(v8, v7)
				table.insert(v8, track2)
				table.insert(v8, track3)
				local total = 0

				for _, v9 in pairs(v8) do
					v9.TimePosition = 0
				end

				local function ScreenCover()
					local screenGui = Instance.new("ScreenGui")
					screenGui.IgnoreGuiInset = true
					game.Debris:AddItem(screenGui, 8)
					screenGui.Parent = game.Players.LocalPlayer.PlayerGui
					local frame = Instance.new("Frame")
					frame.Parent = screenGui
					frame.Size = UDim2.new(1, 0, 1, 0)
					frame.BackgroundColor3 = Color3.new(0, 0, 0)
					TweenService3:Create(frame, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {
						BackgroundTransparency = 1
					}):Play()
				end

				ScreenCover()

				-- equivalent calls inferred from this helper; original call sites unknown
				local function Stop()
					v7:Stop()
					track2:Stop()
					track3:Stop()
					flag3 = true
				end

				if not flag2 then
					flag2 = true
					Stop() -- equivalent call inferred; original call site unknown
				end

				local v9 = {
					look = function()
						for _, folder3 in pairs(v4) do
							if not (typeof(folder3) ~= "RBXScriptConnection" and (folder3.Name == "auraLIGHT" or folder3.Name == "auraLIGHT2")) then
								continue
							end

							for _, beam in pairs(folder3:GetDescendants()) do
								if beam:IsA("Beam") then
									beam.Enabled = false
								end
							end
						end

						local function New()
							game.Lighting.ClockTime = 0
							local object2 = setmetatable({}, class)
							object2._maid = maid.new()
							local v10 = false

							-- equivalent calls inferred from this helper; original call sites unknown
							local function Clean2()
								if not v10 then
									v10 = true
									object2._maid:doCleaning()
								end
							end

							task.delay(15, function()
								Clean2() -- equivalent call inferred; original call site unknown
							end)
							local sequence12 = vfx.sequence1
							local folder3 = quickFX({
								FX = sequence12.CrackModel3,
								Maid = object2._maid,
								Anchor = clone4:GetPivot() * sequence12.CrackModel3:GetAttribute("Offset"):Inverse() * CFrame.new(
									0,
									0,
									-2.5
								)
							})
							game.Debris:AddItem(folder3, 2)
							local v11 = object2._maid:give(Instance.new("NumberValue"))
							v11.Value = -0.1
							TweenService:Create(v11, TweenInfo.new(3, Enum.EasingStyle.Sine), {
								Value = 1
							}):Play()
							local lastTime = tick()
							local pivot = folder3:GetPivot()
							local v12 = object2._maid:give(Instance.new("NumberValue"))
							v12.Value = 0
							TweenService:Create(v12, TweenInfo.new(3, Enum.EasingStyle.Sine), {
								Value = 1
							}):Play()
							local v13 = {
								"PillarsOfCreation1",
								"PillarsOfCreation2",
								"PillarsOfCreation3",
								"PillarsOfCreation4",
								"GasCloud"
							}

							for _, light in pairs(folder3:GetDescendants()) do
								if not light:IsA("PointLight") then
									continue
								end

								light.Color = Color3.new(0.635294, 0.454902, 1)
								TweenService:Create(light, TweenInfo.new(2.5, Enum.EasingStyle.Sine), {
									Color = Color3.new(1, 0, 0)
								}):Play()
							end

							task.spawn(function()
								local v14 = {}

								while tick() - lastTime < 2 do
									for _, descendant in pairs(folder3:GetDescendants()) do
										if descendant:IsA("BasePart") then
											local mesh = descendant:FindFirstChild("Mesh")

											if mesh then
												mesh.Scale += Vector3.new(v11.Value, 0, 0)
											elseif table.find(v13, descendant.Name) then
												local cframe = descendant.CFrame:ToObjectSpace(folder3:GetPivot())
												local v15 = v14[descendant]

												if not v15 then
													v15 = random:NextNumber(0.5, 1)
													v14[descendant] = v15
												end

												descendant.CFrame = folder3:GetPivot() * CFrame.new(
													0,
													-v11.Value * v15,
													0
												) * cframe:Inverse()
											elseif descendant.Name == "BallGl" then
												local v15 = v11.Value * 0.5
												descendant.Size += Vector3.new(v15, v15, v15 * 1)
											else
												descendant.Size += Vector3.new(-v11.Value, v11.Value, -v11.Value)
											end
										end

										if not descendant:IsA("Texture") or table.find(v13, descendant.Parent.Name) or descendant.Parent.Name ~= "CrackModel" then
											continue
										end

										descendant.StudsPerTileU += v11.Value
										descendant.StudsPerTileV += v11.Value
										descendant.Parent.CFrame = descendant.Parent.CFrame * CFrame.Angles(
											0,
											math.rad(v11.Value) * 0.6,
											0
										)
									end

									dtwait(0.01)
									folder3:PivotTo(pivot * CFrame.new(
										random:NextNumber(-v12.Value, v12.Value),
										random:NextNumber(-v12.Value, v12.Value),
										random:NextNumber(-v12.Value, v12.Value)
									))
								end
							end)
						end

						New()
					end,
					hand = function()
						task.delay(0.6, function()
							for _, v10 in pairs(v8) do
								v10:AdjustSpeed(0)
							end

							FOV = nil
						end)
						task.wait(0.8)
						local screenGui = Instance.new("ScreenGui")
						screenGui.Parent = game.Players.LocalPlayer.PlayerGui
						game.Debris:AddItem(screenGui, 15)
						screenGui.IgnoreGuiInset = true
						local frame = Instance.new("Frame")
						frame.Size = UDim2.new(1, 0, 1, 0)
						frame.BackgroundColor3 = Color3.new(0, 0, 0)
						frame.Parent = screenGui
						game.Lighting.ClockTime = 0
						local clone5 = sequence1["Ehhhidk MeshEmitter"]:Clone()
						clone5.Parent = EFP
						currentCamera.CFrame = CFrame.new(0, 100000, 0)
						MoonEmitter.new(clone5):SetAnchor(currentCamera.CFrame * clone5:GetAttribute("Offset"):Inverse())
						local clone6 = sequence1.Preload2:Clone()
						clone6.Parent = game.Players.LocalPlayer.PlayerGui
						game.Debris:AddItem(clone6, 15)
						table.insert(v4, clone6)
						task.wait(1)
						v6:Stop()
						v6:Destroy()
						v7:Stop()
						track2:Stop()
						task.delay(0.3, function()
							local TweenService4 = game:GetService("TweenService")
							TweenService4:Create(frame, TweenInfo.new(1, Enum.EasingStyle.Sine), {
								BackgroundTransparency = 1
							}):Play()
						end)
						flag3 = true
						FallSequence()
					end
				}
				local lastTime = tick()

				for k, v10 in pairs(v9) do
					local connection = nil
					local v11 = v10
					connection = v7:GetMarkerReachedSignal(k):Connect(function()
						if tick() - lastTime > 13 then
							return connection:Disconnect()
						end

						return v11()
					end)
					table.insert(v4, connection)
				end

				task.spawn(function()
					local v10 = {}
					local numberValue2 = Instance.new("NumberValue")
					game.Debris:AddItem(numberValue2, 22)
					numberValue2.Value = 0.1
					TweenService3:Create(
						numberValue2,
						TweenInfo.new(v10.LerpTime or 3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
						{
							Value = 0.5
						}
					):Play()
					local v11 = false
					local v12 = false
					local renderSteppedConnection = nil
					local RunService = game:GetService("RunService")
					renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
						local v13 = not flag3

						if v13 then
							local parent = clone2 and clone2.Parent

							if parent then
								if humanoid.Health > 0 then
									parent = char == game.Players.LocalPlayer.Character
								else
									parent = false
								end
							end

							v13 = not parent
						end

						if flag3 then
							renderSteppedConnection:Disconnect()
							Stop() -- equivalent call inferred; original call site unknown

							if v13 then
								shared.smoothout(currentCamera.CFrame)
							end
						else
							local parent = clone2 and clone2.Parent

							if parent then
								if humanoid.Health > 0 then
									parent = char == game.Players.LocalPlayer.Character
								else
									parent = false
								end
							end

							if parent then
								if not v11 then
									v11 = true
								end

								if dt > 0.08 and not v12 then
									v12 = true
								end

								local v15 = dt * 60
								total += v15
								local v16 = tonumber((math.ceil(total)))

								if currentCamera.CameraType ~= Enum.CameraType.Scriptable then
									currentCamera.CameraType = Enum.CameraType.Scriptable
								end

								currentCamera.CFrame = clone2.Cam.CFrame * cFrameValue.Value + createVector(0, 0, 0)

								if not FOV or flag3 then
									return
								end

								local v17 = FOV

								if type(FOV) == "table" then
									local v18 = FOV[v16]

									if v18 ~= nil then
										if v10.NoLerp or v10.NoLerpAfter and numberValue2.Value == 0.5 then
											currentCamera.FieldOfView = tonumber(v18)
										else
											local v19 = currentCamera
											local fieldOfView = currentCamera.FieldOfView
											v19.FieldOfView = fieldOfView + (tonumber(v18) * numberValue.Value - fieldOfView) * 0.25
										end
									end

									v17 = nil
								end

								local numberValue3 = v17 and v17:FindFirstChild((tostring(v16)))

								if not numberValue3 then
									return
								end

								local numberValue4

								if numberValue3:IsA("NumberValue") then
									numberValue4 = numberValue3
								else
									numberValue4 = numberValue3.Values:FindFirstChildOfClass("NumberValue")
								end

								if v10.NoLerp or v10.NoLerpAfter and numberValue2.Value == 0.5 then
									currentCamera.FieldOfView = tonumber(numberValue4.Value)
									return
								end

								local eases = numberValue3:FindFirstChild("Eases")

								if eases then
									local params = eases:FindFirstChild("Params")
									local direction = params and params:FindFirstChild("Direction")
									local type2 = params and params:FindFirstChild("Type")
									local value = direction and direction.Value or "In"
									local value2 = type2 and type2.Value or "Linear"
									local TweenService4 = game:GetService("TweenService")
									local value3 = TweenService4:GetValue(
										0.35,
										Enum.EasingStyle[value2],
										Enum.EasingDirection[value]
									)
									TweenService2:Create(currentCamera, TweenInfo.new(value3), {})
									currentCamera.FieldOfView += (tonumber(numberValue4.Value) - currentCamera.FieldOfView) * value3 * numberValue.Value
								else
									local v18 = currentCamera
									local fieldOfView = currentCamera.FieldOfView
									v18.FieldOfView = fieldOfView + (tonumber(numberValue4.Value) * numberValue.Value - fieldOfView) * 0.25
								end
							else
								renderSteppedConnection:Disconnect()
								Stop() -- equivalent call inferred; original call site unknown

								if v13 then
									shared.smoothout(currentCamera.CFrame)
								end
							end
						end
					end)
				end)
			end

			FallSequence = function()
				local fallSequence = vfx.FallSequence
				local FOV = require(script.FallSequence.FOV)
				clone2:PivotTo(humanoidRootPart.CFrame * clone2:GetAttribute("Offset"):Inverse() * CFrame.new(0, 0, 0))
				local v6 = fn2(99080785512879)
				local track2 = clone2.AnimationController:LoadAnimation(script.FallSequence.Cam)
				local track3 = clone3.AnimationController:LoadAnimation(script.FallSequence.Scene)
				local clone5 = cosmic.Meshs:Clone()
				clone5:PivotTo(humanoidRootPart.CFrame * clone5:GetAttribute("Offset"):Inverse())
				clone5.Parent = folder
				table.insert(v4, clone5)
				local v7 = {}
				v6:Play()
				track2:Play()
				track3:Play()
				local cFrameValue = Instance.new("CFrameValue")
				local numberValue = Instance.new("NumberValue")
				numberValue.Value = 1
				table.insert(v4, cFrameValue)
				table.insert(v4, numberValue)
				table.insert(v7, v6)
				table.insert(v7, track2)
				table.insert(v7, track3)
				local total = 1492

				for _, v8 in pairs(v7) do
					v8.TimePosition = 24.866666666666667
				end

				local function ScreenCover()
					local screenGui = Instance.new("ScreenGui")
					screenGui.IgnoreGuiInset = true
					screenGui.Parent = game.Players.LocalPlayer.PlayerGui
					game.Debris:AddItem(screenGui, 15)
					local frame = Instance.new("Frame")
					frame.Parent = screenGui
					frame.Size = UDim2.new(1, 0, 1, 0)
					frame.BackgroundColor3 = Color3.new(0, 0, 0)
					TweenService3:Create(frame, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {
						BackgroundTransparency = 1
					}):Play()
				end

				local flag3 = false

				local function Stop()
					if flag3 then
						return
					end

					flag3 = true
					v6:Stop()
					warn("f")
					local CollectionService = game:GetService("CollectionService")
					task.delay(0, function()
						game.Players.LocalPlayer:GetAttribute("S_UltMusic")
						TweenService3:Create(clone, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
							Volume = 2.35
						}):Play()
						humanoid.Died:Once(function()
							TweenService3:Create(
								clone,
								TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Volume = 0
								}
							):Play()
						end)
						task.wait(1)
						shared.repfire({
							Effect = "Music Transition",
							Theme = clone,
							Root = humanoidRootPart,
							Vol = true
						})
						CollectionService:AddTag(clone, "UltimateMusic")
					end)

					for _, connection in pairs(v4) do
						if typeof(connection) == "RBXScriptConnection" then
							connection:Disconnect()
						else
							connection:Destroy()
						end
					end

					track2:Stop()
					track:Stop()
					shared.smoothout(currentCamera.CFrame)
					shared.SetCore(true, 3)
					task.delay(0.85, function()
						local TweenService4 = game:GetService("TweenService")
						TweenService4:Create(
							currentCamera,
							TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								FieldOfView = game.Players.LocalPlayer:GetAttribute("S_FOV") or 70
							}
						):Play()
					end)
					folder:Destroy()
				end

				local function GodFlesh()
					local clone6 = fallSequence.JustCCS:Clone()
					clone6.Parent = EFP
					table.insert(v4, clone6)
					local v8 = MoonEmitter.new(clone6)
					v8:SetTime(24.866666666666667)
					v8:SetTime(v6.TimePosition)
					v8:Play()
					task.delay(3, function()
						v8:Destroy()
						clone6:Destroy()
					end)
					table.insert(v4, v8)
					local clonesByName = {}

					for _, part in pairs(fallSequence.Dast1:GetChildren()) do
						if not part:IsA("Part") then
							continue
						end

						local clone7 = part:Clone()
						game.Debris:AddItem(clone7, 10)
						clone7:PivotTo(char:GetPivot() * clone7:GetAttribute("Offset"):Inverse())
						clone7.Parent = EFP
						clonesByName[clone7.Name] = clone7
					end

					local line = clonesByName.Line

					for _, emitter in pairs(line:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = true
						end
					end

					local clone7 = fallSequence.Dast1.Attachment:Clone()
					game.Debris:AddItem(clone7, 10)
					clone7.Parent = char.Torso
					table.insert(v4, clone7)

					for _, emitter in pairs(clone7:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = true
						end
					end

					task.delay(3, function()
						for _, emitter in pairs(clone7:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = false
							end
						end
					end)
					task.spawn(function()
						local lastTime = tick()

						while tick() - lastTime < 3 do
							local clone8 = fallSequence.FallWind:Clone()
							clone8:ScaleTo(0.5)
							local orientation, v9, v10 = humanoidRootPart.CFrame:ToOrientation()
							playMesh({
								Model = clone8,
								T = 0.5,
								EndT = 1,
								Anchor = CFrame.new(char.Torso.Position) * CFrame.Angles(orientation, v9, v10) * CFrame.Angles(
									1.5707963267948966,
									0,
									0
								),
								Info = TweenInfo.new(0.1, Enum.EasingStyle.Exponential)
							})
							dtwait(0.1)
						end
					end)
				end

				if flag2 then
					task.delay(3.3, function() end)
				else
					flag2 = true
					Stop()
				end

				local function inside()
					fn(1)
					workspace:SetAttribute("MapInvis", true)
					local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
					colorCorrectionEffect.Parent = game.Lighting
					colorCorrectionEffect.Brightness = 1
					table.insert(v4, colorCorrectionEffect)
					numberValue.Value = 0.8
					TweenService3:Create(numberValue, TweenInfo.new(3, Enum.EasingStyle.Sine), {
						Value = 1.4
					}):Play()
					local parent2 = char
					total = 1850
					local FOVBeam = require(script.FallSequence.FOVBeam)
					FOV = FOVBeam
					clone2:PivotTo(clone2:GetPivot() * CFrame.new(0, -17, 0))
					CosmicAura.On({
						Char = char
					})

					if clouds then
						clouds.Enabled = true
					end

					local mainBeam = EFP:FindFirstChild("MainBeam")

					if mainBeam then
						mainBeam:SetAttribute("Done", true)
					end

					for _, child in pairs(EFP:GetChildren()) do
						if child.Name ~= "CosmicAura" then
							child:Destroy()
						end
					end

					local v9 = {}
					v6:Stop()
					track2:Stop()
					local v10 = fn2(80897999245441)
					char:PivotTo(humanoidRootPart:GetPivot() * CFrame.new(13, 1442.5, 883, 1, 0, 0, 0, 1, 0, 0, 0, 1):Inverse())
					v10:Play()
					track:Play()
					table.insert(v9, v10)
					table.insert(v9, track)

					for _, v11 in pairs(v9) do
						v11.TimePosition = 30.833333333333332
					end

					track:GetMarkerReachedSignal("end"):Connect(function()
						track:Stop()
						Stop()
						flag = true
					end)
					TweenService3:Create(colorCorrectionEffect, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
						Brightness = 0
					}):Play()
					local object2 = setmetatable({}, class)
					object2._maid = maid.new()
					local v11 = false

					-- equivalent calls inferred from this helper; original call sites unknown
					local function Clean2()
						if not v11 then
							v11 = true
							object2._maid:doCleaning()
						end
					end

					task.delay(15, function()
						Clean2() -- equivalent call inferred; original call site unknown
					end)
					local beam = vfx.beam
					MoonEmitter.new(beam["AfterBeam MeshEmitter"]):Play()
					local v12 = {
						fall = function()
							for _, part in pairs(workspace.Map:GetDescendants()) do
								if part:IsA("BasePart") then
									part.LocalTransparencyModifier = 0
								end
							end

							workspace:SetAttribute("MapInvis", nil)

							local function FallEvent()
								local fallvfx = vfx.fallvfx
								local CosmicLandbubble = require(script.Parent.CosmicLandbubble)
								CosmicLandbubble:Attack(parent2)
								task.wait(0.1)
								local v13 = object2._maid:give(Instance.new("Highlight"))
								v13.FillTransparency = 0
								v13.OutlineTransparency = 1
								v13.FillColor = Color3.fromRGB(255, 255, 255)
								v13.Parent = parent2
								TweenService:Create(v13, TweenInfo.new(1, Enum.EasingStyle.Sine), {
									FillTransparency = 1
								}):Play()
								local folder3 = quickFX({
									FX = fallvfx.portal2,
									Maid = object2._maid,
									Anchor = parent2:GetPivot() * fallvfx.portal2:GetAttribute("Offset"):Inverse() * CFrame.new(
										0,
										1,
										-9
									)
								})
								local v14 = object2._maid:give(Instance.new("NumberValue"))
								object2._maid:giveTask(v14.Changed:Connect(function()
									folder3:ScaleTo(v14.Value)
								end))
								folder3:ScaleTo(0.01)
								TweenService:Create(v14, TweenInfo.new(1, Enum.EasingStyle.Sine), {
									Value = 1.5
								}):Play()
								v14.Value = folder3:GetScale()

								for _, effect in pairs(folder3:GetDescendants()) do
									if effect:IsA("ParticleEmitter") then
										local lifetime = effect.Lifetime
										effect.Lifetime = NumberRange.new(lifetime.Min / 3, lifetime.Max / 3)
										effect.Rate *= 3
									elseif effect:IsA("Beam") then
										effect.TextureSpeed *= 3
									end
								end

								task.delay(0.6, function()
									able({
										FX = folder3,
										On = false
									})

									for _, descendant in pairs(folder3:GetDescendants()) do
										if descendant:IsA("Beam") then
											playTween(descendant, {
												Time = 0.35,
												EasingStyle = "Sine",
												Goal = {
													Transparency = NumberSequence.new(1)
												}
											})
										elseif descendant:IsA("PointLight") then
											TweenService:Create(descendant, TweenInfo.new(1, Enum.EasingStyle.Sine), {
												Range = 0
											}):Play()
										end
									end
								end)
								task.spawn(function()
									local clone6 = fallvfx["mr cool additions MeshEmitter1"]:Clone()
									clone6.Name = "1"
									clone6.Parent = EFP
									game.Debris:AddItem(clone6, 10)
									local v15 = MoonEmitter.new(clone6)
									v15:SetAnchor(humanoidRootPart.CFrame * CFrame.new(0, 24, -2) * CFrame.Angles(
										0,
										0,
										0
									))
									v15:SetScale(0.2)
									v15:SetTime(3.18)
									v15:SetSpeed(0.5)
									v15:Play()
									v15:OnCompleted(function()
										clone6:Destroy()
										v15:Destroy()
									end)
									task.delay(1, function()
										v15:SetSpeed(1.8)
									end)
									local clone7 = fallvfx["mr cool additions MeshEmitter1"]:Clone()
									clone7.Name = "1"
									clone7.Parent = EFP
									game.Debris:AddItem(clone7, 10)
									local v16 = MoonEmitter.new(clone7)
									v16:SetAnchor(humanoidRootPart.CFrame * CFrame.new(-2, 24, -2) * CFrame.new(
										0,
										0,
										20
									) * CFrame.Angles(0, 2.007128639793479, 0))
									v16:SetScale(0.2)
									v16:SetTime(3.18)
									v16:SetSpeed(0.5)
									v16:Play()
									v16:OnCompleted(function()
										clone7:Destroy()
										v16:Destroy()
									end)
									task.delay(0.5, function()
										v16:Destroy()
										clone7:Destroy()
									end)
								end)
								task.wait(0.5)
								task.spawn(function()
									local clone6 = fallvfx["mr cool additions MeshEmitter1"]:Clone()
									clone6.Parent = EFP
									game.Debris:AddItem(clone6, 10)
									local v15 = MoonEmitter.new(clone6)
									v15:SetAnchor(humanoidRootPart.CFrame * CFrame.new(0, -0.6000000000000001, -2))
									v15:SetScale(0.020000000000000004)
									v15:SetTime(2)
									v15:Play()
									v15:OnCompleted(function()
										clone6:Destroy()
										v15:Destroy()
									end)
									local clone7 = fallvfx["mr cool additions MeshEmitter1"]:Clone()
									clone7.Parent = EFP
									game.Debris:AddItem(clone7, 10)
									local v16 = MoonEmitter.new(clone7)
									v16:SetAnchor(humanoidRootPart.CFrame * CFrame.new(0, 24, -2))
									v16:SetScale(0.2)
									v16:SetTime(2.5)
									v16:SetSpeed(1)
									v16:Play()
									v16:OnCompleted(function()
										clone7:Destroy()
										v16:Destroy()
									end)
								end)
								local folder4 = nil
								task.delay(0.1, function()
									folder4 = quickFX({
										FX = fallvfx.flooraura,
										Maid = object2._maid,
										Anchor = humanoidRootPart.CFrame * fallvfx.flooraura:GetAttribute("Offset"):Inverse()
									})
									folder4:ScaleTo(3)

									for _, light in pairs(folder4:GetDescendants()) do
										if not light:IsA("PointLight") then
											continue
										end

										light.Range = 13
										light.Color = Color3.new(0.85098, 0, 1)
									end
								end)
								task.delay(3.5, function()
									for _, light in pairs(folder4:GetDescendants()) do
										if light:IsA("PointLight") then
											TweenService:Create(light, TweenInfo.new(1, Enum.EasingStyle.Sine), {
												Brightness = 0
											}):Play()
										end
									end
								end)
								local folder5 = quickFX({
									FX = fallvfx.balls,
									Maid = object2._maid,
									Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0)
								})
								lifeScale({
									FX = folder5.Part.Attachment,
									Scale = 0.1
								})
								lifeScale({
									FX = folder5.Part.Hit9,
									Scale = 1
								})
								folder5:ScaleTo(1.3)

								for _, emitter in pairs(folder5:GetDescendants()) do
									if not emitter:IsA("ParticleEmitter") then
										continue
									end

									local emitCount = emitter:GetAttribute("EmitCount")

									if emitCount then
										emitter:Emit(emitCount)
									end
								end

								task.delay(1.5, function()
									for _, descendant in pairs(folder4:GetDescendants()) do
										if descendant.Name == "up" then
											descendant.Enabled = false
										end
									end

									task.wait(1.5)

									for _, descendant in pairs(folder4:GetDescendants()) do
										if not string.match(string.lower(descendant.Name), "specs") then
											continue
										end

										descendant.Enabled = false
									end
								end)
								task.delay(4, function()
									able({
										FX = folder4,
										On = false
									})
									playAttachment(folder4)
									task.wait(0.15)
								end)
								local folder6 = quickFX({
									FX = fallvfx.Side,
									Maid = object2._maid,
									Anchor = humanoidRootPart.CFrame * fallvfx.Side:GetAttribute("Offset"):Inverse()
								})
								folder6:ScaleTo(2)
								task.delay(0.1, function()
									able({
										FX = folder6,
										On = false
									})

									for _, beam2 in pairs(folder6:GetDescendants()) do
										if beam2:IsA("Beam") then
											playTween(beam2, {
												Time = 1,
												EasingStyle = "Sine",
												Goal = {
													Transparency = NumberSequence.new(1)
												}
											})
										end
									end
								end)
							end

							task.spawn(FallEvent)
						end,
						omg = function()
							local fallvfx = vfx.fallvfx

							local function OmgEvent()
								local function Effect()
									game:GetService("RunService")
									game:GetService("ReplicatedStorage")
									game:GetService("TweenService")
									require(game.ReplicatedStorage.Resources.CosmicMods.SebasUtil)
									require(game.ReplicatedStorage.Resources.CosmicMods.MeshSprite)
									local GroundCrack = require(game.ReplicatedStorage.Resources.CosmicMods.GroundCrack)
									local v13 = GroundCrack.new(fallvfx.CrackModel:Clone(), CFrame.new(0, 0, 0))
									v13:setSize((Vector3.new(
										v13.Model:GetExtentsSize().X / 2 - 5,
										0.1,
										v13.Model:GetExtentsSize().Z / 2 - 5
									)))
									v13.SurfaceGui.ClipsDescendants = false
									local _ = v13.Model:GetPivot() * CFrame.new(0, 4, 0) * CFrame.Angles(
										0.6108652381980153,
										0,
										0
									) * CFrame.new(0, 2, 0)
									local v14 = object2._maid:give(game.StarterPlayer.StarterCharacter:Clone())
									v14.Parent = v13.Viewport.WorldModel
									local v15 = {}
									local v16 = {}

									for _, child in pairs(v14:GetChildren()) do
										if child.Name == "TEMPLATE" then
											child:Destroy()
										end
									end

									local humanoidDescriptionFromUserId = game.Players:GetHumanoidDescriptionFromUserId(game.Players.LocalPlayer.UserId)
									v14.Humanoid:ApplyDescription(humanoidDescriptionFromUserId)
									task.delay(4, function()
										v13:Destroy()

										if v14 then
											v14:Destroy()
										end

										for _, v17 in pairs(v15) do
											v17:Destroy()
										end
									end)
									task.spawn(function()
										v13:setSize(createVector(11.6, 2.4, 11.6))
										v13.Model:ScaleTo(24.72)

										local function MirrorPartName(value: string)
											if value:find("^Left ") then
												return value:gsub("^Left ", "Right ")
											end

											if value:find("^Right ") then
												return value:gsub("^Right ", "Left ")
											end

											return value
										end

										local function MirrorCFrame(cframe: CFrame)
											local position = cframe.Position
											local rightVector = cframe.RightVector
											local upVector = cframe.UpVector
											local v17 = -cframe.LookVector

											-- equivalent calls inferred from this helper; original call sites unknown
											local function reflect(vector2: Vector3)
												return (Vector3.new(-vector2.X, vector2.Y, vector2.Z))
											end

											local v18 = -Vector3.new(-rightVector.X, rightVector.Y, rightVector.Z)
											local v19 = reflect(upVector) -- equivalent call inferred; original call site unknown
											local v20 = reflect(v17) -- equivalent call inferred; original call site unknown
											local v21 = reflect(position) -- equivalent call inferred; original call site unknown
											return CFrame.fromMatrix(v21, v18, v19, v20)
										end

										local v17 = {
											["Right Arm"] = "Right Shoulder",
											["Left Arm"] = "Left Shoulder",
											["Right Leg"] = "Right Hip",
											["Left Leg"] = "Left Hip",
											Head = "Neck",
											Torso = "RootJoint"
										}

										for _, childName in pairs({ "Right Leg", "Left Leg" }) do
											local child = parent2:FindFirstChild(childName)

											if not child then
												continue
											end

											local v18 = object2._maid:give(fallvfx.step:Clone())
											v18.Parent = EFP
											v15[child] = v18
										end

										local lastTime = tick()

										while tick() - lastTime < 30 and v13 and v13.Model and v13.Model.Parent do
											v13:setCFrame(humanoidRootPart.CFrame * CFrame.new(
												0,
												-humanoidRootPart.Size.Y * 2.07,
												-3
											) * CFrame.Angles(0, 0, 0))

											if v14 and v14.Parent then
												v14:PivotTo(humanoidRootPart:GetPivot() * CFrame.new(
													0,
													humanoidRootPart.Size.Y * -3,
													0
												) * CFrame.Angles(3.141592653589793, 3.141592653589793, 0))

												for k, v18 in pairs(v15) do
													if not (k and v18 and v18.Parent) then
														continue
													end

													local v19 = humanoidRootPart.CFrame * CFrame.new(
														0,
														-humanoidRootPart.Size.Y * 1.475,
														0
													)
													v18:PivotTo(CFrame.new(k.Position.X, v19.Position.Y, k.Position.Z))
												end

												for _, part in pairs(v14:GetChildren()) do
													if not part:IsA("BasePart") then
														continue
													end

													local v18 = v17[part.Name]

													if not v18 then
														continue
													end

													local v19 = v14:FindFirstChild("Torso") and v14.Torso:FindFirstChild(v18) or v14:FindFirstChild("HumanoidRootPart") and v14.HumanoidRootPart:FindFirstChild(v18)

													if not v19 then
														continue
													end

													v19.C0 = CFrame.new()
													local name = part.Name

													if name:find("^Left ") then
														name = name:gsub("^Left ", "Right ")
													elseif name:find("^Right ") then
														name = name:gsub("^Right ", "Left ")
													end

													local child = parent2:FindFirstChild(name or part.Name)

													if not child then
														continue
													end

													if part.Name == "Torso" then
														v19.C1 = MirrorCFrame(child.CFrame:ToObjectSpace(parent2.HumanoidRootPart.CFrame))
													else
														v19.C1 = MirrorCFrame(child.CFrame:ToObjectSpace(parent2.Torso.CFrame))
													end
												end
											end

											for _, child in pairs(v13.Model:GetChildren()) do
												if child.Name == "untitled" then
													child:PivotTo(child:GetPivot() * CFrame.Angles(
														0,
														0.0005235987755982988,
														0
													))
												end
											end

											for k, v18 in pairs(v16) do
												v18.Total += v18.Spin.Value
												k:PivotTo(v13.Model:GetPivot() * CFrame.new(
													0,
													5 - tonumber(k.Name) * 0.3,
													0
												) * CFrame.Angles(0.08726646259971647, 0, 0) * CFrame.new(0, 2, 0) * CFrame.Angles(
													0,
													v18.angle + math.rad(v18.Total),
													0
												) * CFrame.new(0, 0, v18.Distance) * CFrame.Angles(
													1.5707963267948966,
													0,
													3.141592653589793
												))
											end

											local RunService = game:GetService("RunService")
											RunService.Heartbeat:Wait()
										end
									end)
								end

								Effect()
							end

							task.spawn(OmgEvent)
						end,
						step = function()
							local function LegEvent()
								local DELAY_DURATION = 0.5

								for _, child in pairs(game.Lighting:GetChildren()) do
									if child.Name == "CosmicField" then
										TweenService3:Create(child, TweenInfo.new(1, Enum.EasingStyle.Sine), {
											NearIntensity = 0,
											FarIntensity = 0
										}):Play()
									end
								end

								local fallvfx = vfx.fallvfx
								local v13 = object2._maid:give(fallvfx["dragon trail"]:Clone())
								local v14 = {}
								task.delay(DELAY_DURATION, function()
									playAttachment((quickFX({
										FX = fallvfx.leg,
										Maid = object2._maid,
										Anchor = humanoidRootPart.CFrame * fallvfx.leg:GetAttribute("Offset"):Inverse()
									})))
								end)
								local offset = object2._maid:give(Instance.new("CFrameValue"))
								offset.Value = CFrame.new(0, -0.5, 0)
								local spin = object2._maid:give(Instance.new("NumberValue"))
								spin.Value = 5
								local distance = object2._maid:give(Instance.new("NumberValue"))
								distance.Value = 1
								task.delay(DELAY_DURATION, function()
									v14[v13] = {
										total = -60,
										distance = distance,
										Spin = spin,
										Offset = offset
									}
								end)
								task.spawn(function()
									task.wait(0.5)
									local parent = object2._maid:give(Instance.new("Model"))
									parent.Name = "legparts"
									parent.Parent = EFP
									local v19 = object2._maid:give(Instance.new("Highlight"))
									v19.FillTransparency = 1
									v19.DepthMode = Enum.HighlightDepthMode.Occluded
									v19.Parent = parent

									for _ = 1, 15 do
										local v20 = humanoidRootPart.CFrame * CFrame.new(
											0.187666506,
											1.98115647,
											2.03225183,
											0.977235913,
											-0.141425863,
											-0.158140242,
											0.134847969,
											0.989520073,
											-0.0516338125,
											0.163785294,
											0.0291335285,
											0.986065447
										):Inverse() * CFrame.new(random:NextNumber(-1, 1), 0, random:NextNumber(-1, 1))
										local raycastParams2 = RaycastParams.new()
										raycastParams2.FilterType = Enum.RaycastFilterType.Include
										raycastParams2.FilterDescendantsInstances = {
											game.Workspace.Map,
											game.Workspace.Built
										}
										local raycastResult2 = game.Workspace:Raycast(
											v20.Position,
											createVector(0, -20, 0),
											raycastParams2
										)

										if not raycastResult2 then
											continue
										end

										local v21 = object2._maid:give(Instance.new("Part"))
										v21.Material = raycastResult2.Material
										v21.Color = raycastResult2.Instance.Color
										v21.Anchored = true
										v21.Name = "Idek2"
										v21.CanCollide = false
										v21.Size = createVector(0, 0, 0)
										local number = random:NextNumber(0.03, 0.1)
										TweenService:Create(
											v21,
											TweenInfo.new(random:NextNumber(0.05, 0.1), Enum.EasingStyle.Sine),
											{
												Size = Vector3.new(number, number, number)
											}
										):Play()
										v21.CanCollide = false
										TweenService:Create(
											v21,
											TweenInfo.new(random:NextNumber(0.5, 2), Enum.EasingStyle.Sine),
											{
												CFrame = CFrame.new(raycastResult2.Position + Vector3.new(
													0,
													random:NextNumber(0.5, 1.5),
													0
												)) * CFrame.Angles(
													random:NextNumber(-4, 4),
													random:NextNumber(-4, 4),
													random:NextNumber(-4, 4)
												)
											}
										):Play()
										task.delay(0.1, function()
											TweenService:Create(
												v21,
												TweenInfo.new(random:NextNumber(0.5, 1.5), Enum.EasingStyle.Sine),
												{
													Size = createVector(0, 0, 0)
												}
											):Play()
										end)
										v21.CFrame = CFrame.new(raycastResult2.Position + Vector3.new(0, -v21.Size.Y, 0)) * CFrame.Angles(
											random:NextNumber(-4, 4),
											random:NextNumber(-4, 4),
											random:NextNumber(-4, 4)
										)
										v21.Parent = parent
									end
								end)
								task.wait(0.1)
								local v18 = object2._maid:give(fallvfx["dragon trail2"]:Clone())
								v18.Parent = EFP
								local offset2 = object2._maid:give(Instance.new("CFrameValue"))
								offset2.Value = CFrame.new(0, -1, 0)
								TweenService:Create(offset2, TweenInfo.new(2, Enum.EasingStyle.Sine), {
									Value = CFrame.new(0, 1, 0)
								}):Play()
								local spin2 = object2._maid:give(Instance.new("NumberValue"))
								spin2.Value = 4
								local distance2 = object2._maid:give(Instance.new("NumberValue"))
								distance2.Value = 0.6
								TweenService:Create(distance2, TweenInfo.new(3, Enum.EasingStyle.Sine), {
									Value = 1
								}):Play()
								v14[v18] = {
									total = 0,
									distance = distance2,
									Spin = spin2,
									Offset = offset2
								}
								v18:ScaleTo(0.7)
								local v22 = object2._maid:give(fallvfx["dragon trail2"]:Clone())
								v22.Parent = EFP
								local offset3 = object2._maid:give(Instance.new("CFrameValue"))
								offset3.Value = CFrame.new(0, -1, 0)
								TweenService:Create(offset3, TweenInfo.new(4, Enum.EasingStyle.Sine), {
									Value = CFrame.new(0, 3, 0)
								}):Play()
								local spin3 = object2._maid:give(Instance.new("NumberValue"))
								spin3.Value = 6
								local distance3 = object2._maid:give(Instance.new("NumberValue"))
								distance3.Value = 1.6
								TweenService:Create(distance3, TweenInfo.new(3, Enum.EasingStyle.Sine), {
									Value = 2
								}):Play()
								v14[v22] = {
									total = -60,
									distance = distance3,
									Spin = spin3,
									Offset = offset3
								}
								v22:ScaleTo(0.3)

								for i = 1, 4 do
									local v26 = object2._maid:give(fallvfx["dragon trail2"]:Clone())
									v26.Parent = EFP
									local offset4 = object2._maid:give(Instance.new("CFrameValue"))
									offset4.Value = CFrame.new(0, -1, 0)
									TweenService:Create(offset4, TweenInfo.new(3, Enum.EasingStyle.Sine), {
										Value = CFrame.new(0, i + 3, 0)
									}):Play()
									local spin4 = object2._maid:give(Instance.new("NumberValue"))
									spin4.Value = 6 - i
									local distance4 = object2._maid:give(Instance.new("NumberValue"))
									distance4.Value = 1.6
									TweenService:Create(distance4, TweenInfo.new(3, Enum.EasingStyle.Sine), {
										Value = i + 5
									}):Play()
									local v34 = i
									task.delay(DELAY_DURATION, function()
										v14[v26] = {
											total = -60,
											distance = distance4,
											Spin = spin4,
											Offset = offset4
										}
										v26:ScaleTo(v34 + 1)
									end)
								end

								task.spawn(function()
									local lastTime = tick()

									while tick() - lastTime < 2.5 do
										for k, v26 in pairs(v14) do
											v26.total += v26.Spin.Value
											local _ = v26.ogpivot
											k:PivotTo(humanoidRootPart.CFrame * CFrame.new(
												0.187666506,
												1.98115647,
												2.03225183,
												0.977235913,
												-0.141425863,
												-0.158140242,
												0.134847969,
												0.989520073,
												-0.0516338125,
												0.163785294,
												0.0291335285,
												0.986065447
											):Inverse() * v26.Offset.Value * CFrame.Angles(0, math.rad(v26.total), 0) * CFrame.new(
												0,
												0,
												v26.distance.Value
											))
											k.Parent = EFP
										end

										dtwait(0.01)
									end
								end)
							end

							task.spawn(LegEvent)
						end
					}

					for k, v13 in pairs(v12) do
						local connection = v10:GetMarkerReachedSignal(k):Connect(v13)
						object2._maid:give(connection)
					end

					local function FirstEvent()
						local function WindBeams()
							task.delay(0.7, function()
								local folder3 = quickFX({
									FX = beam["wind beams"],
									Maid = object2._maid,
									Anchor = parent2:GetPivot() * CFrame.new(0, 47, 0)
								})

								for _, beam2 in pairs(folder3:GetDescendants()) do
									if not beam2:IsA("Beam") then
										continue
									end

									local transparency = beam2.Transparency
									beam2.Transparency = NumberSequence.new({
										NumberSequenceKeypoint.new(0, 1),
										NumberSequenceKeypoint.new(1, 1)
									})
									playTween(beam2, {
										Time = 0.8,
										EasingStyle = "Sine",
										Goal = {
											Transparency = transparency
										}
									})
								end

								dtwait(0.9)

								for _, beam2 in pairs(folder3:GetDescendants()) do
									if not beam2:IsA("Beam") then
										continue
									end

									playTween(beam2, {
										Time = 0.9,
										EasingStyle = "Sine",
										Goal = {
											Transparency = NumberSequence.new({
												NumberSequenceKeypoint.new(0, 1),
												NumberSequenceKeypoint.new(1, 1)
											})
										}
									})
									game.Debris:AddItem(beam2, 0.9)
								end
							end)
						end

						local function WindStuff()
							local v13 = quickFX({
								FX = beam.Test,
								Maid = object2._maid,
								Anchor = parent2:GetPivot() * CFrame.new(0, 47, 0)
							})
							game.Debris:AddItem(v13, 3.8)
							local v14 = object2._maid:give(Instance.new("NumberValue"))
							object2._maid:giveTask(v14.Changed:Connect(function()
								v13:ScaleTo(v14.Value)
							end))
							local v15 = object2._maid:give(Instance.new("NumberValue"))
							v15.Value = 15
							TweenService:Create(v15, TweenInfo.new(1.4, Enum.EasingStyle.Sine), {
								Value = 3
							}):Play()
							v13:ScaleTo(0.1)
							v14.Value = v13:GetScale()
							TweenService:Create(v14, TweenInfo.new(4, Enum.EasingStyle.Sine), {
								Value = 3
							}):Play()
							task.spawn(function()
								local lastTime = tick()
								local pivot = v13:GetPivot()
								local count = 0

								while tick() - lastTime < 3 do
									count += 1

									for i, part in pairs(v13:GetChildren()) do
										if part:IsA("BasePart") then
											part.CFrame *= CFrame.Angles(0, math.rad(i) * v15.Value, 0)
										end
									end

									v13:PivotTo(pivot * CFrame.new(0, count * 0.1, 0))
									dtwait(0.01)
								end
							end)
						end

						-- equivalent calls inferred from this helper; original call sites unknown
						local function Main()
							task.spawn(function()
								local v13 = quickFX({
									FX = beam.Cubes2,
									Maid = object2._maid,
									Anchor = parent2:GetPivot() * beam.Cubes:GetAttribute("Offset"):Inverse() * CFrame.Angles(
										0,
										0,
										0
									)
								})
								v13:ScaleTo(2)
								game.Debris:AddItem(v13, 3.8)
								local folder3 = quickFX({
									FX = beam.RoomReal22,
									Maid = object2._maid,
									Anchor = parent2:GetPivot() * beam.Cubes:GetAttribute("Offset"):Inverse()
								})
								folder3:ScaleTo(2.5)
								game.Debris:AddItem(folder3, 3.8)

								for _, descendant in pairs(folder3:GetDescendants()) do
									if descendant:IsA("BasePart") or descendant:IsA("Texture") then
										TweenService:Create(descendant, TweenInfo.new(1, Enum.EasingStyle.Sine), {
											Transparency = 1
										}):Play()
									end
								end

								task.delay(3.8, function() end)
								local lastTime = tick()
								local count = 0

								while tick() - lastTime < 3 do
									count += 1
									folder3:PivotTo(folder3:GetPivot() * CFrame.Angles(0, 0, 0.0017453292519943296))
									dtwait(0.01)
								end
							end)
						end

						local function White()
							task.spawn(function()
								local folder3 = quickFX({
									FX = beam.RoomReal2,
									Maid = object2._maid,
									Anchor = parent2:GetPivot() * beam.Cubes:GetAttribute("Offset"):Inverse()
								})
								folder3:ScaleTo(2.5)
								game.Debris:AddItem(folder3, 3.8)
								local highlight = Instance.new("Highlight")
								highlight.Parent = folder3
								highlight.FillColor = Color3.new(1, 1, 1)
								highlight.FillTransparency = 0
								highlight.OutlineTransparency = 1
								local v13 = object2._maid:give(Instance.new("Highlight"))
								v13.Parent = parent2
								v13.FillColor = Color3.new(1, 1, 1)
								v13.FillTransparency = 0.999
								v13.OutlineTransparency = 1

								for _, descendant in pairs(folder3:GetDescendants()) do
									if not (descendant:IsA("BasePart") or descendant:IsA("Texture")) then
										continue
									end

									descendant.Transparency = 0
									TweenService:Create(descendant, TweenInfo.new(1, Enum.EasingStyle.Sine), {
										Transparency = 1
									}):Play()
								end
							end)
						end

						-- equivalent calls inferred from this helper; original call sites unknown
						local function Beams()
							local function CloudBeam(anchor)
								local folder3 = quickFX({
									FX = beam.CloudBeam,
									Maid = object2._maid,
									Anchor = anchor
								})
								folder3:ScaleTo(0.2)

								for _, beam2 in pairs(folder3:GetDescendants()) do
									if not beam2:IsA("Beam") then
										continue
									end

									local textureSpeed = beam2.TextureSpeed
									beam2.FaceCamera = true
									local transparency = beam2.Transparency
									beam2.Width0 *= 2
									beam2.Width1 *= 2
									beam2.Transparency = NumberSequence.new({
										NumberSequenceKeypoint.new(0, 1),
										NumberSequenceKeypoint.new(1, 1)
									})
									TweenService:Create(beam2, TweenInfo.new(0.8, Enum.EasingStyle.Sine), {
										TextureSpeed = textureSpeed * -295
									}):Play()
									local v13 = beam2
									task.delay(0.15, function()
										playTween(v13, {
											Time = 0.15,
											EasingStyle = "Sine",
											Goal = {
												Transparency = transparency
											}
										})
									end)
								end

								game.Debris:AddItem(folder3, 3)
							end

							task.delay(0.3, function()
								CloudBeam(cFrame * CFrame.new(
									-51,
									7.93533087,
									1.0231297,
									-4.37113883e-8,
									1,
									4.37113883e-8,
									1,
									4.37113918e-8,
									-4.37113847e-8,
									-4.37113883e-8,
									4.37113847e-8,
									-1
								):Inverse())
								CloudBeam(cFrame * CFrame.new(
									-51,
									-9.0646677,
									31.0231304,
									-4.37113883e-8,
									1,
									4.37113883e-8,
									1,
									4.37113918e-8,
									-4.37113847e-8,
									-4.37113883e-8,
									4.37113847e-8,
									-1
								):Inverse())
								CloudBeam(cFrame * CFrame.new(
									-51,
									-1.02313006,
									-22.0646687,
									-4.37113883e-8,
									1,
									4.37113883e-8,
									0,
									-4.37113883e-8,
									1,
									1,
									4.37113883e-8,
									1.91068547e-15
								):Inverse())
								CloudBeam(cFrame * CFrame.new(
									51,
									-41.0231285,
									-18.0646687,
									-4.37113883e-8,
									1,
									4.37113883e-8,
									0,
									-4.37113883e-8,
									1,
									1,
									4.37113883e-8,
									1.91068547e-15
								):Inverse())
							end)
						end

						local function Rift()
							task.delay(0.7, function()
								local Rift2 = require(beam.AuraStuff.Rift)
								Rift2:Create(CFrame.new(0, 85, 0), Color3.fromRGB(112, 145, 255), 1, 2)
							end)
						end

						local function Long()
							local folder3 = quickFX({
								FX = beam.Long4,
								Maid = object2._maid,
								Anchor = parent2:GetPivot() * CFrame.new(0, 40, 0)
							})
							folder3:ScaleTo(4)

							for _, beam2 in pairs(folder3:GetDescendants()) do
								if not beam2:IsA("Beam") then
									continue
								end

								beam2.Brightness = 1
								local width = beam2.Width0 * 41
								local width2 = beam2.Width1 * 11
								beam2.Width0 = 0
								beam2.Width1 = 0
								beam2.TextureSpeed *= -1
								TweenService:Create(beam2, TweenInfo.new(2, Enum.EasingStyle.Sine), {
									Width0 = width,
									Width1 = width2,
									TextureSpeed = -8
								}):Play()
							end

							task.delay(0.45, function()
								for _, beam2 in pairs(folder3:GetDescendants()) do
									if not beam2:IsA("Beam") then
										continue
									end

									playTween(beam2, {
										Time = 0.5,
										EasingStyle = "Sine",
										Goal = {
											Transparency = NumberSequence.new({
												NumberSequenceKeypoint.new(0, 1),
												NumberSequenceKeypoint.new(1, 1)
											})
										}
									})
									game.Debris:AddItem(beam2, 0.5)
								end
							end)
							game.Debris:AddItem(folder3, 3)
							local folder4 = quickFX({
								FX = beam.Kick2,
								Maid = object2._maid,
								Anchor = parent2:GetPivot() * CFrame.new(0, 10, 0)
							})
							folder4:ScaleTo(35)
							game.Debris:AddItem(folder4, 3.8)
							local v13 = object2._maid:give(Instance.new("NumberValue"))
							object2._maid:giveTask(v13.Changed:Connect(function()
								folder4:ScaleTo(v13.Value)
							end))
							local transparenciesByBeam = {}

							for _, beam2 in pairs(folder4:GetDescendants()) do
								if not beam2:IsA("Beam") then
									continue
								end

								beam2.TextureSpeed *= 0.8
								local transparency = beam2.Transparency
								beam2.Width0 *= 2
								beam2.Width1 *= 2
								beam2.Transparency = NumberSequence.new({
									NumberSequenceKeypoint.new(0, 1),
									NumberSequenceKeypoint.new(1, 1)
								})
								transparenciesByBeam[beam2] = transparency
							end

							v13.Value = 0.1
							task.delay(0.45, function()
								for k, transparency in pairs(transparenciesByBeam) do
									playTween(k, {
										Time = 0.15,
										EasingStyle = "Sine",
										Goal = {
											Transparency = transparency
										}
									})
								end

								TweenService:Create(v13, TweenInfo.new(1, Enum.EasingStyle.Sine), {
									Value = 25
								}):Play()
								task.wait(2.7)

								for k, _ in pairs(transparenciesByBeam) do
									playTween(k, {
										Time = 0.35,
										EasingStyle = "Sine",
										Goal = {
											Transparency = NumberSequence.new({
												NumberSequenceKeypoint.new(0, 1),
												NumberSequenceKeypoint.new(1, 1)
											})
										}
									})
									game.Debris:AddItem(k, 0.35)
								end
							end)
						end

						-- equivalent calls inferred from this helper; original call sites unknown
						local function Meshes()
							task.spawn(function()
								local lastTime = tick()
								local v13 = object2._maid:give(Instance.new("NumberValue"))
								v13.Value = 60
								TweenService:Create(v13, TweenInfo.new(1, Enum.EasingStyle.Sine), {
									Value = 10
								}):Play()
								local count = 0

								while tick() - lastTime < 3.5999999999999996 do
									count += 1
									local v14 = parent2:GetPivot() * CFrame.new(0, v13.Value, 0)

									if count % 5 == 0 then
										local clone6 = beam.Test2:Clone()
										clone6:ScaleTo(random:NextNumber(3, 4))
										playMesh({
											Model = clone6,
											EndT = 1,
											Anchor = v14 * CFrame.Angles(3.141592653589793, 0, 0) * CFrame.Angles(
												0,
												math.rad((random:NextNumber(-360, 360))),
												0
											),
											Info = TweenInfo.new(0.1, Enum.EasingStyle.Quad)
										})
									end

									dtwait(0.01)
								end
							end)
						end

						local function Aura()
							local function OldAura()
								local v13 = object2._maid:give(beam["ki aura"]:Clone())
								v13:ScaleTo(6)
								local children = {}

								for _, child in pairs(v13:GetChildren()) do
									local child2 = parent2:FindFirstChild(child.Name)

									if not child2 then
										continue
									end

									for _, child3 in pairs(child:GetChildren()) do
										object2._maid:give(child3)
										child3.Parent = child2
										table.insert(children, child3)
									end
								end

								task.delay(0.5, function()
									for _, emitter in pairs(children) do
										if emitter:IsA("ParticleEmitter") then
											emitter.Enabled = false
										else
											able({
												FX = emitter,
												On = false
											})
										end
									end
								end)
								v13:Destroy()
								task.delay(3, function()
									for _, v14 in pairs(children) do
										v14:Destroy()
									end
								end)
							end

							local folder3 = parent2
							local v13 = parent2
							local humanoidRootPart2 = v13.HumanoidRootPart
							local humanoidRootPart3 = parent2.HumanoidRootPart
							local auraStuff = beam.AuraStuff
							local head = v13:WaitForChild("Head")
							local leftArm = v13:WaitForChild("Left Arm")
							local rightArm = v13:WaitForChild("Right Arm")
							local leftLeg = v13:WaitForChild("Left Leg")
							local rightLeg = v13:WaitForChild("Right Leg")
							local torso = v13:WaitForChild("Torso")
							local v14 = {}
							local v15 = {}
							local heartbeatConnections = {}
							local ReplicatedStorage = game:GetService("ReplicatedStorage")
							local modules = ReplicatedStorage:WaitForChild("modules")
							local currentCamera2 = workspace.CurrentCamera
							local BoatTween = require(modules.BoatTween)
							local Flipbook = require(modules.Flipbook)
							local folder4 = Instance.new("Folder")
							folder4.Name = "VFXContainer" .. parent2.Name .. script.Name
							folder4.Parent = EFP
							local attachment = Instance.new("Attachment")
							attachment.Name = "BeamAttachment"
							attachment.Parent = humanoidRootPart2
							local alignPosition = Instance.new("AlignPosition")
							alignPosition.Name = "FreezePositionConstraint"
							alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
							alignPosition.RigidityEnabled = true
							alignPosition.Attachment0 = attachment
							alignPosition.Enabled = false
							alignPosition.Parent = humanoidRootPart2
							local alignOrientation = Instance.new("AlignOrientation")
							alignOrientation.Name = "FreezeRotationConstraint"
							alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
							alignOrientation.RigidityEnabled = true
							alignOrientation.Attachment0 = attachment
							alignOrientation.Parent = humanoidRootPart2
							local raycastParams = RaycastParams.new()
							raycastParams.FilterType = Enum.RaycastFilterType.Include

							local function shakeCam(p2)
								currentCamera2.CFrame *= p2
							end

							local function emitparticles(folder5, p2)
								for _, descendant in ipairs(folder5:GetDescendants()) do
									if descendant:IsA("ParticleEmitter") then
										local v16 = descendant
										task.spawn(function()
											local emitDelay = v16:GetAttribute("EmitDelay") or 0
											local emitCount = v16:GetAttribute("EmitCount") or 0

											if v16:GetAttribute("EmitDuration") and v16:GetAttribute("EmitDuration") > 0 then
												v16.Enabled = true
												task.wait(v16:GetAttribute("EmitDuration"))
												v16.Enabled = false
											else
												task.wait(emitDelay)
												v16:Emit(emitCount)
											end
										end)
									elseif descendant:IsA("PointLight") and descendant.Name == "SpecialLight" then
										local v16 = descendant
										task.spawn(function()
											v16.Enabled = true
											local brightness = v16:GetAttribute("Brightness")
											local range = v16:GetAttribute("Range")
											local tween = v16:GetAttribute("Tween")
											TweenService:Create(
												v16,
												TweenInfo.new(tween, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
												{
													Brightness = brightness,
													Range = range
												}
											):Play()
										end)
									elseif descendant:IsA("Beam") then
										local v16 = descendant
										task.spawn(function()
											local emitDuration = v16:GetAttribute("EmitDuration")
											local emitDelay = v16:GetAttribute("EmitDelay") or 0
											local v17 = v16.Width0 * p2
											local v18 = v16.Width1 * p2
											task.wait(emitDelay)
											local transparency = v16.Transparency
											v16.Transparency = NumberSequence.new(1)
											v16.Enabled = true
											local v19 = BoatTween:Create(v16, {
												Time = emitDuration / 2,
												EasingStyle = "Sine",
												EasingDirection = "In",
												Goal = {
													Transparency = transparency
												}
											})
											v19:Play()
											v19.Completed:Connect(function()
												v19:Destroy()
											end)
											task.delay(0.5, function()
												local v20 = BoatTween:Create(v16, {
													Time = 0.5,
													EasingStyle = "Sine",
													EasingDirection = "In",
													Goal = {
														Transparency = NumberSequence.new(1)
													}
												})
												v20:Play()
												v20.Completed:Connect(function()
													v20:Destroy()
												end)
											end)
										end)
									end
								end
							end

							local TweenService4 = game:GetService("TweenService")
							local v16 = {}

							local function captureBeamTransparency(p2)
								local v17 = {}

								for _, keypoint in ipairs(p2.Transparency.Keypoints) do
									table.insert(v17, {
										Time = keypoint.Time,
										Value = keypoint.Value
									})
								end

								v16[p2] = v17
							end

							local function lerpTransparency(list, p2, p3)
								local numberSequenceKeypoints = {}

								for i, v17 in ipairs(list) do
									local v18 = p2[i]
									local v19 = v17.Value + (v18.Value - v17.Value) * p3
									table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(v17.Time, v19))
								end

								return NumberSequence.new(numberSequenceKeypoints)
							end

							local function fadeBeam(p2, p3)
								if not v16[p2] then
									captureBeamTransparency(p2)
								end

								task.spawn(function()
									local lastTime = os.clock()
									local v17 = {}
									local v18 = 0

									for _, keypoint in ipairs(p2.Transparency.Keypoints) do
										table.insert(v17, {
											Time = keypoint.Time,
											Value = keypoint.Value
										})
									end

									local v19 = {}

									for _, v20 in ipairs(v16[p2]) do
										table.insert(v19, {
											Time = v20.Time,
											Value = p3 and v20.Value or 1
										})
									end

									p2.Enabled = true

									if p3 then
										local numberSequenceKeypoints = {}

										for _, v20 in ipairs(v16[p2]) do
											table.insert(
												numberSequenceKeypoints,
												NumberSequenceKeypoint.new(v20.Time, 1)
											)
										end

										p2.Transparency = NumberSequence.new(numberSequenceKeypoints)
										v17 = {}

										for _, keypoint in ipairs(p2.Transparency.Keypoints) do
											table.insert(v17, {
												Time = keypoint.Time,
												Value = keypoint.Value
											})
										end
									end

									while v18 < 0.25 do
										v18 = os.clock() - lastTime
										p2.Transparency = lerpTransparency(v17, v19, math.clamp(v18 / 0.25, 0, 1))
										task.wait()
									end

									local numberSequenceKeypoints = {}

									for _, v20 in ipairs(v19) do
										table.insert(
											numberSequenceKeypoints,
											NumberSequenceKeypoint.new(v20.Time, v20.Value)
										)
									end

									p2.Transparency = NumberSequence.new(numberSequenceKeypoints)

									if not p3 then
										p2.Enabled = false
									end
								end)
							end

							local function enableparticles(folder5)
								for _, effect in ipairs(folder5:GetDescendants()) do
									if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
										effect.Enabled = true
									elseif effect:IsA("Beam") then
										if not v16[effect] then
											captureBeamTransparency(effect)
										end

										local v18 = effect
										local v19 = true
										task.spawn(function()
											local lastTime = os.clock()
											local v20 = {}
											local v21 = 0

											for i, keypoint in ipairs(v18.Transparency.Keypoints) do
												table.insert(v20, {
													Time = keypoint.Time,
													Value = keypoint.Value
												})
											end

											local v22 = {}

											for i, v23 in ipairs(v16[v18]) do
												table.insert(v22, {
													Time = v23.Time,
													Value = v19 and v23.Value or 1
												})
											end

											v18.Enabled = true

											if v19 then
												local numberSequenceKeypoints = {}

												for i, v23 in ipairs(v16[v18]) do
													table.insert(
														numberSequenceKeypoints,
														NumberSequenceKeypoint.new(v23.Time, 1)
													)
												end

												v18.Transparency = NumberSequence.new(numberSequenceKeypoints)
												v20 = {}

												for i, keypoint in ipairs(v18.Transparency.Keypoints) do
													table.insert(v20, {
														Time = keypoint.Time,
														Value = keypoint.Value
													})
												end
											end

											while v21 < 0.25 do
												v21 = os.clock() - lastTime
												v18.Transparency = lerpTransparency(
													v20,
													v22,
													math.clamp(v21 / 0.25, 0, 1)
												)
												task.wait()
											end

											local numberSequenceKeypoints = {}

											for i, v23 in ipairs(v22) do
												table.insert(
													numberSequenceKeypoints,
													NumberSequenceKeypoint.new(v23.Time, v23.Value)
												)
											end

											v18.Transparency = NumberSequence.new(numberSequenceKeypoints)

											if not v19 then
												v18.Enabled = false
											end
										end)
									end
								end
							end

							local function disableparticles(folder5)
								for _, effect in ipairs(folder5:GetDescendants()) do
									if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
										effect.Enabled = false
									elseif effect:IsA("Beam") then
										if not v16[effect] then
											captureBeamTransparency(effect)
										end

										local v18 = effect
										local v19 = false
										task.spawn(function()
											local lastTime = os.clock()
											local v20 = {}
											local v21 = 0

											for i, keypoint in ipairs(v18.Transparency.Keypoints) do
												table.insert(v20, {
													Time = keypoint.Time,
													Value = keypoint.Value
												})
											end

											local v22 = {}

											for i, v23 in ipairs(v16[v18]) do
												table.insert(v22, {
													Time = v23.Time,
													Value = v19 and v23.Value or 1
												})
											end

											v18.Enabled = true

											if v19 then
												local numberSequenceKeypoints = {}

												for i, v23 in ipairs(v16[v18]) do
													table.insert(
														numberSequenceKeypoints,
														NumberSequenceKeypoint.new(v23.Time, 1)
													)
												end

												v18.Transparency = NumberSequence.new(numberSequenceKeypoints)
												v20 = {}

												for i, keypoint in ipairs(v18.Transparency.Keypoints) do
													table.insert(v20, {
														Time = keypoint.Time,
														Value = keypoint.Value
													})
												end
											end

											while v21 < 0.25 do
												v21 = os.clock() - lastTime
												v18.Transparency = lerpTransparency(
													v20,
													v22,
													math.clamp(v21 / 0.25, 0, 1)
												)
												task.wait()
											end

											local numberSequenceKeypoints = {}

											for i, v23 in ipairs(v22) do
												table.insert(
													numberSequenceKeypoints,
													NumberSequenceKeypoint.new(v23.Time, v23.Value)
												)
											end

											v18.Transparency = NumberSequence.new(numberSequenceKeypoints)

											if not v19 then
												v18.Enabled = false
											end
										end)
									end
								end
							end

							local function weld(p2, part)
								part.CFrame = p2.CFrame
								local weldConstraint = Instance.new("WeldConstraint")
								weldConstraint.Part0 = p2
								weldConstraint.Part1 = part
								weldConstraint.Parent = p2
								table.insert(v14, weldConstraint)
								return weldConstraint
							end

							local function decal(parent)
								local texture = auraStuff.Texture

								for _, child in ipairs(texture:GetChildren()) do
									local v17 = object2._maid:give(child:Clone())
									v17.Parent = parent
									TweenService4:Create(v17, TweenInfo.new(1), {
										Transparency = 0.15
									}):Play()
									Flipbook.animate(v17, false, 90, 2)
									table.insert(v15, v17)
								end
							end

							local function winds(parent, p2)
								for _ = 1, 8 do
									task.spawn(function()
										local time = math.random() * 1 + 0.5
										local v18 = math.random() * 1 + 0.7
										local clone6 = auraStuff.Wind:Clone()
										clone6.Parent = parent
										clone6.CFrame = p2 * CFrame.fromEulerAnglesXYZ(0, math.random(-360, 360), 0)
										clone6.Mesh.Scale = clone6.Mesh.Scale * v18
										Flipbook.animate(clone6.Decal, false, math.random(30, 60), 1)
										local v19 = BoatTween:Create(clone6.Mesh, {
											Time = time,
											EasingStyle = "Sine",
											EasingDirection = "In",
											Goal = {
												Scale = createVector(14, 7, 14) * v18,
												Offset = createVector(0, 5, 0) * v18
											}
										})
										v19:Play()
										v19.Completed:Connect(function()
											v19:Destroy()
										end)
										TweenService4:Create(
											clone6.Decal,
											TweenInfo.new(time, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, true),
											{
												Transparency = 0
											}
										):Play()
										local heartbeatConnection = nil
										local lastTime = tick()
										table.insert(heartbeatConnections, heartbeatConnection)
										local RunService = game:GetService("RunService")
										heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
											local v20 = math.clamp((tick() - lastTime) / 3, 0, 1)
											local cframe = CFrame.Angles(0, math.rad(100 * dt * 1), 0)
											clone6.CFrame = CFrame.new(clone6.Position) * ((clone6.CFrame - clone6.CFrame.Position) * cframe)

											if v20 >= 1 and heartbeatConnection then
												heartbeatConnection:Disconnect()
											end
										end)
									end)
								end
							end

							local function windbeam(parent, p2)
								local random2 = Random.new()
								local windbeam1

								if random2:NextNumber() <= 0.7 then
									windbeam1 = auraStuff.windbeam.windbeam1
								else
									windbeam1 = auraStuff.windbeam.windbeam2
								end

								local v17

								if windbeam1 == auraStuff.windbeam.windbeam1 then
									v17 = math.floor(random2:NextNumber(1.3, 2) * 10 + 0.5) / 10
								else
									v17 = math.floor(random2:NextNumber(1, 1.5) * 10 + 0.5) / 10
								end

								auraStuff.windbeam:ScaleTo(v17)
								local clone6 = windbeam1:Clone()
								clone6.Parent = parent
								clone6.CFrame = p2 * CFrame.fromEulerAnglesXYZ(
									math.rad((math.random(-360, 360))),
									math.rad((math.random(-360, 360))),
									(math.rad((math.random(-360, 360))))
								)
								emitparticles(clone6, 3)
							end

							local function windmesh(parent, p2)
								local v17 = math.floor(Random.new():NextNumber(1, 2) * 10 + 0.5) / 10
								local clone6 = auraStuff.Mesh:Clone()
								clone6.Parent = parent
								clone6.CFrame = p2 * CFrame.fromEulerAnglesXYZ(0, math.rad((math.random(-360, 360))), 0)
								Flipbook.animate(clone6.d1, false, 30, 1)
								local v18 = BoatTween:Create(clone6.Mesh, {
									Time = 0.3 * v17,
									EasingStyle = "Linear",
									EasingDirection = "In",
									Goal = {
										Scale = Vector3.new(15 * v17, 8, 15 * v17)
									}
								})
								v18:Play()
								v18.Completed:Connect(function()
									v18:Destroy()
								end)
							end

							folder3:SetAttribute("VFXFolderName", folder4.Name)
							alignPosition.Position = humanoidRootPart2.Position
							alignOrientation.CFrame = humanoidRootPart2.CFrame
							alignPosition.Enabled = true
							alignOrientation.Enabled = true
							local folder5 = object2._maid:give(auraStuff.Aura:Clone())
							folder5.Name = "Aura"
							folder5.Parent = parent2
							local head2 = folder5.Head
							head2.CFrame = head.CFrame
							local weldConstraint = Instance.new("WeldConstraint")
							weldConstraint.Part0 = head
							weldConstraint.Part1 = head2
							weldConstraint.Parent = head
							table.insert(v14, weldConstraint)
							local leftArm2 = folder5["Left Arm"]
							leftArm2.CFrame = leftArm.CFrame
							local weldConstraint2 = Instance.new("WeldConstraint")
							weldConstraint2.Part0 = leftArm
							weldConstraint2.Part1 = leftArm2
							weldConstraint2.Parent = leftArm
							table.insert(v14, weldConstraint2)
							local leftLeg2 = folder5["Left Leg"]
							leftLeg2.CFrame = leftLeg.CFrame
							local weldConstraint3 = Instance.new("WeldConstraint")
							weldConstraint3.Part0 = leftLeg
							weldConstraint3.Part1 = leftLeg2
							weldConstraint3.Parent = leftLeg
							table.insert(v14, weldConstraint3)
							local rightArm2 = folder5["Right Arm"]
							rightArm2.CFrame = rightArm.CFrame
							local weldConstraint4 = Instance.new("WeldConstraint")
							weldConstraint4.Part0 = rightArm
							weldConstraint4.Part1 = rightArm2
							weldConstraint4.Parent = rightArm
							table.insert(v14, weldConstraint4)
							local rightLeg2 = folder5["Right Leg"]
							rightLeg2.CFrame = rightLeg.CFrame
							local weldConstraint5 = Instance.new("WeldConstraint")
							weldConstraint5.Part0 = rightLeg
							weldConstraint5.Part1 = rightLeg2
							weldConstraint5.Parent = rightLeg
							table.insert(v14, weldConstraint5)
							local torso2 = folder5.Torso
							torso2.CFrame = torso.CFrame
							local weldConstraint6 = Instance.new("WeldConstraint")
							weldConstraint6.Part0 = torso
							weldConstraint6.Part1 = torso2
							weldConstraint6.Parent = torso
							table.insert(v14, weldConstraint6)
							local aura = folder5.Aura
							aura.CFrame = humanoidRootPart3.CFrame
							local weldConstraint7 = Instance.new("WeldConstraint")
							weldConstraint7.Part0 = humanoidRootPart3
							weldConstraint7.Part1 = aura
							weldConstraint7.Parent = humanoidRootPart3
							table.insert(v14, weldConstraint7)
							enableparticles(folder5)
							local v17 = {}

							for _, descendant in ipairs(folder5:GetDescendants()) do
								if descendant.Name == "Constellation" then
									table.insert(v17, {
										Attachment = descendant,
										BasePosition = descendant.Position
									})
								end
							end

							local v19 = object2._maid:give(auraStuff.Highlight:Clone())
							v19.Parent = parent2
							table.insert({}, v19)
							TweenService:Create(v19, TweenInfo.new(1), {
								OutlineTransparency = 0
							}):Play()
							task.spawn(function()
								local v20 = {}
								local v21 = {}
								local v22 = {}

								for _, descendant in ipairs(folder3:GetDescendants()) do
									if descendant:IsA("Part") and descendant.Parent.Name ~= "Aura" then
										local name = descendant.Name

										if name == "Left Leg" or name == "Right Leg" then
											table.insert(v20, descendant)
										elseif name == "Left Arm" or name == "Right Arm" or name == "Torso" then
											table.insert(v21, descendant)
										elseif name == "Head" then
											table.insert(v22, descendant)
										end
									elseif descendant:IsA("Accessory") then
										local attachment2 = descendant:FindFirstChildWhichIsA("Attachment", true)

										if attachment2 then
											local name = attachment2.Name:lower()

											if name:find("leg") then
												table.insert(v20, descendant.Handle)
											elseif name:find("torso") or name:find("body") or name:find("arm") or name:find("shoulder") or name:find("back") then
												table.insert(v21, descendant.Handle)
											elseif name:find("head") or name:find("face") or name:find("hat") or name:find("hair") then
												table.insert(v22, descendant.Handle)
											end
										end
									end
								end

								local function decalParts(list)
									for _, v23 in ipairs(list) do
										decal(v23)
									end
								end

								TweenService:Create(folder5.Head.eyes, TweenInfo.new(0.5), {
									Transparency = 0
								}):Play()
							end)
						end

						-- equivalent calls inferred from this helper; original call sites unknown
						local function Trails()
							task.spawn(function()
								local v13 = {}
								local v14 = cFrame * CFrame.new(0, -20, 0)
								task.spawn(function()
									for _ = 1, 20 do
										for _ = 1, 1 do
											local clone6 = beam.Part3:Clone()
											clone6.Name = "Idek3"
											clone6.Anchored = true
											clone6.CanCollide = false
											clone6.Shape = Enum.PartType.Ball
											clone6.Material = Enum.Material.Neon
											clone6.Parent = EFP
											clone6.Color = Color3.fromRGB(255, 255, 255)
											object2._maid:give(clone6)
											local v15 = random:NextNumber(0.2, 0.4) * 4
											clone6.Size = Vector3.new(v15, v15, v15)
											clone6.CFrame = v14 * CFrame.new(
												random:NextNumber(-20, 20),
												random:NextNumber(-20, 0),
												random:NextNumber(-20, 20)
											)
											local number = random:NextNumber(2, 3)
											local range = object2._maid:give(Instance.new("NumberValue"))
											range.Value = random:NextNumber(10, 45)
											TweenService:Create(clone6, TweenInfo.new(number, Enum.EasingStyle.Sine), {
												Size = clone6.Size * 1.5
											}):Play()
											task.delay(number, function()
												TweenService:Create(
													clone6,
													TweenInfo.new(number, Enum.EasingStyle.Sine),
													{
														Size = createVector(0, 0, 0)
													}
												):Play()
											end)
											v13[clone6] = {
												Range = range,
												Orientation = CFrame.Angles(
													math.rad((math.random(0, 360))),
													math.rad((math.random(0, 360))),
													(math.rad((math.random(0, 360))))
												),
												Speed = random:NextNumber(0.1, 1) * 0.1,
												Rise = random:NextNumber(0.05, 0.3) * 28
											}
										end

										task.wait(0.03)
									end
								end)
								local lastTime = tick()
								local count = 0

								while tick() - lastTime < 3.9 do
									count += 1

									for k, v15 in pairs(v13) do
										local _ = v15.Range
										k.CFrame *= CFrame.new(0, v15.Rise, 0)
									end

									dtwait(0.01)
								end
							end)
						end

						local function Cylinder()
							local clone6 = beam.Cylinder:Clone()
							clone6:ScaleTo(2)
							playMesh({
								Model = clone6,
								EndT = 0,
								Anchor = parent2:GetPivot() * CFrame.new(0, 44, 0) * CFrame.Angles(
									0,
									0,
									1.5707963267948966
								),
								Info = TweenInfo.new(0.2, Enum.EasingStyle.Quad)
							})
						end

						Main() -- equivalent call inferred; original call site unknown
						Beams() -- equivalent call inferred; original call site unknown
						Long()
						Trails() -- equivalent call inferred; original call site unknown
						Meshes() -- equivalent call inferred; original call site unknown

						local function Cracks()
							task.wait(0.1)
							local v13 = object2._maid:give(Instance.new("NumberValue"))
							local v14 = quickFX({
								FX = beam.ScreenCracks,
								Maid = object2._maid,
								Anchor = parent2.Torso.CFrame
							})
							game.Debris:AddItem(v14, 3)
							v13.Value = v14:GetScale()
							object2._maid:giveTask(v13.Changed:Connect(function()
								v14:ScaleTo(v13.Value)
							end))
							TweenService:Create(v13, TweenInfo.new(1.3, Enum.EasingStyle.Sine), {
								Value = 0.01
							}):Play()
							task.spawn(function()
								local lastTime = tick()

								while tick() - lastTime < 3 do
									v14:PivotTo(v14:GetPivot() * CFrame.Angles(0, 0.08726646259971647, 0))
									dtwait(0.01)
								end
							end)
						end

						local function Tornado(p2)
							local vfx2 = game.Workspace.AllStuff.Tornado.vfx
							task.spawn(function()
								local lastTime = tick()
								local count = 0
								local v13 = {}
								local object3 = setmetatable({}, class)
								object3._maid = maid.new()
								local v14 = false

								-- equivalent calls inferred from this helper; original call sites unknown
								local function Clean3()
									if not v14 then
										v14 = true
										object3._maid:doCleaning()
									end
								end

								task.delay(15, function()
									Clean3() -- equivalent call inferred; original call site unknown
								end)
								local parent = object3._maid:give(Instance.new("Part"))
								parent.CanCollide = false
								parent.Name = "Pivot"
								parent.CFrame = p2.CFrame * CFrame.new(0, 20, 0)
								parent.Anchored = true
								parent.Transparency = 1
								parent.Parent = EFP
								local v16 = object3._maid:give(vfx2.Inner:Clone())
								local pointLight = Instance.new("PointLight")
								pointLight.Brightness = 5
								pointLight.Color = Color3.fromRGB(255, 111, 44)
								pointLight.Range = 25
								pointLight.Parent = parent
								local v17 = object3._maid:give(Instance.new("NumberValue"))
								v17.Value = 8
								TweenService:Create(v17, TweenInfo.new(1, Enum.EasingStyle.Sine), {
									Value = 1
								}):Play()
								local v18 = object3._maid:give(Instance.new("NumberValue"))
								v18.Value = 11
								TweenService:Create(v18, TweenInfo.new(1, Enum.EasingStyle.Sine), {
									Value = 65
								}):Play()
								local v19 = object3._maid:give(Instance.new("NumberValue"))
								v19.Value = 0.1
								TweenService:Create(v19, TweenInfo.new(1, Enum.EasingStyle.Sine), {
									Value = 4.6
								}):Play()
								local v20 = object3._maid:give(Instance.new("NumberValue"))
								v20.Value = 6
								TweenService:Create(v20, TweenInfo.new(1, Enum.EasingStyle.Sine), {
									Value = 12
								}):Play()
								local v21 = object3._maid:give(Instance.new("NumberValue"))
								v21.Value = 0
								TweenService:Create(v21, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
									Value = 0.05
								}):Play()
								local v22 = object3._maid:give(Instance.new("NumberValue"))
								v22.Value = 3
								TweenService:Create(v22, TweenInfo.new(1, Enum.EasingStyle.Sine), {
									Value = 0.1
								}):Play()

								while tick() - lastTime < 1 do
									count += 1

									if count % 1 == 0 then
										local v23 = object3._maid:give(vfx2.New:Clone())
										local color3 = v23.PrimaryPart.Decal.Color3
										local value = v22.Value
										v23.PrimaryPart.Decal.Color3 = Color3.fromRGB(
											855 * value,
											170 * value,
											50 * value
										)
										local orientation, _, _ = CFrame.new(
											parent.Position,
											p2.CFrame * CFrame.new(0, v18.Value, 0).Position
										):ToOrientation()
										local angle = orientation * v21.Value
										v23:PivotTo(parent.CFrame * CFrame.Angles(angle, 0, 0))
										v23.Parent = EFP
										TweenService:Create(
											v23.PrimaryPart.Decal,
											TweenInfo.new(0.6000000000000001, Enum.EasingStyle.Sine),
											{
												Color3 = color3
											}
										):Play()
										local scale = object3._maid:give(Instance.new("NumberValue"))
										scale.Value = 0.2
										TweenService:Create(scale, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
											Value = 1 * random:NextNumber(1, 1.5)
										}):Play()
										local progress = object3._maid:give(Instance.new("NumberValue"))
										progress.Value = 0
										TweenService:Create(progress, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
											Value = 1
										}):Play()
										local spinSpeed = object3._maid:give(Instance.new("NumberValue"))
										spinSpeed.Value = 15
										TweenService:Create(spinSpeed, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
											Value = 1
										}):Play()
										object3._maid:giveTask(scale.Changed:Connect(function()
											v23:ScaleTo(scale.Value * v19.Value)
										end))
										v13[v23] = {
											Scale = scale,
											Rot = random:NextNumber(0, 360),
											Progress = progress,
											Original = v23:GetPivot(),
											SpinSpeed = spinSpeed,
											Angle = angle
										}
									end

									local _ = count % 5 == 0

									for k, v23 in pairs(v13) do
										local _ = (k:GetPivot().Position - p2.CFrame.Position).Magnitude
										local progress = v23.Progress
										k:PivotTo(v23.Original:Lerp(
											p2.CFrame * CFrame.new(0, v18.Value, 0),
											progress.Value
										) * CFrame.Angles(0, v23.Rot, 0) * CFrame.Angles(
											v23.Angle,
											math.rad(v23.SpinSpeed.Value * count),
											0
										))

										if not (v23.Progress.Value >= 1) then
											continue
										end

										k:Destroy()
										v13[k] = nil
									end

									parent:PivotTo(p2.CFrame * CFrame.Angles(0, math.rad(v20.Value * count), 0) * CFrame.new(
										0,
										0,
										v17.Value
									))
									local number = random:NextNumber(1.2, 2.4)
									v16:PivotTo(CFrame.new(
										parent.Position,
										p2.CFrame * CFrame.new(0, v18.Value, 0).Position
									) * CFrame.Angles(0, 0, 0) * CFrame.Angles(0, 1.5707963267948966, 0) * CFrame.Angles(
										math.rad(v20.Value * count * 3),
										0,
										0
									) * CFrame.new(v18.Value * 0.3, 0, 0))
									v16:ScaleTo(math.clamp(v19.Value, 0.01, 1e999) * number)
									dtwait(0.001)
								end

								Clean3() -- equivalent call inferred; original call site unknown
							end)
						end

						local pivot = parent2:GetPivot()
						local v13 = object2._maid:give(Instance.new("Part"))
						v13.Anchored = true
						v13.CanCollide = false
						v13.Name = "Anchor2"
						v13.Transparency = 1
						v13.CFrame = pivot * CFrame.new(0, 20, 0)
						v13.Parent = EFP
					end

					task.spawn(FirstEvent)
				end

				local function Thebeam()
					local object2 = setmetatable({}, class)
					object2._maid = maid.new()
					local v8 = false

					-- equivalent calls inferred from this helper; original call sites unknown
					local function Clean2()
						if not v8 then
							v8 = true
							object2._maid:doCleaning()
						end
					end

					task.delay(15, function()
						Clean2() -- equivalent call inferred; original call site unknown
					end)

					local function FirstEvent()
						task.delay(0.3, function()
							TweenService3:Create(cFrameValue, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
								Value = CFrame.Angles(-0.4363323129985824, 0, 0.2617993877991494)
							}):Play()
							TweenService3:Create(numberValue, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
								Value = 1.3
							}):Play()
							task.wait(0.3)
							TweenService3:Create(clone2.PrimaryPart, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
								CFrame = clone2.PrimaryPart.CFrame * CFrame.new(0, 50, 0)
							}):Play()
						end)
						task.delay(0.55, function()
							TweenService3:Create(cFrameValue, TweenInfo.new(2.5, Enum.EasingStyle.Quad), {
								Value = CFrame.Angles(0, 0, 0)
							}):Play()
							TweenService3:Create(numberValue, TweenInfo.new(1, Enum.EasingStyle.Quad), {
								Value = 1
							}):Play()
						end)
						local v9 = object2._maid:give(Instance.new("Highlight"))
						v9.Parent = char
						v9.FillColor = Color3.new(0, 0, 0)
						v9.FillTransparency = 0
						v9.OutlineTransparency = 1
						task.delay(1, function()
							TweenService:Create(v9, TweenInfo.new(3, Enum.EasingStyle.Sine), {
								FillTransparency = 1
							}):Play()
							game.Debris:AddItem(v9, 3)
						end)
						game:GetService("ReplicatedStorage")
						game:GetService("UserInputService")
						local TweenService4 = game:GetService("TweenService")
						local Debris = game:GetService("Debris")
						local RunService = game:GetService("RunService")
						local VFX = vfx.VFX
						local MeshFlipbookConfig = require(game.ReplicatedStorage.Resources.CosmicMods.MeshFlipbookConfig)
						local MeshFlipbook = require(game.ReplicatedStorage.Resources.CosmicMods.MeshFlipbook)
						local particle_functions = require(game.ReplicatedStorage.Resources.CosmicMods.particle_functions)
						local Part = require(game.ReplicatedStorage.Resources.CosmicMods.Part)
						local v10 = object2._maid:give(Instance.new("BlurEffect"))
						v10.Size = 24
						task.delay(6, function()
							if v10 and v10.Parent then
								v10:Destroy()
							end
						end)
						v10.Parent = game.Lighting
						TweenService3:Create(v10, TweenInfo.new(2, Enum.EasingStyle.Sine), {
							Size = 0
						}):Play()
						local clone6 = cosmic.StartPos:Clone()
						clone6:PivotTo(humanoidRootPart.CFrame * clone6:GetAttribute("Offset"):Inverse())
						clone6.Parent = EFP
						local clone7 = cosmic.CameraPart1:Clone()
						clone7:PivotTo(humanoidRootPart.CFrame * clone7:GetAttribute("Offset"):Inverse())
						clone7.Parent = EFP
						local clone8 = cosmic.CameraPart2:Clone()
						clone8:PivotTo(humanoidRootPart.CFrame * clone8:GetAttribute("Offset"):Inverse())
						clone8.Parent = EFP
						local _ = workspace.CurrentCamera
						local clone9 = VFX.MainBeam:Clone()
						clone9:PivotTo(clone6.CFrame * CFrame.new(0, -300, 0))
						clone9.BeamEnd.Position += createVector(0, -145, 0)
						clone9.Parent = EFP

						local function fn3(duration: number, p2: number, items, fillColor: Color3)
							for _, item in items do
								local highlight = Instance.new("Highlight")
								highlight.Name = "ImpactHighlight"
								highlight.FillColor = fillColor
								highlight.OutlineTransparency = 1
								highlight.Parent = item
							end

							local v11 = game.Lighting:FindFirstChild("Impact")

							if not v11 then
								v11 = Instance.new("ColorCorrectionEffect")
								v11.Brightness = 0
								v11.Contrast = 0
								v11.Saturation = 0
								v11.Enabled = true
								v11.TintColor = Color3.fromRGB(255, 255, 255)
								v11.Name = "Impact"
								v11.Parent = game.Lighting
								game.Debris:AddItem(v11, 3)
							end

							local clone10 = v11:Clone()
							clone10.Parent = game:GetService("Lighting")
							clone10.Brightness = -1
							clone10.Contrast = -100
							clone10.Saturation = -1

							for _ = 1, p2 do
								clone10.Contrast = -100
								task.wait(duration)
								clone10.Contrast = 100
								task.wait(duration)
							end

							clone10.Brightness = 0
							clone10.Contrast = 0
							clone10.Saturation = 0
							clone10:Destroy()

							for _, item in items do
								if item:FindFirstChild("ImpactHighlight") then
									item:Destroy()
								end
							end
						end

						for _, beam in clone9.BeamEnd:GetDescendants() do
							if beam:IsA("Beam") then
								beam.Enabled = true
							end
						end

						object2._maid:give(clone9)
						task.delay(0.15, function()
							warn("trigger")

							local function breakModelLikeMap(original2, velocity)
								if not original2 or original2 == workspace then
									return
								end

								local v11 = {
									Effect = "Break Model",
									Original = original2,
									Velocity = velocity
								}
								local original = v11.Original

								if not (original:GetAttribute("Destructible") or original:GetAttribute("Fragile")) then
									local original3 = original
									original = original.Parent
									v11.Original = original3.Parent

									if not v11.Original then
										return
									end

									if v11.Original:IsA("Folder") then
										v11.Original = original3
										original = original3
									end
								end

								if not original or not original.Parent or original.Parent == game.Lighting or original:GetAttribute("Broken") then
									return
								end

								original:SetAttribute("Broken", true)
								local v12 = {}

								for _, part in pairs(original:GetDescendants()) do
									if not part:IsA("BasePart") then
										continue
									end

									table.insert(v12, {
										part,
										part.CanQuery,
										part.CanTouch,
										part.Transparency,
										part.CanCollide
									})
									part.Transparency = 1
									part.CanCollide = false
									part.CanTouch = false
									part.CanQuery = false
								end

								task.delay((original:GetAttribute("RespawnTime") or 60) - 1.5, function()
									if original and original.Parent then
										original:SetAttribute("Broken", false)
									end

									for _, v13 in pairs(v12) do
										local v14 = v13[1]

										if not (v14 and v14.Parent) then
											continue
										end

										v14.Transparency = v13[4]
										v14.CanCollide = v13[5]
										v14.CanTouch = v13[3]
										v14.CanQuery = v13[2]
									end
								end)
							end

							local partBoundsInRadius = workspace:GetPartBoundsInRadius(clone6.Position, 85)
							local parents = {}

							for _, part in pairs(partBoundsInRadius) do
								if not part:IsA("BasePart") then
									continue
								end

								local parent = part.Parent

								if parent and (parent.Name == "Bench" or parent.Name == "Trashcan" or part:GetAttribute("Destructible")) and not table.find(
									parents,
									parent
								) then
									table.insert(parents, parent)
									breakModelLikeMap(part, math.random(15, 20) * 5)
								end

								if not (part:GetAttribute("IsTree") or part.Name == "TreeRoot") then
									continue
								end

								local parent2 = part.Parent and part.Parent.Parent

								if not parent2 or not parent2:FindFirstChildWhichIsA("BasePart", true) or table.find(
									parents,
									parent2
								) then
									continue
								end

								table.insert(parents, parent2)
								breakModelLikeMap(parent2, math.random(75, 100) * 2)
							end
						end)

						for _, beam in pairs(clone9:GetDescendants()) do
							if not beam:IsA("Beam") then
								continue
							end

							local width0 = beam.Width0
							local width1 = beam.Width1
							beam.Width0 *= 13
							beam.Width1 *= 13
							TweenService:Create(beam, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
								Width0 = width0,
								Width1 = width1
							}):Play()
						end

						local clone10 = VFX.RingBeams:Clone()
						clone10:PivotTo(clone6.CFrame * CFrame.new(0, -300, 0))

						for _, child in clone10:GetChildren() do
							if child.Name == "BeamEnd" then
								child.Position += createVector(0, -100, 0)
							end
						end

						clone10.Parent = EFP
						object2._maid:give(clone10)
						local clone11 = VFX.NoiseCylinder:Clone()
						clone11.Position = clone6.Position + createVector(0, -300, 0) + createVector(1, 0, -1)
						clone11.Mesh.Scale = createVector(16, 12, 16)
						clone11.Parent = EFP
						object2._maid:giveTask(clone9:GetAttributeChangedSignal("Done"):Connect(function()
							clone11:Destroy()
							clone9:PivotTo(CFrame.new(char.Torso.position))

							for _, beam in pairs(clone9:GetDescendants()) do
								if not beam:IsA("Beam") then
									continue
								end

								TweenService3:Create(beam, TweenInfo.new(2, Enum.EasingStyle.Bounce), {
									Width0 = 0,
									Width1 = 0
								}):Play()
								beam:Destroy()
							end

							for _, child in pairs(EFP:GetChildren()) do
								if child.Name == "BeamTrail" then
									child:Destroy()
								end
							end
						end))
						local clone12 = VFX.WindBeams:Clone()
						clone12:PivotTo(clone6.CFrame * CFrame.new(0, -300, 0))
						clone12.Parent = EFP
						object2._maid:give(clone12)

						local function startBlurTweens()
							local Lighting = game:GetService("Lighting")
							local blurEffect = Instance.new("BlurEffect")
							task.delay(5, function()
								if blurEffect and blurEffect.Parent then
									blurEffect:Destroy()
								end
							end)
							blurEffect.Size = 1
							blurEffect.Parent = Lighting
							local tween = TweenService4:Create(
								blurEffect,
								TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 20, true),
								{
									Size = 20
								}
							)
							tween:Play()
							tween.Completed:Connect(function()
								blurEffect:Destroy()
							end)
							Lighting.DepthOfField.Enabled = true
						end

						local function spawnSpike(p2, p3)
							local children = VFX.Spikes:GetChildren()
							local clone13 = children[math.random(1, #children)]:Clone()
							clone13.Parent = EFP
							local v11 = math.random() * 3.141592653589793 * 2
							local v12 = math.random(50, p3)
							local v13 = p2 + Vector3.new(math.cos(v11) * v12, 0, math.sin(v11) * v12)
							local v14 = math.rad((math.random(0, 360)))
							local v15 = math.rad((math.random(-8, 8)))
							local v16 = math.rad((math.random(-8, 8)))
							local v17 = CFrame.Angles(0, v14, 0) * CFrame.Angles(v15, 0, v16)
							local cFrame2 = CFrame.new(v13) * v17
							local cFrame3 = cFrame2 - cFrame2.UpVector * 35
							clone13.PrimaryPart.CFrame = cFrame3
							TweenService4:Create(
								clone13.PrimaryPart,
								TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.In),
								{
									CFrame = cFrame2
								}
							):Play()
							task.delay(0.2, function()
								particle_functions.Emit(clone13)
							end)
							local Debris2 = game:GetService("Debris")
							Debris2:AddItem(clone13, 5)
						end

						local function Spawn(vector2: Vector3, p2: number, p3: number)
							for _ = 1, p3 do
								spawnSpike(vector2, p2)
							end
						end

						local function spawnCrescentFlipbook(p2)
							for _ = 1, p2 do
								local v11 = math.random(1, 360)
								local v12 = math.random(-4, 4)
								local v13 = math.random(10, 60)
								local time = math.random(50, 55) / 100
								local v15 = math.random(-13, 13)
								local v16 = math.random(4, 10)
								local v17 = math.random(34, 50)
								local integer = Random.new():NextInteger(1, 2)
								local clone13 = VFX.CrescentDissolve:Clone()
								clone13.Mesh.Scale = Vector3.new(v17, v16, v17)
								clone13.CFrame = clone6.CFrame * CFrame.Angles(math.rad(v15), math.rad(v11), 0)

								if integer == 1 then
									clone13.Decal.Color3 = Color3.fromRGB(9, 15, 62)
								else
									clone13.Decal.Color3 = Color3.fromRGB(79, 1, 86)
								end

								clone13.Parent = EFP
								Debris:AddItem(clone13, 2)
								local total2 = 0
								local heartbeatConnection = nil
								local v19 = "Y"
								heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
									total2 += dt

									if v19 == "X" then
										clone13.CFrame *= CFrame.Angles(math.rad(v12), 0, 0)
									elseif v19 == "Y" then
										clone13.CFrame *= CFrame.Angles(0, math.rad(v12), 0)
									elseif v19 == "Z" then
										clone13.CFrame *= CFrame.Angles(0, 0, (math.rad(v12)))
									end

									if total2 > 5 and heartbeatConnection then
										heartbeatConnection:Disconnect()
									end
								end)
								local v22 = {
									EasingDirection = "Out",
									Easing = "Sine",
									Time = time,
									Goal = {
										Position = clone6.Position + Vector3.new(0, v13, 0)
									}
								}
								TweenService4:Create(
									clone13,
									TweenInfo.new(
										v22.Time,
										Enum.EasingStyle[v22.Easing],
										Enum.EasingDirection[v22.EasingDirection]
									),
									v22.Goal
								):Play()
								local mesh = clone13.Mesh
								local v23 = {
									EasingDirection = "Out",
									Easing = "Linear",
									Time = time,
									Goal = {
										Scale = Vector3.new(v17 / 1.4, 2, v17 / 1.4)
									}
								}
								TweenService4:Create(
									mesh,
									TweenInfo.new(
										v23.Time,
										Enum.EasingStyle[v23.Easing],
										Enum.EasingDirection[v23.EasingDirection]
									),
									v23.Goal
								):Play()
								MeshFlipbook.flipbook(clone13.Decal, MeshFlipbookConfig.DissolvingCrescent, time)
							end
						end

						local function spawnDebris(p2, p3)
							for _ = 1, p2 do
								for _ = 1, p3 do
									local v11 = math.random(1, 7.5)
									local v12 = math.random(1, 5)
									local clone13 = VFX.Rocks["Rock" .. v12]:Clone()
									clone13.CFrame = clone6.CFrame + Vector3.new(
										math.random(-25, 25),
										1,
										math.random(-25, 25)
									)
									clone13.Anchored = false
									clone13.Massless = false
									clone13.Size = Vector3.new(v11, v11, v11)
									clone13.Parent = EFP
									task.wait()
									clone13:ApplyImpulse(Vector3.new(
										math.random(-20, 20) / 10,
										math.random(5, 10) / 10,
										math.random(-20, 20) / 10
									).Unit * math.random(80, 250) * clone13.AssemblyMass)
									clone13:ApplyAngularImpulse(Vector3.new(
										math.random(-57, 57),
										math.random(-57, 57),
										math.random(-57, 57)
									) * clone13.AssemblyMass)
									Debris:AddItem(clone13, 6)
								end

								task.wait(0.075)
							end
						end

						local function beam()
							local clone13 = VFX.Outer:Clone()
							clone13.Position = clone6.Position + createVector(0, -20, 0)
							clone13.Size = createVector(55.343, 49.134, 36.394)
							clone13.Parent = EFP
							Debris:AddItem(clone13, 0.25)
							local clone14 = VFX.Inner:Clone()
							clone14.Position = clone6.Position + createVector(0, -20, 0)
							clone14.Size = createVector(49.574, 46.016, 32.838)
							clone14.Parent = EFP
							Debris:AddItem(clone14, 0.25)
							local v11 = {
								EasingDirection = "In",
								Easing = "Cubic",
								Time = 0.15,
								Goal = {
									Position = clone6.Position + createVector(0, 15, 0),
									Size = createVector(45, 115, 35)
								}
							}
							TweenService4:Create(
								clone14,
								TweenInfo.new(
									v11.Time,
									Enum.EasingStyle[v11.Easing],
									Enum.EasingDirection[v11.EasingDirection]
								),
								v11.Goal
							):Play()
							local v12 = {
								EasingDirection = "In",
								Easing = "Cubic",
								Time = 0.15,
								Goal = {
									Position = clone6.Position + createVector(0, 17, 0),
									Size = createVector(50, 120, 38)
								}
							}
							TweenService4:Create(
								clone13,
								TweenInfo.new(
									v12.Time,
									Enum.EasingStyle[v12.Easing],
									Enum.EasingDirection[v12.EasingDirection]
								),
								v12.Goal
							):Play()
							task.delay(0.075, function()
								fn3(0.08, 1, { clone13, clone14 }, Color3.new(0, 0, 0))
							end)
							task.delay(0.15, function()
								local v14 = {
									EasingDirection = "In",
									Easing = "Cubic",
									Time = 0.1,
									Goal = {
										Position = clone6.Position + createVector(0, -25, 0),
										Size = createVector(10, 57.436, 10)
									}
								}
								TweenService4:Create(
									clone14,
									TweenInfo.new(
										v14.Time,
										Enum.EasingStyle[v14.Easing],
										Enum.EasingDirection[v14.EasingDirection]
									),
									v14.Goal
								):Play()
								local v16 = {
									EasingDirection = "In",
									Easing = "Cubic",
									Time = 0.1,
									Goal = {
										Position = clone6.Position + createVector(0, -23, 0),
										Size = createVector(12, 53.165, 12)
									}
								}
								TweenService4:Create(
									clone13,
									TweenInfo.new(
										v16.Time,
										Enum.EasingStyle[v16.Easing],
										Enum.EasingDirection[v16.EasingDirection]
									),
									v16.Goal
								):Play()
							end)
							task.delay(0.22, function()
								local DELAY_DURATION = 4
								clone9:PivotTo(clone6.CFrame)
								local beamEnd2 = clone9.BeamEnd
								local v13 = {
									EasingDirection = "Out",
									Easing = "Sine",
									Time = 0.5,
									Goal = {
										Position = clone9.BeamEnd.Position + createVector(0, 145, 0)
									}
								}
								TweenService4:Create(
									beamEnd2,
									TweenInfo.new(
										v13.Time,
										Enum.EasingStyle[v13.Easing],
										Enum.EasingDirection[v13.EasingDirection]
									),
									v13.Goal
								):Play()
								task.delay(DELAY_DURATION, function()
									if clone9.Parent then
										clone9:PivotTo(clone6.CFrame * CFrame.new(0, -300, 0))
										clone9.BeamEnd.Position += createVector(0, -145, 0)
									end
								end)
								clone10:PivotTo(clone6.CFrame)

								for _, child in clone10:GetChildren() do
									if child.Name ~= "BeamEnd" then
										continue
									end

									local v14 = {
										EasingDirection = "Out",
										Easing = "Sine",
										Time = 0.5,
										Goal = {
											Position = child.Position + createVector(0, 100, 0)
										}
									}
									TweenService4:Create(
										child,
										TweenInfo.new(
											v14.Time,
											Enum.EasingStyle[v14.Easing],
											Enum.EasingDirection[v14.EasingDirection]
										),
										v14.Goal
									):Play()
								end

								task.delay(DELAY_DURATION, function()
									clone10:PivotTo(clone6.CFrame * CFrame.new(0, -300, 0))

									for _, child in clone10:GetChildren() do
										if child.Name == "BeamEnd" then
											child.Position += createVector(0, -100, 0)
										end
									end
								end)
								local clone15 = VFX.CylinderMesh:Clone()
								clone15.Position = clone6.Position + createVector(0, -5, 0)
								clone15.Parent = EFP
								clone15.Factors.Enabled.Value = true
								Part:Enable(clone15)
								Debris:AddItem(clone15, 4)
								local clone16 = VFX.ShockMesh:Clone()
								clone16.Position = clone6.Position + createVector(0, -5, 0)
								clone16.Parent = EFP
								clone16.Factors.Enabled.Value = true
								Part:Enable(clone16)
								Debris:AddItem(clone16, 4)
								local clone17 = VFX.CylinderDissolve:Clone()
								clone17.Position = clone6.Position + createVector(0, 18, 0)
								clone17.Parent = EFP
								MeshFlipbook.flipbook(clone17.Decal, MeshFlipbookConfig.DissolvingCylinder, 4)
								Debris:AddItem(clone17, 4)
								MeshFlipbook.flipbook(clone11.Decal, MeshFlipbookConfig.NoiseCylinder, 4)
								clone11.Position = clone6.Position + createVector(0, 30, 0)
								local v14 = {
									EasingDirection = "Out",
									Easing = "Sine",
									Time = 0.5,
									Goal = {
										Scale = createVector(16, 70, 16)
									}
								}
								TweenService4:Create(
									clone11.Mesh,
									TweenInfo.new(
										v14.Time,
										Enum.EasingStyle[v14.Easing],
										Enum.EasingDirection[v14.EasingDirection]
									),
									v14.Goal
								):Play()
								local v16 = {
									EasingDirection = "Out",
									Easing = "Sine",
									Time = 0.5,
									Goal = {
										Position = clone6.Position + createVector(0, 65, 0) + createVector(1, 0, -1)
									}
								}
								TweenService4:Create(
									clone11,
									TweenInfo.new(
										v16.Time,
										Enum.EasingStyle[v16.Easing],
										Enum.EasingDirection[v16.EasingDirection]
									),
									v16.Goal
								):Play()
								object2._maid:give(clone11)
								task.delay(DELAY_DURATION, function()
									if clone11.Parent then
										clone11.Position = clone6.Position + createVector(0, -300, 0) + createVector(
											1,
											0,
											-1
										)
										clone11.Mesh.Scale = createVector(16, 12, 16)
									end
								end)
								clone12:PivotTo(clone6.CFrame)
								task.delay(DELAY_DURATION, function()
									clone12:PivotTo(clone6.CFrame * CFrame.new(0, -300, 0))
								end)
								local clone18 = VFX.SideSpecs:Clone()
								clone18:PivotTo(clone6.CFrame)
								clone18.Parent = EFP
								particle_functions.Enable(clone18, true)
								Debris:AddItem(clone18, 5)
								task.delay(DELAY_DURATION, function()
									particle_functions.Enable(clone18, false)
								end)
								local clone19 = VFX.BeamSpecs:Clone()
								clone19.Position = clone6.Position
								clone19.Parent = EFP
								particle_functions.Enable(clone19, true)
								Debris:AddItem(clone19, 5)
								task.delay(DELAY_DURATION, function()
									particle_functions.Enable(clone19, false)
								end)
								task.spawn(function()
									for _ = 1, 25 do
										spawnCrescentFlipbook(4)
										task.wait(0.12)
									end
								end)
								task.delay(3, function() end)
							end)
						end

						beam()
					end

					task.spawn(FirstEvent)
				end

				local v8 = {
					flesh = function()
						GodFlesh()
					end,
					inside = function()
						inside()
					end,
					land = function()
						local function NewLand()
							for _, part in pairs(workspace.Map:GetDescendants()) do
								if part:IsA("BasePart") then
									part.LocalTransparencyModifier = 0
								end
							end

							workspace:SetAttribute("MapInvis", nil)
							task.delay(14, function()
								Stop()
							end)
							local AccurateFOV = require(script.FallSequence.AccurateFOV)
							FOV = AccurateFOV
							total = 42
							clone2:PivotTo(clone2:GetPivot() * CFrame.new(0, 10, 0))
							local v9 = {}
							v6:AdjustSpeed(0)
							track2:AdjustSpeed(0)
							track2:Stop()
							local track4 = clone2.AnimationController:LoadAnimation(script.FallSequence.AccurateCam)
							track4:Play()
							track4.TimePosition = 0.7

							for _, v10 in pairs(v9) do
								v10.TimePosition = 0.8166666666666667
							end

							tick()
							local morevfx = vfx.morevfx
							game.Lighting.EnvironmentDiffuseScale = 1
							game.Lighting.EnvironmentSpecularScale = 1
							task.delay(4, function()
								game.Lighting.EnvironmentDiffuseScale = 0
								game.Lighting.EnvironmentSpecularScale = 0
							end)
							local v10 = {
								start = function()
									clone2:PivotTo(clone2:GetPivot() * CFrame.new(0, 10, 0))
									local clone6 = morevfx["AdjustedStar MeshEmitter"]:Clone()
									clone6.Parent = EFP
									game.Debris:AddItem(clone6, 10)
									local v11 = MoonEmitter.new(clone6)
									v11:SetAnchor(clone2:GetPivot() * clone6:GetAttribute("Offset"):Inverse() * CFrame.new(
										1,
										0,
										0
									))
									local depthOfFieldEffect = Instance.new("DepthOfFieldEffect")
									depthOfFieldEffect.FarIntensity = 0.733
									depthOfFieldEffect.NearIntensity = 0.75
									depthOfFieldEffect.InFocusRadius = 30
									depthOfFieldEffect.FocusDistance = 0
									depthOfFieldEffect.Parent = game.Lighting
									depthOfFieldEffect.Name = "CosmicField"
									game.Debris:AddItem(depthOfFieldEffect, 21)
									local bloomEffect = Instance.new("BloomEffect")
									bloomEffect.Size = 21
									bloomEffect.Intensity = 1
									bloomEffect.Threshold = 2
									bloomEffect.Parent = game.Lighting
									game.Debris:AddItem(bloomEffect, 21)
									local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
									colorCorrectionEffect.Parent = game.Lighting
									game.Debris:AddItem(colorCorrectionEffect, 21)
									v11:AssignExternal("ColorCorrection", colorCorrectionEffect)
									v11:SetTime(0.7999999999999999)
									v11:Play()
								end,
								boom = function()
									local anchor = clone2:GetPivot() * CFrame.new(
										0,
										103,
										0,
										-1.1920929e-7,
										0,
										1.00000012,
										0,
										1,
										0,
										-1.00000012,
										0,
										-1.1920929e-7
									):Inverse()
									local object2 = setmetatable({}, class)
									object2._maid = maid.new()
									local v12 = false

									-- equivalent calls inferred from this helper; original call sites unknown
									local function Clean2()
										if not v12 then
											v12 = true
											object2._maid:doCleaning()
										end
									end

									task.delay(15, function()
										Clean2() -- equivalent call inferred; original call site unknown
									end)
									local parent = object2._maid:give(Instance.new("Folder"))
									parent.Parent = EFP
									parent.Name = "NewFolder"

									local function ExploEvent()
										local main = vfx.main

										local function ExploEvent2()
											local v14 = object2._maid:give(morevfx["explosion MeshEmitter"]:Clone())
											v14.Parent = parent
											v14:ScaleTo(0.01)
											local v15 = object2._maid:give(Instance.new("NumberValue"))
											object2._maid:giveTask(v15.Changed:Connect(function()
												v14:ScaleTo(v15.Value)
											end))
											v14:PivotTo(anchor * CFrame.new(0, -6, 0))
											v15.Value = v14:GetScale()
											TweenService:Create(v15, TweenInfo.new(1, Enum.EasingStyle.Sine), {
												Value = 2
											}):Play()
											TweenService:Create(
												v14.PrimaryPart,
												TweenInfo.new(3, Enum.EasingStyle.Quad),
												{
													CFrame = v14:GetPivot() * CFrame.new(0, 50, 0)
												}
											):Play()
											task.delay(0.5, function()
												TweenService:Create(
													v14.PrimaryPart,
													TweenInfo.new(3, Enum.EasingStyle.Quad),
													{
														CFrame = v14:GetPivot() * CFrame.new(0, 120, 0)
													}
												):Play()
											end)
											task.wait(0.32)
											task.delay(0.2, function()
												TweenService:Create(
													v15,
													TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
													{
														Value = 0.01
													}
												):Play()
											end)
											local FX = object2._maid:give(main.Fireball:Clone())
											local v17 = object2._maid:give(Instance.new("NumberValue"))
											v17.Value = 0
											local count = 0
											raiseZIndex({
												FX = FX,
												Count = -2
											})
											v17.Changed:Connect(function()
												count += 1
												FX:ScaleTo(v17.Value)
												FX:PivotTo(anchor * CFrame.new(0, 6 * FX:GetScale(), 0) * CFrame.Angles(
													0,
													math.rad(count * 5),
													0
												))
											end)
											FX.Parent = parent
											game.Debris:AddItem(FX, 0.2)
											local FX2 = object2._maid:give(main.ScreenLines:Clone())
											FX2.Parent = parent
											able({
												FX = FX2,
												On = false
											})
											task.spawn(function()
												local lastTime = tick()

												while tick() - lastTime < 1 do
													FX2:PivotTo(currentCamera.CFrame * CFrame.new(0, 0, -1) * CFrame.Angles(
														0,
														3.141592653589793,
														0
													))
													local RunService = game:GetService("RunService")
													RunService.RenderStepped:Wait()
												end

												able({
													FX = FX2,
													On = false
												})
											end)
											task.delay(0.1, function()
												local v19 = quickFX({
													FX = main.Done,
													Anchor = anchor * CFrame.new(0, -20, 0),
													Maid = object2._maid
												})
												v19:ScaleTo(3)
												playAttachment(v19)
											end)

											-- equivalent calls inferred from this helper; original call sites unknown
											local function Darkness(p2)
												task.spawn(function()
													if p2 then
														TweenService:Create(
															game.Lighting,
															TweenInfo.new(1.827, Enum.EasingStyle.Quad),
															{
																Brightness = 0,
																Ambient = Color3.fromRGB(0, 0, 0),
																OutdoorAmbient = Color3.fromRGB(25, 25, 25)
															}
														):Play()
														TweenService:Create(
															game.Lighting,
															TweenInfo.new(0.65, Enum.EasingStyle.Quad),
															{
																ClockTime = 0
															}
														):Play()
													else
														TweenService:Create(
															game.Lighting,
															TweenInfo.new(1.827, Enum.EasingStyle.Quad),
															{
																Brightness = 2,
																Ambient = Color3.fromRGB(138, 138, 138),
																OutdoorAmbient = Color3.fromRGB(128, 128, 128)
															}
														):Play()
														TweenService:Create(
															game.Lighting,
															TweenInfo.new(0.65, Enum.EasingStyle.Quad),
															{
																ClockTime = 12.302
															}
														):Play()
													end
												end)
											end

											Darkness(true) -- equivalent call inferred; original call site unknown
											task.wait(0.2)
											local FX3 = quickFX({
												FX = main.explo,
												Maid = object2._maid,
												Anchor = CFrame.new(0, 0, 0)
											})
											FX3:ScaleTo(0.4)
											raiseZIndex({
												FX = FX3,
												Count = 4
											})
											FX3:PivotTo(anchor * CFrame.new(0, 7, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1):Inverse())
											local v21 = object2._maid:give(main.Space:Clone())
											v21:PivotTo(anchor * v21:GetAttribute("Offset"):Inverse() * CFrame.new(
												0,
												20,
												0
											))
											v21.Parent = parent
											task.delay(0.6, function()
												playAttachment(FX3)
												raiseZIndex({
													FX = FX3,
													Count = -9
												})
											end)
											task.wait(0.2)
											local folder3 = quickFX({
												FX = main.FinalCrack,
												Anchor = anchor * CFrame.new(-5, 0.2, 0) * CFrame.Angles(0, 0, 0),
												Maid = object2._maid
											})

											for _, beam in pairs(folder3:GetDescendants()) do
												if beam:IsA("Beam") then
													beam.Color = ColorSequence.new(Color3.fromRGB(60, 42, 255))
												end
											end

											folder3:ScaleTo(3)
											local folder4 = quickFX({
												FX = main.Wisp,
												Anchor = anchor,
												Maid = object2._maid
											})
											game.Debris:AddItem(folder4, 2)
											task.delay(0.1, function()
												playAttachment(folder4)
												dtwait(0.5)

												for _, emitter in pairs(folder4:GetDescendants()) do
													if emitter:IsA("ParticleEmitter") then
														TweenService:Create(emitter, TweenInfo.new(0.2), {
															TimeScale = 0
														}):Play()
													end
												end

												dtwait(1)

												for _, emitter in pairs(folder4:GetDescendants()) do
													if emitter:IsA("ParticleEmitter") then
														TweenService:Create(emitter, TweenInfo.new(0.2), {
															TimeScale = 1
														}):Play()
													end
												end
											end)
											local v22 = {}
											task.spawn(function()
												local lastTime = tick()

												while tick() - lastTime < 1.5 do
													for _, model in pairs(v22) do
														if model.Parent and model:IsA("Model") then
															model:SetPrimaryPartCFrame(model.PrimaryPart.CFrame * CFrame.Angles(
																0,
																-0.017453292519943295,
																0
															))
														end
													end

													dtwait(0.02)
												end
											end)
											task.delay(0.2, function()
												local v23 = quickFX({
													FX = main.Glints,
													Maid = object2._maid,
													Anchor = anchor
												})
												v23:ScaleTo(0.4)
												playAttachment(v23)
											end)
											task.spawn(function()
												local cFrame2 = anchor * CFrame.new(0, -35, 0)
												local v24 = {}

												for _ = 1, 30 do
													local clone6 = main.Part:Clone()
													clone6.Shape = Enum.PartType.Ball
													clone6.Material = Enum.Material.Neon
													clone6.Parent = parent
													clone6.Name = "BeamTrail"
													clone6.Anchored = true
													clone6.CanCollide = false
													clone6.Name = "TrailPart"
													clone6.Color = Color3.fromRGB(255, 255, 255)
													object2._maid:give(clone6)
													local v25 = random:NextNumber(0.2, 0.4) * 4
													clone6.Size = Vector3.new(v25, v25, v25)
													clone6.CFrame = cFrame2
													local number = random:NextNumber(2, 3)
													local range = object2._maid:give(Instance.new("NumberValue"))
													range.Value = 0
													TweenService:Create(
														range,
														TweenInfo.new(number, Enum.EasingStyle.Sine),
														{
															Value = random:NextNumber(10, 20) * 4
														}
													):Play()
													TweenService:Create(
														clone6,
														TweenInfo.new(number, Enum.EasingStyle.Sine),
														{
															Size = clone6.Size * 1.5
														}
													):Play()
													task.delay(number, function()
														TweenService:Create(
															clone6,
															TweenInfo.new(number, Enum.EasingStyle.Sine),
															{
																Size = createVector(0, 0, 0)
															}
														):Play()
													end)
													v24[clone6] = {
														Range = range,
														Orientation = CFrame.Angles(
															math.rad((math.random(0, 360))),
															math.rad((math.random(0, 360))),
															(math.rad((math.random(0, 360))))
														),
														Speed = random:NextNumber(0.1, 1) * 6,
														Rise = random:NextNumber(0.05, 0.3) * 8
													}
												end

												local lastTime = tick()
												local count2 = 0

												while tick() - lastTime < 3.4 do
													count2 += 1

													for k, v25 in pairs(v24) do
														local range = v25.Range
														k.CFrame = cFrame2 * CFrame.new(0, v25.Rise * count2, 0) * CFrame.Angles(
															0.4363323129985824,
															math.rad(count2 * v25.Speed),
															0
														) * v25.Orientation * CFrame.Angles(0, 0, 0) * CFrame.new(
															0,
															0,
															range.Value
														)
													end

													dtwait(0.01)
												end
											end)
											local v23 = {}

											for _, part in pairs(folder3:GetChildren()) do
												if not part:IsA("BasePart") then
													continue
												end

												local v24 = {}

												for i = 1, 6 do
													local child = part:FindFirstChild("Top" .. i)
													local child2 = part:FindFirstChild("Bottom" .. i)
													local child3 = part:FindFirstChild("Bottom" .. i - 1)
													part:FindFirstChild("Bottom" .. i + 1)

													if not (child and child2) then
														continue
													end

													local cFrame2 = child2.CFrame
													local original = child3 and v24[i - 1].Original or child2.CFrame
													child2.CFrame = original
													child.CFrame = original
													v24[i] = {
														Top = child,
														Bottom = child2,
														Original = cFrame2
													}
												end

												local raycastParams2 = RaycastParams.new()
												raycastParams2.FilterType = Enum.RaycastFilterType.Include
												raycastParams2.FilterDescendantsInstances = {
													game.Workspace.Built,
													game.Workspace.Map
												}
												task.spawn(function()
													task.spawn(function()
														for k, v27 in pairs(v24) do
															local top = v27.Top
															local bottom = v27.Bottom
															local original = v27.Original
															TweenService:Create(
																bottom,
																TweenInfo.new(0.05, Enum.EasingStyle.Sine),
																{
																	CFrame = original
																}
															):Play()
															TweenService:Create(
																top,
																TweenInfo.new(0.05, Enum.EasingStyle.Sine),
																{
																	CFrame = original * CFrame.new(5 * k, 0, 0)
																}
															):Play()
															dtwait(0.05)
															local raycastResult2 = game.Workspace:Raycast(
																top.WorldCFrame.Position,
																createVector(0, -50, 0),
																raycastParams2
															)

															if not (raycastResult2 and math.random(1, 2) == 1 and (raycastResult2.Position - folder3:GetPivot().Position).Magnitude >= 30) then
																continue
															end

															local parent2 = object2._maid:give(main.RockTemplates:GetChildren()[math.random(
																1,
																#main.RockTemplates:GetChildren()
															)]:Clone())
															parent2.Material = raycastResult2.Instance.Material
															parent2.Color = raycastResult2.Instance.Color
															parent2.CanCollide = false
															parent2.Anchored = true
															parent2.CFrame = bottom.WorldCFrame * CFrame.new(
																random:NextNumber(-10, 10),
																0,
																random:NextNumber(-10, 10)
															) * CFrame.Angles(
																math.rad((math.random(0, 360))),
																math.rad((math.random(0, 360))),
																(math.rad((math.random(0, 360))))
															)
															parent2.Position = Vector3.new(
																parent2.Position.X,
																raycastResult2.Position.Y - math.max(
																	parent2.Size.X,
																	parent2.Size.Y,
																	parent2.Size.Z
																),
																parent2.Position.Z
															)
															parent2.Size *= random:NextNumber(1.2, 1.6)
															parent2.Parent = parent
															game.Debris:AddItem(parent2, 2.5)
															local pointLight = Instance.new("PointLight")
															pointLight.Parent = parent2
															pointLight.Brightness = 8
															pointLight.Color = Color3.new(1, 0, 0)
															pointLight.Range = 10
															table.insert(v23, parent2)
															TweenService:Create(
																parent2,
																TweenInfo.new(
																	random:NextNumber(1, 2),
																	Enum.EasingStyle.Exponential
																),
																{
																	CFrame = CFrame.new(parent2.Position + Vector3.new(
																		0,
																		random:NextNumber(10, 35),
																		0
																	)) * CFrame.Angles(
																		math.rad((math.random(0, 360))),
																		math.rad((math.random(0, 360))),
																		(math.rad((math.random(0, 360))))
																	)
																}
															):Play()
														end
													end)
													task.spawn(function()
														dtwait(0.3)

														for i, beam in pairs(folder3:GetDescendants()) do
															if beam:IsA("Beam") then
																TweenService:Create(
																	beam,
																	TweenInfo.new(
																		tonumber(beam.Name) / 20 + 0.5,
																		Enum.EasingStyle.Sine
																	),
																	{
																		TextureSpeed = 0
																	}
																):Play()
															end
														end

														task.wait(1)

														for i, beam in pairs(folder3:GetDescendants()) do
															if not beam:IsA("Beam") then
																continue
															end

															playTween(beam, {
																Time = 0.15,
																EasingStyle = "Sine",
																Goal = {
																	Transparency = NumberSequence.new({
																		NumberSequenceKeypoint.new(0, 1),
																		NumberSequenceKeypoint.new(1, 1)
																	})
																}
															})
															game.Debris:AddItem(beam, 0.15)
														end
													end)
												end)
											end

											dtwait(4.2)
											playAttachment((quickFX({
												FX = main.Done,
												Anchor = anchor * CFrame.new(0, 10, 0),
												Maid = object2._maid
											})))
											Darkness(false) -- equivalent call inferred; original call site unknown
											dtwait(1.4)
											folder3:Destroy()

											for _, v26 in pairs(v23) do
												v26:Destroy()
											end
										end

										ExploEvent2()
									end

									local function Boom()
										local folder3 = object2._maid:give(morevfx.Glass:Clone())
										folder3.Parent = parent
										folder3:ScaleTo(5)
										folder3:PivotTo(CFrame.new(currentCamera.CFrame.Position) * CFrame.Angles(
											1.5707963267948966,
											0,
											0
										))
										game.Debris:AddItem(folder3, 0.8)
										local now = os.clock()
										local currentCamera2 = game.Workspace.CurrentCamera
										local v14 = {}
										local _ = {
											Front = createVector(0, 0, -1),
											Back = createVector(0, 0, 1),
											Left = createVector(-1, 0, 0),
											Right = createVector(1, 0, 0),
											Top = createVector(0, 1, 0),
											Bottom = createVector(0, -1, 0)
										}
										local v15 = {
											Front = {
												rx = 1,
												lz = 0,
												uy = -1,
												lzY = 0
											},
											Back = {
												rx = -1,
												lz = 0,
												uy = -1,
												lzY = 0
											},
											Left = {
												rx = 0,
												lz = -1,
												uy = -1,
												lzY = 0
											},
											Right = {
												rx = 0,
												lz = 1,
												uy = -1,
												lzY = 0
											},
											Top = {
												rx = 1,
												lz = 0,
												uy = 0,
												lzY = -1
											},
											Bottom = {
												rx = 1,
												lz = 0,
												uy = 0,
												lzY = 1
											}
										}

										local function registerTexture(texture)
											local face = texture:GetAttribute("Face") or tostring(texture.Face)
											local v16 = Enum.NormalId[face]

											if not v16 then
												return
											end

											table.insert(v14, {
												texture = texture,
												map = v15[v16.Name]
											})
										end

										local total2 = 0
										local total3 = 0

										for _, texture in pairs(folder3:GetDescendants()) do
											if texture:IsA("Texture") then
												registerTexture(texture)
											end
										end

										local RunService = game:GetService("RunService")
										local renderSteppedConnection = RunService.RenderStepped:Connect(function()
											local now2 = os.clock()
											local v16 = now2 - now
											now = now2
											local cFrame2 = currentCamera2.CFrame
											local _ = cFrame2.RightVector.X
											local _ = cFrame2.LookVector.Z
											local _ = cFrame2.UpVector.Y
											local v17 = math.clamp(
												((currentCamera2.CFrame.Position - anchor.Position).Magnitude - 2) / 13,
												0,
												1
											)
											local _ = v17 * -2 + 8
											local v18 = (v17 * 0.9 + 0.1) * 1.1
											total2 += v18 * v16
											total3 += v18 * v16 * 0.5

											for _, v19 in ipairs(v14) do
												v19.texture.StudsPerTileU += 3
												v19.texture.StudsPerTileV += 3
											end

											folder3:PivotTo(folder3:GetPivot() * CFrame.Angles(
												0,
												0.017453292519943295,
												0
											))

											for _, v19 in ipairs(v14) do
												local texture = v19.texture
												local _ = v19.map
												local _ = 5 * texture.ZIndex
												texture.OffsetStudsU += 5
												texture.OffsetStudsV += 5
											end
										end)
										task.delay(1, function()
											renderSteppedConnection:Disconnect()
										end)
										anchor *= CFrame.new(0, 0, 0)
										local folder4 = quickFX({
											FX = morevfx.SpaceBoom2,
											Maid = object2._maid,
											Anchor = anchor * CFrame.new(1, -13, 0)
										})
										folder4:ScaleTo(0.3)
										folder4.Parent = parent

										-- equivalent calls inferred from this helper; original call sites unknown
										local function Shards()
											local v16 = anchor
											local v17 = object2._maid:give(Instance.new("NumberValue"))
											v17.Value = 2
											task.spawn(function()
												task.wait(0.5)
												local parent2 = object2._maid:give(Instance.new("Model"))
												parent2.Parent = parent
												local v19 = object2._maid:give(Instance.new("Highlight"))
												v19.OutlineTransparency = -11
												v19.FillTransparency = -10
												v19.Parent = parent2
												v19.FillColor = Color3.fromRGB(167, 40, 241)
												v19.DepthMode = Enum.HighlightDepthMode.Occluded
												local lastTime = tick()

												while tick() - lastTime < 2 do
													for _ = 1, 3 do
														local number = random:NextNumber(0.05, 0.07)
														local clone6 = morevfx.ShardSphere:Clone()
														local _ = math.random(1, 2) == 1
														game.Debris:AddItem(clone6, number)
														clone6.Color = Color3.fromRGB(101, 255, 152)
														local v20 = random:NextNumber(-20, 20) * 2
														local v21 = random:NextNumber(-20, 20) * 2
														local v22 = v16 * CFrame.new(v20, math.random(90, 200), v21)
														clone6.CFrame = CFrame.new(
															v16 * CFrame.new(v20, math.random(10, 15), v21).Position,
															v22.Position
														) * CFrame.Angles(1.5707963267948966, 0, 0)
														clone6.Parent = parent2
														local number2 = random:NextNumber(1, 3)
														clone6.Mesh.Scale = Vector3.new(
															number2,
															math.random(25, 35),
															number2
														) * 1.4 * v17.Value
														playTween(clone6, {
															EasingStyle = "Sine",
															Time = number,
															Goal = {
																Position = v22.Position
															}
														})
														playTween(clone6.Mesh, {
															EasingStyle = "Sine",
															Time = number,
															Goal = {
																Scale = Vector3.new(
																	0,
																	math.random(30, 40) * 1.4 * v17.Value,
																	0
																)
															}
														})
													end

													task.wait(0.05)
												end
											end)
										end

										Shards() -- equivalent call inferred; original call site unknown
										local v16 = object2._maid:give(Instance.new("NumberValue"))
										object2._maid:giveTask(v16.Changed:Connect(function()
											folder4:ScaleTo(v16.Value)
										end))

										for _, emitter in pairs(folder4:GetDescendants()) do
											if not emitter:IsA("ParticleEmitter") then
												continue
											end

											local lifetime = emitter.Lifetime
											local speed = emitter.Speed
											emitter.Rate *= 2
											emitter.Speed = NumberRange.new(speed.Min / 2, speed.Max / 2)
											emitter.Lifetime = NumberRange.new(lifetime.Min / 2, lifetime.Max / 2)
											emitter.Drag *= 2
										end

										local FX = nil
										task.delay(0.2, function()
											FX = object2._maid:give(morevfx.Glint:Clone())
											FX:ScaleTo(0.01)
											FX:PivotTo(anchor)
											FX.Parent = parent
											local v18 = object2._maid:give(Instance.new("NumberValue"))
											object2._maid:giveTask(v18.Changed:Connect(function()
												FX:ScaleTo(v18.Value)
											end))
											v18.Value = FX:GetScale()
											TweenService:Create(v18, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {
												Value = 2
											}):Play()
											raiseZIndex({
												FX = FX,
												Count = 15
											})
											local v19 = object2._maid:give(Instance.new("CFrameValue"))
											v19.Value = FX:GetPivot()
											local v20 = object2._maid:give(Instance.new("NumberValue"))
											v20.Value = 1
											TweenService:Create(v20, TweenInfo.new(2, Enum.EasingStyle.Sine), {
												Value = 3
											}):Play()
											TweenService:Create(v19, TweenInfo.new(3, Enum.EasingStyle.Sine), {
												Value = v19.Value * CFrame.new(0, 75, 0)
											}):Play()
											task.spawn(function()
												local lastTime = tick()

												while tick() - lastTime < 4 do
													FX:PivotTo(v19.Value * CFrame.new(
														random:NextNumber(-v20.Value, v20.Value),
														random:NextNumber(-v20.Value, v20.Value),
														random:NextNumber(-v20.Value, v20.Value)
													))
													dtwait(0.01)
												end
											end)
										end)
										task.delay(0.5, function()
											local v18 = quickFX({
												FX = morevfx.Done,
												Maid = object2._maid,
												Anchor = anchor
											})
											v18.Parent = parent
											playAttachment(v18)
										end)
										task.spawn(function()
											local count = 0

											for _ = 1, 5 do
												local folder5 = object2._maid:give(morevfx.mybrainissocookedatthispoint:Clone())
												folder5:PivotTo(anchor * CFrame.new(0, count * 2, 0))
												folder5.Parent = parent
												folder5:ScaleTo(count * 0.1 + 0.5)

												for _, descendant in pairs(folder5:GetDescendants()) do
													local effectDuration = descendant:GetAttribute("EffectDuration")

													if effectDuration then
														descendant:SetAttribute(
															"EffectDuration",
															NumberRange.new(
																effectDuration.Min * 0.5,
																effectDuration.Max * 0.5
															)
														)
													end
												end

												count += 1
												shared.vfx.emit(folder5)
												task.wait(0.1)
											end
										end)
										v16.Value = folder4:GetScale()
										task.wait(0.3)
										able({
											FX = FX,
											On = false
										})
										TweenService:Create(v16, TweenInfo.new(4, Enum.EasingStyle.Sine), {
											Value = 4
										}):Play()
										task.delay(1, function()
											TweenService:Create(v16, TweenInfo.new(1, Enum.EasingStyle.Sine), {
												Value = 1
											}):Play()
										end)
										task.delay(0.5, function()
											able({
												FX = FX,
												On = false
											})
											task.wait(1.7)
											able({
												FX = folder4,
												On = false
											})
										end)
									end

									task.delay(0.15, Boom)
									local main = vfx.main

									local function ExploEvent2()
										local v14 = object2._maid:give(morevfx["explosion MeshEmitter"]:Clone())
										v14.Parent = parent
										v14:ScaleTo(0.01)
										local v15 = object2._maid:give(Instance.new("NumberValue"))
										object2._maid:giveTask(v15.Changed:Connect(function()
											v14:ScaleTo(v15.Value)
										end))
										v14:PivotTo(anchor * CFrame.new(0, -6, 0))
										v15.Value = v14:GetScale()
										TweenService:Create(v15, TweenInfo.new(1, Enum.EasingStyle.Sine), {
											Value = 2
										}):Play()
										TweenService:Create(v14.PrimaryPart, TweenInfo.new(3, Enum.EasingStyle.Quad), {
											CFrame = v14:GetPivot() * CFrame.new(0, 50, 0)
										}):Play()
										task.delay(0.5, function()
											TweenService:Create(
												v14.PrimaryPart,
												TweenInfo.new(3, Enum.EasingStyle.Quad),
												{
													CFrame = v14:GetPivot() * CFrame.new(0, 120, 0)
												}
											):Play()
										end)
										task.wait(0.32)
										task.delay(0.2, function()
											TweenService:Create(v15, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {
												Value = 0.01
											}):Play()
										end)
										local FX = object2._maid:give(main.Fireball:Clone())
										local v17 = object2._maid:give(Instance.new("NumberValue"))
										v17.Value = 0
										local count = 0
										raiseZIndex({
											FX = FX,
											Count = -2
										})
										v17.Changed:Connect(function()
											count += 1
											FX:ScaleTo(v17.Value)
											FX:PivotTo(anchor * CFrame.new(0, 6 * FX:GetScale(), 0) * CFrame.Angles(
												0,
												math.rad(count * 5),
												0
											))
										end)
										FX.Parent = parent
										game.Debris:AddItem(FX, 0.2)
										local FX2 = object2._maid:give(main.ScreenLines:Clone())
										FX2.Parent = parent
										able({
											FX = FX2,
											On = false
										})
										task.spawn(function()
											local lastTime = tick()

											while tick() - lastTime < 1 do
												FX2:PivotTo(currentCamera.CFrame * CFrame.new(0, 0, -1) * CFrame.Angles(
													0,
													3.141592653589793,
													0
												))
												local RunService = game:GetService("RunService")
												RunService.RenderStepped:Wait()
											end

											able({
												FX = FX2,
												On = false
											})
										end)
										task.delay(0.1, function()
											local v19 = quickFX({
												FX = main.Done,
												Anchor = anchor * CFrame.new(0, -20, 0),
												Maid = object2._maid
											})
											v19:ScaleTo(3)
											playAttachment(v19)
										end)

										-- equivalent calls inferred from this helper; original call sites unknown
										local function Darkness(p2)
											task.spawn(function()
												if p2 then
													TweenService:Create(
														game.Lighting,
														TweenInfo.new(1.827, Enum.EasingStyle.Quad),
														{
															Brightness = 0,
															Ambient = Color3.fromRGB(0, 0, 0),
															OutdoorAmbient = Color3.fromRGB(25, 25, 25)
														}
													):Play()
													TweenService:Create(
														game.Lighting,
														TweenInfo.new(0.65, Enum.EasingStyle.Quad),
														{
															ClockTime = 0
														}
													):Play()
												else
													TweenService:Create(
														game.Lighting,
														TweenInfo.new(1.827, Enum.EasingStyle.Quad),
														{
															Brightness = 2,
															Ambient = Color3.fromRGB(138, 138, 138),
															OutdoorAmbient = Color3.fromRGB(128, 128, 128)
														}
													):Play()
													TweenService:Create(
														game.Lighting,
														TweenInfo.new(0.65, Enum.EasingStyle.Quad),
														{
															ClockTime = 12.302
														}
													):Play()
												end
											end)
										end

										Darkness(true) -- equivalent call inferred; original call site unknown
										task.wait(0.2)
										local FX3 = quickFX({
											FX = main.explo,
											Maid = object2._maid,
											Anchor = CFrame.new(0, 0, 0)
										})
										FX3:ScaleTo(0.4)
										raiseZIndex({
											FX = FX3,
											Count = 4
										})
										FX3:PivotTo(anchor * CFrame.new(0, 7, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1):Inverse())
										local v21 = object2._maid:give(main.Space:Clone())
										v21:PivotTo(anchor * v21:GetAttribute("Offset"):Inverse() * CFrame.new(0, 20, 0))
										v21.Parent = parent
										task.delay(0.6, function()
											playAttachment(FX3)
											raiseZIndex({
												FX = FX3,
												Count = -9
											})
										end)
										task.wait(0.2)
										local folder3 = quickFX({
											FX = main.FinalCrack,
											Anchor = anchor * CFrame.new(-5, 0.2, 0) * CFrame.Angles(0, 0, 0),
											Maid = object2._maid
										})

										for _, beam in pairs(folder3:GetDescendants()) do
											if beam:IsA("Beam") then
												beam.Color = ColorSequence.new(Color3.fromRGB(60, 42, 255))
											end
										end

										folder3:ScaleTo(3)
										local folder4 = quickFX({
											FX = main.Wisp,
											Anchor = anchor,
											Maid = object2._maid
										})
										game.Debris:AddItem(folder4, 2)
										task.delay(0.1, function()
											playAttachment(folder4)
											dtwait(0.5)

											for _, emitter in pairs(folder4:GetDescendants()) do
												if emitter:IsA("ParticleEmitter") then
													TweenService:Create(emitter, TweenInfo.new(0.2), {
														TimeScale = 0
													}):Play()
												end
											end

											dtwait(1)

											for _, emitter in pairs(folder4:GetDescendants()) do
												if emitter:IsA("ParticleEmitter") then
													TweenService:Create(emitter, TweenInfo.new(0.2), {
														TimeScale = 1
													}):Play()
												end
											end
										end)
										local v22 = {}
										task.spawn(function()
											local lastTime = tick()

											while tick() - lastTime < 1.5 do
												for _, model in pairs(v22) do
													if model.Parent and model:IsA("Model") then
														model:SetPrimaryPartCFrame(model.PrimaryPart.CFrame * CFrame.Angles(
															0,
															-0.017453292519943295,
															0
														))
													end
												end

												dtwait(0.02)
											end
										end)
										task.delay(0.2, function()
											local v23 = quickFX({
												FX = main.Glints,
												Maid = object2._maid,
												Anchor = anchor
											})
											v23:ScaleTo(0.4)
											playAttachment(v23)
										end)
										task.spawn(function()
											local cFrame2 = anchor * CFrame.new(0, -35, 0)
											local v24 = {}

											for _ = 1, 30 do
												local clone6 = main.Part:Clone()
												clone6.Shape = Enum.PartType.Ball
												clone6.Material = Enum.Material.Neon
												clone6.Parent = parent
												clone6.Name = "BeamTrail"
												clone6.Anchored = true
												clone6.CanCollide = false
												clone6.Name = "TrailPart"
												clone6.Color = Color3.fromRGB(255, 255, 255)
												object2._maid:give(clone6)
												local v25 = random:NextNumber(0.2, 0.4) * 4
												clone6.Size = Vector3.new(v25, v25, v25)
												clone6.CFrame = cFrame2
												local number = random:NextNumber(2, 3)
												local range = object2._maid:give(Instance.new("NumberValue"))
												range.Value = 0
												TweenService:Create(
													range,
													TweenInfo.new(number, Enum.EasingStyle.Sine),
													{
														Value = random:NextNumber(10, 20) * 4
													}
												):Play()
												TweenService:Create(
													clone6,
													TweenInfo.new(number, Enum.EasingStyle.Sine),
													{
														Size = clone6.Size * 1.5
													}
												):Play()
												task.delay(number, function()
													TweenService:Create(
														clone6,
														TweenInfo.new(number, Enum.EasingStyle.Sine),
														{
															Size = createVector(0, 0, 0)
														}
													):Play()
												end)
												v24[clone6] = {
													Range = range,
													Orientation = CFrame.Angles(
														math.rad((math.random(0, 360))),
														math.rad((math.random(0, 360))),
														(math.rad((math.random(0, 360))))
													),
													Speed = random:NextNumber(0.1, 1) * 6,
													Rise = random:NextNumber(0.05, 0.3) * 8
												}
											end

											local lastTime = tick()
											local count2 = 0

											while tick() - lastTime < 3.4 do
												count2 += 1

												for k, v25 in pairs(v24) do
													local range = v25.Range
													k.CFrame = cFrame2 * CFrame.new(0, v25.Rise * count2, 0) * CFrame.Angles(
														0.4363323129985824,
														math.rad(count2 * v25.Speed),
														0
													) * v25.Orientation * CFrame.Angles(0, 0, 0) * CFrame.new(
														0,
														0,
														range.Value
													)
												end

												dtwait(0.01)
											end
										end)
										local v23 = {}

										for _, part in pairs(folder3:GetChildren()) do
											if not part:IsA("BasePart") then
												continue
											end

											local v24 = {}

											for i = 1, 6 do
												local child = part:FindFirstChild("Top" .. i)
												local child2 = part:FindFirstChild("Bottom" .. i)
												local child3 = part:FindFirstChild("Bottom" .. i - 1)
												part:FindFirstChild("Bottom" .. i + 1)

												if not (child and child2) then
													continue
												end

												local cFrame2 = child2.CFrame
												local original = child3 and v24[i - 1].Original or child2.CFrame
												child2.CFrame = original
												child.CFrame = original
												v24[i] = {
													Top = child,
													Bottom = child2,
													Original = cFrame2
												}
											end

											local raycastParams2 = RaycastParams.new()
											raycastParams2.FilterType = Enum.RaycastFilterType.Include
											raycastParams2.FilterDescendantsInstances = {
												game.Workspace.Built,
												game.Workspace.Map
											}
											task.spawn(function()
												task.spawn(function()
													for k, v27 in pairs(v24) do
														local top = v27.Top
														local bottom = v27.Bottom
														local original = v27.Original
														TweenService:Create(
															bottom,
															TweenInfo.new(0.05, Enum.EasingStyle.Sine),
															{
																CFrame = original
															}
														):Play()
														TweenService:Create(
															top,
															TweenInfo.new(0.05, Enum.EasingStyle.Sine),
															{
																CFrame = original * CFrame.new(5 * k, 0, 0)
															}
														):Play()
														dtwait(0.05)
														local raycastResult2 = game.Workspace:Raycast(
															top.WorldCFrame.Position,
															createVector(0, -50, 0),
															raycastParams2
														)

														if not (raycastResult2 and math.random(1, 2) == 1 and (raycastResult2.Position - folder3:GetPivot().Position).Magnitude >= 30) then
															continue
														end

														local parent2 = object2._maid:give(main.RockTemplates:GetChildren()[math.random(
															1,
															#main.RockTemplates:GetChildren()
														)]:Clone())
														parent2.Material = raycastResult2.Instance.Material
														parent2.Color = raycastResult2.Instance.Color
														parent2.CanCollide = false
														parent2.Anchored = true
														parent2.CFrame = bottom.WorldCFrame * CFrame.new(
															random:NextNumber(-10, 10),
															0,
															random:NextNumber(-10, 10)
														) * CFrame.Angles(
															math.rad((math.random(0, 360))),
															math.rad((math.random(0, 360))),
															(math.rad((math.random(0, 360))))
														)
														parent2.Position = Vector3.new(
															parent2.Position.X,
															raycastResult2.Position.Y - math.max(
																parent2.Size.X,
																parent2.Size.Y,
																parent2.Size.Z
															),
															parent2.Position.Z
														)
														parent2.Size *= random:NextNumber(1.2, 1.6)
														parent2.Parent = parent
														game.Debris:AddItem(parent2, 2.5)
														local pointLight = Instance.new("PointLight")
														pointLight.Parent = parent2
														pointLight.Brightness = 8
														pointLight.Color = Color3.new(1, 0, 0)
														pointLight.Range = 10
														table.insert(v23, parent2)
														TweenService:Create(
															parent2,
															TweenInfo.new(
																random:NextNumber(1, 2),
																Enum.EasingStyle.Exponential
															),
															{
																CFrame = CFrame.new(parent2.Position + Vector3.new(
																	0,
																	random:NextNumber(10, 35),
																	0
																)) * CFrame.Angles(
																	math.rad((math.random(0, 360))),
																	math.rad((math.random(0, 360))),
																	(math.rad((math.random(0, 360))))
																)
															}
														):Play()
													end
												end)
												task.spawn(function()
													dtwait(0.3)

													for i, beam in pairs(folder3:GetDescendants()) do
														if beam:IsA("Beam") then
															TweenService:Create(
																beam,
																TweenInfo.new(
																	tonumber(beam.Name) / 20 + 0.5,
																	Enum.EasingStyle.Sine
																),
																{
																	TextureSpeed = 0
																}
															):Play()
														end
													end

													task.wait(1)

													for i, beam in pairs(folder3:GetDescendants()) do
														if not beam:IsA("Beam") then
															continue
														end

														playTween(beam, {
															Time = 0.15,
															EasingStyle = "Sine",
															Goal = {
																Transparency = NumberSequence.new({
																	NumberSequenceKeypoint.new(0, 1),
																	NumberSequenceKeypoint.new(1, 1)
																})
															}
														})
														game.Debris:AddItem(beam, 0.15)
													end
												end)
											end)
										end

										dtwait(4.2)
										playAttachment((quickFX({
											FX = main.Done,
											Anchor = anchor * CFrame.new(0, 10, 0),
											Maid = object2._maid
										})))
										Darkness(false) -- equivalent call inferred; original call site unknown
										dtwait(1.4)
										folder3:Destroy()

										for _, v26 in pairs(v23) do
											v26:Destroy()
										end
									end

									ExploEvent2()
								end,
								pillar = function()
									Thebeam()
									task.wait(2.45)

									for _, v11 in pairs(v9) do
										v11:Stop()
									end

									track4:Stop()
									inside()
									clone2:PivotTo(clone2:GetPivot() * CFrame.new(0, -10, 0))
								end
							}
							local connections = {}

							for k, v11 in pairs(v10) do
								table.insert(connections, (track4:GetMarkerReachedSignal(k):Connect(v11)))
							end

							task.delay(20, function()
								for _, connection in pairs(connections) do
									connection:Disconnect()
								end
							end)
						end

						NewLand()
					end,
					torn = function()
						task.wait(0.2)
						local v9 = {
							{
								"rbxassetid://126345619062862",
								"rbxassetid://99303886332474",
								"rbxassetid://121637092604416",
								"rbxassetid://113029456950748",
								"rbxassetid://138572874693768",
								"rbxassetid://92607920533530",
								"rbxassetid://138142224621278",
								"rbxassetid://120065192728444",
								"rbxassetid://70411827948913",
								"rbxassetid://71491448109970",
								"rbxassetid://85524876848679",
								"rbxassetid://84060367679631",
								"rbxassetid://98004646393019",
								"rbxassetid://139881862115187",
								"rbxassetid://75646293133592",
								"rbxassetid://82260360973815",
								"rbxassetid://80749449158947",
								"rbxassetid://75562819739007",
								"rbxassetid://78560402198235",
								"rbxassetid://134122785594190",
								"rbxassetid://122238912891286",
								"rbxassetid://83757815885857"
							},
							{
								"rbxassetid://79659437605905",
								"rbxassetid://118290359008121",
								"rbxassetid://93612183410156",
								"rbxassetid://79503345167950",
								"rbxassetid://75259404133000",
								"rbxassetid://123404852590285",
								"rbxassetid://89121436722950",
								"rbxassetid://122757847245395",
								"rbxassetid://110337433498526",
								"rbxassetid://82000074938026",
								"rbxassetid://96669627548575",
								"rbxassetid://113917452449518",
								"rbxassetid://133381373610534",
								"rbxassetid://138651759212140",
								"rbxassetid://120620024709807",
								"rbxassetid://95006064285568",
								"rbxassetid://135806306899349",
								"rbxassetid://134049946195990",
								"rbxassetid://77590421805120",
								"rbxassetid://71393365951006",
								"rbxassetid://94079431186519"
							}
						}
						local object2 = setmetatable({}, class)
						object2._maid = maid.new()
						local v10 = false

						-- equivalent calls inferred from this helper; original call sites unknown
						local function Clean2()
							if not v10 then
								v10 = true
								object2._maid:doCleaning()
							end
						end

						task.delay(15, function()
							Clean2() -- equivalent call inferred; original call site unknown
						end)
						local main = vfx.main
						local v11 = cFrame * CFrame.new(11, -3, 0)
						game.Lighting.ClockTime = 6.4
						task.delay(0.1, function()
							local FX = quickFX({
								FX = vfx.main.Pre,
								Maid = object2._maid,
								Anchor = v11 * CFrame.new(0, 800, 0)
							})
							FX:ScaleTo(6)
							lifeScale({
								FX = FX,
								Scale = 1
							})
							playAttachment(FX)
						end)
						task.spawn(function()
							local function OPTornado(part)
								-- equivalent calls inferred from this helper; original call sites unknown
								local function Darkness(p2)
									task.spawn(function()
										if p2 then
											TweenService:Create(
												game.Lighting,
												TweenInfo.new(1.827, Enum.EasingStyle.Quad),
												{
													Brightness = 0,
													Ambient = Color3.fromRGB(0, 0, 0),
													OutdoorAmbient = Color3.fromRGB(25, 25, 25)
												}
											):Play()
											TweenService:Create(
												game.Lighting,
												TweenInfo.new(0.65, Enum.EasingStyle.Quad),
												{
													ClockTime = 6.4
												}
											):Play()
										else
											TweenService:Create(
												game.Lighting,
												TweenInfo.new(1.827, Enum.EasingStyle.Quad),
												{
													Brightness = 2,
													Ambient = Color3.fromRGB(138, 138, 138),
													OutdoorAmbient = Color3.fromRGB(128, 128, 128)
												}
											):Play()
											TweenService:Create(
												game.Lighting,
												TweenInfo.new(0.65, Enum.EasingStyle.Quad),
												{
													ClockTime = 12.302
												}
											):Play()
										end
									end)
								end

								Darkness(true) -- equivalent call inferred; original call site unknown
								task.spawn(function()
									local lastTime = tick()
									local v13 = object2._maid:give(main.TornPart:Clone())
									v13.CFrame = part.CFrame * CFrame.new(0, 20, 0)
									v13.Anchored = true
									v13.Transparency = 1
									v13.Parent = EFP
									v13:PivotTo(clone2:GetPivot() * CFrame.new(
										89.4429779,
										-723,
										-3.57936382,
										0,
										0,
										1,
										0,
										1,
										0,
										-1,
										0,
										0
									):Inverse())
									playAttachment(v13)
									local clone6 = main.SkyRing:Clone()
									clone6:ScaleTo(2)
									playMesh({
										Model = clone6,
										Anchor = v13.CFrame,
										Info = TweenInfo.new(2, Enum.EasingStyle.Exponential)
									})
									local v14 = clone2:GetPivot() * CFrame.new(
										89.4429779,
										-703,
										-3.57936382,
										0,
										0,
										1,
										0,
										1,
										0,
										-1,
										0,
										0
									):Inverse()

									local function CloudBeam(anchor)
										local folder3 = quickFX({
											FX = main.CloudBeam,
											Maid = object2._maid,
											Anchor = anchor
										})
										folder3:ScaleTo(2)

										for _, beam in pairs(folder3:GetDescendants()) do
											if not beam:IsA("Beam") then
												continue
											end

											local textureSpeed = beam.TextureSpeed
											beam.FaceCamera = true
											beam.TextureSpeed *= -25
											beam.Brightness *= 13
											local transparency = beam.Transparency
											beam.Width0 *= 2
											beam.Width1 *= 2
											beam.Transparency = NumberSequence.new({
												NumberSequenceKeypoint.new(0, 1),
												NumberSequenceKeypoint.new(1, 1)
											})
											TweenService:Create(beam, TweenInfo.new(0.8, Enum.EasingStyle.Sine), {
												TextureSpeed = textureSpeed * -295
											}):Play()
											local v15 = beam
											task.delay(0.15, function()
												playTween(v15, {
													Time = 0.15,
													EasingStyle = "Sine",
													Goal = {
														Transparency = transparency
													}
												})
											end)
										end

										game.Debris:AddItem(folder3, 3)
									end

									CloudBeam(v14 * CFrame.new(
										750,
										-63.5003738,
										-3.09774566,
										-4.37113883e-8,
										1,
										4.37113883e-8,
										1,
										4.37113918e-8,
										-4.37113847e-8,
										-4.37113883e-8,
										4.37113847e-8,
										-1
									):Inverse())
									CloudBeam(v14 * CFrame.new(
										750,
										-148.500366,
										146.902252,
										-4.37113883e-8,
										1,
										4.37113883e-8,
										1,
										4.37113918e-8,
										-4.37113847e-8,
										-4.37113883e-8,
										4.37113847e-8,
										-1
									):Inverse())
									CloudBeam(v14 * CFrame.new(
										750,
										3.09774828,
										-213.500366,
										-4.37113883e-8,
										1,
										4.37113883e-8,
										0,
										-4.37113883e-8,
										1,
										1,
										4.37113883e-8,
										1.91068547e-15
									):Inverse())
									CloudBeam(v14 * CFrame.new(
										750,
										-196.902252,
										-193.500366,
										-4.37113883e-8,
										1,
										4.37113883e-8,
										0,
										-4.37113883e-8,
										1,
										1,
										4.37113883e-8,
										1.91068547e-15
									):Inverse())

									local function LightningCircle(p2, value, p3, value2, p4, value3, p5)
										local v15 = math.random(-15, 15)
										local v16 = math.random(-15, 15)
										local v17 = value3 or 1
										local effect = ObjectService.CreateEffect(
											"Model",
											main.LightningPoints,
											v13.CFrame * CFrame.new(0, 3, 2) * CFrame.Angles(
												math.rad(v16),
												0,
												(math.rad(v15))
											),
											EFP
										)
										effect.Object:ScaleTo(p4 or math.random(10, 15) * 0.1)

										if p5 ~= nil then
											effect.Object:ScaleTo(effect.Object:GetScale() * p5)
										end

										BeamLightning.new(
											effect.Object.LP1,
											effect.Object.LP2,
											8,
											7,
											CFrame.new(5, 0, 0),
											value or 0.5,
											p3 or math.random(1, 3),
											value2 or 0.5,
											0.5 / v17,
											"Cubic",
											"Out",
											0.25,
											1.0125000000000002,
											nil,
											p2
										):Destroy(
											0.15 / v17,
											0.55 / v17,
											"Bounce",
											"Out"
										)
										BeamLightning.new(
											effect.Object.LP2,
											effect.Object.LP3,
											8,
											7,
											CFrame.new(5, 0, 0),
											value or 0.5,
											p3 or math.random(1, 3),
											value2 or 0.5,
											0.5 / v17,
											"Cubic",
											"Out",
											0.25,
											1.0125000000000002,
											nil,
											p2
										):Destroy(
											0.15 / v17,
											0.55 / v17,
											"Bounce",
											"Out"
										)
										BeamLightning.new(
											effect.Object.LP3,
											effect.Object.LP4,
											8,
											7,
											CFrame.new(5, 0, 0),
											value or 0.5,
											p3 or math.random(1, 3),
											value2 or 0.5,
											0.5 / v17,
											"Cubic",
											"Out",
											0.25,
											1.0125000000000002,
											nil,
											p2
										):Destroy(
											0.15 / v17,
											0.55 / v17,
											"Bounce",
											"Out"
										)
										BeamLightning.new(
											effect.Object.LP4,
											effect.Object.LP1,
											8,
											7,
											CFrame.new(5, 0, 0),
											value or 0.5,
											p3 or math.random(1, 3),
											value2 or 0.5,
											0.5 / v17,
											"Cubic",
											"Out",
											0.25,
											1.0125000000000002,
											nil,
											p2
										):Destroy(
											0.15 / v17,
											0.55 / v17,
											"Bounce",
											"Out"
										)
										effect:Destroy(0.15)
									end

									local function LightningRod(value, _)
										local _ = math.random(-25, -5) * 44
										local v15 = math.random(-180, 180)
										local v16 = value or 1
										local effect = ObjectService.CreateEffect(
											"Model",
											main.LightningStrike,
											v13.CFrame * CFrame.new(0, 0, 2) * CFrame.Angles(0, math.rad(v15), 0),
											EFP
										)
										effect.Object.Bottom.CFrame = v13.CFrame
										effect.Object.Top.CFrame = v13.CFrame * CFrame.new(
											random:NextNumber(-90, 90),
											random:NextNumber(0, 180),
											random:NextNumber(-90, 90)
										)
										BeamLightning.new(
											effect.Object.Top,
											effect.Object.Bottom,
											10,
											10,
											CFrame.new(math.random(-10, 10), 0, 0),
											4,
											math.random(2, 4) * 4,
											math.random(2, 4) * 4,
											0.5 / v16,
											"Cubic",
											"Out",
											0.25,
											3.75,
											nil,
											main.Beam5
										):Destroy(
											0.15 / v16,
											0.55 / v16,
											"Bounce",
											"Out"
										)
										effect:Destroy(0.15 / v16)
									end

									local function LightningRod2(value, _)
										local v15 = math.random(-25, -5)
										local v16 = math.random(-180, 180)
										local v17 = value or 1
										local v18 = math.random(-75, 75)
										local v19 = math.random(-75, 75)
										local effect = ObjectService.CreateEffect(
											"Model",
											main.LightningStrike2,
											v13.CFrame * CFrame.new(0, 0, 2) * CFrame.Angles(0, math.rad(v16), 0) * CFrame.new(
												v15,
												-3,
												0
											) * CFrame.Angles(math.rad(v18), 0, (math.rad(v19))),
											EFP
										)
										effect.Object.Bottom.CFrame = v13.CFrame
										effect.Object.Top.CFrame = v13.CFrame * CFrame.new(
											random:NextNumber(-90, 90),
											random:NextNumber(0, 180),
											random:NextNumber(-90, 90)
										)
										BeamLightning.new(
											effect.Object.Top,
											effect.Object.Bottom,
											7,
											10,
											CFrame.new(math.random(-10, 10), 0, 0),
											4,
											math.random(2, 4) * 4,
											math.random(2, 4) * 4,
											0.5 / v17,
											"Cubic",
											"Out",
											0.25,
											3.75,
											nil,
											main.Beam5
										):Destroy(
											0.15 / v17,
											0.55 / v17,
											"Bounce",
											"Out"
										)
										effect:Destroy(0.15 / v17)
									end

									local function LightningRod3(p2)
										local v15 = math.rad((math.random(-180, 180)))
										local v16 = math.rad((math.random(-180, 180)))
										local v17 = math.rad((math.random(-180, 180)))
										local effect = ObjectService.CreateEffect(
											"Model",
											main.BodyLightning,
											v13.CFrame * CFrame.new(0, 0, 0) * CFrame.Angles(v15, v16, v17),
											EFP
										)

										if p2 ~= nil then
											effect.Object:ScaleTo(effect.Object:GetScale() * p2)
											effect.Object:PivotTo(v13.CFrame * CFrame.new(0, 0, 0) * CFrame.Angles(
												v15,
												v16,
												v17
											))
										end

										BeamLightning.new(
											effect.Object.Bottom,
											effect.Object.Top,
											5,
											math.random(1, 2),
											CFrame.new(),
											0.5,
											math.random(1, 2),
											0.5,
											0.35,
											"Cubic",
											"Out",
											0.25,
											3.25,
											nil,
											main.Beam2
										):Destroy(
											0.1,
											0.55,
											"Bounce",
											"Out"
										)
										effect:Destroy(0.1)
									end

									local v15 = LoopService.LoopWithFunctions(0.01, {
										{
											Iterations = 8,
											Function = function() end
										},
										{
											Iterations = 8,
											Function = function()
												LightningRod()
												LightningRod2()
											end
										},
										{
											Iterations = 2,
											Function = function() end
										}
									})
									task.delay(1, function()
										v15:EndLoop()
									end)
									local v16 = object2._maid:give(main.Inner:Clone())
									local v17 = object2._maid:give(Instance.new("NumberValue"))
									v17.Value = 0
									TweenService:Create(v17, TweenInfo.new(0.5, Enum.EasingStyle.Bounce), {
										Value = 775
									}):Play()
									local v18 = object2._maid:give(Instance.new("NumberValue"))
									v18.Value = 1
									local v19 = object2._maid:give(Instance.new("NumberValue"))
									v19.Value = 5
									TweenService:Create(v19, TweenInfo.new(0.6, Enum.EasingStyle.Sine), {
										Value = 1
									}):Play()
									task.delay(0.1, function()
										TweenService:Create(v17, TweenInfo.new(0.45, Enum.EasingStyle.Bounce), {
											Value = 11
										}):Play()
										task.wait(0.75)
										TweenService:Create(v17, TweenInfo.new(0.25, Enum.EasingStyle.Bounce), {
											Value = 21
										}):Play()
									end)
									local v20 = object2._maid:give(Instance.new("NumberValue"))
									v20.Value = 0
									TweenService:Create(v20, TweenInfo.new(1, Enum.EasingStyle.Sine), {
										Value = 195
									}):Play()
									local v21 = object2._maid:give(Instance.new("NumberValue"))
									v21.Value = 0.1
									TweenService:Create(v21, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
										Value = 4
									}):Play()
									task.delay(0.1, function()
										TweenService:Create(v21, TweenInfo.new(0.7, Enum.EasingStyle.Sine), {
											Value = 1
										}):Play()
									end)
									local v22 = object2._maid:give(Instance.new("NumberValue"))
									v22.Value = 1
									TweenService:Create(v22, TweenInfo.new(1, Enum.EasingStyle.Sine), {
										Value = 21
									}):Play()
									local v23 = object2._maid:give(Instance.new("NumberValue"))
									v23.Value = 0
									TweenService:Create(v23, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
										Value = 0.25
									}):Play()
									local v24 = object2._maid:give(Instance.new("NumberValue"))
									v24.Value = 5
									TweenService:Create(v24, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
										Value = 0.5
									}):Play()
									task.delay(0.4, function()
										TweenService:Create(v18, TweenInfo.new(1, Enum.EasingStyle.Sine), {
											Value = 5
										}):Play()
										task.wait(0.2)
										TweenService:Create(v21, TweenInfo.new(0.7, Enum.EasingStyle.Sine), {
											Value = 1.4
										}):Play()
										TweenService:Create(v24, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {
											Value = 3
										}):Play()
										task.wait(0.25)
									end)
									local total2 = 0
									local v25 = {}
									local v26 = {}

									while tick() - lastTime < 0.9 do
										total2 += 0.5
										local v27 = object2._maid:give(main.New:Clone())
										local color3 = v27.PrimaryPart.Decal.Color3
										local value = v19.Value
										v27.PrimaryPart.Decal.Color3 = Color3.fromRGB(
											855 * value,
											170 * value,
											50 * value
										)
										TweenService:Create(
											v27.PrimaryPart.Decal,
											TweenInfo.new(0.1 * v18.Value, Enum.EasingStyle.Sine),
											{
												Color3 = color3
											}
										):Play()
										local orientation, _, _ = CFrame.new(
											v13.Position,
											part.CFrame * CFrame.new(0, v20.Value, 0).Position
										):ToOrientation()
										local angle = orientation * v23.Value
										v27:PivotTo(v13.CFrame * CFrame.Angles(angle, 0, 0))
										v27.Parent = EFP
										local scale = object2._maid:give(Instance.new("NumberValue"))
										scale.Value = 0.2 * v21.Value
										TweenService:Create(scale, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
											Value = 1 * random:NextNumber(1, 1.5) * 2.5
										}):Play()
										local progress2 = object2._maid:give(Instance.new("NumberValue"))
										progress2.Value = 0
										TweenService:Create(progress2, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
											Value = 1
										}):Play()
										local spinSpeed = object2._maid:give(Instance.new("NumberValue"))
										spinSpeed.Value = 1
										TweenService:Create(spinSpeed, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
											Value = 25
										}):Play()
										object2._maid:giveTask(scale.Changed:Connect(function()
											v27:ScaleTo(scale.Value * v21.Value)
										end))
										v25[v27] = {
											Scale = scale,
											Rot = random:NextNumber(0, 360),
											Progress = progress2,
											Original = v27:GetPivot(),
											SpinSpeed = spinSpeed,
											Angle = angle
										}

										if total2 % 2 == 0 and tick() - lastTime > 0.3 and tick() - lastTime < 0.75 then
											local cFrame2 = part.CFrame

											for _ = 1, 3 do
												local number = random:NextNumber(0.05, 0.07)
												local clone7 = main.ShardSphere:Clone()

												if math.random(1, 2) == 1 then
													clone7.Color = Color3.new(0, 0, 0)
													clone7.Color = Color3.new(1, 0.333333, 0.109804)
												else
													clone7.Color = Color3.new(1, 0.227451, 0.0901961)
												end

												game.Debris:AddItem(clone7, number)
												local number2 = random:NextNumber(-50, 50)
												local number3 = random:NextNumber(-50, 50)
												local v34 = cFrame2 * CFrame.new(number2, math.random(90, 200), number3)
												clone7.CFrame = CFrame.new(
													cFrame2 * CFrame.new(number2, math.random(10, 15), number3).Position,
													v34.Position
												) * CFrame.Angles(1.5707963267948966, 0, 0)
												clone7.Parent = EFP
												local number4 = random:NextNumber(1, 3)
												clone7.Mesh.Scale = Vector3.new(number4, math.random(25, 35), number4) * 1.4 * 1.3
												playTween(clone7, {
													EasingStyle = "Sine",
													Time = number,
													Goal = {
														Position = v34.Position
													}
												})
												playTween(clone7.Mesh, {
													EasingStyle = "Sine",
													Time = number,
													Goal = {
														Scale = Vector3.new(0, math.random(30, 40) * 1.4 * 1.3, 0)
													}
												})
											end
										end

										if total2 % 1 == 0 then
											task.spawn(function()
												for _ = 1, 6 do
													local clone7 = main.Swirlnormalfaceorigin3:Clone()
													clone7:PivotTo(v13.CFrame * CFrame.new(0, 0.3, 0) * CFrame.Angles(
														3.141592653589793,
														math.rad((random:NextNumber(-360, 360))),
														0
													))
													clone7.Size *= v21.Value
													clone7.Mesh.Scale += createVector(0, 0.5, 0)
													clone7.Mesh.Scale *= 5.5 * v24.Value
													v26[clone7] = {
														Speed = random:NextNumber(0.5, 1)
													}
													TweenService:Create(
														clone7.Mesh,
														TweenInfo.new(0.7, Enum.EasingStyle.Sine),
														{
															Scale = clone7.Mesh.Scale * 4
														}
													):Play()
													clone7.Parent = EFP
													game.Debris:AddItem(clone7, 10)
													random:NextNumber(3, 6)
													random:NextNumber(0.0075, 0.015)
													local _ = random:NextInteger(1, 2) == 1
													local v35 = v9[math.random(1, 2)]
													task.spawn(function()
														for i = 1, #v35, 2 do
															local texture = v35[i]

															if texture then
																clone7.Decal.Texture = texture
															end

															dtwait(0.0045)
														end

														clone7:Destroy()
													end)
													local v37 = clone7
													task.delay(0.015, function()
														TweenService:Create(
															v37.Decal,
															TweenInfo.new(
																0.015,
																Enum.EasingStyle.Linear,
																Enum.EasingDirection.In
															),
															{
																Color3 = Color3.fromRGB(34, 5, 5)
															}
														):Play()
													end)
												end
											end)
										end

										if total2 % 1 == 0 then
											local v34 = quickFX({
												FX = main.Dotted,
												Maid = object2._maid,
												Anchor = v13.CFrame
											})
											v34:ScaleTo(v24.Value * 7)
											playAttachment(v34)
											v26[v34] = {
												Speed = random:NextNumber(0.3, 0.5)
											}
										end

										for k, v34 in pairs(v25) do
											local _ = (k:GetPivot().Position - part.CFrame.Position).Magnitude
											local progress = v34.Progress
											k:PivotTo(v34.Original:Lerp(
												part.CFrame * CFrame.new(0, v20.Value, 0),
												progress.Value
											) * CFrame.Angles(0, v34.Rot, 0) * CFrame.Angles(
												v34.Angle,
												math.rad(v34.SpinSpeed.Value * total2),
												0
											))

											if not (v34.Progress.Value >= 1) then
												continue
											end

											k:Destroy()
											v25[k] = nil
										end

										for k, v34 in pairs(v26) do
											if k.Parent then
												if k.Name == "Dotted" then
													k:PivotTo(k:GetPivot() * CFrame.new(0, -1, 0) * CFrame.Angles(
														0,
														math.rad(v34.Speed) * 25,
														0
													))
												else
													k:PivotTo(k:GetPivot() * CFrame.Angles(
														0,
														math.rad(v34.Speed) * 25,
														0
													))
												end
											else
												v26[k] = nil
											end
										end

										v13:PivotTo(part.CFrame * CFrame.Angles(0, math.rad(v22.Value * total2), 0) * CFrame.new(
											0,
											0,
											v17.Value
										))
										local number = random:NextNumber(1.2, 2.4)
										v16:PivotTo(CFrame.new(
											v13.Position,
											part.CFrame * CFrame.new(0, v20.Value, 0).Position
										) * CFrame.Angles(0, 0, 0) * CFrame.Angles(0, 1.5707963267948966, 0) * CFrame.Angles(
											math.rad(v22.Value * total2 * 3),
											0,
											0
										) * CFrame.new(v20.Value * 0.3, 0, 0))
										v16:ScaleTo(math.clamp(v21.Value, 0.01, 1e999) * number)
										dtwait(0.001)
									end

									Clean2() -- equivalent call inferred; original call site unknown
								end)
							end

							local part = Instance.new("Part")
							part.Size = createVector(15, 15, 15)
							part.Anchored = true
							part.CanCollide = false
							part.CFrame = v11 * CFrame.new(-100, 800, 0)
							part.Transparency = 1
							part:PivotTo(clone2:GetPivot() * CFrame.new(
								89.4429779,
								-703,
								-3.57936382,
								0,
								0,
								1,
								0,
								1,
								0,
								-1,
								0,
								0
							):Inverse())
							local highlight = Instance.new("Highlight")
							highlight.Parent = part
							part.Parent = EFP
							local cFrame3 = clone2:GetPivot() * CFrame.new(
								-13.7550583,
								97,
								-1.41651678,
								0,
								0,
								1,
								0,
								1,
								0,
								-1,
								0,
								0
							):Inverse()
							TweenService:Create(part, TweenInfo.new(0.9, Enum.EasingStyle.Sine), {
								CFrame = cFrame3
							}):Play()
							game.Debris:AddItem(part, 3)
							folder2:ClearAllChildren()

							for _, child in pairs(folder:GetChildren()) do
								if child.Name == "SceneRig" or child.Name == "Meshs" or child.Name == "RoomReal" or child.Name == "JustStars" then
									child:Destroy()
								end
							end

							OPTornado(part)
						end)
					end
				}
				local lastTime = tick()

				for k, v9 in pairs({
					hand = function()
						task.wait(1)
						Stop()
					end
				}) do
					local connection = nil
					local v10 = v9
					connection = v6:GetMarkerReachedSignal(k):Connect(function()
						if tick() - lastTime > 13 then
							return connection:Disconnect()
						end

						return v10()
					end)
					table.insert(v4, connection)
				end

				for k, v9 in pairs(v8) do
					local connection = nil
					local v10 = v9
					connection = track2:GetMarkerReachedSignal(k):Connect(function()
						if tick() - lastTime > 13 then
							return connection:Disconnect()
						end

						return v10()
					end)
					table.insert(v4, connection)
				end

				task.spawn(function()
					local v9 = {}
					local numberValue2 = Instance.new("NumberValue")
					game.Debris:AddItem(numberValue2, 22)
					numberValue2.Value = 0.1
					TweenService3:Create(
						numberValue2,
						TweenInfo.new(v9.LerpTime or 3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
						{
							Value = 0.5
						}
					):Play()
					local v10 = false
					local v11 = false
					local v12 = false
					local renderSteppedConnection = nil
					local RunService = game:GetService("RunService")
					renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
						if not flag then
							local parent = clone2 and clone2.Parent

							if parent then
								if humanoid.Health > 0 then
									parent = char == game.Players.LocalPlayer.Character
								else
									parent = false
								end
							end
						end

						if flag then
							renderSteppedConnection:Disconnect()
							Stop()
						else
							local parent = clone2 and clone2.Parent

							if parent then
								if humanoid.Health > 0 then
									parent = char == game.Players.LocalPlayer.Character
								else
									parent = false
								end
							end

							if parent then
								if not v10 then
									v10 = true
								end

								if dt > 0.08 and not v11 then
									v11 = true
								end

								local v14 = dt * 60
								total += v14
								local v15 = tonumber((math.ceil(total)))

								if currentCamera.CameraType ~= Enum.CameraType.Scriptable then
									currentCamera.CameraType = Enum.CameraType.Scriptable
								end

								local success, _ = pcall(function()
									currentCamera.CFrame = clone2.Cam.CFrame * cFrameValue.Value + createVector(0, 0, 0)
								end)

								if not (success or v12) then
									v12 = true
								end

								if not FOV then
									return
								end

								local v16 = FOV

								if type(FOV) == "table" then
									local v17 = FOV[v15]

									if v17 ~= nil then
										if v9.NoLerp or v9.NoLerpAfter and numberValue2.Value == 0.5 then
											currentCamera.FieldOfView = tonumber(v17)
										else
											local v18 = currentCamera
											local fieldOfView = currentCamera.FieldOfView
											v18.FieldOfView = fieldOfView + (tonumber(v17) * numberValue.Value - fieldOfView) * 0.25
										end
									end

									v16 = nil
								end

								local numberValue3 = v16 and v16:FindFirstChild((tostring(v15)))

								if not numberValue3 then
									return
								end

								local numberValue4

								if numberValue3:IsA("NumberValue") then
									numberValue4 = numberValue3
								else
									numberValue4 = numberValue3.Values:FindFirstChildOfClass("NumberValue")
								end

								if v9.NoLerp or v9.NoLerpAfter and numberValue2.Value == 0.5 then
									currentCamera.FieldOfView = tonumber(numberValue4.Value)
									return
								end

								local eases = numberValue3:FindFirstChild("Eases")

								if eases then
									local params = eases:FindFirstChild("Params")
									local direction = params and params:FindFirstChild("Direction")
									local type2 = params and params:FindFirstChild("Type")
									local value = direction and direction.Value or "In"
									local value2 = type2 and type2.Value or "Linear"
									local TweenService4 = game:GetService("TweenService")
									local value3 = TweenService4:GetValue(
										0.35,
										Enum.EasingStyle[value2],
										Enum.EasingDirection[value]
									)
									TweenService2:Create(currentCamera, TweenInfo.new(value3), {})
									currentCamera.FieldOfView += (tonumber(numberValue4.Value) - currentCamera.FieldOfView) * value3 * numberValue.Value
								else
									local v17 = currentCamera
									local fieldOfView = currentCamera.FieldOfView
									v17.FieldOfView = fieldOfView + (tonumber(numberValue4.Value) * numberValue.Value - fieldOfView) * 0.25
								end
							else
								renderSteppedConnection:Disconnect()
								Stop()
							end
						end
					end)
					table.insert(v4, renderSteppedConnection)
				end)
			end

			Sequence1()
		end

		task.spawn(function()
			local v5, _ = xpcall(Transform, diagTraceback)

			if not v5 then
				pcall(function()
					if currentCamera and currentCamera.CameraType == Enum.CameraType.Scriptable then
						shared.smoothout(currentCamera.CFrame)
					end
				end)
			end
		end)
		wait(10)
		Clean() -- equivalent call inferred; original call site unknown
	else
		task.spawn(function()
			local OutsideV2 = require(script.Parent.OutsideV2)
			OutsideV2.FirstEvent({
				Char = char
			})
		end)
		task.wait(0.3)

		if not v then
			v = true
			task.delay(15, function()
				v = nil
			end)
			local OutsideV2 = require(script.Parent.OutsideV2)
			OutsideV2.StormEvent({
				Char = char
			})
		end
	end
end

return CosmicTransformation