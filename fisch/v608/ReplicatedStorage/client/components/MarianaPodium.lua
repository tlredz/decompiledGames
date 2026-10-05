local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local packages = ReplicatedStorage:WaitForChild("packages")
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local Timer = require(packages.Timer)
local Net = require(packages.Net)
local modules = ReplicatedStorage.shared.modules
local items = require(modules.library.items)
local fish = require(modules.library.fish)
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local assets = require(ReplicatedStorage.shared.utils.assets)
local localPlayer = Players.LocalPlayer
local marianaPodium = legacyLocalPlayerData.fetch():WaitForChild("Cache"):WaitForChild("MarianaPodium", 15)

if not marianaPodium then
	return {}
end

local remoteEvent = Net:RemoteEvent("MarianaPodiumService/Place")
local _ = {
	"Common",
	"Heat",
	"Ice",
	"Deep"
}
local v = {
	Heat = "rbxassetid://114021683567370",
	Ice = "rbxassetid://111212529156838",
	Deep = "rbxassetid://109555482745392"
}
local v2 = Component.new({
	Tag = "MarianaPodium"
})

local function IsValidToPlace(object)
	local character = localPlayer.Character

	if not character then
		return false
	end

	local tool = character:FindFirstChildOfClass("Tool")

	if not tool then
		return false
	end

	if table.find(object.ValidItems, tool.Name) then
		return table.find(string.split(object.DataStringValue.Value, "."), tool.Name) == nil
	end

	return false
end

local function SetupAnimatedModel(data, folder, cFrame: CFrame)
	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
	end

	folder.Name = "Fish"
	folder.Parent = data.Instance
	local extentsSize = folder:GetExtentsSize()
	folder:ScaleTo(math.min(
		2.001559257507324 / extentsSize.X,
		1.294995903968811 / extentsSize.Y,
		3.430952787399292 / extentsSize.Z
	) * folder:GetScale())
	local extentsSize2 = folder:GetExtentsSize()
	local primaryPart

	if folder.PrimaryPart then
		primaryPart = folder.PrimaryPart
	elseif folder:FindFirstChild("handle") then
		primaryPart = folder:FindFirstChild("handle")
	elseif folder:FindFirstChild("Handle") then
		primaryPart = folder:FindFirstChild("Handle")
	else
		primaryPart = folder:FindFirstChildOfClass("BasePart")
	end

	if primaryPart then
		folder.PrimaryPart = primaryPart
		primaryPart.Anchored = true
	end

	local v3 = cFrame * CFrame.new(0, extentsSize2.Y / 1.5, 0)
	local renderSteppedConnection = nil
	renderSteppedConnection = RunService.RenderStepped:Connect(function(_: number)
		local now = os.clock()
		local v4 = 0.08726646259971647 * now
		local v5 = math.sin(now * 2) * 0.2
		local cFrame2 = v3 * CFrame.new(0, v5, 0) * CFrame.Angles(0, v4, 0)

		if folder and folder.Parent and folder.PrimaryPart then
			folder.PrimaryPart.CFrame = cFrame2
		else
			renderSteppedConnection:Disconnect()
		end
	end)
	data.Trove:Add(renderSteppedConnection)
	data.Trove:Add(folder)
end

function v2:BuildInterface()
	local main = self.Resources:WaitForChild("Main")
	local resources = main:WaitForChild("Resources")

	for childName, validItem in self.ValidItems do
		local child = resources:WaitForChild(childName)

		if fish[validItem] ~= nil then
			child.Title.Text = validItem
			child.Icon.Image = fish[validItem].Icon or ""
		else
			child.Title.Text = validItem
			child.Icon.Image = items.Items[validItem].Icon or ""
		end
	end

	local rewards = main:WaitForChild("Rewards")
	local suit = rewards:WaitForChild("Suit")
	local submarineSkin = rewards:WaitForChild("SubmarineSkin")
	local item = items.Items[self.Suit]
	suit.Icon.Image = item.Icon or ""
	suit.Title.Text = self.Suit
	submarineSkin.Title.Text = `{self.SubmarineSkin} Upgrade`
	submarineSkin.Icon.Image = v[self.SubmarineSkin]
end

function v2:UpdateRender()
	local main = self.Resources:WaitForChild("Main")
	local resources = main:WaitForChild("Resources")
	local v3 = string.split(self.DataStringValue.Value, ".")

	for childName, childName2 in self.ValidItems do
		if table.find(v3, childName2) then
			if not self.RenderedItems[childName2] then
				local clone

				if fish[childName2] ~= nil then
					clone = assets.getAsync("fish", childName2):Clone()
				else
					clone = assets.getAsync("item", childName2):WaitForChild(childName2):Clone()
				end

				local cFrame = self.Instance:WaitForChild("Podium"):WaitForChild(childName).CFrame
				self.RenderedItems[childName2] = clone
				SetupAnimatedModel(self, clone, cFrame)
			end
		elseif self.RenderedItems[childName2] then
			self.RenderedItems[childName2]:Destroy()
			self.RenderedItems[childName2] = nil
		end
	end

	main.Amount.Text = `{v3[1] == "" and 0 or #v3}/{#self.ValidItems}`

	if self.Resources.Enabled == true then
		for childName, validItem in self.ValidItems do
			local waitForChild = resources:WaitForChild(childName)
			waitForChild.Checkmark.Visible = table.find(v3, validItem) ~= nil
		end
	end

	local rewards = main:WaitForChild("Rewards")
	local suit = rewards:WaitForChild("Suit")
	local submarineSkin = rewards:WaitForChild("SubmarineSkin")
	suit.Checkmark.Visible = #v3 == #self.ValidItems
	submarineSkin.Checkmark.Visible = #v3 == #self.ValidItems
end

function v2:Construct()
	self.Trove = Trove.new()
	self.ValidItems = string.split(self.Instance:GetAttribute("Resources"), ".")
	self.RenderedItems = {}
	self.Suit = self.Instance:GetAttribute("Suit")
	self.SubmarineSkin = self.Instance:GetAttribute("SubmarineSkin")
	self.DataStringValue = marianaPodium:WaitForChild(self.Instance.Name)
	self.Floating = self.Instance:WaitForChild("Floating")
	self.Resources = self.Floating:WaitForChild("Resources")
	self.ProximityPrompt = self.Floating:WaitForChild("ProximityPrompt")
end

function v2:Start()
	self:BuildInterface()
	self.Trove:Add(self.DataStringValue.Changed:Connect(function()
		self:UpdateRender()
	end))
	self.Trove:Add(self.ProximityPrompt.Triggered:Connect(function()
		remoteEvent:FireServer(self.Instance.Name)
	end))
	self:UpdateRender()
	local v3 = Timer.new(1)
	self.Trove:Add(v3.Tick:Connect(function()
		self.ProximityPrompt.Enabled = IsValidToPlace(self)
	end))
	self.Trove:Add(v3, "Destroy")
	v3:Start()
end

function v2.Stop(p)
	p.Trove:Destroy()
end

return v2