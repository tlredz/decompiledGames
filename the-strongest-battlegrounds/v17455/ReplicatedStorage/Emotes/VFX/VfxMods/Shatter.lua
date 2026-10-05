local createVector = vector.create
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local mowingBladeFX = game.ReplicatedStorage.Resources.OldPirate.MowingBladeFX
local thrown = game.Workspace.Thrown
local Shatter = {}

function Shatter.start(player, _)
	if player.Character:FindFirstChild("Welds") then
		local bisento = player.Character.Welds:FindFirstChild("Bisento", true)
		player.Utilities = require(script.Parent.Utilities)
		local alignGroup, _ = player.Utilities.AlignGroup(mowingBladeFX.bistentofx:Clone(), bisento.PrimaryPart.CFrame)
		alignGroup.Parent = thrown
		task.spawn(function()
			while alignGroup.Parent do
				alignGroup:PivotTo(bisento.PrimaryPart.CFrame)
				task.wait()
			end
		end)
		player.Utilities.Debris(alignGroup, 10)
		task.spawn(function()
			local v = player.Utilities.AttachVFX(
				mowingBladeFX.fx.start.Part:GetChildren(),
				bisento:FindFirstChild("Top", true)
			)
			player.Utilities.VFXHandle(v, {
				Emit = true,
				Debris = 3
			})
			task.delay(0.25, function()
				local v2 = player.Utilities.AttachVFX(
					mowingBladeFX.fx.idle.Part:GetChildren(),
					bisento:FindFirstChild("Top", true)
				)
				player.Utilities.VFXHandle(v2, {
					Toggle = "On",
					Debris = 0.65
				})
			end)
			player.Utilities.TweenFlipbook(alignGroup.PrimaryPart, {
				"rbxassetid://18808458718",
				"rbxassetid://18808458614",
				"rbxassetid://18808458527",
				"rbxassetid://18808458417",
				"rbxassetid://18808458276",
				"rbxassetid://18808457993",
				"rbxassetid://18808457805",
				"rbxassetid://18808457681",
				"rbxassetid://18808457556",
				"rbxassetid://18808457407",
				"rbxassetid://18808457280",
				"rbxassetid://18808457079"
			}, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 1, false), function()
				alignGroup:Destroy()
			end)
		end)
	end
end

function Shatter.freeze(player, _)
	player.Utilities = require(script.Parent.Utilities)
	local alignGroup, _ = player.Utilities.AlignGroup(mowingBladeFX.freeze:Clone(), player.Character.PrimaryPart.CFrame)
	alignGroup.Parent = thrown
	player.Utilities.VFXHandle(alignGroup, {
		Emit = true,
		Debris = 3
	})
	local cut = alignGroup.cut
	cut.Parent = nil
	task.delay(0.075, function()
		for _, emitter in alignGroup.fx.FX:GetChildren() do
			if emitter:IsA("ParticleEmitter") then
				emitter.TimeScale = 0.05
			end
		end

		task.delay(0.175, function()
			alignGroup.fx.FX.Parent = nil
		end)
	end)
	task.delay(0.15, function()
		for _, child in alignGroup.ground.Attachment:GetChildren() do
			local beam = child:FindFirstChildWhichIsA("Beam")
			local attachment0 = beam.Attachment0
			local attachment1 = beam.Attachment1
			local tween = TweenService:Create(
				attachment0,
				TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
				{
					Position = CFrame.new(0, 0, 0).Position
				}
			)
			tween:Play()
			TweenService:Create(beam, TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
				CurveSize0 = 0,
				CurveSize1 = 0
			}):Play()
			tween.Completed:Once(function()
				TweenService:Create(
					attachment0,
					TweenInfo.new(0.05, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Position = attachment1.CFrame.Position
					}
				):Play()
			end)
		end

		for _, beam in alignGroup.fx.Beams:GetDescendants() do
			if not beam:IsA("Beam") then
				continue
			end

			local attachment0 = beam.Attachment0
			local attachment1 = beam.Attachment1

			if beam.Name == "Beam" then
				TweenService:Create(beam, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
					TextureSpeed = -2
				}):Play()
				TweenService:Create(beam, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					Width0 = 0,
					Width1 = 15
				}):Play()
				local v = beam
				local attachment = attachment1
				local attachment2 = attachment0
				task.delay(0.25, function()
					TweenService:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
						Width0 = 0,
						Width1 = 0
					}):Play()
					TweenService:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
						CurveSize0 = -4,
						CurveSize1 = 0
					}):Play()
					TweenService:Create(
						attachment,
						TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
						{
							Position = attachment.CFrame:Lerp(attachment2.CFrame, 0.5).Position
						}
					):Play()
					player.Utilities.TweenNumberSequence(
						v.Transparency,
						NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 1) }),
						50,
						0.5,
						v,
						"Transparency",
						Enum.EasingStyle.Sine,
						Enum.EasingDirection.In
					)
				end)
			else
				TweenService:Create(beam, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					Width0 = 0,
					Width1 = 0
				}):Play()
			end
		end

		task.wait(0.2)
		cut.Parent = alignGroup

		for _, child in cut.Attachment:GetChildren() do
			local beam = child:FindFirstChildWhichIsA("Beam")
			local attachment0 = beam.Attachment0
			local attachment1 = beam.Attachment1
			local tween = TweenService:Create(attachment0, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
				Position = CFrame.new(0, 0, 0).Position
			})
			tween:Play()
			TweenService:Create(beam, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
				CurveSize0 = 0,
				CurveSize1 = 0
			}):Play()
			tween.Completed:Once(function()
				TweenService:Create(
					attachment0,
					TweenInfo.new(0.05, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Position = attachment1.CFrame.Position
					}
				):Play()
			end)
		end
	end)
end

function Shatter.crack(player, _)
	if player.Character:FindFirstChild("Welds") then
		player.Utilities = require(script.Parent.Utilities)
		local _, v, _ = player.Utilities.CreateOrgin(player.Character.PrimaryPart.CFrame, nil)
		player.Character.Welds:FindFirstChild("Bisento", true):FindFirstChild("Top", true):ClearAllChildren()
		local v2 = v + v.LookVector * 10
		local alignGroup, _ = player.Utilities.AlignGroup(mowingBladeFX.smash.crack:Clone(), v2)
		alignGroup.Parent = thrown
		player.Utilities.Debris(alignGroup, 10)
		local v3 = {
			mesh1 = task.spawn(function()
				local mesh = alignGroup.Mesh.mesh
				task.spawn(function()
					for _ = 1, 40000 do
						mesh.CFrame *= CFrame.Angles(0, 0.2617993877991494, 0)
						task.wait(0.01)
					end
				end)
				TweenService:Create(mesh, TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					Position = (mesh.CFrame * CFrame.new(0, 20, 0)).Position
				}):Play()
				TweenService:Create(
					mesh.Mesh,
					TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Scale = createVector(25, 2.5, 25)
					}
				):Play()
				TweenService:Create(
					mesh.decal,
					TweenInfo.new(0.3375, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut),
					{
						Transparency = 1
					}
				):Play()
			end),
			mesh2 = task.spawn(function()
				local mesh2 = alignGroup.Mesh.mesh2
				TweenService:Create(mesh2, TweenInfo.new(0.25, Enum.EasingStyle.Circular, Enum.EasingDirection.Out), {
					Position = (mesh2.CFrame * CFrame.new(0, -20, 0)).Position
				}):Play()
				TweenService:Create(
					mesh2.Mesh,
					TweenInfo.new(0.25, Enum.EasingStyle.Circular, Enum.EasingDirection.Out),
					{
						Scale = createVector(17.5, 10, 17.5)
					}
				):Play()
				TweenService:Create(mesh2.decal, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					Transparency = 1
				}):Play()
			end),
			growglass = task.spawn(function()
				local quake = alignGroup.Flipbook.Quake
				quake.CFrame *= CFrame.Angles(0, math.rad((math.random(0, 360))), 0)
				player.Utilities.TweenFlipbook(quake, {
					"rbxassetid://18840126037",
					"rbxassetid://18840125833",
					"rbxassetid://18840125602",
					"rbxassetid://18840125602",
					"rbxassetid://18840125602",
					"rbxassetid://18840125602",
					"rbxassetid://18840125449",
					"rbxassetid://18840125332",
					"rbxassetid://18840125174",
					"rbxassetid://18840125022",
					"rbxassetid://18840124888",
					"rbxassetid://18840124504",
					"rbxassetid://18840124339",
					"rbxassetid://18840124089"
				}, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.In), nil)
				TweenService:Create(
					quake.Decal,
					TweenInfo.new(0.1725, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
					{
						Transparency = 0.875
					}
				):Play()
				TweenService:Create(
					quake.Mesh,
					TweenInfo.new(0.1725, Enum.EasingStyle.Circular, Enum.EasingDirection.Out),
					{
						Scale = quake.Mesh.Scale * 0.5
					}
				):Play()
				task.delay(0.32249999999999995, function()
					TweenService:Create(
						quake.Decal,
						TweenInfo.new(0.375, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
						{
							Transparency = 0.95
						}
					):Play()
				end)
				local alignGroup2, _ = player.Utilities.AlignGroup(mowingBladeFX.smash.white:Clone(), v2)
				alignGroup2.Parent = thrown
				player.Utilities.VFXHandle(alignGroup2, {
					Emit = true,
					Debris = 2
				})
			end)
		}
		task.delay(0.0975, function()
			player.Utilities.VFXHandle(alignGroup, {
				Emit = true
			})
			v3.bluegrowglass = task.spawn(function()
				local quake2 = alignGroup.Flipbook.Quake2
				quake2.CFrame *= CFrame.Angles(0, math.rad((math.random(0, 360))), 0)
				player.Utilities.TweenFlipbook(quake2, {
					"rbxassetid://18841684798",
					"rbxassetid://18841684701",
					"rbxassetid://18841684605",
					"rbxassetid://18841684408",
					"rbxassetid://18841684235",
					"rbxassetid://18841684134",
					"rbxassetid://18841683940",
					"rbxassetid://18841683790",
					"rbxassetid://18841683499",
					"rbxassetid://18841683231",
					"rbxassetid://18841683007",
					"rbxassetid://18841682830"
				}, TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.In), function()
					task.delay(0.5, function()
						player.Utilities.TweenFlipbook(quake2, {
							"rbxassetid://18841682830",
							"rbxassetid://18841683007",
							"rbxassetid://18841683231",
							"rbxassetid://18841683499",
							"rbxassetid://18841683790",
							"rbxassetid://18841683940",
							"rbxassetid://18841684134",
							"rbxassetid://18841684235",
							"rbxassetid://18841684408",
							"rbxassetid://18841684605",
							"rbxassetid://18841684701",
							"rbxassetid://18841684798"
						}, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), function()
							alignGroup:Destroy()
						end)
						task.delay(0.1, function()
							TweenService:Create(
								alignGroup.Flipbook.Quake.Decal,
								TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut),
								{
									Transparency = 0
								}
							):Play()
							player.Utilities.TweenFlipbook(alignGroup.Flipbook.Quake, {
								"rbxassetid://18840124089",
								"rbxassetid://18840124339",
								"rbxassetid://18840124504",
								"rbxassetid://18840124888",
								"rbxassetid://18840125022",
								"rbxassetid://18840125174",
								"rbxassetid://18840125332",
								"rbxassetid://18840125449",
								"rbxassetid://18840125602",
								"rbxassetid://18840125602",
								"rbxassetid://18840125833",
								"rbxassetid://18840126037"
							}, TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.In), function()
								if alignGroup and alignGroup.Flipbook and alignGroup.Flipbook.Quake then
									alignGroup.Flipbook.Quake:Destroy()
								end
							end)
						end)
						task.delay(0.325, function()
							local alignGroup2, _ = player.Utilities.AlignGroup(mowingBladeFX.smash.blue:Clone(), v2)
							alignGroup2.Parent = thrown
							player.Utilities.VFXHandle(alignGroup2, {
								Emit = true,
								Debris = 5
							})
						end)
					end)
				end)
				TweenService:Create(
					quake2.Mesh,
					TweenInfo.new(0.2875, Enum.EasingStyle.Circular, Enum.EasingDirection.Out),
					{
						Scale = quake2.Mesh.Scale * 1.25
					}
				):Play()
			end)
		end)
		alignGroup.Destroying:Connect(function()
			for _, v4 in v3 do
				task.cancel(v4)
			end
		end)
	end
end

function Shatter.swing(player, _)
	player.Utilities = require(script.Parent.Utilities)
	local _, v, _ = player.Utilities.CreateOrgin(player.Character.PrimaryPart.CFrame, nil)
	local v2 = {}
	local alignGroup, _ = player.Utilities.AlignGroup(mowingBladeFX.jump.dash:Clone(), v)
	alignGroup.Parent = thrown
	player.Utilities.VFXHandle(alignGroup, {
		Emit = true,
		Debris = 5
	})
	v2.basebeam = task.spawn(function()
		local fx = alignGroup.fx
		task.spawn(function()
			local v3 = 10

			for _ = 1, 40000 do
				if v3 <= 0 then
					break
				end

				fx.CFrame *= CFrame.Angles(0, 0, (math.rad(-v3)))
				v3 -= 0.35
				task.wait(0.015)
			end
		end)

		for _, beam in fx:GetDescendants() do
			if not beam:IsA("Beam") then
				continue
			end

			local attachment0 = beam.Attachment0
			local attachment1 = beam.Attachment1
			local tween = TweenService:Create(
				attachment0,
				TweenInfo.new(0.12, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
				{
					Position = CFrame.new(0, 0, 0).Position
				}
			)
			tween:Play()
			TweenService:Create(beam, TweenInfo.new(0.12, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
				CurveSize0 = 0,
				CurveSize1 = 0
			}):Play()
			tween.Completed:Once(function()
				TweenService:Create(
					attachment0,
					TweenInfo.new(0.05, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Position = attachment1.CFrame.Position
					}
				):Play()
			end)
		end
	end)
	alignGroup.Destroying:Connect(function()
		for _, v3 in v2 do
			task.cancel(v3)
		end
	end)
end

function Shatter.projectile(state, _)
	state.Utilities = require(script.Parent.Utilities)
	local anchor = state.Data.Anchor
	local alignGroup, _ = state.Utilities.AlignGroup(mowingBladeFX.Projectile.slash:Clone(), anchor)
	alignGroup.Parent = thrown
	state.Utilities.VFXHandle(alignGroup, {
		Emit = true,
		Debris = 8
	})
	local v = {}
	local mesh = alignGroup.mesh
	task.spawn(function()
		v.mesh = task.spawn(function()
			local wind = mesh.Wind
			TweenService:Create(wind, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				CFrame = wind.CFrame * CFrame.Angles(0, -2.0943951023931953, 0) * CFrame.new(0, -5, 0),
				Size = createVector(50, 75, 50)
			}):Play()
			TweenService:Create(wind, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
				Transparency = 1
			}):Play()
		end)
		v.mesh1 = task.spawn(function()
			local ring = mesh.ring
			TweenService:Create(ring, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut), {
				Position = (ring.CFrame * CFrame.new(0, -5, 0)).Position,
				Size = createVector(45, 25, 45)
			}):Play()
			TweenService:Create(
				ring,
				TweenInfo.new(0.35000000000000003, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut),
				{
					Transparency = 1
				}
			):Play()
		end)
	end)
	local wind = alignGroup.PrimaryPart.wind
	task.spawn(function()
		v.spin = task.spawn(function()
			TweenService:Create(wind, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {
				CFrame = wind.CFrame * CFrame.Angles(0, -0, -2.0943951023931953)
			}):Play()
			task.wait(0.05)
			TweenService:Create(wind, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
				CFrame = wind.CFrame * CFrame.Angles(0, -0, -2.0943951023931953)
			}):Play()
			task.wait(0.15)
			TweenService:Create(wind, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = wind.CFrame * CFrame.Angles(0, 0, -2.0943951023931953)
			}):Play()
		end)
		v.handle = task.spawn(function()
			for _, beam in wind:GetDescendants() do
				if not beam:IsA("Beam") then
					continue
				end

				local attachment0 = beam.Attachment0
				local attachment1 = beam.Attachment1
				TweenService:Create(beam, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
					Width0 = 0,
					Width1 = 0
				}):Play()
				TweenService:Create(beam, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
					CurveSize0 = 0,
					CurveSize1 = 0
				}):Play()
				TweenService:Create(attachment1, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
					CFrame = attachment1.CFrame * CFrame.new(-25, 0, 15)
				}):Play()
				TweenService:Create(attachment0, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
					CFrame = attachment0.CFrame * CFrame.new(0, -5, -15)
				}):Play()
				task.wait(0.15)
			end
		end)
		v.circles = task.spawn(function()
			for _, beam in alignGroup.beams:GetDescendants() do
				if not beam:IsA("Beam") then
					continue
				end

				local attachment0 = beam.Attachment0
				local attachment1 = beam.Attachment1
				TweenService:Create(
					attachment1,
					TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
					{
						CFrame = attachment1.CFrame * CFrame.new(0, 0, -15)
					}
				):Play()
				TweenService:Create(
					attachment0,
					TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
					{
						CFrame = attachment0.CFrame * CFrame.new(0, 0, -15)
					}
				):Play()
				local v2 = beam
				task.spawn(function()
					state.Utilities.TweenNumberSequence(
						v2.Transparency,
						NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 1) }),
						50,
						0.15,
						v2,
						"Transparency",
						Enum.EasingStyle.Sine,
						Enum.EasingDirection.Out
					)
				end)
				task.wait(0.075)
			end
		end)
	end)
	local folder = state.Utilities.AlignGroup(
		mowingBladeFX.Projectile.Projectile:Clone(),
		anchor * CFrame.new(0, -3, -25)
	)
	folder.Parent = thrown
	local bind = state.Data.Bind
	local clone = script["wb 2nd move projectile"]:Clone()
	clone.Parent = folder.Icosphere
	clone:Play()
	task.spawn(function()
		v.tweenmodel = task.spawn(function()
			while alignGroup.Parent do
				folder:PivotTo(bind:GetAttribute("CFrame"))
				task.wait()
			end
		end)
		v.spinfx = task.spawn(function()
			local v2 = nil
			v2 = shared.loop(function()
				if alignGroup and alignGroup.Parent and folder and folder:FindFirstChild("Beams") then
					folder.Beams.Beams.CFrame *= CFrame.Angles(0, 0, -0.1832595714594046)
				else
					return v2()
				end
			end)
			task.delay(3, function()
				if v2 then
					return v2()
				end
			end)
		end)
		v.ground = task.spawn(function()
			for _, beam in folder.Beams.BeamsCheck:GetDescendants() do
				if not beam:IsA("Beam") then
					continue
				end

				local _ = beam.Attachment0
				local attachment1 = beam.Attachment1
				TweenService:Create(
					attachment1,
					TweenInfo.new(0.85, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
					{
						CFrame = attachment1.CFrame * CFrame.new(0, 0, -45)
					}
				):Play()
			end
		end)

		for _, beam in pairs(folder:GetDescendants()) do
			if beam:IsA("Beam") then
				TweenService:Create(beam, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
					TextureSpeed = -0.1
				}):Play()
			end
		end

		task.delay(0.825, function()
			for _, descendant in pairs(folder:GetDescendants()) do
				if descendant:IsA("Decal") or descendant:IsA("BasePart") then
					TweenService:Create(descendant, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
						Transparency = 1
					}):Play()
				elseif descendant:IsA("Beam") then
					TweenService:Create(
						descendant,
						TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
						{
							Width0 = 0,
							Width1 = 0
						}
					):Play()
				elseif descendant:IsA("ParticleEmitter") then
					descendant.Enabled = false
				end
			end

			game.Debris:AddItem(folder, 1)
			task.delay(0.3, function()
				task.cancel(v.tweenmodel)
				task.cancel(v.spinfx)
				v.spinfx = nil
				v.tweenmodel = nil
			end)
		end)
	end)
	alignGroup.Destroying:Connect(function()
		for _, v2 in v do
			task.cancel(v2)
		end
	end)
end

function Shatter.destroy(instance, _)
	instance:Destroy()
end

return Shatter