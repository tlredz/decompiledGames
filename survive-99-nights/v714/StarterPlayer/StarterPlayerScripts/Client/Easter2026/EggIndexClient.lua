local EggIndexClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local instances = {}
local v = {}

function RefreshEggs(p)
	for _, folder in pairs((nil):GetChildren()) do
		if not folder:IsA("Folder") then
			continue
		end

		local child = p.SurfaceGui.ScrollingFrame:FindFirstChild(folder.Name)

		if not child then
			continue
		end

		local found = folder:GetAttribute("Found")
		local new = folder:GetAttribute("New")

		if found then
			if not v[folder.Name] then
				v[folder.Name] = true
				Client.Events.RevealEggIndexName:FireServer(folder.Name)
			end

			child.Tick.Visible = true
			child.TextLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
			child.EggImage.ImageColor3 = Color3.fromRGB(255, 255, 255)
		else
			child.Tick.Visible = false
			child.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			child.EggImage.ImageColor3 = Color3.fromRGB(103, 103, 103)
			child.TextLabel.Text = "???"
		end

		if new then
			child.NewLabel.Visible = true
		else
			child.NewLabel.Visible = false
		end
	end
end

function TrackEggFolder(p, p2)
	p2.AttributeChanged:Connect(function()
		RefreshEggs(p)
	end)
end

function EggIndexAdded(instance)
	if not instance:FindFirstChild("SurfaceGui") then
		return
	end

	if not table.find(instances, instance) then
		table.insert(instances, instance)
	end

	task.spawn(function()
		while true do
			wait(2)
		end
	end)
end

Client.Events.RevealEggIndexName:Connect(function(childName, text)
	for _, v2 in pairs(instances) do
		if not (v2:FindFirstChild("SurfaceGui") and v2.SurfaceGui.ScrollingFrame:FindFirstChild(childName)) then
			continue
		end

		v2.SurfaceGui.ScrollingFrame[childName].TextLabel.Text = text
	end
end)
Client.Utility.ForAllTagged("EggIndex", EggIndexAdded)

function EggIndexClient.Init() end

return EggIndexClient