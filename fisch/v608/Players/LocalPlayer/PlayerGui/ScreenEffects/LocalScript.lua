game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local events = ReplicatedStorage.events
local packages = ReplicatedStorage.packages
local fade = script.Parent.Fade
require(packages.Net)
local Promise = require(packages.Promise)
local Trove = require(packages.Trove)

function fastTween(p, p2, p3, _: boolean?)
	local tween = TweenService:Create(p, p2, p3)
	tween:Play()
	tween.Completed:Connect(function()
		tween:Destroy()
	end)
	return tween
end

local v = Trove.new()

local function Fade(p: number, _: number, p2: number)
	v:Clean()
	fade.BackgroundTransparency = 1
	fade.Visible = true
	local v2 = tonumber(p) or 0.5
	local v3 = tonumber(v2) or 0.5
	local v4 = tonumber(p2) or v2
	v:Add((fastTween(fade, TweenInfo.new(v2, Enum.EasingStyle.Sine), {
		BackgroundTransparency = 0
	})))
	v:AddPromise(Promise.delay(v4):andThen(function()
		v:Add((fastTween(fade, TweenInfo.new(v3, Enum.EasingStyle.Sine), {
			BackgroundTransparency = 1
		})))
	end):andThenCall(Promise.delay, v3):andThen(function()
		fade.BackgroundTransparency = 1
		fade.Visible = false
	end))
end

events.ScreenEffect.OnClientEvent:Connect(function(p: string, ...)
	if p == "Fade" then
		Fade(...)
	end
end)