local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local Players = game:GetService("Players")
local v = Component.new({
	Tag = "SecretNuclearScreens"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._code = ""
	self._maxLength = 4
	self._previousLength = 0
	self._textConnection = nil
end

function v:Start()
	local codeInput = self.Instance:WaitForChild("CenterScreen"):WaitForChild("ScreenText"):WaitForChild("CodeInput")
	local frame = codeInput:WaitForChild("Frame")
	self._codeInput = codeInput
	self._codeInputFrame = frame
	self._codeInputText = frame:WaitForChild("TextLabel")
	self._codeInputTextBox = frame:WaitForChild("TextBox")
	self._typingSound = self.Instance:WaitForChild("TypingSound")
	self._Janitor:Add(Remotes.connectComponentRemote(self.Instance, "ScreenInteraction", function(p: string)
		if p == "start" then
			self:EnableKeyboardInput()
		elseif p == "end" then
			self:DisableKeyboardInput()
		end
	end))
end

function v:EnableKeyboardInput()
	self:ResetInput()
	self._typingSound:Play()

	if self._textConnection ~= nil then
		self._textConnection:Disconnect()
		self._textConnection = nil
	end

	self._codeInputTextBox:CaptureFocus()
	self._textConnection = self._codeInputTextBox:GetPropertyChangedSignal("Text"):Connect(function()
		local text = self._codeInputTextBox.Text

		if #text < self._previousLength then
			self._code = self._code:sub(1, (math.max(#self._code - 1, 0)))
			self._previousLength = #text
			self:UpdateDisplay()
		else
			self._previousLength = #text
			local v2 = text:sub(#text, #text)

			if v2 == " " then
				self:ExitChairFromInput()
			elseif #self._code < 4 then
				self._code ..= v2
				self:UpdateDisplay()
			end
		end
	end)
end

function v:DisableKeyboardInput()
	self._typingSound:Stop()

	if self._textConnection ~= nil then
		self._textConnection:Disconnect()
		self._textConnection = nil
	end

	self._codeInputTextBox:ReleaseFocus()
	self:ResetInput()
end

function v:UpdateDisplay()
	local text = ""

	for i = 1, 4 do
		local v3 = self._code:sub(i, i)

		if v3 == "" then
			text ..= "_ "
		else
			text ..= v3 .. " "
		end
	end

	self._codeInputText.Text = text

	if #self._code == self._maxLength then
		Remotes.fireServerComponent(self.Instance, "SubmitCode", self._code)
	end
end

function v:ResetInput()
	self._code = ""
	self._previousLength = 0
	self._codeInputTextBox.Text = ""
	self:UpdateDisplay()
end

function v:ExitChairFromInput()
	self._codeInputTextBox:ReleaseFocus()
	local humanoid = Players.LocalPlayer.Character:FindFirstChild("Humanoid")
	task.spawn(function()
		humanoid.Jump = true
		task.wait()
		humanoid.Jump = false
	end)
end

function v:Stop()
	self:DisableKeyboardInput()
	self._Janitor:Destroy()
end

return v