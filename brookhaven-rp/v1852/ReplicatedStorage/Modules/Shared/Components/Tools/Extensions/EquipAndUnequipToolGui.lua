local Players = game:GetService("Players")
return {
	Constructing = function(object)
		local instance = object.Instance
		local toolGui = instance:FindFirstChild("ToolGui")

		if not toolGui then
			return
		end

		local diedConnection = nil
		local mouseButton1ClickConnection = nil
		local v = false

		local function EquipTool()
			local parent = instance.Parent
			local playerFromCharacter = Players:GetPlayerFromCharacter(parent)

			if not playerFromCharacter or v == true and toolGui.Parent == playerFromCharacter.PlayerGui then
				return
			end

			local humanoid = parent:FindFirstChild("Humanoid")

			if diedConnection then
				diedConnection:Disconnect()
			end

			diedConnection = humanoid.Died:Connect(function()
				toolGui.Parent = instance
			end)
			toolGui.Parent = playerFromCharacter.PlayerGui
			v = true
			toolGui.DisplayOrder = 60

			if mouseButton1ClickConnection ~= nil then
				mouseButton1ClickConnection:Disconnect()
				mouseButton1ClickConnection = nil
			end

			mouseButton1ClickConnection = toolGui.Frame.Delete.MouseButton1Click:Connect(function()
				object:UnequipTool(playerFromCharacter)
			end)
		end

		instance.Equipped:Connect(function()
			EquipTool()
		end)

		if instance.Parent and Players:GetPlayerFromCharacter(instance.Parent) then
			EquipTool()
		end

		instance.Unequipped:Connect(function()
			if not instance.Parent then
				v = false
				return
			end

			if diedConnection then
				diedConnection:Disconnect()
				diedConnection = nil
			end

			toolGui.Parent = instance
			v = false

			if mouseButton1ClickConnection then
				mouseButton1ClickConnection:Disconnect()
				mouseButton1ClickConnection = nil
			end
		end)
		instance.Destroying:Connect(function()
			if toolGui.Parent == nil then
				return
			end

			if diedConnection then
				diedConnection:Disconnect()
				diedConnection = nil
			end

			if mouseButton1ClickConnection then
				mouseButton1ClickConnection:Disconnect()
				mouseButton1ClickConnection = nil
			end

			v = false
			toolGui:Destroy()
		end)
	end
}