local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local SoundService = game:GetService("SoundService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
game:GetService("TweenService")
local v = require3(ReplicatedStorage2.Common.Utils)
local v2 = require3(ReplicatedStorage2.Packages.Replion)
require3(ReplicatedStorage2.Packages.Net)
local signal = v.Signal
local maid = v.Maid
local localPlayer = Players.LocalPlayer
local class = {}
class.__index = class

function class:Skip()
	self._skip = true
end

function class:Wait()
	return self.Ended:Wait()
end

function class:Destroy()
	if not self.Completed then
		self.Ended:Fire()
	end

	self._maid:Destroy()

	for k, v3 in pairs(self._queue) do
		if v3 ~= self then
			continue
		end

		table.remove(self._queue, k)
		break
	end
end

local function disableMusic(instance)
	local maid2 = v.Maid.new()
	local music = SoundService.Music

	local function updateVolume()
		if music.Volume > 0.25 then
			if instance._maid.LoweringVolume then
				return
			end

			instance._maid.RaisingVolume = nil
			local volume = music.Volume
			local v3 = 0.25 - volume
			instance._maid.LoweringVolume = v.Thread.LoopFor(math.min(math.abs(v3), 1) * 3, function(p)
				music.Volume = volume + v3 * p
			end).Ended:Connect(function()
				instance._maid.LoweringVolume = nil
			end)
		end
	end

	maid2.OnVolumeChange = music:GetPropertyChangedSignal("Volume"):Connect(updateVolume)
	updateVolume()
	maid2:GiveTask(function()
		local replion = v2.Client:GetReplion("Data")

		if not replion then
			return
		end

		local settings = replion:Get("Settings")

		if settings then
			local v3 = 0.5 * settings.Volume.Music.Current / 50

			if v3 > 0.25 then
				local volume = music.Volume
				local v4 = v3 - volume
				instance._maid.LoweringVolume = nil
				instance._maid.RaisingVolume = v.Thread.LoopFor(math.min(math.abs(v4), 1) * 3, function(p)
					music.Volume = volume + v4 * p
				end).Ended:Connect(function()
					instance._maid.RaisingVolume = nil
				end)
			end
		end
	end)
	return maid2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function removeTags(contentText)
	return (contentText:gsub("<br%s*/>", "\n"):gsub("<[^<>]->", ""))
end

function class:Show()
	local content = self.Label.Content
	local v3 = removeTags(content.ContentText) -- equivalent call inferred; original call site unknown
	self.Label.Visible = true
	self._maid.Rendering = true
	local lastTime = os.clock()
	local textSpeed = self._dialogueData.TextSpeed or 35
	task.spawn(function()
		local count = 0

		for _, _ in utf8.graphemes(v3) do
			count += 1
			content.MaxVisibleGraphemes = count

			if self._skip then
				continue
			end

			local v4 = os.clock() - lastTime
			local v5 = count / textSpeed

			if v4 < v5 then
				task.wait(v5 - v4)
			end
		end

		if self._maid.Rendering then
			self.Completed = true
			self.Ended:Fire(true)
			self._maid.Rendering = nil
		end
	end)
	local duration = self._dialogueData.Duration

	if self._dialogueData.Sound then
		local v4 = v.Sounds:Play(self._dialogueData.Sound)

		if v4 and duration then
			textSpeed = #v3 / math.clamp(v4.TimeLength, 1, duration)
			self._maid.DisableMusic = disableMusic(self)
		end
	end

	self.Ended:Connect(function(p)
		self._maid.DisableMusic = nil

		if not p then
			return
		end

		self._maid.DelayFade = v.Thread.Delay(duration or 0, function()
			self._maid.FadeAway = v.Thread.LoopFor(1, function(p2)
				self.Label.BackgroundTransparency = p2
				self.Label.Title.TextTransparency = p2
				self.Label.Content.TextTransparency = p2
				self.Label.Title.TextStrokeTransparency = p2
				self.Label.Content.TextStrokeTransparency = p2
			end).Ended:Connect(function()
				self:Destroy()
			end)
		end)
	end)
end

function class.new(_, screenGui, dialogueData, queue)
	local self = setmetatable({}, class)
	self.Ended = signal.new()
	self._maid = maid.new()
	self._queue = queue
	self._dialogueData = dialogueData
	self.ScreenGui = screenGui
	local clone = screenGui.List.DialogueFrame:Clone()
	clone.Name = "dialogue"
	clone.Content.Visible = true
	clone.Title.Visible = true
	self._maid:GiveTask(clone)

	if dialogueData.Title then
		clone.Title.Text = dialogueData.Title .. ": "
		clone.Title.TextColor3 = dialogueData.TitleColor or Color3.fromRGB(255, 255, 255)
	else
		clone.Title.Visible = false
	end

	clone.Content.Text = dialogueData.Text or "N/A"
	clone.Content.TextColor3 = dialogueData.TextColor or Color3.fromRGB(255, 255, 255)
	clone.Content.MaxVisibleGraphemes = 0
	clone.Parent = screenGui.List
	self.Label = clone
	return self
end

local DialogueController = {}

local function dialogueHasNotLoaded()
	warn("Dialog has not loaded.")
end

DialogueController.SentText = dialogueHasNotLoaded

function DialogueController:CreateDialogue(text: string, title: string, textSpeed: number?, requiresInput: boolean?, color: Color3?, color2: Color3?, duration: number?)
	return {
		Text = text,
		Title = title,
		TextSpeed = textSpeed,
		TitleColor = color2,
		TextColor = color,
		Duration = duration,
		RequiresInput = requiresInput
	}
end

function DialogueController.QuickSend(_, p: string, p2: string, p3: number?, flag: boolean?, color: Color3?, color2: Color3?, p4: number?)
	DialogueController:SendText((DialogueController:CreateDialogue(p, p2, p3, flag, color, color2, p4)))
end

local v3 = {}

function DialogueController:SendText(...)
	v3[#v3 + 1] = { ... }
end

function DialogueController.Start(_)
	v.Streamer:Sync(localPlayer, "PlayerGui", "Dialogue").Loaded:Connect(function(p)
		p.Enabled = true
		local v4 = {}
		local v5 = false

		function DialogueController:SendText(p2, flag: boolean?)
			local selected = flag or class.new(class, p, p2, v4)

			if not flag and v5 then
				table.insert(v4, selected)
				return selected
			end

			v5 = true
			selected:Show()
			selected.Ended:Connect(function()
				if #v4 > 0 then
					DialogueController:SendText(nil, (table.remove(v4, 1)))
				else
					v5 = false
				end
			end)
			return selected
		end

		while next(v3) ~= nil do
			local v6 = table.remove(v3, 1)
			DialogueController:SendText(unpack(v6))
		end
	end)
end

return DialogueController