local gameSettings = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("gameSettings"))
local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local Utility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
local vfxUtility = require(game.ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local v = {
	[5] = 2
}
return function(parent, p, parent2)
	local v2 = p == nil and 1 or p

	if parent ~= nil and v2 ~= nil and (workspace.CurrentCamera.CFrame.Position - parent.Position).Magnitude <= 200 then
		local clone = script.PunchEffect.Attachment:Clone()
		local cFrame = clone.CFrame
		local identity = CFrame.identity

		if parent2 == nil or parent2.Parent == nil or not Utility.IsMeshRig(parent.Parent) then
			clone.Parent = parent
		else
			clone.Parent = parent2
			identity = CFrame.new(0, 0, gameSettings.rigHitEffectOffset)
		end

		clone.CFrame = identity * cFrame * CFrame.Angles(0, 0, math.random(-10, 10) / 10 * 3.141592653589793)
		DebrisModule:AddItem(clone, 0.8)

		if v[v2] then
			clone.SHardLongFlipbook:SetAttribute("EmitCount", v[v2])
		end

		vfxUtility.EmitAll(clone, vfxUtility.Owned(parent))
		local sounds = script:FindFirstChild("Sounds")
		local v3 = sounds == nil and {} or sounds:GetChildren() or {}

		if #v3 > 0 then
			local clone2 = v3[math.random(1, #v3)]:Clone()
			clone2.Parent = parent
			clone2:Play()
			DebrisModule:AddItem(clone2, clone2.TimeLength)
		end

		Utility.Damagehighlight(parent, v2)
	end
end