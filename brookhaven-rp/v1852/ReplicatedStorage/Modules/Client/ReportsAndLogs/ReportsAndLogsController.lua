local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LogService = game:GetService("LogService")
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local ReportsAndLogsConstants = require(ReplicatedStorage.Modules.Shared.ReportsAndLogs.ReportsAndLogsConstants)
local Logger = require(ReplicatedStorage.Packages.Logger)
local Framework = require(ReplicatedStorage.Modules.Shared.Framework.Framework)

local function onGetClientLogs(p: number)
	local logHistory = LogService:GetLogHistory()
	local result = {}

	for i = #logHistory, math.max(#logHistory - p, 1), -1 do
		table.insert(result, 1, logHistory[i])
	end

	return result
end

local function splitStringIntoChunks(value: string, p: number)
	local result = {}

	for i = 1, #value, p do
		table.insert(result, value:sub(i, i + p - 1))
	end

	return result
end

local function onGetClientReport(p: string, _: number?)
	if p == ReportsAndLogsConstants.ReportTypes.FrameworkBoot then
		Framework.promiseFrameworkDoneBooting():await()
		return Framework.getBootLog()
	else
		Logger.error((`Invalid report type {p}`))
	end
end

local function onSendLogString(p: string)
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

local ReportsAndLogsController = {}

function ReportsAndLogsController.FrameworkStart()
	Remotes.onInvoke("GetClientLogs", onGetClientLogs)
	Remotes.onInvoke("GetClientReport", onGetClientReport)
	Remotes.connect("SendLogString", onSendLogString)
end

function ReportsAndLogsController.showLogString(p: string)
	onSendLogString(p)
end

return ReportsAndLogsController