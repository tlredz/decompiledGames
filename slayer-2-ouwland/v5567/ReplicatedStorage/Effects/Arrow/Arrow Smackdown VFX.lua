local createVector = vector.create
game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("Lighting")
local CAM = ReplicatedStorage.CAM
local modules = CAM.Client.Modules
local debree = workspace.Debree
local assets = script:FindFirstChild("Assets")
script:FindFirstChild("Sounds")
local token = modules.Effects.Token
local DebrisModule = require(CAM.DebrisModule)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local Cam_Shaker = require(modules.Effects.Cam_Shaker)
local CraterExtension = require(modules.Effects.Craters.CraterExtension)
require(modules.Effects.Craters.CraterEffects)
local TokenKit = require(token.TokenKit)
local vfxUtility = require(game.ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local _ = game.Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = { workspace.Map }
raycastParams.FilterType = Enum.RaycastFilterType.Include
local v = {
	Cancel = true,
	Initiate = true,
	Hit = true,
	InitiateStrike = true
}
local v2 = CFrame.new(-0.0531005859375, 15.436896324157715, 0.27850341796875) * CFrame.fromEulerAnglesYXZ(
	-1.5707963705062866,
	-0,
	0
)
local cframe = CFrame.new(0, 0, -25)

local function trackedCF(part, cframe2: CFrame)
	if part == nil or not part:IsA("BasePart") or part.Parent == nil then
		return cframe2
	end

	local position = part.Position
	local raycastResult = workspace:Raycast(
		position + createVector(0, 5, 0),
		createVector(0, -20, 0),
		RaycastHelper.Crater
	)

	if raycastResult == nil then
		return CFrame.new(position, position + createVector(0, 1, 0)) * CFrame.Angles(-1.5707963267948966, 0, 0)
	end

	return CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
		-1.5707963267948966,
		0,
		0
	)
end

return function(instance, p: string, cFrame, p2, p3)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

	if humanoidRootPart == nil or p ~= "Cancel" and (humanoidRootPart.Position - currentCamera.CFrame.Position).Magnitude > 250 then
		return
	end

	instance:FindFirstChild("UpperTorso")
	local name = string.format("%s Arrow_SmackDown_Effects", instance.Name)
	local parent = debree:FindFirstChild(name)

	if not v[p] then
		if parent then
			parent:Destroy()
		end

		parent = Instance.new("Folder")
		parent.Name = name
		parent.Parent = debree
		DebrisModule:AddItem(parent, 9)
	end

	if parent == nil then
		return
	end

	if p == "Start" then
		local clone = assets.SkillInitialFX:Clone()
		clone.Parent = parent
		local clone2 = script.Sounds.PS2arrowDROPstart:Clone()
		clone2.Parent = clone
		clone2:Play()
		clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -1, 0)
		vfxUtility.EmitAll(clone:GetDescendants(), vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone, 6)
		Cam_Shaker(humanoidRootPart.Position, "tinyshake_less_aggresive_preset")
	elseif p == "Initiate" then
		local clone = assets.Part.SummonPurp:Clone()
		clone.Parent = instance.RightHand
		DebrisModule:AddItem(clone, 3)
		vfxUtility.EmitAll(clone, vfxUtility.Owned(instance))
		local clone2 = assets.Part.SummonPurp:Clone()
		clone2.Parent = instance.LeftHand
		DebrisModule:AddItem(clone2, 3)
		vfxUtility.EmitAll(clone2, vfxUtility.Owned(instance))
		local v5 = trackedCF(p3, cFrame)
		local clone3 = assets.ArrowHit1:Clone()
		clone3.CFrame = v5 * CFrame.new(0, 0.5, 0)
		clone3.Parent = parent
		local clone4 = script.Sounds.PS2arrowDROPsummonNEW:Clone()
		clone4.Parent = clone3
		clone4:Play()
		local clone5 = assets.ArrowModel:Clone()
		clone5.Parent = parent
		clone5:PivotTo(clone3.CFrame * v2)
		DebrisModule:AddItem(clone5, 6)

		for _, descendant in clone5:GetDescendants() do
			if descendant.ClassName == "ParticleEmitter" then
				descendant:Emit(descendant:GetAttribute("EmitCount"))
			end

			if descendant.ClassName == "Trail" then
				descendant.Enabled = true
			end

			if descendant.ClassName == "Decal" then
				descendant.Transparency = 0
			end
		end

		task.wait(0.25)

		if not clone5:IsDescendantOf(parent) then
			return
		end

		local clone6 = script.Sounds.PS2arrowDROPdropNEW:Clone()
		clone6.Parent = clone3
		clone6:Play()

		if p3 == nil or p3.Parent == nil then
			TweenService:Create(clone5.PrimaryPart, TweenInfo.new(0.3), {
				CFrame = clone5.PrimaryPart.CFrame * cframe
			}):Play()
		else
			local lastTime = os.clock()
			local postSimulationConnection = nil
			postSimulationConnection = RunService.PostSimulation:Connect(function()
				if not clone5:IsDescendantOf(parent) then
					postSimulationConnection:Disconnect()
					return
				end

				v5 = trackedCF(p3, v5)
				clone3.CFrame = v5 * CFrame.new(0, 0.5, 0)
				local v6 = clone3.CFrame * v2
				local v7 = math.clamp((os.clock() - lastTime) / 0.3, 0, 1)
				clone5:PivotTo(v6:Lerp(v6 * cframe, v7))

				if v7 >= 1 then
					postSimulationConnection:Disconnect()
				end
			end)
		end

		task.wait(0.15)

		if not clone5:IsDescendantOf(parent) then
			return
		end

		Cam_Shaker(clone3.Position, {
			FadeInTime = 0,
			Frequency = 0.2,
			Amplitude = 0.5,
			SustainTime = 0.1,
			FadeOutTime = 0.5,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
		local clone7 = script.Sounds.PS2arrowDROPslam1:Clone()
		clone7.Parent = clone3
		clone7:Play()
		vfxUtility.EmitAll(clone3:GetDescendants(), vfxUtility.Owned(instance, vfxUtility.GetDustColorSettings(p2)))
		DebrisModule:AddItem(clone3, 3)

		for _, descendant in clone5:GetDescendants() do
			if descendant.ClassName == "ParticleEmitter" or descendant.ClassName == "Trail" then
				descendant.Enabled = false
			end

			if descendant.ClassName == "Decal" then
				TweenService:Create(descendant, TweenInfo.new(0.2), {
					Transparency = 1
				}):Play()
			end
		end
	elseif p == "InitiateStrike" then
		local clone = assets.ArrowHit2:Clone()
		clone.Parent = parent
		clone.CFrame = cFrame
		vfxUtility.EmitAll(clone:GetDescendants(), vfxUtility.Owned(instance, vfxUtility.GetDustColorSettings(p2)))
		DebrisModule:AddItem(clone, 3)
		CraterExtension.Ground(clone.Position, 10, createVector(2.5, 3.5, 2), nil, 2, false, 2)
		CraterExtension.Ground(clone.Position, 8, createVector(2.5, 3.5, 2), nil, 5, false, 2)
		task.spawn(TokenKit.GroundRocks, {
			CF = clone.CFrame,
			InnerRadius = 5,
			OuterRadius = 10,
			Velocity = {
				Min = 20,
				Max = 40
			},
			Size = {
				Min = 1,
				Max = 3
			}
		})
		Cam_Shaker(clone.Position, {
			FadeInTime = 0,
			Frequency = 0.3,
			Amplitude = 0.5,
			SustainTime = 0.1,
			FadeOutTime = 0.5,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
	elseif p == "Hit" then
		local clone = assets.ArrowModel:Clone()
		clone.Parent = parent

		if clone == nil or clone.Parent == nil then
			return
		end

		clone:PivotTo(cFrame * CFrame.fromEulerAnglesYXZ(1.5392810106277466, 0.8367703557014465, -2.305187702178955))
		TweenService:Create(clone.PrimaryPart, TweenInfo.new(1), {
			CFrame = clone.PrimaryPart.CFrame * CFrame.new(0, 0, -28)
		}):Play()
		DebrisModule:AddItem(clone, 6)
		Cam_Shaker(clone.PrimaryPart.Position, {
			FadeInTime = 0,
			Frequency = 0.3,
			Amplitude = 0.5,
			SustainTime = 0.1,
			FadeOutTime = 0.5,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})

		for _, descendant in clone:GetDescendants() do
			if descendant.ClassName == "ParticleEmitter" then
				descendant:Emit(descendant:GetAttribute("EmitCount"))
			end

			if descendant.ClassName == "Trail" then
				descendant.Enabled = true
			end

			if descendant.ClassName == "Decal" then
				descendant.Transparency = 0
			end
		end

		local clone2 = script.Sounds.PS2arrowDROPlift:Clone()
		clone2.Parent = clone.PrimaryPart
		clone2:Play()
		task.wait(1.2666666666666666)

		if clone == nil or clone.Parent == nil then
			return
		end

		clone.PrimaryPart.CFrame = CFrame.lookAt(clone.PrimaryPart.Position, cFrame.Position)
		TweenService:Create(clone.PrimaryPart, TweenInfo.new(0.16666666666666666), {
			CFrame = clone.PrimaryPart.CFrame * CFrame.new(0, 0, -40)
		}):Play()
		vfxUtility.EnableAll(clone.MainPart)
		Cam_Shaker(clone.PrimaryPart.Position, {
			FadeInTime = 0,
			Frequency = 0.3,
			Amplitude = 0.5,
			SustainTime = 0.1,
			FadeOutTime = 0.5,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
		local clone3 = script.Sounds.PS2arrowDROPdrop:Clone()
		clone3.Parent = clone.PrimaryPart
		clone3:Play()
		task.wait(0.11666666666666665)
		local clone4 = script.Sounds.PS2arrowDROPslam2:Clone()
		clone4.Parent = clone.PrimaryPart
		clone4:Play()

		if clone == nil or clone.Parent == nil then
			return
		end

		for _, descendant in clone:GetDescendants() do
			if descendant.ClassName == "ParticleEmitter" or descendant.ClassName == "Trail" then
				descendant.Enabled = false
			end

			if descendant.ClassName == "Decal" then
				TweenService:Create(descendant, TweenInfo.new(0.2), {
					Transparency = 1
				}):Play()
			end
		end
	elseif p == "Cancel" then
		parent:Destroy()
	end
end