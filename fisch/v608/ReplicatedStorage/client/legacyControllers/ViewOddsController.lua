local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Net = require(ReplicatedStorage.packages.Net)
local Signal = require(ReplicatedStorage.packages.Signal)
local module = require("./HudController")
local viewodds = module:GetSafeZone():WaitForChild("viewodds")
local remoteFunction = Net:RemoteFunction("ViewOdds/Request", -1)
local ViewOddsController = {
	IsLoading = false,
	Closed = Signal.new()
}

function ViewOddsController.ShowOdds(p: string, p2)
	viewodds.content.CanvasPosition = Vector2.zero
	viewodds.Cancel.Visible = false
	viewodds.Confirm.Visible = false
	viewodds.Visible = true

	if ViewOddsController.IsLoading then
		return
	end

	ViewOddsController.IsLoading = true
	viewodds.content.contentText.Text = "Loading..."
	local success, result = pcall(function()
		viewodds.content.contentText.Text = remoteFunction:InvokeServer(p, p2)
	end)
	ViewOddsController.IsLoading = false

	if not success then
		warn((`Failed to fetch odds for {p} {HttpService:JSONEncode(p2)}: {tostring(result)}`))
		viewodds.content.contentText.Text = `Something went wrong while fetching chances.\nError message: {tostring(result)}\n\nPlease try again later.`
	end
end

function ViewOddsController.PromptConfirmOdds(p: string, p2)
	viewodds.content.CanvasPosition = Vector2.zero
	viewodds.Cancel.Visible = false
	viewodds.Confirm.Visible = false
	viewodds.Visible = true

	if ViewOddsController.IsLoading then
		return
	end

	local backpackGui = module:GetBackpackGui()
	backpackGui.Enabled = false
	ViewOddsController.IsLoading = true
	viewodds.content.contentText.Text = "Loading..."
	local success, result = pcall(function()
		viewodds.content.contentText.Text = remoteFunction:InvokeServer(p, p2)
	end)
	viewodds.Cancel.Visible = true
	viewodds.Confirm.Visible = true
	ViewOddsController.IsLoading = false

	if not success then
		warn((`Failed to fetch odds for {p} {HttpService:JSONEncode(p2)}: {tostring(result)}`))
		viewodds.content.contentText.Text = `Something went wrong while fetching chances.\nError message: {tostring(result)}\n\nPlease try again later.`
	end

	local v = false
	local activatedConnection = viewodds.Confirm.Activated:Once(function()
		v = true
		viewodds.Visible = false
	end)

	if viewodds.Visible then
		viewodds:GetPropertyChangedSignal("Visible"):Wait()
	end

	activatedConnection:Disconnect()
	local backpackGui_2 = module:GetBackpackGui()
	backpackGui_2.Enabled = true
	return v
end

function ViewOddsController.Start(_)
	viewodds:GetPropertyChangedSignal("Visible"):Connect(function()
		if not viewodds.Visible then
			ViewOddsController.Closed:FireDeferred()
		end
	end)
end

return ViewOddsController