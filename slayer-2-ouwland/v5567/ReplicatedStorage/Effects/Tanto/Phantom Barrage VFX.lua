local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local assets = script.Assets
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local DebrisModule = require(CAM.DebrisModule)
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local Ouwmit = require(CAM.Client.Modules.Effects.Ouwmit)
local RaycastHelper = require(CAM.Global.RaycastHelper)

local function teardownRig(instance)
	local child = workspace.Debree:FindFirstChild((`{instance.Name}-PhantomBarrageRig`))

	if child and child.Parent then
		vfxUtility.EnableAll(child, false, nil, true)
		child.Name = "--"
		DebrisModule:AddItem(child, 1.3)
	end
end

return function(instance, p: string, cframe: CFrame?)
	if instance == nil then
		return
	end

	if p == "Cancel" then
		teardownRig(instance)
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

	if humanoidRootPart == nil then
		return
	end

	if p == "Start" then
		local has_Blade = instance:FindFirstChild("Has_Blade", true)

		if has_Blade ~= nil then
			local parent = has_Blade.Parent
			local clone = script.Assets.CenterWinds:Clone()
			clone.Parent = parent.Blade
			DebrisModule:AddItem(clone, 2.5)
			task.wait(0.1)
			Ouwmit.Emit(clone, Ouwmit.Owned(instance))
		end
	else
		local v = cframe or humanoidRootPart.CFrame
		local raycastResult = workspace:Raycast(
			v.Position + createVector(0, 5, 0),
			createVector(-0, -15, -0),
			RaycastHelper.Crater
		)
		local v2 = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil

		if p == "Barrage" then
			Cam_Shaker(v.Position, {
				FadeInTime = 0,
				Frequency = 0.15,
				Amplitude = 0.25,
				SustainTime = 0.5,
				FadeOutTime = 1,
				RotationInfluence = createVector(0.25, 0.25, 0.25),
				PositionInfluence = createVector(1, 1, 1)
			})
			teardownRig(instance)
			local asset = vfxUtility.cloneAsset(assets, workspace.Debree, "Barrage", humanoidRootPart.CFrame, 4)

			if asset then
				asset.Name = `{instance.Name}-PhantomBarrageRig`
				local root = asset:FindFirstChild("Root")

				if root then
					for _, part in asset:GetDescendants() do
						if part:IsA("BasePart") then
							part.Anchored = false
						end
					end

					local weld = Instance.new("Weld")
					weld.Part0 = humanoidRootPart
					weld.Part1 = root
					weld.Parent = root
				end

				Ouwmit.Emit(asset, Ouwmit.Owned(instance, v2))
			end

			local assetRoot

			if asset then
				assetRoot = asset:FindFirstChild("Root") or humanoidRootPart
			else
				assetRoot = humanoidRootPart
			end

			vfxUtility.PlaySound(script.Sounds, "PS2tantoPHANTOMBARRAGEbrrg", assetRoot, assetRoot == humanoidRootPart)
			Ouwmit.Emit(vfxUtility.cloneAsset(assets, workspace.Debree, "Emit", v, 4), Ouwmit.Owned(instance, v2))
		elseif p == "BarrageTimeScale" then
			Ouwmit.Emit(
				vfxUtility.cloneAsset(assets, workspace.Debree, "BarrageTimeScale", v, 4),
				Ouwmit.Owned(instance, v2)
			)
		elseif p == "End" then
			Cam_Shaker(v.Position, {
				FadeInTime = 0,
				Frequency = 0.15,
				Amplitude = 1,
				SustainTime = 0.1,
				FadeOutTime = 0.5,
				RotationInfluence = createVector(0.25, 0.25, 0.25),
				PositionInfluence = createVector(1, 1, 1)
			})
			vfxUtility.PlaySound(script.Sounds, "PS2tantoPHANTOMBARRAGEfinal", humanoidRootPart, true)
			Ouwmit.Emit(vfxUtility.cloneAsset(assets, workspace.Debree, "EmitEnd", v, 4), Ouwmit.Owned(instance, v2))
		end
	end
end