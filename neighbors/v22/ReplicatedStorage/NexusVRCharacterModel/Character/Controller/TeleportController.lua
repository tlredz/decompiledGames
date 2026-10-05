local Workspace = game:GetService("Workspace")
local parent = script.Parent.Parent.Parent
local module = require(parent)
local api = module.Api
local BaseController = require(script.Parent:WaitForChild("BaseController"))
local ArcWithBeacon = require(script.Parent:WaitForChild("Visual"):WaitForChild("ArcWithBeacon"))
local VRInputService = require(parent:WaitForChild("State"):WaitForChild("VRInputService"))
local instance = VRInputService.GetInstance()
local TeleportController = {}
TeleportController.__index = TeleportController
setmetatable(TeleportController, BaseController)

function TeleportController.new()
	local self = setmetatable(BaseController.new(), TeleportController)
	self.ActionsToLock = { Enum.KeyCode.Thumbstick1, Enum.KeyCode.ButtonR3 }
	return self
end

function TeleportController:Enable()
	BaseController.Enable(self)
	self.LeftArc = ArcWithBeacon.new()
	self.RightArc = ArcWithBeacon.new()
	self.ArcControls = {
		{
			Thumbstick = Enum.KeyCode.Thumbstick1,
			UserCFrame = Enum.UserCFrame.LeftHand,
			Arc = self.LeftArc
		},
		{
			Thumbstick = Enum.KeyCode.Thumbstick2,
			UserCFrame = Enum.UserCFrame.RightHand,
			Arc = self.RightArc
		}
	}
end

function TeleportController.Disable(p)
	BaseController.Disable(p)
	p.LeftArc:Destroy()
	p.RightArc:Destroy()
end

function TeleportController:UpdateCharacter()
	BaseController.UpdateCharacter(self)

	if not self.Character then
		return
	end

	local vRInputs = instance:GetVRInputs()

	for _, v in Enum.UserCFrame:GetEnumItems() do
		vRInputs[v] = self:ScaleInput(vRInputs[v])
	end

	local humanoidSeatPart = self.Character:GetHumanoidSeatPart()

	for _, arcControl in self.ArcControls do
		if arcControl.Thumbstick == Enum.KeyCode.Thumbstick1 and humanoidSeatPart and humanoidSeatPart:IsA("VehicleSeat") then
			arcControl.Arc:Hide()
		else
			local v = not api.Controller or api.Controller:IsControllerInputEnabled(arcControl.UserCFrame)
			local joystickState, v2, v3 = self:GetJoystickState(arcControl)

			if v then
				local humanoidRootPart = self.Character.Parts.HumanoidRootPart

				if joystickState ~= "Forward" or v2 == "Released" then
					arcControl.Arc:Hide()
				end

				if v3 == "Released" then
					arcControl.Arc:Hide()

					if joystickState == "Forward" then
						local lastHitPart = arcControl.LastHitPart

						if lastHitPart and arcControl.LastHitPosition then
							self:PlayBlur()
							local flag

							if humanoidSeatPart then
								self.IgnoreNextExternalTeleport = true
								self.Character.Humanoid.Sit = false
								flag = true
							else
								flag = false
							end

							if (lastHitPart:IsA("Seat") or lastHitPart:IsA("VehicleSeat")) and not (lastHitPart.Occupant or lastHitPart.Disabled) then
								if flag then
									local lastHitPart2 = lastHitPart
									task.spawn(function()
										while self.Character.Humanoid.SeatPart do
											task.wait()
										end

										lastHitPart2:Sit(self.Character.Humanoid)
									end)
								else
									lastHitPart:Sit(self.Character.Humanoid)
								end
							elseif flag then
								local humanoidRootPart2 = humanoidRootPart
								local v5 = arcControl
								task.spawn(function()
									while self.Character.Humanoid.SeatPart do
										task.wait()
									end

									humanoidRootPart2.CFrame = CFrame.new(v5.LastHitPosition) * CFrame.new(
										0,
										4.5 * self.Character:GetHumanoidScale("BodyHeightScale"),
										0
									) * (CFrame.new(-humanoidRootPart2.Position) * humanoidRootPart2.CFrame)
								end)
							else
								humanoidRootPart.CFrame = CFrame.new(arcControl.LastHitPosition) * CFrame.new(
									0,
									4.5 * self.Character:GetHumanoidScale("BodyHeightScale"),
									0
								) * (CFrame.new(-humanoidRootPart.Position) * humanoidRootPart.CFrame)
							end
						end
					end
				elseif v3 == "Cancel" then
					arcControl.Arc:Hide()
				elseif joystickState == "Forward" and v2 == "Extended" then
					local lastHitPart, lastHitPosition = arcControl.Arc:Update(Workspace.CurrentCamera:GetRenderCFrame() * vRInputs[Enum.UserCFrame.Head]:Inverse() * vRInputs[arcControl.UserCFrame])
					arcControl.LastHitPart = lastHitPart
					arcControl.LastHitPosition = lastHitPosition
				end

				self:UpdateRotating(arcControl.UserCFrame, joystickState, v3)
			else
				arcControl.Arc:Hide()
				arcControl.WaitForRelease = false
				arcControl.RadiusState = nil
			end
		end
	end
end

return TeleportController