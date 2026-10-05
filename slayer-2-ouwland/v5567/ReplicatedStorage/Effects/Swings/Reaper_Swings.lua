local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local Cam_Shaker = require(CAM.Client.Modules.Effects.Cam_Shaker)
local Ouwmit = require(CAM.Client.Modules.Effects.Ouwmit)
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local DebrisModule = require(CAM.DebrisModule)
local v = {
	[5] = true,
	[7] = true
}

local function pickSound(p: number)
	local sounds = script:FindFirstChild("Sounds")

	if sounds == nil then
		return nil
	end

	if p == 6 then
		return (sounds:FindFirstChild("PS2reaperSWINGSswing1uptilt"))
	end

	local swings = sounds:FindFirstChild("Swings")

	if swings == nil then
		return nil
	end

	local children = swings:GetChildren()

	if #children == 0 then
		return nil
	end

	table.sort(children, function(a, b)
		return a.Name < b.Name
	end)

	if p == 1 or #children == 1 then
		return children[1]
	end

	return children[(p - 2) % (#children - 1) + 2]
end

return function(instance, p: number?, _: boolean?)
	if instance == nil or p == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil or (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > 100 then
		return
	end

	Cam_Shaker(humanoidRootPart.Position, v[p] and "tinyshake_preset" or "punch_shake")
	local v2 = pickSound(p)

	if v2 ~= nil then
		local clone = v2:Clone()
		clone.Parent = humanoidRootPart
		clone:Play()
		DebrisModule:AddItem(clone, clone.TimeLength + 1)
	end

	local v3 = vfxUtility.cloneAsset(script, workspace.Debree, "m" .. p, humanoidRootPart.CFrame, 3) or vfxUtility.cloneAsset(
		script,
		workspace.Debree,
		"m1",
		humanoidRootPart.CFrame,
		3
	)

	if v3 == nil then
		return
	end

	local raycastResult = workspace:Raycast(
		humanoidRootPart.Position + createVector(0, 5, 0),
		createVector(-0, -15, -0),
		RaycastHelper.Crater
	)
	local v4 = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
	Ouwmit.Emit(v3, Ouwmit.Owned(instance, v4))
end