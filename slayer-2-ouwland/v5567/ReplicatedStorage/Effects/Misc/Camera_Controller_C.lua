local localPlayer = game.Players.LocalPlayer
local camAnim = script:WaitForChild("CamAnim")
local currentCamera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
currentCamera.CameraType = Enum.CameraType.Custom
local child = game.ReplicatedStorage.Player_Service:WaitForChild("Values"):WaitForChild(localPlayer.Name)
local playerGui = localPlayer:WaitForChild("PlayerGui")
local Camera_Traffic_Handler = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Controllers"):WaitForChild("Camera_Traffic_Handler"))
local v = nil
local CutsceneLines = require(ReplicatedStorage.CAM.Client.Components.Client.CutsceneLines)
local v2 = true
local v3 = 0
local v4 = nil
local v5 = nil
game.Players.LocalPlayer.CharacterAdded:Connect(function()
	for _, v6 in pairs(game.CollectionService:GetTagged("cutscene_tag123")) do
		local bindname = v6:GetAttribute("bindname")

		if bindname then
			RunService:UnbindFromRenderStep(bindname)
		end
	end

	if child:FindFirstChild("Cutscene_Cam") ~= nil then
		child.Cutscene_Cam:Destroy()
	end

	v = nil

	if v4 ~= nil then
		v4()
		v4 = nil
	end

	if playerGui:FindFirstChild("Cutscene_Cam_Gui") ~= nil then
		playerGui.Cutscene_Cam_Gui:Destroy()
	end

	v3 = 0

	if Camera_Traffic_Handler.Cutscene ~= false then
		Camera_Traffic_Handler.Cutscene = false
		RunService:UnbindFromRenderStep("cambind")
	end
end)
local cFrame = nil
local cFrame2 = nil

function upd_cam_bind(p)
	if p == v then
		return
	end

	v = p

	if child:FindFirstChild("Cutscene_Cam") ~= nil then
		child.Cutscene_Cam:Destroy()
	end

	if v4 == nil then
		if playerGui:FindFirstChild("Cutscene_Cam_Gui") ~= nil then
			playerGui.Cutscene_Cam_Gui:Destroy()
		end
	else
		v4()
		v4 = nil
		local cutscene_Cam_Gui = playerGui:FindFirstChild("Cutscene_Cam_Gui")

		if cutscene_Cam_Gui ~= nil then
			task.delay(v5, cutscene_Cam_Gui.Destroy, cutscene_Cam_Gui)
		end
	end

	if p == true then
		if game.Players.LocalPlayer.Character ~= nil and game.Players.LocalPlayer.Character.PrimaryPart ~= nil then
			cFrame2 = game.Players.LocalPlayer.Character.PrimaryPart.CFrame
		end

		cFrame = currentCamera.CFrame

		if v2 then
			local screenGui = Instance.new("ScreenGui")
			screenGui.DisplayOrder = -1
			screenGui.ScreenInsets = Enum.ScreenInsets.None
			screenGui.Name = "Cutscene_Cam_Gui"
			screenGui.Parent = playerGui
			v4, v5 = CutsceneLines(screenGui)
		end

		local boolValue = Instance.new("BoolValue")
		boolValue.Name = "Cutscene_Cam"
		boolValue.Parent = child
	elseif cFrame ~= nil then
		local cFrame3

		if cFrame2 == nil or game.Players.LocalPlayer.Character == nil or game.Players.LocalPlayer.Character.PrimaryPart == nil then
			cFrame3 = cFrame
		else
			local v7 = cFrame2:Inverse() * cFrame
			cFrame3 = game.Players.LocalPlayer.Character.PrimaryPart.CFrame * v7
		end

		currentCamera.CFrame = cFrame3
		cFrame = nil
		cFrame2 = nil
	end
end

upd_cam_bind(false)

function cam_bind()
	if Camera_Traffic_Handler.Equipped_Hirearchy == "Cutscene" then
		currentCamera.CFrame = camAnim.Value
	end
end

function upd_cam_changed(_)
	if Camera_Traffic_Handler.Cutscene ~= true then
		upd_cam_bind(true)
		RunService:BindToRenderStep("cambind", Enum.RenderPriority.Camera.Value, cam_bind)
		Camera_Traffic_Handler.Cutscene = true
	end

	local v6 = math.random(1, 999999)
	v3 = v6
	wait(0.075)

	if v3 == v6 and Camera_Traffic_Handler.Cutscene ~= false then
		upd_cam_bind(false)
		Camera_Traffic_Handler.Cutscene = false
		RunService:UnbindFromRenderStep("cambind")
	end
end

local tostring2 = tostring
return function(instance, value, p)
	if instance == nil then
		return
	end

	if typeof(value) == "boolean" then
		p = value
		value = nil
	end

	v2 = not p

	if value ~= nil then
		local v6 = string.split(value, ">")

		for _, childName in pairs(v6) do
			instance = instance:WaitForChild(childName, 3)

			if instance == nil then
				break
			end
		end
	end

	if instance == nil then
		return
	end

	local isA = instance:IsA("Bone")

	if not (instance:IsA("BasePart") or isA) then
		return
	end

	local v6 = instance:GetFullName() .. tostring2(math.random(1, 999))
	RunService:UnbindFromRenderStep(v6)
	instance:SetAttribute("bindname", v6)
	instance:AddTag("cutscene_tag123")
	RunService:BindToRenderStep(v6, Enum.RenderPriority.Camera.Value, function()
		if instance == nil or instance.Parent == nil or not instance:IsDescendantOf(workspace) then
			RunService:UnbindFromRenderStep(v6)
			return
		end

		local worldCFrame

		if isA then
			worldCFrame = instance.WorldCFrame
		else
			worldCFrame = instance.CFrame
		end

		if camAnim.Value ~= worldCFrame then
			camAnim.Value = worldCFrame
		end

		upd_cam_changed(v6)
	end)
	local parentChangedConnection = nil
	parentChangedConnection = instance:GetPropertyChangedSignal("Parent"):Connect(function()
		if parentChangedConnection ~= nil then
			parentChangedConnection:Disconnect()
			parentChangedConnection = nil
		end

		RunService:UnbindFromRenderStep(v6)
	end)
end