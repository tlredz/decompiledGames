local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local controllers = ReplicatedStorage:WaitForChild("Controllers")
local InterfaceController = require(controllers.InterfaceController)
local NotificationController = require(controllers.NotificationController)
local SoundController = require(controllers.SoundController)
local classes = ReplicatedStorage:WaitForChild("Classes")
local AnimatedButton = require(classes.AnimatedButton)
local packages = ReplicatedStorage.Packages
local Trove = require(packages.Trove)
local Net = require(packages.Net)
local Observers = require(packages.Observers)
local Synchronizer = require(packages.Synchronizer)
local TradePlazaServerBrowserFlags = require(ReplicatedStorage.Shared.Flags.TradePlazaServerBrowserFlags)
local TradePlazaPartitions = require(ReplicatedStorage.Shared.TradePlazaPartitions)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local NumberUtils = require(ReplicatedStorage.Utils.NumberUtils)
local cframe = CFrame.new(0, -100000, 0)
local v = { "Normal", "Pro", "OG" }
local color = Color3.fromRGB(81, 158, 86)
local color2 = Color3.fromRGB(115, 152, 172)
local color3 = Color3.fromRGB(55, 68, 76)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

local function meetsPartitionRequirement(p: string)
	if p == "Normal" then
		return true
	end

	if p == "Pro" and ServerData.TradePlazaProPlaceId == 0 or p == "OG" and ServerData.TradePlazaOgPlaceId == 0 then
		return false
	end

	local v2 = Synchronizer:Get(localPlayer)

	if not v2 then
		return false
	end

	local generation = v2:Get("Generation") or 0
	local podiumsHaveOGBrainrot = TradePlazaPartitions.podiumsHaveOGBrainrot(v2:Get("AnimalPodiums"))
	return TradePlazaPartitions.meetsRequirement(p, generation, podiumsHaveOGBrainrot)
end

return {
	Start = function(_)
		if not ServerData.IsTradePlaza() then
			return
		end

		local remoteFunction = Net:RemoteFunction("TradePlazaServerBrowserService/Search")
		local remoteFunction2 = Net:RemoteFunction("TradePlazaServerBrowserService/Join")
		local tradePlazaServerBrowser = playerGui:WaitForChild("TradePlazaServerBrowser"):WaitForChild("TradePlazaServerBrowser")
		local main = tradePlazaServerBrowser.Main
		local list = main.Content.Holder.List
		local btns = main.Content.Btns
		local searchBox = main.Header.SearchFrame.SearchBox
		local v2 = InterfaceController:Register("TradePlazaServerBrowser", tradePlazaServerBrowser, "TopQuint")
		v2:AttachCloseButton(main.Header.Close)
		v2:Close()
		local clone = list.Template:Clone()
		clone.Visible = false

		for _, guiObject in list:GetChildren() do
			if guiObject.Name == "Template" and guiObject:IsA("GuiObject") then
				guiObject:Destroy()
			end
		end

		local v3 = "Normal"
		local text = ""
		local flag = false
		local v4 = false
		local maid = Trove.new()

		local function joinServer(data, p)
			if data.isCurrentServer then
				return
			end

			SoundController:PlaySound("Sounds.Sfx.Activated")
			p.Txt.Text = "..."
			xpcall(function()
				local v5, v6 = remoteFunction2:InvokeServer(data.jobId, data.partition)

				if not v5 then
					if typeof(v6) == "string" then
						NotificationController:Error(v6)
					end

					p.Txt.Text = "JOIN"
				end
			end, function(p2)
				warn("[TradePlazaServerBrowserController] Join failed", p2)
				p.Txt.Text = "JOIN"
			end)
		end

		local function renderResults(result)
			maid:Clean()

			if type(result) ~= "table" then
				return
			end

			for k, item in result do
				local clone2 = maid:Clone(clone)
				clone2.Name = item.jobId
				clone2.LayoutOrder = k
				clone2.Top.ServerName.Text = item.name
				clone2.Bottom.RegionName.Text = item.region
				clone2.Bottom.Players.Text = `{item.players}/{item.maxPlayers}`
				local totalGeneration = clone2.Top.TotalGeneration
				totalGeneration.RichText = true
				local formatted = `Total: <font color="rgb(0,255,0)">${NumberUtils:ToString(item.totalGeneration)}/s</font>`
				local formatted2 = `Median: <font color="rgb(0,255,0)">${NumberUtils:ToString(item.medianGeneration)}/s</font>`
				totalGeneration.Text = formatted
				maid:Add(totalGeneration.MouseEnter:Connect(function()
					totalGeneration.Text = formatted2
				end))
				local totalGeneration2 = totalGeneration
				maid:Add(totalGeneration.MouseLeave:Connect(function()
					totalGeneration2.Text = formatted
				end))
				local join = clone2.Bottom.Join
				join.Txt.Text = item.isCurrentServer and "CURRENT" or "JOIN"
				local v9 = AnimatedButton.new(join)
				v9:Animate()
				maid:Add(v9, "Destroy")
				local v10 = item
				maid:Add(v9.OnActivated:Connect(function()
					joinServer(v10, join)
				end))
				clone2.Visible = true
				clone2.Parent = list
			end
		end

		local function runSearch()
			if flag then
				v4 = true
				return
			end

			flag = true
			searchBox.TextEditable = false
			searchBox.Active = false

			while true do
				v4 = false
				searchBox.Text = "..."
				local lastTime = os.clock()
				local success, result = pcall(function()
					return remoteFunction:InvokeServer(v3, text)
				end)
				local v5 = TradePlazaServerBrowserFlags.MinSearchDuration:Get()
				local v6 = os.clock() - lastTime

				if v6 < v5 then
					task.wait(v5 - v6)
				end

				if success and type(result) == "table" then
					renderResults(result)
				elseif not success then
					warn("[TradePlazaServerBrowserController] Search failed", result)
				end

				if v4 then
					continue
				end

				searchBox.Text = text
				searchBox.TextEditable = true
				searchBox.Active = true
				flag = false
				break
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getLockedText(childName: string)
			if childName == "Pro" then
				return (`${NumberUtils:ToString(TradePlazaPartitions.getProGenerationRequirement())}/s required`)
			elseif childName == "OG" then
				return (`${NumberUtils:ToString(TradePlazaPartitions.getOGGenerationRequirement())}/s + OG required`)
			end

			return ""
		end

		local function updatePartitionVisual(p: string)
			for _, childName in v do
				local guiObject = btns:FindFirstChild(childName)

				if not (guiObject and guiObject:IsA("GuiObject")) then
					continue
				end

				local v5 = meetsPartitionRequirement(childName)
				local locked = guiObject:FindFirstChild("Locked")

				if locked and locked:IsA("GuiObject") then
					locked.Visible = not v5
					local txt = locked:FindFirstChild("Txt")

					if txt and txt:IsA("TextLabel") then
						local lockedText = getLockedText(childName) -- equivalent call inferred; original call site unknown
						txt.Text = lockedText
					end
				end

				if v5 then
					local backgroundColor

					if childName == p then
						backgroundColor = color
					else
						backgroundColor = color2
					end

					guiObject.BackgroundColor3 = backgroundColor
				else
					guiObject.BackgroundColor3 = color3
				end
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function refreshPartitionVisual()
			local v5

			if meetsPartitionRequirement(v3) then
				v5 = false
			else
				v3 = "Normal"
				v5 = true
			end

			updatePartitionVisual(v3)

			if v5 and v2:IsOpened() then
				runSearch()
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setPartition(p: string)
			if meetsPartitionRequirement(p) then
				v3 = p
				updatePartitionVisual(p)
				runSearch()
			else
				NotificationController:Error("You don't meet the requirements for that server")
				refreshPartitionVisual() -- equivalent call inferred; original call site unknown
			end
		end

		for _, childName in v do
			local button = btns:FindFirstChild(childName)

			if not (button and button:IsA("GuiButton")) then
				continue
			end

			local v5 = AnimatedButton.new(button)
			v5:Animate()
			local v6 = childName
			v5.OnActivated:Connect(function()
				if v3 == v6 then
					return
				end

				if meetsPartitionRequirement(v6) then
					SoundController:PlaySound("Sounds.Sfx.Activated")
					setPartition(v6) -- equivalent call inferred; original call site unknown
				else
					refreshPartitionVisual() -- equivalent call inferred; original call site unknown
				end
			end)
		end

		searchBox.ReturnPressedFromOnScreenKeyboard:Connect(function()
			searchBox:ReleaseFocus(true)
		end)
		searchBox.FocusLost:Connect(function(flag2: boolean)
			if not flag2 then
				return
			end

			text = searchBox.Text
			runSearch()
		end)
		v2.OnOpen:Connect(function()
			refreshPartitionVisual() -- equivalent call inferred; original call site unknown
			runSearch()
		end)
		task.spawn(function()
			local v5 = Synchronizer:Wait(localPlayer)

			if not v5 then
				return
			end

			v5:OnChanged("AnimalPodiums", refreshPartitionVisual)
			v5:OnChanged("AnimalAddedOrRemoved", refreshPartitionVisual)
			v5:OnChanged("Generation", refreshPartitionVisual)
			refreshPartitionVisual() -- equivalent call inferred; original call site unknown
		end)
		refreshPartitionVisual() -- equivalent call inferred; original call site unknown

		local function isFeatureEnabled()
			return TradePlazaServerBrowserFlags.Enabled:Get()
		end

		local v5 = {}

		local function refreshAll()
			for k in v5 do
				k()
			end
		end

		Observers.observeTag("TradePlazaServerBrowserPrompt", function(proximityPrompt)
			if not proximityPrompt:IsA("ProximityPrompt") then
				return
			end

			proximityPrompt.Style = Enum.ProximityPromptStyle.Custom

			-- equivalent calls inferred from this helper; original call sites unknown
			local function apply()
				proximityPrompt.Enabled = TradePlazaServerBrowserFlags.Enabled:Get()
			end

			local triggeredConnection = proximityPrompt.Triggered:Connect(function()
				if not TradePlazaServerBrowserFlags.Enabled:Get() then
					return
				end

				InterfaceController:Toggle("TradePlazaServerBrowser", true)
			end)
			v5[apply] = true
			apply() -- equivalent call inferred; original call site unknown
			return function()
				v5[apply] = nil
				triggeredConnection:Disconnect()
			end
		end)
		Observers.observeTag("TradePlazaServerBrowserModel", function(pVInstance)
			if not pVInstance:IsA("PVInstance") then
				return
			end

			local pivot = pVInstance:GetPivot()

			-- equivalent calls inferred from this helper; original call sites unknown
			local function apply()
				if TradePlazaServerBrowserFlags.Enabled:Get() then
					pVInstance:PivotTo(pivot)
				else
					pVInstance:PivotTo(pivot * cframe)
				end
			end

			v5[apply] = true
			apply() -- equivalent call inferred; original call site unknown
			return function()
				v5[apply] = nil

				if pVInstance.Parent then
					pcall(function()
						pVInstance:PivotTo(pivot)
					end)
				end
			end
		end)
		TradePlazaServerBrowserFlags.Enabled.Changed:Connect(function()
			for k in v5 do
				k()
			end

			if not TradePlazaServerBrowserFlags.Enabled:Get() then
				InterfaceController:SetState("TradePlazaServerBrowser", false)
			end
		end)
	end
}