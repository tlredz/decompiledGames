local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local packages = ReplicatedStorage:WaitForChild("packages")
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local Net = require(packages.Net)
local Signal = require(packages.Signal)
local legacyControllers = ReplicatedStorage:WaitForChild("client").legacyControllers
local DataController = require(legacyControllers.DataController)
local modules = ReplicatedStorage:WaitForChild("shared").modules
local fish = require(modules.library.fish)
local items = require(modules.library.items)
local utils = ReplicatedStorage:WaitForChild("shared").utils
local assets = require(utils.assets)
local remoteEvent = Net:RemoteEvent("PodiumService/UpdateState", -1)
local remoteFunction = Net:RemoteFunction("PodiumService/Claim")
local remoteFunction2 = Net:RemoteFunction("PodiumService/Place")
local remoteFunction3 = Net:RemoteFunction("PodiumService/GetState")
local localPlayer = Players.LocalPlayer
local onPodiumActivated = Signal.new()
local podium = Component.new({
	Tag = "Podium"
})

function podium:SetState(placed: boolean, finished: boolean, placedUserId: number?, fishInfo)
	self.Placed = placed
	self.Finished = finished
	self.PlacedUserId = placedUserId
	self.FishInfo = fishInfo
	self.ModelCollector:Clean()

	if placed == true then
		local name = fishInfo.Name
		local clone

		if fish[name] ~= nil then
			local getAsync = assets.getAsync

			if self.IsShiny then
				name = "Shiny_" .. name
			end

			clone = getAsync("fish", name):Clone()
		else
			clone = assets.getAsync("item", name):WaitForChild(name):Clone()
		end

		local cFrame = self.Instance.PrimaryPart.CFrame

		for _, part in clone:GetDescendants() do
			if not part:IsA("BasePart") then
				continue
			end

			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
		end

		clone.Name = "Fish"
		clone.Parent = self.Instance
		local extentsSize = clone:GetExtentsSize()
		clone:ScaleTo(math.min(
			2.001559257507324 / extentsSize.X,
			1.294995903968811 / extentsSize.Y,
			3.430952787399292 / extentsSize.Z
		) * clone:GetScale())
		clone:GetExtentsSize()
		local primaryPart

		if clone.PrimaryPart then
			primaryPart = clone.PrimaryPart
		elseif clone:FindFirstChild("handle") then
			primaryPart = clone:FindFirstChild("handle")
		elseif clone:FindFirstChild("Handle") then
			primaryPart = clone:FindFirstChild("Handle")
		else
			primaryPart = clone:FindFirstChildOfClass("BasePart")
		end

		if primaryPart then
			clone.PrimaryPart = primaryPart
			primaryPart.Anchored = true
		end

		local renderSteppedConnection = nil
		renderSteppedConnection = RunService.RenderStepped:Connect(function(_: number)
			local now = os.clock()
			local v3 = 0.08726646259971647 * now
			local v4 = math.sin(now * 2) * 0.2
			local cFrame2 = cFrame * CFrame.new(0, v4, 0) * CFrame.Angles(0, v3, 0)

			if clone and clone.Parent and clone.PrimaryPart then
				clone.PrimaryPart.CFrame = cFrame2
			else
				renderSteppedConnection:Disconnect()
			end
		end)
		self.ModelCollector:Add(renderSteppedConnection)
		self.ModelCollector:Add(clone)
	end
end

function podium:RefreshPrompt()
	local enabled = false

	if self.Finished then
		enabled = false
	else
		local character = localPlayer.Character

		if self.Placed == false and character and self.Instance:GetAttribute("IsActive") then
			local tool = character:FindFirstChildOfClass("Tool")

			if tool then
				local itemFromLink = DataController.getItemFromLink(tool)

				if itemFromLink then
					local v4 = fish[itemFromLink.name] and "Fish" or items.Items[itemFromLink.name] and "Item" or nil
					enabled = v4 and table.find(self.ListOfItems, itemFromLink.name) and table.find(self.ListOfType, v4) and true or false
				end
			end

			self.ProximityPrompt.ActionText = self.ActionText
		elseif character then
			enabled = self.PlacedUserId == localPlayer.UserId and self.Instance:GetAttribute("BlockClaim") ~= true or false
			self.ProximityPrompt.ActionText = "Claim"
		end
	end

	self.ProximityPrompt.Enabled = enabled
end

function podium:Construct()
	self.Name = self.Instance.Name
	self.Placed = false
	self.Finished = false
	self.Collector = Trove.new()
	self.ModelCollector = Trove.new()
	self.Collector:Add(self.ModelCollector, "Destroy")
	self.Global = self.Instance:GetAttribute("Global") or false
	self.IsShiny = self.Instance:GetAttribute("Shiny") or false
	self.SaveOnData = self.Instance:GetAttribute("SaveOrData") or false
	local listOfItems = self.Instance:GetAttribute("ListOfItems") or ""
	self.ListOfItems = string.split(listOfItems, ",")
	local listOfType = self.Instance:GetAttribute("ListOfType") or ""
	self.ListOfType = string.split(listOfType, ",")
	self.ActionText = ""

	for k, listOfItem in self.ListOfItems do
		if k == 1 then
			self.ActionText ..= listOfItem
		else
			self.ActionText ..= " " .. listOfItem
		end
	end

	local proximityPrompt = Instance.new("ProximityPrompt", self.Instance.PrimaryPart)
	proximityPrompt.Name = "ProximityPrompt"
	proximityPrompt.ActionText = self.ActionText
	proximityPrompt.HoldDuration = 3
	proximityPrompt.MaxActivationDistance = 7
	proximityPrompt.ObjectText = "Podium"
	proximityPrompt.RequiresLineOfSight = false
	proximityPrompt.Style = Enum.ProximityPromptStyle.Custom
	self.ProximityPrompt = proximityPrompt
	self.Instance:GetAttributeChangedSignal("ListOfItems"):Connect(function()
		local listOfItems2 = self.Instance:GetAttribute("ListOfItems") or ""
		self.ListOfItems = string.split(listOfItems2, ",")
		self.ActionText = ""

		for k, listOfItem in self.ListOfItems do
			if k == 1 then
				self.ActionText ..= listOfItem
			else
				self.ActionText ..= " " .. listOfItem
			end
		end

		proximityPrompt.ActionText = self.ActionText
	end)
	self.Instance:GetAttributeChangedSignal("ListOfType"):Connect(function()
		local listOfType2 = self.Instance:GetAttribute("ListOfType") or ""
		self.ListOfType = string.split(listOfType2, ",")
	end)
end

function podium:Start()
	self.Collector:Add(RunService.Stepped:Connect(function(_, _)
		self:RefreshPrompt()
	end))
	self.Collector:Add(self.ProximityPrompt.Triggered:Connect(function()
		if self.Finished == true then
			return
		end

		if self.Placed == true and self.PlacedUserId == localPlayer.UserId then
			remoteFunction:InvokeServer(self.Instance.Name)
		elseif self.Placed == false then
			local _ = remoteFunction2:InvokeServer(self.Instance.Name) == true
		end
	end))
	self.Collector:Add(remoteEvent.OnClientEvent:Connect(function(p: string, flag: boolean, ...)
		if self.Name ~= p then
			return
		end

		if flag == true then
			onPodiumActivated:Fire(p)
		end

		self:SetState(flag, ...)
	end))
	self:SetState(remoteFunction3:InvokeServer(self.Name))
end

function podium.Stop(p)
	p.Collector:Destroy()
end

return {
	Podium = podium,
	OnPodiumActivated = onPodiumActivated
}