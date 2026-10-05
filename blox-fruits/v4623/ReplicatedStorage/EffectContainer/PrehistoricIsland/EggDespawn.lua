local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
require(ReplicatedStorage:WaitForChild("Effect"))
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

	for _, descendant in ipairs(descendants) do
		descendant:Emit(descendant:GetAttribute("EmitCount") or 1)
	end
end