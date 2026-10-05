local CodeDialog = require(game.ReplicatedStorage.Controllers.UI.CodeDialog)
local FunctionQueue = require(game.ReplicatedStorage.Util.FunctionQueue)
FunctionQueue.new(1, "LocalScriptV3")(function()
	while not CodeDialog.IsInitialized do
		task.wait()
	end

	assert(CodeDialog.IsInitialized, "bad code dialog")

	local function toggle()
		local AnalyticsUtil = require(game.ReplicatedStorage.Util.AnalyticsUtil)
		AnalyticsUtil.reportActivity("HUD/Button/Settings/Codes")

		if CodeDialog.IsOpen then
			CodeDialog:Close()
			return
		end

		local Global = require(game.ReplicatedStorage.Global)

		if Global.closeSettingsMenu then
			local Global2 = require(game.ReplicatedStorage.Global)
			pcall(Global2.closeSettingsMenu)
		end

		CodeDialog:Open()
	end

	script.Parent.Activated:Connect(toggle)
	game.ReplicatedStorage.Events.ToggleCodesWindow.Event:Connect(toggle)
end)