game:GetService("Players")
game:GetService("UserInputService")
UserSettings():GetService("UserGameSettings")
local CameraInput = require(script.Parent:WaitForChild("CameraInput"))
local CameraUI = require(script.Parent:WaitForChild("CameraUI"))
local CameraUtils = require(script.Parent:WaitForChild("CameraUtils"))
local v = false
local lastTime = tick()
local v2 = false
local v3 = false
local v4 = false
CameraUI.setCameraModeToastEnabled(false)
return function(flag: boolean)
	local togglePan = CameraInput.getTogglePan()

	if flag and togglePan ~= v then
		v2 = true
	end

	if v ~= togglePan or tick() - lastTime > 3 then
		local v5 = togglePan and tick() - lastTime < 3
		CameraUI.setCameraModeToastOpen(v5)

		if togglePan then
			v2 = false
		end

		lastTime = tick()
		v = togglePan
	end

	if flag ~= v4 then
		if flag then
			v3 = CameraInput.getTogglePan()
			CameraInput.setTogglePan(true)
		elseif not v2 then
			CameraInput.setTogglePan(v3)
		end
	end

	local v5

	if CameraInput.candyMenuIsOpen == nil then
		v5 = false
	else
		v5 = CameraInput.candyMenuIsOpen()
	end

	local v6 = CameraInput.getTogglePan() and not v5

	if flag then
		if v6 then
			CameraUtils.setMouseIconOverride("rbxasset://textures/Cursors/CrossMouseIcon.png")
			CameraUtils.setMouseBehaviorOverride(Enum.MouseBehavior.LockCenter)
		else
			CameraUtils.restoreMouseIcon()
			CameraUtils.restoreMouseBehavior()
		end

		CameraUtils.setRotationTypeOverride(Enum.RotationType.CameraRelative)
	elseif v6 then
		CameraUtils.setMouseIconOverride("rbxasset://textures/Cursors/CrossMouseIcon.png")
		CameraUtils.setMouseBehaviorOverride(Enum.MouseBehavior.LockCenter)
		CameraUtils.setRotationTypeOverride(Enum.RotationType.MovementRelative)
	elseif CameraInput.getHoldPan() then
		CameraUtils.restoreMouseIcon()
		CameraUtils.setMouseBehaviorOverride(Enum.MouseBehavior.LockCurrentPosition)
		CameraUtils.setRotationTypeOverride(Enum.RotationType.MovementRelative)
	else
		CameraUtils.restoreMouseIcon()
		CameraUtils.restoreMouseBehavior()
		CameraUtils.restoreRotationType()
	end

	v4 = flag
end