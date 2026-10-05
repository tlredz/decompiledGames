local createVector = vector.create
local LeafPileClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local TweenService = game:GetService("TweenService")
game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local UtilityAlec = require(ReplicatedStorage.Modules.UtilityAlec)
local leafPileTracks = nil
local random = Random.new()

function CheckForChests()
	if localPlayer.Character and localPlayer.Character.PrimaryPart then
		local tagged = CollectionService:GetTagged("Chest")
		local v = 9999999999
		local v2 = nil

		for _, v3 in pairs(tagged) do
			if not v3:IsDescendantOf(workspace) or not v3.PrimaryPart or v3:GetAttribute(localPlayer.UserId .. "Opened") then
				continue
			end

			local magnitude = (localPlayer.Character.PrimaryPart.Position - v3.PrimaryPart.Position).Magnitude

			if not (magnitude < v) then
				continue
			end

			v2 = v3
			v = magnitude
		end

		if v2 and v < 350 then
			return v2.PrimaryPart.Position
		end
	end
end

function CheckForFairy()
	if localPlayer.Character and localPlayer.Character.PrimaryPart and Client.FlowerAndCoinsClient.FlowerAmount >= 10 and not (Client.FairyClient.AlreadyFound or localPlayer:GetAttribute("CompassFoundFairy")) then
		local fairy = Client.FairyClient.GetFairy()
		local primaryPart = localPlayer.Character.PrimaryPart

		if fairy and fairy:IsDescendantOf(workspace) then
			if (primaryPart.Position - fairy.PrimaryPart.Position).Magnitude < 350 then
				return fairy.PrimaryPart.Position
			end
		else
			return false
		end
	end

	return false
end

function CheckForWinter()
	if not workspace.Map.Landmarks:FindFirstChild("Snow Clothing Shop") or localPlayer.Character:GetAttribute("Warmth") and localPlayer.Character:GetAttribute("Warmth") > 0 then
		return false
	end

	if localPlayer.Character and localPlayer.Character.PrimaryPart then
		local snowClothingShop = workspace.Map.Landmarks:FindFirstChild("Snow Clothing Shop")
		local primaryPart = localPlayer.Character.PrimaryPart

		if snowClothingShop.PrimaryPart and snowClothingShop:IsDescendantOf(workspace) then
			if (primaryPart.Position - snowClothingShop.PrimaryPart.Position).Magnitude < 350 then
				return snowClothingShop:GetPivot().Position
			end
		else
			return false
		end
	end

	return false
end

function LeafPileClient:PileDug()
	task.spawn(function()
		if self and self:FindFirstChild("LeafPile") then
			self.PrimaryPart.ProximityAttachment:Destroy()
			self.LeafPile:Destroy()
			self:SetAttribute("Dug", true)
			self.ChestMarker.SurfaceGui.Enabled = true
			self.Name = "DugPile"
			Client.Sound.Play("DirtPile")
			task.spawn(function()
				wait(90)

				if self then
					self:Destroy()
				end
			end)
		end
	end)
end

function GetPositionInFrontOfPlayer()
	if not (localPlayer.Character and localPlayer.Character.PrimaryPart) then
		return
	end

	local primaryPart = localPlayer.Character.PrimaryPart
	local lookVector = primaryPart.CFrame.LookVector
	local rightVector = primaryPart.CFrame.RightVector
	local number = random:NextNumber(-40, 40)
	local v = primaryPart.Position + lookVector * 85 + rightVector * number
	return (Vector3.new(v.X, 30, v.Z))
end

function FindGrassBlock(p)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = { workspace.Map.Ground }
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.IgnoreWater = true
	local raycastResult = workspace:Raycast(p, createVector(0, -55, 0), raycastParams)

	if raycastResult then
		return raycastResult.Position, raycastResult
	end

	return nil
end

function SpawnPile(positionToPoint, p)
	if positionToPoint then
		local clone = leafPileTracks:Clone()
		clone:SetAttribute("PositionToPoint", positionToPoint)
		local v = GetPositionInFrontOfPlayer()

		if not v then
			return
		end

		local v2 = FindGrassBlock(v)

		if not v2 then
			return
		end

		clone:PivotTo(CFrame.new(v2 - createVector(0, 0.47, 0)))

		if p == "Fairy" then
			clone.ChestMarker.SurfaceGui.ImageLabel.Image = "rbxassetid://88353825247405"
			clone.ChestMarker.SurfaceGui.ImageLabel.ImageColor3 = Color3.fromRGB(86, 28, 76)
			clone.LeafPile.Stone.Color = Color3.fromRGB(247, 119, 213)
		elseif p == "Winter" then
			clone.ChestMarker.SurfaceGui.ImageLabel.Image = "rbxassetid://111990197084972"
			clone.ChestMarker.SurfaceGui.ImageLabel.ImageColor3 = Color3.fromRGB(56, 56, 56)
			clone.LeafPile.Stone.Color = Color3.fromRGB(74, 104, 168)
			clone.LeafPile.Stone.Material = Enum.Material.Neon
		else
			clone.ChestMarker.SurfaceGui.ImageLabel.Image = "rbxassetid://137995367025399"
			clone.ChestMarker.SurfaceGui.ImageLabel.ImageColor3 = Color3.fromRGB(86, 57, 18)
			clone.LeafPile.Stone.Color = Color3.fromRGB(171, 87, 44)
		end

		local position = clone:GetPivot().Position
		local vector2 = Vector3.new(positionToPoint.X, position.Y, positionToPoint.Z)
		clone:PivotTo(CFrame.lookAt(position, vector2) * CFrame.Angles(0, -1.5707963267948966, 0))
		clone.Parent = workspace

		for _, part in pairs(clone.LeafPile:GetDescendants()) do
			if part:IsA("BasePart") then
				TweenService:Create(part, TweenInfo.new(4, Enum.EasingStyle.Linear), {
					Transparency = 0
				}):Play()
			end
		end

		task.spawn(function()
			wait(30)

			if clone and not clone:GetAttribute("Dug") then
				task.spawn(function()
					while clone do
						if localPlayer.Character and localPlayer.Character.PrimaryPart and clone.PrimaryPart and (localPlayer.Character.PrimaryPart.Position - clone.PrimaryPart.Position).Magnitude > 35 then
							clone:Destroy()
						end

						wait(10)
					end
				end)
			end
		end)
	end
end

function SpawnPileLoop()
	task.spawn(function()
		while true do
			wait(random:NextInteger(76, 108))

			if not localPlayer.Character or not localPlayer.Character.PrimaryPart or (workspace:FindFirstChild("LeafPileTracks") or Client.WeatherEffectModule.Inside) then
				continue
			end

			local v = CheckForChests()
			SpawnPile(v, nil)
		end
	end)
end

function LeafPileClient.Init()
	task.spawn(function()
		UtilityAlec.preload({ "rbxassetid://137995367025399" })
		leafPileTracks = ReplicatedStorage.Assets.Alec:WaitForChild("LeafPileTracks")
		wait(9)
		SpawnPileLoop()
	end)
end

return LeafPileClient