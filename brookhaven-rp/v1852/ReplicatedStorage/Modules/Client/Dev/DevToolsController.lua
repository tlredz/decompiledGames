local DevToolsController = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Packages.Remotes)

local function splitStringIntoChunks(value: string, p: number)
	local result = {}

	for i = 1, #value, p do
		table.insert(result, value:sub(i, i + p - 1))
	end

	return result
end

function DevToolsController.ShowString(p: string)
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "LogString"
	screenGui.Parent = game.Players.LocalPlayer.PlayerGui
	local textBox = Instance.new("TextBox")
	textBox.Name = "LogString"
	textBox.AnchorPoint = Vector2.new(0.5, 0.5)
	textBox.Position = UDim2.new(0.5, 0, 0.5, 0)
	textBox.Size = UDim2.new(0.3, 0, 0.3, 0)
	textBox.Parent = screenGui
	local v = splitStringIntoChunks(p, 16384)

	for k, text in pairs(v) do
		textBox.Text = ("Click to copy log chunk %d/%d"):format(k, #v)
		textBox.Focused:Wait()
		task.wait()
		textBox.Text = text
		textBox.FocusLost:Wait()
	end

	screenGui:Destroy()
end

function DevToolsController.DevToolsEvent(p: string, ...)
	if DevToolsController[p] then
		DevToolsController[p](...)
	else
		error((`DevToolsController.DevToolsEvent: Event {tostring(p)} not found!`))
	end
end

function DevToolsController.FrameworkStart()
	Remotes.connect("DevTools", DevToolsController.DevToolsEvent)
end

return DevToolsController