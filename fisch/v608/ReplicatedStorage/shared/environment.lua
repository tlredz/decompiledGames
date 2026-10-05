game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Environment = {
	target = ({
		[7431162737] = "dev",
		[6756890519] = "staging"
	})[game.GameId] or "prod",
	place = ReplicatedStorage.Place.Value,
	subplaces = {
		sea1 = 0,
		sea2 = 0
	}
}

if Environment.target == "dev" then
	Environment.subplaces.sea1 = 124935812290893
	Environment.subplaces.sea2 = 135499799161875
elseif Environment.target == "qa" then
	Environment.subplaces.sea1 = 131579468225600
	Environment.subplaces.sea2 = 115164489660674
elseif Environment.target == "prod" then
	Environment.subplaces.sea1 = 16732694052
	Environment.subplaces.sea2 = 72907489978215
end

function Environment.loadContent(instance)
	local child = instance:FindFirstChild(Environment.place)
	assert(child, "critical error")
	local legacyScripts = child:FindFirstChild("legacyScripts")

	if legacyScripts then
		for _, child2 in legacyScripts:GetChildren() do
			local v = child2
			task.defer(function()
				v.Enabled = true
			end)
		end
	end

	local initialiseFolder

	initialiseFolder = function(instance2)
		local children = instance2:GetChildren()

		for _, instance3 in children do
			if string.match(instance3.Name, "Component$") and instance3:IsA("ModuleScript") then
				task.spawn(require, instance3)
			elseif instance3:IsA("Folder") then
				initialiseFolder(instance3)
			elseif instance3:IsA("ModuleScript") then
				local v = instance3
				local success, result = pcall(function()
					local module = require(v)

					if typeof(module) ~= "table" then
						warn(v:GetFullName(), "ISNT RETURNING A TABLE!!!")
						return nil
					end

					if typeof(module.init) == "function" then
						task.spawn(module.init)
					elseif typeof(module.Start) == "function" then
						task.spawn(module.Start, module)
					end

					return nil
				end)

				if not success then
					warn((`ENVRIONMENT ERROR: [{instance3.Name}] {result}`))
				end
			end
		end
	end

	initialiseFolder(child)
end

return Environment