local currentCamera = workspace.CurrentCamera
local Cam_Shaker = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Modules"):WaitForChild("Effects"):WaitForChild("Cam_Shaker"))
local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local vfxUtility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Modules"):WaitForChild("Effects"):WaitForChild("vfxUtility"))
return function(cFrame: CFrame, p, p2: number?)
	if p then
		cFrame = p.CFrame or cFrame
	end

	if cFrame == nil or (cFrame.Position - currentCamera.CFrame.Position).Magnitude >= 300 then
		return
	end

	local VFX = script.VFX
	local v

	if VFX:IsA("Model") then
		v = p2 or vfxUtility.GetRigEffectScale(p) or nil
	end

	local clone, VFX2

	if v == nil then
		if VFX:IsA("Model") then
			VFX = VFX:FindFirstChild("VFX") or VFX
		end

		clone = VFX:Clone()
		clone.Parent = workspace.Debree
		clone.CFrame = cFrame
		VFX2 = clone
	else
		clone = VFX:Clone()
		clone:ScaleTo(v)
		clone.Parent = workspace.Debree
		clone:PivotTo(cFrame)
		VFX2 = clone:FindFirstChild("VFX") or clone
	end

	vfxUtility.EmitAll(clone)
	DebrisModule:AddItem(clone, 2)
	VFX2.Attachment.Sound:Play()
	Cam_Shaker(cFrame.Position, "tinyshake_preset")
end