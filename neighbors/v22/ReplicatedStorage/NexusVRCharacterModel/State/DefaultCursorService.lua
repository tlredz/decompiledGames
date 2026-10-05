local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local DefaultCursorService = {}
DefaultCursorService.__index = DefaultCursorService
local v = nil

function DefaultCursorService.new()
	return (setmetatable({
		CursorOptionsList = { "Detect", "Enabled", "Disabled" },
		CursorOptions = {
			Detect = function()
				StarterGui:SetCore("VRLaserPointerMode", "Pointer")
				RunService.Stepped:Wait()
				RunService:BindToRenderStep(
					"NexusVRCharacterModel_MoveCursorWorkaround",
					Enum.RenderPriority.Last.Value + 1,
					function()
						local vRCoreEffectParts = Workspace.CurrentCamera:FindFirstChild("VRCoreEffectParts")

						if vRCoreEffectParts then
							local laserPointerOrigin = vRCoreEffectParts:FindFirstChild("LaserPointerOrigin")
							local cursor = vRCoreEffectParts:FindFirstChild("Cursor")

							if laserPointerOrigin and cursor then
								local cursorSurfaceGui = cursor:FindFirstChild("CursorSurfaceGui")

								if cursorSurfaceGui and not cursorSurfaceGui.Enabled then
									laserPointerOrigin.CFrame = CFrame.new(0, 1e999, 0)
								end
							end
						end
					end
				)
			end,
			Enabled = function()
				StarterGui:SetCore("VRLaserPointerMode", "Pointer")
			end,
			Disabled = function()
				StarterGui:SetCore("VRLaserPointerMode", "Disabled")
			end
		},
		CursorDisabledOptions = {
			Detect = function()
				RunService:UnbindFromRenderStep("NexusVRCharacterModel_MoveCursorWorkaround")
			end
		}
	}, DefaultCursorService))
end

function DefaultCursorService.GetInstance()
	if not v then
		v = DefaultCursorService.new()
	end

	return v
end

function DefaultCursorService:SetCursorState(currentCursorState: string)
	if self.CurrentCursorState == currentCursorState then
		return
	end

	if self.CurrentCursorState and self.CursorDisabledOptions[self.CurrentCursorState] then
		self.CursorDisabledOptions[self.CurrentCursorState]()
	end

	self.CurrentCursorState = currentCursorState
	task.spawn(self.CursorOptions[currentCursorState])
end

return DefaultCursorService