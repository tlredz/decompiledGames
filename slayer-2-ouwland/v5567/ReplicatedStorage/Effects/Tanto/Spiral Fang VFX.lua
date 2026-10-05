local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local assets = script.Assets
local Cam_Shaker = require(CAM.Client.Modules.Effects.Cam_Shaker)
local DebrisModule = require(CAM.DebrisModule)
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local Ouwmit = require(CAM.Client.Modules.Effects.Ouwmit)
local RaycastHelper = require(CAM.Global.RaycastHelper)

local function teardownRig(instance)
	local child = workspace.Debree:FindFirstChild((`{instance.Name}-SpiralFangAura`))

	if child and child.Parent then
		Ouwmit.Enable(child, false)
		vfxUtility.DisableAll(child)
		child.Name = "--"
		DebrisModule:AddItem(child, 1.3)
	end
end

return function(instance, p: string, cframe: CFrame?)
	if instance == nil then
		return
	end

	if p == "Cancel" then
		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

		if humanoidRootPart then
			vfxUtility.PlaySound(script.Sounds, "PS2tantoSPIRALFANGstop", humanoidRootPart, true)
		end

		teardownRig(instance)
	else
		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

		if humanoidRootPart == nil then
			return
		end

		if p == "Start" then
			teardownRig(instance)
			local v = cframe or humanoidRootPart.CFrame
			local raycastResult = workspace:Raycast(
				v.Position + createVector(0, 5, 0),
				createVector(-0, -15, -0),
				RaycastHelper.Crater
			)
			local v2 = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
			local asset = vfxUtility.cloneAsset(assets, workspace.Debree, "Barrage", v, 4)

			if asset == nil then
				return
			end

			local formatted = `{instance.Name}-SpiralFangAura`
			asset.Name = formatted
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

			Ouwmit.Enable(asset, true, Ouwmit.Owned(instance, v2))
			vfxUtility.PlaySound(script.Sounds, "PS2tantoSPIRALFANGinit", humanoidRootPart, true)
			vfxUtility.PlaySound(script.Sounds, "PS2tantoSPIRALFANGloop", root or humanoidRootPart, root == nil)
			local cam_Shaker = Cam_Shaker(humanoidRootPart, {
				FadeInTime = 0.1,
				Frequency = 0.2,
				Amplitude = 0.35,
				SustainTime = 2,
				FadeOutTime = 0.5,
				RotationInfluence = createVector(0.25, 0.25, 0.25),
				PositionInfluence = createVector(1, 1, 1)
			})

			while asset.Parent ~= nil and asset.Name == formatted do
				task.wait(0.1)
			end

			cam_Shaker:Destroy()
		end
	end
end