local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GlobalUtil = require(ReplicatedStorage:WaitForChild("GlobalUtil"))
local Director = require(ReplicatedStorage:WaitForChild("Director"))

if GlobalUtil.FFlags.IsUnitTest == true then
	return
end

local directorComponents = ReplicatedStorage:WaitForChild("DirectorComponents")
local v = {}

local function handleComponent(moduleScript)
	if v[moduleScript] then
		return
	end

	v[moduleScript] = true

	if moduleScript:IsA("ModuleScript") then
		local module = require(moduleScript)
		Director.Register(moduleScript, module.new, module.ancestor)
	end
end

directorComponents.DescendantAdded:Connect(handleComponent)

for _, descendant in directorComponents:GetDescendants() do
	task.spawn(handleComponent, descendant)
end