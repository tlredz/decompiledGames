local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local Ouwmit = require(CAM.Client.Modules.Effects.Ouwmit)
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local DebrisModule = require(CAM.DebrisModule)
local Combat_Swings = require(script.Parent:WaitForChild("Combat_Swings"))
local v = {
	[6] = "Updraft",
	[7] = "DownSlam"
}

local function emit(humanoidRootPart, p: string)
	if humanoidRootPart.Parent == nil then
		return
	end

	local v2 = vfxUtility.cloneAsset(script, workspace.Debree, p, humanoidRootPart.CFrame, 3) or vfxUtility.cloneAsset(
		script,
		workspace.Debree,
		"1",
		humanoidRootPart.CFrame,
		3
	)

	if v2 == nil then
		return
	end

	local raycastResult = workspace:Raycast(
		humanoidRootPart.Position + createVector(0, 5, 0),
		createVector(-0, -15, -0),
		RaycastHelper.Crater
	)
	local v3 = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
	Ouwmit.Emit(v2, Ouwmit.Owned(humanoidRootPart, v3))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playSound(humanoidRootPart)
	local sound = script:FindFirstChildOfClass("Sound")

	if sound == nil then
		return false
	end

	local clone = sound:Clone()
	clone.Parent = humanoidRootPart
	clone:Play()
	DebrisModule:AddItem(clone, clone.TimeLength + 1)
	return true
end

return function(instance, p, p2)
	if instance == nil or p == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil or (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > 100 then
		return
	end

	local v2 = playSound(humanoidRootPart) -- equivalent call inferred; original call site unknown

	if v2 == false then
		Combat_Swings(instance, p, p2)
	end

	if p2 == true and p == 1 then
		task.delay(0.1, emit, humanoidRootPart, "DashHit")
	else
		emit(humanoidRootPart, v[p] or tostring(p))
	end
end