local module = require("@game/ReplicatedStorage/Omni")
local color = Color3.fromRGB(255, 255, 255)
local color2 = Color3.fromRGB(255, 78, 78)
local color3 = Color3.fromRGB(255, 220, 93)
local fusion = module.Libs.Fusion
local Controller = require(script.Controller)
local categories = script.Categories
local backpack = module.Interface:WaitForChild("Frames"):WaitForChild("Backpack")
local categoryFrames = backpack:WaitForChild("CategoryFrames")
local scroll = backpack:WaitForChild("CategoryOptions"):WaitForChild("Scroll")
local category = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("Inventory"):WaitForChild("Category")
local innerScopes = {}
local indexesByName = {}
local Inventory = {}

local function IsCategoryAvailable(p: string)
	if Controller.Mode ~= "Selection" then
		return true
	end

	local isCategoryAvailable = Controller.ModeParams.IsCategoryAvailable
	return typeof(isCategoryAvailable) ~= "function" or isCategoryAvailable(p) == true
end

local scope = fusion.scoped(fusion, {
	Build = function(self, duration: number)
		self.SelectionProgress = self:Value(0)
		self.SelectionProgressSpring = self:Spring(self.SelectionProgress, 10, 1)
		self.Position = self:Value(UDim2.fromScale(-0.5, 0.5))
		self.PositionSpring = self:Spring(self.Position, 10, 1)
		self.Instance = category:Clone()
		self.Instance.Name = self.Name
		self.Instance.Main.Title.Text = self.Name
		module.Button:Create(self.Instance.Main, "Small"):BindFunction("Click", function()
			if Controller.Mode == "Selection" then
				return
			end

			Controller.SetCategory(self.Name)
		end)
		self.Instance.LayoutOrder = self.Index or 999
		self.Instance.Parent = scroll
		self.Instance.Visible = true
		self:Hydrate(self.Instance.Main)({
			Position = self.PositionSpring
		})
		self:Observer(self.SelectionProgressSpring):onBind(function()
			local selectionProgressSpring = self.peek(self.SelectionProgressSpring)

			if not selectionProgressSpring then
				return
			end

			local colorSequence = ColorSequence.new({
				ColorSequenceKeypoint.new(0, color:Lerp(color2, selectionProgressSpring)),
				ColorSequenceKeypoint.new(1, color:Lerp(color3, selectionProgressSpring))
			})
			self.Instance.Main.UIGradient.Color = colorSequence
			self.Instance.Main.Title.UIGradient.Color = colorSequence
		end)

		if duration and duration > 0 then
			task.delay(duration, function()
				if not next(self) then
					return
				end

				self.Position:set(UDim2.fromScale(0.5, 0.5))
			end)
		else
			self.Position:set(UDim2.fromScale(0.5, 0.5))
		end

		self:Update()
		return true
	end,
	Update = function(self)
		local visible = self.Name == Controller.Category
		self.SelectionProgress:set(visible and 1 or 0)
		local instance = self.Instance

		if not visible then
			local name = self.Name

			if Controller.Mode == "Selection" then
				local isCategoryAvailable = Controller.ModeParams.IsCategoryAvailable
				visible = typeof(isCategoryAvailable) ~= "function" or isCategoryAvailable(name) == true
			else
				visible = true
			end
		end

		instance.Visible = visible
	end
})

function Inventory.GetController()
	return Controller
end

function Inventory.GetCategory(p: string)
	return Controller.Categories[p]
end

function Inventory.UpdateCategories()
	for _, v in innerScopes do
		v:Update()
	end

	for _, frame in categoryFrames:GetChildren() do
		if frame:IsA("Frame") then
			frame.Visible = frame.Name == Controller.Category
		end
	end
end

function Inventory.Clear()
	for _, v in innerScopes do
		v.Instance:Destroy()
		v:doCleanup()
	end

	table.clear(innerScopes)
end

function Inventory.Generate()
	local total = 0

	for k, v in indexesByName do
		if innerScopes[k] then
			continue
		end

		local innerScope = scope:innerScope()
		innerScope.Name = k
		innerScope.Index = v

		if innerScope:Build(total) then
			innerScopes[k] = innerScope
			total += 0.05
		else
			innerScope:doCleanup()
		end
	end

	if not indexesByName[Controller.Category] then
		Controller.SetCategory("Items")
	end
end

function Inventory.Init()
	module.Frame:OnFrameClosed(backpack, Inventory.Clear)
	module.Frame:OnFrameOpened(backpack, Inventory.Generate)

	for _, frame in categoryFrames:GetChildren() do
		if frame:IsA("Frame") then
			indexesByName[frame.Name] = frame:GetAttribute("Index") or 999
		end
	end

	Controller.CategoryChanged:Connect(Inventory.UpdateCategories)
	Controller.ModeChanged:Connect(Inventory.UpdateCategories)

	for _, moduleScript in categories:GetChildren() do
		if not moduleScript:IsA("ModuleScript") then
			continue
		end

		local module2 = require(moduleScript)

		if not module2 then
			continue
		end

		if module2.Init then
			module2.Init()
		end

		if module2.Interface then
			module.Frame:OnFrameClosed(module2.Interface, function()
				Controller.UnlockMode()
				Controller.SetMode("Default")
			end)
		end

		Controller.Categories[moduleScript.Name] = module2
	end
end

return Inventory