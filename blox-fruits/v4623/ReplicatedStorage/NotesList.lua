local NotesList = {}

for _, moduleScript in pairs(script:GetChildren()) do
	local module = require(moduleScript)
	local content = module:sub(1, #module - 1)
	NotesList[moduleScript.Name] = {
		Name = moduleScript.Name,
		Content = content
	}
end

return NotesList