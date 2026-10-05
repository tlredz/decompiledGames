local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GamepadService = game:GetService("GamepadService")
local Players = game:GetService("Players")
require(ReplicatedStorage.Modules.CONSTANTS)
local Signal = require(ReplicatedStorage.Modules.Signal)
local ControlsController = require(Players.LocalPlayer.PlayerScripts.Controllers.ControlsController)
local pages = Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Pages")
local PageSystem = {}
PageSystem.__index = PageSystem

function PageSystem.new(container)
	assert(typeof(container) == "Instance", "Argument 1 invalid, expected an Instance, got " .. tostring(container))
	local self = setmetatable({}, PageSystem)
	self.CurrentPage = nil
	self.PageAdded = Signal.new()
	self.PageOpened = Signal.new()
	self.PageClosed = Signal.new()
	self.PagesActivity = Signal.new()
	self._pages = {}
	self._container = container
	self:_Init()
	return self
end

function PageSystem:GetDefaultElement()
	return self.CurrentPage and self.CurrentPage:GetDefaultElement()
end

function PageSystem:CloseRequest()
	if self.CurrentPage then
		self.CurrentPage:CloseRequest()
	end
end

function PageSystem:GetPage(value)
	assert(typeof(value) == "string", "Argument 1 invalid, expected a string, got " .. tostring(value))

	for k, _page in pairs(self._pages) do
		if _page.Name == value then
			return _page, k
		end
	end
end

function PageSystem:OpenPage(value, p)
	assert(typeof(value) == "string", "Argument 1 invalid, expected a string, got " .. tostring(value))
	assert(not p or typeof(p) == "boolean", "Argument 2 invalid, expected a boolean or nil, got " .. tostring(p))
	local page = self:GetPage(value)

	if not page then
		self:CreatePage(value)
		page = self:WaitForPage(value)
	end

	assert(page ~= nil, "Argument 1 invalid, expected a valid page name, got " .. tostring(value))

	if page == self.CurrentPage then
		if p then
			return
		end

		self:CloseCurrentPage()
	elseif p ~= false then
		self:CloseCurrentPage()
		self:_OpenPage(page)
	end
end

function PageSystem:CloseCurrentPage()
	local currentPage = self.CurrentPage

	if currentPage then
		currentPage:Close()
		self.CurrentPage = nil
		self.PageClosed:Fire(currentPage)
	end
end

function PageSystem:WaitForPage(value)
	assert(typeof(value) == "string", "Argument 1 invalid, expected a string, got " .. tostring(value))
	local page = self:GetPage(value)

	while not page or page.Name ~= value do
		page = self.PageAdded:Wait()
	end

	return page
end

function PageSystem:CreatePage(childName)
	assert(typeof(childName) == "string", "Argument 1 invalid, expected a string, got " .. tostring(childName))
	local module = require(pages:WaitForChild(childName))
	assert(module.GetDefaultElement, "You forgot to implement " .. childName .. ":GetDefaultElement()")
	assert(module.CloseRequest, "You forgot to implement " .. childName .. ":CloseRequest()")
	module.Closed:Connect(function()
		self:OpenPage(module.Name, false)
	end)
	module.OpenPage:Connect(function(...)
		if module:IsOpen() then
			self:OpenPage(...)
		end
	end)
	module:Close()
	table.insert(self._pages, module)
	self.PageAdded:Fire(module)
end

function PageSystem:_OpenPage(currentPage)
	self.CurrentPage = currentPage
	self.CurrentPage:Open(self._container)
	self.PageOpened:Fire(self.CurrentPage)

	if ControlsController.CurrentControls == "Gamepad" then
		local defaultElement = self.CurrentPage:GetDefaultElement()

		if defaultElement and defaultElement:IsDescendantOf(Players.LocalPlayer.PlayerGui) then
			GamepadService:EnableGamepadCursor(defaultElement)
		end
	end
end

function PageSystem:_Init()
	self.PageOpened:Connect(function()
		self.PagesActivity:Fire()
	end)
	self.PageClosed:Connect(function()
		self.PagesActivity:Fire()
	end)
end

return PageSystem