local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local TweenService = game:GetService("TweenService")
return function(instance, p: string, cFrame, flag: boolean?)
	if instance == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil or p ~= "Cancel" and vector.magnitude(humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position) > 200 then
		return
	end

	local v = string.format("%s %s", instance.Name, script.Name)

	if p == "ZigZag" or p == "Cancel" then
		local formatted = `{v}-ZigZag`
		local child = workspace.Debree:FindFirstChild(formatted)

		if child ~= nil then
			child.Name = "--"
			local reaperClone = child:FindFirstChild("ReaperClone")

			if reaperClone ~= nil then
				vfxUtility.EnableAll(reaperClone, false)

				for _, descendant in ipairs(reaperClone:GetDescendants()) do
					if descendant:IsA("BasePart") or descendant:IsA("Decal") then
						descendant.Transparency = 1
					elseif descendant.ClassName == "Highlight" then
						descendant.FillTransparency = 1
					end
				end
			end

			DebrisModule:AddItem(child, 2)
		end
	end

	if p == "Start" then
		local clone = script.SkillAssets.BlitzEnd:Clone()
		clone.Parent = workspace.Debree
		clone:PivotTo(humanoidRootPart.CFrame)
		local weld = Instance.new("Weld", clone.HumanoidRootPart)
		weld.Part0 = humanoidRootPart
		weld.Part1 = clone.HumanoidRootPart
		vfxUtility.EnableAll(clone, true, vfxUtility.Owned(instance))
		task.delay(0.2, function()
			vfxUtility.EnableAll(clone, false)
			vfxUtility.EmitAll(clone, vfxUtility.Owned(instance))
			weld:Destroy()
			clone.HumanoidRootPart.Anchored = true
		end)
		DebrisModule:AddItem(clone, 4)
		local clone2 = script.Sounds.PS2reaperBLITZinitiate:Clone()
		clone2.Parent = clone.HumanoidRootPart
		clone2:Play()
		Cam_Shaker(humanoidRootPart.Position, "activate_shake")
	elseif p == "Jump" then
		local clone = script.SkillAssets.Dash:Clone()
		clone.Parent = workspace.Debree
		clone:PivotTo(cFrame)
		local clone2 = script.Sounds.PS2reaperBLITZdash:Clone()
		clone2.Parent = clone.HumanoidRootPart
		clone2:Play()
		vfxUtility.EmitAll(clone, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone, 4)
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.15,
			Amplitude = 0.5,
			SustainTime = 0,
			FadeOutTime = 1,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(1, 1, 1)
		})
	elseif p == "hit" then
		local clone = script.SkillAssets.Hit1:Clone()
		clone.CFrame = cFrame
		vfxUtility.EmitAll(clone, vfxUtility.Owned(instance))
		clone.Parent = workspace.Debree
		DebrisModule:AddItem(clone, 2)
		local clone2 = flag and script.Sounds.PS2reaperBLITZhitfinal:Clone() or script.Sounds.PS2reaperBLITZhit:Clone()
		clone2.Parent = clone
		clone2:Play()
	elseif p == "ZigZag" then
		local configuration = Instance.new("Configuration", workspace.Debree)
		configuration.Name = `{v}-ZigZag`
		DebrisModule:AddItem(configuration, 10)
		local clone = script.SkillAssets.ReaperClone:Clone()
		clone.Parent = configuration
		clone:PivotTo(humanoidRootPart.CFrame * CFrame.Angles(0, 1.5707963267948966, 0))
		local track = clone.AnimationController.Animator:LoadAnimation(game.ReplicatedStorage.Skills.Reaper.Sonido.Sonido["Sonido-Loop"])
		track:Play()
		vfxUtility.EnableAll(clone, true, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone, 3.1)
		local weld = Instance.new("Weld")
		weld.Part0 = humanoidRootPart
		weld.Part1 = clone.PrimaryPart
		weld.Parent = clone.PrimaryPart
		weld.C1 = CFrame.Angles(0, 1.5707963267948966, 0)
		local clone2 = script.SkillAssets.Randomness:Clone()
		clone2.Parent = configuration
		clone2:PivotTo(humanoidRootPart.CFrame)
		vfxUtility.EnableAll(clone2, true, vfxUtility.Owned(instance))
		local weld2 = Instance.new("Weld")
		weld2.Part0 = humanoidRootPart
		weld2.Part1 = clone2.PrimaryPart
		weld2.Parent = clone2.PrimaryPart
		local clone3 = script.Sounds.PS2reaperBLITZloop:Clone()
		clone3.Parent = humanoidRootPart
		clone3:Play()
		local cam_Shaker = Cam_Shaker(humanoidRootPart, {
			FadeInTime = 0.2,
			Frequency = 0.25,
			Amplitude = 0.15,
			SustainTime = 5,
			FadeOutTime = 0.1,
			RotationInfluence = createVector(0.15, 0.15, 0.15),
			PositionInfluence = createVector(0.5, 0.5, 0.5)
		})

		while configuration ~= nil and configuration.Parent ~= nil and configuration.Name ~= "--" do
			task.wait(0.1)
		end

		cam_Shaker:Destroy()
		TweenService:Create(clone3, TweenInfo.new(0.5), {
			Volume = 1
		}):Play()
		DebrisModule:AddItem(clone3, 0.5)

		if humanoidRootPart == nil or humanoidRootPart.Parent == nil or (configuration == nil or configuration.Parent == nil) then
			return
		end

		vfxUtility.EnableAll(clone2, false)
		local clone4 = script.SkillAssets.BlitzEnd:Clone()
		clone4.Parent = configuration
		clone4:PivotTo(humanoidRootPart.CFrame)
		vfxUtility.EnableAll(clone4, true, vfxUtility.Owned(instance))
		local clone5 = script.Sounds.PS2reaperBLITZreappear:Clone()
		clone5.Parent = clone4.HumanoidRootPart
		clone5:Play()
		Cam_Shaker(humanoidRootPart.Position, "activate_shake")
		task.delay(0.2, function()
			vfxUtility.EnableAll(clone4, false)
			local raycastResult = workspace:Raycast(
				humanoidRootPart.Position + createVector(0, 5, 0),
				createVector(-0, -20, -0),
				RaycastHelper.Crater
			)

			if raycastResult then
				vfxUtility.EmitAll(clone4, vfxUtility.Owned(instance, {
					Color = raycastResult.Instance.Color,
					ColorWhitelist = { "DustRaycast", "dustraycast" }
				}))
			else
				vfxUtility.EmitAll(clone4, vfxUtility.Owned(instance))
			end
		end)
		DebrisModule:AddItem(clone4, 4)
		track:Stop()
	end
end