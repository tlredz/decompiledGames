local createVector = vector.create
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local TweenService = game:GetService("TweenService")
local CustomCollisions = require(ReplicatedStorage:WaitForChild("CustomCollisions"))
local _ = Util.CameraShaker
local rocks = CustomCollisions.new("Rocks")
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local C = FX:WaitForChild("Creation").C
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")

-- equivalent calls inferred from this helper; original call sites unknown
local function DeleteImpactAfterDuration(folder)
	task.spawn(function()
		local v = 0

		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				v = math.max(v, emitter.Lifetime.Max)
			end
		end

		task.wait(v)
		folder:Destroy()
	end)
end

local function CreateCube(size, cFrame, folder, clones)
	local clone = C.Phase1.CubePart:Clone()
	clone.Size = size
	clone.CFrame = cFrame
	clone.Parent = folder
	clone.Color = Color3.fromRGB(math.random(200, 250), math.random(35, 70), math.random(60, 100)):Lerp(
		Color3.fromRGB(0, 0, 0),
		0.9
	)
	clone.Transparency = 0
	local v = math.random(5, 10) / 100
	local tween = TweenService:Create(
		clone,
		TweenInfo.new(0.325 - v, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
		{
			CFrame = clone.CFrame * CFrame.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5)),
			Size = Vector3.new(math.random(0, 25), math.random(0, 15), math.random(0, 25))
		}
	)
	clone.CFrame *= CFrame.new(math.random(-5, 5) * 2, math.random(-5, 5) * 2, math.random(-5, 5) * 2)
	clone.CFrame *= CFrame.Angles(
		math.rad(math.random(-5, 5) * 10),
		math.rad(math.random(-5, 5) * 10),
		(math.rad(math.random(-5, 5) * 10))
	)
	clone.Size = Vector3.new(math.random(0, 15), math.random(0, 15), math.random(0, 15))
	tween:Play()
	task.spawn(function()
		tween.Completed:Wait()
		tween = TweenService:Create(
			clone,
			TweenInfo.new(0.125 - math.random(5, 10) / 100, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
			{
				Size = size,
				CFrame = cFrame
			}
		)
		tween:Play()
		tween.Completed:Wait()

		if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			if Util.RotatableRegion.new(clone.CFrame, clone.Size):CastSphere(
				game.Players.LocalPlayer.Character.HumanoidRootPart.Position,
				0.1
			) then
				clone.CanCollide = false
			else
				clone.CanCollide = true
			end
		end
	end)
	local v2 = {
		Color3.fromRGB(150, 200, 300),
		Color3.fromRGB(380, 50, 100),
		Color3.fromRGB(250, 200, 150),
		Color3.fromRGB(250, 380, 400),
		Color3.fromRGB(250, 380, 250),
		Color3.fromRGB(400, 100, 250),
		Color3.fromRGB(400, 200, 250),
		Color3.fromRGB(200, 100, 350)
	}
	local selectionBox = clone.SelectionBox
	selectionBox.Color3 = v2[math.random(1, 8)]
	selectionBox.Parent = clone
	selectionBox.Adornee = clone
	task.spawn(function()
		selectionBox.LineThickness = 0
		task.wait(0.25)
		selectionBox.LineThickness = 1
		TweenService:Create(selectionBox, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), {
			LineThickness = 0.5
		}):Play()
	end)
	table.insert(clones, clone)
	task.wait(1)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function WeaponStab(p, parent, clones, now)
	task.spawn(function()
		local clone = C.Phase3.Weapon:Clone()
		clone.CFrame = p * CFrame.Angles(
			math.rad((math.random(-180, 10))),
			math.rad(math.random(-180, 180) / 1.5),
			(math.rad((math.random(-180, 180))))
		) * CFrame.new(0, math.random(-25, 0), 150)
		clone.CFrame = CFrame.new(clone.Position, p.Position)
		clone.Parent = parent
		clone.Model:ScaleTo(35 + math.random(3, 7) / 2)
		table.insert(clones, clone)
		local tween = TweenService:Create(clone, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
			CFrame = clone.CFrame * CFrame.new(0, 0, -50) * CFrame.Angles(0, 0, (math.rad((math.random(-180, 180)))))
		})
		tween:Play()
		tween.Completed:Wait()
		local clone2 = C.Phase3.SwordHitImpact:Clone()
		clone2.CFrame = clone.CFrame
		clone2.Parent = parent

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		local clone3 = C.Phase3.CrackBeam:Clone()
		clone3.CFrame = clone2.CFrame * CFrame.new(0, 0, -50)
		clone3.Parent = clone

		for _, beam in pairs(clone3:GetDescendants()) do
			if not beam:IsA("Beam") then
				continue
			end

			local width = beam.Width0 * math.random(10, 20) / 10
			local width2 = beam.Width1 * math.random(10, 30) / 10
			local tween2 = TweenService:Create(
				beam,
				TweenInfo.new(0.125, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
				{
					Width0 = width,
					Width1 = width2
				}
			)
			beam.Width0 = 0
			beam.Width1 = 0
			tween2:Play()
			local v3 = beam
			task.spawn(function()
				tween2.Completed:Wait()
				task.wait(1 - (now - tick()))
				task.wait(math.random(1, 10) / 100)
				tween2 = TweenService:Create(
					v3,
					TweenInfo.new(0.175, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Width0 = 0,
						Width1 = 0
					}
				)
				tween2:Play()
			end)
		end
	end)
end

return function(player)
	local origin = player.Origin

	if (currentCamera.CFrame.p - origin).Magnitude > 1200 then
		return
	end

	local stage = player.Stage

	if stage == 1 then
		local holding = player.Holding

		if not (holding and holding.Value) then
			return
		end

		local character = player.Character
		local root = player.Root
		local folder = Instance.new("Folder")
		folder.Parent = _WorldOrigin
		local _ = root.CFrame
		Util.Sound:Play("CreationFruit_V1_C_UserStart_01", root.Position)
		local v = Util.Sound:Play("CreationFruit_V1_C_User_Hold_01", root)
		TweenService:Create(v, TweenInfo.new(0.5), {
			Volume = 1
		}):Play()
		local clone = C.Phase0.HoldAura:Clone()
		clone.CFrame = root.CFrame
		clone.Parent = folder
		clone.Weld.Part1 = root
		clone.Anchored = false
		clone.Massless = true

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter:Emit(1)
			emitter.Enabled = true
		end

		local ray = Ray.new(root.Position, root.CFrame.UpVector * -20)
		local part, v2 = workspace:FindPartOnRayWithIgnoreList(ray, { folder, character })
		local clone2

		if part then
			clone2 = C.Phase0.HoldAuraGround:Clone()
			clone2.CFrame = CFrame.new(v2) * CFrame.new(0, 0.1, 0)
			clone2.Parent = folder

			for _, beam in pairs(clone2:GetDescendants()) do
				if beam.Name == "1" then
					local tween = TweenService:Create(beam, TweenInfo.new(0.25 * math.random() + 0.1), {
						Position = beam.Position
					})
					beam.Position = createVector(0, 0, 5)
					tween:Play()
				else
					beam:IsA("Beam")
				end
			end
		end

		local clone3 = C.Phase0.Box:Clone()
		clone3.CFrame = root.CFrame * CFrame.new(0, 0, -3)
		clone3.Parent = folder
		local outline = clone3.Outline
		outline.CFrame = clone3.CFrame
		local orientation = createVector(0, -1, 0)
		local orientation2 = createVector(1, 1, 1)

		while true do
			clone3.Position = root.CFrame * CFrame.new(0, 0, -3).Position
			clone3.Orientation = orientation
			outline.Position = clone3.Position
			outline.Orientation = orientation2
			orientation2 += createVector(1, 1, 1)
			orientation += createVector(0, -1, 0)

			if clone2 ~= nil then
				clone2.CFrame *= CFrame.Angles(0, 0.0017453292519943296, 0)
			end

			task.wait()

			if holding:IsDescendantOf(workspace) and holding.Value then
				continue
			end

			if v then
				Util.Sound:FadeOut(v, 0.2)
			end

			if clone2 ~= nil then
				for _, beam in pairs(clone2:GetDescendants()) do
					if beam:IsA("Beam") then
						TweenService:Create(beam, TweenInfo.new(0.25 * math.random() + 0.1), {
							Width0 = 0,
							Width1 = 0
						}):Play()
					elseif beam.Name == "0" then
						TweenService:Create(beam, TweenInfo.new(0.25 * math.random() + 0.1), {
							Position = createVector(0, 0, -5)
						}):Play()
					elseif beam.Name == "1" then
						TweenService:Create(beam, TweenInfo.new(0.25 * math.random() + 0.1), {
							Position = createVector(0, 0, 5)
						}):Play()
					end
				end

				task.wait(0.35)
				clone2:Destroy()
			end

			TweenService:Create(clone3, TweenInfo.new(0.15), {
				Size = createVector(0, 0, 0),
				Orientation = Vector3.new(math.random(-90, 90), math.random(-90, 90), math.random(-90, 90))
			}):Play()

			for _, descendant in pairs(clone3:GetDescendants()) do
				if descendant:IsA("SelectionBox") then
					TweenService:Create(descendant, TweenInfo.new(0.15), {
						LineThickness = 0,
						Transparency = 1
					}):Play()
				elseif descendant:IsA("BasePart") then
					TweenService:Create(descendant, TweenInfo.new(0.15), {
						Size = createVector(0, 0, 0)
					}):Play()
				end
			end

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			task.wait(5)
			folder:Destroy()
			return
		end
	elseif stage == 2 then
		local folder = Instance.new("Folder")
		folder.Name = "CreationC" .. player.Seed
		folder.Parent = _WorldOrigin
		Util.Debris:AddItem(folder, 15)
		local startCFrame = player.StartCFrame
		local v = startCFrame
		Util.Sound:Play("CreationFruit_V1_C_UserRelease_BoxSpawn_03", startCFrame.Position)
		local _ = C.Phase1.GlowBox
		local v2 = {}
		Random.new(player.Seed)
		task.spawn(function()
			for i = 1, 5 do
				for _ = 1, 4 do
					task.wait()
					v *= CFrame.Angles(0, 1.5707963267948966, 0)
					local total = -67.5

					for _ = 1, 5 do
						task.spawn(function()
							local cFrame = v * CFrame.new(total, 5, -67.5)
							task.wait(math.random(0, 25) / 100)
							CreateCube(createVector(27, 30, 27), cFrame, folder, v2)
						end)
						total += 27
					end
				end

				if i == 1 or i == 5 then
					local v3 = i
					task.spawn(function()
						local total = -36
						local v4 = v3 == 1 and -10 or v3 == 5 and 20 or nil

						for i2 = 1, 3 do
							local total2 = -36

							for i3 = 1, 3 do
								task.spawn(function()
									local cFrame = v * CFrame.new(total2, v4, total)
									CreateCube(createVector(36, 1, 36), cFrame, folder, v2)
								end)
								total2 += 36
								task.wait()
							end

							total += 36
						end
					end)
					task.wait(0.25)
				end

				if i == 1 then
					task.wait(0.15)
				end

				v *= CFrame.new(0, 30, 0)
			end
		end)
		local clone = C.Phase1.BeamStartBeams:Clone()
		clone.CFrame = startCFrame * CFrame.new(0, -5, 0)
		clone.Parent = folder

		for _, descendant in pairs(clone:GetDescendants()) do
			if descendant:IsA("ParticleEmitter") then
				descendant.Enabled = true
				local v3 = descendant
				task.spawn(function()
					task.wait(0.5)
					v3.Enabled = false
				end)
			elseif not descendant:IsA("Weld") then
				if descendant:IsA("Attachment") then
					if descendant.Name == "Attach1" then
						local tween = TweenService:Create(descendant, TweenInfo.new(0.25), {
							Position = createVector(0, 150, 0)
						})
						descendant.Position = createVector(0, 0, 0)
						task.delay(0.25, function()
							tween:Play()
						end)
					end
				elseif not descendant:IsA("Trail") then
					if descendant:IsA("Beam") then
						descendant.Width0 = 1.5
						descendant.Width1 = 1.5

						if descendant.Parent.Name == "Attach2" then
							descendant.Enabled = false
							local v3 = descendant
							task.spawn(function()
								task.wait(0.15)
								v3.Parent.Position = createVector(0, 150, 0)
								local tween = TweenService:Create(v3.Parent, TweenInfo.new(0.35), {
									Position = v3.Parent.Position
								})

								if v3.Parent.Parent.Name == "A2" then
									v3.Parent.Position = createVector(-79.411766, 150, -79.411766)
								elseif v3.Parent.Parent.Name == "B2" then
									v3.Parent.Position = createVector(-79.411766, 150, 79.411766)
								elseif v3.Parent.Parent.Name == "C2" then
									v3.Parent.Position = createVector(79.411766, 150, 79.411766)
								elseif v3.Parent.Parent.Name == "D2" then
									v3.Parent.Position = createVector(79.411766, 150, -79.411766)
								end

								tween:Play()
								v3.Enabled = true
							end)
						end

						descendant.Width0 = 3
						descendant.Width1 = 3
						local v3 = descendant
						task.spawn(function()
							task.wait(0.5)
							local tween = TweenService:Create(
								v3,
								TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Width0 = 0,
									Width1 = 0
								}
							)
							tween:Play()
							tween.Completed:Wait()
							v3:Destroy()
						end)
					elseif descendant:IsA("BasePart") then
						if descendant.Name == "A" then
							descendant.WeldConstraint.Enabled = false
							descendant.CFrame = clone.CFrame * CFrame.new(77.14285714285714, 0, 77.14285714285714)
							descendant.WeldConstraint.Enabled = true
						elseif descendant.Name == "B" then
							descendant.WeldConstraint.Enabled = false
							descendant.CFrame = clone.CFrame * CFrame.new(77.14285714285714, 0, -77.14285714285714)
							descendant.WeldConstraint.Enabled = true
						elseif descendant.Name == "C" then
							descendant.WeldConstraint.Enabled = false
							descendant.CFrame = clone.CFrame * CFrame.new(-77.14285714285714, 0, -77.14285714285714)
							descendant.WeldConstraint.Enabled = true
						elseif descendant.Name == "D" then
							descendant.WeldConstraint.Enabled = false
							descendant.CFrame = clone.CFrame * CFrame.new(-77.14285714285714, 0, 77.14285714285714)
							descendant.WeldConstraint.Enabled = true
						end
					end
				end
			end
		end

		TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			CFrame = clone.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
		}):Play()
		task.spawn(function()
			task.wait(0.25)

			for i = 1, 4 do
				local clone2 = C.Phase1.CubeAura:Clone()
				clone2.Size = Vector3.new(135, 1.5, clone2.Size.Z)
				clone2.CFrame = startCFrame * CFrame.Angles(0, math.rad(i * 90), 0)
				clone2.Parent = folder
				clone2.CFrame *= CFrame.new(0, 0, -97.2)
				TweenService:Create(clone2, TweenInfo.new(0.5), {
					CFrame = clone2.CFrame * CFrame.new(0, 75, 0),
					Size = Vector3.new(160, 150, clone2.Size.Z * 1.25)
				}):Play()
				local folder2 = clone2
				task.delay(0.5, function()
					for i2, emitter in pairs(folder2:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end
				end)
			end
		end)
		task.spawn(function()
			task.wait(0.225)

			for i = 1, 4 do
				local clone2 = C.Phase1.BeamWall:Clone()
				clone2.CFrame = startCFrame * CFrame.Angles(0, math.rad(i * 90), 0)
				clone2.Parent = folder
				clone2.CFrame *= CFrame.new(0, -5, -80)

				for _, beam in pairs(clone2:GetDescendants()) do
					if beam.Name == "Attach1" then
						local tween = TweenService:Create(beam, TweenInfo.new(0.25), {
							Position = createVector(0, 150, 0)
						})
						beam.Position = createVector(0, 0, 0)
						tween:Play()
						local v3 = beam
						task.delay(0.35, function()
							TweenService:Create(v3.Parent.Attach0, TweenInfo.new(0.5), {
								Position = v3.Position
							}):Play()
						end)
					elseif beam:IsA("Beam") then
						beam.Width0 = 162
						beam.Width1 = 162
					end
				end

				task.delay(1, function()
					clone2:Destroy()
				end)
			end
		end)
	elseif stage == 3 then
		local startCFrame = player.StartCFrame
		local v = player.Root and player.Root.Parent == game.Players.LocalPlayer.Character
		local _ = C.Phase1.GlowBox
		local children = {}
		local random = Random.new(player.Seed)
		local parent = _WorldOrigin:FindFirstChild("CreationC" .. player.Seed) or Instance.new("Folder")
		parent.Parent = _WorldOrigin
		Util.Debris:AddItem(parent, 15)
		parent.ChildAdded:Connect(function(child)
			if child.Name == "CubePart" then
				table.insert(children, child)

				if v then
					return
				end

				local flag = false

				for _, v4 in pairs(player.CaughtInside or {}) do
					if v4 ~= game.Players.LocalPlayer.Character then
						continue
					end

					flag = true
					break
				end

				if flag then
					rocks:ApplyCollision(child, nil, true)
				end
			end
		end)
		task.spawn(function()
			local cFrame = startCFrame * CFrame.new(0, 75, 0)
			task.wait(0.3)
			local clones = {}
			local v4 = false
			task.spawn(function()
				local clone = C.Phase3.AreaHitImpact:Clone()
				clone.CFrame = cFrame
				clone.Parent = parent
				local now = tick()
				task.wait(0.5)

				for _ = 1, 10 do
					WeaponStab(cFrame, parent, clones, now) -- equivalent call inferred; original call site unknown

					for _, emitter in pairs(clone:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter:Emit(emitter:GetAttribute("EmitCount"))
						end
					end

					task.wait(0.075)
				end
			end)
			task.spawn(function()
				local caughtInside = player.CaughtInside

				if caughtInside[1] then
					for _, v5 in pairs(caughtInside) do
						local v6 = v5
						task.spawn(function()
							local v7 = v6
							local clone = C.Phase3.SwordEndImpact:Clone()
							clone.CFrame = cFrame
							clone.Parent = parent
							local clone2 = C.Phase3.SwordHitImpactSmall:Clone()
							clone2.CFrame = startCFrame
							clone2.Parent = parent
							local clone3 = C.Phase3.TrapModel:Clone()
							clone3:PivotTo(v7:GetPivot())
							clone3:ScaleTo(v7:GetScale() * 1.25)
							clone3.Parent = parent

							for i, attachment in pairs(clone3:GetDescendants()) do
								if not attachment:IsA("Attachment") then
									continue
								end

								local tween = TweenService:Create(attachment, TweenInfo.new(0.25), {
									Position = attachment.Position
								})
								attachment.Position = createVector(0, 0, 0)
								tween:Play()
							end

							local v8 = true
							task.spawn(function()
								local total = 0

								while v8 and v4 == false do
									clone3:PivotTo(CFrame.new(v7:GetPivot().Position) * CFrame.Angles(0, total, 0))
									total += 1.0471975511965976 * task.wait() / 0.25
								end

								clone3:Destroy()
							end)

							for i = 1, 15 do
								task.spawn(function()
									local v9 = v7.PrimaryPart.CFrame * CFrame.new(
										math.random(-1, 1),
										math.random(-1, 1),
										0
									)
									local clone4 = C.Phase3.WeaponSmall:Clone()
									clone4.CFrame = v9 * CFrame.Angles(
										math.rad((math.random(-130, 0))),
										math.rad(math.random(-180, 180) / 2),
										(math.rad((math.random(-180, 180))))
									)
									local ray = Ray.new(
										clone4.Position,
										CFrame.new(clone4.Position, clone4.CFrame * CFrame.new(0, 0, 100).Position).LookVector * 100
									)
									local part, v10 = workspace:FindPartOnRayWithWhitelist(ray, children)
									local magnitude = (clone4.Position - v10).Magnitude
									clone4.CFrame *= CFrame.new(0, 0, magnitude)
									clone4.CFrame = CFrame.new(clone4.Position, v9.Position)
									clone4.Parent = parent
									clone4.Model:ScaleTo(2.5 + math.random(-10, 5) / 10)
									local clone5 = C.Phase3.Portal:Clone()
									clone5.CFrame = clone4.CFrame
									clone5.Parent = parent

									for i2, emitter in pairs(clone5:GetDescendants()) do
										if not emitter:IsA("ParticleEmitter") then
											continue
										end

										local v11 = emitter
										task.spawn(function()
											v11:Emit(v11:GetAttribute("EmitCount"))
											v11.Enabled = true
											task.wait(0.35)
											v11.Enabled = false
										end)
									end

									for i2, emitter in pairs(clone4:GetDescendants()) do
										if not emitter:IsA("ParticleEmitter") then
											continue
										end

										local v11 = emitter
										task.spawn(function()
											v11:Emit(v11:GetAttribute("EmitCount"))
											v11.Enabled = true
											task.wait(0.45)
											v11.Enabled = false
										end)
									end

									table.insert(clones, clone4)
									local v11 = (clone4.Position - v9.Position).Magnitude - 3
									local tween = TweenService:Create(
										clone4,
										TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In),
										{
											CFrame = clone4.CFrame * CFrame.new(0, 0, -v11) * CFrame.Angles(
												0,
												0,
												(math.rad((math.random(-180, 180))))
											)
										}
									)
									tween:Play()
									tween.Completed:Wait()
									clone2.CFrame = clone4.CFrame

									for i2, emitter in pairs(clone2:GetDescendants()) do
										if emitter:IsA("ParticleEmitter") then
											emitter:Emit(emitter:GetAttribute("EmitCount"))
										end
									end

									task.delay(0.05, function()
										clone.CFrame = clone4.CFrame

										for i2, emitter in pairs(clone:GetDescendants()) do
											if emitter:IsA("ParticleEmitter") then
												emitter:Emit(emitter:GetAttribute("EmitCount"))
											end
										end

										task.wait(0.1)
										clone4:Destroy()
									end)
								end)
								task.wait(0.05 * random:NextNumber(0, 1) + 0.025)

								if v4 == true then
									break
								end
							end

							task.wait(1)
							v8 = false
						end)
					end
				end
			end)
			task.spawn(function()
				task.wait(1.55)

				for _, v5 in pairs(clones) do
					v5:Destroy()
				end

				clones = nil
			end)
			task.wait(0.5)
			task.wait(1.15)
			v4 = true
			local clone = C.Phase4.EndImpact:Clone()
			clone.CFrame = cFrame
			clone.Parent = parent

			for _, emitter in pairs(clone:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v5 = emitter
				task.spawn(function()
					if v5:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v5:GetAttribute("EmitDelay"))
					end

					v5:Emit(v5:GetAttribute("EmitCount"))
				end)
			end

			DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
			local clone2 = C.Phase4.Explosion:Clone()
			clone2.CFrame = cFrame
			clone2.Parent = parent

			for _, emitter in pairs(clone2:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v5 = emitter
				task.spawn(function()
					if v5:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v5:GetAttribute("EmitDelay"))
					end

					v5:Emit(v5:GetAttribute("EmitCount"))
				end)
			end

			DeleteImpactAfterDuration(clone2) -- equivalent call inferred; original call site unknown

			for _, part in pairs(parent:GetChildren()) do
				if not (part:IsA("BasePart") and part.Name == "CubePart") then
					continue
				end

				local v5 = part
				task.spawn(function()
					v5.CanCollide = true
					rocks:ApplyCollision(v5, nil, true)
					v5.Anchored = false
					v5.Massless = false
					local v6 = 0.1 * math.random() + 0.2
					local tween = TweenService:Create(
						v5,
						TweenInfo.new(v6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Position = CFrame.new(v5.Position, cFrame.Position) * CFrame.new(
								0,
								math.random(10, 50),
								50 * math.random() + 50
							).Position,
							Orientation = Vector3.new(math.random(-50, 50), math.random(-50, 50), math.random(-50, 50)),
							Size = Vector3.new(
								v5.Size.X / math.random(2, 5),
								v5.Size.Y / math.random(2, 5),
								v5.Size.Z / math.random(2, 5)
							)
						}
					)
					tween:Play()
					task.spawn(function()
						task.wait(v6 * 0.8)
						tween:Pause()
						tween:Destroy()
						v5.Velocity = CFrame.new(v5.Position, cFrame.Position).LookVector * -math.random(50, 100)
					end)
					v5.SelectionBox.LineThickness = 0.25
					task.wait(1.5)
					task.wait(0.5 * math.random())
					local tween2 = TweenService:Create(v5, TweenInfo.new(0.225), {
						Size = createVector(0, 0, 0),
						Orientation = Vector3.new(math.random(-50, 50), math.random(-50, 50), math.random(-50, 50))
					})
					tween2:Play()
					tween2.Completed:Wait()
					v5.SelectionBox.Transparency = 1
				end)
			end
		end)
	end
end