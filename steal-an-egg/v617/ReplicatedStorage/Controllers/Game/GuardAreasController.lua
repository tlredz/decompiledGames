local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local ForestGuardRuntime = require(script.ForestGuardRuntime)
local GuardComponent = require(script.GuardComponent)
local GuardEscapeSignController = require(script.GuardEscapeSignController)
local GuardTutorialController = require(script.GuardTutorialController)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Promise = require(ReplicatedStorage.Packages.Promise)
local v = {}
local v2 = {}
local v3 = {}
return {
	Start = function()
		local v4 = GuardTutorialController.new()
		task.spawn(function()
			v4:Start()
		end)
		local v5 = true
		local v6 = -1
		local world = Workspace:WaitForChild("World")
		assert(world:IsA("Folder"), "Workspace.World must be a Folder")
		local areas = world:WaitForChild("Areas")
		assert(areas:IsA("Folder"), "Workspace.World.Areas must be a Folder")
		local guardAreas = areas:WaitForChild("GuardAreas")
		assert(guardAreas:IsA("Folder"), "Workspace.World.Areas.GuardAreas must be a Folder")

		local function applyGuardsEnabled(flag: boolean, p: number)
			if p < v6 then
				return
			end

			v5 = flag
			v6 = p

			for _, v7 in pairs(v2) do
				if v7 ~= nil and v7.ForestRuntime ~= nil then
					v7.ForestRuntime:SetEnabled(flag)
				end
			end
		end

		local function setupAreaModel(model)
			if v[model] == nil then
				v[model] = GuardEscapeSignController.new(model)
			end

			if v2[model] ~= nil then
				return
			end

			local forestRuntime = nil
			local guard

			if model.Name == "Forest" then
				forestRuntime = ForestGuardRuntime.new(model)
				guard = GuardComponent.new(model)
				forestRuntime:SetWakeHandler(function(_)
					guard:PlayWakeUp()
				end)
			else
				guard = GuardComponent.new(model)
			end

			if model.Parent == guardAreas then
				v2[model] = {
					ForestRuntime = forestRuntime,
					Guard = guard
				}
				v3[guard:GetGuardModel()] = guard

				if forestRuntime ~= nil then
					forestRuntime:SetEnabled(v5)
					forestRuntime:Start()
				end
			else
				guard:Destroy()

				if forestRuntime ~= nil then
					forestRuntime:Destroy()
				end
			end
		end

		local function cleanupAreaModel(model)
			local v7 = v[model]

			if v7 ~= nil then
				v[model] = nil
				v7:Destroy()
			end

			local v8 = v2[model]

			if v8 == nil then
				return
			end

			v2[model] = nil
			v3[v8.Guard:GetGuardModel()] = nil
			v8.Guard:Destroy()

			if v8.ForestRuntime ~= nil then
				v8.ForestRuntime:Destroy()
			end
		end

		guardAreas.ChildAdded:Connect(function(model)
			assert(model:IsA("Model"), (`{model:GetFullName()} must be a guard area Model`))
			setupAreaModel(model)
		end)
		guardAreas.ChildRemoved:Connect(function(model)
			assert(model:IsA("Model"), (`{model:GetFullName()} must be a guard area Model`))
			cleanupAreaModel(model)
		end)

		for _, model in ipairs(guardAreas:GetChildren()) do
			assert(model:IsA("Model"), (`{model:GetFullName()} must be a guard area Model`))
			task.spawn(setupAreaModel, model)
		end

		Remotes.GuardPatrol.Rouse.OnClientEvent:Connect(function(p)
			local v7 = v3[p]

			if v7 == nil then
				return
			end

			v7:PlayWakeUp()
		end)
		Remotes.GuardPatrol.EnabledShifted.OnClientEvent:Connect(applyGuardsEnabled)
		task.spawn(function()
			while v6 < 0 do
				local v7, v8, v9 = Promise.try(function()
					return Remotes.GuardPatrol.AskEnabled:InvokeServer()
				end):timeout(30):await()

				if v7 and typeof(v8) == "boolean" and typeof(v9) == "number" then
					applyGuardsEnabled(v8, v9)
					break
				else
					task.wait(1)
				end
			end
		end)
	end
}