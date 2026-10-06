local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local isClient = RunService:IsClient()

local function observeLocalCharacter(callback)
	assert(isClient, "observeLocalCharacter can only be called from the client")
	local v = nil
	local v2 = true

	local function onCharacterAdded(instance)
		local v3 = nil
		local ancestryChangedConnection = nil
		ancestryChangedConnection = instance.AncestryChanged:Connect(function(_, parent)
			if parent == nil and ancestryChangedConnection.Connected then
				ancestryChangedConnection:Disconnect()

				if typeof(v3) == "function" and v2 then
					task.spawn(v3)

					if v == v3 then
						v = nil
					end
				end
			end
		end)
		v3 = callback(instance)

		if typeof(v3) == "function" then
			if ancestryChangedConnection.Connected then
				v = v3
			else
				task.spawn(v3)
			end
		end
	end

	local characterAddedConnection = Players.LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

	if Players.LocalPlayer.Character ~= nil then
		task.spawn(onCharacterAdded, Players.LocalPlayer.Character)
	end

	return function()
		v2 = false
		characterAddedConnection:Disconnect()

		if typeof(v) == "function" then
			task.spawn(v)
			v = nil
		end
	end
end

return observeLocalCharacter