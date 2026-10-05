local localPlayer = game.Players.LocalPlayer
local mouse = localPlayer:GetMouse()
local TweenService = game:GetService("TweenService")
local Network = require(game.ReplicatedStorage.Modules.Network)
local Server = require(game.ReplicatedStorage.Modules.Server)
local now = 0
local count = 0

if Server:GetServerType() == Server.Servers.Neighborhood then
	script.Parent.Visible = false
	return
end

local mainGui = localPlayer.PlayerGui:WaitForChild("MainGui", 30)

local function create_ripple()
	local clone = script.Ripple:Clone()
	clone.Position = UDim2.new(0, mouse.X, 0, mouse.Y)
	local v = math.random(50, 300)
	clone.Size = UDim2.new(0, 0, 0, 0)
	local tween = TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
		Transparency = 1,
		Size = UDim2.new(0, v, 0, v)
	})
	tween:Play()
	tween.Completed:connect(function()
		return clone:Destroy()
	end)
	local clone2 = script.Sound:Clone()
	clone2.PlaybackSpeed += math.random() * 0.3
	clone2.Parent = mainGui
	clone2:Play()
	game.Debris:AddItem(clone2, 1)
	clone.Parent = mainGui
end

local function bump()
	local tween = TweenService:Create(script.Parent, TweenInfo.new(0.1), {
		TextSize = 23
	})
	tween:Play()
	tween.Completed:connect(function()
		TweenService:Create(script.Parent, TweenInfo.new(0.1), {
			TextSize = 17
		}):Play()
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function update_visibility()
	if localPlayer.character:GetAttribute("Carried") or localPlayer.character:GetAttribute("Tied") then
		script.Parent.Visible = true
	else
		script.Parent.Visible = false
	end
end

script.Parent:GetPropertyChangedSignal("Visible"):connect(function()
	if script.Parent.Visible then
		count = 0
	end
end)
mouse.Button1Down:connect(function()
	if script.Parent.Visible and count < 40 and os.clock() - now > 0.1 then
		count += 1
		now = os.clock()
		create_ripple()
		bump()

		if count >= 40 then
			Network:fire("BreakFree")
			script.Parent.Visible = false
		end
	end
end)
update_visibility() -- equivalent call inferred; original call site unknown
localPlayer.CharacterAdded:Connect(function(character)
	script.Parent.Visible = false
	character:GetAttributeChangedSignal("Carried"):connect(update_visibility)
	character:GetAttributeChangedSignal("Tied"):connect(update_visibility)
end)
localPlayer.Character:GetAttributeChangedSignal("Carried"):connect(update_visibility)
localPlayer.Character:GetAttributeChangedSignal("Tied"):connect(update_visibility)