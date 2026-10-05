local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
local simplesignal = require(ReplicatedStorage.Packages.simplesignal)
local SkillStats = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Subsets"):WaitForChild("Gameplay"):WaitForChild("StatsFetch"):WaitForChild("Modules"):WaitForChild("SkillStats"))
return {
	new = function(player, value: number, list, p: string?)
		local v = false

		if p ~= nil then
			local get = SkillStats.Get
			local v2

			if player ~= nil then
				v2 = player.Character
			end

			local v3 = get(p, v2)
			v = v3 and v3.cancel_bypass ~= nil and true or v
		end

		local v2 = value or 5

		if not player then
			warn("No player provided to module:New")
			return
		end

		local v3 = simplesignal.new()
		local childAddedConnection = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function destroy()
			if childAddedConnection then
				childAddedConnection:Disconnect()
				childAddedConnection = nil
			end

			if v3 then
				v3:DisconnectAll()
				v3:Destroy()
				v3 = nil
			end
		end

		childAddedConnection = Utility.getvaluesfolder(player).ChildAdded:Connect(function(child)
			if v and child:GetAttribute("Counter") ~= true then
				return
			end

			if list ~= nil and table.find(list, child.Name) or list == nil and Utility.Cancel_Values[child.Name] then
				v3:Fire(child.Name)
				destroy() -- equivalent call inferred; original call site unknown
			end
		end)

		if v2 >= 0 then
			task.delay(v2, destroy)
		end

		return v3, destroy
	end
}