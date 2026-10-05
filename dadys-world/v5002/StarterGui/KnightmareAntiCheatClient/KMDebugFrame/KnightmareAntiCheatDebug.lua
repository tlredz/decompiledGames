task.wait(2)
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local v

if workspace:GetAttribute("KM_DEBUG_SERVER_SCANNING_SPEED") then
	print("🔵 Starting Knightmare Anti-Cheat Service Debug GUI")
	v = true

	if workspace:GetAttribute("KM_DEBUG_GUI_TEXT_COLOR") then
		script.Parent.KMDebugTextOutputLabel.TextColor3 = workspace:GetAttribute("KM_DEBUG_GUI_TEXT_COLOR")
		script.Parent.FrameFPS.CurrentFPSTextLabel.TextColor3 = workspace:GetAttribute("KM_DEBUG_GUI_TEXT_COLOR")
	end

	if workspace:GetAttribute("KM_DEBUG_GUI_TEXT_SIZE") then
		script.Parent.KMDebugTextOutputLabel.TextSize = workspace:GetAttribute("KM_DEBUG_GUI_TEXT_SIZE")
	end

	if workspace:GetAttribute("KM_DEBUG_GUI_SIZE_X") and workspace:GetAttribute("KM_DEBUG_GUI_SIZE_Y") then
		script.Parent.Parent.KMDebugFrame.Size = UDim2.new(
			workspace:GetAttribute("KM_DEBUG_GUI_SIZE_X"),
			0,
			workspace:GetAttribute("KM_DEBUG_GUI_SIZE_Y"),
			0
		)
	end

	if workspace:GetAttribute("KM_DEBUG_GUI_DISABLE_BG") == true then
		script.Parent.Style = Enum.FrameStyle.Custom
		script.Parent.BackgroundTransparency = 1
		script.Parent.FrameFPS.Style = Enum.FrameStyle.Custom
		script.Parent.FrameFPS.BackgroundTransparency = 1
	end

	local UserInputService = game:GetService("UserInputService")
	local parent = script.Parent
	local mouse = localPlayer:GetMouse()
	local v2 = false
	local v3 = false
	local moveConnection = nil
	local v4 = nil
	local v5 = nil
	local position = nil

	local function Drag()
		if v3 == false then
			moveConnection:Disconnect()
			return
		end

		local v6 = v4 - mouse.X
		local v7 = v5 - mouse.Y
		parent.Position = position - UDim2.new(0, v6, 0, v7)
	end

	parent.MouseEnter:Connect(function()
		v2 = true
	end)
	parent.MouseLeave:Connect(function()
		v2 = false
	end)
	UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			v3 = v2

			if v3 then
				local X = mouse.X
				local Y = mouse.Y
				v4 = X
				v5 = Y
				position = parent.Position
				moveConnection = mouse.Move:Connect(Drag)
			end
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			v3 = false
		end
	end)
	script.Parent.Parent.KMDebugFrame.Visible = true
else
	if script:GetAttribute("KM_DEBUG_BANNER") and script:GetAttribute("KM_DEBUG_BANNER") ~= "" then
		print(script:GetAttribute("KM_DEBUG_BANNER"))
	end

	v = false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function round(p, value)
	if not p then
		return 0
	end

	local v2 = 10 ^ (value or 3)
	return math.round(p * v2) / v2
end

local KM_DEBUG_SERVER_SCANNING_SPEED = workspace:GetAttribute("KM_DEBUG_SERVER_SCANNING_SPEED") or 0
local v2 = nil
local v3 = nil
local v4 = nil
local v5 = nil
local v6 = nil
local v7 = nil
local v8 = nil
local v9 = nil
local v10 = nil
local v11 = nil
local v12 = nil
local v13 = nil
local v14 = nil
local v15 = nil
local v16 = nil
local v17 = nil
local v18 = nil
local v19 = nil
local v20 = nil
local v21 = nil
local v22 = nil
local v23 = 6
local v24 = 6
local v25 = 6
local v26 = 6
local v27 = 6

function updateDebugOutput()
	if (localPlayer:GetAttribute("KM_LOCAL_DEBUG_REFRESH_FPS") or 6) == 0 then
		return
	end

	KM_DEBUG_SERVER_SCANNING_SPEED = workspace:GetAttribute("KM_DEBUG_SERVER_SCANNING_SPEED") or 0
	local KM_DEBUG_RPT_PLAYER_PING = workspace:GetAttribute("KM_DEBUG_RPT_PLAYER_PING") or ""
	local KM_DEBUG_SPEED_CHEAT_PLAYER_SPEED = workspace:GetAttribute("KM_DEBUG_SPEED_CHEAT_PLAYER_SPEED") or ""
	local KM_DEBUG_SPEED_CHEAT_COUNTER = workspace:GetAttribute("KM_DEBUG_SPEED_CHEAT_COUNTER") or ""
	local KM_DEBUG_SPEED_CHEAT_SPEED_EXCEPTION_ACTIVE = workspace:GetAttribute("KM_DEBUG_SPEED_CHEAT_SPEED_EXCEPTION_ACTIVE") or ""
	local KM_DEBUG_SPEED_CHEAT_MAX_DETECTIONS = workspace:GetAttribute("KM_DEBUG_SPEED_CHEAT_MAX_DETECTIONS") or ""
	local KM_DEBUG_SPEED_CHEAT_MAX_FREE_FALL_EXCEEDED = workspace:GetAttribute("KM_DEBUG_SPEED_CHEAT_MAX_FREE_FALL_EXCEEDED") or ""
	local KM_DEBUG_SPEED_CHEAT_FREE_FALL_TIME = workspace:GetAttribute("KM_DEBUG_SPEED_CHEAT_FREE_FALL_TIME") or ""
	local KM_DEBUG_FLY_CHEAT_STANDING_OBJECT_RAY = workspace:GetAttribute("KM_DEBUG_FLY_CHEAT_STANDING_OBJECT_RAY") or ""
	local KM_DEBUG_FLY_CHEAT_STANDING_OBJECT_RADIUS = workspace:GetAttribute("KM_DEBUG_FLY_CHEAT_STANDING_OBJECT_RADIUS") or ""
	local KM_DEBUG_FLY_CHEAT_LINEAR_VELOCITY = workspace:GetAttribute("KM_DEBUG_FLY_CHEAT_LINEAR_VELOCITY") or ""
	local KM_DEBUG_FLY_CHEAT_FLOATING_TIMER = workspace:GetAttribute("KM_DEBUG_FLY_CHEAT_FLOATING_TIMER") or ""
	local KM_DEBUG_FLY_CHEAT_COUNTER = workspace:GetAttribute("KM_DEBUG_FLY_CHEAT_COUNTER") or ""
	local KM_DEBUG_FLY_CHEAT_DETECTED = workspace:GetAttribute("KM_DEBUG_FLY_CHEAT_DETECTED") or ""
	local KM_DEBUG_FLY_CHEAT_EXCEPTION_ACTIVE = workspace:GetAttribute("KM_DEBUG_FLY_CHEAT_EXCEPTION_ACTIVE") or ""
	local KM_DEBUG_TELEPORT_CHEAT_DISTANCE = workspace:GetAttribute("KM_DEBUG_TELEPORT_CHEAT_DISTANCE") or ""
	local KM_DEBUG_TELEPORT_CHEAT_HIT_OBJECT = workspace:GetAttribute("KM_DEBUG_TELEPORT_CHEAT_HIT_OBJECT") or ""
	local KM_DEBUG_TELEPORT_CHEAT_EXCEPTION_ACTIVE = workspace:GetAttribute("KM_DEBUG_TELEPORT_CHEAT_EXCEPTION_ACTIVE") or ""
	local KM_DEBUG_TELEPORT_CHEAT_DETECTED = workspace:GetAttribute("KM_DEBUG_TELEPORT_CHEAT_DETECTED") or ""
	local KM_DEBUG_JUMP_CHEAT_DISTANCE = workspace:GetAttribute("KM_DEBUG_JUMP_CHEAT_DISTANCE") or ""
	local KM_DEBUG_JUMP_CHEAT_EXCEPTION_ACTIVE = workspace:GetAttribute("KM_DEBUG_JUMP_CHEAT_EXCEPTION_ACTIVE") or ""
	local KM_DEBUG_JUMP_CHEAT_MAX_JUMP_HEIGHT = workspace:GetAttribute("KM_DEBUG_JUMP_CHEAT_MAX_JUMP_HEIGHT") or ""
	local text

	if KM_DEBUG_SERVER_SCANNING_SPEED == 0 then
		text = ""
	else
		local v29 = KM_DEBUG_SERVER_SCANNING_SPEED < 0.22 and "🟢" or KM_DEBUG_SERVER_SCANNING_SPEED < 0.3 and "🟡" or "🔴"
		local v33 = round(1 / KM_DEBUG_SERVER_SCANNING_SPEED, 0) -- equivalent call inferred; original call site unknown
		text = v29 .. "Scan FPS⏱️: " .. tostring(v33) .. "\n"
	end

	if KM_DEBUG_RPT_PLAYER_PING == "" then
		if v2 then
			text ..= v2
			v2 = nil
		end
	else
		text ..= KM_DEBUG_RPT_PLAYER_PING
		v2 = KM_DEBUG_RPT_PLAYER_PING
	end

	if KM_DEBUG_SPEED_CHEAT_PLAYER_SPEED == "" then
		if v3 then
			text ..= v3
			v3 = nil
		end
	else
		text ..= KM_DEBUG_SPEED_CHEAT_PLAYER_SPEED
		v3 = KM_DEBUG_SPEED_CHEAT_PLAYER_SPEED
	end

	if KM_DEBUG_SPEED_CHEAT_COUNTER == "" then
		if v4 then
			text ..= v4

			if v23 == 0 then
				v4 = nil
			end
		end
	else
		text ..= KM_DEBUG_SPEED_CHEAT_COUNTER
		v4 = KM_DEBUG_SPEED_CHEAT_COUNTER
		v23 = 6
	end

	if KM_DEBUG_SPEED_CHEAT_SPEED_EXCEPTION_ACTIVE == "" then
		if v5 then
			text ..= v5

			if v23 == 0 then
				v5 = nil
			end
		end
	else
		text ..= KM_DEBUG_SPEED_CHEAT_SPEED_EXCEPTION_ACTIVE
		v5 = KM_DEBUG_SPEED_CHEAT_SPEED_EXCEPTION_ACTIVE
		v23 = 6
	end

	if KM_DEBUG_SPEED_CHEAT_FREE_FALL_TIME == "" then
		if v6 then
			text ..= v6

			if v23 < 3 then
				v6 = nil
			end
		end
	else
		text ..= KM_DEBUG_SPEED_CHEAT_FREE_FALL_TIME
		v6 = KM_DEBUG_SPEED_CHEAT_FREE_FALL_TIME
		v23 = 6
	end

	if KM_DEBUG_SPEED_CHEAT_MAX_FREE_FALL_EXCEEDED == "" then
		if v7 then
			text ..= v7

			if v23 < 2 then
				v7 = nil
			end
		end
	else
		text ..= KM_DEBUG_SPEED_CHEAT_MAX_FREE_FALL_EXCEEDED
		v7 = KM_DEBUG_SPEED_CHEAT_MAX_FREE_FALL_EXCEEDED
		v23 = 6
	end

	if KM_DEBUG_SPEED_CHEAT_MAX_DETECTIONS == "" then
		if v8 then
			text ..= v8

			if v23 == 0 then
				v8 = nil
			end
		end
	else
		text ..= KM_DEBUG_SPEED_CHEAT_MAX_DETECTIONS
		v8 = KM_DEBUG_SPEED_CHEAT_MAX_DETECTIONS
		v23 = 6
	end

	if KM_DEBUG_TELEPORT_CHEAT_DISTANCE == "" then
		if v9 then
			text ..= v9
			v9 = nil
		end
	else
		text ..= KM_DEBUG_TELEPORT_CHEAT_DISTANCE
		v9 = KM_DEBUG_TELEPORT_CHEAT_DISTANCE
	end

	if KM_DEBUG_TELEPORT_CHEAT_EXCEPTION_ACTIVE == "" then
		if v11 then
			text ..= v11

			if v25 == 0 then
				v11 = nil
			end
		end
	else
		text ..= KM_DEBUG_TELEPORT_CHEAT_EXCEPTION_ACTIVE
		v11 = KM_DEBUG_TELEPORT_CHEAT_EXCEPTION_ACTIVE
		v25 = 6
	end

	if KM_DEBUG_TELEPORT_CHEAT_DETECTED == "" then
		if v12 then
			text ..= v12

			if v25 == 0 then
				v12 = nil
			end
		end
	else
		text ..= KM_DEBUG_TELEPORT_CHEAT_DETECTED
		v12 = KM_DEBUG_TELEPORT_CHEAT_DETECTED
		v25 = 6
	end

	if KM_DEBUG_TELEPORT_CHEAT_HIT_OBJECT == "" then
		if v10 then
			text ..= v10

			if v25 == 0 then
				v10 = nil
			end
		end
	else
		text ..= KM_DEBUG_TELEPORT_CHEAT_HIT_OBJECT
		v10 = KM_DEBUG_TELEPORT_CHEAT_HIT_OBJECT
		v25 = 6
	end

	if KM_DEBUG_JUMP_CHEAT_DISTANCE == "" then
		if v13 then
			text ..= v13

			if v27 == 0 then
				v13 = nil
			end
		end
	else
		text ..= KM_DEBUG_JUMP_CHEAT_DISTANCE
		v13 = KM_DEBUG_JUMP_CHEAT_DISTANCE
		v27 = 6
	end

	if KM_DEBUG_JUMP_CHEAT_MAX_JUMP_HEIGHT == "" then
		if v14 then
			text ..= v14

			if v26 == 0 then
				v14 = nil
			end
		end
	else
		text ..= KM_DEBUG_JUMP_CHEAT_MAX_JUMP_HEIGHT
		v14 = KM_DEBUG_JUMP_CHEAT_MAX_JUMP_HEIGHT
		v26 = 6
	end

	if KM_DEBUG_JUMP_CHEAT_EXCEPTION_ACTIVE == "" then
		if v15 then
			text ..= v15

			if v26 == 0 then
				v15 = nil
			end
		end
	else
		text ..= KM_DEBUG_JUMP_CHEAT_EXCEPTION_ACTIVE
		v15 = KM_DEBUG_JUMP_CHEAT_EXCEPTION_ACTIVE
		v26 = 6
	end

	if KM_DEBUG_FLY_CHEAT_STANDING_OBJECT_RAY == "" then
		if v16 then
			text ..= v16
			v16 = nil
		end
	else
		text ..= KM_DEBUG_FLY_CHEAT_STANDING_OBJECT_RAY
		v16 = KM_DEBUG_FLY_CHEAT_STANDING_OBJECT_RAY
	end

	if KM_DEBUG_FLY_CHEAT_STANDING_OBJECT_RADIUS == "" then
		if v17 then
			text ..= v17
			v17 = nil
		end
	else
		text ..= KM_DEBUG_FLY_CHEAT_STANDING_OBJECT_RADIUS
		v17 = KM_DEBUG_FLY_CHEAT_STANDING_OBJECT_RADIUS
	end

	if KM_DEBUG_FLY_CHEAT_LINEAR_VELOCITY == "" then
		if v18 then
			text ..= v18

			if v24 < 3 then
				v18 = nil
			end
		end
	else
		text ..= KM_DEBUG_FLY_CHEAT_LINEAR_VELOCITY
		v18 = KM_DEBUG_FLY_CHEAT_LINEAR_VELOCITY
		v24 = 6
	end

	if KM_DEBUG_FLY_CHEAT_FLOATING_TIMER == "" then
		if v19 then
			text ..= v19

			if v24 < 3 then
				v19 = nil
			end
		end
	else
		text ..= KM_DEBUG_FLY_CHEAT_FLOATING_TIMER
		v19 = KM_DEBUG_FLY_CHEAT_FLOATING_TIMER
		v24 = 6
	end

	if KM_DEBUG_FLY_CHEAT_COUNTER == "" then
		if v20 then
			text ..= v20

			if v24 < 3 then
				v20 = nil
			end
		end
	else
		text ..= KM_DEBUG_FLY_CHEAT_COUNTER
		v20 = KM_DEBUG_FLY_CHEAT_COUNTER
		v24 = 6
	end

	if KM_DEBUG_FLY_CHEAT_DETECTED == "" then
		if v21 then
			text ..= v21

			if v24 == 0 then
				v21 = nil
			end
		end
	else
		text ..= KM_DEBUG_FLY_CHEAT_DETECTED
		v21 = KM_DEBUG_FLY_CHEAT_DETECTED
		v24 = 6
	end

	if KM_DEBUG_FLY_CHEAT_EXCEPTION_ACTIVE == "" then
		if v22 then
			text ..= v22

			if v24 == 0 then
				v22 = nil
			end
		end
	else
		text ..= KM_DEBUG_FLY_CHEAT_EXCEPTION_ACTIVE
		v22 = KM_DEBUG_FLY_CHEAT_EXCEPTION_ACTIVE
		v24 = 6
	end

	script.Parent.KMDebugTextOutputLabel.Text = text
end

local v28 = 5

function increaseFPS()
	local KM_LOCAL_DEBUG_REFRESH_FPS = localPlayer:GetAttribute("KM_LOCAL_DEBUG_REFRESH_FPS") or 6

	if KM_LOCAL_DEBUG_REFRESH_FPS < v28 + 1 then
		localPlayer:SetAttribute("KM_LOCAL_DEBUG_REFRESH_FPS", KM_LOCAL_DEBUG_REFRESH_FPS + 1)
		script.Parent.FrameFPS.CurrentFPSTextLabel.Text = "🐞" .. tostring(KM_LOCAL_DEBUG_REFRESH_FPS + 1) .. " FPS"
	end
end

function decreaseFPS()
	local KM_LOCAL_DEBUG_REFRESH_FPS = localPlayer:GetAttribute("KM_LOCAL_DEBUG_REFRESH_FPS") or 6

	if KM_LOCAL_DEBUG_REFRESH_FPS > 0 then
		localPlayer:SetAttribute("KM_LOCAL_DEBUG_REFRESH_FPS", KM_LOCAL_DEBUG_REFRESH_FPS - 1)
		script.Parent.FrameFPS.CurrentFPSTextLabel.Text = "🐞" .. tostring(KM_LOCAL_DEBUG_REFRESH_FPS - 1) .. " FPS"
	end
end

script.Parent.FrameFPS.DownTextButton.Activated:Connect(decreaseFPS)
script.Parent.FrameFPS.UpTextButton.Activated:Connect(increaseFPS)
local v29 = 5

while v == true do
	local KM_LOCAL_DEBUG_REFRESH_FPS = localPlayer:GetAttribute("KM_LOCAL_DEBUG_REFRESH_FPS") or 6
	local v32 = round(1 / KM_DEBUG_SERVER_SCANNING_SPEED, 0) -- equivalent call inferred; original call site unknown

	if v28 < v32 then
		if KM_LOCAL_DEBUG_REFRESH_FPS - 1 == v28 then
			localPlayer:SetAttribute("KM_LOCAL_DEBUG_REFRESH_FPS", v32 + 1)
			script.Parent.FrameFPS.CurrentFPSTextLabel.Text = "🐞" .. tostring(v32 + 1) .. " FPS"
		end

		v28 = v32
	end

	if KM_LOCAL_DEBUG_REFRESH_FPS > 0 then
		updateDebugOutput()

		if v29 == 0 then
			if v23 > 0 then
				v23 -= 1
			end

			if v24 > 0 then
				v24 -= 1
			end

			if v25 > 0 then
				v25 -= 1
			end

			if v26 > 0 then
				v26 -= 1
			end

			if v27 > 0 then
				v27 -= 1
			end

			v29 = math.abs(1 / (1 / KM_LOCAL_DEBUG_REFRESH_FPS) - 1)
		else
			v29 -= 1
		end
	end

	if KM_LOCAL_DEBUG_REFRESH_FPS > 0 then
		task.wait(1 / KM_LOCAL_DEBUG_REFRESH_FPS)
	else
		task.wait(1)
	end
end

script.Parent:Destroy()