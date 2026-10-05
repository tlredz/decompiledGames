local UIController = {}
UIController.__index = UIController
local styleController = require(script.Parent.styleController)
local Signal = require(script.Parent.Signal)
local MenuManager = require(script.Parent.MenuManager)

local function makeProxy(module)
	return (setmetatable({}, {
		__index = function(p, childName)
			local child = module:WaitForChild(childName, 10)

			if not child then
				warn("UIController proxy: module '" .. tostring(childName) .. "' not found in " .. module:GetFullName())
				return nil
			end

			local module2 = require(child)
			rawset(p, childName, module2)
			return module2
		end
	}))
end

function UIController.new(gui, p)
	local object = setmetatable({}, UIController)
	object.gui = gui
	object.activePage = nil
	object._connections = {}
	object._pageSignals = {}
	object.tweens = require(script.Parent.tweenHelpers)
	object.menuManager = MenuManager
	object.map = object.tweens.scanGui(gui)

	if p and p.modules then
		for k, module in pairs(p.modules) do
			object[k] = makeProxy(module)
		end
	end

	object.stylesheets = gui:FindFirstChild("Stylesheets", true)
	object.styleController = styleController.new(object.stylesheets)
	object.styleController.gui = gui
	object._pagesFolder = gui:FindFirstChild("Pages", true)
	object:_setupStylesheet()
	object:_setupPages()
	return object
end

function UIController:_setupStylesheet()
	for _, descendant in pairs(self.gui:GetDescendants()) do
		local stylesheet = descendant:GetAttribute("stylesheet")

		if stylesheet and self.styleController.stylesheets and self.styleController.stylesheets[stylesheet] then
			self.styleController:Apply(descendant, stylesheet)
		end
	end
end

function UIController:_setupPages()
	self._pageMap = {}
	self._pageByName = {}

	if not self._pagesFolder then
		return
	end

	for _, frame in ipairs(self._pagesFolder:GetChildren()) do
		if not frame:IsA("Frame") then
			continue
		end

		local home = frame:FindFirstChild("Home")

		if home and home:IsA("GuiObject") then
			self._pageMap[frame] = {
				Type = "Category",
				Category = frame
			}
			self._pageByName[frame.Name] = home
			self._pageByName[frame.Name .. ".Home"] = home

			for _, guiObject in ipairs(frame:GetChildren()) do
				if not guiObject:IsA("GuiObject") then
					continue
				end

				self._pageMap[guiObject] = {
					Type = "SubPage",
					Category = frame
				}
				self._pageByName[guiObject.Name] = guiObject
				self._pageByName[frame.Name .. "." .. guiObject.Name] = guiObject
			end
		else
			self._pageMap[frame] = {
				Type = "Page"
			}
			self._pageByName[frame.Name] = frame
		end

		frame.Visible = false
	end
end

function UIController:FindPage(value)
	if typeof(value) == "Instance" then
		return value
	end

	if typeof(value) == "string" then
		return self._pageByName[value]
	end

	return nil
end

function UIController:ShowPage(p)
	local page = self:FindPage(p)

	if not page then
		warn("ShowPage failed: page not found")
		return
	end

	local v = self._pageMap[page]

	if not v then
		warn("ShowPage failed: page not registered", page:GetFullName())
		return
	end

	if self.activePage then
		self.activePage.Visible = false
	end

	if v.Type == "SubPage" or v.Type == "Category" then
		local category = v.Category
		self:HideAllPages(category)
		category.Visible = true
		page.Visible = true
		self.activePage = page
		self.gui:SetAttribute("CurrentCategory", category.Name)
		self.gui:SetAttribute("CurrentPage", page.Name)
		self:_firePageShown(category.Name)
	else
		page.Visible = true
		self.activePage = page
		self.gui:SetAttribute("CurrentCategory", page.Name)
		self.gui:SetAttribute("CurrentPage", page.Name)
		self:_firePageShown(page.Name)
	end
end

function UIController:HideAllPages(instance)
	for _, frame in ipairs(instance:GetChildren()) do
		if frame:IsA("Frame") then
			frame.Visible = false
		end
	end

	self.activePage = nil
end

function UIController:BindTab(p, p2)
	local activatedConnection = p.Activated:Connect(function()
		self:ShowPage(p2)
	end)
	table.insert(self._connections, activatedConnection)
end

function UIController:BindButton(p2, callback)
	local activatedConnection = p2.Activated:Connect(function()
		if callback then
			callback()
		end
	end)
	table.insert(self._connections, activatedConnection)
end

function UIController:OnPageShown(p2, p3)
	if not self._pageSignals[p2] then
		self._pageSignals[p2] = Signal.new()
	end

	local connection = self._pageSignals[p2]:Connect(p3)
	table.insert(self._connections, connection)
	return connection
end

function UIController:_firePageShown(p2)
	local _pageSignal = self._pageSignals[p2]

	if _pageSignal then
		_pageSignal:Fire(p2)
	end
end

function UIController.CreateCarousel(_, data)
	local v = {
		Items = data.Items,
		Frames = data.Frames,
		ParentGui = data.ParentGui,
		ItemsPerFrame = data.ItemsPerFrame or 1,
		RenderItem = data.RenderItem,
		Pages = {},
		CurrentPage = 1
	}
	local count = #v.Frames
	local _ = v.ItemsPerFrame * count
	local v2 = 1
	local v3 = 1

	while v2 <= #v.Items do
		local v4 = {
			Frames = {},
			Index = v3
		}

		for i = 1, count do
			v4.Frames[i] = {}

			for i2 = 1, v.ItemsPerFrame do
				if #v.Items < v2 then
					break
				end

				v4.Frames[i][i2] = v.Items[v2]
				v2 += 1
			end
		end

		table.insert(v.Pages, v4)
		v3 += 1
	end

	function v:ShowPage(value)
		local currentPage = math.clamp(value, 1, #v.Pages)
		v.CurrentPage = currentPage
		v.ParentGui:SetAttribute("currentPage", v.CurrentPage)

		for _, frame in ipairs(v.Frames) do
			for _, guiObject in ipairs(frame:GetChildren()) do
				if guiObject:IsA("GuiObject") then
					guiObject.Visible = false
				end
			end
		end

		local page = v.Pages[currentPage]

		for i, list in ipairs(page.Frames) do
			local frame = v.Frames[i]

			for _, v5 in ipairs(list) do
				v5.Visible = true
				v5.Parent = frame
			end
		end
	end

	function v.Next(_)
		if v.CurrentPage < #v.Pages then
			v:ShowPage(v.CurrentPage + 1)
		end
	end

	function v.Previous(_)
		if v.CurrentPage > 1 then
			v:ShowPage(v.CurrentPage - 1)
		end
	end

	function v.GetPageCount(_)
		return #v.Pages
	end

	function v.GetCurrentPage(_)
		return v.CurrentPage
	end

	local v4 = {}

	for i, item in ipairs(v.Items) do
		local item2 = v.RenderItem(item)
		item2.Visible = false
		v4[i] = item2
	end

	local v5 = 1

	for _, page in ipairs(v.Pages) do
		for _, frame in ipairs(page.Frames) do
			for i = 1, #frame do
				frame[i] = v4[v5]
				v5 += 1
			end
		end
	end

	v:ShowPage(1)
	return v
end

function UIController.Open(p)
	if not p.gui:IsA("GuiObject") then
		return
	end

	if p.gui:IsA("ScreenGui") or p.gui:IsA("SurfaceGui") or p.gui:IsA("BillboardGui") then
		p.gui.Enabled = true
	else
		p.gui.Visible = true
	end
end

function UIController.Close(p, _)
	if not p.gui:IsA("GuiObject") then
		return
	end

	if p.gui:IsA("ScreenGui") or p.gui:IsA("SurfaceGui") or p.gui:IsA("BillboardGui") then
		p.gui.Enabled = false
	else
		p.gui.Visible = false
	end
end

function UIController:Destroy()
	for _, _connection in ipairs(self._connections) do
		_connection:Disconnect()
	end

	for _, _pageSignal in pairs(self._pageSignals) do
		_pageSignal:Destroy()
	end

	table.clear(self)
end

return UIController