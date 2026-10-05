local parent = script.Parent.Parent

if not (parent and parent:IsA("Model")) then
	return
end

local remotes = parent:WaitForChild("Remotes", 30)

if not remotes then
	warn("[RVBillboard] Remotes folder never appeared on " .. parent:GetFullName())
	return
end

local AdClient = require(script.Parent:WaitForChild("AdClient"))
AdClient.Init(remotes)
local BillboardController = require(script.Parent:WaitForChild("BillboardController"))
BillboardController.start(parent, AdClient, remotes, false)