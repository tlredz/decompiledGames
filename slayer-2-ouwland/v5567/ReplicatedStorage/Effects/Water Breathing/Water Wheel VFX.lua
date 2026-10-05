local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local ParticleBudget = require(ReplicatedStorage.CAM.Client.Modules.Effects.ParticleBudget)
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local Config = require(ReplicatedStorage.Skills["Water Breathing"]["Water Wheel"].Config)

local function SwordTrail(parent, flag: boolean)
	local has_Blade = parent:FindFirstChild("Has_Blade", true)
	local blade

	if not (has_Blade == nil or has_Blade.Parent == nil) then
		blade = has_Blade.Parent:FindFirstChild("Blade")
	end

	if blade == nil then
		return
	end

	if flag == true or flag == nil then
		local clones = {}

		for _, child in pairs(script.Parent.SwordTrail:GetChildren()) do
			local clone = child:Clone()
			clone.Name = "bladetfftians##asd"
			clone.Enabled = not ParticleBudget.Muted(parent, clone)
			ParticleBudget.Rate(clone, parent)
			clone.Parent = blade
			table.insert(clones, clone)

			if not clone:IsA("Trail") then
				continue
			end

			clone.Attachment0 = blade:FindFirstChild("Sword_At_A")
			clone.Attachment1 = blade:FindFirstChild("Sword_At_B")
		end

		if clones ~= nil and clones[1] ~= nil then
			task.delay(5, function()
				if clones[1].Name ~= "--" then
					for _, v in ipairs(clones) do
						v:Destroy()
					end
				end
			end)
		end
	else
		local children = {}

		for _, child in pairs(blade:GetChildren()) do
			if child.Name ~= "bladetfftians##asd" then
				continue
			end

			child.Name = "--"
			child.Enabled = false
			table.insert(children, child)
		end

		if #children > 0 then
			task.delay(1.35, function()
				for _, v in ipairs(children) do
					v:Destroy()
				end
			end)
		end
	end
end

local TweenService = game:GetService("TweenService")
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)

function CreateSlash(instance, parent, childName: string, _, p)
	local rootPart = instance.Humanoid.RootPart
	local cFrame = rootPart.CFrame
	local clone = script.Assets:FindFirstChild(childName):Clone()
	clone:PivotTo(cFrame)
	clone.Parent = parent
	DebrisModule:AddItem(clone, 1)
	Cam_Shaker(cFrame.Position, "activate_shake")
	local color = nil
	local raycastResult = workspace:Raycast(cFrame.Position, cFrame.UpVector * -15, RaycastHelper.Crater)

	if raycastResult == nil or raycastResult.Instance == nil then
		clone[childName].Ground:Destroy()
	else
		color = raycastResult.Instance.Color
		clone[childName].Ground.WorldCFrame = CFrame.new(
			raycastResult.Position,
			raycastResult.Position + raycastResult.Normal
		) * CFrame.Angles(-1.5707963267948966, 0, 0)
	end

	vfxUtility.EmitAll(clone, vfxUtility.Owned(instance, color ~= nil and ({
		Color = color,
		ColorWhitelist = "Ground"
	} or nil) or nil))
	local serializedMeshAnim = clone.SlashBeams.SerializedMeshAnim
	TweenService:Create(serializedMeshAnim, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
		CFrame = serializedMeshAnim.CFrame * serializedMeshAnim:GetAttribute("CFrameDiff")
	}):Play()

	for _, beam in pairs(clone:GetDescendants()) do
		if not beam:IsA("Beam") then
			continue
		end

		beam.Enabled = true
		TweenService:Create(beam, TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			TextureLength = 0.1,
			Width0 = 0,
			Width1 = 0
		}):Play()
	end

	Cam_Shaker(rootPart, "punch_shake")

	if p then
		vfxUtility.PlaySound(script.Sounds, "PS2WBwaterwheelHOLDslash" .. p, rootPart, true)
	end
end

local OuwCraters = require(ReplicatedStorage.CAM.Client.Modules.Effects.Craters.OuwCraters)
local CraterHandler = require(ReplicatedStorage.CAM.Client.Modules.Effects.Craters.CraterHandler)

function ClearWheel(childName)
	local child = workspace.Debree:FindFirstChild(childName)

	if child ~= nil then
		child.Name = "--"
		vfxUtility.EnableAll(child, false)
		DebrisModule:AddItem(child, 1.5)
	end
end

return function(parent, p: string, ...)
	if parent:FindFirstChild("Humanoid") == nil or parent:FindFirstChild("HumanoidRootPart") == nil then
		return
	end

	local humanoidRootPart = parent.HumanoidRootPart
	local formatted = `{script.Name}-{parent.Name}-WaterWheelWheel`

	if vector.magnitude(workspace.CurrentCamera.CFrame.Position - parent.HumanoidRootPart.Position) > 250 and p ~= "Cancel" then
		return
	end

	if p == "Startup" then
		local clone = script.Assets.Startup:Clone()
		clone.Parent = workspace.Debree
		clone.CFrame = humanoidRootPart.CFrame
		vfxUtility.EmitAll(clone:GetDescendants(), vfxUtility.Owned(parent))
		DebrisModule:AddItem(clone, 2)
		vfxUtility.PlaySound(script.Sounds, "PS2WBwaterwheelSTART", humanoidRootPart, true)
		local clone2 = script.Assets.StartHighlight:Clone()
		clone2.Parent = parent
		TweenService:Create(clone2, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			OutlineTransparency = 1,
			FillTransparency = 1
		}):Play()
		DebrisModule:AddItem(clone2, 2)
		SwordTrail(parent)
	elseif p == "Cancel" then
		ClearWheel(formatted)
		SwordTrail(parent, false)
	elseif p == "CreateSlash" then
		CreateSlash(parent, workspace.Debree, ...)
	elseif p == "Tap" then
		local rootPart = parent.Humanoid.RootPart
		ClearWheel(formatted)
		local folder = Instance.new("Folder", workspace.Debree)
		folder.Name = formatted
		DebrisModule:AddItem(folder, Config.TAP_ROLL_VFX_DUR + 2.5)
		Cam_Shaker(rootPart, {
			FadeInTime = 0,
			Frequency = 0.3,
			Amplitude = 0.35,
			SustainTime = 0.4,
			FadeOutTime = 0.3,
			RotationInfluence = createVector(0.1, 0.1, 0.1),
			PositionInfluence = createVector(0.5, 0.5, 0.5)
		})
		local clone = script.Assets.WaterWheelFXTap:Clone()
		local weld = Instance.new("Weld", clone.Root)
		weld.Part0 = rootPart
		weld.Part1 = clone.Root
		weld.Parent = clone
		clone.Parent = folder
		local lastTime = os.clock()
		local v = vfxUtility.PlaySound(script.Sounds, "PS2WBwaterwheelLOOP", clone.Root)

		while folder.Parent ~= nil and folder.Name ~= "--" and not (os.clock() - lastTime > Config.TAP_ROLL_VFX_DUR) do
			task.wait()
		end

		if v ~= nil then
			TweenService:Create(v, TweenInfo.new(1), {
				Volume = 1
			}):Play()
			DebrisModule:AddItem(v, 1)
		end

		Ouwmit.Enable(clone, false)
		SwordTrail(parent, false)

		if rootPart == nil or rootPart.Parent == nil or (folder == nil or folder.Name == "--") then
			return
		end

		local cFrame = rootPart.CFrame
		local v2 = cFrame * CFrame.new(0, 0, -8)
		OuwCraters.Scales({
			Center = v2.Position,
			Count = 7,
			Radius = 6.5
		})
		local clone2 = script.Assets.WaterWheelLasthit:Clone()
		clone2.CFrame = cFrame * CFrame.new(0, -2.5, -3)
		clone2.Parent = folder
		Ouwmit.Emit(clone2, Ouwmit.Owned(parent))
		CraterHandler.new("Break", v2 * CFrame.new(0, 5, 0), {
			PartCount = 10,
			BlockSize = { 0.5, 1.5 },
			Range = 30,
			Height = { 30, 60 },
			Radius = 10,
			HoldTime = 1.5
		})
		vfxUtility.PlaySound(script.Sounds, "PS2WBwaterwheelHOLDfinalslash", rootPart, true)
		Cam_Shaker(cFrame.Position, "Medium_tiny_shake_preset")
		local raycastResult = workspace:Raycast(
			(cFrame * CFrame.new(0, 0, -10)).Position,
			cFrame.UpVector * -5,
			RaycastHelper.Crater
		)

		if raycastResult ~= nil and raycastResult.Instance ~= nil then
			local clone3 = script.Assets.WaterWheelGround:Clone()
			clone3.CFrame = CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
				-1.5707963267948966,
				0,
				0
			)
			clone3.Parent = folder
			Ouwmit.Emit(clone3, Ouwmit.Owned(parent, {
				Color = raycastResult.Instance.Color,
				ColorWhitelist = { "Smoke", "Smoke2" }
			}))
		end
	elseif p == "Wheel" then
		ClearWheel(formatted)
		local folder = Instance.new("Folder", workspace.Debree)
		folder.Name = formatted
		DebrisModule:AddItem(folder, 3)
		local rootPart = parent.Humanoid.RootPart
		local cFrame = rootPart.CFrame
		local v = vfxUtility.PlaySound(script.Sounds, "PS2WBwaterwheelLOOP", rootPart)
		local clone = script.Assets.WaterWheelFX:Clone()
		clone:PivotTo(cFrame)
		clone.Parent = folder
		local raycastResult = workspace:Raycast(cFrame.Position, cFrame.UpVector * -5, RaycastHelper.Crater)
		local color = nil

		if raycastResult == nil or raycastResult.Instance == nil then
			clone.GroundVFX.SmokeCast:Destroy()
			clone.GroundVFX.GroundHitFX:Destroy()
			clone.GroundVFX.Crack:Destroy()
			clone.GroundVFX.Sparks:Destroy()
		else
			color = raycastResult.Instance.Color
			clone.GroundVFX.Position = raycastResult.Position
		end

		vfxUtility.WeldConstraint(clone.PrimaryPart, rootPart)
		DebrisModule:AddItem(clone, 4)
		Ouwmit.Enable(clone, true, Ouwmit.Owned(parent, color ~= nil and ({
			Color = color,
			ColorWhitelist = "SmokeCast",
			ColorBlacklist = "NoColorTing"
		} or nil) or nil))
		vfxUtility.TweenLight(clone, {
			Time = 0.125,
			Del = 0.225,
			DelayTimer = 1.2
		})

		for _, beam in clone.WheelVFX:GetDescendants() do
			if not beam:IsA("Beam") then
				continue
			end

			beam.Enabled = true
			local width0 = beam.Width0
			local width1 = beam.Width1
			beam.Width0 = 0
			beam.Width1 = 0
			TweenService:Create(beam, TweenInfo.new(0.2), {
				Width0 = width0,
				Width1 = width1
			}):Play()
			local v2 = beam
			task.delay(0.7, function()
				if v2.Name == "AnimeWind" then
					TweenService:Create(v2, TweenInfo.new(0.755), {
						Width0 = 0,
						Width1 = 0
					}):Play()
				else
					TweenService:Create(v2, TweenInfo.new(0.155), {
						Width0 = 0,
						Width1 = 0
					}):Play()
				end
			end)
		end

		local cam_Shaker = Cam_Shaker(rootPart, {
			FadeInTime = 0,
			Frequency = 0.3,
			Amplitude = 0.35,
			SustainTime = 0.4,
			FadeOutTime = 0.3,
			RotationInfluence = createVector(0.1, 0.1, 0.1),
			PositionInfluence = createVector(0.5, 0.5, 0.5)
		})
		local lastTime = os.clock()

		while folder.Parent ~= nil and folder.Name ~= "--" and not (os.clock() - lastTime > 0.6) do
			task.wait()
		end

		if cam_Shaker ~= nil then
			cam_Shaker:Destroy()
		end

		if v then
			v:Destroy()
		end

		if folder.Parent ~= nil and folder.Name ~= "--" then
			vfxUtility.PlaySound(script.Sounds, "PS2WBwaterwheelSTOP", rootPart, true)
		end

		vfxUtility.EnableAll(clone, false)
	elseif p == "MiddleSlash" then
		local rootPart = parent.Humanoid.RootPart
		local cFrame = rootPart.CFrame
		local clone = script.Assets.MiddleSlash:Clone()
		clone:PivotTo(cFrame)
		local raycastResult = workspace:Raycast(cFrame.Position, cFrame.UpVector * -10, RaycastHelper.Crater)
		local color = nil

		if raycastResult == nil or raycastResult.Instance == nil then
			clone.SlashVFX.GroundRaycasting.Ground:Destroy()
		else
			color = raycastResult.Instance.Color
			local position = clone.SlashVFX.GroundRaycasting.Ground.Position
			clone.SlashVFX.GroundRaycasting.Ground.Position = vector.create(
				position.X,
				raycastResult.Position.Y,
				position.Z
			)
		end

		clone.Parent = workspace.Debree
		DebrisModule:AddItem(clone, 3)
		vfxUtility.EmitAll(clone.SlashVFX, vfxUtility.Owned(parent, color ~= nil and ({
			Color = color,
			ColorWhitelist = { "Smoke", "Smoke2" }
		} or nil) or nil))
		vfxUtility.TweenBeams(clone.SlashBeams.SerializedMeshAnim, {
			Time = 0.3,
			Del = 0.3
		})
		Cam_Shaker(rootPart.Position, "medium_shake_preset")
		local v = cFrame * CFrame.new(0, 0, -8)
		OuwCraters.Scales({
			Center = v.Position,
			Count = 7,
			Radius = 6.5
		})
		CraterHandler.new("Break", v * CFrame.new(0, 5, 0), {
			PartCount = 10,
			BlockSize = { 0.5, 1.5 },
			Range = 30,
			Height = { 30, 60 },
			Radius = 10,
			HoldTime = 1.5
		})
		local cFrame2 = clone.SlashBeams.SerializedMeshAnim.CFrame * clone.SlashBeams.SerializedMeshAnim:GetAttribute("CFrameDiff")
		local windyMeshy = clone.SlashVFX.GroundRaycasting.WindyMeshy
		local v3 = windyMeshy.SerializedMeshAnim.CFrame * windyMeshy.SerializedMeshAnim:GetAttribute("CFrameDiff")
		local serializedMeshAnim = clone.SlashVFX.GroundRaycasting.SwirlEffect.SerializedMeshAnim
		local endPartSize = serializedMeshAnim:GetAttribute("EndPartSize")
		local v4 = serializedMeshAnim.CFrame * serializedMeshAnim:GetAttribute("CFrameDiff")
		TweenService:Create(clone.SlashBeams.SerializedMeshAnim, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
			CFrame = cFrame2
		}):Play()
		TweenService:Create(windyMeshy.SerializedMeshAnim, TweenInfo.new(2, Enum.EasingStyle.Quad), {
			Position = v3.Position
		}):Play()
		TweenService:Create(windyMeshy.SerializedMeshAnim.Mesh, TweenInfo.new(2, Enum.EasingStyle.Quad), {
			Scale = createVector(0.619, 0.56, 0.541)
		}):Play()
		TweenService:Create(
			windyMeshy.SerializedMeshAnim,
			TweenInfo.new(2.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
			{
				Orientation = windyMeshy.SerializedMeshAnim.Orientation + createVector(0, -300, 0)
			}
		):Play()
		TweenService:Create(serializedMeshAnim, TweenInfo.new(2, Enum.EasingStyle.Quad), {
			Size = endPartSize,
			Position = v4.Position
		}):Play()
		TweenService:Create(serializedMeshAnim, TweenInfo.new(2.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Orientation = serializedMeshAnim.Orientation + createVector(0, -300, 0)
		}):Play()
		TweenService:Create(serializedMeshAnim, TweenInfo.new(2, Enum.EasingStyle.Quint), {
			Transparency = 1
		}):Play()
		vfxUtility.PlaySound(script.Sounds, "PS2WBwaterwheelHOLDfinalslash", rootPart, true)
		Cam_Shaker(rootPart, "punch_shake")
		SwordTrail(parent, false)
	end
end