local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local Ouwmit = require(CAM.Client.Modules.Effects.Ouwmit)
local DebrisModule = require(CAM.DebrisModule)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local Cam_Shaker = require(CAM.Client.Modules.Effects.Cam_Shaker)
local debree = workspace.Debree
local assets = script.Assets
local sounds = script:FindFirstChild("Sounds")

local function soundAnchor(instance)
	if instance:IsA("BasePart") then
		return instance
	end

	if instance:IsA("Model") then
		return instance.PrimaryPart or instance:FindFirstChildWhichIsA("BasePart", true)
	end

	return nil
end

local function stopRollLoop(instance)
	if typeof(instance) ~= "Instance" then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	local pS2yetiSNOWBALLloop = humanoidRootPart and humanoidRootPart:FindFirstChild("PS2yetiSNOWBALLloop")

	if pS2yetiSNOWBALLloop and pS2yetiSNOWBALLloop:IsA("Sound") then
		pS2yetiSNOWBALLloop:Stop()
		pS2yetiSNOWBALLloop:Destroy()
	end
end

local function groundInfo(vector2: Vector3)
	local raycastResult = workspace:Raycast(
		vector2 + createVector(0, 4, 0),
		createVector(0, -60, 0),
		RaycastHelper.Crater
	)

	if raycastResult then
		vector2 = raycastResult.Position + createVector(0, 0.5, 0)
	end

	return CFrame.new(vector2), raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
end

return function(list)
	local v = list[1]

	if v == "Activate" then
		local v2 = list[4]

		if typeof(v2) ~= "Vector3" or (v2 - workspace.CurrentCamera.CFrame.Position).Magnitude >= 250 then
			return
		end

		Cam_Shaker(v2, {
			FadeInTime = 0,
			Frequency = 0.25,
			Amplitude = 0.75,
			SustainTime = 0.2,
			FadeOutTime = 0.7,
			RotationInfluence = createVector(0.3, 0.3, 0.3),
			PositionInfluence = createVector(1, 1, 1)
		})
		local raycastResult = workspace:Raycast(
			v2 + createVector(0, 4, 0),
			createVector(0, -60, 0),
			RaycastHelper.Crater
		)

		if raycastResult then
			v2 = raycastResult.Position + createVector(0, 0.5, 0)
		end

		local cframe = CFrame.new(v2)
		local v3 = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
		local clone = assets.BAllUp:Clone()
		local v4 = tonumber(list[5]) or 1

		if v4 ~= 1 then
			clone:ScaleTo(v4)
		end

		clone:PivotTo(cframe * CFrame.new(0, 1.5, 0))
		clone.Parent = debree
		Ouwmit.Emit(clone, Ouwmit.Owned(list[3], v3))
		DebrisModule:AddItem(clone, 3)

		if not clone:IsA("BasePart") then
			if clone:IsA("Model") then
				clone = clone.PrimaryPart or clone:FindFirstChildWhichIsA("BasePart", true)
			else
				clone = nil
			end
		end

		if clone then
			vfxUtility.PlaySound(sounds, "PS2yetiSNOWBALLinit", clone, true)
		end

		local v5 = list[3]
		stopRollLoop(v5)
		local humanoidRootPart

		if typeof(v5) == "Instance" then
			humanoidRootPart = v5:FindFirstChild("HumanoidRootPart")
		else
			humanoidRootPart = false
		end

		local v6 = humanoidRootPart and vfxUtility.PlaySound(sounds, "PS2yetiSNOWBALLloop", humanoidRootPart, false)

		if v6 then
			DebrisModule:AddItem(v6, 10)
		end
	elseif v == "Deactivate" then
		stopRollLoop(list[3])
		local cFrame = list[4]

		if typeof(cFrame) ~= "CFrame" then
			local child = debree:FindFirstChild(list[2])

			if child == nil then
				return
			else
				cFrame = child.CFrame
			end
		end

		if (cFrame.Position - workspace.CurrentCamera.CFrame.Position).Magnitude >= 250 then
			return
		end

		Cam_Shaker(cFrame.Position, {
			FadeInTime = 0,
			Frequency = 0.22,
			Amplitude = 1.5,
			SustainTime = 0.12,
			FadeOutTime = 0.9,
			RotationInfluence = createVector(0.35, 0.35, 0.35),
			PositionInfluence = createVector(1, 1, 1)
		})
		local position = cFrame.Position
		local raycastResult = workspace:Raycast(
			position + createVector(0, 4, 0),
			createVector(0, -60, 0),
			RaycastHelper.Crater
		)

		if raycastResult then
			position = raycastResult.Position + createVector(0, 0.5, 0)
		end

		local cframe = CFrame.new(position)
		local v2 = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
		local clone = assets.BallExplosion:Clone()
		local v3 = tonumber(list[5]) or 1

		if v3 ~= 1 then
			clone:ScaleTo(v3 * 0.3)
		end

		clone:PivotTo(cframe * CFrame.new(0, 2.5 * v3, 0))
		clone.Parent = debree
		Ouwmit.Emit(clone, Ouwmit.Owned(list[3], v2))
		DebrisModule:AddItem(clone, 4)

		if not clone:IsA("BasePart") then
			if clone:IsA("Model") then
				clone = clone.PrimaryPart or clone:FindFirstChildWhichIsA("BasePart", true)
			else
				clone = nil
			end
		end

		if clone then
			vfxUtility.PlaySound(sounds, "PS2yetiSNOWBALLstop", clone, true)
		end
	end
end