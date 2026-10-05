game.StarterGui.ScreenOrientation = Enum.ScreenOrientation.LandscapeSensor
local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- equivalent calls inferred from this helper; original call sites unknown
local function update_sensor()
	playerGui.ScreenOrientation = Enum.ScreenOrientation.LandscapeSensor
end

update_sensor() -- equivalent call inferred; original call site unknown
playerGui:GetPropertyChangedSignal("ScreenOrientation"):connect(function()
	task.wait()
	update_sensor() -- equivalent call inferred; original call site unknown
end)