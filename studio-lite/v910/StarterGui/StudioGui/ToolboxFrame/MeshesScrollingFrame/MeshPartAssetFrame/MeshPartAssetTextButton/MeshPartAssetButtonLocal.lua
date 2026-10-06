local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local getMeshInfoServerFunction = ReplicatedStorage:WaitForChild("StudioLiteFolder"):WaitForChild("GetMeshInfoServerFunction")
local setSelection = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("StudioGui", 9):WaitForChild("ExplorerPanel"):WaitForChild("SetSelection")
local AssetService = game:GetService("AssetService")
local name = ""
local v2 = ""
local textureID = ""
local v4 = ""
local flag = true
local studioGui = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("StudioGui")
local v5 = false
local workingImageLabel1 = studioGui:WaitForChild("WorkingImageLabel1")
local workingImageLabel2 = studioGui:WaitForChild("WorkingImageLabel2")

function WorkingWaiting()
	spawn(function()
		v5 = true

		for _ = 1, 100 do
			if not v5 then
				break
			end

			if workingImageLabel1.Visible then
				workingImageLabel1.Visible = false
				workingImageLabel2.Visible = true
			else
				workingImageLabel1.Visible = true
				workingImageLabel2.Visible = false
			end

			task.wait(0.1)
		end

		v5 = false
		workingImageLabel1.Visible = false
		workingImageLabel2.Visible = false
	end)
end

script.Parent.Activated:Connect(function()
	if flag then
		flag = false
		script.Parent.Text = "working"
		WorkingWaiting()
		local match = script.Parent.Parent.MeshPartAssetTextBox.Text:match("%d+")

		if match and tonumber(match) > 999 then
			name, v2, textureID, v4 = getMeshInfoServerFunction:InvokeServer(match)
			local v6 = nil
			local success, _ = pcall(function()
				if v2:find("://", 2, true) then
					v6 = AssetService:CreateMeshPartAsync(Content.fromUri(v2))
					return
				end

				v2 = "rbxassetid://" .. match
				name = "MeshPart"
				v6 = AssetService:CreateMeshPartAsync(Content.fromUri(v2))
				v6.Size = createVector(10, 10, 10)
			end)

			if success then
				v6.Name = name
				v6.Anchored = true
				v6.CanCollide = false
				v6.TextureID = textureID
				v6.Parent = workspace
				v6:SetAttribute("SL_Anchored", true)
				v6:SetAttribute("SL_CanCollide", true)
				local cFrame = workspace.CurrentCamera.CFrame
				local v7 = math.floor((cFrame.X + cFrame.lookVector.X * 30) * 2) / 2
				local v8 = v6.Size.Y / 2
				local vector2 = Vector3.new(v7, v8, math.floor((cFrame.Z + cFrame.lookVector.Z * 30) * 2) / 2)
				local raycastResult = workspace:Raycast(
					Vector3.new(vector2.X, cFrame.Y, vector2.Z),
					(Vector3.new(0, -cFrame.Y, 0))
				)

				if raycastResult then
					local X = vector2.X
					local v9 = raycastResult.Instance.Position.Y + raycastResult.Instance.Size.Y / 2 + v6.Size.Y / 2
					vector2 = Vector3.new(X, v9, vector2.Z)
				end

				v6.Position = vector2 + createVector(0, 4, 0)
				task.wait(0.2)
				setSelection:Invoke({ v6 })
			else
				warn("Enter a MeshPart asset from create.roblox.com/store, or enter a MeshId to build a new MeshPart.")
			end
		else
			warn("Paste a MeshPart asset from create.roblox.com/store, or paste a MeshId to build a new MeshPart.")
		end

		v5 = false
		script.Parent.Text = "Get"
		flag = true
	end
end)