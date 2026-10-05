local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
require(ReplicatedStorage.CAM.Client.Modules.Effects.Token.TokenKit)
require(ReplicatedStorage.CAM.Client.Modules.Effects.Craters.OuwCraters)
require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local ImpactFrames = require(ReplicatedStorage.CAM.Client.Modules.Effects.ImpactFrames)
return function(instance, p: string, instance2, list)
	if instance == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil or p ~= "Cancel" and (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > 250 then
		return
	end

	local name = string.format("%s %s", instance.Name, script.Name)

	if p == "Start" then
		local configuration = Instance.new("Configuration")
		configuration.Name = name
		configuration.Parent = workspace.Debree
		DebrisModule:AddItem(configuration, 5)
		local emitLRHRP = humanoidRootPart:FindFirstChild("EmitLRHRP")

		if emitLRHRP then
			emitLRHRP:Destroy()
		end

		local clone = script.SkillAssets.sUPEERDash:Clone()
		clone:PivotTo(humanoidRootPart.CFrame)
		clone.Parent = configuration
		local clone2 = script.Sounds.PS2reaperULTlaunch1:Clone()
		clone2.Parent = humanoidRootPart
		clone2:Play()
		DebrisModule:AddItem(clone2, clone2.TimeLength)
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.2,
			SustainTime = 0.2,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.2, 0.2, 0.2),
			PositionInfluence = createVector(2.5, 2.5, 2.5)
		})
		local raycastResult = workspace:Raycast(
			clone.PrimaryPart.Position + createVector(0, 5, 0),
			createVector(-0, -20, -0),
			RaycastHelper.Crater
		)
		local color

		if raycastResult and raycastResult.Instance ~= nil then
			color = raycastResult.Instance.Color
		end

		vfxUtility.EmitAll(clone, vfxUtility.Owned(instance, color ~= nil and ({
			Color = color,
			ColorWhitelist = { "DustRaycast", "dustraycast" }
		} or nil) or nil))
		task.wait(0.1)

		if humanoidRootPart == nil or humanoidRootPart.Parent == nil or configuration == nil or configuration.Parent == nil then
			return
		end

		local v2 = tonumber(instance2) or 0.6
		local clone3 = script.SkillAssets.EmitLRHRP:Clone()
		clone3.Parent = humanoidRootPart
		DebrisModule:AddItem(clone3, v2 + 0.6)
		vfxUtility.EnableAll(clone3, true, vfxUtility.Owned(instance, color ~= nil and ({
			Color = color,
			ColorWhitelist = { "DustRaycast", "dustraycast" }
		} or nil) or nil))
		local lastTime = os.clock()

		while os.clock() - lastTime < v2 and configuration ~= nil and configuration.Parent ~= nil do
			task.wait(0.05)
		end

		if clone3 == nil or clone3.Parent == nil then
			return
		end

		vfxUtility.EnableAll(clone3, false)
		TweenService:Create(clone3.HandTrail.PointLight, TweenInfo.new(0.3), {
			Brightness = 0,
			Range = 0
		}):Play()
	elseif p == "StartAttack" then
		local configuration = Instance.new("Configuration", workspace.Debree)
		configuration.Name = `{instance.Name}-{script.Name}-{"StartAttack"}`
		DebrisModule:AddItem(configuration, 3)
		local emitLRHRP = humanoidRootPart:FindFirstChild("EmitLRHRP")

		if emitLRHRP then
			vfxUtility.EnableAll(emitLRHRP, false)
			DebrisModule:AddItem(emitLRHRP, 2)
		end

		local clone = script.SkillAssets.InitialKickHit:Clone()
		clone:PivotTo(humanoidRootPart.CFrame)
		clone.Parent = configuration
		local raycastResult = workspace:Raycast(
			clone.PrimaryPart.Position + createVector(0, 5, 0),
			createVector(-0, -20, -0),
			RaycastHelper.Crater
		)

		if raycastResult then
			vfxUtility.EmitAll(clone, vfxUtility.Owned(instance, {
				Color = raycastResult.Instance.Color,
				ColorWhitelist = { "DustRaycast", "dustraycast" }
			}))
		else
			vfxUtility.EmitAll(clone, vfxUtility.Owned(instance))
		end

		local clone2 = script.Sounds.PS2reaperULTlaunch2:Clone()
		clone2.Parent = clone.HumanoidRootPart
		clone2:Play()
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.2,
			SustainTime = 0.2,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.2, 0.2, 0.2),
			PositionInfluence = createVector(2.5, 2.5, 2.5)
		})
	elseif p == "DashHit" then
		local child = workspace.Debree:FindFirstChild((`{instance.Name}-DashHit`))

		if child ~= nil then
			child:Destroy()
		end

		local child2 = workspace.Debree:FindFirstChild(name)

		if child2 ~= nil then
			child2:Destroy()
		end

		local configuration = Instance.new("Configuration", workspace.Debree)
		configuration.Name = `{instance.Name}-DashHit`
		DebrisModule:AddItem(configuration, 4.5)
		local raycastResult = workspace:Raycast(
			humanoidRootPart.Position + createVector(0, 5, 0),
			createVector(-0, -20, -0),
			RaycastHelper.Crater
		)
		local color

		if raycastResult and raycastResult.Instance ~= nil then
			color = raycastResult.Instance.Color
		else
			color = nil
		end

		task.delay(0.16666666666666666, function()
			if humanoidRootPart == nil or humanoidRootPart.Parent == nil or configuration == nil or configuration.Parent == nil then
				return
			end

			local clone = script.SkillAssets.BlitzEnd:Clone()
			clone.Parent = configuration
			clone:PivotTo(humanoidRootPart.CFrame)
			vfxUtility.EnableAll(clone, true, vfxUtility.Owned(instance, color ~= nil and ({
				Color = color,
				ColorWhitelist = { "DustRaycast", "dustraycast" }
			} or nil) or nil))
			task.delay(0.5, function()
				if clone == nil then
					return
				end

				vfxUtility.EnableAll(clone, false)
			end)
		end)
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.2,
			SustainTime = 0.2,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.2, 0.2, 0.2),
			PositionInfluence = createVector(2.5, 2.5, 2.5)
		})
		task.wait(1.1)

		if humanoidRootPart == nil or humanoidRootPart.Parent == nil or configuration == nil or configuration.Parent == nil then
			return
		end

		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.2,
			SustainTime = 0.2,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.2, 0.2, 0.2),
			PositionInfluence = createVector(2.5, 2.5, 2.5)
		})
		local clone = script.SkillAssets.Dash:Clone()
		clone:PivotTo(humanoidRootPart.CFrame)
		clone.Parent = configuration
		vfxUtility.EmitAll(clone, vfxUtility.Owned(instance, color ~= nil and ({
			Color = color,
			ColorWhitelist = { "DustRaycast", "dustraycast" }
		} or nil) or nil))
		task.wait(0.725)

		if humanoidRootPart == nil or humanoidRootPart.Parent == nil or configuration == nil or configuration.Parent == nil then
			return
		end

		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.2,
			SustainTime = 0.2,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.2, 0.2, 0.2),
			PositionInfluence = createVector(2.5, 2.5, 2.5)
		})
		local clone2 = script.SkillAssets.Kick:Clone()
		clone2:PivotTo(humanoidRootPart.CFrame)
		clone2.Parent = configuration
		local clone3 = script.Sounds.PS2reaperULThit:Clone()
		clone3.Parent = clone2.HumanoidRootPart
		clone3:Play()
		DebrisModule:AddItem(clone3, clone3.TimeLength)
		vfxUtility.EmitAll(clone2, vfxUtility.Owned(instance, color ~= nil and ({
			Color = color,
			ColorWhitelist = { "DustRaycast", "dustraycast" }
		} or nil) or nil))
		TweenService:Create(clone2.Slash, TweenInfo.new(0.3), {
			CFrame = clone2.Slash.CFrame * CFrame.Angles(-2.0943951023931953, 0, 0)
		}):Play()
		TweenService:Create(clone2.MaceHit.lightattach.PointLight, TweenInfo.new(0.3), {
			Brightness = 0,
			Range = 0
		}):Play()
		task.delay(0.15, function()
			for _, beam in clone2.Slash:GetDescendants() do
				if not beam:IsA("Beam") then
					continue
				end

				TweenService:Create(beam, TweenInfo.new(0.1), {
					TextureLength = 0
				}):Play()
				local v2 = beam
				task.delay(0.05, function()
					TweenService:Create(v2, TweenInfo.new(0.1), {
						Width0 = 0,
						Width1 = 0
					}):Play()
				end)
			end
		end)
	elseif p == "StartCinema" then
		local child = workspace.Debree:FindFirstChild(name)

		if child ~= nil then
			child:Destroy()
		end

		local configuration = Instance.new("Configuration", workspace.Debree)
		configuration.Name = "Cutscene"
		DebrisModule:AddItem(configuration, 8)

		if instance2 == nil then
			return
		end

		local upperTorso = instance2:FindFirstChild("UpperTorso")

		if upperTorso == nil then
			return
		end

		local clone = script.Sounds.PS2reaperULTcinematic:Clone()
		clone.Parent = humanoidRootPart
		clone:Play()
		DebrisModule:AddItem(clone, clone.TimeLength)
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.2,
			SustainTime = 0.2,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.2, 0.2, 0.2),
			PositionInfluence = createVector(2.5, 2.5, 2.5)
		})
		local clone2 = script.SkillAssets.DustTrail:Clone()
		clone2.Parent = upperTorso
		DebrisModule:AddItem(clone2, 3)
		local raycastResult = workspace:Raycast(
			humanoidRootPart.Position + createVector(0, 5, 0),
			createVector(-0, -20, -0),
			RaycastHelper.Crater
		)
		local color

		if raycastResult and raycastResult.Instance ~= nil then
			color = raycastResult.Instance.Color
		else
			color = nil
		end

		vfxUtility.EnableAll(clone2, true, vfxUtility.Owned(instance, color ~= nil and ({
			Color = color,
			ColorWhitelist = { "DustRaycast", "dustraycast" }
		} or nil) or nil))
		local v2 = false
		local clone3 = nil
		local clone4 = nil
		task.delay(0.8, function()
			if clone2 == nil or clone2.Parent == nil then
				return
			end

			vfxUtility.EnableAll(clone2, false)
		end)
		task.delay(1, function()
			if v2 == true then
				return
			end

			if instance2 == nil or instance2.Parent == nil or upperTorso == nil or upperTorso.Parent == nil or configuration == nil or configuration.Parent == nil then
				return
			end

			clone3 = script.SkillAssets.ReaperClone:Clone()
			clone3.Parent = configuration
			clone3:PivotTo(humanoidRootPart.CFrame * CFrame.new(4, 0, -30))
			clone3.AnimationController.Animator:LoadAnimation(game.ReplicatedStorage.Skills.Reaper.Sonido.Sonido["Sonido-Loop"]):Play()
			vfxUtility.EnableAll(clone3, true, vfxUtility.Owned(instance))
			clone4 = script.SkillAssets.ReaperClone12:Clone()
			clone4.Parent = configuration
			clone4:PivotTo(clone3.PrimaryPart.CFrame * CFrame.Angles(0, 1.5707963267948966, 0))
			clone4.AnimationController.Animator:LoadAnimation(game.ReplicatedStorage.Skills.Reaper.Sonido.Sonido["Sonido-Loop"]):Play()
		end)
		task.spawn(function()
			for _ = 1, 4 do
				if instance2 == nil or instance2.Parent == nil or upperTorso == nil or upperTorso.Parent == nil or configuration == nil or configuration.Parent == nil then
					break
				end

				Cam_Shaker(humanoidRootPart.Position, {
					FadeInTime = 0,
					Frequency = 0.1,
					Amplitude = 0.2,
					SustainTime = 0.2,
					FadeOutTime = 0.2,
					RotationInfluence = createVector(0.2, 0.2, 0.2),
					PositionInfluence = createVector(2.5, 2.5, 2.5)
				})
				task.wait(0.15)
			end
		end)
		task.delay(3.75, function()
			if instance2 == nil or instance2.Parent == nil or upperTorso == nil or upperTorso.Parent == nil or configuration == nil or configuration.Parent == nil then
				return
			end

			v2 = true
			local v3 = { clone3, clone4 }

			for _, folder in ipairs(v3) do
				for _, part in ipairs(folder:GetDescendants()) do
					if part:IsA("BasePart") then
						part.Transparency = 1
					elseif part.ClassName == "Highlight" then
						part.FillTransparency = 1
					end
				end

				vfxUtility.EnableAll(folder, false)
			end

			task.spawn(function()
				if game.Players.LocalPlayer.Character == instance or table.find(
					list,
					game.Players.LocalPlayer.Character
				) then
					ImpactFrames.PlaySet({
						FrameRate = 0.022222222222222223,
						FramesSetName = "Reaper1"
					})
				end
			end)
			local clone5 = script.SkillAssets.EndingInitial:Clone()
			clone5:PivotTo(humanoidRootPart.CFrame)
			clone5.Parent = configuration
			vfxUtility.EmitAll(clone5, vfxUtility.Owned(instance, color ~= nil and ({
				Color = color,
				ColorWhitelist = { "DustRaycast", "dustraycast" }
			} or nil) or nil))
			local clone6 = script.SkillAssets.EndingLoop:Clone()
			clone6:PivotTo(humanoidRootPart.CFrame)
			clone6.Parent = configuration
			vfxUtility.EnableAll(clone6, true, vfxUtility.Owned(instance))
			task.wait(1)
			vfxUtility.EnableAll(clone6, false)
			task.spawn(function()
				if game.Players.LocalPlayer.Character == instance or table.find(
					list,
					game.Players.LocalPlayer.Character
				) then
					ImpactFrames.PlaySet({
						FrameRate = 0.022222222222222223,
						FramesSetName = "Reaper2"
					})
				end
			end)
			local clone7 = script.SkillAssets.EndingFinish:Clone()
			clone7:PivotTo(humanoidRootPart.CFrame)
			clone7.Parent = configuration
			TweenService:Create(clone7.MaceHit.lightattach.PointLight, TweenInfo.new(0.3), {
				Brightness = 0,
				Range = 0
			}):Play()
			vfxUtility.EmitAll(clone7, vfxUtility.Owned(instance, color ~= nil and ({
				Color = color,
				ColorWhitelist = { "DustRaycast", "dustraycast" }
			} or nil) or nil))
			Cam_Shaker(humanoidRootPart.Position, {
				FadeInTime = 0,
				Frequency = 0.1,
				Amplitude = 0.2,
				SustainTime = 0.2,
				FadeOutTime = 0.2,
				RotationInfluence = createVector(0.2, 0.2, 0.2),
				PositionInfluence = createVector(2.5, 2.5, 2.5)
			})
		end)
	elseif p == "Cancel" then
		local child = workspace.Debree:FindFirstChild(name)

		if child ~= nil then
			child:Destroy()
		end

		local child2 = workspace.Debree:FindFirstChild((`{instance.Name}-DashHit`))

		if child2 ~= nil then
			child2:Destroy()
		end
	end
end