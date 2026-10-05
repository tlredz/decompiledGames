local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local CAM = ReplicatedStorage.CAM
local Ouwmit = require(CAM.Client.Modules.Effects.Ouwmit)
local Cam_Shaker = require(CAM.Client.Modules.Effects.Cam_Shaker)
local Combat_Swings = require(script.Parent.Combat_Swings)
local WeaponAuras = require(script.Parent.WeaponAuras)
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local v = {
	anchorParts = {
		["Circle.003"] = true
	},
	skipTrails = true,
	skipSound = true
}
local cframe = CFrame.new(
	-0.02876091,
	0.123809814,
	-1.52137148,
	0.999527872,
	-0.0271155462,
	-0.0147776194,
	0.0236407239,
	0.979749262,
	-0.198837101,
	0.0198708829,
	0.198392391,
	0.979925871
)
local v2 = {
	Flash = function(instance)
		if instance == nil then
			return nil
		end

		local shotgunModel = instance:FindFirstChild("ShotgunModel", true)

		if shotgunModel == nil then
			return nil
		end

		local rightHandle = shotgunModel:FindFirstChild("RightHandle")

		if rightHandle == nil then
			return nil
		end

		local muzzleVFX = shotgunModel:GetAttribute("MuzzleVFX")
		local v3 = (typeof(muzzleVFX) ~= "string" or script:FindFirstChild(muzzleVFX) == nil) and "MuzzleShotVFX" or muzzleVFX
		local clone = script[v3]:Clone()
		clone.Parent = workspace.Debree
		clone:PivotTo(rightHandle.CFrame * cframe)
		Ouwmit.Emit(clone, Ouwmit.Owned(instance))
		DebrisModule:AddItem(clone, 2)
		return rightHandle
	end
}
return (setmetatable(v2, {
	__call = function(_, instance, p: number, flag: boolean)
		if instance == nil then
			return
		end

		WeaponAuras(instance, p, flag, v)

		if p == 6 or p == 7 then
			return Combat_Swings(instance, p, flag)
		end

		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart ~= nil then
			vfxUtility.PlaySound(script.Swing_Sounds, "PS2shotgunM1sSWING" .. p, humanoidRootPart, true)
		end

		task.wait(0.1)
		local flash = v2.Flash(instance)

		if flash ~= nil then
			vfxUtility.PlaySound(script.Explosion_Sounds, "PS2shotgunM1sSWINGexplo" .. p, flash, true)
			Cam_Shaker(flash.Position, "tinyshake_less_aggresive_preset")
		end
	end
}))