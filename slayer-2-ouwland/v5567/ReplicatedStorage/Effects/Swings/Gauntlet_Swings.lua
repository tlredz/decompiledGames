local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local Ouwmit = require(CAM.Client.Modules.Effects.Ouwmit)
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local RaycastHelper = require(CAM.Global.RaycastHelper)
script:WaitForChild("m5")
script.m5:WaitForChild("Impact")
Ouwmit.Preload(
	script.m5.Impact.Dash.Windbeams.Part.WindBeams.ASide.Beam,
	script.m5.Impact.Dash.Windbeams.Part.WindBeams.BSide.Beam
)
local DebrisModule = require(CAM.DebrisModule)
local WeaponAuras = require(script.Parent:WaitForChild("WeaponAuras"))
local v = {
	anchorParts = {
		RightForearm = true,
		LeftForearm = true,
		Forearm = true,
		["Meshes/Gauntlet_Dummy15.001 (4)"] = true,
		["Meshes/Gauntlet_Dummy15.003"] = true
	},
	skipTrails = true,
	skipSound = true
}

local function playSound(humanoidRootPart, p: number)
	local sounds = script:FindFirstChild("Sounds")

	if sounds == nil then
		return
	end

	local pS2gauntletswingsUPTILT = nil

	if p == 6 then
		pS2gauntletswingsUPTILT = sounds:FindFirstChild("PS2gauntletswingsUPTILT")
	else
		local swings = sounds:FindFirstChild("Swings")
		local v2 = swings == nil and {} or swings:GetChildren()

		if #v2 > 0 then
			table.sort(v2, function(a, b)
				return a.Name < b.Name
			end)

			if p == 1 or #v2 == 1 then
				pS2gauntletswingsUPTILT = v2[1]
			else
				pS2gauntletswingsUPTILT = v2[(p - 2) % (#v2 - 1) + 2]
			end
		end
	end

	if pS2gauntletswingsUPTILT == nil then
		return
	end

	local clone = pS2gauntletswingsUPTILT:Clone()
	clone.Parent = humanoidRootPart
	clone:Play()
	DebrisModule:AddItem(clone, clone.TimeLength + 1)
end

local function emit(humanoidRootPart, p: string)
	if humanoidRootPart.Parent == nil then
		return
	end

	local asset = vfxUtility.cloneAsset(script, workspace.Debree, p, humanoidRootPart.CFrame, 3)

	if not asset then
		if p == "m-1" then
			asset = nil
		else
			asset = vfxUtility.cloneAsset(script, workspace.Debree, "m1", humanoidRootPart.CFrame, 3) or nil
		end
	end

	if asset == nil then
		return
	end

	local raycastResult = workspace:Raycast(
		humanoidRootPart.Position + createVector(0, 5, 0),
		createVector(-0, -15, -0),
		RaycastHelper.Crater
	)
	local v2 = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
	Ouwmit.Emit(asset, Ouwmit.Owned(humanoidRootPart, v2))
end

return function(instance, p, p2)
	if instance == nil or p == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil or (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > 100 then
		return
	end

	playSound(humanoidRootPart, p)
	WeaponAuras(instance, p, p2, v)

	if p2 == true and p == 1 then
		task.delay(0.2, emit, humanoidRootPart, "m-1")
	else
		emit(humanoidRootPart, "m" .. p)
	end
end