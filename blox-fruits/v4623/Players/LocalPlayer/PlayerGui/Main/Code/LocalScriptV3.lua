local CodeDialog = require(game.ReplicatedStorage.Controllers.UI.CodeDialog)
local FunctionQueue = require(game.ReplicatedStorage.Util.FunctionQueue)
FunctionQueue.new(1, "LocalScriptV3")(function()
	CodeDialog.init()

	local function toggle()
		local EventServiceUtil = require(game.ReplicatedStorage.Util.EventServiceUtil)
		EventServiceUtil.reportActivity("HUD/Button/Settings/Codes")

		if CodeDialog.IsOpen then
			CodeDialog:Close()
		else
			CodeDialog:Open()
		end
	end

	script.Parent.MouseButton1Click:Connect(toggle)
	game.ReplicatedStorage.Events.ToggleCodesWindow.Event:Connect(toggle)
end)