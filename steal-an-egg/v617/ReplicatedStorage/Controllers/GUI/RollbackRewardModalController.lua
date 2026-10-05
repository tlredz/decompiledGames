local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GUI = require(ReplicatedStorage.Client.GUI)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
return {
	Start = function()
		local rollbackReward = GUI.RollbackReward()
		local main = rollbackReward.Main
		local close = main.Close
		local contents = main.Contents
		local ok = contents.Ok
		local title = contents.Title
		local description = contents.Description
		local imageHolder = contents.ImageHolder
		local imageLabel = imageHolder.ImageLabel

		-- equivalent calls inferred from this helper; original call sites unknown
		local function hideModal()
			rollbackReward.Enabled = false
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function showNotice(value: string?, value2: string?, value3: string?, instance)
			title.Text = value or ""
			description.Text = value2 or ""
			imageLabel.Image = value3 or ""
			local uIGradient = imageHolder:FindFirstChildOfClass("UIGradient")

			if uIGradient then
				uIGradient:Destroy()
			end

			if instance then
				local clone = instance:Clone()
				clone.Parent = imageHolder
			end

			rollbackReward.Enabled = true
		end

		hideModal() -- equivalent call inferred; original call site unknown
		GUI.OnActivated(close, function()
			hideModal() -- equivalent call inferred; original call site unknown
		end)
		GUI.OnActivated(ok, function()
			hideModal() -- equivalent call inferred; original call site unknown
		end)
		Remotes.RollbackRewards.ShowNotice.OnClientEvent:Connect(function(value: string?, value2: string?, value3: string?, uIGradient)
			local v = nil

			if typeof(uIGradient) == "Instance" and uIGradient:IsA("UIGradient") then
				v = uIGradient
			end

			showNotice(value, value2, value3, v) -- equivalent call inferred; original call site unknown
		end)
	end
}