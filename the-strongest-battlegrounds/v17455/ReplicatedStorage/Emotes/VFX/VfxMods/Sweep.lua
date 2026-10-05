local createVector = vector.create
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local whilwindFX = game.ReplicatedStorage.Resources.OldPirate.WhilwindFX
local thrown = game.Workspace.Thrown
local Sweep = {}

function Sweep.spin(player, _)
	player.Utilities = require(script.Parent.Utilities)
	local alignGroups = {}
	local alignGroup = player.Utilities.AlignGroup(whilwindFX.Spin:Clone(), player.Character.PrimaryPart.CFrame)
	alignGroup.Parent = thrown
	player.Utilities.Debris(alignGroup, 5)
	local v = {}
	table.insert(alignGroups, alignGroup)
	task.spawn(function()
		local lastTime = tick()

		while tick() - lastTime < 3 and alignGroup.Parent do
			for _, v2 in pairs(alignGroups) do
				v2:PivotTo(player.Character.PrimaryPart.CFrame)
			end

			local RunService = game:GetService("RunService")
			RunService.RenderStepped:Wait()
		end
	end)
	v.beamthread = task.spawn(function()
		v.white = task.spawn(function()
			local beams = {}

			for _, folder in alignGroup.beam:GetChildren() do
				if folder:IsA("Folder") then
					continue
				end

				for _, beam in folder:GetDescendants() do
					if not beam:IsA("Beam") then
						continue
					end

					local _ = beam.Attachment0
					local _ = beam.Attachment1
					beam:SetAttribute("wd0", beam.Width0)
					beam:SetAttribute("wd1", beam.Width1)
					beam.Width0 = 0
					beam.Width1 = 0
					table.insert(beams, beam)
				end

				local v2 = folder
				task.spawn(function()
					for i = 1, 40000 do
						local orientation, v3, v4 = v2.CFrame:ToOrientation()
						local tween = TweenService:Create(v2, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {
							CFrame = CFrame.new(
								player.Character.PrimaryPart.Position.X,
								v2.Position.Y,
								player.Character.PrimaryPart.Position.Z
							) * CFrame.Angles(orientation, v3, v4) * CFrame.Angles(0, -2.0943951023931953, 0)
						})
						tween:Play()
						tween.Completed:Wait()
					end
				end)
			end

			for _, v2 in beams do
				task.wait(0.05)
				TweenService:Create(v2, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
					Width0 = v2:GetAttribute("wd0"),
					Width1 = v2:GetAttribute("wd1")
				}):Play()
				local v3 = v2
				task.delay(0.85, function()
					TweenService:Create(v3, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
						Width0 = 0,
						Width1 = 0
					}):Play()
				end)
			end
		end)
		v.blue = task.spawn(function()
			for _, folder in alignGroup.beam:GetChildren() do
				if not folder:IsA("Folder") then
					continue
				end

				for _, descendant in folder:GetDescendants() do
					if descendant:IsA("BasePart") then
						local v2 = descendant
						task.spawn(function()
							for i = 1, 40000 do
								local tween = TweenService:Create(v2, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
									CFrame = v2.CFrame * CFrame.Angles(0, -2.0943951023931953, 0)
								})
								tween:Play()
								tween.Completed:Wait()
							end
						end)
					end

					if not descendant:IsA("Beam") then
						continue
					end

					local attachment0 = descendant.Attachment0
					local attachment1 = descendant.Attachment1
					local width0 = descendant.Width0
					local width1 = descendant.Width1
					descendant.Width0 = 0
					descendant.Width1 = 0
					TweenService:Create(
						descendant,
						TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
						{
							Width0 = width0,
							Width1 = width1
						}
					):Play()
					local v3 = descendant
					task.delay(0.25, function()
						TweenService:Create(attachment1, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
							Position = attachment1.Position * 1.15
						}):Play()
						TweenService:Create(v3, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
							CurveSize0 = v3.CurveSize0 * 1.15,
							CurveSize1 = v3.CurveSize1 * 1.15
						}):Play()
					end)
					local v4 = attachment1
					local v6 = descendant
					task.delay(0.85, function()
						TweenService:Create(v4, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
							Position = v4.CFrame:Lerp(attachment0.CFrame, 0.5).Position + createVector(0, -25, 0)
						}):Play()
						TweenService:Create(v6, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
							CurveSize0 = -25,
							CurveSize1 = 0
						}):Play()
						TweenService:Create(v6, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
							Width0 = 0,
							Width1 = 0
						}):Play()
						task.delay(0.1, function()
							TweenService:Create(
								v4,
								TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
								{
									CFrame = v4.CFrame * CFrame.new(5, 0, -30)
								}
							):Play()
							TweenService:Create(
								v6,
								TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
								{
									CurveSize0 = 0,
									CurveSize1 = 0
								}
							):Play()
						end)
					end)
				end
			end
		end)
	end)
	v.meshhread = task.spawn(function()
		for _, child in alignGroup.mesh:GetChildren() do
			local v2 = child
			task.spawn(function()
				task.delay(0.75, function()
					TweenService:Create(v2.Decal, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
						Transparency = 1
					}):Play()
				end)

				for i = 1, 25 do
					local orientation, v3, v4 = v2.CFrame:ToOrientation()
					local tween = TweenService:Create(v2, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {
						CFrame = CFrame.new(
							player.Character.PrimaryPart.Position.X,
							v2.Position.Y,
							player.Character.PrimaryPart.Position.Z
						) * CFrame.Angles(orientation, v3, v4) * CFrame.Angles(0, -2.0943951023931953, 0)
					})
					tween:Play()
					tween.Completed:Wait()
				end
			end)
		end
	end)
	v.fxhread = task.spawn(function()
		task.delay(0.86, function()
			player.Utilities.VFXHandle(alignGroup.Spin, {
				Toggle = "Off"
			})
			task.wait(0.015)
			player.Utilities.VFXHandle(alignGroup.Ground, {
				Toggle = "Off"
			})
		end)
	end)
	v.emithread = task.spawn(function()
		for _ = 1, 8 do
			local alignGroup2 = player.Utilities.AlignGroup(
				whilwindFX.Emit:Clone(),
				player.Character.PrimaryPart.CFrame * CFrame.Angles(0, math.rad((math.random(0, 360))), 0)
			)
			alignGroup2.Parent = thrown
			player.Utilities.VFXHandle(alignGroup2, {
				Debris = 3,
				Emit = true
			})
			v.wind = task.spawn(function()
				local wind = alignGroup2.mesh.Wind
				TweenService:Create(wind, TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					CFrame = wind.CFrame * CFrame.new(0, 5, 0),
					Size = createVector(60, 15, 60)
				}):Play()
				TweenService:Create(wind, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					Transparency = 1
				}):Play()

				for i = 1, 9 do
					local tween = TweenService:Create(wind, TweenInfo.new(0.075, Enum.EasingStyle.Linear), {
						CFrame = wind.CFrame * CFrame.Angles(0, -2.0943951023931953, 0) * CFrame.new(0, 5, 0)
					})
					tween:Play()
					tween.Completed:Wait()
				end
			end)
			local v3 = alignGroup2
			v.mesh = task.spawn(function()
				local mesh = v3.mesh.mesh
				TweenService:Create(
					mesh.Mesh,
					TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Offset = createVector(0, -10, 0),
						Scale = createVector(25, 35, 25) * Random.new():NextInteger(1.15, 1.65)
					}
				):Play()
				TweenService:Create(mesh.decal, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					Transparency = 1
				}):Play()

				for i = 1, 9 do
					local tween = TweenService:Create(mesh, TweenInfo.new(0.175, Enum.EasingStyle.Linear), {
						CFrame = mesh.CFrame * CFrame.Angles(0, -2.0943951023931953, 0) * CFrame.new(0, 5, 0)
					})
					tween:Play()
					tween.Completed:Wait()
				end
			end)
			task.wait(0.15)
		end
	end)
	alignGroup.Destroying:Once(function()
		for _, v2 in v do
			task.cancel(v2)
		end
	end)
end

function Sweep.slash(player, _)
	player.Utilities = require(script.Parent.Utilities)

	if player.Character:FindFirstChild("Welds") then
		local bisento = player.Character.Welds:FindFirstChild("Bisento", true)
		local v = player.Utilities.AttachVFX(
			whilwindFX.fx.start.Part:GetChildren(),
			bisento:FindFirstChild("Top", true)
		)
		player.Utilities.VFXHandle(v, {
			Emit = true,
			Debris = 3
		})
		task.delay(0.25, function()
			local v2 = player.Utilities.AttachVFX(
				whilwindFX.fx.idle.Part:GetChildren(),
				bisento:FindFirstChild("Top", true)
			)
			player.Utilities.VFXHandle(v2, {
				Toggle = "On",
				Debris = 0.65
			})
		end)
		local alignGroup, _ = player.Utilities.AlignGroup(whilwindFX.bistentofx:Clone(), bisento.PrimaryPart.CFrame)
		alignGroup.Parent = thrown
		task.spawn(function()
			while alignGroup.Parent do
				alignGroup:PivotTo(bisento.PrimaryPart.CFrame)
				task.wait()
			end
		end)
		task.spawn(function()
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
			}, TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 1, false), function()
				alignGroup:Destroy()
			end)
		end)
		task.wait(0.25)
		local alignGroup2, _ = player.Utilities.AlignGroup(
			whilwindFX.charage:Clone(),
			player.Character.PrimaryPart.CFrame
		)
		alignGroup2.Parent = thrown
		player.Utilities.VFXHandle(alignGroup2, {
			Emit = true,
			Debris = 8
		})
		local ring = alignGroup2.ring
		TweenService:Create(ring, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			CFrame = ring.CFrame * CFrame.new(0, -10, 0),
			Size = createVector(25, 7.5, 25)
		}):Play()
		TweenService:Create(ring, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
	end
end

function Sweep.int(player, _)
	player.Utilities = require(script.Parent.Utilities)
	task.delay(0.1, function()
		local alignGroup, _ = player.Utilities.AlignGroup(
			whilwindFX.smash.white:Clone(),
			player.Character.PrimaryPart.CFrame * CFrame.new(0, 0, -10) * CFrame.Angles(
				1.5707963267948966,
				0,
				1.5707963267948966
			)
		)
		alignGroup.Parent = thrown
		player.Utilities.VFXHandle(alignGroup, {
			Emit = true,
			Debris = 2
		})
	end)
	task.wait(0.15)
	local alignGroup, _ = player.Utilities.AlignGroup(whilwindFX.wind:Clone(), player.Character.PrimaryPart.CFrame)
	alignGroup.Parent = thrown
	player.Utilities.VFXHandle(alignGroup, {
		Emit = true,
		Debris = 2
	})

	for _, child in alignGroup.cut.Attachment:GetChildren() do
		local beam = child:FindFirstChildWhichIsA("Beam")
		local _ = beam.Attachment0
		local _ = beam.Attachment1
		TweenService:Create(beam, TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			Width0 = 0,
			Width1 = 0
		}):Play()
	end
end

function Sweep.smash(state, _)
	state.Utilities = require(script.Parent.Utilities)
	local anchor = state.Data.Anchor
	local alignGroup = state.Utilities.AlignGroup(whilwindFX.Smash:Clone(), anchor * CFrame.new(0, 0, -10))
	alignGroup.Parent = thrown
	state.Utilities.VFXHandle(alignGroup, {
		Emit = true,
		Debris = 10
	})
	local v = {
		growglass = task.spawn(function()
			local quake = alignGroup.flipbook.Quake
			quake.CFrame *= CFrame.Angles(0, math.rad((math.random(0, 360))), 0)
			state.Utilities.TweenFlipbook(quake, {
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
			}, TweenInfo.new(0.125, Enum.EasingStyle.Sine, Enum.EasingDirection.In), function()
				TweenService:Create(
					quake.Decal,
					TweenInfo.new(0.125, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
					{
						Transparency = 0.875
					}
				):Play()
				TweenService:Create(
					quake.Mesh,
					TweenInfo.new(0.125, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
					{
						Scale = quake.Mesh.Scale * 0.5
					}
				):Play()
				state.Utilities.TweenFlipbook(alignGroup.flipbook.Quake, {
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
				}, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), function()
					alignGroup.flipbook.Quake:Destroy()
				end)
			end)
		end),
		bluegrowglass = task.spawn(function()
			task.wait(0.144)
			local quake2 = alignGroup.flipbook.Quake2
			quake2.CFrame *= CFrame.Angles(0, math.rad((math.random(0, 360))), 0)
			state.Utilities.TweenFlipbook(quake2, {
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
			}, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.In), function()
				task.delay(0.5, function()
					state.Utilities.TweenFlipbook(quake2, {
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
					}, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), function() end)
					task.delay(0.325, function()
						local alignGroup2, _ = state.Utilities.AlignGroup(
							whilwindFX.smash.blue:Clone(),
							quake2.CFrame * CFrame.Angles(1.5707963267948966, 0, 1.5707963267948966)
						)
						alignGroup2.Parent = thrown
						state.Utilities.VFXHandle(alignGroup2, {
							Emit = true,
							Debris = 5
						})
					end)
				end)
			end)
			TweenService:Create(
				quake2.Mesh,
				TweenInfo.new(0.1725, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Scale = quake2.Mesh.Scale * 1.95
				}
			):Play()
		end),
		meshthread = task.spawn(function()
			local wind = alignGroup.mesh.wind
			state.Utilities.GetTween(wind).play()
			local mesh1 = alignGroup.mesh.mesh1
			state.Utilities.GetTween(mesh1).play()
			local mesh = alignGroup.mesh.mesh
			state.Utilities.GetTween(mesh).play()
			local mesh2 = alignGroup.mesh.mesh2
			local highlight = Instance.new("Highlight", mesh2)
			highlight.OutlineTransparency = 1
			highlight.FillTransparency = 1
			state.Utilities.GetTween(mesh2).play()
		end)
	}
	alignGroup.Destroying:Connect(function()
		for _, v2 in v do
			task.cancel(v2)
		end
	end)
end

function Sweep.projectile(player, _)
	player.Utilities = require(script.Parent.Utilities)
	local alignGroup = player.Utilities.AlignGroup(
		whilwindFX.Projectile:Clone(),
		player.Character.PrimaryPart.CFrame * CFrame.new(0, -3, -25)
	)
	alignGroup.Parent = thrown
	local v = {}
	player.Utilities.Debris(alignGroup, 5)
	v.projectilethread = task.spawn(function()
		v.tweenmodel = task.spawn(function()
			while alignGroup.Parent do
				alignGroup:PivotTo(alignGroup:GetPivot() * CFrame.new(0, 0, -0.75))
				task.wait()
			end
		end)
		v.spinfx = task.spawn(function()
			while alignGroup.Parent and alignGroup do
				alignGroup.Beams.Beams.CFrame *= CFrame.Angles(0, 0, -0.04363323129985824)
				task.wait()
			end
		end)
		task.delay(0.75, function()
			task.cancel(v.tweenmodel)
			task.cancel(v.spinfx)
			v.spinfx = nil
			v.tweenmodel = nil
			alignGroup:Destroy()
		end)
	end)
	alignGroup.Destroying:Connect(function()
		for _, v2 in v do
			task.cancel(v2)
		end
	end)
end

function Sweep.destroy(instance, _)
	instance:Destroy()
end

return Sweep