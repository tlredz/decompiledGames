local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Cmdr = {
	_initialized = false
}

-- equivalent calls inferred from this helper; original call sites unknown
local function erroro(p)
	error("[GameSdk - Cmdr] " .. p)
end

local function _assertInitialized(flag: boolean, p: string)
	if Cmdr._initialized ~= flag then
		erroro(p) -- equivalent call inferred; original call site unknown
	end
end

local function splitStringIntoChunks(value: string, p: number)
	local result = {}

	for i = 1, #value, p do
		table.insert(result, value:sub(i, i + p - 1))
	end

	return result
end

local function onSendLogString(p: string, value: string?)
	local playerGui

	if RunService:IsRunning() or not RunService:IsStudio() then
		playerGui = Players.LocalPlayer.PlayerGui
	else
		playerGui = StarterGui
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "LogString"
	screenGui.Parent = playerGui
	local textBox = Instance.new("TextBox")
	textBox.Name = "LogString"
	textBox.AnchorPoint = Vector2.new(0.5, 0.5)
	textBox.Position = UDim2.new(0.5, 0, 0.5, 0)
	textBox.Size = UDim2.new(0.3, 0, 0.3, 0)
	textBox.Parent = screenGui
	local v = splitStringIntoChunks(p, 16384)

	for k, text in pairs(v) do
		textBox.Text = (value or "Click to copy log chunk %d/%d"):format(k, #v)
		textBox.Focused:Wait()
		task.wait()
		textBox.Text = text
		textBox.FocusLost:Wait()
	end

	screenGui:Destroy()
end

function Cmdr.Init()
	if Cmdr._initialized ~= false then
		error("[GameSdk - Cmdr] Already initialized")
	end

	Cmdr._remote = ReplicatedStorage:WaitForChild("GameSdkCmdrEvent", 20)

	if Cmdr._remote == nil then
		error("[GameSdk - Cmdr] Failed to find remote event")
	end

	Cmdr._remote.OnClientEvent:Connect(onSendLogString)
	Cmdr._initialized = true
end

return Cmdr