local createVector = vector.create
local DinoKidQuestClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local ContextActionService = game:GetService("ContextActionService")
local currentCamera = workspace.CurrentCamera
local map = nil
local v = nil
local cameraType = nil
local cFrame = nil
local fieldOfView = nil
local v2 = nil
local v3 = nil
local v4 = nil
local v5 = nil
local v6 = {}
local v7 = nil
local count = 0
local v8 = {}
local v9 = {}

function GetActivePaper(instance)
	for i = 1, 5 do
		local child = instance:FindFirstChild("Paper" .. i)

		if child and child:GetAttribute("Found") ~= true then
			return child, i
		end
	end
end

function SnapCameraToPaper(instance)
	local v10 = currentCamera.ViewportSize.X / currentCamera.ViewportSize.Y
	local v11 = instance.Size.X / 2 * 1.8
	local v12 = math.max(instance.Size.Y / 2 * 1.8 / 0.4663076581549986, v11 / (0.4663076581549986 * v10))
	currentCamera.CameraType = Enum.CameraType.Scriptable
	currentCamera.FieldOfView = 50
	currentCamera.CFrame = CFrame.lookAt(
		instance.Position + Vector3.new(0, v12, 0) - instance.CFrame.UpVector * (v12 * 0.01),
		instance.Position,
		instance.CFrame.UpVector
	)
end

function MapBuilt()
	for _, v10 in pairs(CollectionService:GetTagged("MapDraw")) do
		if v10:IsDescendantOf(workspace.Structures) then
			return true
		end
	end

	return false
end

function CaptureClueButtonTransparency()
	local dinoDeskClueButton = Client.Interface.DinoDeskClueButton
	local descendants = dinoDeskClueButton:GetDescendants()
	table.insert(descendants, dinoDeskClueButton)

	for _, instance in pairs(descendants) do
		if v8[instance] ~= nil then
			continue
		end

		local v10 = {}

		if instance:IsA("GuiObject") then
			v10.BackgroundTransparency = instance.BackgroundTransparency
		end

		if instance:IsA("TextLabel") or instance:IsA("TextButton") then
			v10.TextTransparency = instance.TextTransparency
			v10.TextStrokeTransparency = instance.TextStrokeTransparency
		end

		if instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
			v10.ImageTransparency = instance.ImageTransparency
		end

		if instance:IsA("UIStroke") then
			v10.Transparency = instance.Transparency
		end

		v8[instance] = v10
	end
end

function SetClueButtonDim(p)
	for k, v10 in pairs(v8) do
		if not k.Parent then
			continue
		end

		for k2, v11 in pairs(v10) do
			if p then
				k[k2] = math.max(v11, 0.99)
			else
				k[k2] = v11
			end
		end
	end
end

function BlinkClueButton()
	local v10 = count
	task.spawn(function()
		for _ = 1, 5 do
			task.wait(0.15)

			if v10 ~= count then
				break
			end

			SetClueButtonDim(true)
			task.wait(0.15)

			if v10 ~= count then
				break
			end

			SetClueButtonDim(false)
		end
	end)
end

function SetClueButtonVisible(visible)
	count += 1
	local dinoDeskClueButton = Client.Interface.DinoDeskClueButton
	local visible2 = dinoDeskClueButton.Visible
	SetClueButtonDim(false)
	dinoDeskClueButton.Visible = visible

	if visible and not visible2 then
		BlinkClueButton()
	end
end

function IsDinoKidRescuedUnfriended()
	for _, v10 in pairs(CollectionService:GetTagged("ChildNPC")) do
		if v10:GetAttribute("KidId") == "DinoKid" and v10:GetAttribute("Interaction") == "BefriendDinoKid" then
			return true
		end
	end

	return false
end

function UpdateClueButton()
	local v10, v11

	if v then
		v10, v11 = GetActivePaper(v)
	end

	local v12 = v10 and v11 ~= v7 and typeof(v10:GetAttribute("AdjustedPosition")) == "Vector3" and true or false

	if v11 == 1 and IsDinoKidRescuedUnfriended() then
		v12 = false
	end

	SetClueButtonVisible(v12)
end

function RefreshView()
	if v == nil then
		return
	end

	local v10 = GetActivePaper(v)

	if v10 == nil then
		CloseDesk()
		return
	end

	SnapCameraToPaper(v10)
	UpdateClueButton()
end

function GetDeskPrompt(instance)
	local proximityAttachment = instance.PrimaryPart and instance.PrimaryPart:FindFirstChild("ProximityAttachment")
	return proximityAttachment and proximityAttachment:FindFirstChild("ProximityInteraction")
end

function OpenDesk(instance)
	if v then
		return
	end

	local v10 = GetActivePaper(instance)

	if v10 == nil then
		return
	end

	v = instance

	if currentCamera.CameraType == Enum.CameraType.Scriptable then
		cFrame = nil
	else
		cameraType = currentCamera.CameraType
		cFrame = currentCamera.CFrame
	end

	fieldOfView = currentCamera.FieldOfView
	instance:RemoveTag("Interaction")
	v7 = nil
	local v11 = GetDeskPrompt(instance)

	if v11 then
		v11.Enabled = false
	end

	SnapCameraToPaper(v10)
	UpdateClueButton()
	Client.Interface.DinoDeskClose.Visible = not Client.Interface.MapHolder.Visible
	Client.Sound.Play("PosterOpen")

	if IsDinoKidRescuedUnfriended() then
		Client.PopUpUI.AddPopUp("talk to dino kid", "warning")
	end
end

function CloseDesk()
	if v == nil then
		return
	end

	local v10 = v
	v = nil

	if cFrame then
		local v11 = GetActivePaper(v10)
		local primaryPart = localPlayer.Character and localPlayer.Character.PrimaryPart
		local v12 = v11 and v11.CFrame.UpVector * createVector(1, 0, 1)

		if primaryPart and v12 and v12.Magnitude > 0 then
			local v13 = primaryPart.Position + createVector(0, 2, 0)
			currentCamera.CFrame = CFrame.lookAt(v13 - v12.Unit * 12 + createVector(0, 4, 0), v13)
		else
			currentCamera.CFrame = cFrame
		end

		cFrame = nil
	end

	currentCamera.CameraType = cameraType or Enum.CameraType.Custom
	currentCamera.FieldOfView = fieldOfView or 70
	Client.Interface.DinoDeskClose.Visible = false
	SetClueButtonVisible(false)
	Client.Sound.Play("CloseButton")

	if GetActivePaper(v10) then
		v10:AddTag("Interaction")
		local v11 = GetDeskPrompt(v10)

		if v11 then
			v11.Enabled = true
		end
	end
end

function MaxCircleSize(p)
	if p <= 2 then
		return 0.18
	end

	if p <= 4 then
		return 0.25
	end

	return 0.35
end

function StageSize(p, p2)
	return (math.max(MaxCircleSize(p) - (p2 - 1) * 0.05, 0.08))
end

function StageCount(p)
	local v10 = 1

	while StageSize(p, v10) > 0.081 do
		v10 += 1
	end

	return v10
end

function StageCenter(instance, p)
	if p == 1 then
		return instance:GetAttribute("AdjustedPosition")
	end

	return instance:GetAttribute("AdjustedPosition" .. p)
end

function MakeCircle(p, p2, imageTransparency)
	local clone = Client.Interface.MapHolder.DinoKid.Circle:Clone()
	clone.Size = UDim2.new(p2, 0, p2, 0)
	local worldToScale, v10 = Client.MapDrawClient.WorldToScale(p.X, p.Z)
	clone.Position = UDim2.new(worldToScale, 0, v10, 0)
	clone.ZIndex = 20
	clone.ImageTransparency = 1
	clone.Visible = true
	clone.Parent = map.Icons
	TweenService:Create(clone, TweenInfo.new(1), {
		ImageTransparency = imageTransparency
	}):Play()
	return clone
end

function MakeOldCircle(p, p2)
	local v10 = MakeCircle(p, p2, 0.8)
	v10.Name = "CircleOLD"
	v10.ImageColor3 = Color3.fromRGB(212, 212, 0)
	v10.ZIndex = 19
	return v10
end

function ClearCircles()
	if v2 then
		v2:Destroy()
		v2 = nil
	end

	if v4 then
		v4:Destroy()
		v4 = nil
	end

	v3 = nil
	v5 = nil
end

function FadeOutCircle(instance)
	if instance == nil then
		return
	end

	local tween = TweenService:Create(instance, TweenInfo.new(1), {
		ImageTransparency = 1
	})
	tween.Completed:Connect(function()
		instance:Destroy()
	end)
	tween:Play()
end

function ClearClueCircles()
	FadeOutCircle(v2)
	FadeOutCircle(v4)
	v2 = nil
	v4 = nil
	v3 = nil
	v5 = nil
end

function DrawCircleStage(instance, p)
	ClearCircles()
	local v10 = v6[p]
	local v11 = v10 > 1 and StageCenter(instance, v10 - 1)

	if v11 then
		v4 = MakeOldCircle(v11, StageSize(p, v10 - 1))
	end

	local v12 = StageCenter(instance, v10) or instance:GetAttribute("AdjustedPosition")
	v2 = MakeCircle(v12, StageSize(p, v10), 0.1)
	v3 = p
	v5 = instance
end

function AdvanceCircleStage(p)
	v6[p] += 1

	if v3 == p and v5 then
		DrawCircleStage(v5, p)
	end
end

function StartShrinkLoop(p)
	task.spawn(function()
		while v6[p] and v6[p] < StageCount(p) do
			task.wait(270)

			if v6[p] then
				AdvanceCircleStage(p)
			end
		end
	end)
end

function DrawCircle(p, p2)
	if v6[p2] == nil then
		v6[p2] = 1
		StartShrinkLoop(p2)
	end

	DrawCircleStage(p, p2)
end

function RevealClue()
	if v == nil then
		return
	end

	local v10, v11 = GetActivePaper(v)

	if v10 == nil then
		return
	end

	local itemName = v10:GetAttribute("ItemName")
	local inventory = localPlayer:FindFirstChild("Inventory")

	if itemName and inventory and inventory:FindFirstChild(itemName) then
		Client.PopUpUI.AddPopUp("check your hotbar", "warning")
		return
	end

	if typeof((v10:GetAttribute("AdjustedPosition"))) ~= "Vector3" or map == nil then
		return
	end

	if not MapBuilt() then
		Client.PopUpUI.AddPopUp("build a map first", "warning")
		return
	end

	Client.Sound.Play("ClueBoardDraw", {
		Volume = 0.4
	})

	if v10:GetAttribute("DrawnOnMap") ~= true then
		v10:SetAttribute("DrawnOnMap", true)
		Client.Events.DinoKidClueRevealed:FireServer(v11)
	end

	v7 = v11
	SetClueButtonVisible(false)
	DrawCircle(v10, v11)
	Client.PopUpUI.AddPopUp("The clue points to this area", "yellow")
	Client.MapDrawClient.OpenMap()
end

function PaperFound(p)
	v6[p] = nil

	if v3 == p then
		ClearClueCircles()
	end

	RefreshView()
end

function DeskAdded(instance)
	for i = 1, 5 do
		local child = instance:WaitForChild("Paper" .. i, 10)

		if not child then
			continue
		end

		local v10 = child
		local v11 = i
		child:GetAttributeChangedSignal("Found"):Connect(function()
			if v10:GetAttribute("Found") == true then
				PaperFound(v11)
			end
		end)
		local v12 = i
		local v13 = child
		child:GetAttributeChangedSignal("AdjustedPosition"):Connect(function()
			if v == instance then
				UpdateClueButton()
			end

			if v3 == v12 and v5 == v13 then
				DrawCircleStage(v13, v12)
			end
		end)
	end
end

function DeskRemoved(p)
	if v == p then
		CloseDesk()
	end
end

function WatchDinoKidRescue(instance)
	if instance:GetAttribute("KidId") ~= "DinoKid" then
		return
	end

	instance:GetAttributeChangedSignal("Interaction"):Connect(function()
		if instance:GetAttribute("Interaction") == "BefriendDinoKid" then
			ClearClueCircles()
			UpdateClueButton()
		end
	end)
end

function DinoFaceAdded(p)
	p.Enabled = false
	v9[p] = true
end

function DinoFaceRemoved(p)
	v9[p] = nil
end

function GetBillboardPosition(instance)
	local adornee = instance.Adornee or instance.Parent

	if adornee == nil then
		return nil
	end

	if adornee:IsA("Attachment") then
		return adornee.WorldPosition
	end

	if adornee:IsA("BasePart") then
		return adornee.Position
	end

	if adornee:IsA("Model") then
		return adornee:GetPivot().Position
	end
end

function LoopUpdateDinoFaces()
	while true do
		task.wait(0.5)
		local primaryPart = localPlayer.Character and localPlayer.Character.PrimaryPart

		for k in pairs(v9) do
			if k.Parent == nil then
				v9[k] = nil
			else
				local v10 = GetBillboardPosition(k)
				k.Enabled = primaryPart and v10 and (v10 - primaryPart.Position).Magnitude <= 16 and true or false
			end
		end
	end
end

function IsTrinket(p)
	return string.sub(p.Name, 1, 10) == "Dino Kid's"
end

function IsHoldingItemBag()
	local currentlyEquipped = Client.InventoryHandler.GetCurrentlyEquipped()

	if currentlyEquipped == nil then
		return false
	end

	return (currentlyEquipped:GetAttribute("ToolName") or currentlyEquipped.Name) == "Item Bag"
end

function WarnTrinketStore()
	if not IsHoldingItemBag() then
		return
	end

	local focusItem = Client.InteractionHandler.GetFocusItem()

	if focusItem and IsTrinket(focusItem) then
		Client.PopUpUI.AddPopUp("equip this to your hotbar", "warning")
	end
end

function DinoKidQuestClient.Init()
	task.spawn(function()
		map = game.ReplicatedStorage.Assets.Alec.MapClient:WaitForChild("Map")
	end)
	CaptureClueButtonTransparency()
	Client.InteractionHandler.RegisterInteraction("DinoKidDesk", OpenDesk)
	Client.Utility.ForAllTagged("DinoKidDesk", DeskAdded, DeskRemoved)
	Client.Utility.ForAllTagged("DinoFace", DinoFaceAdded, DinoFaceRemoved)
	task.spawn(function()
		LoopUpdateDinoFaces()
	end)
	ContextActionService:BindActionAtPriority("DinoTrinketBagWarning", function(_, p)
		if p == Enum.UserInputState.Begin then
			WarnTrinketStore()
		end

		return Enum.ContextActionResult.Pass
	end, false, Enum.ContextActionPriority.High.Value + 1, Enum.KeyCode.F, Enum.KeyCode.ButtonY)
	Client.Events.RequestStoreItem:Connect(WarnTrinketStore)
	Client.Interface.DinoDeskClose.Activated:Connect(CloseDesk)
	Client.Interface.DinoDeskClueButton.Upper.Activated:Connect(RevealClue)
	Client.Interface.MapHolder.CloseButton.MouseButton1Down:Connect(function()
		CloseDesk()
	end)
	Client.Interface.MapHolder:GetPropertyChangedSignal("Visible"):Connect(function()
		if v then
			Client.Interface.DinoDeskClose.Visible = not Client.Interface.MapHolder.Visible
		end
	end)
	localPlayer.CharacterAdded:Connect(function()
		CloseDesk()
	end)
	Client.Utility.ForAllTagged("ChildNPC", WatchDinoKidRescue)
	task.spawn(function()
		localPlayer:WaitForChild("Inventory").ChildAdded:Connect(function(child)
			if IsTrinket(child) then
				ClearClueCircles()
			end
		end)
	end)
end

return DinoKidQuestClient