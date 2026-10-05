local localPlayer = game.Players.LocalPlayer
local character = localPlayer.Character
local pushToTalk = localPlayer.PlayerGui:WaitForChild("UI"):WaitForChild("PushToTalk")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
character:WaitForChild("Humanoid")
local UserInputService = game:GetService("UserInputService")
local Network = require(game.ReplicatedStorage.Modules.Network)
local count = 0
local pushToTalk2 = script:WaitForChild("PushToTalk")
pushToTalk2.Parent = localPlayer.PlayerGui
pushToTalk2.Adornee = humanoidRootPart

-- equivalent calls inferred from this helper; original call sites unknown
local function update_gui()
	if localPlayer:GetAttribute("PushToTalk") then
		pushToTalk2.Enabled = true
		pushToTalk.Visible = UserInputService.TouchEnabled
		local label = pushToTalk2:WaitForChild("Label")
		label.Text = localPlayer:GetAttribute("MicEnabled") and "(Speaking)" or "(Muted)"
	else
		pushToTalk2.Enabled = false
		pushToTalk.Visible = false
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function enable()
	count += 1
	Network:fire("SetMicEnabled", true)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function disable()
	local v = count
	task.wait(0.2)

	if count == v then
		Network:fire("SetMicEnabled", false)
	end
end

UserInputService.InputBegan:connect(function(p, p2)
	if p2 or p.KeyCode ~= Enum.KeyCode.V then
		return
	else
		return enable()
	end
end)
UserInputService.InputEnded:connect(function(p, p2)
	if p2 or p.KeyCode ~= Enum.KeyCode.V then
		return
	else
		return disable()
	end
end)

if UserInputService.TouchEnabled then
	pushToTalk.MouseButton1Down:connect(function()
		enable() -- equivalent call inferred; original call site unknown

		while wait() and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do

		end

		disable() -- equivalent call inferred; original call site unknown
	end)
end

Network:fire("SetMicEnabled", false)
localPlayer:GetAttributeChangedSignal("MicEnabled"):connect(update_gui)
localPlayer:GetAttributeChangedSignal("PushToTalk"):connect(update_gui)
update_gui() -- equivalent call inferred; original call site unknown