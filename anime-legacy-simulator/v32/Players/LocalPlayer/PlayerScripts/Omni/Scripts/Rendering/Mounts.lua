local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Omni = require(ReplicatedStorage:WaitForChild("Omni"))
local mount = Omni.Assets:WaitForChild("Effects"):WaitForChild("Mount")
local mobile = Omni.Interface:WaitForChild("HUD"):WaitForChild("Mobile")
local v = {}
local v2 = nil
local v3 = 0
local Mounts = {}

local function RefreshMountButton(character)
	local v4 = character:GetAttribute("Mounted") ~= nil

	if v2 == v4 then
		return
	end

	v2 = v4
	mobile.Mount.Title.Text = v4 and "[ON]" or "[OFF]"
	mobile.Mount.Title.FrontTitle.Text = v4 and "[ON]" or "[OFF]"
	local frontTitle = mobile.Mount.Title.FrontTitle
	local textColor

	if v4 then
		textColor = Color3.new(0, 1, 0)
	else
		textColor = Color3.new(1, 0, 0)
	end

	frontTitle.TextColor3 = textColor
end

function Mounts.Init()
	for _, moduleScript in script:GetChildren() do
		if not moduleScript:IsA("ModuleScript") then
			continue
		end

		local v4 = v
		local name = moduleScript.Name
		local module = require(moduleScript)
		v4[name] = module
	end
end

function Mounts.Active()
	if Omni.Instance:GetAttribute("MountName") or not Omni.Instance:GetAttribute("Frozen") then
		Omni.Signal:Fire("General", "Mounts", "Active")
	end
end

function Mounts.RefreshPlayer(player)
	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local mount2 = player:GetAttribute("Mount")
	local mounted = character:GetAttribute("Mounted")
	local mountHidden = character:GetAttribute("MountHidden")
	local v4 = player == Omni.Instance

	if v4 then
		RefreshMountButton(character)
	end

	if mount2 then
		local v5 = Omni.Shared.Mounts.List[mount2]

		if not v5 then
			return
		end

		if v5.HideCharacter and not mountHidden then
			character:SetAttribute("MountHidden", true)

			for _, descendant in character:GetDescendants() do
				if not (descendant:IsA("BasePart") or descendant:IsA("Decal")) then
					continue
				end

				if not descendant:GetAttribute("OriginalProperty") then
					descendant:SetAttribute("OriginalProperty", descendant.Transparency)
				end

				descendant.Transparency = 1
			end
		end

		if not mounted then
			local v6 = v[v5.Type]

			if not v6 then
				return
			end

			if v6.Create(player, character, mount2) == true then
				local clone = mount:Clone()
				clone.CFrame = humanoidRootPart.CFrame
				clone.Parent = workspace
				Omni.Utils.Particles:Emit(clone)
				Omni.Services.Debris:AddItem(clone, 3)
				character:SetAttribute("Mounted", v5.Type)

				if v4 then
					RefreshMountButton(character)
				end
			end
		end
	else
		if mountHidden then
			character:SetAttribute("MountHidden", nil)

			for _, descendant in character:GetDescendants() do
				if not ((descendant:IsA("BasePart") or descendant:IsA("Decal")) and descendant:GetAttribute("OriginalProperty")) then
					continue
				end

				descendant.Transparency = descendant:GetAttribute("OriginalProperty")
			end
		end

		if mounted then
			local v5 = v[mounted].Get(character)

			if not v5 then
				return
			end

			local clone = mount:Clone()
			clone.CFrame = humanoidRootPart.CFrame
			clone.Parent = workspace
			Omni.Utils.Particles:Emit(clone)
			Omni.Services.Debris:AddItem(clone, 3)
			v5:Destroy()
			character:SetAttribute("Mounted", nil)

			if v4 then
				RefreshMountButton(character)
			end
		end
	end
end

function Mounts.Refresh()
	for _, v4 in Omni.Services.Players:GetPlayers() do
		Mounts.RefreshPlayer(v4)
	end
end

Omni.Button:Create(mobile.Mount, "Small"):BindFunction("Click", function()
	Mounts.Active()
end)
Omni.Services.UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.KeyCode == Enum.KeyCode.M or input.KeyCode == Enum.KeyCode.V or input.KeyCode == Enum.KeyCode.DPadLeft then
		Mounts.Active()
	end
end)
Omni.Instance:GetAttributeChangedSignal("Mount"):Connect(Mounts.Refresh)
Omni.Services.RunService.Heartbeat:Connect(function()
	Mounts.RefreshPlayer(Omni.Instance)
	local now = os.clock()

	if now - v3 < 0.1 then
		return
	end

	v3 = now

	for _, v4 in Omni.Services.Players:GetPlayers() do
		if v4 ~= Omni.Instance then
			Mounts.RefreshPlayer(v4)
		end
	end
end)
return Mounts