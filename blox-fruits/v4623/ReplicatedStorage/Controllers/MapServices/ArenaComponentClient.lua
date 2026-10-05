local Component = require(game.ReplicatedStorage.Modules.Component)
require(game.ReplicatedStorage.Util.Signal2)
require(game.ReplicatedStorage.Types.SlappingArenaTypes)
require(game.ReplicatedStorage.Util.Maid)
require(game.ReplicatedStorage.Util.IsTransformed)
local IrisLog = require(game.ReplicatedStorage.Util.IrisLog)
local slappingArena = IrisLog.new("SlappingArena", nil, {
	Hidden = true
})
local v = Component.new({
	Tag = "SlappingArena"
})
task.spawn(function()
	require(script.RemoteEventInputComponent)
end)
task.spawn(function()
	require(script.ArenaFishComponent)
end)
task.spawn(function()
	require(script.ArenaPlayerHealthComponent)
end)
task.spawn(function()
	require(script.ArenaCameraDirector)
end)
local v2 = nil

local function confirmEquipRedeem(p: string)
	local PromptController = require(game.ReplicatedStorage.Controllers.UI.PromptController)
	local confirmEquipRedeem2 = PromptController.new("ConfirmEquipRedeem")
	v2 = confirmEquipRedeem2
	local v3 = confirmEquipRedeem2:AddTemplate("Default")
	local formatted = `\nYou are selecting to use your\n<font color="rgb(255, 214, 49)">&#60;{p.Name}&#62;</font>!\n`
	local description = v3:FindFirstChild("Description")
	description.Text = formatted .. [[

The opponent may steal this fish if you are knocked out of the arena!
]]
	description.RichText = true
	local v4 = assert(confirmEquipRedeem2:AddButton("Confirm", {
		TextLabel = {
			Text = "CONFIRM"
		},
		Visible = true
	}))
	local v5 = assert(confirmEquipRedeem2:AddButton("Cancel", {
		TextLabel = {
			Text = "CANCEL"
		},
		Visible = true
	}))
	local v6 = false
	local v7 = nil
	local thread = coroutine.running()
	v4.Instance.Activated:Connect(function()
		confirmEquipRedeem2:Destroy()
		v7 = "CONFIRM"

		if not v6 then
			task.spawn(thread)
		end
	end)
	v5.Instance.Activated:Connect(function()
		confirmEquipRedeem2:Destroy()
		v7 = "CANCEL"

		if not v6 then
			task.spawn(thread)
		end
	end)
	confirmEquipRedeem2:SetTitle("Fish Selection")
	confirmEquipRedeem2:Open()
	coroutine.yield()
	v6 = true
	return v7
end

function v:Start()
	self.ProximityPrompts = {}
	self.ProxDisables = 0

	local function updateProximities()
		for _, proximityPrompt in self.ProximityPrompts do
			if self.Instance:GetAttribute("Playing") or not proximityPrompt:GetAttribute("ServerEnabled") or self.ProxDisables > 0 then
				proximityPrompt.Enabled = false
			else
				proximityPrompt.Enabled = true
			end
		end
	end

	for _, proximityPrompt in self.Instance:GetDescendants() do
		if not proximityPrompt:IsA("ProximityPrompt") then
			continue
		end

		table.insert(self.ProximityPrompts, proximityPrompt)
		proximityPrompt:GetAttributeChangedSignal("ServerEnabled"):Connect(updateProximities)
	end

	local function playingChanged()
		updateProximities()
	end

	self.Instance:GetAttributeChangedSignal("Playing"):Connect(playingChanged)
	updateProximities()
	game.Players.LocalPlayer.ChildAdded:Connect(function(child)
		if child.Name == "CurrentArena" or child.Name == "SelectingArena" then
			slappingArena:Append("disable proxprompts clientside ", child)
			self.ProxDisables += 1
			updateProximities()
			local ancestryChangedConnection = nil
			ancestryChangedConnection = child.AncestryChanged:Connect(function(_, parent)
				if not parent then
					ancestryChangedConnection:Disconnect()
					slappingArena:Append("enable proxprompts clientside ", child)
					self.ProxDisables -= 1
					updateProximities()
				end
			end)
		end
	end)
	task.delay(1, function()
		updateProximities()
	end)
	slappingArena:Append("Arena added: ", self.Instance)
	local remoteFunction = self.Instance:WaitForChild("RemoteFunction", 999)

	remoteFunction.OnClientInvoke = function(p, ...)
		local success, result = pcall(function()
			local CraftWindow = require(game.ReplicatedStorage.Controllers.UI.CraftWindow)

			if p == "GetSelectedFish" then
				local v3 = CraftWindow:Open("SelectSlappingFish", {
					{
						IsChoosable = true,
						Rarity = 0,
						Type = "Fish",
						Amount = 1,
						Name = "Choosable1",
						Required = 1,
						Count = 0
					}
				}, {}, {}, "SelectSlappingFish")
				return v3 or false
			elseif p == "Close" then
				pcall(function()
					v2:Destroy()
				end)
				pcall(function()
					CraftWindow:Close()
				end)
			end
		end)

		if not success then
			warn("fish slapping craft selection error:", result)
		end

		return success and result or false
	end
end

return v