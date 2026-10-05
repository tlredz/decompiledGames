local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local Util = require(game.ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local debris = Util.Debris
return function(p)
	local cFrame = p.CFrame

	if (workspace.CurrentCamera.CFrame.Position - cFrame.Position).Magnitude > 1000 then
		return
	end

	local clone = script.EffectPart:Clone()
	debris:AddItem(clone, 5)
	clone.CFrame = cFrame
	clone.Parent = _WorldOrigin
	local descendants = clone.Attachment:GetDescendants()

	for _, descendant in descendants do
		descendant:Emit(descendant:GetAttribute("EmitCount") or 1)
	end
end