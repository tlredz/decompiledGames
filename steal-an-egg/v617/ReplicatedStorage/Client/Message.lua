local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Audio = require(ReplicatedStorage.Shared.Audio)
local ButtonFX = require(ReplicatedStorage.Client.UI.VFX.ButtonFX)
local GUI = require(ReplicatedStorage.Client.GUI)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Save = require(ReplicatedStorage.Shared.Save)
local Tabs = require(ReplicatedStorage.Client.Tabs)
local v = {
	Notice = true,
	Warn = true,
	Confirm = true
}
local v2 = {
	Confirm = "Prompt",
	Notice = "Notice",
	Warn = "Failure"
}

local function child(instance, childName: string)
	local child2 = instance:FindFirstChild(childName)
	assert(child2, (`{instance:GetFullName()} is missing {childName}`))
	return child2
end

local message = GUI.Message()
local frame = message:FindFirstChild("Frame")
assert(frame, (`{message:GetFullName()} is missing Frame`))
local contents = frame:FindFirstChild("Contents")
assert(contents, (`{frame:GetFullName()} is missing Contents`))
local v3 = {
	accept = 0,
	acknowledge = 0,
	decline = 0,
	dismiss = 0
}
local accept = contents:FindFirstChild("Accept")
assert(accept, (`{contents:GetFullName()} is missing Accept`))
v3.accept = accept
local acknowledge = contents:FindFirstChild("Acknowledge")
assert(acknowledge, (`{contents:GetFullName()} is missing Acknowledge`))
v3.acknowledge = acknowledge
local decline = contents:FindFirstChild("Decline")
assert(decline, (`{contents:GetFullName()} is missing Decline`))
v3.decline = decline
local close = frame:FindFirstChild("Close")
assert(close, (`{frame:GetFullName()} is missing Close`))
v3.dismiss = close
local v4 = {
	heading = 0,
	illustrated = 0,
	plain = 0
}
local top = frame:FindFirstChild("Top")
assert(top, (`{frame:GetFullName()} is missing Top`))
local title = top:FindFirstChild("Title")
assert(title, (`{top:GetFullName()} is missing Title`))
v4.heading = title
local illustratedBody = contents:FindFirstChild("IllustratedBody")
assert(illustratedBody, (`{contents:GetFullName()} is missing IllustratedBody`))
v4.illustrated = illustratedBody
local body = contents:FindFirstChild("Body")
assert(body, (`{contents:GetFullName()} is missing Body`))
v4.plain = body
local artwork = contents:FindFirstChild("Artwork")
assert(artwork, (`{contents:GetFullName()} is missing Artwork`))
local v5 = {}
local v6 = {}
local v7 = nil
local flag = false

local function present(data)
	local visible = data.kind == "Confirm"
	local visible2 = data.image ~= nil
	v3.accept.Visible = visible
	v3.decline.Visible = visible
	v3.acknowledge.Visible = not visible
	v3.dismiss.Visible = true
	artwork.Image = data.image or ""
	artwork.Visible = visible2
	v4.illustrated.Visible = visible2
	v4.plain.Visible = not visible2
	v4.illustrated.Text = data.body
	v4.plain.Text = data.body
	v4.heading.Text = data.kind == "Warn" and "Uh-oh!" or data.heading or "Heads up!"
end

local function releaseActivation(connection)
	if typeof(connection) ~= "table" then
		return
	end

	for _, connection2 in connection do
		if typeof(connection2) == "RBXScriptConnection" then
			connection2:Disconnect()
		end
	end

	if typeof(connection.Disconnect) == "function" then
		connection:Disconnect()
	end
end

local function resumeIfWaiting(callback: thread, ...)
	if coroutine.status(callback) == "suspended" then
		task.spawn(callback, ...)
	end
end

local function awaitVerdict(flag2: boolean)
	local thread = coroutine.running()
	local flag3 = false
	local v8 = nil
	local v9 = {}
	local connections = {}

	local function settle(flag4: boolean?)
		if flag3 then
			return
		end

		flag3 = true
		v8 = flag4

		for _, v10 in v9 do
			releaseActivation(v10)
		end

		for _, connection in connections do
			connection:Disconnect()
		end

		resumeIfWaiting(thread)
	end

	local function bind(p, flag4: boolean?)
		table.insert(v9, GUI.OnActivated(p, function()
			settle(flag4)
		end))
	end

	local v10

	if flag2 then
		v10 = false
	else
		v10 = nil
	end

	local accept2 = v3.accept
	local v11 = true
	table.insert(v9, GUI.OnActivated(accept2, function()
		settle(v11)
	end))
	local decline2 = v3.decline
	local v12 = false
	table.insert(v9, GUI.OnActivated(decline2, function()
		settle(v12)
	end))
	local acknowledge2 = v3.acknowledge
	local v13 = nil
	table.insert(v9, GUI.OnActivated(acknowledge2, function()
		settle(v13)
	end))
	local dismiss = v3.dismiss
	table.insert(v9, GUI.OnActivated(dismiss, function()
		settle(v10)
	end))
	table.insert(connections, message:GetPropertyChangedSignal("Enabled"):Connect(function()
		if not message.Enabled then
			settle(v10)
		end
	end))

	if not flag3 then
		coroutine.yield()
	end

	return v8
end

local function ask(p)
	present(p)

	if Tabs.IsActive("Message") or Tabs.Activate("Message") then
		Audio.Chime(v2[p.kind])
		return awaitVerdict(p.kind == "Confirm"), true
	else
		return nil, false
	end
end

local function drain()
	if flag then
		return
	end

	flag = true
	local active = Tabs.Active()

	if active == "Message" then
		active = nil
	end

	while true do
		local v8 = table.remove(v6, 1)

		if v8 == nil then
			break
		end

		v7 = v8
		local v9, v10 = ask(v8)
		v7 = nil
		local v11 = #v6 == 0

		if v11 then
			flag = false

			if v10 then
				if active == nil or v8.leaveClosed then
					Tabs.Deactivate()
				else
					Tabs.Activate(active, {
						instant = true
					})
				end
			end
		end

		resumeIfWaiting(v8.waiter, v9)

		if v11 then
			return
		end
	end

	flag = false
end

local function alreadyQueued(body2: string, kind: string)
	if v7 and v7.body == body2 and v7.kind == kind then
		return true
	end

	for _, v8 in v6 do
		if v8.body == body2 and v8.kind == kind then
			return true
		end
	end

	return false
end

function v5.Show(data)
	assert(type(data) == "table", "dialog request must be a table")
	local body2 = data.Body
	assert(type(body2) == "string", "dialog body must be a string")
	local kind = data.Kind or "Notice"
	assert(v[kind] == true, (`unknown dialog kind {tostring(kind)}`))

	if Save.Await() == nil or (alreadyQueued(body2, kind) or #v6 >= 3) then
		return nil
	end

	table.insert(v6, {
		body = body2,
		kind = kind,
		heading = data.Heading,
		image = data.Image,
		leaveClosed = data.LeaveClosed == true,
		waiter = coroutine.running()
	})
	task.spawn(drain)
	return (coroutine.yield())
end

-- equivalent calls inferred from this helper; original call sites unknown
local function withBody(body2: string, kind: string, p)
	local selected = p == nil and {} or table.clone(p)
	selected.Body = body2
	selected.Kind = kind
	return selected
end

function v5.Notice(body2: string, p)
	v5.Show(withBody(body2, "Notice", p))
end

function v5.Warn(body2: string, p)
	v5.Show(withBody(body2, "Warn", p))
end

function v5.Confirm(body2: string, p)
	return v5.Show(withBody(body2, "Confirm", p))
end

function v5.WarnGeneric()
	v5.Warn("That didn't go through. Please try again in a moment.")
end

v4.illustrated.RichText = true
v4.plain.RichText = true
message:SetAttribute("ModalDialog", true)

for _, v8 in {
	v3.acknowledge,
	v3.accept,
	v3.decline,
	v3.dismiss
} do
	ButtonFX(v8)
end

Remotes.Toasts.Line.OnClientEvent:Connect(function(p)
	if typeof(p) ~= "table" or typeof(p.Body) ~= "string" then
		warn((`Toasts.Line expects a dialog request table, got {typeof(p)}`))
		return
	end

	local clone = table.clone(p)

	if clone.Kind ~= "Warn" then
		clone.Kind = "Notice"
	end

	v5.Show(clone)
end)

Remotes.Haul.OfferFullSatchelSale.OnClientInvoke = function(p: string)
	return v5.Confirm(p) == true
end

return table.freeze(v5)