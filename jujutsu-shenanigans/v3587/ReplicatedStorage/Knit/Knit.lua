local RunService = game:GetService("RunService")

if RunService:IsServer() then
	return require(script.KnitServer)
end

local knitServer = script:FindFirstChild("KnitServer")

if knitServer and RunService:IsRunning() then
	knitServer:Destroy()
end

return require(script.KnitClient)