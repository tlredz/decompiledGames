local PlayerScripts = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local modules = ReplicatedStorage.Modules
local childrenByName = {}
local count = 0

function Init(p)
	p.ClientInitDone = true
	p.Init()
end

function PlayerScripts.Init()
	PrescanFolder(script)
	ConfigureLoading()
	LoadDatabases()
	Init(PlayerScripts.Events)
	Init(PlayerScripts.Settings)
	Init(PlayerScripts.Interface)
	ScanFolder(script)
end

function PrescanFolder(instance)
	for _, child in pairs(instance:GetChildren()) do
		if child:IsA("ModuleScript") then
			if childrenByName[child.Name] then
				warn("module collision", child.Name)
			end

			childrenByName[child.Name] = child
		elseif child:IsA("Folder") then
			PrescanFolder(child)
		end
	end
end

function ScanFolder(instance)
	for _, child in pairs(instance:GetChildren()) do
		if child:IsA("ModuleScript") and child.Name:sub(1, 1) ~= "_" and rawget(PlayerScripts, child.Name) == nil then
			count += 1
			local v2 = count
			local v3 = child
			task.spawn(function()
				task.wait(5)

				if count == v2 then
					warn("Failed to load client module: " .. v3.Name)
					warn(v3:GetFullName())
				end
			end)
			local v4 = PlayerScripts[child.Name]

			if v4.Init then
				Init(v4)
			end

			count += 1
		elseif child:IsA("Folder") then
			ScanFolder(child)
		elseif rawget(PlayerScripts, child.Name) and PlayerScripts[child.Name].Init and not PlayerScripts[child.Name].ClientInitDone then
			Init(PlayerScripts[child.Name])
		end
	end
end

function LoadDatabases()
	PlayerScripts.Databases = {}

	for _, moduleScript in pairs(game.ReplicatedStorage.Databases:GetChildren()) do
		local databases = PlayerScripts.Databases
		local name = moduleScript.Name
		local module = require(moduleScript)
		databases[name] = module
	end
end

function ConfigureLoading()
	setmetatable(PlayerScripts, {
		__index = function(_, p)
			local v = Import(p)

			if not v then
				return
			end

			PlayerScripts[p] = v
			return v
		end
	})
	PlayerScripts.ServerLoaded = false
	PlayerScripts.ServerLoadedEvent = PlayerScripts.BindableEvent.new()
end

function PlayerScripts.FinishLoading(_)
	if not game.ReplicatedStorage:GetAttribute("ServerLoaded") then
		game.ReplicatedStorage:GetAttributeChangedSignal("ServerLoaded"):Wait()
	end

	PlayerScripts.ServerLoaded = true
	PlayerScripts.ServerLoadedEvent:Fire()
	PlayerScripts.ClientLoaded = true
	PlayerScripts.Events.ClientLoaded:Fire()
	PlayerScripts.Events.ClientLoaded:FireServer()
end

function Import(childName)
	local v = childrenByName[childName]

	if v then
		local module = require(v)
		return module
	end

	if modules:FindFirstChild(childName) then
		return require(modules[childName])
	end
end

return PlayerScripts