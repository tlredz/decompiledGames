local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
game:GetService("RunService")
local Players = game:GetService("Players")
local ServerAuthority = require(ReplicatedStorage.Shared.ServerAuthority)
local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Trove = require(ReplicatedStorage.Packages.Trove)
local localPlayer = Players.LocalPlayer
return {
	Start = function(_)
		local mobileShiftLock = localPlayer.PlayerGui:WaitForChild("RightBottom"):WaitForChild("MobileShiftLock")
		local v

		if ServerAuthority.isEnabled() then
			v = game:GetService("StarterPlayer")
		else
			v = localPlayer.PlayerScripts
		end

		local CameraModule = require(v:WaitForChild("PlayerModule"):WaitForChild("CameraModule"))
		mobileShiftLock.Activated:Connect(function()
			if CameraModule.activeMouseLockController then
				CameraModule.activeMouseLockController:OnMouseLockToggled()
			end
		end)
		local maid = Trove.new()
		local v2 = nil

		local function updateVisibility()
			local v3 = Synchronizer:Get(localPlayer)

			if not v3 then
				return
			end

			local visible

			if UserInputService.PreferredInput == Enum.PreferredInput.Touch then
				visible = v3:Get("Settings.Mobile Shift Lock")
			else
				visible = false
			end

			if v2 == visible then
				return
			end

			v2 = visible
			maid:Clean()
			mobileShiftLock.Visible = visible

			if visible then
				maid:Add(Observers.observeTag("JumpButton", function(instance)
					-- equivalent calls inferred from this helper; original call sites unknown
					local function update()
						local absoluteSize = instance.AbsoluteSize
						local absolutePosition = instance.AbsolutePosition
						mobileShiftLock.Size = UDim2.fromOffset(absoluteSize.X * 0.5, absoluteSize.Y * 0.5)
						mobileShiftLock.Position = UDim2.fromOffset(
							absolutePosition.X - absoluteSize.X * 0.4,
							absolutePosition.Y - absoluteSize.Y * 0.4 * 0.5
						)
					end

					local absolutePositionChangedConnection = instance:GetPropertyChangedSignal("AbsolutePosition"):Connect(update)
					instance:GetPropertyChangedSignal("AbsoluteSize"):Connect(update)
					update() -- equivalent call inferred; original call site unknown
					return function()
						absolutePositionChangedConnection:Disconnect()
					end
				end))
			elseif UserInputService.PreferredInput == Enum.PreferredInput.Touch and CameraModule.activeMouseLockController and CameraModule.activeMouseLockController.isMouseLocked then
				CameraModule.activeMouseLockController:OnMouseLockToggled()
			end
		end

		Synchronizer:WaitAndCall(localPlayer, function(object)
			UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(updateVisibility)
			object:OnChanged("Settings.Mobile Shift Lock", updateVisibility)
			task.spawn(updateVisibility)
		end)

		if CameraModule.activeMouseLockController and CameraModule.activeMouseLockController.mouseLockToggledEvent then
			-- equivalent calls inferred from this helper; original call sites unknown
			local function updateIcon()
				mobileShiftLock.Image = CameraModule.activeMouseLockController.isMouseLocked and "rbxasset://textures/ui/mouseLock_on.png" or "rbxasset://textures/ui/mouseLock_off.png"
			end

			CameraModule.activeMouseLockController.mouseLockToggledEvent.Event:Connect(updateIcon)
			updateIcon() -- equivalent call inferred; original call site unknown
		end
	end
}