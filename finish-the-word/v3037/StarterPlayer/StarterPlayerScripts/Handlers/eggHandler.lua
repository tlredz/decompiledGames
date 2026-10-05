local import = _G.import("romodel")
local import2 = _G.import("event")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local import3 = _G.import("eggCollection")
local import4 = _G.import("viewImports")
local eggBillboard = import4:get("eggBillboard")
local eggOpeningOverlay = import4:get("eggOpeningOverlay").EggOpeningOverlay
local itemBillboard = import4:get("itemBillboard").ItemBillboard
local localPlayer = game.Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local v = {
	{
		Count = 1,
		Key = Enum.KeyCode.E
	},
	{
		Count = 10,
		Key = Enum.KeyCode.R
	}
}
local v2 = {}
local count = 0

local function initEgg(child)
	local name = child.Name
	local eggData = import3:get(name)

	if not eggData then
		return
	end

	local root = child:FindFirstChild("Root")

	if not root then
		return
	end

	local v4 = nil
	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt.Parent = root
	proximityPrompt.HoldDuration = 0
	proximityPrompt.RequiresLineOfSight = false
	proximityPrompt.MaxActivationDistance = 5
	proximityPrompt.Style = Enum.ProximityPromptStyle.Custom
	proximityPrompt.KeyboardKeyCode = Enum.KeyCode.X
	local v5 = nil
	proximityPrompt.PromptShown:Connect(function()
		v4.Enabled = false
		v5 = import.make(eggBillboard.EggViewer, {
			EggId = name,
			EggData = eggData,
			Adornee = root
		})
		import.mount(v5, playerGui)
	end)
	proximityPrompt.PromptHidden:Connect(function()
		v4.Enabled = true

		if not v5 then
			return
		end

		v5:Destroy()
		v5 = nil
	end)
	local child2 = game.ReplicatedStorage.ReplicatedAssets.Eggs:FindFirstChild(name)

	if child2 then
		local clone = child2:Clone()
		clone.Parent = root
		local boundingBox, v6 = clone:GetBoundingBox()
		local vector = Vector3.new(0, clone:GetPivot().Position.Y - (boundingBox.Position.Y - v6.Y / 2), 0)
		clone:PivotTo(CFrame.new(root.Position + vector))
		count += 1
		v2[clone] = {
			Root = root,
			BaseOffset = vector,
			Phase = count * 0.7
		}
		v4 = import.mount(import.make(itemBillboard, {
			Pet = eggData.Pet,
			Robux = eggData.Robux,
			Currency = { eggData.Currency, eggData.Cost },
			Cost = eggData.Cost,
			Height = 5.5,
			Item = eggData,
			Prompt = proximityPrompt,
			Adornee = clone
		}), playerGui)
		UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then
				return
			end

			for _, v7 in ipairs(v) do
				if input.KeyCode ~= v7.Key then
					continue
				end

				local humanoidRootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")

				if (clone.PrimaryPart.Position - humanoidRootPart.Position).Magnitude > proximityPrompt.MaxActivationDistance then
					continue
				end

				if not v5 then
					break
				end

				local container = v5.Container

				if not container then
					break
				end

				local buttons = container.Content.Main.Buttons

				if not buttons then
					break
				end

				if buttons.OnOpen then
					buttons.OnOpen(v7.Count)
				end
			end
		end)
	else
		warn("No asset found for egg", name)
	end
end

return {
	Priority = 1,
	Run = function()
		import2.connect("dataLoaded", function()
			for _, child in pairs(workspace.Meta.Eggs:GetChildren()) do
				initEgg(child)
			end
		end)
		RunService.RenderStepped:Connect(function()
			local now = os.clock()

			for k, v3 in pairs(v2) do
				if k.Parent and v3.Root.Parent then
					local v4 = math.sin(now * 2 + v3.Phase) * 0.35
					local v5 = now * 0.6108652381980153 + v3.Phase
					local v6 = math.sin(now * 1.6 + v3.Phase) * 0.17453292519943295
					local v7 = v3.Root.Position + v3.BaseOffset + Vector3.new(0, v4, 0)
					k:PivotTo(CFrame.new(v7) * CFrame.Angles(0, v5, v6))
				else
					v2[k] = nil
				end
			end
		end)
		import2.remoteConnect("eggRewarded", function(eggId, p2)
			import.mount(import.make(eggOpeningOverlay, {
				EggId = eggId
			}), playerGui).Container:setRewards(p2)
		end)
	end
}