local module = require("@game/ReplicatedStorage/Omni")
local playerLevel = module.Interface:WaitForChild("Frames"):WaitForChild("PlayerLevel")
local main = playerLevel:WaitForChild("Main")
local Controller = {
	CurrentFrame = nil,
	FrameModules = {},
	FrameChanged = module.Libs.GoodSignal.new(),
	InterfaceOpened = module.Libs.GoodSignal.new(),
	InterfaceClosed = module.Libs.GoodSignal.new()
}

function Controller.OpenFrame(currentFrame: string?)
	if currentFrame == Controller.CurrentFrame then
		return
	end

	if currentFrame == nil then
		Controller.CurrentFrame = nil
	else
		Controller.CurrentFrame = currentFrame

		for _, frame in main:GetChildren() do
			if frame:IsA("Frame") then
				frame.Visible = frame.Name == currentFrame
			end
		end
	end

	Controller.FrameChanged:Fire(currentFrame)
end

module.Frame:OnFrameOpened(playerLevel, function()
	Controller.OpenFrame("Stats")
	Controller.InterfaceOpened:Fire()
end)
module.Frame:OnFrameClosed(playerLevel, function()
	Controller.OpenFrame(nil)
	Controller.InterfaceClosed:Fire()
end)
return Controller