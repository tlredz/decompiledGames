local ReplicatedStorage = game:GetService("ReplicatedStorage")
local studioLiteFolder = ReplicatedStorage:WaitForChild("StudioLiteFolder")
local loadAssetModelToPlayerGuiServerFunction = studioLiteFolder:WaitForChild("LoadAssetModelToPlayerGuiServerFunction")
local clearAssetModelToPlayerGuiServerFunction = studioLiteFolder:WaitForChild("ClearAssetModelToPlayerGuiServerFunction")
local setSelection = game.Players.LocalPlayer.PlayerGui.StudioGui:WaitForChild("ExplorerPanel"):WaitForChild("SetSelection")
local v = nil
script.Parent.Activated:Connect(function()
	if not loadAssetModelToPlayerGuiServerFunction:InvokeServer(156280871985) then
		warn("Asset not found or not in your inventory:", 156280871985)
		return
	end

	local clone = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild((tostring(156280871985))):FindFirstChildOfClass("Model"):Clone()

	if clone:IsA("Model") then
		clone.Parent = workspace
		local boundingBox, v2 = clone:GetBoundingBox()
		local v3 = not clone.PrimaryPart and 0 or clone.PrimaryPart.Position.Y - boundingBox.Position.Y
		local cFrame = workspace.Camera.CFrame
		local vector = Vector3.new(
			math.floor((cFrame.X + cFrame.lookVector.X * 30) * 2) / 2,
			v2.Y / 2 + v3,
			math.floor((cFrame.Z + cFrame.lookVector.Z * 30) * 2) / 2
		)
		local raycastResult = workspace:Raycast(
			Vector3.new(vector.X, cFrame.Y, vector.Z),
			(Vector3.new(0, -cFrame.Y, 0))
		)

		if raycastResult then
			vector = Vector3.new(
				vector.X,
				raycastResult.Instance.Position.Y + raycastResult.Instance.Size.Y / 2 + v2.Y / 2 + v3,
				vector.Z
			)
		end

		clone:PivotTo(CFrame.new(vector) * boundingBox.Rotation)
		v = nil

		for _, postEffect in pairs(clone:GetChildren()) do
			v = postEffect

			if postEffect:IsA("PostEffect") or postEffect.ClassName == "Sky" then
				postEffect.Parent = game.Lighting
			else
				postEffect.Parent = workspace
			end
		end

		clone:Destroy()
	else
		clone.Parent = workspace
	end

	task.wait(0.2)

	if clone then
		setSelection:Invoke({ clone })
	else
		print(v:GetFullName())
		setSelection:Invoke({ v })
	end

	clearAssetModelToPlayerGuiServerFunction:InvokeServer(clone)
end)