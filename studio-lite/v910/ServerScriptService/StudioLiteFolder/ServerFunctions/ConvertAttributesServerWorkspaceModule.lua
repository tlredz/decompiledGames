local ConvertAttributesServerWorkspaceModule = {}
ConvertAttributesServerWorkspaceModule.__index = ConvertAttributesServerWorkspaceModule

function ConvertAttributesServerWorkspaceModule.Play(_)
	local recurse

	recurse = function(part)
		if part:IsA("BasePart") then
			if part:GetAttribute("SL_AssemblyLinearVelocity") then
				part.AssemblyLinearVelocity = part:GetAttribute("SL_AssemblyLinearVelocity")
			elseif part:GetAttribute("SL_AssemblyAngularVelocity") then
				part.AssemblyAngularVelocity = part:GetAttribute("SL_AssemblyAngularVelocity")
			end
		end

		for _, child in pairs(part:GetChildren()) do
			recurse(child)
		end
	end

	recurse(workspace)
end

return ConvertAttributesServerWorkspaceModule