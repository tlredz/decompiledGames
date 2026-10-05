local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local assets = script.Assets
local sounds = script:FindFirstChild("Sounds")
local DebrisModule = require(CAM.DebrisModule)
local OuwCraters = require(ReplicatedStorage.CAM.Client.Modules.Effects.Craters.OuwCraters)
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local Ouwmit = require(CAM.Client.Modules.Effects.Ouwmit)
local Cam_Shaker = require(CAM.Client.Modules.Effects.Cam_Shaker)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local Config = require(ReplicatedStorage.Skills.Soryu["Face Breaker"].Config)

-- equivalent calls inferred from this helper; original call sites unknown
local function teardownDashWind(instance)
	local child = workspace.Debree:FindFirstChild((`{instance.Name}-FaceBreakerDashWind`))

	if child and child.Parent then
		vfxUtility.EnableAll(child, false)
		child.Name = "--"
		DebrisModule:AddItem(child, 1)
	end
end

return function(instance, p: string, instance2, p2)
	if instance == nil then
		return
	end

	teardownDashWind(instance) -- equivalent call inferred; original call site unknown

	if p == "Cancel" then
		instance:SetAttribute("FaceBreakerCancelledAt", os.clock())
	elseif p == "Start" then
		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

		if humanoidRootPart == nil then
			return
		end

		local now = os.clock()
		task.wait(Config.STARTUP)
		local faceBreakerCancelledAt = instance:GetAttribute("FaceBreakerCancelledAt")

		if faceBreakerCancelledAt ~= nil and now <= faceBreakerCancelledAt then
			return
		end

		local asset = vfxUtility.cloneAsset(assets, workspace.Debree, "DashWind", humanoidRootPart.CFrame, 5)

		if asset then
			asset.Name = `{instance.Name}-FaceBreakerDashWind`
			local root = asset:FindFirstChild("Root")

			if root then
				for _, v in asset:QueryDescendants("Weld") do
					local part1 = v.Part1

					if not (part1 and (part1:GetAttribute("PartDistance") ~= nil or part1:GetAttribute("PartScale") ~= nil)) then
						continue
					end

					v:Destroy()
				end

				for _, v in asset:QueryDescendants("BasePart") do
					if v:GetAttribute("PartDistance") == nil and v:GetAttribute("PartScale") == nil then
						v.Anchored = false
					else
						v.Anchored = true
					end
				end

				local weld = Instance.new("Weld")
				weld.Part0 = humanoidRootPart
				weld.Part1 = root
				weld.Parent = root
			end

			local raycastResult = workspace:Raycast(
				humanoidRootPart.Position + createVector(0, 5, 0),
				createVector(-0, -15, -0),
				RaycastHelper.Crater
			)
			Ouwmit.Emit(
				asset,
				Ouwmit.Owned(instance, raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil)
			)
			vfxUtility.PlaySound(sounds, "PS2soryuFACEBREAKERdash", root or humanoidRootPart, true)
		end
	elseif p == "Grab" then
		if instance2 == nil or p2 == nil then
			return
		end

		local head = instance2:FindFirstChild("Head")
		local raycastResult = workspace:Raycast(
			p2.Position + createVector(0, 5, 0),
			createVector(-0, -15, -0),
			RaycastHelper.Crater
		)
		local v = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
		Ouwmit.Emit(
			vfxUtility.cloneAsset(assets, workspace.Debree, "Wind", p2 * CFrame.new(0, 0, -2), 5),
			Ouwmit.Owned(instance, v)
		)

		if head then
			Ouwmit.Emit(vfxUtility.cloneAsset(assets, head, "FaceGrab", nil, 5), Ouwmit.Owned(instance, v))
		end

		Cam_Shaker(p2.Position, "activate_shakelessaggresive")
		task.wait(Config.SLAM_AT - 0.725)
		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

		if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
			vfxUtility.PlaySound(sounds, "PS2soryuFACEBREAKERconnect", humanoidRootPart, true)
		end

		task.wait(0.22499999999999998)
		Ouwmit.Emit(
			vfxUtility.cloneAsset(assets, workspace.Debree, "Charge", p2 * CFrame.new(0, 0, -2), 5),
			Ouwmit.Owned(instance, v)
		)
	elseif p == "Slam" then
		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

		if humanoidRootPart == nil then
			return
		end

		local v = p2 or humanoidRootPart.CFrame
		local v2 = v * CFrame.new(0, 0, -2.5)
		local raycastResult = workspace:Raycast(
			v2.Position + createVector(0, 5, 0),
			createVector(-0, -15, -0),
			RaycastHelper.Crater
		)
		local v3

		if raycastResult then
			v3 = vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
		end

		local v4 = CFrame.lookAt(v.Position, v.Position + v.LookVector * 5 - createVector(0, 5, 0)) * CFrame.new(
			0,
			0,
			-4.5
		)
		Ouwmit.Emit(vfxUtility.cloneAsset(assets, workspace.Debree, "Slam", v4, 5), Ouwmit.Owned(instance, v3))
		task.wait(0.1)
		Ouwmit.Emit(vfxUtility.cloneAsset(assets, workspace.Debree, "HitGround", v2, 5), Ouwmit.Owned(instance, v3))
		Cam_Shaker(v.Position, "medium_shake_preset")

		if raycastResult then
			OuwCraters.Scales({
				Center = CFrame.new(raycastResult.Position),
				Radius = 7,
				Count = 9,
				ScaleMult = 0.6,
				OffsetMargin = 3
			})
		end
	end
end