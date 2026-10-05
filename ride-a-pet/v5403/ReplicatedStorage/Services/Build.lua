local createVector = vector.create
game:GetService("UserInputService")
game:GetService("RunService")
game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
return {
	InitiateObjectPlacing = function(_, instance)
		local localPlayer = Players.LocalPlayer
		local v = true
		local clone = nil
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.IgnoreWater = true

		if instance:IsA("Model") then
			clone = instance:Clone()

			if clone.PrimaryPart == nil then
				for _, part in pairs(clone:GetDescendants()) do
					if not part:IsA("BasePart") then
						continue
					end

					clone.PrimaryPart = part
					break
				end
			end
		elseif instance:IsA("BasePart") or instance:IsA("MeshPart") then
			clone = instance:Clone()
		end

		if not clone then
			return
		end

		if clone:IsA("Model") then
			for _, descendant in pairs(clone:GetDescendants()) do
				if descendant:IsA("Script") or descendant:IsA("LocalScript") then
					descendant:Destroy()
				elseif descendant:IsA("BasePart") then
					descendant.Transparency = 0.5
					descendant.Color = Color3.fromRGB(0, 255, 0)
					descendant.Material = Enum.Material.ForceField
					descendant.CanCollide = false
					descendant.CanTouch = false
					descendant.CanQuery = false
				elseif descendant:IsA("Texture") or descendant:IsA("Decal") then
					descendant.Transparency = 0.5
				end
			end
		elseif clone:IsA("BasePart") or clone:IsA("MeshPart") then
			if clone:FindFirstChildOfClass("Script") then
				clone:FindFirstChildOfClass("Script"):Destroy()
			end

			if clone:FindFirstChildOfClass("LocalScript") then
				clone:FindFirstChildOfClass("LocalScript"):Destroy()
			end

			clone.Transparency = 0.5
			clone.Color = Color3.fromRGB(0, 255, 0)
			clone.Material = Enum.Material.ForceField
			clone.CanCollide = false
			clone.CanTouch = false
			clone.CanQuery = false

			for _, child in pairs(clone:GetChildren()) do
				if child:IsA("Texture") or child:IsA("Decal") then
					child.Transparency = 0.5
				end
			end
		end

		clone.Parent = workspace
		local characters = { clone }

		if localPlayer.Character then
			table.insert(characters, localPlayer.Character)
		end

		raycastParams.FilterDescendantsInstances = characters

		local function updatePosition()
			if not v then
				return
			end

			local currentCamera = workspace.CurrentCamera
			local mouseLocation = UserInputService:GetMouseLocation()
			local raycastResult = workspace:Raycast(
				currentCamera.CFrame.Position,
				currentCamera:ScreenPointToRay(mouseLocation.X, mouseLocation.Y).Direction * 1000,
				raycastParams
			)

			if raycastResult then
				local position = raycastResult.Position

				if clone:IsA("Model") then
					if clone.PrimaryPart then
						clone:SetPrimaryPartCFrame(CFrame.new(position) + createVector(0, 0.5, 0))
					end
				else
					clone.CFrame = CFrame.new(position + createVector(0, 0.5, 0))
				end
			end
		end

		local renderSteppedConnection = nil

		local function cleanup()
			v = false

			if clone then
				clone:Destroy()
			end

			if renderSteppedConnection then
				renderSteppedConnection:Disconnect()
			end
		end

		local function placeObject()
			if not v then
				return
			end

			local clone2 = instance:Clone()
			clone2.Parent = workspace

			if clone2:IsA("Model") then
				if clone2.PrimaryPart then
					clone2:SetPrimaryPartCFrame(clone.PrimaryPart.CFrame)
				end
			else
				clone2.CFrame = clone.CFrame
			end
		end

		renderSteppedConnection = RunService.RenderStepped:Connect(updatePosition)
		return cleanup
	end
}