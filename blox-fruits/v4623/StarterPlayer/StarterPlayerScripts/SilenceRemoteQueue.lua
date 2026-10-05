local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remotes = ReplicatedStorage:WaitForChild("Remotes", 2100000000)
local net = ReplicatedStorage:WaitForChild("Modules", 2100000000):WaitForChild("Net", 2100000000)

local function noop() end

remotes:WaitForChild("FX", 2100000000).OnClientEvent:Connect(noop)
net:WaitForChild("RE/PlayAttackStartEffect", 2100000000).OnClientEvent:Connect(noop)
net:WaitForChild("RE/VisualUnequipped", 2100000000).OnClientEvent:Connect(noop)
net:WaitForChild("RE/VisualEquipped", 2100000000).OnClientEvent:Connect(noop)