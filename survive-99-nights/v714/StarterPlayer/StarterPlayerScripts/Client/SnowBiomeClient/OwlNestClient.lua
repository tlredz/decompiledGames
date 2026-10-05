local OwlNestClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local v = {}
local v2 = {}
local v3 = 0
local color = Color3.fromRGB(90, 90, 90)
local color2 = Color3.fromRGB(255, 238, 88)

function AllFeathersPlaced(_) end

function SetFeatherState(folder, transparency: number, color3: Color3, p: number)
	if folder:GetAttribute("Invisible") then
		color3 = nil
		transparency = 1
	end

	for _, part in pairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		if part:GetAttribute("OrigTransparency") == nil then
			part:SetAttribute("OrigTransparency", part.Transparency)
		end

		if part:GetAttribute("OrigColour") == nil then
			part:SetAttribute("OrigColour", part.Color)
		end

		local color4 = color3 or part:GetAttribute("OrigColour")

		if p == nil then
			part.Transparency = transparency
			part.Color = color4
		else
			local v5 = part
			local transparency2 = part.Transparency
			local color5 = part.Color
			local color6 = color4
			Client.TweenModule.new(function(p2)
				if not (v3 == p and v[folder] ~= nil) then
					return true
				end

				v5.Transparency = transparency2 + (transparency - transparency2) * p2
				v5.Color = color5:Lerp(color6, p2)
			end, 0.5):Play()
		end
	end
end

function RefreshFeatherGhosts()
	local v4 = v3 + 1
	v3 = v4

	for k, _ in v do
		if not k:GetAttribute("Placed") then
			RefreshFeather(k, v4)
		end
	end
end

function ListenForFeatherDragged()
	Client.Events.StartDraggingItem:Connect(function(instance)
		if instance:HasTag("OwlFeather") then
			RefreshFeatherGhosts()
		end
	end)
	Client.Events.ItemDraggingEnded:Connect(function(_)
		task.wait()
		local draggingItem = Client.InteractionHandler.GetDraggingItem()

		if draggingItem == nil or not draggingItem:HasTag("OwlFeather") then
			RefreshFeatherGhosts()
		end
	end)
end

function GetNearestEmptyFeather(p, vector: Vector3)
	local v4 = 1e999
	local v5 = nil

	for _, child in pairs(p.Functional.PlacedFeathers:GetChildren()) do
		if not child:HasTag("PlacedOwlFeather") or child:GetAttribute("Placed") then
			continue
		end

		local magnitude = (child:GetPivot().Position - vector).Magnitude

		if not (magnitude < v4) then
			continue
		end

		v5 = child
		v4 = magnitude
	end

	return v5
end

function FeatherWantsGhost()
	local draggingItem = Client.InteractionHandler.GetDraggingItem()
	return draggingItem ~= nil and draggingItem:HasTag("OwlFeather")
end

function RefreshFeather(instance, p: number)
	if instance:GetAttribute("Invisible") then
		SetFeatherState(instance, 1, nil, p)
	elseif instance:GetAttribute("Placed") then
		SetFeatherState(instance, 0, nil, p)
	elseif FeatherWantsGhost() then
		SetFeatherState(instance, 0.7, color2, p)
	else
		SetFeatherState(instance, 0.7, color, p)
	end
end

function FeatherPlaced(p)
	RefreshFeather(p)
end

function FeatherReset(p)
	RefreshFeather(p)
end

function PlacedFeatherAdded(instance)
	if not instance:GetAttribute("Placed") then
		v[instance] = true
	end

	RefreshFeather(instance)
	instance:GetAttributeChangedSignal("Placed"):Connect(function()
		if instance:GetAttribute("Placed") then
			v[instance] = nil
			FeatherPlaced(instance)
		else
			v[instance] = true
			FeatherReset(instance)
		end
	end)
	instance:GetAttributeChangedSignal("Invisible"):Connect(function()
		RefreshFeather(instance)
	end)
end

function OwlNestAdded(instance)
	instance:WaitForChild("Functional"):WaitForChild("TouchZone").Touched:Connect(function(otherPart)
		if instance:GetAttribute("Completed") then
			return
		end

		local parent = otherPart.Parent

		if parent == nil or parent.Parent ~= workspace.Items or not parent:HasTag("OwlFeather") then
			return
		end

		if parent:GetAttribute("Owner") ~= localPlayer.UserId and parent:GetAttribute("LastOwner") ~= localPlayer.UserId or v2[parent] then
			return
		end

		local v4 = GetNearestEmptyFeather(instance, parent:GetPivot().Position)

		if v4 == nil then
			return
		end

		v2[parent] = true
		parent.Parent = game.ReplicatedStorage.TempStorage
		Client.Sound.Play("FeatherPlace", {
			Replicate = true
		})
		local v5 = Client.Events.RequestPlaceOwlFeather:InvokeServer(parent, v4)
		v2[parent] = nil

		if not (v5 and v5.Success) then
			task.delay(0.5, function()
				parent.Parent = workspace.Items
			end)
		end
	end)
	instance:GetAttributeChangedSignal("Completed"):Connect(function()
		if instance:GetAttribute("Completed") then
			AllFeathersPlaced(instance)
		end
	end)
end

function OwlNestClient.Init()
	Client.Utility.ForAllTagged("PlacedOwlFeather", PlacedFeatherAdded)
	Client.Utility.ForAllTagged("OwlNest", OwlNestAdded)
	ListenForFeatherDragged()
end

return OwlNestClient