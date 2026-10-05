workspace:WaitForChild("Spawn")

while not workspace:GetAttribute("ClientModulesLoaded") do
	workspace:GetAttributeChangedSignal("ClientModulesLoaded"):Wait()
end

local parentModule = require(script.Parent)
parentModule:Init()