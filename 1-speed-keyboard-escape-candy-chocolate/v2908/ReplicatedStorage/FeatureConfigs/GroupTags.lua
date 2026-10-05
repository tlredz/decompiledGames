local GroupTags = {}

for _, moduleScript in ipairs(script.Configs:GetChildren()) do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local success, result = pcall(require, moduleScript)

	if success and result and result.available ~= false then
		GroupTags[result.key] = result
	end
end

return GroupTags