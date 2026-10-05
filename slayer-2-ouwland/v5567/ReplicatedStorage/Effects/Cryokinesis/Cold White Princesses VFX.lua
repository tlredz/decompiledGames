local createVector = vector.create
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local assets = script.Assets
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local OuwCraters = require(ReplicatedStorage.CAM.Client.Modules.Effects.Craters.OuwCraters)
local DebrisModule = require(CAM.DebrisModule)
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)

local function lingerTime(folder)
	local v = 0

	for _, effect in ipairs(folder:GetDescendants()) do
		if effect:IsA("ParticleEmitter") then
			v = math.max(v, effect.Lifetime.Max)
		elseif effect:IsA("Trail") then
			v = math.max(v, effect.Lifetime)
		end
	end

	return v
end

local function releaseFolder(p)
	local formatted = `{p.Name}-ColdWhitePrincessesVFX`
	local child = workspace.Debree:FindFirstChild(formatted)

	if child and child.Parent then
		vfxUtility.ToggleWithColor(child, false)
		child.Name = "--"
		DebrisModule:AddItem(child, lingerTime(child) + 0.1)
	end
end

local function createFolder(p)
	releaseFolder(p)
	local configuration = Instance.new("Configuration")
	configuration.Name = `{p.Name}-ColdWhitePrincessesVFX`
	configuration.Parent = workspace.Debree
	DebrisModule:AddItem(configuration, 10)
	return configuration
end

-- equivalent calls inferred from this helper; original call sites unknown
local function findFolder(instance)
	local formatted = `{instance.Name}-ColdWhitePrincessesVFX`
	return (workspace.Debree:FindFirstChild(formatted))
end

return function(instance, p: string, parent, cframe: CFrame?)
	if instance == nil then
		return
	end

	if p == "Cancel" then
		releaseFolder(instance)
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

	if humanoidRootPart == nil then
		return
	end

	local parent2

	if p == "Start" then
		releaseFolder(instance)
		parent2 = Instance.new("Configuration")
		parent2.Name = `{instance.Name}-ColdWhitePrincessesVFX`
		parent2.Parent = workspace.Debree
		DebrisModule:AddItem(parent2, 10)
	else
		parent2 = findFolder(instance)
	end

	if parent2 == nil then
		return
	end

	if p == "Start" then
		local asset = vfxUtility.cloneAsset(
			assets,
			parent2,
			"StarterAura",
			humanoidRootPart.CFrame * CFrame.new(0, -0.5, 0),
			5
		)
		vfxUtility.EmitAll(asset, vfxUtility.Owned(instance))
		vfxUtility.ToggleWithColor(asset, true, nil, nil, instance)
		Cam_Shaker(humanoidRootPart.Position, "activate_shake")
		vfxUtility.PlaySound(script.Sounds, "PS2cryokenesisSKILL2initiate", humanoidRootPart, true)
		task.wait(3)

		if asset.Parent then
			vfxUtility.ToggleWithColor(asset, false)
		end
	elseif p == "Flowers" then
		local clone = ReplicatedStorage.Assets.StarterCharacterCloneable:Clone()
		clone:PivotTo(cframe)
		clone.Parent = parent2
		DebrisModule:AddItem(clone, 1.6)
		vfxUtility.PlaySound(script.Sounds, "PS2cryokenesisSKILL2grab", humanoidRootPart, true)
		local clone2 = assets.Attachments.IceHighlight:Clone()
		clone2.FillTransparency = 1
		clone2.Parent = clone
		TweenService:Create(clone2, TweenInfo.new(0.5), {
			FillTransparency = 0.1
		}):Play()
		Cam_Shaker(clone.HumanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.15,
			Amplitude = 1.15,
			SustainTime = 0.1,
			FadeOutTime = 0.4,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(1.3, 1.3, 1.3)
		})
		local track = clone:FindFirstChild("Humanoid").Animator:LoadAnimation(assets.ColdWhitePrincessesLoop)
		track:Play()
		track:AdjustSpeed(0)
		local asset = vfxUtility.cloneAsset(
			assets,
			parent2,
			"Hit",
			humanoidRootPart.CFrame * CFrame.new(0, -0.5, -2),
			2
		)
		vfxUtility.EmitAll(asset, vfxUtility.Owned(instance))
		local flowersRig = assets.RigAssets:FindFirstChild("FlowersRig")
		local clone3

		if flowersRig then
			clone3 = flowersRig:Clone()
		end

		if clone3 then
			clone3:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, 2, 0.5))
			clone3.Parent = parent2
			DebrisModule:AddItem(clone3, 4.15)
		end

		local coldWhitePrincessesFlowerRigAnimation = assets.ColdWhitePrincessesFlowerRigAnimation
		local tracks = {}

		if clone3 then
			for _, childName in { "Flower1", "Flower2" } do
				local child = clone3:FindFirstChild(childName, true)
				local animator = child and child:FindFirstChildWhichIsA("Animator", true)

				if not animator then
					continue
				end

				local track2 = animator:LoadAnimation(coldWhitePrincessesFlowerRigAnimation)
				track2:Play()
				DebrisModule:AddItem(track2, 6.3)
				table.insert(tracks, track2)
			end
		end

		local humanoidRootPart2 = parent and parent:FindFirstChild("HumanoidRootPart")
		local v2

		if humanoidRootPart2 then
			v2 = vfxUtility.cloneAsset(
				assets,
				parent2,
				"IceFloor",
				humanoidRootPart2.CFrame * CFrame.new(0, -2.5, -2.5),
				7
			)
		end

		local folder

		if humanoidRootPart2 then
			folder = vfxUtility.cloneAsset(
				assets,
				parent2,
				"RisingIce",
				humanoidRootPart2.CFrame * CFrame.new(0, -5, 0),
				7
			)
		end

		local clone4

		if humanoidRootPart2 then
			vfxUtility.EmitAll(v2, vfxUtility.Owned(instance))
			vfxUtility.ToggleWithColor(v2, true, nil, nil, instance)
			vfxUtility.EmitAll(folder, vfxUtility.Owned(instance))
			TweenService:Create(folder.PrimaryPart, TweenInfo.new(2), {
				CFrame = folder.PrimaryPart.CFrame * CFrame.new(0, 5, 0)
			}):Play()
			clone4 = assets.Attachments.IceHighlight:Clone()
			clone4.Parent = parent
			clone4.FillTransparency = 1
			TweenService:Create(clone4, TweenInfo.new(3), {
				FillTransparency = 0.1
			}):Play()
			DebrisModule:AddItem(clone4, 3)
		end

		task.wait(1.5)

		if not findFolder(instance) then
			return
		end

		local asset2 = vfxUtility.cloneAsset(assets, parent2, "Hit", cframe, 5)
		vfxUtility.EmitAll(asset2, vfxUtility.Owned(instance))

		if humanoidRootPart ~= nil and humanoidRootPart.Parent ~= nil then
			vfxUtility.PlaySound(script.Sounds, "PS2cryokenesisSKILL2clonedisappear", humanoidRootPart, true)
			Cam_Shaker(humanoidRootPart.Position, "activate_shake")
		end

		task.wait(0.25)

		if not findFolder(instance) then
			return
		end

		if clone3 and clone3.Parent then
			vfxUtility.ToggleWithColor(clone3, true, nil, nil, instance)
		end

		task.wait(0.75)

		if not findFolder(instance) then
			return
		end

		if clone3 and clone3.Parent then
			for _, v3 in tracks do
				if v3.IsPlaying then
					v3:AdjustSpeed(-1.5)
				end
			end

			vfxUtility.ToggleWithColor(clone3, false)
		end

		task.wait(0.5)

		if not findFolder(instance) then
			return
		end

		if humanoidRootPart2 and humanoidRootPart2.Parent then
			Cam_Shaker(humanoidRootPart2.Position, {
				FadeInTime = 0,
				Frequency = 0.15,
				Amplitude = 1.5,
				SustainTime = 0.1,
				FadeOutTime = 0.4,
				RotationInfluence = createVector(0.25, 0.25, 0.25),
				PositionInfluence = createVector(1.3, 1.3, 1.3)
			})

			if v2 and v2.Parent then
				vfxUtility.ToggleWithColor(v2, false)
			end

			if folder and folder.Parent then
				TweenService:Create(folder.PrimaryPart, TweenInfo.new(2), {
					CFrame = folder.PrimaryPart.CFrame * CFrame.new(0, -5, 0)
				}):Play()

				for _, part in folder:GetDescendants() do
					if part:IsA("BasePart") and part ~= folder.PrimaryPart then
						TweenService:Create(part, TweenInfo.new(2), {
							Transparency = 1
						}):Play()
					end
				end
			end

			local asset3 = vfxUtility.cloneAsset(assets, parent2, "Hit", humanoidRootPart2.CFrame, 2)
			vfxUtility.EmitAll(asset3, vfxUtility.Owned(instance))
			OuwCraters.Scales({
				Center = humanoidRootPart2.Position + createVector(0, 3, 0),
				Radius = 6,
				ScaleMult = 0.7
			})

			if clone4 then
				clone4:Destroy()
			end
		end
	end
end