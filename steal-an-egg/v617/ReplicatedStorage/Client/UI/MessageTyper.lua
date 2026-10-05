local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Audio = require(ReplicatedStorage.Shared.Audio)
local Alphabet = require(ReplicatedStorage.Data.Sounds.Languages.Alphabet)
local normal = Alphabet.Normal
local MessageTyper = {}
MessageTyper.__index = MessageTyper
MessageTyper.__class = "MessageTyper"

local function splitGlyphs(text: string)
	local v = string.gsub(text, "<.->", "")
	local result = {}

	for k, v2 in utf8.graphemes(v) do
		result[#result + 1] = string.sub(v, k, v2)
	end

	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function voiceGlyph(value: string, clickSound: string)
	if value == " " then
		return
	end

	local v = normal[string.lower(value)]

	if v then
		Audio.PlaySound(v.Sound:Clone(), v.Sound.Parent)
	else
		Audio.Play(clickSound, ReplicatedFirst)
	end
end

function MessageTyper.new(label, value: string?, value2: number?, flag: boolean?)
	local self = setmetatable({}, MessageTyper)
	self.label = label
	self.run = 0
	self.clickSound = value or "rbxassetid://91414159854126"
	self.clicksOn = flag ~= false
	self.pace = value2 or 0.09
	self.driver = nil
	self.watcher = nil
	self.sweep = nil
	return self
end

function MessageTyper:Halt()
	self.run += 1
	local sweep = self.sweep

	if sweep then
		sweep:Cancel()
		self.sweep = nil
	end

	local watcher = self.watcher

	if watcher then
		watcher:Disconnect()
		self.watcher = nil
	end

	local driver = self.driver

	if driver then
		driver:Destroy()
		self.driver = nil
	end

	self.label.MaxVisibleGraphemes = -1
end

function MessageTyper:Blank()
	self:Halt()
	self.label.Text = ""
end

function MessageTyper:ShowAll(text: string, textColor: Color3)
	local label = self.label
	local v

	if label.Text == text and label.TextColor3 == textColor then
		v = label.MaxVisibleGraphemes == -1
	else
		v = false
	end

	if v then
		return
	end

	self:Halt()
	label.RichText = true
	label.Text = text
	label.TextColor3 = textColor
	label.MaxVisibleGraphemes = -1
end

function MessageTyper:Type(text: string, textColor: Color3)
	local label = self.label

	if label.Text == text and label.TextColor3 == textColor then
		return
	end

	self:Halt()
	self.run += 1
	local run = self.run
	label.RichText = true
	label.Text = text
	label.TextColor3 = textColor
	local v = splitGlyphs(text)
	local count = #v

	if count <= 0 then
		label.MaxVisibleGraphemes = -1
		return
	end

	label.MaxVisibleGraphemes = 0
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = 0
	self.driver = numberValue
	local v2 = 0
	self.watcher = numberValue:GetPropertyChangedSignal("Value"):Connect(function()
		if run ~= self.run then
			return
		end

		local maxVisibleGraphemes = math.clamp(math.floor(numberValue.Value + 0.5), 0, count)

		if maxVisibleGraphemes == v2 then
			return
		end

		label.MaxVisibleGraphemes = maxVisibleGraphemes

		if self.clicksOn then
			for i = v2 + 1, maxVisibleGraphemes do
				local v4 = v[i]

				if not v4 then
					continue
				end

				voiceGlyph(v4, self.clickSound) -- equivalent call inferred; original call site unknown
			end
		end

		v2 = maxVisibleGraphemes
	end)
	local tween = TweenService:Create(numberValue, TweenInfo.new(count * self.pace), {
		Value = count
	})
	self.sweep = tween
	tween.Completed:Connect(function()
		if run ~= self.run then
			return
		end

		label.MaxVisibleGraphemes = -1
		local watcher = self.watcher

		if watcher then
			watcher:Disconnect()
			self.watcher = nil
		end

		local driver = self.driver

		if driver then
			driver:Destroy()
			self.driver = nil
		end

		self.sweep = nil
	end)
	tween:Play()
end

return MessageTyper