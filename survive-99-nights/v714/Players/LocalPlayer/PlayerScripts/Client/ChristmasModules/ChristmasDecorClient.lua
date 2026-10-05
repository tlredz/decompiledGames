local createVector = vector.create
local ChristmasDecorClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local v = nil
local v2 = nil
local v3 = nil
local v4 = nil
local v5 = nil
local tagged = {}
local v6 = {
	Bell = function(instance)
		task.spawn(function()
			local pivot = instance:GetPivot()
			local total = 0

			while true do
				total += task.wait()
				local v7 = math.sin(total * 1.0471975511965976) * 0.7853981633974483
				instance:PivotTo(pivot * CFrame.Angles(0, 0, v7))
			end
		end)
	end,
	NorthPole = function(instance)
		task.spawn(function()
			while true do
				local v7 = 2.792526803190927 * task.wait()
				instance:PivotTo(instance:GetPivot() * CFrame.Angles(0, v7, 0))
			end
		end)
	end
}

function ChristmasBiomeComplete()
	local tagged2 = CollectionService:GetTagged("ChristmasBiomeAnimation")

	for _, v7 in pairs(tagged2) do
		if v6[v7.Name] then
			v6[v7.Name](v7)
		end
	end

	CollectionService:GetInstanceAddedSignal("ChristmasBiomeAnimation"):Connect(function(p)
		if v6[p.Name] then
			v6[p.Name](p)
		end
	end)
end

function TrackChristmasBiomeProgress()
	if (workspace:GetAttribute("ChristmasDecoration") or 0) >= 1 then
		ChristmasBiomeComplete()
		return
	end

	local christmasDecorationChangedConnection = nil
	christmasDecorationChangedConnection = workspace:GetAttributeChangedSignal("ChristmasDecoration"):Connect(function()
		if (workspace:GetAttribute("ChristmasDecoration") or 0) >= 1 then
			christmasDecorationChangedConnection:Disconnect()
			ChristmasBiomeComplete()
		end
	end)
end

function CreatePrompt()
	local attachment = Instance.new("Attachment")
	attachment.Parent = workspace.Terrain
	v = attachment
	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt.MaxActivationDistance = 20
	proximityPrompt.ActionText = "Decorate"
	proximityPrompt:SetAttribute("Theme", "Christmas")
	proximityPrompt.Style = Enum.ProximityPromptStyle.Custom
	proximityPrompt.HoldDuration = 0.75
	proximityPrompt.Enabled = false
	proximityPrompt.Parent = attachment
	proximityPrompt.RequiresLineOfSight = false
	v2 = proximityPrompt
	proximityPrompt.Triggered:Connect(function()
		print("decorate", v3)
		AttemptDecorateModel(v3)
	end)
end

function AdornHighlight(adornee)
	if v4 then
		v4:Pause()
		v4:Destroy()
		v4 = nil
	end

	v5 = adornee
	local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad)

	if adornee == nil then
		local tween = TweenService:Create(nil, tweenInfo, {
			FillTransparency = 1
		})
		tween.Completed:Connect(function()
			if v5 == adornee then
				(nil).Adornee = nil
				(nil).Enabled = false
			end
		end)
		v4 = tween
		tween:Play()
	else
		(nil).Adornee = adornee;
		(nil).FillTransparency = 1
		(nil).Enabled = true
		local tween = TweenService:Create(nil, tweenInfo, {
			FillTransparency = 0
		})
		v4 = tween
		tween:Play()
	end
end

function AttemptDecorateModel(instance)
	if not instance:HasTag("ChristmasDecor") then
		HighlightClosestDecor()
		return
	end

	local christmasLights = localPlayer.Inventory:FindFirstChild("Christmas Lights")

	if christmasLights then
		task.spawn(function()
			christmasLights.Parent = game.ReplicatedStorage.TempStorage
			local v7 = Client.Events.RequestChristmasDecorate:InvokeServer(instance, christmasLights)
			HighlightClosestDecor()

			if not (v7 and v7.Success) then
				task.delay(0.5, function()
					christmasLights.Parent = localPlayer.Inventory
				end)
				return
			end

			local v8 = instance:GetPivot() + createVector(0, 9, 0)

			for i = 1, 3 do
				local v9 = v8 * CFrame.Angles(0, math.rad(i * 120), 0) * CFrame.new(0, 0, -5)
				Client.CandyCaneClient.SpawnCandyCane(v9, "ChristmasTree", (Vector3.new()))
			end
		end)
	else
		Client.PopUpUI.AddPopUp("you need christmas lights (hint: trees and wolves)", "warning")
	end
end

function PrepareDecor()
	tagged = CollectionService:GetTagged("ChristmasDecor")
	CollectionService:GetInstanceAddedSignal("ChristmasDecor"):Connect(function(p)
		table.insert(tagged, p)
	end)
	CollectionService:GetInstanceRemovedSignal("ChristmasDecor"):Connect(function(p)
		local index = table.find(tagged, p)

		if index then
			table.remove(tagged, index)
		end

		if v3 == p then
			HighlightClosestDecor()
		end
	end)
end

function GetClosestDecor()
	if (workspace:GetAttribute("ChristmasDecoration") or 0) >= 1 then
		return nil
	end

	local v7 = nil
	local v8 = 1e999

	if localPlayer.Character == nil then
		return
	end

	local position = localPlayer.Character:GetPivot().Position

	for _, v9 in pairs(tagged) do
		local magnitude = (position - v9:GetPivot().Position).Magnitude

		if not (magnitude < v8) then
			continue
		end

		v7 = v9
		v8 = magnitude
	end

	return v7, v8
end

function HighlightClosestDecor()
	local v7, v8 = GetClosestDecor()
	local v9 = nil

	if v7 and v8 <= 20 then
		v9 = v7
	end

	if v9 ~= v3 then
		if v9 then
			AdornHighlight(v9:FindFirstChild("Decoration"))
			v.WorldCFrame = v9:GetPivot()
			v2.Enabled = true
		else
			AdornHighlight(nil)
			v2.Enabled = false
		end
	end

	v3 = v9
end

function LoopCheckClosestDecor()
	task.spawn(function()
		while (workspace:GetAttribute("ChristmasDecoration") or 0) < 1 do
			HighlightClosestDecor()
			task.wait(0.1)
		end

		(nil).Adornee = nil
		(nil).Enabled = false
		print("no more checks")
	end)
end

function ChristmasDecorClient.InChristmasSafezone(position)
	if typeof(position) == "Instance" then
		if not position.Character then
			return
		end

		position = position.Character:GetPivot().Position
	end

	local v8 = (workspace:GetAttribute("ChristmasDecoration") or 0) >= 1 and Client.BiomesClient.GetBiome(position) == "Christmas" or false

	if v8 then
		workspace:GetAttribute("ChristmasSafezone")
	end

	return false, v8
end

Client.Events.LightTree:Connect(function(instance)
	local pivot = instance:GetPivot()
	Client.Sound.Play("LightTree", {
		Position = pivot.Position
	})
	Client.Utility.SpawnParticles("LightChristmasTree", pivot)
end)

function ChristmasDecorClient.Init() end

return ChristmasDecorClient