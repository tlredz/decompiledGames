local createVector = vector.create
local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local v = {
	Dash1 = "PS2scytheBLOODLUSTslash1",
	Dash2 = "PS2scytheBLOODLUSTslash2",
	Dash3 = "PS2scytheBLOODLUSTslashFINALAoE"
}

local function groundDust(position)
	local v2 = vfxUtility.CheckForGround(position, createVector(0, -20, 0), vfxUtility.RayParams.Map)
	return vfxUtility.GetDustColorSettings(v2)
end

local function BlurEffect(value)
	local blurEffect = Instance.new("BlurEffect")
	blurEffect.Size = 8
	blurEffect.Parent = game.Lighting
	DebrisModule:AddItem(blurEffect, value or 0.08333333333333333)
end

local function Shake(position, amplitude, items)
	local v2 = {
		FadeInTime = 0,
		Frequency = 0.175,
		Amplitude = amplitude,
		SustainTime = 0.2,
		FadeOutTime = 0.2,
		RotationInfluence = createVector(0.2, 0.2, 0.2),
		PositionInfluence = createVector(2.5, 2.5, 2.5)
	}

	if items then
		for k, item in items do
			v2[k] = item
		end
	end

	Cam_Shaker(position, v2)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function CloneFX(instance)
	task.spawn(function()
		local tweenInfo = TweenInfo.new(0.55, Enum.EasingStyle.Linear)
		local folder = Instance.new("Folder")
		folder.Name = "BloodLustClones"
		folder.Parent = workspace.Debree
		DebrisModule:AddItem(folder, 1)

		for _ = 1, 5 do
			local clone = ReplicatedStorage.Assets.StarterCharacterCloneable:Clone()
			clone.Name = "Clone"

			for _, tag in ipairs(clone:GetTags()) do
				clone:RemoveTag(tag)
			end

			for _, part in ipairs(clone:GetChildren()) do
				if part:IsA("BasePart") then
					local child = instance:FindFirstChild(part.Name)

					if child == nil then
						part:Destroy()
					else
						part.CFrame = child.CFrame
						part.Anchored = true
						part.CanCollide = false
						part.Color = Color3.new(0, 0, 0)
						part.Material = Enum.Material.SmoothPlastic
						part.Transparency = part.Name == "HumanoidRootPart" and 1 or 0

						if part.Transparency < 1 then
							TweenService:Create(part, tweenInfo, {
								Transparency = 1
							}):Play()
						end
					end
				else
					part:Destroy()
				end
			end

			clone.Parent = folder
			task.wait(0.07)
		end
	end)
end

local function emitStrike(humanoidRootPart, p, cframe, p2)
	local clone = script[p]:Clone()
	clone.Parent = workspace.Debree
	clone:PivotTo(humanoidRootPart.CFrame * cframe)

	if p2 then
		clone:ScaleTo(clone:GetScale() * p2)
	end

	Ouwmit.Emit(clone, Ouwmit.Owned(humanoidRootPart, groundDust(humanoidRootPart.Position)))
	DebrisModule:AddItem(clone, 5)
end

return function(instance, p)
	local humanoidRootPart = instance.HumanoidRootPart

	if (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude >= 250 then
		return
	end

	if p == "Dash1" or p == "Dash2" or p == "Dash3" then
		local clone = script.Teleport:Clone()
		clone.Parent = workspace.Debree
		clone:PivotTo(humanoidRootPart.CFrame)
		Ouwmit.Emit(clone, Ouwmit.Owned(instance, groundDust(humanoidRootPart.Position)))
		DebrisModule:AddItem(clone, 5)
		local v2 = v[p]

		if v2 then
			vfxUtility.PlaySound(script.Sounds, v2, humanoidRootPart, true)
		end

		CloneFX(instance) -- equivalent call inferred; original call site unknown
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.175,
			Amplitude = p == "Dash3" and 0.25 or 0.15,
			SustainTime = 0.2,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.2, 0.2, 0.2),
			PositionInfluence = createVector(2.5, 2.5, 2.5)
		})
	elseif p == "Finisher1" then
		emitStrike(humanoidRootPart, "Strike1", CFrame.new(0, 0, -8))
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.175,
			Amplitude = 0.3,
			SustainTime = 0.2,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.2, 0.2, 0.2),
			PositionInfluence = createVector(2.5, 2.5, 2.5)
		})
	elseif p == "Finisher2" then
		emitStrike(humanoidRootPart, "Strike2", CFrame.new(0, 0, -7))
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.175,
			Amplitude = 0.4,
			SustainTime = 0.2,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.2, 0.2, 0.2),
			PositionInfluence = createVector(2.5, 2.5, 2.5)
		})
	elseif p == "Finisher3b" then
		emitStrike(humanoidRootPart, "Strike3", CFrame.new(0, -1, -6), 1.6)
		local blurEffect = Instance.new("BlurEffect")
		blurEffect.Size = 8
		blurEffect.Parent = game.Lighting
		DebrisModule:AddItem(blurEffect, 0.35)
		Shake(humanoidRootPart.Position, 0.55, {
			Frequency = 0.25,
			SustainTime = 0.6,
			FadeOutTime = 0.5,
			Amplitude = 1,
			RotationInfluence = createVector(0.35, 0.35, 0.35),
			PositionInfluence = createVector(5, 5, 5)
		})
	end
end