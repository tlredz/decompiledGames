local createVector = vector.create
local FX = require(game.ReplicatedStorage.FX)
local indraCutscene = FX:WaitForChild("IndraCutscene")
return function(_)
	local RunService = game:GetService("RunService")
	local TweenService = game:GetService("TweenService")
	local Effect = require(game.ReplicatedStorage.Effect)
	local Sound = require(game.ReplicatedStorage.Util.Sound)
	local bindableEvent = Instance.new("BindableEvent")
	local v = { 0, 1e999 }
	local localPlayer = game.Players.LocalPlayer
	local clone = indraCutscene.IndraIsland:Clone()
	clone.Parent = workspace.Map
	local v2 = 0
	local anim = clone.anim
	anim.Parent = workspace

	local function play(childName)
		local child = anim:FindFirstChild(childName)
		local track = child:FindFirstChild("Humanoid"):LoadAnimation((anim:FindFirstChild(childName .. "anim")))
		coroutine.wrap(function()
			track:Play(nil, nil, 0.001)
			task.wait(0.1)
			track:Stop()
			bindableEvent.Event:Wait()
			track.TimePosition = v[1]
			track:Play()
			track.TimePosition = v[1]
			local camPart = child:FindFirstChild("CamPart", true)

			if camPart then
				camPart.Transparency = 1
				local cframe = CFrame.Angles(0, 3.141592653589793, 0)
				local currentCamera = workspace.CurrentCamera

				if currentCamera then
					currentCamera.CameraType = Enum.CameraType.Scriptable
				end

				pcall(function()
					game.Players.LocalPlayer.Character.LowerTorso.Anchored = true
				end)

				while track.IsPlaying do
					currentCamera.CFrame = camPart.CFrame * cframe * CFrame.new(
						(math.random() - 0.5) * v2,
						(math.random() - 0.5) * v2,
						(math.random() - 0.5) * v2
					) * CFrame.Angles(
						(math.random() - 0.5) * v2 * 0.1,
						(math.random() - 0.5) * v2 * 0.1,
						(math.random() - 0.5) * v2 * 0.1
					)
					local v3 = RunService.RenderStepped:Wait()

					if v2 > 0 then
						v2 -= v3 * 2.75
					end

					if v2 < 0 then
						v2 = 0
					end
				end

				pcall(function()
					game.Players.LocalPlayer.Character.LowerTorso.Anchored = false
				end)
				local currentCamera2 = workspace.CurrentCamera

				if not currentCamera2 then
					return
				end

				currentCamera2.CameraType = Enum.CameraType.Custom
				local character = localPlayer.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")

				if humanoid then
					currentCamera2.CameraSubject = humanoid
				end
			end
		end)()
		return (setmetatable({
			Cancel = function()
				track:Stop()
			end
		}, {
			__index = function(_, childName2)
				return child:FindFirstChild(childName2)
			end
		}))
	end

	local v3 = play("rip_indra")
	local v4 = play("mygame43")
	local v5 = true
	local characterAddedConnection = localPlayer.CharacterAdded:Connect(function()
		if not v5 then
			return
		end

		bindableEvent:Fire(2)
		local currentCamera = workspace.CurrentCamera

		if not currentCamera then
			return
		end

		currentCamera.CameraType = Enum.CameraType.Custom
		local character = localPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			currentCamera.CameraSubject = humanoid
		end
	end)

	local function clash(long, value, p2)
		local v6 = value or "Runes"
		local position = p2 or v3.DarkBlade.Right[v6].Position:Lerp(v4.DarkBlade.Right[v6].Position, 0.5)
		v2 += long and 0.8 or 0.4
		Effect.new("Hit.Clash"):replicate({
			Long = long,
			Position = position
		})
	end

	local function fist(p)
		local position = p or v3.LowerTorso.Position:Lerp(v4.LowerTorso.Position, 0.5)
		Sound:Play("Hit1", position)
		v2 += 0.7
		local Effect2 = require(game.ReplicatedStorage.Effect)
		Effect2.new("Hit.Combat"):replicate({
			Position = position,
			Type = "Punch"
		})
	end

	local function slash(p)
		local position = p or v3.LowerTorso.Position:Lerp(v4.LowerTorso.Position, 0.5)
		Sound:Play("QuickSlice", position)
		v2 += 0.7
		local Effect2 = require(game.ReplicatedStorage.Effect)
		Effect2.new("Hit.Combat"):replicate({
			Position = position,
			Type = "Sword"
		})
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function mapRay(p, p2)
		local ray = Ray.new(p, p2)
		return workspace:FindPartOnRayWithWhitelist(ray, { workspace.Map })
	end

	local WaitFrame = require(game.ReplicatedStorage.Util.WaitFrame)
	local v6, connection = WaitFrame()
	bindableEvent.Event:Connect(function(p)
		if p == 1 then
			local v7 = {
				0,
				function() end,
				1.5,
				function() end,
				2.85,
				function()
					Sound:Play("SwordSwing", v3.Head.Position)
					v6(0.15)
					clash()
				end,
				5.75,
				function()
					Sound:Play("SwordSwing", v4.Head.Position)
				end,
				8,
				function()
					for i = 1, 10 do
						Sound:Play("SwordSwing", v3.Head.Position)
						v6(i / 120 + 0.06)
					end

					Sound:Play("SwordSwing", v3.Head.Position)
				end,
				11.05,
				function()
					Sound:Play("SwordSwing", v3.Head.Position)
					v6(0.1)
					clash(false, "Blade")
				end,
				11.55,
				function()
					Sound:Play("SwordSwing", v3.Head.Position)
					v6(0.1)
					clash(true, "Blade")
				end,
				13,
				function()
					Sound:Play("MeleeSwing", v4.Head.Position)
					v6(0.2)
					fist(v3.LowerTorso.Position)
				end,
				14.7,
				function()
					Sound:Play("SwordSwing", v3.Head.Position)
					v6(0.1)
					clash()
				end,
				15.4,
				function()
					Sound:Play("SwordSwing", v3.Head.Position)
					v6(0.1)
					clash()
				end,
				16.08,
				function()
					Sound:Play("SwordSwing", v3.Head.Position)
				end,
				16.5,
				function()
					Sound:Play("SwordSwing", v3.Head.Position)
					Sound:Play("DodgeQuick2", v3.Head.Position)
				end,
				17,
				function()
					Sound:Play("SwordSwing", v3.Head.Position)
					v6(0.1)
					clash()
				end,
				17.6,
				function()
					local v9, position, normal = mapRay(
						v4.DarkBlade.Right.Runes.Position + createVector(0, 3, 0),
						createVector(0, -13, 0)
					)
					Effect.new("Mochi-Mochi.CarvedDough.Floor"):replicate({
						v9,
						CFrame.new(position, position + normal),
						20,
						0.1,
						0.2
					})
					Effect.new("GroundSmash"):replicate({
						Size = 10,
						Position = position,
						Normal = normal,
						Color = v9.Color,
						Duration = 0.2
					})
					v2 += 1
				end,
				18.7,
				function()
					Sound:Play("SwordSwing", v3.Head.Position)
					v6(0.1)
					clash()
				end,
				19.05,
				function()
					Sound:Play("SwordSwing", v3.Head.Position)
					v6(0.1)
					clash()
				end,
				19.55,
				function()
					Sound:Play("SwordSwing", v3.Head.Position)
					v6(0.1)
					clash(true)
				end,
				20,
				function()
					Sound:Play("DodgeQuick2", v4.Head.Position)
				end,
				20.55,
				function()
					Sound:Play("SwordSwing", v3.Head.Position)
					v6(0.1)
					clash()
				end,
				22.4,
				function()
					Sound:Play("SwordSwing", v3.Head.Position)
					Sound:Play("SwordSwing", v4.Head.Position)
					v6(0.15)
					clash(true, "Blade")
				end,
				24.7,
				function()
					Sound:Play("SwordSwing", v4.Head.Position)
					v6(0.1)
					clash(false, false, v3.DarkBlade.Right.Runes.Position)
				end,
				25.28,
				function()
					Sound:Play("SwordSwing", v3.Head.Position)
					v6(0.1)
					slash(v4.LowerTorso.Position)
				end,
				27.95,
				function()
					Sound:Play("SwordSwing", v3.Head.Position)
				end,
				29,
				function()
					Sound:Play("SwordSwing", v3.Head.Position)
				end,
				30.05,
				function()
					Effect.new("Shared.Soru"):replicate({
						Duration = 0.3,
						Scale = 8,
						CFrame = CFrame.new(v3.LowerTorso.Position)
					})
				end,
				30.45,
				function()
					Sound:Play("SwordSwing", v4.Head.Position)
					v6(0.1)
					clash(true, false, v4.DarkBlade.Right.Blade.Position)
				end,
				33.35,
				function()
					local v9, position, normal = mapRay(
						v4.DarkBlade.Right.Runes.Position + createVector(0, 3, 0),
						createVector(0, -13, 0)
					)
					Effect.new("Mochi-Mochi.CarvedDough.Floor"):replicate({
						v9,
						CFrame.new(position, position + normal),
						4,
						0.4,
						0.4
					})
					Effect.new("GroundSmash"):replicate({
						Size = 8,
						Position = position,
						Normal = normal,
						Color = v9.Color,
						Duration = 0.4
					})
					v2 += 1.5
				end,
				36.65,
				function()
					Sound:Play("DodgeQuick2", v3.Head.Position)
				end,
				38,
				function()
					Effect.new("Shared.Soru"):replicate({
						Duration = 0.3,
						Scale = 9,
						CFrame = CFrame.new(v3.UpperTorso.Position - createVector(0, 3, 0) + v3.UpperTorso.CFrame.LookVector * 4)
					})
				end,
				39.5,
				function()
					local cFrame = v3.UpperTorso.CFrame
					Sound:Play("DarknessFormation", cFrame)
					Sound:Play("DarknessLayer", cFrame)

					for i = 1, 2 do
						local clone2 = game.ReplicatedStorage.EffectContainer.Tushita.Main.RedSlash:Clone()
						clone2.Red.Electric.Color = ColorSequence.new(Color3.new(0, 1, 0))
						clone2.Red.Color = Color3.new(0, 1, 0)
						clone2:SetPrimaryPartCFrame(cFrame * CFrame.Angles(
							3.141592653589793 * math.random() * i,
							3.141592653589793 * math.random() * i,
							3.141592653589793 * math.random() * i
						))

						for _, child in pairs(clone2:GetChildren()) do
							child.Size *= (3 + math.random() * 2) * 4
							local tween = TweenService:Create(child, TweenInfo.new(1.1, Enum.EasingStyle.Quad), {
								Size = Vector3.new(),
								CFrame = child.CFrame * CFrame.Angles(3.141592653589793, 3.141592653589793, 0)
							})

							if child == clone2.PrimaryPart then
								local v8 = clone2
								tween.Completed:Connect(function()
									v8:Destroy()
								end)
							end

							tween:Play()
						end

						clone2.Parent = workspace._WorldOrigin
					end

					v2 += 3.75
					v6(1.2)
					Sound:Play("Ability", v3.Head.Position)
					local clone2 = FX:WaitForChild("ActivationRing"):Clone()
					clone2.Color = ColorSequence.new(Color3.new(0, 1, 0))
					clone2.Size = NumberSequence.new(0, 30)
					clone2.Parent = v3.LowerTorso.RootRigAttachment
					clone2:Emit(1)
					v6(0.2)
					Sound:Play("SwordSwing", v3.Head.Position)
					v6(3)
					clone2:Destroy()
				end,
				41.6,
				function()
					for i = 1, 44 do
						v2 += 0.14
						local v8 = CFrame.new(
							v3.UpperTorso.Position,
							(Vector3.new(v4.UpperTorso.Position.X, v3.UpperTorso.Position.Y, v4.UpperTorso.Position.Z))
						) * CFrame.new(0, 0, -11 - math.min(i, 27) * 2.6 - i / 15)

						if i % 2 == 0 then
							Sound:Play("QuickSlice", v8)
						end

						for _ = 1, 3 do
							local clone2 = game.ReplicatedStorage.EffectContainer.Tushita.Main.RedSlash:Clone()
							clone2.Red.Electric.Color = ColorSequence.new(Color3.new(0, 1, 0))
							clone2.Red.Color = Color3.new(0, 1, 0)
							clone2:SetPrimaryPartCFrame(v8 * CFrame.Angles(
								3.141592653589793 * math.random() * 2,
								3.141592653589793 * math.random() * 2,
								3.141592653589793 * math.random() * 2
							))

							for _, child in pairs(clone2:GetChildren()) do
								child.Size *= (3 + math.random() * 2) * 3
								local tween = TweenService:Create(child, TweenInfo.new(0.15, Enum.EasingStyle.Bounce), {
									Size = Vector3.new(),
									CFrame = child.CFrame * CFrame.Angles(
										3.141592653589793,
										3.141592653589793,
										3.141592653589793
									)
								})

								if child == clone2.PrimaryPart then
									local v9 = clone2
									tween.Completed:Connect(function()
										v9:Destroy()
									end)
								end

								tween:Play()
							end

							clone2.Parent = workspace._WorldOrigin
						end

						for _ = 1, 5 do
							local clone2 = game.ReplicatedStorage.EffectContainer.Spin.Z.SpinSpike:Clone()
							clone2.Color = Color3.new(1, 1, 1)
							clone2.Size *= 0.5
							clone2.CFrame = v8 * CFrame.Angles(
								math.random() * 3.141592653589793 * 2,
								math.random() * 3.141592653589793 * 2,
								math.random() * 3.141592653589793 * 2
							) * CFrame.new(math.random(1, 8), math.random(1, 8), 15)
							clone2.Parent = workspace._WorldOrigin
							local tween = TweenService:Create(
								clone2,
								TweenInfo.new(
									0.2 + math.random() * 0.04,
									Enum.EasingStyle.Exponential,
									Enum.EasingDirection.Out
								),
								{
									Size = createVector(0, 0, 15),
									Transparency = 1,
									CFrame = clone2.CFrame * CFrame.new(0, 0, -30)
								}
							)
							tween.Completed:Connect(function()
								clone2:Destroy()
							end)
							tween:Play()
						end

						if i > 25 then
							Effect.new("GUISlash"):replicate({
								Part = v4.UpperTorso,
								Scale = math.random(30, 60),
								Duration = 0.1,
								Color = Color3.new(0, 1, 0)
							})
						end

						v6()

						for _ = 1, i / 44 * 5 do
							v6()
						end
					end
				end,
				51.4,
				function()
					Sound:Play("MeleeSwing", v4.Head.Position)
					v6(0.1)
					fist(v4.Head.Position)
					v6(0.15)
					local v9, position, normal = mapRay(
						v4.UpperTorso.Position + createVector(0, 3, 0),
						createVector(0, -13, 0)
					)
					Effect.new("Mochi-Mochi.CarvedDough.Floor"):replicate({
						v9,
						CFrame.new(position, position + normal),
						8,
						0.3,
						0.3
					})
					Effect.new("GroundSmash"):replicate({
						Size = 14,
						Position = position,
						Normal = normal,
						Color = v9.Color,
						Duration = 0.3
					})
					v2 += 1
				end,
				55.3,
				function()
					Sound:Play("Swoosh", v3.Head.Position)
					local _, v9, v10 = mapRay(v3.UpperTorso.Position + createVector(0, 3, 0), createVector(0, -13, 0))
					local cFrame = CFrame.new(v9, v9 + v10) * CFrame.Angles(1.5707963267948966, 0, 0)
					local part = Instance.new("Part")
					part.Material = "Neon"
					part.Color = Color3.new()
					part.Size = createVector(0.1, 0.5, 0.1)
					part.CanCollide = false
					part.CFrame = cFrame
					part.Anchored = true
					local specialMesh = Instance.new("SpecialMesh", part)
					specialMesh.Scale = createVector(1, 1, 1)
					specialMesh.MeshType = "Sphere"
					part.Parent = workspace._WorldOrigin
					TweenService:Create(part, TweenInfo.new(0.7, Enum.EasingStyle.Quad), {
						CFrame = cFrame,
						Size = createVector(8, 0.5, 8)
					}):Play()
					v6(2)
					Sound:Play("Activate", v3.Head.Position)
					TweenService:Create(part, TweenInfo.new(0.7, Enum.EasingStyle.Quad), {
						CFrame = cFrame,
						Size = createVector(0.1, 0.5, 0.1)
					}):Play()
					v6(0.7)
					part:Destroy()
					v6(2)
					Effect.new("BlindCam"):replicate({
						Color = Color3.new(),
						Duration = 2,
						Faded = 0.75
					})
				end,
				60.5,
				function() end
			}
			_G.updateMusic2(true)
			Sound:SetDisabled({
				LongClash = true,
				ShortClash = true,
				ShortClash1 = true,
				ShortClash2 = true,
				ShortClash3 = true,
				SwordSwing = true,
				MeleeSwing = true
			})
			Sound:SetGlobalVolume(1.65)
			game.Players.LocalPlayer.PlayerGui.Main.Enabled = false
			local v8 = v7[#v7 - 1]
			local v9 = v[2]
			local v10 = tick() - v[1]

			while tick() - v10 < v8 do
				local v11 = tick() - v10

				if v11 > 25 then
					Sound:SetDisabled(nil)
				end

				for k, v12 in pairs(v7) do
					if not (typeof(v12) == "number" and v12 < v11 and math.abs(v12 - v11) < 0.1) then
						continue
					end

					v7[k] = false
					local v13 = k
					coroutine.resume(coroutine.create(function()
						local success, result = pcall(function()
							v7[v13 + 1]()
						end)

						if not success then
							warn("Cutscene", result)
						end
					end))
					break
				end

				if v9 < v11 then
					break
				else
					RunService.Stepped:Wait()
				end
			end

			bindableEvent:Fire(2)
			Sound:SetDisabled(nil)
			Sound:SetGlobalVolume(1)
			game.Players.LocalPlayer.PlayerGui.Main.Enabled = true
			clone:Destroy()
			anim:Destroy()
			_G.updateMusic2(false)
			connection:Disconnect()
			v5 = false

			if characterAddedConnection then
				characterAddedConnection:Disconnect()
				characterAddedConnection = nil
			end
		else
			if not v5 then
				return
			end

			v3:Cancel()
			v4:Cancel()
			Sound:SetDisabled(nil)
			Sound:SetGlobalVolume(1)
			pcall(function()
				game.Players.LocalPlayer.PlayerGui.Main.Enabled = true
			end)
			pcall(function()
				_G.updateMusic2(false)
			end)
			local currentCamera = workspace.CurrentCamera

			if currentCamera then
				currentCamera.CameraType = Enum.CameraType.Custom
				local character = localPlayer.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")

				if humanoid then
					currentCamera.CameraSubject = humanoid
				end
			end

			pcall(function()
				clone:Destroy()
			end)
			pcall(function()
				anim:Destroy()
			end)
			pcall(function()
				connection:Disconnect()
			end)
			v5 = false

			if characterAddedConnection then
				characterAddedConnection:Disconnect()
				characterAddedConnection = nil
			end
		end
	end)
	local cFrame2 = workspace.CurrentCamera.CFrame * CFrame.new(0, -250, 250)
	local clone2 = game.ReplicatedStorage.EffectContainer.Tushita.Main.RedSlash:Clone()
	clone2:SetPrimaryPartCFrame(cFrame2)
	clone2.Parent = workspace._WorldOrigin
	local clone3 = game.ReplicatedStorage.EffectContainer.Spin.Z.SpinSpike:Clone()
	clone3.CFrame = cFrame2
	clone3.Parent = workspace._WorldOrigin
	Effect.new("Mochi-Mochi.CarvedDough.Floor"):replicate({
		clone2.PrimaryPart,
		cFrame2,
		1,
		0.1,
		0.1
	})
	Effect.new("GroundSmash"):replicate({
		Size = 1,
		Position = workspace.CurrentCamera.CFrame * createVector(0, 0, 350),
		Normal = createVector(0, 1, 0),
		Color = Color3.new(),
		Duration = 0.1,
		Mute = true
	})
	Effect.new("GUISlash"):replicate({
		Part = clone2.PrimaryPart,
		Scale = 10,
		Duration = 0.1,
		Color = Color3.new(0, 1, 0)
	})
	clash(false, false, cFrame2.p + createVector(0, 999999, 0))
	fist(workspace.CurrentCamera.CFrame * createVector(0, 0, 100))
	slash(workspace.CurrentCamera.CFrame * createVector(0, 0, 100))
	Sound:Play("GroundSmash", CFrame.new(0, 999999, 0))
	Sound:Play("DarknessFormation", CFrame.new(0, 999999, 0))
	Sound:Play("DarknessLayer", CFrame.new(0, 999999, 0))
	Sound:Play("MeleeSwing", CFrame.new(0, 999999, 0))
	Sound:Play("SwordSwing", CFrame.new(0, 999999, 0))
	Sound:Play("Ability", CFrame.new(0, 999999, 0))
	Sound:Play("DodgeQuick2", CFrame.new(0, 999999, 0))
	Sound:Play("Swoosh", CFrame.new(0, 999999, 0))
	Sound:Play("Activate", CFrame.new(0, 999999, 0))
	Effect.new("Shared.Soru"):replicate({
		Duration = 0.3,
		Scale = 9,
		CFrame = cFrame2
	})
	local clone4 = FX:WaitForChild("ActivationRing"):Clone()
	clone4.Color = ColorSequence.new(Color3.new(0, 1, 0))
	clone4.Size = NumberSequence.new(0, 30)
	clone4.Parent = clone2
	clone4:Emit(1)
	local fXWithMusic = Sound.Storage.AnimatedBattle.FXWithMusic
	task.spawn(function()
		local ContentProvider = game:GetService("ContentProvider")
		ContentProvider:PreloadAsync({ fXWithMusic:GetAttribute("SoundId") })
	end)
	local sound = Instance.new("Sound")
	sound.PlaybackSpeed = fXWithMusic:GetAttribute("PlaybackSpeed")
	sound.RollOffMinDistance = fXWithMusic:GetAttribute("RollOffMinDistance")
	sound.RollOffMaxDistance = fXWithMusic:GetAttribute("RollOffMaxDistance")
	sound.RollOffMode = fXWithMusic:GetAttribute("RollOffMode")
	sound.TimePosition = fXWithMusic:GetAttribute("TimePosition")
	sound.SoundId = fXWithMusic:GetAttribute("SoundId")
	sound.PlayOnRemove = fXWithMusic:GetAttribute("PlayOnRemove")
	sound.Playing = fXWithMusic:GetAttribute("Playing")
	sound.Looped = fXWithMusic:GetAttribute("Looped")
	sound.Name = fXWithMusic.Name
	sound.Volume = math.clamp(fXWithMusic:GetAttribute("Volume") * 1.05, 0, 1.5) * Sound.__GlobalVolume
	sound.Parent = workspace
	sound.Ended:Connect(function()
		wait()
		sound:Destroy()
	end)
	v6(2.5)
	sound:Play()
	v6(0.5)
	clone2:Destroy()
	clone3:Destroy()
	clone4:Destroy()
	Effect.new("BlindCam"):replicate({
		Color = Color3.new(),
		Duration = 1,
		Fade = 0.5
	})
	v6(1)
	bindableEvent:Fire(1)
end