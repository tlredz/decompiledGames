local currentCamera = workspace.CurrentCamera

if currentCamera:FindFirstChild("camera_part_anchor_ui") == nil then
	local folder = Instance.new("Folder")
	folder.Name = "camera_part_anchor_ui"
	folder.Parent = currentCamera
end

local modulesByName = {}

for _, moduleScript in pairs(script.Presets:GetChildren()) do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local name = moduleScript.Name
	local module = require(moduleScript)
	modulesByName[name] = module
end

return function(p, ...)
	if modulesByName[p] then
		local _ = modulesByName[p]
	end

	modulesByName[p](...)
end