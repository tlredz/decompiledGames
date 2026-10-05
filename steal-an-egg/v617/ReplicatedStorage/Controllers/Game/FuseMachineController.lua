local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Assets = require(ReplicatedStorage.Data.Assets)
local directory = Assets.Directory
local Audio = require(ReplicatedStorage.Shared.Audio)
require(ReplicatedStorage.Shared.Globals.Constants)
local FuseMachineMotion = require(ReplicatedStorage.Client.FuseMachineMotion)
local FuseMachineSignals = require(ReplicatedStorage.Client.FuseMachineSignals)
local FuseMachine = require(ReplicatedStorage.Shared.Types.FuseMachine)
local Log = require(ReplicatedStorage.Packages.Log)
local Message = require(ReplicatedStorage.Client.Message)
local Toast = require(ReplicatedStorage.Client.Notifications.Toast)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Tabs = require(ReplicatedStorage.Client.Tabs)
local v = Log.new()
return {
	Start = function()
		local machines = Workspace:WaitForChild("World").Machines
		assert(machines:IsA("Folder"), "Workspace.World.Machines must be a Folder")
		local fuseMachine = machines.FuseMachine
		assert(fuseMachine:IsA("Model"), "Workspace FuseMachine must be a Model")
		local machine = fuseMachine.Machine
		assert(machine:IsA("BasePart"), "FuseMachine.Machine must be a BasePart")
		local attachment = machine.Attachment
		assert(attachment:IsA("Attachment"), "FuseMachine.Machine.Attachment must be an Attachment")
		local proximityPrompt = attachment.ProximityPrompt
		assert(proximityPrompt:IsA("ProximityPrompt"), "FuseMachine proximity prompt must be a ProximityPrompt")
		local count = 0

		-- equivalent calls inferred from this helper; original call sites unknown
		local function notifyError(text: string)
			Toast.Show({
				Text = text,
				Color = Color3.fromRGB(255, 0, 0),
				Seconds = 3
			})
		end

		local function playFuseAndGrant(p)
			local assetCategory = p.AssetCategory
			local v2 = directory[assetCategory]

			if v2 == nil then
				v:AtError():Log("Fuse result category has no asset config", {
					Category = assetCategory
				})
				return
			end

			local egg = v2.Egg
			count += 1
			local v3 = count
			proximityPrompt.Enabled = false

			if not FuseMachineMotion.Run(fuseMachine, machine, function()
				return count == v3
			end) then
				proximityPrompt.Enabled = true
				return
			end

			Audio.Play(103131639134026, script)
			Message.Notice(`You fused <font color="#{v2.Rarity.Color:ToHex()}">{egg.DisplayName}</font>`, {
				Image = egg.Icon,
				LeaveClosed = true
			})
			local v4, v5 = Remotes.Fusery.FinishReveal:InvokeServer()

			if not v4 then
				notifyError(typeof(v5) ~= "string" and "Failed to grant fused egg" or v5) -- equivalent call inferred; original call site unknown
			end

			proximityPrompt.Enabled = true
			Tabs.Deactivate({
				instant = true
			})
		end

		proximityPrompt.ActionText = "Fuse Pets"
		proximityPrompt.Triggered:Connect(function()
			Tabs.Activate("PetFuse")
		end)
		FuseMachineSignals.FuseStarted:Connect(function(p)
			assert(FuseMachine.FuseResult(p), "Fuse started signal requires a valid serialized reward egg")
			task.spawn(playFuseAndGrant, p)
		end)
	end
}