local parent = script.Parent
local module = require(parent)
parent:SetAttribute("Loaded", true)

while parent:GetAttribute("Init") == nil do
	parent:GetAttributeChangedSignal("Init"):Wait()
end

if module.Init then
	local success, result = pcall(module.Init, module)

	if not success then
		task.spawn(error, (`{parent.Name}:Init() - {result}`))
	end
end

parent:SetAttribute("Init", true)

while parent:GetAttribute("Start") == nil do
	parent:GetAttributeChangedSignal("Start"):Wait()
end

if module.Start then
	task.spawn(function()
		debug.setmemorycategory(parent.Name)
		module:Start()
	end)
end

parent:SetAttribute("Start", true)