local parent = script.Parent.Parent
local UserInputService = game:GetService("UserInputService")
local mouseLock = parent:WaitForChild("MouseLock")
local playerModule = parent:WaitForChild("PlayerModule")
local mouseLockController = playerModule:WaitForChild("CameraModule"):WaitForChild("MouseLockController")
script.CameraOffset.Parent = mouseLockController
script.CursorImage.Parent = mouseLockController
script.BoundKeys.Parent = mouseLockController
local module = require(playerModule)
local cameras = module.cameras

local function addMouseLockControlller()
	local module2 = require(mouseLockController)
	cameras.activeMouseLockController = module2.new()
	local bindableToggleEvent = cameras.activeMouseLockController:GetBindableToggleEvent()

	if bindableToggleEvent then
		bindableToggleEvent:Connect(function()
			cameras:OnMouseLockToggled()
		end)
	end
end

function triggerMouseLock(p)
	local isMouseLocked = cameras.activeMouseLockController.isMouseLocked
	local v = p == true
	local v2 = p == false
	local v3 = p == nil

	if v and not isMouseLocked then
		cameras.activeMouseLockController:OnMouseLockToggled()
	elseif v2 and isMouseLocked then
		cameras.activeMouseLockController:OnMouseLockToggled()
	elseif v3 then
		cameras.activeMouseLockController:OnMouseLockToggled()
	end

	mouseLock:SetAttribute("Enabled", cameras.activeMouseLockController.isMouseLocked)
	return cameras.activeMouseLockController.isMouseLocked
end

local function onInitialize()
	if UserInputService.TouchEnabled and cameras.activeMouseController == nil then
		addMouseLockControlller()
	end

	mouseLock:SetAttribute("Enabled", false)
	mouseLock.OnInvoke = triggerMouseLock
	cameras.activeMouseLockController:GetBindableToggleEvent():Connect(function()
		script.Parent.MouseLockToggled:Fire(cameras.activeMouseLockController.isMouseLocked)
	end)
end

onInitialize()