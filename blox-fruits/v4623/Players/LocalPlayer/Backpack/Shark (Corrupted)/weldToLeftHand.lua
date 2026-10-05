local rootPart = script.Parent:WaitForChild("RootPart", 999)

if rootPart and rootPart:IsDescendantOf(game) then
	local spawnFunction = require(game.ReplicatedStorage.Util.spawnFunction)
	spawnFunction(function()
		local ancestryChangedConnection = nil
		ancestryChangedConnection = script.Parent.AncestryChanged:Connect(function(_, instance)
			if instance and instance:FindFirstChild("LeftHand") then
				rootPart.Part0 = instance:FindFirstChild("LeftHand")
			else
				rootPart.Part0 = nil
			end

			if instance == nil then
				ancestryChangedConnection:Disconnect()
			end
		end)
	end)
end

return {}