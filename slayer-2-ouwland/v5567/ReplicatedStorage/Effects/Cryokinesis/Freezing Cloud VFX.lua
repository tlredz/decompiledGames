local createVector = vector.create
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local assets = script.Assets
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local OuwCraters = require(ReplicatedStorage.CAM.Client.Modules.Effects.Craters.OuwCraters)
local DebrisModule = require(CAM.DebrisModule)
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Exponential)
local tweenInfo2 = TweenInfo.new(1)
local v = {
	{
		name = "IceSlide1",
		offset = CFrame.new(0.314, -12.468, -3.692) * CFrame.Angles(0, 1.5707963267948966, 0),
		rise = 10,
		ground = "Ground1"
	},
	{
		name = "IceSlide2",
		offset = CFrame.new(0.314, -12.375, -6.757) * CFrame.Angles(0, 1.5707963267948966, 0),
		rise = 10,
		ground = "Ground2"
	},
	{
		name = "IceSlide3",
		offset = CFrame.new(0.314, -11.805, -11.806) * CFrame.Angles(0, 1.5707963267948966, 0),
		rise = 10,
		ground = "Ground3"
	},
	{
		name = "IceSlide4",
		offset = CFrame.new(0.751, -21.381, -19.343) * CFrame.Angles(0, 1.5707963267948966, 0),
		rise = 20,
		ground = "Ground4"
	},
	{
		name = "IceSlide5",
		offset = CFrame.new(0.904, -20.929, -33.891) * CFrame.Angles(0, 1.5707963267948966, 0),
		rise = 20,
		ground = "Ground5"
	}
}

-- equivalent calls inferred from this helper; original call sites unknown
local function releaseFolder(p)
	local formatted = `{p.Name}-FreezingCloudVFX`
	local child = workspace.Debree:FindFirstChild(formatted)

	if child and child.Parent then
		child.Name = "--"
	end
end

local function createFolder(p)
	releaseFolder(p) -- equivalent call inferred; original call site unknown
	local configuration = Instance.new("Configuration")
	configuration.Name = `{p.Name}-FreezingCloudVFX`
	configuration.Parent = workspace.Debree
	DebrisModule:AddItem(configuration, 13)
	return configuration
end

-- equivalent calls inferred from this helper; original call sites unknown
local function findFolder(parent)
	local formatted = `{parent.Name}-FreezingCloudVFX`
	return (workspace.Debree:FindFirstChild(formatted))
end

local function cloneFrom(instance, childName: string, parent, cframe: CFrame?, p: number?)
	local child = instance:FindFirstChild(childName)

	if child == nil then
		return nil
	end

	local clone = child:Clone()

	if cframe then
		clone:PivotTo(cframe)
	end

	clone.Parent = parent

	if p then
		DebrisModule:AddItem(clone, p)
	end

	return clone
end

return function(parent, p: string, cframe, _: boolean?)
	if parent == nil then
		return
	end

	if p == "Cancel" then
		releaseFolder(parent) -- equivalent call inferred; original call site unknown
	else
		local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart") or parent.PrimaryPart

		if humanoidRootPart == nil then
			return
		end

		local parent2

		if p == "Startup" then
			releaseFolder(parent) -- equivalent call inferred; original call site unknown
			parent2 = Instance.new("Configuration")
			parent2.Name = `{parent.Name}-FreezingCloudVFX`
			parent2.Parent = workspace.Debree
			DebrisModule:AddItem(parent2, 13)
		else
			parent2 = findFolder(parent)
		end

		if parent2 == nil then
			return
		end

		if p == "Startup" then
			local asset = vfxUtility.cloneAsset(
				assets,
				parent2,
				"StarterAura",
				humanoidRootPart.CFrame * CFrame.new(0, -0.5, 0),
				5
			)
			vfxUtility.EmitAll(asset, vfxUtility.Owned(parent))
			Cam_Shaker(humanoidRootPart.Position, "activate_shake")
			vfxUtility.PlaySound(script.Sounds, "PS2cryokenesisSKILL4disappear", humanoidRootPart, true)
			task.wait(0.3333333333333333)

			if not findFolder(parent) then
				return
			end

			local asset2 = vfxUtility.cloneAsset(
				assets,
				parent2,
				"IceThing",
				humanoidRootPart.CFrame * CFrame.new(0, -2.5, 0),
				12
			)
			vfxUtility.EmitAll(asset2, vfxUtility.Owned(parent))
			local clone_2 = assets.Attachments.InvisAttach:Clone()
			clone_2.Parent = asset2
			local clone = assets.Attachments.IceHighlight:Clone()
			clone.Parent = parent
			clone.FillTransparency = 0.8
			DebrisModule:AddItem(clone, 2)
		elseif p == "Hit" then
			local iceThing = parent2:FindFirstChild("IceThing")
			local invisAttach = iceThing and iceThing:FindFirstChild("InvisAttach", true)

			if invisAttach then
				invisAttach:Destroy()
			end

			vfxUtility.PlaySound(script.Sounds, "PS2cryokenesisSKILL4grabthrow", humanoidRootPart, true)
			task.wait(0.16666666666666666)

			if not findFolder(parent) then
				return
			end

			local hitbutfr = assets:FindFirstChild("Hitbutfr")
			local handAttach = hitbutfr and hitbutfr:FindFirstChild("HandAttach", true)
			local rightHand = parent:FindFirstChild("RightHand")

			if handAttach and rightHand then
				Cam_Shaker(rightHand.Position, "activate_shake")
				local clone = handAttach:Clone()
				clone.Parent = rightHand
				vfxUtility.EmitAll(clone, vfxUtility.Owned(parent))
				DebrisModule:AddItem(clone, 5)
			end

			task.wait(0.5)

			if not findFolder(parent) then
				return
			end

			local v3 = humanoidRootPart.CFrame * CFrame.new(-0.617, -2.589, -5.899) * CFrame.Angles(
				0,
				0,
				1.5707963267948966
			)
			Cam_Shaker(v3.Position, {
				FadeInTime = 0,
				Frequency = 0.165,
				Amplitude = 1.5,
				SustainTime = 0.1,
				FadeOutTime = 0.4,
				RotationInfluence = createVector(0.25, 0.25, 0.25),
				PositionInfluence = createVector(1.3, 1.3, 1.3)
			})
			OuwCraters.Scales({
				Center = v3.Position + createVector(0, 3, 0),
				Radius = 6,
				ScaleMult = 0.7
			})
			local asset = vfxUtility.cloneAsset(assets, parent2, "HitPart", v3, 5)
			vfxUtility.EmitAll(asset, vfxUtility.Owned(parent))
		elseif p == "Clone" then
			local iceThing = parent2:FindFirstChild("IceThing")
			local invisAttach = iceThing and iceThing:FindFirstChild("InvisAttach", true)

			if invisAttach then
				invisAttach:Destroy()
			end

			local asset = vfxUtility.cloneAsset(assets, parent2, "Hit", cframe, 5)
			vfxUtility.EmitAll(asset, vfxUtility.Owned(parent))
			vfxUtility.PlaySound(script.Sounds, "PS2cryokenesisSKILL4var2icecrystals", asset, true)
			local clone = ReplicatedStorage.Assets.StarterCharacterCloneable:Clone()
			clone:PivotTo(cframe)
			clone.Parent = parent2
			DebrisModule:AddItem(clone, 1.6)
			local primaryPart = clone.PrimaryPart
			local clone2 = assets.Attachments.IceHighlight:Clone()
			clone2.FillTransparency = 0.1
			clone2.Parent = clone
			local clone3 = assets.Attachments.CharFX:Clone()
			clone3.Parent = clone
			vfxUtility.EmitAll(clone3, vfxUtility.Owned(parent))
			task.wait(0.2)

			if not findFolder(parent) then
				return
			end

			if clone.Parent then
				local animator = clone:FindFirstChild("Humanoid") and clone.Humanoid:FindFirstChild("Animator")
				local freezingCloudClone = assets:FindFirstChild("FreezingCloudClone")

				if animator and freezingCloudClone then
					animator:LoadAnimation(freezingCloudClone):Play()
				end
			end

			task.wait(0.4)

			if not findFolder(parent) or clone.Parent == nil or primaryPart == nil then
				return
			end

			local cFrame = primaryPart.CFrame
			local iceCloneFX = assets:FindFirstChild("IceCloneFX")

			if iceCloneFX == nil then
				return
			end

			local v3 = cFrame * CFrame.new(0.467, -2.9, -1.759) * CFrame.Angles(0, 1.5707963267948966, 0)
			local kickImpact = iceCloneFX:FindFirstChild("KickImpact")

			if kickImpact ~= nil then
				local clone4 = kickImpact:Clone()

				if v3 then
					clone4:PivotTo(v3)
				end

				clone4.Parent = parent2
				DebrisModule:AddItem(clone4, 5)
			end

			local v4 = cFrame * CFrame.new(0.456, -2.584, -8.815)
			local iceSlideFX = iceCloneFX:FindFirstChild("IceSlideFX")
			local clone4

			if iceSlideFX ~= nil then
				clone4 = iceSlideFX:Clone()

				if v4 then
					clone4:PivotTo(v4)
				end

				clone4.Parent = parent2
				DebrisModule:AddItem(clone4, 6)
			end

			task.wait(0.1)

			for k, v5 in v do
				if not findFolder(parent) then
					return
				end

				local child = clone4 and clone4:FindFirstChild(v5.ground)

				if child then
					vfxUtility.EmitAll(child, vfxUtility.Owned(parent))
				end

				local name = v5.name
				local v6 = cFrame * v5.offset
				local child2 = iceCloneFX:FindFirstChild(name)
				local clone5

				if child2 ~= nil then
					clone5 = child2:Clone()

					if v6 then
						clone5:PivotTo(v6)
					end

					clone5.Parent = parent2
					DebrisModule:AddItem(clone5, 6)
				end

				if clone5 then
					vfxUtility.EmitAll(clone5, vfxUtility.Owned(parent))

					if clone5:IsA("Model") then
						clone5 = clone5.PrimaryPart
					end

					if clone5 then
						local cFrame2 = clone5.CFrame * CFrame.new(0, v5.rise, 0)
						TweenService:Create(clone5, tweenInfo, {
							CFrame = cFrame2
						}):Play()
						local v8 = clone5
						local v10 = v5
						task.delay(0.6, function()
							if v8.Parent then
								TweenService:Create(v8, tweenInfo2, {
									CFrame = cFrame2 * CFrame.new(0, -v10.rise * 2, 0)
								}):Play()
							end
						end)
					end
				end

				if k < #v then
					task.wait(0.2)
				end
			end

			if primaryPart and primaryPart.Parent then
				local asset2 = vfxUtility.cloneAsset(assets, parent2, "Hit", primaryPart.CFrame, 5)
				vfxUtility.PlaySound(script.Sounds, "PS2cryokenesisSKILL4var2reappear", asset2, true)
				vfxUtility.EmitAll(asset2, vfxUtility.Owned(parent))
			end
		end
	end
end