local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local assets = script.Assets
local sounds = script:FindFirstChild("Sounds")
local OuwCraters = require(ReplicatedStorage.CAM.Client.Modules.Effects.Craters.OuwCraters)
local Cam_Shaker = require(CAM.Client.Modules.Effects.Cam_Shaker)
local DebrisModule = require(CAM.DebrisModule)
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local Ouwmit = require(CAM.Client.Modules.Effects.Ouwmit)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local v = {
	Startup = "Startup",
	Kick = "Kick",
	Jump = "Jump",
	AirDash = "AirDash",
	Land = "EndSmash"
}
local v2 = {
	Startup = "PS2spearSTORMRUSHandPIERCERinit",
	Kick = "PS2spearSTORMRUSHkick",
	Jump = "PS2spearSTORMRUSHjump",
	AirDash = "PS2spearSTORMRUSHlaunch",
	Land = "PS2spearSTORMRUSHslam"
}

-- equivalent calls inferred from this helper; original call sites unknown
local function findFolder(p)
	return workspace.Debree:FindFirstChild((`{p.Name}-StormRush`))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyFolder(p)
	local folder = findFolder(p) -- equivalent call inferred; original call site unknown

	if folder and folder.Parent then
		Ouwmit.Enable(folder, false)
		folder.Name = "--"
		DebrisModule:AddItem(folder, 1.3)
	end
end

return function(instance, p: string, cframe: CFrame?)
	if instance == nil then
		return
	end

	if p == "Cancel" then
		destroyFolder(instance) -- equivalent call inferred; original call site unknown
	else
		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

		if humanoidRootPart == nil then
			return
		end

		if p == "Barrage" then
			destroyFolder(instance) -- equivalent call inferred; original call site unknown
			local configuration = Instance.new("Configuration")
			configuration.Name = `{instance.Name}-StormRush`
			configuration.Parent = workspace.Debree
			DebrisModule:AddItem(configuration, 4)
			Cam_Shaker(humanoidRootPart.Position, {
				FadeInTime = 0,
				Frequency = 0.15,
				Amplitude = 0.25,
				SustainTime = 0.5,
				FadeOutTime = 0.5,
				RotationInfluence = createVector(0.2, 0.2, 0.2),
				PositionInfluence = createVector(1, 1, 1)
			})
			local asset = vfxUtility.cloneAsset(assets, configuration, "Rush", humanoidRootPart.CFrame, 4)

			if asset then
				local humanoidRootPart2 = asset:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart2 then
					for _, part in asset:GetDescendants() do
						if part:IsA("BasePart") then
							part.Anchored = false
						end
					end

					local weld = Instance.new("Weld")
					weld.Part0 = humanoidRootPart
					weld.Part1 = humanoidRootPart2
					weld.Parent = humanoidRootPart2
				end

				local raycastResult = workspace:Raycast(
					humanoidRootPart.Position + createVector(0, 5, 0),
					createVector(-0, -15, -0),
					RaycastHelper.Crater
				)
				Ouwmit.Enable(
					asset,
					true,
					Ouwmit.Owned(
						instance,
						raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
					)
				)
				local v3 = vfxUtility.PlaySound(
					sounds,
					"PS2spearSTORMRUSHbrrg",
					humanoidRootPart2 or humanoidRootPart,
					false
				)

				if v3 then
					DebrisModule:AddItem(v3, 1)
				end

				task.delay(1, function()
					if workspace.Debree:FindFirstChild((`{instance.Name}-StormRush`)) == configuration then
						destroyFolder(instance) -- equivalent call inferred; original call site unknown
					end
				end)
			end
		else
			local v3 = v[p]

			if v3 == nil then
				return
			end

			local center = cframe or humanoidRootPart.CFrame
			local raycastResult = workspace:Raycast(
				center.Position + createVector(0, 5, 0),
				createVector(-0, -15, -0),
				RaycastHelper.Crater
			)
			local v5 = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil

			if p == "Kick" or p == "AirDash" then
				Cam_Shaker(center.Position, {
					FadeInTime = 0,
					Frequency = 0.15,
					Amplitude = 0.5,
					SustainTime = 0.15,
					FadeOutTime = 0.5,
					RotationInfluence = createVector(0.25, 0.25, 0.25),
					PositionInfluence = createVector(1, 1, 1)
				})
			elseif p == "Land" then
				OuwCraters.Scales({
					Center = center
				})
				Cam_Shaker(center.Position, {
					FadeInTime = 0,
					Frequency = 0.2,
					Amplitude = 2,
					SustainTime = 0.2,
					FadeOutTime = 1,
					RotationInfluence = createVector(0.25, 0.25, 0.25),
					PositionInfluence = createVector(1, 1, 1)
				})
			end

			Ouwmit.Emit(vfxUtility.cloneAsset(assets, workspace.Debree, v3, center, 4), Ouwmit.Owned(instance, v5))
			local v6 = v2[p]

			if v6 then
				vfxUtility.PlaySound(sounds, v6, humanoidRootPart, true)
			end
		end
	end
end