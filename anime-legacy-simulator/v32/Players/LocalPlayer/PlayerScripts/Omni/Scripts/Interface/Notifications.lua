require("@game/ReplicatedStorage/Omni")
local modulesByName = {}
local flag = false
local Notifications = {}

function Notifications.Create(value, p)
	if not (typeof(value) == "string" and typeof(p) == "table") then
		return
	end

	if not flag then
		Notifications.Init()
	end

	local v = modulesByName[value]

	if not v then
		return
	end

	v.Create(p)
end

function Notifications.Destroy()
	for _, v in modulesByName do
		if v.Destroy then
			v.Destroy()
		end
	end

	table.clear(modulesByName)
	flag = false
end

function Notifications.Init()
	if flag then
		return
	end

	flag = true

	for _, moduleScript in script:GetChildren() do
		if not moduleScript:IsA("ModuleScript") then
			continue
		end

		local module = require(moduleScript)

		if not module.Create then
			continue
		end

		modulesByName[moduleScript.Name] = module

		if module.Init then
			module.Init()
		end
	end
end

return Notifications