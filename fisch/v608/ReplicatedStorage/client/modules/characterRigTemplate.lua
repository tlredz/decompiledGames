local clone = script.TemplateR6:Clone()
clone:PivotTo(CFrame.new(0, 10000, 0))
clone.HumanoidRootPart.Anchored = true
clone.Parent = workspace.VFXDebris
task.spawn(function()
	task.wait(1)
	clone.Humanoid:ApplyDescription(game.Players:GetHumanoidDescriptionFromUserId(game.Players.LocalPlayer.UserId))
	clone:SetAttribute("ready", true)
end)
local CharacterRigTemplate = {
	copy = function()
		return clone:Clone()
	end
}

function CharacterRigTemplate.replace(instance, callback)
	if not clone:GetAttribute("ready") then
		clone:GetAttributeChangedSignal("ready"):Once(function()
			local copy = CharacterRigTemplate.copy()
			copy.Name = instance.Name
			copy.Parent = instance.Parent
			copy:PivotTo(instance:GetPivot())
			instance:Destroy()
			callback(copy)
		end)
		return
	end

	local copy = CharacterRigTemplate.copy()
	copy.Name = instance.Name
	copy.Parent = instance.Parent
	copy:PivotTo(instance:GetPivot())
	instance:Destroy()
	callback(copy)
end

return CharacterRigTemplate