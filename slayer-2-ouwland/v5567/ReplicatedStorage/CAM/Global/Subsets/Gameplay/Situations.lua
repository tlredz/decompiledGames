local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local isServer = RunService:IsServer()
local Situations = {
	Loaded = {}
}
local situations = ReplicatedStorage:FindFirstChild("Situations")

if situations then
	for _, child in situations:GetChildren() do
		local moduleScript = child:FindFirstChild(isServer and child.Name .. "Server" or child.Name)

		if not (moduleScript ~= nil and moduleScript:IsA("ModuleScript")) then
			continue
		end

		local loaded = Situations.Loaded
		local name = child.Name
		local module = require(moduleScript)
		loaded[name] = module
	end
end

function Situations.Swap(p, p2: string?, p3: string?)
	if p2 == p3 then
		return
	end

	local v

	if p2 ~= nil then
		v = Situations.Loaded[p2] or nil
	end

	if v ~= nil and v.End ~= nil then
		task.spawn(v.End, p)
	end

	local v2

	if p3 ~= nil then
		v2 = Situations.Loaded[p3] or nil
	end

	if v2 ~= nil and v2.Start ~= nil then
		task.spawn(v2.Start, p)
	end
end

return Situations