while not workspace:GetAttribute("ClientModulesLoaded") do
	workspace:GetAttributeChangedSignal("ClientModulesLoaded"):Wait()
end

local parentModule = require(script.Parent)
local Players = game:GetService("Players")

if Players:WaitForChild("Oseday", 120) then
	assert(parentModule:GetKey("TestKey") == "working", "Client FFlag test failed")
	print("Client FFlag test passed")
end