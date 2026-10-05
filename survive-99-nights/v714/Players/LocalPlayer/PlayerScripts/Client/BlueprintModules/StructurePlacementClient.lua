local createVector = vector.create
local StructurePlacementClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
localPlayer:GetMouse()
game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
StructurePlacementClient.PlacementActive = false
local v = nil
local v2 = nil
local tweenModule = nil
local rounded = 180
local v3 = 180
local cframe = CFrame.new()
local values = {}
local count = 0
local v4 = {}
local positions = {}
local v5 = {
	["Boost Pad"] = 0,
	["Winged Boost Pad"] = 0,
	["Wood Rain Storage"] = 0,
	["Weather Machine"] = 0,
	["Temporal Accelerometer"] = 0,
	["Respawn Capsule"] = 0,
	["Ammo Crate"] = 0,
	["Heavy Ammo Crate"] = 0
}
local overlapParams = OverlapParams.new()
local buildingHighlight = workspace.Highlights.BuildingHighlight
local mainFire = nil

function AttemptPlaceItem(instance)
	if v4.Valid then
		if v:HasTag("Turret") and #CollectionService:GetTagged("Turret" .. localPlayer.UserId) >= Client.GlobalSettings.MaxTurrets then
			Client.PopUpUI.AddPopUp("You have placed the maximum number of turrets", "warning")
			return
		end

		print("send request")
		local clone = v:Clone()
		ClearAttributes(clone)
		clone:PivotTo(v4.CFrame)

		if instance:GetAttribute("StructureMoved") and clone:FindFirstChild("OneTimeItems") then
			clone.OneTimeItems:Destroy()
		end

		clone.Parent = workspace
		task.spawn(function()
			local v6 = Client.Events.RequestPlaceStructure:InvokeServer(
				instance,
				v4,
				cframe,
				v:GetAttribute("PlaceAnywhere")
			)

			if not v6.Success then
				print(v6.Error)
			end

			clone:Destroy()
		end)
		StructurePlacementClient.StopPlacingItem()
		return {
			Success = true
		}
	else
		warn(v4.ErrorType)

		if v4.ErrorType == "NotBraced" then
			Client.PopUpUI.AddPopUp("Ladder must be braced against a wall", "warning")
		end
	end
end

StructurePlacementClient.AttemptPlaceItem = AttemptPlaceItem

function GetStructure(parent)
	while parent:GetAttribute("IsStructure") == nil do
		parent = parent.Parent
	end

	return parent
end

function CheckValidity(p, p2, instance)
	if not p then
		return false, false, "NoRaycast"
	end

	local instance2 = p.Instance

	if instance:GetAttribute("WallDecoration") then
		local v6 = instance2:IsDescendantOf(workspace.Structures) and GetStructure(instance2)

		if v6 and (v6:GetAttribute("WallDecoration") or v6:GetAttribute("CanPlaceOnSurface")) then
			return false, true, "NotOnWall"
		end
	else
		if instance2 == nil then
			return false, true, "NoGround"
		end

		if instance:GetAttribute("CanPlaceOnSurface") then
			local v6 = instance2:IsDescendantOf(workspace.Structures) and GetStructure(instance2)

			if instance2.Name ~= "Grass" and not (v6 and v6:GetAttribute("Surface")) and not localPlayer:GetAttribute("ContentCreator") and game.ReplicatedStorage:GetAttribute("GameMode") ~= "UpdateParty" then
				return false, true, "NotOnSurface"
			end
		elseif instance:GetAttribute("OnlyPlaceOnSurface") then
			local v6 = instance2:IsDescendantOf(workspace.Structures) and GetStructure(instance2)

			if not (v6 and v6:GetAttribute("Surface")) then
				return false, true, "NotOnSurface"
			end
		elseif not instance:HasTag("Turret") and instance2.Name ~= "Grass" and not instance2:GetAttribute("BuildingAllowed") and not localPlayer:GetAttribute("ContentCreator") and game.ReplicatedStorage:GetAttribute("GameMode") ~= "UpdateParty" then
			return false, true, "NotOnGround"
		end

		if instance:GetAttribute("Ladder") then
			local partsInPart = workspace:GetPartsInPart(v2.OverlapZone, overlapParams)

			for _, v6 in pairs(partsInPart) do
				if not v6:IsDescendantOf(v2) and v6.Parent ~= localPlayer.Character and v6.Parent.Parent ~= localPlayer.Character and v6.Name ~= "Leaves" then
					return false, true, "ThroughWall"
				end
			end

			local partsInPart2 = workspace:GetPartsInPart(v2.StickZone, overlapParams)
			local count2 = 0

			for _, v6 in pairs(partsInPart2) do
				if v6:IsDescendantOf(v2) or v6.Parent == localPlayer.Character or v6.Parent.Parent == localPlayer.Character then
					continue
				end

				count2 += 1
			end

			if count2 == 0 then
				return false, true, "NotBraced"
			end
		end
	end

	local magnitude = ((mainFire.PrimaryPart.Position - p2) * createVector(1, 0, 1)).Magnitude

	if magnitude < Client.GlobalSettings.MinBuildingRadius then
		return false, true, "TooCloseToCamp"
	end

	local _, v6 = Client.ChristmasDecorClient.InChristmasSafezone(p2)
	local v7 = magnitude < (Client.GlobalSettings.FireOuterZoneSize + 14) / 2 or (v:GetAttribute("PlaceAnywhere") and true or false)
	local v8 = (localPlayer:GetAttribute("ContentCreator") or game.ReplicatedStorage:GetAttribute("GameMode") == "UpdateParty") and true or v7

	if v6 or v8 then
		return true, true
	end

	return false, true, "OutsideCampArea"
end

function UpdateDemoCFrame()
	if v:GetAttribute("WallDecoration") then
		local cFrame = Client.PlayerHandler.HumanoidRootPart.CFrame
		local v6 = cFrame.Position + createVector(0, 0, 0)
		local raycastResult = workspace:Raycast(v6, cFrame.LookVector * 7, Client.CollisionUtility.DefaultParams)
		local position = raycastResult and raycastResult.Position
		local v7 = v2.PrimaryPart and v2.PrimaryPart.Size.Y / 2 or 0
		local instance = raycastResult and raycastResult.Instance

		if raycastResult and instance and instance:IsDescendantOf(workspace.Structures) and v2 and math.abs(raycastResult.Normal.Y) < 0.2 then
			local normal = raycastResult.Normal
			local cFrame2 = CFrame.lookAlong(position, normal) * CFrame.new(0, v7, 0)
			v2:PivotTo(cFrame2)
			v2.Parent = workspace.Particles
			local position2 = cFrame2.Position
			local valid, v10, errorType = CheckValidity(raycastResult, position2, v)
			v4.Valid = valid
			v4.Position = position2
			v4.CFrame = cFrame2
			v4.ErrorType = errorType

			if not v10 then
				v2.Parent = nil
			elseif valid then
				buildingHighlight.FillColor = Color3.fromRGB(0, 255, 81)
				buildingHighlight.OutlineColor = Color3.fromRGB(81, 255, 0)
			else
				buildingHighlight.FillColor = Color3.fromRGB(255, 0, 0)
				buildingHighlight.OutlineColor = Color3.fromRGB(255, 0, 0)
			end
		else
			local v8 = cFrame * CFrame.new(0, 0, -7) * CFrame.Angles(0, 3.141592653589793, 0)

			if raycastResult then
				v8 = v8 - v8.Position + raycastResult.Position
			end

			v2:PivotTo(v8 * CFrame.new(0, v7, 0))
			v2.Parent = workspace.Particles
			v4.Valid = false
			v4.Position = v8.Position
			v4.CFrame = v8 * CFrame.new(0, v7, 0)
			v4.ErrorType = "NoWall"
			buildingHighlight.FillColor = Color3.fromRGB(255, 0, 0)
			buildingHighlight.OutlineColor = Color3.fromRGB(255, 0, 0)
		end
	else
		local cFrame = Client.PlayerHandler.HumanoidRootPart.CFrame
		local placementOffset = v:GetAttribute("PlacementOffset") or 5
		local v6 = (cFrame * CFrame.new(0, 0, -placementOffset)).Position + createVector(0, 10, 0)
		local raycastResult = workspace:Raycast(v6, createVector(0, -30, 0), Client.CollisionUtility.DefaultParams)
		local position = raycastResult and raycastResult.Position

		if raycastResult and v2 then
			local v7

			if Client.StructureInterfaceClient.Settings.SnapToGrid then
				v7 = v2.Name == "Snow Block" and 4 or 3
			end

			local X = position.X
			local Z = position.Z

			if v7 and v7 > 0 then
				local v8 = math.round(v2.PrimaryPart.Size.X / v7)
				local v9 = math.round(v2.PrimaryPart.Size.Z / v7)
				X, Z = Client.Utility.RoundToGrid(position, v8, v9, v7)
			end

			local position2 = Vector3.new(X, position.Y, Z) + Client.GlobalSettings.GridOffset
			local unit = (cFrame.LookVector * createVector(1, 0, 1)).Unit
			local cframe2 = CFrame.new()
			cframe = CFrame.new()

			if v:GetAttribute("NoRotation") == nil then
				if Client.StructureInterfaceClient.Settings.SnapToGrid then
					local angleBetweenVectors, v9 = Client.Utility.GetAngleBetweenVectors(createVector(1, 0, 0), unit)
					local rounded2 = round(math.deg(angleBetweenVectors * v9), 45)
					RoundRotation(22.5)
					local cframe3 = CFrame.Angles(0, math.rad(rounded2 - 90), 0)
					cframe2 = cframe3 * CFrame.Angles(0, math.rad(v3), 0)
					cframe = cframe3 * CFrame.Angles(0, math.rad(rounded), 0)
				else
					cframe = CFrame.lookAlong(Vector3.new(), unit)
					cframe2 = cframe * CFrame.Angles(0, math.rad(v3), 0)
					cframe *= CFrame.Angles(0, math.rad(rounded), 0)
				end
			end

			local structureHeightOffset = v:GetAttribute("StructureHeightOffset") or v2.PrimaryPart and v2.PrimaryPart.Size.Y / 2 or 0
			local cFrame2 = cframe2 + position2 + Vector3.new(0, structureHeightOffset, 0)
			v2:PivotTo(cFrame2)
			v2.Parent = workspace.Particles
			local valid, v11, errorType = CheckValidity(raycastResult, position2, v)
			v4.Valid = valid
			v4.Position = position2
			v4.CFrame = cFrame2
			v4.ErrorType = errorType

			if v11 then
				if valid then
					buildingHighlight.FillColor = Color3.fromRGB(0, 255, 81)
					buildingHighlight.OutlineColor = Color3.fromRGB(81, 255, 0)
				else
					buildingHighlight.FillColor = Color3.fromRGB(255, 0, 0)
					buildingHighlight.OutlineColor = Color3.fromRGB(255, 0, 0)
				end
			else
				v2.Parent = nil
			end
		end
	end
end

function round(p, p2)
	local v6 = math.round(p / p2) * p2

	if v6 == -0 then
		return 0
	end

	return v6
end

function ClearAttributes(instance)
	for k, _ in pairs(instance:GetAttributes()) do
		if k ~= "RBX_ReimportId" then
			instance:SetAttribute(k, nil)
		end
	end

	for _, tag in pairs(instance:GetTags()) do
		instance:RemoveTag(tag)
	end
end

function MakeDemoModel(instance)
	local clone = instance:Clone()
	ClearAttributes(clone)

	for _, descendant in pairs(clone:GetDescendants()) do
		if descendant:IsA("Attachment") or descendant:IsA("Folder") and descendant.Name ~= "Colourable" then
			descendant:Destroy()
		elseif descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = false
			descendant.CanQuery = false
			descendant.CanTouch = false
		end
	end

	buildingHighlight.Adornee = clone
	v2 = clone
end

function RoundRotation(p)
	if rounded % p > 1 then
		rounded = round(rounded, p)

		if tweenModule then
			tweenModule:Stop()
			tweenModule = nil
		end

		v3 = rounded
	end
end

function Rotate(value)
	if not StructurePlacementClient.PlacementActive then
		return Enum.ContextActionResult.Pass
	end

	local v6 = Client.StructureInterfaceClient.Settings.SnapToGrid and 22.5 or value or 10
	rounded = (rounded + v6) % 360
	values[v.Name] = rounded

	if tweenModule then
		tweenModule:Stop()
		tweenModule = nil
	end

	local v7 = v3 % 360
	local v8 = rounded

	if v8 < v7 then
		v8 += 360
	end

	local v9 = v8 - v7
	tweenModule = Client.TweenModule.new(function(p)
		v3 = v7 + v9 * p
	end, 0.1, "Quad", "InOut")
	tweenModule:Play()
end

StructurePlacementClient.Rotate = Rotate

function StartRotating(p)
	if not StructurePlacementClient.PlacementActive then
		return Enum.ContextActionResult.Pass
	end

	count += 1
	local v6 = count
	Rotate()
	task.delay(0.3, function()
		while count == v6 and p.UserInputState ~= Enum.UserInputState.End do
			Rotate()
			task.wait(0.08)
		end
	end)
end

StructurePlacementClient.StartRotating = StartRotating

function StopRotating()
	count += 1
end

StructurePlacementClient.StopRotating = StopRotating

function RotateInput(_, p, p2)
	if p == Enum.UserInputState.Begin then
		return StartRotating(p2)
	end

	StopRotating()
	return Enum.ContextActionResult.Sink
end

ContextActionService:BindActionAtPriority(
	"RotateStructure",
	RotateInput,
	false,
	Enum.ContextActionPriority.High.Value + 10,
	Enum.KeyCode.R
)
ContextActionService:BindActionAtPriority(
	"RotateStructureGamepad",
	RotateInput,
	false,
	Enum.ContextActionPriority.High.Value - 1,
	Enum.KeyCode.ButtonB
)

function StructurePlacementClient.StartPlacingItem(instance)
	StructurePlacementClient.PlacementActive = true
	v = instance
	MakeDemoModel(instance)
	rounded = values[instance.Name] or v5[instance.Name] or 180
	v3 = rounded

	if v:GetAttribute("PlaceAnywhere") then
		Client.Interface.PlacementNotif.Visible = true
	end

	Client.Events.StopDraggingItem:Fire()
	RunService:BindToRenderStep("PlaceStructure", Enum.RenderPriority.Last.Value, UpdateDemoCFrame)

	if not instance:GetAttribute("WallDecoration") then
		Client.GuiButtonHandler.ShowButton("Rotate")
	end
end

Client.Events.PlayerDied:Connect(function()
	StructurePlacementClient.StopPlacingItem()
end)

function StructurePlacementClient.StopPlacingItem()
	RunService:UnbindFromRenderStep("PlaceStructure")
	buildingHighlight.Adornee = nil

	if v2 then
		v2:Destroy()
		v2 = nil
	end

	Client.Interface.PlacementNotif.Visible = false
	StructurePlacementClient.PlacementActive = false
	v4 = {}
	StopRotating()

	if tweenModule then
		tweenModule:Stop()
		tweenModule = nil
		v3 = rounded
	end

	Client.GuiButtonHandler.HideButton("Rotate")
end

function CampsiteTorchAdded(instance)
	if instance.Parent ~= workspace.Structures then
		return
	end

	local position = instance:GetPivot().Position
	table.insert(positions, position)
end

function StructurePlacementClient.Init()
	task.spawn(function()
		mainFire = workspace:WaitForChild("Map"):WaitForChild("Campground"):WaitForChild("MainFire")
	end)
	Client.Utility.ForAllTagged("CampsiteTorch", CampsiteTorchAdded)
end

return StructurePlacementClient