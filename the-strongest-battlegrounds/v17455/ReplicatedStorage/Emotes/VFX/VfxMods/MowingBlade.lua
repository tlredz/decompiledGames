local createVector = vector.create
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local Auxiliary = require(script.Parent.Auxiliary)
local shatter = game.ReplicatedStorage.Resources.OldPirate.Shatter
local v = {}
local thrown = game.Workspace.Thrown
local MowingBlade = {}

function MowingBlade.start(player, _)
	player.Utilities = require(script.Parent.Utilities)
	local alignGroup = player.Utilities.AlignGroup(shatter.Run.Start:Clone(), player.Character.PrimaryPart.CFrame)
	alignGroup.Parent = thrown
	player.Utilities.VFXHandle(alignGroup, {
		Emit = true,
		Debris = 10
	})
	local _ = {
		meshthread = task.spawn(function()
			local ground = alignGroup.mesh.ground
			player.Utilities.GetTween(ground).play()
			local mesh = alignGroup.mesh.mesh
			player.Utilities.GetTween(mesh).play()
		end)
	}
end

function MowingBlade.running(player, _)
	player.Utilities = require(script.Parent.Utilities)
	local alignGroup = player.Utilities.AlignGroup(shatter.Run.Run:Clone(), player.Character.PrimaryPart.CFrame)
	alignGroup.Parent = thrown
	player.Utilities.Debris(alignGroup, 5)
	local v2 = {
		fxloop2 = task.spawn(function()
			local top = player.Character.Welds:FindFirstChild("Bisento", true):FindFirstChild("Top", true)
			local cFrame = player.Character.PrimaryPart.CFrame

			while alignGroup.Sparks.Parent do
				local raycastResult = workspace:Raycast(
					top.WorldPosition + createVector(0, 2, 0),
					createVector(0, -5, 0),
					Auxiliary.RequestRaycastParams("Map")
				)

				if raycastResult then
					alignGroup.Sparks.CFrame = CFrame.new(raycastResult.Position) * CFrame.Angles(cFrame:ToOrientation())
				else
					alignGroup.Sparks.CFrame = CFrame.new(top.WorldPosition) * CFrame.Angles(cFrame:ToOrientation())
				end

				task.wait()
			end
		end)
	}
	task.wait(0.55)
	player.Utilities.VFXHandle(alignGroup.Sparks, {
		Toggle = "Off"
	})

	for _, v3 in v2 do
		task.cancel(v3)
	end
end

function MowingBlade.stab(player, _)
	player.Utilities = require(script.Parent.Utilities)
	local alignGroup = player.Utilities.AlignGroup(shatter.Run.Stab:Clone(), player.Character.PrimaryPart.CFrame)
	alignGroup.Parent = thrown
	player.Utilities.VFXHandle(alignGroup, {
		Emit = true,
		Debris = 10
	})
	local v2 = {}
	local mesh = alignGroup.mesh
	local beams = alignGroup.beams
	beams.Parent = nil
	mesh.Parent = nil
	task.wait(0.05)
	beams.Parent = alignGroup
	mesh.Parent = alignGroup
	v2.meshthread = task.spawn(function()
		local wind = mesh.wind
		local mesh2 = mesh.mesh
		local tween = player.Utilities.GetTween(mesh2)
		local tween2 = player.Utilities.GetTween(wind)
		tween.play()
		tween2.play()
		player.Utilities.GetTween(mesh.wind2).play()
		tween.tweens.DecalTween.Completed:Connect(function()
			mesh2:Destroy()
		end)
		tween2.tweens.DecalTween.Completed:Connect(function()
			wind:Destroy()
		end)
		TweenService:Create(wind.decal, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
			Transparency = 1
		}):Play()
		TweenService:Create(mesh2.decal, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
			Transparency = 1
		}):Play()
		game.Debris:AddItem(wind, 0.1)
		game.Debris:AddItem(mesh2, 0.1)
	end)
	v2.beamthread = task.spawn(function()
		v2.rootbeam = task.spawn(function()
			for _, beam in alignGroup.PrimaryPart:GetDescendants() do
				if not beam:IsA("Beam") then
					continue
				end

				local attachment0 = beam.Attachment0
				local attachment1 = beam.Attachment1
				TweenService:Create(beam, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
					Width0 = 0,
					Width1 = 0
				}):Play()
				TweenService:Create(attachment1, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
					CFrame = attachment0.CFrame
				}):Play()
				local v3 = beam
				task.delay(0.1, function()
					v3.Enabled = false
				end)
			end
		end)
		v2.beams = task.spawn(function()
			local beams2 = alignGroup.beams
			local tween = TweenService:Create(beams2, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {
				CFrame = beams2.CFrame * CFrame.Angles(0, 0, -2.0943951023931953)
			})
			tween:Play()
			tween.Completed:Once(function()
				TweenService:Create(beams2, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					CFrame = beams2.CFrame * CFrame.Angles(0, 0, -0.4363323129985824)
				}):Play()
			end)

			for _, beam in beams2:GetDescendants() do
				if not beam:IsA("Beam") then
					continue
				end

				local attachment0 = beam.Attachment0
				local attachment1 = beam.Attachment1
				TweenService:Create(beam, TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
					Width0 = 0,
					Width1 = 0
				}):Play()
				TweenService:Create(beam, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					CurveSize0 = 5
				}):Play()
				TweenService:Create(attachment0, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					CFrame = attachment0.CFrame * CFrame.new(3, 0, 0)
				}):Play()
				TweenService:Create(beam, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					TextureSpeed = 0.5
				}):Play()
				TweenService:Create(attachment1, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					CFrame = attachment1.CFrame * CFrame.new(1.5, 0, 15)
				}):Play()
			end
		end)
		v2.ground = task.spawn(function()
			for _, beam in alignGroup.ground:GetDescendants() do
				if not beam:IsA("Beam") then
					continue
				end

				local attachment0 = beam.Attachment0
				local attachment1 = beam.Attachment1
				TweenService:Create(beam, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					TextureSpeed = 0.75
				}):Play()
				TweenService:Create(attachment1, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					CFrame = attachment0.CFrame
				}):Play()
				TweenService:Create(beam, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					Width0 = 0,
					Width1 = 0
				}):Play()
			end
		end)
	end)
end

function MowingBlade.intsma(player, _)
	player.Utilities = require(script.Parent.Utilities)
	local alignGroup = player.Utilities.AlignGroup(shatter.Grab.Intsmash:Clone(), player.Character.PrimaryPart.CFrame)
	alignGroup.Parent = thrown
	player.Utilities.Debris(alignGroup, 5)
	local raycastResult = workspace:Raycast(
		player.Character.PrimaryPart.Position + player.Character.PrimaryPart.CFrame.LookVector * 15,
		createVector(0, -5, 0),
		Auxiliary.RequestRaycastParams("Map")
	)
	local v2 = {
		fxloop2 = task.spawn(function()
			local top = player.Character.Welds:FindFirstChild("Bisento", true).bis.Top

			while alignGroup.Parent do
				alignGroup:PivotTo(CFrame.new(top.WorldPosition, raycastResult.Position + createVector(0, -10, 0)))
				task.wait()
			end
		end)
	}
	local folder = nil
	v2.swing = task.spawn(function()
		task.wait(0.15)
		folder = player.Utilities.AlignGroup(shatter.Grab.wind:Clone(), player.Character.PrimaryPart.CFrame)
		folder.Parent = thrown

		for _, beam in folder:GetDescendants() do
			if not beam:IsA("Beam") then
				continue
			end

			local attachment0 = beam.Attachment0
			local attachment1 = beam.Attachment1
			local v3 = beam
			task.delay(0, function()
				if v3.Name ~= "Beam1" then
					return
				end

				TweenService:Create(v3, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
					CurveSize0 = 0
				}):Play()
				TweenService:Create(attachment0, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
					CFrame = attachment1.CFrame
				}):Play()
			end)
			local v6 = beam
			local attachment = attachment1
			local attachment2 = attachment0
			task.delay(0.1, function()
				if v6.Name ~= "Beam2" then
					v6.Enabled = false
					return
				end

				TweenService:Create(v6, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					CurveSize0 = 0
				}):Play()
				TweenService:Create(
					attachment,
					TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						CFrame = attachment2.CFrame
					}
				):Play()
			end)
		end
	end)
	task.wait(0.45)
	folder:Destroy()
	player.Utilities.VFXHandle(alignGroup, {
		Toggle = "Off"
	})

	for _, v3 in v2 do
		task.cancel(v3)
	end
end

function MowingBlade.spin(player, _)
	player.Utilities = require(script.Parent.Utilities)
	local alignGroup = player.Utilities.AlignGroup(shatter.Grab.Spin:Clone(), player.Character.PrimaryPart.CFrame)
	alignGroup.Parent = thrown
	player.Utilities.VFXHandle(alignGroup, {
		Debris = 3
	})
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
						local tween = TweenService:Create(v2, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
							CFrame = v2.CFrame * CFrame.Angles(0, -2.0943951023931953, 0)
						})
						tween:Play()
						tween.Completed:Wait()
					end
				end)
			end

			for _, v2 in beams do
				TweenService:Create(v2, TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
					Width0 = v2:GetAttribute("wd0"),
					Width1 = v2:GetAttribute("wd1")
				}):Play()
				local v3 = v2
				task.delay(0.12, function()
					TweenService:Create(v3, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
						Width0 = 0,
						Width1 = 0
					}):Play()
				end)
			end
		end)
	end)
	v.meshhread = task.spawn(function()
		for _, child in alignGroup.mesh:GetChildren() do
			local v2 = child
			task.spawn(function()
				task.delay(0.24, function()
					TweenService:Create(v2.Decal, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
						Transparency = 1
					}):Play()
				end)

				for i = 1, 25 do
					local tween = TweenService:Create(v2, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
						CFrame = v2.CFrame * CFrame.Angles(0, -2.0943951023931953, 0)
					})
					tween:Play()
					tween.Completed:Wait()
				end
			end)
		end
	end)
	v.emithread = task.spawn(function()
		for _ = 1, 3 do
			player.Utilities.VFXHandle(alignGroup, {
				Emit = true
			})
			task.wait(0.125)
		end
	end)
end

function MowingBlade.quake(player, _)
	player.Utilities = require(script.Parent.Utilities)
	local leftArm = player.Character["Left Arm"]
	local v2 = player.Utilities.AttachVFX(shatter.Grab.fx.start.Part:GetChildren(), leftArm)
	player.Utilities.VFXHandle(v2, {
		Emit = true,
		Debris = 3
	})
	task.delay(0.25, function()
		local v3 = player.Utilities.AttachVFX(shatter.Grab.fx.idle.Part:GetChildren(), leftArm)
		player.Utilities.VFXHandle(v3, {
			Toggle = "On",
			Debris = 1
		})
	end)
end

function MowingBlade.charge(player, _)
	player.Utilities = require(script.Parent.Utilities)
	local alignGroup = player.Utilities.AlignGroup(
		shatter.Grab.Charging:Clone(),
		player.Character.PrimaryPart.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
	)
	alignGroup.Parent = thrown
	player.Utilities.VFXHandle(alignGroup, {
		Debris = 5
	})
	player.Utilities.VFXHandle(alignGroup, {
		Emit = 1
	})
	local root = alignGroup.root
	local mesh = alignGroup.mesh
	root.Parent = nil
	mesh.Parent = nil
	local beam = alignGroup.beam
	v.start = task.spawn(function()
		local beam3 = beam
		local tween = TweenService:Create(beam3, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {
			CFrame = beam3.CFrame * CFrame.Angles(0, 0, -2.0943951023931953)
		})
		tween:Play()
		tween.Completed:Once(function()
			TweenService:Create(beam3, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				CFrame = beam3.CFrame * CFrame.Angles(0, 0, -2.0943951023931953)
			}):Play()
		end)

		for _, beam2 in beam:GetDescendants() do
			if not beam2:IsA("Beam") then
				continue
			end

			local attachment0 = beam2.Attachment0
			local attachment1 = beam2.Attachment1
			TweenService:Create(
				attachment1,
				TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false),
				{
					CFrame = attachment1.CFrame * CFrame.new(5, -10, -5)
				}
			):Play()
			TweenService:Create(beam2, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {
				Width1 = 0,
				Width0 = 0,
				CurveSize0 = -25,
				CurveSize1 = 0
			}):Play()
			TweenService:Create(
				attachment0,
				TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false),
				{
					CFrame = attachment0.CFrame * CFrame.new(0, 5, -5)
				}
			):Play()
		end
	end)
	v.enga = task.spawn(function()
		task.wait(0.35)
		local mesh2 = mesh
		root.Parent = alignGroup
		mesh2.Parent = alignGroup

		for _, beam2 in root:GetDescendants() do
			if not beam2:IsA("Beam") then
				continue
			end

			local attachment0 = beam2.Attachment0
			local attachment1 = beam2.Attachment1
			local cFrame = attachment1.CFrame
			attachment1.CFrame = attachment0.CFrame * CFrame.new(-10, 0, 15)
			TweenService:Create(
				attachment1,
				TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut),
				{
					CFrame = cFrame
				}
			):Play()
		end

		player.Utilities.GetTween(mesh).play()
		task.wait(0.2)
		local mesh3 = mesh
		root.Parent = nil
		mesh3.Parent = nil
	end)
end

function MowingBlade.quakesmash(player, _)
	player.Utilities = require(script.Parent.Utilities)
	local alignGroup = player.Utilities.AlignGroup(
		shatter.Grab.Quake.glass:Clone(),
		player.Character.PrimaryPart.CFrame * CFrame.new(0, 0, -7) * CFrame.Angles(
			-1.5707963267948966,
			-1.5707963267948966,
			-0
		)
	)
	alignGroup.Parent = thrown
	player.Utilities.VFXHandle(alignGroup, {
		Debris = 5
	})
	local alignGroup2 = player.Utilities.AlignGroup(
		shatter.Grab.Quake.green:Clone(),
		alignGroup:GetPivot() * CFrame.Angles(-1.5707963267948966, -0, -0)
	)
	alignGroup2.Parent = thrown
	player.Utilities.VFXHandle(alignGroup2, {
		Debris = 5
	})
	v.black = task.spawn(function()
		local quake = alignGroup.Quake
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
		}, TweenInfo.new(0.125, Enum.EasingStyle.Sine, Enum.EasingDirection.In), function()
			player.Utilities.TweenFlipbook(alignGroup.Quake, {
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
				quake:Destroy()
			end)
		end)
	end)
	v.green = task.spawn(function()
		local quake2 = alignGroup.Quake2
		local parent = quake2.Parent
		quake2.Parent = nil
		task.wait(0.144)
		local highlight = Instance.new("Highlight", alignGroup.planes)
		highlight.OutlineTransparency = 1
		highlight.FillTransparency = 1
		quake2.Parent = parent
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
		}, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), function()
			player.Utilities.VFXHandle(alignGroup2, {
				Emit = true
			})
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
					player.Utilities.VFXHandle(alignGroup2, {
						Emit = true
					})
				end)
			end)
		end)
	end)
	v.meshthread = task.spawn(function()
		task.delay(0.144, function()
			local mesh2 = alignGroup2.mesh2
			local highlight = Instance.new("Highlight", mesh2)
			highlight.OutlineTransparency = 1
			highlight.FillTransparency = 1
			player.Utilities.GetTween(mesh2).play()
		end)
		task.delay(0, function()
			for _, part in alignGroup.planes:GetChildren() do
				if not part:IsA("BasePart") then
					continue
				end

				game.TweenService:Create(part, TweenInfo.new(0.85, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
					Size = createVector(0, 0, 0)
				}):Play()
				task.wait()
			end
		end)
	end)
	v.bust = task.spawn(function()
		task.delay(0.015, function()
			local folder = player.Utilities.AlignGroup(
				shatter.Grab.Quake.quak2:Clone(),
				player.Character.PrimaryPart.CFrame * CFrame.new(0, 0, -8.5)
			)
			folder.Parent = thrown
			player.Utilities.VFXHandle(folder, {
				Debris = 0.15
			})

			for _, beam in folder:GetDescendants() do
				if not beam:IsA("Beam") then
					continue
				end

				local _ = beam.Attachment0
				local _ = beam.Attachment1
				TweenService:Create(beam, TweenInfo.new(0.15, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {
					Width1 = 0,
					Width0 = 0,
					CurveSize0 = 0,
					CurveSize1 = 0
				}):Play()
			end
		end)
		task.wait(0.144)
		local alignGroup3 = player.Utilities.AlignGroup(
			shatter.Grab.Quake.quak:Clone(),
			player.Character.PrimaryPart.CFrame * CFrame.new(0, 0, -8.5)
		)
		alignGroup3.Parent = thrown
		player.Utilities.VFXHandle(alignGroup3, {
			Emit = true,
			Debris = 5
		})
		local mesh = alignGroup3.mesh
		task.spawn(function()
			v.mesh = task.spawn(function()
				local wind = mesh.Wind
				TweenService:Create(wind, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					CFrame = wind.CFrame * CFrame.Angles(0, -2.0943951023931953, 0) * CFrame.new(0, -15, 0),
					Size = createVector(36.661, 70.004, 38.189)
				}):Play()
				TweenService:Create(wind, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
					Transparency = 1
				}):Play()
			end)
			v.mesh1 = task.spawn(function()
				local mesh2 = mesh.mesh
				TweenService:Create(
					mesh2,
					TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut),
					{
						Position = (mesh2.CFrame * CFrame.new(0, -25, 0)).Position,
						Size = createVector(60.348, 17.5, 60.348)
					}
				):Play()
				TweenService:Create(
					mesh2,
					TweenInfo.new(0.2625, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut),
					{
						Transparency = 0
					}
				):Play()
				task.delay(0.15, mesh2.Destroy, mesh2)
			end)
		end)
		task.spawn(function()
			v.green = task.spawn(function()
				local beams = alignGroup3.beams
				local tween = TweenService:Create(beams, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
					CFrame = beams.CFrame * CFrame.Angles(0, 0, -2.0943951023931953)
				})
				tween:Play()
				tween.Completed:Once(function()
					TweenService:Create(beams, TweenInfo.new(0.65, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
						CFrame = beams.CFrame * CFrame.Angles(0, 0, -0.7853981633974483)
					}):Play()
				end)

				for _, beam in beams:GetDescendants() do
					if beam:IsA("Beam") then
						TweenService:Create(
							beam,
							TweenInfo.new(0.85, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
							{
								Width1 = 0,
								Width0 = 0
							}
						):Play()
					end
				end
			end)
			v.wind = task.spawn(function()
				local primaryPart = alignGroup3.PrimaryPart
				local tween = TweenService:Create(primaryPart, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
					CFrame = primaryPart.CFrame * CFrame.Angles(0, 0, -2.0943951023931953)
				})
				tween:Play()
				tween.Completed:Once(function()
					TweenService:Create(primaryPart, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
						CFrame = primaryPart.CFrame * CFrame.Angles(0, 0, -2.0943951023931953)
					}):Play()
					task.wait(0.3)
					TweenService:Create(
						primaryPart,
						TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
						{
							CFrame = primaryPart.CFrame * CFrame.Angles(0, 0, -2.0943951023931953)
						}
					):Play()
				end)

				for _, beam in primaryPart:GetDescendants() do
					if not beam:IsA("Beam") then
						continue
					end

					local attachment0 = beam.Attachment0
					local attachment1 = beam.Attachment1
					TweenService:Create(
						attachment1,
						TweenInfo.new(0.625, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false),
						{
							CFrame = attachment1.CFrame * CFrame.new(5, -10, -5)
						}
					):Play()
					TweenService:Create(beam, TweenInfo.new(1.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
						Width1 = 0,
						Width0 = 0,
						CurveSize0 = 0,
						CurveSize1 = 0
					}):Play()
					TweenService:Create(
						attachment0,
						TweenInfo.new(0.625, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false),
						{
							CFrame = attachment0.CFrame * CFrame.new(0, 5, -5)
						}
					):Play()
				end
			end)
			v.back = task.spawn(function()
				for _, beam in alignGroup3.se:GetDescendants() do
					if not beam:IsA("Beam") then
						continue
					end

					local _ = beam.Attachment0
					local _ = beam.Attachment1
					TweenService:Create(beam, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
						TextureSpeed = 0.5
					}):Play()
					local v2 = beam
					task.spawn(function()
						player.Utilities.TweenNumberSequence(
							v2.Transparency,
							NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 1) }),
							50,
							1,
							v2,
							"Transparency",
							Enum.EasingStyle.Sine,
							Enum.EasingDirection.Out
						)
					end)
				end
			end)
		end)
	end)
end

function MowingBlade.smash(player, _)
	player.Utilities = require(script.Parent.Utilities)
	player._connections = {}
	local alignGroup = player.Utilities.AlignGroup(
		shatter.Grab.smash:Clone(),
		player.Character.PrimaryPart.CFrame * CFrame.new(0, -3, -3)
	)
	alignGroup.Parent = thrown
	player.Utilities.VFXHandle(alignGroup, {
		Emit = true,
		Debris = 2
	})
	player._connections.beams = task.spawn(function()
		local beams = alignGroup.beams
		local tween = TweenService:Create(beams, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
			CFrame = beams.CFrame * CFrame.Angles(0, -2.0943951023931953, 0)
		})
		tween:Play()
		tween.Completed:Once(function()
			TweenService:Create(beams, TweenInfo.new(0.65, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				CFrame = beams.CFrame * CFrame.Angles(0, -2.0943951023931953, 0)
			}):Play()
		end)

		for _, beam in beams:GetDescendants() do
			if not beam:IsA("Beam") then
				continue
			end

			local _ = beam.Attachment0
			local attachment1 = beam.Attachment1
			TweenService:Create(
				attachment1,
				TweenInfo.new(0.375, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false),
				{
					CFrame = attachment1.CFrame * CFrame.new(0, -15, -10)
				}
			):Play()
			TweenService:Create(beam, TweenInfo.new(0.75, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {
				Width0 = 0,
				CurveSize0 = -25,
				CurveSize1 = 0
			}):Play()
			local v2 = beam
			task.spawn(function()
				player.Utilities.TweenNumberSequence(
					v2.Transparency,
					NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 1) }),
					50,
					0.5625,
					v2,
					"Transparency",
					Enum.EasingStyle.Sine,
					Enum.EasingDirection.Out
				)
			end)
		end
	end)
	player._connections.mesh = task.spawn(function()
		local mesh = alignGroup.mesh
		local mesh1 = mesh.mesh1
		player.Utilities.GetTween(mesh1).play()
		local mesh2 = mesh.mesh
		player.Utilities.GetTween(mesh2).play()
	end)
	alignGroup.Destroying:Connect(function()
		for _, _connection in player._connections do
			task.cancel(_connection)
		end
	end)
end

function MowingBlade.destroy(instance, _)
	instance:Destroy()

	for _, v2 in v do
		task.cancel(v2)
	end
end

return MowingBlade