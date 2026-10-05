local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local Ouwmit = require(CAM.Client.Modules.Effects.Ouwmit)
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local assets = script.Assets
local debree = workspace.Debree
return function(cframe: CFrame?)
	if typeof(cframe) ~= "CFrame" or (cframe.Position - workspace.CurrentCamera.CFrame.Position).Magnitude >= 250 then
		return
	end

	local raycastResult = workspace:Raycast(
		cframe.Position + createVector(0, 3, 0),
		createVector(0, -40, 0),
		RaycastHelper.Crater
	)
	local v = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance)
	local v2 = cframe * assets.YetiVFX.Berg.CFrame:ToObjectSpace(assets.YetiVFX:GetPivot())
	local asset = vfxUtility.cloneAsset(assets, debree, "YetiVFX", v2, 10)

	if asset == nil then
		return
	end

	local berg = asset.Berg
	local clone = script.Sounds.YetiIceExplosion:Clone()
	clone.Parent = berg
	clone:Play()
	Ouwmit.Emit(asset, v)
	task.delay(0.5, function()
		if berg.Parent == nil then
			return
		end

		local clone2 = script.Sounds.YetiRoar:Clone()
		clone2.Parent = berg
		clone2:Play()
	end)
end