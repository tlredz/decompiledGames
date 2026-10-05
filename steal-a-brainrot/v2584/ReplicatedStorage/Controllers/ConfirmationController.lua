local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Net = require(ReplicatedStorage.Packages.Net)
local Signal = require(ReplicatedStorage.Packages.Signal)
local AnimatedButton = require(ReplicatedStorage.Classes.AnimatedButton)
local playerGui = Players.LocalPlayer.PlayerGui
local remoteEvent = Net:RemoteEvent("ConfirmationService/Show")
local confirmation = playerGui:WaitForChild("Confirmation")
local template = confirmation:WaitForChild("Template")
local ConfirmationController = {}
local flag = false

function ConfirmationController.IsInPrompt(_)
	return flag
end

function ConfirmationController:Show(value: string?, duration: number?, childName: string?)
	while flag do
		task.wait()
	end

	flag = true
	local v = Signal.new()
	local clone = childName and confirmation:FindFirstChild(childName) and confirmation[childName]:Clone() or template:Clone()
	clone.Name = "Confirmation"
	clone.Visible = true
	clone.Parent = confirmation
	local description = clone.Content.Description
	local close = clone.Close
	local yes = clone.Yes
	local no = clone.No
	description.Text = value or "Do you really want to do this?"

	-- equivalent calls inferred from this helper; original call sites unknown
	local function cleanup()
		clone:Destroy()
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function respond(flag2: boolean)
		v:Fire(flag2)
	end

	local v2 = AnimatedButton.new(yes)
	v2:Animate()
	v2.OnActivated:Connect(function()
		respond(true) -- equivalent call inferred; original call site unknown
	end)
	local v3 = AnimatedButton.new(no)
	v3:Animate()
	v3.OnActivated:Connect(function()
		respond(false) -- equivalent call inferred; original call site unknown
	end)
	local v4 = AnimatedButton.new(close)
	v4:Animate()
	v4.OnActivated:Connect(function()
		respond(false) -- equivalent call inferred; original call site unknown
	end)
	local thread

	if duration then
		thread = task.delay(duration, function()
			respond(false) -- equivalent call inferred; original call site unknown
		end)
	end

	local v5 = v:Wait()
	cleanup() -- equivalent call inferred; original call site unknown
	v:Destroy()

	if thread and coroutine.status(thread) == "suspended" then
		pcall(task.cancel, thread)
	end

	flag = false
	return v5
end

function ConfirmationController.ShowTradePlazaJoin(_, p, duration: number?)
	while flag do
		task.wait()
	end

	flag = true
	local clone = confirmation.TradePlazaJoinTemplate:Clone()
	clone.Name = "Confirmation"
	clone.Visible = true
	clone.Parent = confirmation
	local v = Signal.new()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function respond(p2: string?)
		v:Fire(p2)
	end

	local v2 = AnimatedButton.new(clone.Close)
	v2:Animate()
	v2.OnActivated:Connect(function()
		respond(nil) -- equivalent call inferred; original call site unknown
	end)

	for _, childName in { "Normal", "Pro", "OG" } do
		local child = clone.Btns:FindFirstChild(childName)

		if not child then
			continue
		end

		local visible = p[childName] == true
		child.Visible = visible

		if not visible then
			continue
		end

		local v4 = AnimatedButton.new(child)
		v4:Animate()
		local v5 = childName
		v4.OnActivated:Connect(function()
			respond(v5) -- equivalent call inferred; original call site unknown
		end)
	end

	local thread

	if duration then
		thread = task.delay(duration, function()
			respond(nil) -- equivalent call inferred; original call site unknown
		end)
	end

	local v3 = v:Wait()
	clone:Destroy()
	v:Destroy()

	if thread and coroutine.status(thread) == "suspended" then
		pcall(task.cancel, thread)
	end

	flag = false
	return v3
end

function ConfirmationController.Start(_)
	remoteEvent.OnClientEvent:Connect(function(p, p2, p3)
		remoteEvent:FireServer(p, (ConfirmationController:Show(p2, p3 - workspace:GetServerTimeNow())))
	end)
end

return ConfirmationController