local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CAM = ReplicatedStorage.CAM
local assets = script.Assets
local sounds = script:FindFirstChild("Sounds")
local DebrisModule = require(CAM.DebrisModule)
local Cam_Shaker = require(CAM.Client.Modules.Effects.Cam_Shaker)
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local Ouwmit = require(CAM.Client.Modules.Effects.Ouwmit)
local RaycastHelper = require(CAM.Global.RaycastHelper)
return function(instance, p: string, p2, p3)
	if instance == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

	if humanoidRootPart == nil then
		return
	end

	if p == "Windup" then
		vfxUtility.PlaySound(sounds, "PS2warfansWARGALEWINDtwist", humanoidRootPart, true)
	elseif p == "Skill1" then
		local cFrame = humanoidRootPart.CFrame
		Cam_Shaker(cFrame.Position, "activate_shake")
		local raycastResult = workspace:Raycast(
			cFrame.Position + createVector(0, 5, 0),
			createVector(-0, -15, -0),
			RaycastHelper.Crater
		)
		Ouwmit.Emit(
			vfxUtility.cloneAsset(assets, workspace.Debree, "BuddhaComeUp", cFrame, 5),
			Ouwmit.Owned(instance, raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil)
		)
		vfxUtility.PlaySound(sounds, "PS2warfansWARGALEWINDrelease", humanoidRootPart, true)
		local playerFromCharacter = Players:GetPlayerFromCharacter(instance)
		local v = p2 or workspace.Debree.Projectiles:WaitForChild(
			`{playerFromCharacter and playerFromCharacter.Name or instance.Name} War Gale Wind`,
			1
		)

		if v == nil then
			return
		end

		local v2 = typeof(p3) == "CFrame" and p3 or CFrame.identity
		local clone = assets.Tornado:Clone()
		clone.Parent = workspace.Debree
		DebrisModule:AddItem(clone, 8)
		local v3 = v.CFrame * v2
		clone:PivotTo(v3)
		local raycastResult2 = workspace:Raycast(
			v3.Position + createVector(0, 5, 0),
			createVector(-0, -15, -0),
			RaycastHelper.Crater
		)
		local v4 = raycastResult2 and vfxUtility.GetDustColorSettings(raycastResult2.Instance)
		Ouwmit.Enable(clone, true, Ouwmit.Owned(instance, v4))
		local primaryPart = clone.PrimaryPart or clone:FindFirstChildWhichIsA("BasePart", true)
		local v5

		if primaryPart then
			v5 = vfxUtility.PlaySound(sounds, "PS2warfansWARGALEWINDtornadoloop", primaryPart, false)
		else
			v5 = primaryPart
		end

		while clone.Parent ~= nil and v.Parent ~= nil do
			v3 = v.CFrame * v2
			clone:PivotTo(v3)
			task.wait()
		end

		Ouwmit.Enable(clone, false)

		if v5 then
			v5:Stop()
			v5:Destroy()
		end

		Cam_Shaker(v3.Position, "Medium_tiny_shake_preset2")
		local raycastResult3 = workspace:Raycast(
			v3.Position + createVector(0, 5, 0),
			createVector(-0, -15, -0),
			RaycastHelper.Crater
		)
		local emit = Ouwmit.Emit
		local asset = vfxUtility.cloneAsset(assets, workspace.Debree, "Explosion", v3, 5)
		local owned = Ouwmit.Owned

		if raycastResult3 then
			v4 = vfxUtility.GetDustColorSettings(raycastResult3.Instance) or v4
		end

		emit(asset, owned(instance, v4))

		if primaryPart then
			vfxUtility.PlaySound(sounds, "PS2warfansWARGALEWINDstop", primaryPart, true)
		end
	end
end