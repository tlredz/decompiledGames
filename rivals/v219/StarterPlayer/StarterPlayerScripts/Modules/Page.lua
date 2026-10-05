local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local Signal = require(ReplicatedStorage.Modules.Signal)
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UILibrary"))
local pages = Players.LocalPlayer.PlayerScripts.Assets:WaitForChild("Temp"):WaitForChild("Pages")
local Page = {}
Page.__index = Page

function Page.new(name)
	assert(typeof(name) == "string", "Argument 1 invalid, expected a string, got " .. tostring(name))
	local self = setmetatable({}, Page)
	self.OpenChanged = Signal.new()
	self.Closed = Signal.new()
	self.OpenPage = Signal.new()
	self.Name = name
	self.PageFrame = UILibrary:GetPage(name)
	self.CantBeClosedFromInputs = false
	self._default_size = self.PageFrame.Size
	self._is_open = false
	self._is_open_hash = 0
	self._open_connections = {}
	self._open_threads = {}
	self._temp_folder = pages
	self._redirect_to = nil
	self._open_animation_disabled = false
	self:_Init()
	return self
end

function Page:GetDefaultElement()
	return self.PromptSystem and self.PromptSystem:GetDefaultElement() or self.PageFrame
end

function Page:CloseRequest()
	if self.PromptSystem and self.PromptSystem.CurrentPrompt then
		self.PromptSystem.CurrentPrompt:CloseRequest()
		return
	end

	if not self._redirect_to then
		self.Closed:Fire()
		return
	end

	self.OpenPage:Fire(self._redirect_to)
	self._redirect_to = nil
end

function Page:IsOpen()
	return self._is_open
end

function Page:Open(parent)
	assert(typeof(parent) == "Instance", "Argument 1 invalid, expected an Instance, got " .. tostring(parent))
	self.PageFrame.Parent = parent
	self.PageFrame.Visible = true

	if self._open_animation_disabled or GuiService.ReducedMotionEnabled then
		self.PageFrame.Size = self._default_size
		self.PageFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	else
		self.PageFrame.Size = UDim2.new(
			self._default_size.X.Scale * 0.75,
			self._default_size.X.Offset * 0.75,
			self._default_size.Y.Scale * 0.75,
			self._default_size.Y.Offset * 0.75
		)
		self.PageFrame:TweenSize(self._default_size, "Out", "Back", 0.25, true)
		self.PageFrame.Position = UDim2.new(0.5, 0, 0.6, 0)
		self.PageFrame:TweenPosition(UDim2.new(0.5, 0, 0.5, 0), "Out", "Back", 0.25, true)
	end

	self:_CleanupOnOpenChanged()
	self._is_open = true
	self._is_open_hash += 1
	self.OpenChanged:Fire()
end

function Page:Close()
	self:_CleanupOnOpenChanged()
	self._is_open = false
	self._is_open_hash += 1
	self.OpenChanged:Fire()

	if self.PromptSystem then
		self.PromptSystem:Close()
	end

	self.PageFrame.Visible = false
	self.PageFrame.Parent = pages
end

function Page:RedirectTo(redirect_to)
	self._redirect_to = redirect_to
end

function Page:_CleanupOnOpenChanged()
	for _, _open_connection in pairs(self._open_connections) do
		_open_connection:Disconnect()
	end

	for _, _open_thread in pairs(self._open_threads) do
		pcall(task.cancel, _open_thread)
	end

	self._open_connections = {}
	self._open_threads = {}
end

function Page:_Init() end

return Page