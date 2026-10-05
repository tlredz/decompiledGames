local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local StarterGui = game:GetService("StarterGui")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
game:GetService("GamepadService")
local MissingPosterClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local UtilityAlec = require(ReplicatedStorage.Modules.UtilityAlec)
local v = nil
local proximityInteraction = nil
local noticeBoardClose = nil
local cframe = CFrame.new(-0.851651669, 0.763598442, -15.1319122, 0, 0, 1, 0, 1, 0, -1, 0, 0)
local cframe2 = CFrame.new(
	-0.0491454601,
	-0.699206352,
	-6.19888306,
	0.998844266,
	0.0480650812,
	0,
	-0.0480650812,
	0.998844266,
	0,
	0,
	0,
	1
)
CFrame.new(
	0.00644230843,
	-0.196750641,
	-0.734977722,
	0.783697367,
	0.621142983,
	0,
	-0.0939550176,
	0.118543223,
	0.98849386,
	0.613995969,
	-0.77467984,
	0.151261494
)
local cframe3 = CFrame.new(
	-0.00104403496,
	0.290322304,
	-0.645233154,
	0.74314481,
	0.669130623,
	0,
	0,
	0,
	1,
	0.669130623,
	-0.74314481,
	0
)
local currentCamera = workspace.CurrentCamera
local cameraType = nil
local cFramesByChild = {}
local v2 = nil
local v3 = nil
local v4 = false
local count = 0
local v5 = {
	{
		"rbxassetid://138286215328777",
		"rbxassetid://82969444241552",
		"rbxassetid://126235493340218",
		"rbxassetid://90154784049696",
		"rbxassetid://80133347071249"
	},
	{
		"rbxassetid://100089970938321",
		"rbxassetid://117029318679718",
		"rbxassetid://122988396152326",
		"rbxassetid://96063413954384",
		"rbxassetid://95210392795830"
	},
	{
		"rbxassetid://74763027681661",
		"rbxassetid://92019776205424",
		"rbxassetid://131626282136588",
		"rbxassetid://89602890485538",
		"rbxassetid://118345944832507"
	},
	{
		"rbxassetid://75339690003185",
		"rbxassetid://127620265633369",
		"rbxassetid://139576377910538",
		"rbxassetid://74293080825826",
		"rbxassetid://101619219441175"
	}
}
local v6 = {
	"rbxassetid://104082844276300",
	"rbxassetid://80605544835747",
	"rbxassetid://113836674403809",
	"rbxassetid://113378388034939"
}
local v7 = {
	"DinoKid",
	"KrakenKid",
	"SquidKid",
	"KoalaKid"
}
local images = {}
local flag = false

function MissingPosterClient.ZoomToBoard()
	v4 = false
	count += 1
	flag = true
	local v8 = count
	proximityInteraction.Enabled = false
	Client.Interface.NoticeBoardClose.Visible = true

	if currentCamera.CameraType ~= Enum.CameraType.Scriptable then
		cameraType = currentCamera.CameraType
	end

	currentCamera.CameraType = Enum.CameraType.Scriptable
	currentCamera.CFrame = v.Board.AttachmentPart.CFrame:ToWorldSpace(cframe:Inverse())
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
	local findFirstChild = v:FindFirstChild("Poster" .. 1)
	findFirstChild.Part.ClickDetector.MaxActivationDistance = 999
	local findFirstChild_2 = v:FindFirstChild("Poster" .. 2)
	findFirstChild_2.Part.ClickDetector.MaxActivationDistance = 999
	local findFirstChild_3 = v:FindFirstChild("Poster" .. 3)
	findFirstChild_3.Part.ClickDetector.MaxActivationDistance = 999
	local findFirstChild_4 = v:FindFirstChild("Poster" .. 4)
	findFirstChild_4.Part.ClickDetector.MaxActivationDistance = 999
	task.spawn(function()
		wait(0.1)

		while v8 == count and flag do
			for i = 1, 4 do
				local child = v:FindFirstChild("Poster" .. i)

				if not child.Part.SurfaceGui.Frame.Smudge.Visible and not child.Part.SurfaceGui.Frame.FoundLabel2.Visible and v2 ~= child then
					child.Part.ClickDetector.MaxActivationDistance = 999
					local parent = child
					task.spawn(function()
						if not parent:FindFirstChild("Highlight") then
							local highlight = Instance.new("Highlight")
							highlight.OutlineTransparency = 1
							highlight.FillColor = Color3.fromRGB(255, 255, 255)
							highlight.FillTransparency = 1
							highlight.DepthMode = Enum.HighlightDepthMode.Occluded
							highlight.Parent = parent
						end

						if not proximityInteraction.Enabled and v2 ~= parent and v8 == count then
							TweenService:Create(
								parent:FindFirstChild("Highlight"),
								TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
								{
									FillTransparency = 0.35
								}
							):Play()
							wait(0.2)
							TweenService:Create(
								parent:FindFirstChild("Highlight"),
								TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
								{
									FillTransparency = 1
								}
							):Play()
						end

						wait(1.2)
					end)
				end

				if UserInputService:GetLastInputType() ~= Enum.UserInputType.Gamepad1 or not child.Part:FindFirstChild("Alert") or not (i <= v:GetAttribute("KidProgress")) or v4 then
					continue
				end

				v4 = true
				local parent2 = child
				local v10 = i
				local v11 = i
				task.delay(0.25, function()
					if v8 == count and flag then
						parent2.Part.Alert.Enabled = false
						CollectionService:GetTagged("ChildNPC")

						if workspace.Map.MissingKids:GetAttribute(v7[v10]) and localPlayer.Character and localPlayer.Character.PrimaryPart and v10 <= v:GetAttribute("KidProgress") then
							local attribute = workspace.Map.MissingKids:GetAttribute(v7[v10])
							local vector = Vector3.new(attribute.X, 0, attribute.Z)
							Client.CompassClient.AddIconToCompass("Kid" .. v10, v6[v10], vector)
						end

						LookAtPoster(parent2, v10)
					end
				end)
			end

			wait(1.5499999999999998)
		end
	end)
end

local clone = nil
local count2 = 0
local count3 = 0

function Unzoom()
	flag = false
	v3 = nil
	count3 += 1
	ReplicatedStorage.Core.Sounds.HorrorMusic:Stop()
	currentCamera.CameraType = cameraType
	proximityInteraction.Enabled = true
	Client.Interface.NoticeBoardClose.Visible = false
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
	local findFirstChild = v:FindFirstChild("Poster" .. 1)
	findFirstChild.Part.ClickDetector.MaxActivationDistance = 0
	local findFirstChild_2 = v:FindFirstChild("Poster" .. 2)
	findFirstChild_2.Part.ClickDetector.MaxActivationDistance = 0
	local findFirstChild_3 = v:FindFirstChild("Poster" .. 3)
	findFirstChild_3.Part.ClickDetector.MaxActivationDistance = 0
	local findFirstChild_4 = v:FindFirstChild("Poster" .. 4)
	findFirstChild_4.Part.ClickDetector.MaxActivationDistance = 0

	if v2 then
		v2.Part:PivotTo(cFramesByChild[v2])
	end

	if clone then
		clone:Destroy()
	end

	count2 += 1
	Client.Interface.MissingKidNotif.Visible = false
	local v8

	if v2 then
		v8 = tonumber((string.sub(v2.Name, 7)))
	end

	if v2 and v8 and v8 <= v:GetAttribute("KidProgress") and v2.Part:FindFirstChild("Alert") then
		v2.Part.Alert.Enabled = true
	end

	v2 = nil
end

function FlickerArrow(p, p2)
	if p and p.Transparency == 0 and flag then
		count2 += 1
		local v8 = count2
		task.spawn(function()
			for i = 1, 6 do
				if not (v8 == count2 and clone and clone.Parent) then
					continue
				end

				if i % 2 == 0 then
					Client.Interface.MissingKidNotif.Visible = true
					clone.Transparency = 0
					clone.darkred.Transparency = 0.65
					clone.darkred2.Transparency = 0.3
				else
					Client.Interface.MissingKidNotif.Visible = false
					clone.Transparency = 1
					clone.darkred.Transparency = 1
					clone.darkred2.Transparency = 1
				end

				wait(0.5)
			end

			if clone and flag and v3 == p2 then
				Client.Interface.MissingKidNotif.Visible = true
			else
				Client.Interface.MissingKidNotif.Visible = false
			end

			if clone and clone.Parent then
				clone.Transparency = 0
				clone.darkred.Transparency = 0.65
				clone.darkred2.Transparency = 0.3
			end
		end)
	end
end

function MakeArrow(p)
	if clone then
		clone:Destroy()
	end

	Client.Interface.MissingKidNotif.Visible = false
	local tagged = CollectionService:GetTagged("ChildNPC")
	local v8 = nil

	for _, v9 in pairs(tagged) do
		if v9:GetAttribute("KidId") == v7[p] then
			v8 = v9
		end
	end

	if (v8 or workspace.Map.MissingKids:GetAttribute(v7[p])) and localPlayer.Character and localPlayer.Character.PrimaryPart and p <= v:GetAttribute("KidProgress") then
		local vector

		if v8 then
			vector = Vector3.new(v8.PrimaryPart.Position.X, 5, v8.PrimaryPart.Position.Z)
		else
			local attribute = workspace.Map.MissingKids:GetAttribute(v7[p])
			vector = Vector3.new(attribute.X, 5, attribute.Z)
		end

		local magnitude = (v.PrimaryPart.Position - vector).Magnitude
		clone = ReplicatedStorage.Assets.Billboards.Arrow:Clone()
		clone.CFrame = currentCamera.CFrame:ToWorldSpace(cframe3)
		clone.Parent = workspace
		Client.Interface.MissingKidNotif.Text = math.floor(magnitude + 0.5) .. "m"
		Client.Interface.MissingKidNotif.Visible = true
		local vector2 = Vector3.new(vector.X, clone.Position.Y, vector.Z)
		clone.CFrame = CFrame.new(clone.Position, vector2) * CFrame.Angles(1.5707963267948966, 0, -1.5707963267948966)
		FlickerArrow(clone, p)
	end
end

function LookAtPoster(p, p2)
	count3 += 1
	local v8 = count3
	v2 = p
	TweenService:Create(p.Part, TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
		CFrame = currentCamera.CFrame:ToWorldSpace(cframe2)
	}):Play()
	MakeArrow(p2)
	local frame = p.Part.SurfaceGui.Frame

	local function checkTick()
		if v8 == count3 and frame and not frame.Smudge.Visible and v2 == p then
			return true
		end
	end

	Client.Sound.Play("PosterOpen")
	v3 = p2

	if not images[p] then
		ReplicatedStorage.Core.Sounds.HorrorMusic:Stop()
		images[p] = frame.ImageLabel.Image
	end

	task.spawn(function()
		wait(2.5)

		while v8 == count3 and frame and not frame.Smudge.Visible and v2 == p and true or nil do
			ReplicatedStorage.Core.Sounds.HorrorMusic:Play()

			for i = 1, #v5[p2] do
				if v8 ~= count3 or not frame or frame.Smudge.Visible or v2 ~= p then
					continue
				end

				frame.ImageLabel.Image = v5[p2][i]
				wait(1.75)
			end

			ReplicatedStorage.Core.Sounds.HorrorMusic:Stop()
			frame.ImageLabel.Image = images[p]

			if v8 ~= count3 or not frame or frame.Smudge.Visible or v2 ~= p then
				continue
			end

			FlickerArrow(clone, p2)
			wait(3.75)
		end

		if v8 == count3 then
			ReplicatedStorage.Core.Sounds.HorrorMusic:Stop()
		end

		frame.ImageLabel.Image = images[p]
	end)
end

local v8 = {}

local function AttributeChanged(folder)
	local name = folder.Name
	v8 = v8 or {}
	v8[name] = v8[name] or {}

	local function check()
		local v9 = nil

		for k, v10 in pairs(v7) do
			if v10 == name then
				v9 = k
			end
		end

		local child = v:FindFirstChild("Poster" .. v9)

		if child then
			local part = child:WaitForChild("Part")
			part.SurfaceGui.Frame.FoundLabel.Visible = true
			part.SurfaceGui.Frame.FoundLabel2.Visible = true
			part.SurfaceGui.Frame.FoundLabel3.Visible = true

			if part:FindFirstChild("Alert") then
				part.Alert:Destroy()
			end
		end
	end

	v8[name].attributeChanged = folder.AttributeChanged:Connect(function(p)
		if p == "Found" then
			check()
		end
	end)

	if folder:GetAttribute("Found") then
		check()
	end
end

local function InitializeFolders()
	local missingKidTracker = v.MissingKidTracker

	for _, folder in pairs(missingKidTracker:GetChildren()) do
		if folder:IsA("Folder") then
			AttributeChanged(folder)
		end
	end
end

local function SetupBoard(object)
	v = object
	proximityInteraction = object.Board:WaitForChild("AttachmentPart").ProximityAttachment.ProximityInteraction
	InitializeFolders()

	for i = 1, 4 do
		local child = v:FindFirstChild("Poster" .. i)
		cFramesByChild[child] = child:WaitForChild("Part").CFrame
		local v10 = i
		child.Part:WaitForChild("ClickDetector").MouseClick:Connect(function()
			if v2 == child then
				v2.Part.SurfaceGui.Frame.ImageLabel.Image = images[v2]
				ReplicatedStorage.Core.Sounds.HorrorMusic:Stop()

				if v2.Part:FindFirstChild("Alert") and v10 <= v:GetAttribute("KidProgress") then
					v2.Part.Alert.Enabled = true
				end

				v2 = nil
				TweenService:Create(
					child.Part,
					TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
					{
						CFrame = cFramesByChild[child]
					}
				):Play()

				if clone then
					clone:Destroy()
				end

				count2 += 1
				Client.Interface.MissingKidNotif.Visible = false
				count3 += 1
				v3 = nil
			elseif flag then
				if v2 then
					TweenService:Create(
						v2.Part,
						TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
						{
							CFrame = cFramesByChild[v2]
						}
					):Play()
					v2.Part.SurfaceGui.Frame.ImageLabel.Image = images[v2]
					ReplicatedStorage.Core.Sounds.HorrorMusic:Stop()
					local v11 = tonumber((string.sub(v2.Name, 7)))

					if v2.Part:FindFirstChild("Alert") and v11 <= v:GetAttribute("KidProgress") then
						v2.Part.Alert.Enabled = true
					end
				end

				if child.Part:FindFirstChild("Alert") and v10 <= v:GetAttribute("KidProgress") then
					child.Part.Alert.Enabled = false
					CollectionService:GetTagged("ChildNPC")

					if workspace.Map.MissingKids:GetAttribute(v7[v10]) and localPlayer.Character and localPlayer.Character.PrimaryPart and v10 <= v:GetAttribute("KidProgress") then
						local attribute = workspace.Map.MissingKids:GetAttribute(v7[v10])
						local vector = Vector3.new(attribute.X, 0, attribute.Z)
						Client.CompassClient.AddIconToCompass("Kid" .. v10, v6[v10], vector)
					end
				end

				LookAtPoster(child, v10)
			end
		end)
		local v11 = {}

		for _, v12 in pairs(v5[i]) do
			table.insert(v11, v12)
		end

		UtilityAlec.preload(v11)
	end

	local function adjustKidProgressDisplay()
		for i = 2, v:GetAttribute("KidProgress") do
			local child = v:FindFirstChild("Poster" .. i)

			if not child then
				continue
			end

			child.Part.SurfaceGui.Frame.Smudge.Visible = false

			if child.Part:FindFirstChild("Alert") then
				child.Part.Alert.Enabled = true
			end
		end
	end

	object:GetAttributeChangedSignal("KidProgress"):Connect(function()
		adjustKidProgressDisplay()
	end)
	adjustKidProgressDisplay()
end

function MissingPosterClient.Init()
	task.spawn(function()
		noticeBoardClose = Client.Interface.NoticeBoardClose
		noticeBoardClose.MouseButton1Down:Connect(function()
			Client.Sound.Play("CloseButton")
			Unzoom()
		end)
		ContextActionService:BindAction("CloseMissingPoster", function()
			if flag then
				Client.Sound.Play("CloseButton")
				Unzoom()
			end
		end, false, Enum.KeyCode.ButtonB)
		Client.Utility.ForAllTagged("NoticeBoard", SetupBoard)
	end)
end

return MissingPosterClient