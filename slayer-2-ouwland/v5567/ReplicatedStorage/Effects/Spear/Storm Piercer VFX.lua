local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local assets = script.Assets
local sounds = script:FindFirstChild("Sounds")
local Cam_Shaker = require(CAM.Client.Modules.Effects.Cam_Shaker)
local DebrisModule = require(CAM.DebrisModule)
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local Ouwmit = require(CAM.Client.Modules.Effects.Ouwmit)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local Config = require(ReplicatedStorage.Skills.Spear["Storm Piercer"].Config)
local v = {
	Startup = "PS2spearSTORMRUSHandPIERCERinit",
	Dash = "PS2spearSTORMPIERCERlaunch",
	Hit = "PS2spearSTORMPIERCERconnect"
}

-- equivalent calls inferred from this helper; original call sites unknown
local function findFolder(instance)
	return workspace.Debree:FindFirstChild((`{instance.Name}-StormPiercer`))
end

local function destroyFolder(instance, p)
	local folder = findFolder(instance) -- equivalent call inferred; original call site unknown
	local v2 = p or folder

	if v2 and v2.Parent then
		vfxUtility.EnableAll(v2, false)
		v2.Name = "--"
		DebrisModule:AddItem(v2, 1)
	end

	if v2 ~= nil and folder ~= nil and v2 ~= folder then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	local rigHumAttach = humanoidRootPart and humanoidRootPart:FindFirstChild("RigHumAttach")

	if rigHumAttach then
		rigHumAttach:Destroy()
	end
end

return function(instance, p: string, cframe: CFrame?)
	if instance == nil then
		return
	end

	if p == "Cancel" or p == "Miss" then
		destroyFolder(instance)
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

	if humanoidRootPart == nil then
		return
	end

	if p == "Loop" then
		local rigHumAttach = humanoidRootPart:FindFirstChild("RigHumAttach")

		if rigHumAttach then
			rigHumAttach:Destroy()
		end

		destroyFolder(instance)
		local configuration = Instance.new("Configuration")
		configuration.Name = `{instance.Name}-StormPiercer`
		configuration.Parent = workspace.Debree
		DebrisModule:AddItem(configuration, 7)
		local asset = vfxUtility.cloneAsset(assets, configuration, "SpearLoop", humanoidRootPart.CFrame, 7)

		if asset then
			local humanoidRootPart2 = asset:FindFirstChild("HumanoidRootPart")
			local rootRigAttachment = humanoidRootPart2 and humanoidRootPart2:FindFirstChild("RootRigAttachment")
			local rigidConstraint = rootRigAttachment and rootRigAttachment:FindFirstChild("RigidConstraint")
			local rigHumAttach2 = rootRigAttachment and rootRigAttachment:FindFirstChild("RigHumAttach")

			if rigidConstraint and rigHumAttach2 then
				rigHumAttach2.Parent = humanoidRootPart
				rigidConstraint.Attachment1 = rigHumAttach2
			end

			local raycastResult = workspace:Raycast(
				humanoidRootPart.Position + createVector(0, 5, 0),
				createVector(-0, -15, -0),
				RaycastHelper.Crater
			)
			vfxUtility.EnableAll(
				asset,
				true,
				vfxUtility.Owned(
					instance,
					raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
				)
			)
		end
	else
		local v2 = cframe or humanoidRootPart.CFrame
		local raycastResult = workspace:Raycast(
			v2.Position + createVector(0, 5, 0),
			createVector(-0, -15, -0),
			RaycastHelper.Crater
		)
		local v3 = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
		local v4 = v[p]

		if v4 then
			vfxUtility.PlaySound(sounds, v4, humanoidRootPart, true)
		end

		if p == "Startup" then
			Ouwmit.Emit(vfxUtility.cloneAsset(assets, workspace.Debree, "Startup", v2, 4), Ouwmit.Owned(instance, v3))
		elseif p == "Dash" then
			Ouwmit.Emit(vfxUtility.cloneAsset(assets, workspace.Debree, "Dash", v2, 4), Ouwmit.Owned(instance, v3))
		elseif p == "Hit" then
			Cam_Shaker(v2.Position, "activate_shake")
			Ouwmit.Emit(vfxUtility.cloneAsset(assets, workspace.Debree, "Hit", v2, 4), Ouwmit.Owned(instance, v3))
			local folder = findFolder(instance) -- equivalent call inferred; original call site unknown
			task.delay(Config.SLAM_AT, function()
				if folder ~= nil and folder ~= workspace.Debree:FindFirstChild((`{instance.Name}-StormPiercer`)) then
					return
				end

				destroyFolder(instance, folder)
				local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart2 == nil then
					return
				end

				local raycastResult2 = workspace:Raycast(
					humanoidRootPart2.Position + createVector(0, 5, 0),
					createVector(-0, -15, -0),
					RaycastHelper.Crater
				)
				local v5 = raycastResult2 and vfxUtility.GetDustColorSettings(raycastResult2.Instance) or nil
				Ouwmit.Emit(
					vfxUtility.cloneAsset(assets, workspace.Debree, "Ending", humanoidRootPart2.CFrame, 5),
					Ouwmit.Owned(instance, v5)
				)
			end)
		end
	end
end