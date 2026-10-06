local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PlaySfx = require(game.ReplicatedStorage.Engine.Service.PlaySfx)
local PreMade = require(script.PreMade)

local function scaleUDim2(udim: UDim2, value: number?, value2: number?)
	local v = value or 1
	local v2 = value2 or 1
	return UDim2.new(udim.X.Scale * v, udim.X.Offset * v, udim.Y.Scale * v2, udim.Y.Offset * v2)
end

local function traverse(instance, className, fn)
	local fn2 = type(className) ~= "function" and function(instance2)
		return instance2:IsA(className)
	end or className

	if type(fn) ~= "function" then
		fn = fn == "Destroy" and function(instance2)
			instance2:Destroy()
		end or error((`不支持的 Callback: {fn}`))
	end

	for _, child in instance:GetChildren() do
		if fn2(child) then
			fn(child)
		end
	end
end

local function guiExpand(clone)
	if clone:GetAttribute("FullSize") == nil then
		clone:SetAttribute("FullSize", clone.Size)
	end

	local fullSize = clone:GetAttribute("FullSize")
	clone.Size = UDim2.new()
	clone.Visible = true
	TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
		Size = fullSize
	}):Play()
end

local function guiShrink(clone)
	if clone:GetAttribute("FullSize") == nil then
		clone:SetAttribute("FullSize", clone.Size)
	end

	TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
		Size = UDim2.new()
	}):Play()
	task.delay(0.1, function()
		clone.Visible = false
	end)
end

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local screenNotifyGui = script.ScreenNotifyGui
local v = {
	Center = screenNotifyGui.CenterHolderFrame,
	Top = screenNotifyGui.TopHolderFrame,
	Upper = screenNotifyGui.UpperHolderFrame
}
local notifyTemplateTextLabel = v.Center.NotifyTemplateTextLabel
local v2 = -1
local bindableEvent = Instance.new("BindableEvent")
local v3 = {
	Success = {
		Duration = 3,
		Color = Color3.new(0, 1),
		Sound = PlaySfx.ref.Ding
	},
	Error = {
		Duration = 3,
		Color = Color3.new(1),
		Sound = PlaySfx.ref["Windows Error"]
	},
	reward = {
		Duration = 3,
		Color = Color3.new(1, 1),
		Sound = PlaySfx.ref.RewardSoundGroup,
		Queued = true
	}
}

function SingletonLogic(data)
	if data.SingletonName then
		traverse(data.TargetFrame, function(instance)
			return instance:GetAttribute("SingletonName") == data.SingletonName
		end, "Destroy")
		data.Label:SetAttribute("SingletonName", data.SingletonName)
	end
end

function applyPreMade(p)
	if p.preMade then
		for k, v4 in p.preMade do
			p[k] = v4
		end
	end
end

function ApplyStyle(p)
	if p.Style then
		for k, v4 in v3[p.Style] do
			if p[k] == nil then
				p[k] = v4
			end
		end
	end
end

function Notify(state)
	local v4 = v[state.Area or "Center"]
	local layoutOrder = -#v4:GetChildren()
	local clone = notifyTemplateTextLabel:Clone()
	state.TargetFrame = v4
	state.Label = clone
	SingletonLogic(state)
	local size = clone.Size
	local sizeScale = state.SizeScale or 1
	clone.Size = UDim2.new(size.X.Scale * 1, size.X.Offset * 1, size.Y.Scale * sizeScale, size.Y.Offset * sizeScale)
	clone.LayoutOrder = layoutOrder
	clone.TextColor3 = state.Color or Color3.new(1, 1, 1)
	clone.Text = state.Text
	guiExpand(clone)

	if state.Sound then
		PlaySfx.play({
			sound = state.Sound
		})
	end

	clone.Parent = v4

	if state.Keep then
		return
	end

	task.wait(state.Duration or 1)
	guiShrink(clone)
	Debris:AddItem(clone, 0.2)
end

function loadArgs(p)
	applyPreMade(p)
	ApplyStyle(p)
end

function QueuedNotify(p)
	bindableEvent:Fire(p)
end

script.Client.Enabled = true

if localPlayer then
	screenNotifyGui.Parent = localPlayer.PlayerGui
end

if RunService:IsClient() then
	bindableEvent.Event:Connect(function(p)
		loadArgs(p)

		if not p.Queued then
			task.spawn(Notify, p)
			return
		end

		v2 += 1
		task.wait(script.NotifyInterval.Value * v2)
		task.spawn(Notify, p)
		v2 -= 1
	end)
end

local ScreenNotify = {}
ScreenNotify.SoundRef = PlaySfx.ref

function ScreenNotify:Play()
	if RunService:IsServer() then
		if self.Target == "AllPlayers" then
			script.RemoteEvent:FireAllClients(self)
		else
			script.RemoteEvent:FireClient(self.Target, self)
		end
	end

	if RunService:IsClient() then
		QueuedNotify(self)
	end
end

function ScreenNotify.Clear(p)
	traverse(v[p.Area or "Center"], "TextLabel", "Destroy")
end

ScreenNotify.preMade = PreMade
return ScreenNotify