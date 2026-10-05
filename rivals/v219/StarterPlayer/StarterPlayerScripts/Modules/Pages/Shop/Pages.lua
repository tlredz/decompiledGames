local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Signal = require(ReplicatedStorage.Modules.Signal)
require(script:WaitForChild("Daily"))
require(script:WaitForChild("Currency"))
require(script:WaitForChild("Bundles"))
require(script:WaitForChild("Ranked"))
require(script:WaitForChild("Skins"))
require(script:WaitForChild("Home"))
local shopPages = Players.LocalPlayer.PlayerScripts.Assets:WaitForChild("Temp"):WaitForChild("ShopPages")
local v = {
	"Currency",
	"Bundles",
	"Ranked",
	"Daily",
	"Skins",
	"Home"
}
local Pages = {}
Pages.__index = Pages

function Pages.new(shop)
	local self = setmetatable({}, Pages)
	self.UpdateCanvasSize = Signal.new()
	self.Shop = shop
	self.Frame = self.Shop.Container:WaitForChild("Pages")
	self.Components = {}
	self._page_frames = {}
	self:_Init()
	return self
end

function Pages.GetComponentFrame(p, p2)
	return p.Components[p2] and p.Components[p2].Frame
end

function Pages:Open()
	for _, component in pairs(self.Components) do
		component:Open()
	end
end

function Pages:Close()
	for _, component in pairs(self.Components) do
		component:Close()
	end
end

function Pages:Setup()
	for _, component in pairs(self.Components) do
		component:Setup()
	end

	self:_Update()
end

function Pages:_Update()
	for k, _page_frame in pairs(self._page_frames) do
		local visible = k == self.Shop.CurrentPage
		_page_frame.Parent = visible and self.Frame or shopPages
		_page_frame.Visible = visible
	end
end

function Pages:_Setup()
	for _, childName in pairs(v) do
		local module = require(script:WaitForChild(childName))
		local v2 = module.new(self)
		v2.Frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			self.UpdateCanvasSize:Fire()
		end)
		v2.Frame:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
			self.UpdateCanvasSize:Fire()
		end)
		self.Components[childName] = v2
	end

	for _, childName in pairs(self.Shop.PAGE_NAMES) do
		local child = self.Frame:WaitForChild(childName)
		child.Visible = false
		child.Parent = shopPages
		self._page_frames[childName] = child
	end
end

function Pages:_Init()
	self.Shop.CurrentPageChanged:Connect(function()
		self:_Update()
	end)
	self:_Setup()
end

return Pages