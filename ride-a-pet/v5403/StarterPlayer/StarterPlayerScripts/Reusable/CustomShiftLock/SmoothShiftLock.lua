local createVector = vector.create
local SmoothShiftLock = {}
SmoothShiftLock.__index = SmoothShiftLock
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
game:GetService("TweenService")
local Maid = require(script.Utils:WaitForChild("Maid"))
local Spring = require(script.Utils:WaitForChild("Spring"))
local localPlayer = Players.LocalPlayer
local mobileCrosshair = localPlayer.PlayerGui:WaitForChild("Main"):WaitForChild("MobileCrosshair", 1)
local toggleShiftLock = script:WaitForChild("ToggleShiftLock")
local editConfig = script:WaitForChild("EditConfig")
local v = {
	CHARACTER_SMOOTH_ROTATION = true,
	MANUALLY_TOGGLEABLE = true,
	CHARACTER_ROTATION_SPEED = 3,
	TRANSITION_SPRING_DAMPER = 0.7,
	CAMERA_TRANSITION_IN_SPEED = 10,
	CAMERA_TRANSITION_OUT_SPEED = 14,
	LOCKED_CAMERA_OFFSET = createVector(0, 0, 0),
	LOCKED_MOUSE_ICON = "rbxassetid://112139393637030",
	SHIFT_LOCK_KEYBINDS = { Enum.KeyCode.LeftShift, Enum.KeyCode.RightShift }
}
local v2 = false
local maid = Maid.new()

function SmoothShiftLock:Init()
	local maid2 = Maid.new()

	if localPlayer.Character then
		coroutine.wrap(function()
			self:CharacterAdded()
		end)()
	end

	maid2:GiveTask(localPlayer.CharacterAdded:Connect(function()
		coroutine.wrap(function()
			self:CharacterAdded()
		end)()
	end))
end

function SmoothShiftLock:CharacterAdded()
	local object = setmetatable({}, SmoothShiftLock)
	object.Character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
	object.RootPart = object.Character:WaitForChild("HumanoidRootPart")
	object.Humanoid = object.Character:WaitForChild("Humanoid")
	object.Head = object.Character:WaitForChild("Head")
	object.Camera = Workspace.CurrentCamera
	object._connectionsMaid = Maid.new()
	object.camOffsetSpring = Spring.new(createVector(0, 0, 0))
	object.camOffsetSpring.Damper = v.TRANSITION_SPRING_DAMPER
	object._connectionsMaid:GiveTask(RunService.RenderStepped:Connect(function()
		if object.Head.LocalTransparencyModifier > 0.6 then
			return
		end

		local coordinateFrame = object.Camera.CoordinateFrame

		if (object.Head.Position - coordinateFrame.p).magnitude > 1 then
			object.Camera.CFrame = object.Camera.CFrame * CFrame.new(object.camOffsetSpring.Position)

			if v2 and UserInputService.MouseBehavior ~= Enum.MouseBehavior.LockCenter then
				object:SetMouseState(v2)
			end
		end
	end))
	object._connectionsMaid:GiveTask(toggleShiftLock.Event:Connect(function(flag: boolean)
		if object.Humanoid and object.Humanoid.Health ~= 0 then
			object:ToggleShiftLock(flag)
		end
	end))
	object._connectionsMaid:GiveTask(editConfig.Event:Connect(function(p, p2)
		if v[p] ~= nil then
			v[p] = p2
		end
	end))
	object._connectionsMaid:GiveTask(object.Humanoid.Died:Connect(function()
		object:CharacterDiedOrRemoved()
	end))
	object._connectionsMaid:GiveTask(localPlayer.CharacterRemoving:Connect(function()
		object:CharacterDiedOrRemoved()
	end))
	return object
end

function SmoothShiftLock:CharacterDiedOrRemoved()
	self:ToggleShiftLock(false)

	if self._connectionsMaid ~= nil then
		self._connectionsMaid:Destroy()
	end

	maid:DoCleaning()
end

function SmoothShiftLock.IsEnabled(_)
	return v2
end

function SmoothShiftLock:SetMouseState(flag: boolean)
	UserInputService.MouseBehavior = flag and Enum.MouseBehavior.LockCenter or Enum.MouseBehavior.Default
end

function SmoothShiftLock:SetMouseIcon(flag: boolean)
	UserInputService.MouseIcon = flag and v.LOCKED_MOUSE_ICON or ""
end

function SmoothShiftLock:TransitionLockOffset(flag: boolean)
	if flag then
		self.camOffsetSpring.Speed = v.CAMERA_TRANSITION_IN_SPEED
		self.camOffsetSpring.Target = v.LOCKED_CAMERA_OFFSET
	else
		self.camOffsetSpring.Speed = v.CAMERA_TRANSITION_OUT_SPEED
		self.camOffsetSpring.Target = createVector(0, 0, 0)
	end
end

function SmoothShiftLock:ToggleShiftLock(visible: boolean)
	assert(typeof(visible) == "boolean", "Enable value is not a boolean.")
	v2 = visible

	if UserInputService.TouchEnabled == true and mobileCrosshair then
		mobileCrosshair.Visible = visible
	end

	self:SetMouseState(v2)
	self:SetMouseIcon(v2)
	self:TransitionLockOffset(v2)

	if v2 then
		maid:GiveTask(RunService.RenderStepped:Connect(function(dt)
			if self.Camera.CameraType == Enum.CameraType.Scriptable then
				maid:Destroy()
				return
			end

			if self.Humanoid and self.RootPart then
				self.Humanoid.AutoRotate = not v2
			end

			if v2 then
				if self.Humanoid.Sit or not v.CHARACTER_SMOOTH_ROTATION then
					if not self.Humanoid.Sit then
						local _, v3, _ = self.Camera.CFrame:ToOrientation()
						self.RootPart.CFrame = CFrame.new(self.RootPart.Position) * CFrame.Angles(0, v3, 0)
					end
				else
					local _, v3, _ = self.Camera.CFrame:ToOrientation()
					self.RootPart.CFrame = self.RootPart.CFrame:Lerp(
						CFrame.new(self.RootPart.Position) * CFrame.Angles(0, v3, 0),
						dt * 5 * v.CHARACTER_ROTATION_SPEED
					)
				end
			end

			if not v2 then
				maid:Destroy()
			end
		end))
	end

	return self
end

return SmoothShiftLock