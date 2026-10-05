local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Packages.Replion)
require3(script.InventoryTypes)
local v2 = {
	Client = require3(script.Client),
	Server = 0,
	None = 0
}
local server

if script:FindFirstChild("Server") then
	server = require3(script.Server)
end

v2.Server = server
v2.None = v.None
return table.freeze(v2)