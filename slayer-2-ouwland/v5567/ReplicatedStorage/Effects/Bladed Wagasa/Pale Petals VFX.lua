local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CAM = ReplicatedStorage.CAM
local assets = script:FindFirstChild("Assets")
local sounds = script:FindFirstChild("Sounds")
local DebrisModule = require(CAM.DebrisModule)
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local Ouwmit = require(CAM.Client.Modules.Effects.Ouwmit)
local Cam_Shaker = require(CAM.Client.Modules.Effects.Cam_Shaker)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local Config = require(ReplicatedStorage.Skills["Bladed Wagasa"]["Pale Petals"].Config)
local UMBWEP2_F45 = Config.UMBWEP2_F45
local UMBWEP2_F55 = Config.UMBWEP2_F55
local cframe = CFrame.fromMatrix(
	createVector(0, 0, 0),
	createVector(0, -0.9999, 0.0011),
	createVector(0, 0.0011, 0.9999)
)
local v = CFrame.new(0.012, 11.291, -0.092) * UMBWEP2_F55.Rotation * cframe

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyFolder(p)
	local child = workspace.Debree:FindFirstChild((`{p.Name}-PalePetalsVFX`))

	if child and child.Parent then
		Ouwmit.Enable(child, false)
		child.Name = "--"
		DebrisModule:AddItem(child, 1.3)
	end
end

local function createFolder(p)
	destroyFolder(p) -- equivalent call inferred; original call site unknown
	local configuration = Instance.new("Configuration")
	configuration.Name = `{p.Name}-PalePetalsVFX`
	configuration.Parent = workspace.Debree
	DebrisModule:AddItem(configuration, 7)
	return configuration
end

-- equivalent calls inferred from this helper; original call sites unknown
local function findFloat(instance)
	local child = workspace.Debree:FindFirstChild((`{instance.Name}-PalePetalsVFX`))
	return child and child:QueryDescendants("Model#FloatUmbrella")[1]
end

return function(instance, p: string, childName, part, aimTarget)
	if instance == nil then
		return
	end

	if p == "Cancel" then
		local float = findFloat(instance) -- equivalent call inferred; original call site unknown

		if float then
			vfxUtility.PlaySound(sounds, "PS2bladedwagasaPALEPETALSreturn", instance.PrimaryPart or instance, true)
			float:Destroy()
		end

		destroyFolder(instance) -- equivalent call inferred; original call site unknown
	else
		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

		if humanoidRootPart == nil then
			return
		end

		if p == "Attempt" then
			local cFrame = humanoidRootPart.CFrame
			local raycastResult = workspace:Raycast(
				cFrame.Position + createVector(0, 5, 0),
				createVector(-0, -15, -0),
				RaycastHelper.Crater
			)
			local v2 = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
			Ouwmit.Emit(
				vfxUtility.cloneAsset(assets, workspace.Debree, "Attempt", cFrame, 3),
				Ouwmit.Owned(instance, v2)
			)
			vfxUtility.PlaySound(sounds, "PS2bladedwagasaPALEPETALSattempt", humanoidRootPart, true)
			Cam_Shaker(cFrame.Position, {
				FadeInTime = 0,
				Frequency = 0.25,
				Amplitude = 0.4,
				SustainTime = 0.1,
				FadeOutTime = 0.3,
				RotationInfluence = createVector(0.25, 0.25, 0.25),
				PositionInfluence = createVector(1, 1, 1)
			})
		elseif p == "Start" then
			destroyFolder(instance) -- equivalent call inferred; original call site unknown
			local configuration = Instance.new("Configuration")
			configuration.Name = `{instance.Name}-PalePetalsVFX`
			configuration.Parent = workspace.Debree
			DebrisModule:AddItem(configuration, 7)
			local cFrame = humanoidRootPart.CFrame
			local v2

			if assets then
				v2 = vfxUtility.cloneAsset(assets, configuration, "UmbrellaFloat", cFrame * v, 7)
			else
				v2 = nil
			end

			if v2 then
				Ouwmit.Enable(v2, true, Ouwmit.Owned(instance))
			end

			local v3 = instance:QueryDescendants("Model#Umbrella")[1]

			if v3 then
				local clone = v3:Clone()
				clone.Name = "FloatUmbrella"
				local primaryPart = clone.PrimaryPart or clone:QueryDescendants("BasePart")[1]

				for _, part2 in clone:QueryDescendants("BasePart") do
					part2.Anchored = true
					part2.CanCollide = false
					part2.CanQuery = false

					if part2:IsA("MeshPart") then
						part2.Transparency = 0
					end
				end

				for _, v4 in clone:QueryDescendants("ParticleEmitter") do
					local setTransparency = v4:GetAttribute("SetTransparency")

					if setTransparency == nil then
						continue
					end

					v4.Enabled = setTransparency
					v4:SetAttribute("SetTransparency", nil)
				end

				if primaryPart then
					clone:PivotTo(cFrame * UMBWEP2_F45)
				end

				clone.Parent = configuration
				vfxUtility.PlaySound(sounds, "PS2bladedwagasaPALEPETALSrise", primaryPart or humanoidRootPart, true)
				task.spawn(function()
					local cframe2 = cFrame * UMBWEP2_F55
					local objectSpace = cframe2:ToObjectSpace(cFrame * v)
					local v4 = cframe2
					local total = 0
					local v5 = nil
					local total2 = 0

					while primaryPart and clone.Parent do
						local v6 = RunService.Heartbeat:Wait()
						total += v6

						if total < 0.16666666666666666 then
							local v7 = total / 0.16666666666666666
							clone:PivotTo(cFrame * UMBWEP2_F45:Lerp(UMBWEP2_F55, 1 - (1 - v7) * (1 - v7)))
						else
							if v5 == nil then
								v5 = vfxUtility.PlaySound(
									sounds,
									"PS2bladedwagasaPALEPETALSshootloop",
									primaryPart,
									false
								)
							end

							local aimTarget2 = clone:GetAttribute("AimTarget")
							local v7

							if aimTarget2 then
								v7 = CFrame.lookAt(cframe2.Position, aimTarget2)
							else
								v7 = cframe2
							end

							v4 = v4:Lerp(v7, (math.min(v6 * 10, 1)))
							total2 += v6 * -6
							clone:PivotTo(v4 * CFrame.Angles(0, 0, total2))

							if v2 then
								v2:PivotTo(v4 * objectSpace)
							end
						end
					end

					if v5 and v5.Parent then
						v5:Stop()
						v5:Destroy()
					end
				end)
			end

			if assets then
				Ouwmit.Emit(
					vfxUtility.cloneAsset(assets, configuration, "Impact", part or cFrame, 4),
					Ouwmit.Owned(instance)
				)
			end

			Cam_Shaker(cFrame.Position, "activate_shake")
		elseif p == "Fire" then
			if assets == nil then
				return
			end

			if typeof(part) ~= "Instance" then
				part = nil
			end

			if not (part and part:IsA("BasePart")) then
				part = (workspace.Debree:FindFirstChild("Projectiles") or workspace.Debree):WaitForChild(childName, 0.5)
			end

			if not (part and part:IsA("BasePart")) then
				return
			end

			local projectile = assets:FindFirstChild("Projectile")

			if projectile == nil then
				return
			end

			local clone = projectile:Clone()
			clone:PivotTo(part.CFrame * CFrame.Angles(0, 1.5707963267948966, 0))
			clone.Parent = part

			for _, v2 in clone:QueryDescendants("BasePart") do
				v2.Anchored = false
				vfxUtility.WeldConstraint(part, v2)
			end

			if clone:IsA("BasePart") then
				clone.Anchored = false
				vfxUtility.WeldConstraint(part, clone)
			end

			Ouwmit.Enable(clone, true, Ouwmit.Owned(instance))
			Cam_Shaker(humanoidRootPart.Position, "punch_shake")
			part.AncestryChanged:Connect(function(_, parent)
				if parent == nil then
					clone:Destroy()
				end
			end)

			if aimTarget then
				local float = findFloat(instance) -- equivalent call inferred; original call site unknown

				if float then
					float:SetAttribute("AimTarget", aimTarget)
				end
			end
		end
	end
end