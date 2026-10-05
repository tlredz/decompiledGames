local localPlayer = game.Players.LocalPlayer
local mouse = localPlayer:GetMouse()
local PlatformHandler = {
	Shift_lock = 1
}
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local gameSettings = require(ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("gameSettings"))
PlatformHandler.Test = ""
PlatformHandler.Forced = ""
local v = {
	PC = 1,
	Mobile = 2,
	Xbox = 3,
	Playstation = 4
}
local isStudio = RunService:IsStudio()

function PlatformHandler.update_platform()
	local forced, id

	if game.Players.LocalPlayer:FindFirstChild("PlayerGui") == nil or game.Players.LocalPlayer.PlayerGui:FindFirstChild("TouchGui") == nil or game.Players.LocalPlayer.PlayerGui.TouchGui:FindFirstChild("TouchControlFrame") == nil or game.Players.LocalPlayer.PlayerGui.TouchGui.TouchControlFrame:FindFirstChild("JumpButton") == nil then
		forced = "PC"
		id = 1
	else
		forced = "Mobile"
		id = 2
	end

	if forced ~= "Mobile" and UserInputService.TouchEnabled and not (UserInputService.KeyboardEnabled or UserInputService.MouseEnabled) then
		forced = "Mobile"
		id = 2
	end

	if UserInputService.GamepadEnabled == true and forced ~= "Mobile" then
		local lastInputType = UserInputService:GetLastInputType()

		if lastInputType ~= Enum.UserInputType.Keyboard and lastInputType.Name:sub(1, 5) ~= "Mouse" then
			if UserInputService:GetStringForKeyCode(Enum.KeyCode.ButtonY) == "ButtonTriangle" then
				forced = "Playstation"
				id = 4
			else
				forced = "Xbox"
				id = 3
			end
		end
	end

	if PlatformHandler.Forced == "Console" then
		if forced ~= "Xbox" and forced ~= "Playstation" then
			forced = "Xbox"
			id = 3
		end
	elseif v[PlatformHandler.Forced] ~= nil then
		forced = PlatformHandler.Forced
		id = v[PlatformHandler.Forced]
	end

	if isStudio and v[PlatformHandler.Test] ~= nil then
		forced = PlatformHandler.Test
		id = v[PlatformHandler.Test]
	end

	if PlatformHandler.Platform.Value ~= forced then
		PlatformHandler.Platform.Value = forced
		PlatformHandler.Platform.Id = id
		PlatformHandler.Platform.Changed:Fire(forced, id)
	end

	UserInputService.MouseIconEnabled = forced ~= "Xbox" and forced ~= "Playstation"
	return forced, id
end

PlatformHandler.Apply = PlatformHandler.update_platform
PlatformHandler.Platform = {
	Value = "",
	Id = 0,
	Changed = script:WaitForChild("Event")
}
local update_platform, id2 = PlatformHandler.update_platform()
PlatformHandler.Platform.Value = update_platform
PlatformHandler.Platform.Id = id2
UserInputService.GamepadConnected:Connect(PlatformHandler.update_platform)
UserInputService.GamepadDisconnected:Connect(PlatformHandler.update_platform)
UserInputService.LastInputTypeChanged:Connect(PlatformHandler.update_platform)
task.spawn(function()
	local playerGui = localPlayer:WaitForChild("PlayerGui", 30)

	if playerGui == nil then
		return
	end

	playerGui.DescendantAdded:Connect(function(descendant)
		if descendant.Name == "JumpButton" or descendant.Name == "TouchGui" then
			task.defer(PlatformHandler.update_platform)
		end
	end)
	PlatformHandler.update_platform()
end)

function PlatformHandler.ShowsKeyLabels()
	return PlatformHandler.Platform.Value == "PC"
end

function PlatformHandler.IsGamepad()
	return PlatformHandler.Platform.Value == "Xbox" or PlatformHandler.Platform.Value == "Playstation"
end

function PlatformHandler.KeyLabelOffset()
	if PlatformHandler.ShowsKeyLabels() then
		return gameSettings.KeybindTextOffset
	end

	return 0
end

function PlatformHandler.Get_Key_Visual(p)
	if p == nil then
		return
	end

	local imageForKeyCode = UserInputService:GetImageForKeyCode(Enum.KeyCode[p])
	local v3

	if imageForKeyCode and #imageForKeyCode > 0 then
		v3 = "Image"
	else
		imageForKeyCode = p
		v3 = "Text"
	end

	return imageForKeyCode, v3
end

local v3 = nil
local v4 = nil
local zero = Vector2.zero
local zero2 = Vector2.zero
local now = 0
local v5 = 0
local v6 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function pointerOf(p)
	if p.UserInputType == Enum.UserInputType.Touch then
		return Vector2.new(p.Position.X, p.Position.Y)
	end

	return UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
end

local v7 = {
	Dash = true,
	Blocking = true,
	["Double Jump"] = true
}

local function heldSkill()
	local character = localPlayer.Character
	local SHC

	if character ~= nil then
		SHC = character:FindFirstChild("SHC")
	end

	if SHC == nil then
		return ""
	end

	return SHC.Value
end

local function holdingSkill()
	local character = localPlayer.Character
	local SHC

	if character ~= nil then
		SHC = character:FindFirstChild("SHC")
	end

	local v8 = SHC == nil and "" or SHC.Value
	return v8 ~= "" and v7[v8] ~= true
end

function PlatformHandler.AimCentre()
	local guiInset = GuiService:GetGuiInset()
	local viewportSize = workspace.CurrentCamera.ViewportSize
	return Vector2.new(viewportSize.X / 2 - guiInset.X, viewportSize.Y / 2 - guiInset.Y)
end

function PlatformHandler.HoldingSkill()
	local character = localPlayer.Character
	local SHC

	if character ~= nil then
		SHC = character:FindFirstChild("SHC")
	end

	local v8 = SHC == nil and "" or SHC.Value
	return v8 ~= "" and v7[v8] ~= true
end

function PlatformHandler.AimActive()
	if PlatformHandler.Platform.Value == "Mobile" then
		local now2 = os.clock()
		local character = localPlayer.Character
		local SHC

		if character ~= nil then
			SHC = character:FindFirstChild("SHC")
		end

		local v8 = SHC == nil and "" or SHC.Value
		local v9

		if v8 == "" then
			v9 = false
		else
			v9 = v7[v8] ~= true
		end

		if v9 then
			v5 = now2
			return true
		end

		return now2 - v5 <= 1 and now2 - now <= 0.3
	else
		if not PlatformHandler.IsGamepad() then
			return false
		end

		local character = localPlayer.Character
		local SHC

		if character ~= nil then
			SHC = character:FindFirstChild("SHC")
		end

		local v8 = SHC == nil and "" or SHC.Value
		return v8 ~= "" and v7[v8] ~= true or v6
	end
end

function PlatformHandler.SetAimLock(flag: boolean)
	v6 = flag == true
end

function PlatformHandler.BeginAim(p)
	if not PlatformHandler.AimActive() then
		zero2 = Vector2.zero
	end

	v3 = p
	v4 = pointerOf(p) -- equivalent call inferred; original call site unknown
	zero = zero2
end

function PlatformHandler.EndAim(p)
	if p ~= v3 then
		return
	end

	v3 = nil
	v4 = nil
end

local v8 = nil

function PlatformHandler.SkillDragTurnsCamera()
	if v8 ~= nil then
		return v8:Get() == true
	end

	local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
	local SettingsKeys = require(ReplicatedStorage2.CAM.Global.Subsets.Gameplay.SettingsKeys)
	local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
	local DataValue = require(ReplicatedStorage3.CAM.Client.Modules.DataValue)
	local mobileSkillDragTurnsCamera = SettingsKeys.MobileSkillDragTurnsCamera
	v8 = DataValue.new(mobileSkillDragTurnsCamera.Path, mobileSkillDragTurnsCamera.Default, SettingsKeys.Scope)
	return v8:Get() == true
end

function PlatformHandler.AimInput()
	return v3
end

function PlatformHandler.AimPoint()
	if PlatformHandler.Platform.Value ~= "Mobile" and not PlatformHandler.IsGamepad() then
		return Vector2.new(mouse.X, mouse.Y)
	end

	local aimCentre = PlatformHandler.AimCentre()
	local v9 = v3
	local v10 = v4

	if v9 ~= nil and v10 ~= nil and not PlatformHandler.SkillDragTurnsCamera() then
		local v11 = zero
		local v12 = pointerOf(v9) -- equivalent call inferred; original call site unknown
		zero2 = v11 + (v12 - v10)
	end

	local v11 = workspace.CurrentCamera.ViewportSize - GuiService:GetGuiInset()
	local v12 = aimCentre + zero2
	return Vector2.new(math.clamp(v12.X, 0, v11.X), (math.clamp(v12.Y, 0, v11.Y)))
end

function PlatformHandler.NudgeAim(point: Vector2)
	zero2 += point

	if v3 ~= nil then
		zero += point
	end
end

function getmouse_cor(p: string?)
	if not p then
		local character = localPlayer.Character
		local SHC

		if character ~= nil then
			SHC = character:FindFirstChild("SHC")
		end

		p = SHC == nil and "" or SHC.Value
	end

	if v7[p] ~= true then
		now = os.clock()
	end

	local aimPoint = PlatformHandler.AimPoint()
	return aimPoint.X, aimPoint.Y
end

local currentCamera = workspace.CurrentCamera
local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = { workspace.Debree }
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
local character = nil
local find = table.find

function PlatformHandler.mousepos(value: number?, p, p2: string?)
	if localPlayer.Character ~= nil and character ~= localPlayer.Character and find(
		raycastParams.FilterDescendantsInstances,
		localPlayer.Character
	) == nil then
		raycastParams.FilterDescendantsInstances = { workspace.Debree, localPlayer.Character }
		character = localPlayer.Character
	end

	local v9, v10 = getmouse_cor(p2)
	local screenPointToRay = currentCamera:ScreenPointToRay(v9, v10)
	local v11 = screenPointToRay.Direction * math.max(value or 500, 500)
	local position = nil

	if p ~= nil then
		local raycastResult = workspace:Raycast(screenPointToRay.Origin, v11, p)

		if raycastResult ~= nil and raycastResult.Position ~= nil then
			position = raycastResult.Position
		end
	end

	if position == nil then
		local raycastResult = workspace:Raycast(screenPointToRay.Origin, v11, raycastParams)
		position = raycastResult ~= nil and raycastResult.Position ~= nil and raycastResult.Position or screenPointToRay.Origin + v11
	end

	if value == nil then
		return position
	end

	local humanoidRootPart

	if localPlayer.Character == nil then
		humanoidRootPart = false
	else
		humanoidRootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
	end

	if humanoidRootPart ~= nil then
		local v12 = position - humanoidRootPart.Position

		if value < v12.Magnitude then
			position = humanoidRootPart.Position + v12.Unit * value
		end
	end

	return position
end

function PlatformHandler.getMouseDirection(vector2: Vector3?, position)
	if vector2 == nil then
		vector2 = PlatformHandler.mousepos()
	end

	if position == nil and game.Players.LocalPlayer.Character ~= nil then
		position = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
	end

	return (vector.normalize(vector2 - vector.create(position.X, vector2.Y, position.Z)))
end

return PlatformHandler