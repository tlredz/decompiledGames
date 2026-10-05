local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Input = require(packages.Input)
local Signal = require(packages.Signal)
local Net = require(packages.Net)
local classes = ReplicatedStorage:WaitForChild("Classes")
require(classes.ClickEffect)
local remoteEvent = Net:RemoteEvent("TeleportService/Reconnect")
local _ = Players.LocalPlayer
local v = {
	Mouse = Input.Mouse.new(),
	Gamepad = Input.Gamepad.new(),
	Touch = Input.Touch.new(),
	Keyboard = Input.Keyboard.new()
}
local v2 = {
	OnMouseLeftBegan = Signal.new()
}
local InputController = {}

function InputController.Events(_, p: string)
	return v2[p]
end

function InputController.Get(_, p: string)
	return v[p]
end

function InputController.Start(_)
	local lastTime = os.clock()
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		lastTime = os.clock()

		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			v2.OnMouseLeftBegan:Fire(input, gameProcessed)
		end
	end)
	task.spawn(function()
		while task.wait(5) do
			if os.clock() - lastTime >= 1140 then
				remoteEvent:FireServer()
			end
		end
	end)
end

return InputController