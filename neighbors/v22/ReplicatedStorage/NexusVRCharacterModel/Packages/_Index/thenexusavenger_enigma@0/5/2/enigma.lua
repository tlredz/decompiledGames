local UserInputService = game:GetService("UserInputService")
local VRService = game:GetService("VRService")
local TrackerRole = require(script:WaitForChild("Data"):WaitForChild("TrackerRole"))
local CombinedInput = require(script:WaitForChild("Input"):WaitForChild("CombinedInput"))
local CompanionPluginInput = require(script:WaitForChild("Input"):WaitForChild("CompanionPluginInput"))
local TextBoxInput = require(script:WaitForChild("Input"):WaitForChild("TextBoxInput"))
local DeserializeOpenVrInputs = require(script:WaitForChild("Serialization"):WaitForChild("DeserializeOpenVrInputs"))
local CalculateRolloff = require(script:WaitForChild("Util"):WaitForChild("CalculateRolloff"))
local Enigma = {}
Enigma.Enabled = false
Enigma.TrackerRoles = TrackerRole
Enigma.Input = nil
Enigma.LastInputData = ""
Enigma.LastInputTime = tick()
Enigma.LastFloorCFrameToOrigin = CFrame.identity
Enigma.LastInputs = {}

function Enigma.IsActive(p)
	local focusedTextBox = UserInputService:GetFocusedTextBox()

	if focusedTextBox and focusedTextBox.Parent and focusedTextBox.Name == "EnigmaTextBox" then
		return true
	end

	return tick() - p.LastInputTime < 0.5
end

function Enigma:UpdateUserCFrames()
	if not self.Input then
		warn("Enigma is not enabled. Call Enigma:Enable() before calling.")
		return
	end

	local currentText = self.Input:GetCurrentText()

	if currentText ~= self.LastInputData then
		pcall(function()
			local lastInputs = {}

			for _, v2 in DeserializeOpenVrInputs(currentText) do
				if not lastInputs[v2.TrackerRole] then
					lastInputs[v2.TrackerRole] = {}
				end

				table.insert(lastInputs[v2.TrackerRole], v2)
			end

			self.LastInputData = currentText
			self.LastInputTime = tick()
			self.LastFloorCFrameToOrigin = VRService:GetUserCFrame(Enum.UserCFrame.Floor)
			self.LastInputs = lastInputs
		end)
	elseif tick() - self.LastInputTime >= 0.5 then
		self.LastInputs = {}
	end
end

function Enigma:GetUserCFrameEnabled(p, value: number?)
	self:UpdateUserCFrames()
	local lastInput = self.LastInputs[p]
	return lastInput ~= nil and lastInput[value or 1] ~= nil
end

function Enigma:GetUserCFrame(p, value: number?)
	self:UpdateUserCFrames()
	local lastInput = self.LastInputs[p]

	if not lastInput then
		return nil
	end

	local v = lastInput[value or 1]

	if not v then
		return nil
	end

	local calculateRolloff = CalculateRolloff(0.03, 0.09, tick() - self.LastInputTime)
	return self.LastFloorCFrameToOrigin * (CFrame.new(v.FloorRelativeVelocity * calculateRolloff) * v.FloorRelativeCFrame)
end

function Enigma.Enable(p)
	if p.Input then
		return
	end

	p.Input = CombinedInput.new({ TextBoxInput.new(), CompanionPluginInput.new() })
	p.Enabled = true
end

return Enigma