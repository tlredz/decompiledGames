local HintService = require(game.ReplicatedStorage.Modules.HintService)
local Network = require(game.ReplicatedStorage.Modules.Network)
game:GetService("TweenService")

local function display_text(p, p2, options, flag: boolean)
	local v = HintService.new(Enum.TextXAlignment.Center, flag)
	local v2 = options or {}
	v:setLabel(p)
	v:setLabelColor(v2.labelColor or Color3.fromRGB(0, 0, 0))
	v:setHintBackgroundColor(v2.hintBgColor or Color3.fromRGB(255, 255, 255))
	v:setHintBackgroundCornerRadius(v2.hintBgCornerRadius or UDim.new(0, 8))
	v:setHintBackgroundStroke(
		v2.hintBgStroke_Thickness or 1,
		v2.hintBgStroke_Color or Color3.fromRGB(0, 0, 0),
		v2.hintBgStroke_LineJoinMode or Enum.LineJoinMode.Round
	)
	v:setVisibleTime(p2)
	v:setDestroyOnFinish(true)
	task.spawn(function()
		return v:activateHint(true)
	end)
	return v
end

local function display_success(p, p2)
	local v = HintService.new(Enum.TextXAlignment.Center)
	v:setLabel(p)
	v:setLabelColor(Color3.fromRGB(0, 0, 0))
	v:setHintBackgroundColor(Color3.fromRGB(85, 255, 127))
	v:setHintBackgroundCornerRadius(UDim.new(0, 8))
	v:setHintBackgroundStroke(1, Color3.fromRGB(0, 0, 0), Enum.LineJoinMode.Round)
	v:setVisibleTime(p2)
	v:setDestroyOnFinish(true)
	task.spawn(function()
		return v:activateHint(true)
	end)
	return v
end

local function display_announcement(p, p2)
	local v = HintService.new(Enum.TextXAlignment.Center)
	v:setLabel(p)
	v:setLabelColor(Color3.fromRGB(0, 0, 0))
	v:setHintBackgroundColor(Color3.fromRGB(255, 238, 53))
	v:setHintBackgroundCornerRadius(UDim.new(0, 8))
	v:setHintBackgroundStroke(1, Color3.fromRGB(0, 0, 0), Enum.LineJoinMode.Round)
	v:setVisibleTime(p2)
	v:setDestroyOnFinish(true)
	task.spawn(function()
		return v:activateHint(true)
	end)
	return v
end

local function display_error(p, p2, p3)
	if p3 and not script.Error.Playing then
		script.Error:Play()
	end

	if not p then
		return
	end

	local v = display_text(p, p2)
	v:setHintBackgroundColor(Color3.fromRGB(255, 67, 67))
	return v
end

local function display_cooldown(p, duration, _)
	for _, descendant in game.Players.LocalPlayer.PlayerGui.BackpackGui:GetDescendants() do
		if not (descendant.Name == "ToolName" and descendant.Text == p.Name) then
			continue
		end

		local parent = descendant.Parent
		local clone = script.Cooldown:Clone()
		clone.Parent = parent
		clone.Cooldown:TweenSizeAndPosition(
			UDim2.fromScale(1, 0),
			UDim2.fromScale(0.5, 1),
			Enum.EasingDirection.Out,
			Enum.EasingStyle.Linear,
			duration
		)
		task.delay(duration, function()
			clone:Destroy()
		end)
	end
end

function _G.DisplayText(...)
	return (display_text(...))
end

function _G.DisplaySuccess(...)
	return (display_success(...))
end

function _G.DisplayError(...)
	return display_error(...)
end

function _G.DisplayCooldown(...)
	return display_cooldown(...)
end

function _G.DisplayAnnouncement(...)
	return (display_announcement(...))
end

Network:listen("DisplayText", function(...)
	return (display_text(...))
end)
Network:listen("DisplaySuccess", function(...)
	return (display_success(...))
end)
Network:listen("DisplayError", function(...)
	return display_error(...)
end)
Network:listen("DisplayCooldown", function(...)
	return display_cooldown(...)
end)
Network:listen("Announce", function(...)
	return (display_announcement(...))
end)