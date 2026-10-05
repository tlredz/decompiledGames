local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)
local Platform = require(ReplicatedStorage.Modules.Client.Util.Platform)
local ConsoleControlsConstructGate = require(ReplicatedStorage.Modules.Client.Components.UI.Console.ConsoleControlsConstructGate)
local v = Component.new({
	Tag = "ConsoleGlyphImage",
	Extensions = { ConsoleControlsConstructGate }
})
local v2 = {
	DPadUp = "rbxassetid://127242707942108",
	DPadDown = "rbxassetid://109308480997776",
	DPadLeft = "rbxassetid://138012929233940",
	DPadRight = "rbxassetid://81742803492625",
	ButtonA = "rbxassetid://87257014791492",
	ButtonB = "rbxassetid://110843577590637",
	ButtonX = "rbxassetid://79157774848742",
	ButtonY = "rbxassetid://84911095859140",
	ButtonLB = "rbxassetid://103890339908464",
	ButtonLT = "rbxassetid://85443542863117",
	ButtonRB = "rbxassetid://109413976371304",
	ButtonRT = "rbxassetid://115651834797765",
	ButtonCross = "rbxassetid://90997279782416",
	ButtonCircle = "rbxassetid://76020976960287",
	ButtonSquare = "rbxassetid://114433918111380",
	ButtonTriangle = "rbxassetid://128203409502032",
	ButtonL1 = "rbxassetid://139475713940047",
	ButtonL2 = "rbxassetid://139081269764026",
	ButtonR1 = "rbxassetid://87588311016309",
	ButtonR2 = "rbxassetid://136126492973342"
}

function v:Construct()
	self._Janitor = Janitor.new()
	self._createdImageLabel = nil
	self._isUsingOverlay = false
	self._imageObject = nil
	self._textObject = nil
	self._originalTextTransparency = nil
	self._originalRotation = nil
	self._originalBackgroundTransparency = nil
	self._originalScaleType = nil
	self._isExperimentEnabled = true

	if self.Instance:IsA("ImageLabel") or self.Instance:IsA("ImageButton") then
		self._imageObject = self.Instance
	elseif self.Instance:IsA("GuiObject") then
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Name = "ConsoleGlyphImageOverlay"
		imageLabel.BackgroundTransparency = 1
		imageLabel.BorderSizePixel = 0
		imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		imageLabel.Position = UDim2.fromScale(0.5, 0.5)
		imageLabel.Size = UDim2.fromScale(1, 1)
		imageLabel.ScaleType = Enum.ScaleType.Fit
		imageLabel.Image = ""
		imageLabel.Parent = self.Instance
		self._createdImageLabel = imageLabel
		self._isUsingOverlay = true
		self._imageObject = imageLabel

		if self.Instance:IsA("TextLabel") or self.Instance:IsA("TextButton") then
			self._textObject = self.Instance
			self._originalTextTransparency = self._textObject.TextTransparency
		end
	else
		warn((`[ConsoleGlyphImage] Expected GuiObject, got {self.Instance.ClassName} at {self.Instance:GetFullName()}`))
		self._isValidImage = false
		self._defaultImage = ""
		return
	end

	self._isValidImage = true
	local _imageObject = self._imageObject
	self._defaultImage = _imageObject.Image
	self._originalRotation = _imageObject.Rotation
	self._originalBackgroundTransparency = _imageObject.BackgroundTransparency
	self._originalScaleType = _imageObject.ScaleType
end

function v:_resolveExperimentGate()
	local consoleControlsExperimentVariable = self.Instance:GetAttribute("ConsoleControlsExperimentVariable")

	if consoleControlsExperimentVariable == nil then
		return true
	end

	if typeof(consoleControlsExperimentVariable) ~= "string" then
		warn((`[ConsoleGlyphImage] ConsoleControlsExperimentVariable must be a string for {self.Instance:GetFullName()}, received {typeof(consoleControlsExperimentVariable)}`))
		return false
	end

	local v3, v4 = ABTest.GetExperimentVariable("console-controls", consoleControlsExperimentVariable):timeout(7):await()

	if v3 then
		return v4 == true
	end

	return false
end

function v:_getConsoleGlyphImage()
	local consoleGlyphKeyCode = self.Instance:GetAttribute("ConsoleGlyphKeyCode")

	if typeof(consoleGlyphKeyCode) ~= "string" then
		return nil
	end

	local v3 = Enum.KeyCode[consoleGlyphKeyCode]

	if v3 then
		return v2[UserInputService:GetStringForKeyCode(v3)] or UserInputService:GetImageForKeyCode(v3)
	end

	warn((`[ConsoleGlyphImage] Invalid ConsoleGlyphKeyCode "{consoleGlyphKeyCode}" for {self.Instance:GetFullName()}`))
	return nil
end

function v:_applyImage(image: string)
	self._imageObject.Image = image
end

function v:_refreshImage()
	local v3 = Platform.IsConsole() and self:_getConsoleGlyphImage()

	if v3 then
		self:_applyImage(v3)
		self._imageObject.Rotation = 0

		if not self._isUsingOverlay then
			self._imageObject.BackgroundTransparency = 1
			self._imageObject.ScaleType = Enum.ScaleType.Fit
		end

		if self._textObject then
			self._textObject.TextTransparency = 1
		end
	else
		self:_applyImage(self._defaultImage)
		self._imageObject.Rotation = self._originalRotation

		if not self._isUsingOverlay then
			self._imageObject.BackgroundTransparency = self._originalBackgroundTransparency
			self._imageObject.ScaleType = self._originalScaleType
		end

		if self._textObject then
			self._textObject.TextTransparency = self._originalTextTransparency
		end
	end
end

function v:Start()
	if not self._isValidImage then
		return
	end

	self._isExperimentEnabled = self:_resolveExperimentGate()

	if self._isExperimentEnabled ~= true then
		return
	end

	self._Janitor:Add(Platform.PlatformChangedSignal:Connect(function()
		self:_refreshImage()
	end))
	self._Janitor:Add(UserInputService.LastInputTypeChanged:Connect(function()
		self:_refreshImage()
	end))
	self:_refreshImage()
end

function v:Stop()
	self._Janitor:Destroy()

	if self._textObject and self._originalTextTransparency ~= nil then
		self._textObject.TextTransparency = self._originalTextTransparency
	end

	if self._createdImageLabel then
		self._createdImageLabel:Destroy()
		self._createdImageLabel = nil
	end
end

return v