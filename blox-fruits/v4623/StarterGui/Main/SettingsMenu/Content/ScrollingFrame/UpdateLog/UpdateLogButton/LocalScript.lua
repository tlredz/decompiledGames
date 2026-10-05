local FunctionQueue = require(game.ReplicatedStorage.Util.FunctionQueue)
FunctionQueue.new(1, "LocalScriptV3")(function()
	while true do
		local Global = require(game.ReplicatedStorage.Global)

		if typeof(Global.updateLog) == "function" then
			break
		end

		task.wait()
	end

	local function toggle()
		local Global = require(game.ReplicatedStorage.Global)

		if Global.closeSettingsMenu then
			local Global2 = require(game.ReplicatedStorage.Global)
			pcall(Global2.closeSettingsMenu)
		end

		local Global2 = require(game.ReplicatedStorage.Global)
		Global2.updateLog()
	end

	script.Parent.MouseButton1Click:Connect(toggle)
	game.ReplicatedStorage.Events.ToggleCodesWindow.Event:Connect(toggle)
end)