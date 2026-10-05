local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)
local BackActionRouter = require(ReplicatedStorage.Modules.Client.UI.BackActionRouter)
local AdIntegrationsController = require(ReplicatedStorage.Modules.Client.Ads.AdIntegrationsController)
local OnlyRunOnPlayerHotbar = require(ReplicatedStorage.Modules.Shared.Components.Tools.Extensions.OnlyRunOnPlayerHotbar)
local v = Enum.ContextActionPriority.High.Value + 1
local v2 = Component.new({
	Tag = "ToolRoot",
	Extensions = { OnlyRunOnPlayerHotbar }
})

function v2:Construct()
	self._Janitor = Janitor.new()
	self.OnToolComponentAdded = Signal.new()
	self._Janitor:Add(self.OnToolComponentAdded)
	self.HoldDeleteProgressChanged = Signal.new()
	self._Janitor:Add(self.HoldDeleteProgressChanged)
	self._holdDeleteProgress = 0
	self._TrackedComponents = {}
end

function v2:_SetHoldDeleteProgress(value: number)
	if typeof(value) ~= "number" then
		return
	end

	local holdDeleteProgress = math.clamp(value, 0, 1)

	if holdDeleteProgress == self._holdDeleteProgress then
		return
	end

	self._holdDeleteProgress = holdDeleteProgress
	self.HoldDeleteProgressChanged:Fire(holdDeleteProgress)
end

function v2:GetHoldDeleteProgress()
	return self._holdDeleteProgress
end

function v2.GetToolInstance(p)
	return p.Instance
end

function v2:AddTrackedComponent(p2: string, p3)
	self._TrackedComponents[p2] = self._TrackedComponents[p2] or {}
	self._TrackedComponents[p2][p3.Instance] = p3
	self.OnToolComponentAdded:Fire(p2, p3)
end

function v2:GetToolComponents(p2: string)
	return self._TrackedComponents[p2] or {}
end

function v2:WaitForToolComponent(p2: string)
	while not self._TrackedComponents[p2] do
		task.wait()
	end

	local v3 = next(self._TrackedComponents[p2])
	return self._TrackedComponents[p2][v3]
end

function v2.DeleteTool(p)
	Remotes.fireServerComponent(p.Instance, "QuickDelete")
end

function v2:Start()
	local instance = self.Instance
	local v3, v4 = ABTest.GetExperimentVariable("console-controls", "enabled"):timeout(7):await()
	local v5 = not v3 or typeof(v4) ~= "boolean" or v4
	local v6, v7 = ABTest.GetExperimentVariable("console-controls", "dpadNavigation"):timeout(7):await()

	if not v6 or typeof(v7) ~= "boolean" then
		v7 = false
	end

	local v8 = v5 and not v7
	local holdDeleteSeconds = instance:GetAttribute("HoldDeleteSeconds")
	local v9 = (typeof(holdDeleteSeconds) ~= "number" or not (holdDeleteSeconds > 0)) and 0.5 or holdDeleteSeconds
	local v10 = false
	local v11 = nil
	local v12 = 0
	local renderSteppedConnection = nil
	local v13 = nil
	local v14 = false
	local toolAdIntegrationName = AdIntegrationsController.GetToolAdIntegrationName(instance.Name)

	if toolAdIntegrationName then
		self.Instance:SetAttribute("AdIntegrationName", toolAdIntegrationName)
		self.Instance:AddTag("AdIntegrationTool")
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function CancelHold()
		v12 += 1

		if renderSteppedConnection ~= nil then
			renderSteppedConnection:Disconnect()
			renderSteppedConnection = nil
		end

		self:_SetHoldDeleteProgress(0)
	end

	self._Janitor:Add(CancelHold)

	local function SendDelete(p, p2, _)
		if not (p == "QuickDeleteThroughC" and p2 == Enum.UserInputState.Begin) then
			return
		end

		Remotes.fireServerComponent(instance, "QuickDelete")
	end

	local function HoldDelete(p, p2, _)
		if p ~= "HoldDeleteThroughB" then
			return Enum.ContextActionResult.Pass
		end

		if p2 == Enum.UserInputState.Begin then
			CancelHold() -- equivalent call inferred; original call site unknown
			local v15 = v12 + 1
			v12 = v15
			local lastTime = os.clock()
			v13 = lastTime
			v14 = false
			self:_SetHoldDeleteProgress(0)
			renderSteppedConnection = RunService.RenderStepped:Connect(function()
				if v12 ~= v15 then
					return
				end

				local v16 = math.clamp((os.clock() - lastTime) / v9, 0, 1)
				self:_SetHoldDeleteProgress(v16)

				if v16 >= 1 then
					Remotes.fireServerComponent(instance, "QuickDelete")
					v14 = true
					CancelHold() -- equivalent call inferred; original call site unknown
				end
			end)
			return Enum.ContextActionResult.Sink
		else
			if p2 ~= Enum.UserInputState.End and p2 ~= Enum.UserInputState.Cancel then
				return Enum.ContextActionResult.Pass
			end

			local v15 = v13 == nil and 1e999 or os.clock() - v13
			local v16

			if v14 == false and v13 ~= nil then
				v16 = v15 < 0.2
			else
				v16 = false
			end

			CancelHold() -- equivalent call inferred; original call site unknown
			v13 = nil

			if v16 then
				BackActionRouter.RunTopHandler()
			end

			v14 = false
			return Enum.ContextActionResult.Sink
		end
	end

	local function UnequipTool(p, p2, _)
		if not (p == "QuickUnequipThroughL2" and p2 == Enum.UserInputState.Begin) then
			return
		end

		local character = Players.LocalPlayer.Character

		if character == nil then
			return
		end

		local humanoid = character:FindFirstChildOfClass("Humanoid")

		if humanoid == nil then
			return
		end

		humanoid:UnequipTools()
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function UnbindActions()
		ContextActionService:UnbindAction("QuickDeleteThroughC")
		ContextActionService:UnbindAction("HoldDeleteThroughB")
		ContextActionService:UnbindAction("QuickUnequipThroughL2")
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function MarkUnequipped()
		if v10 == false then
			return
		end

		v10 = false
		v11 = nil
		CancelHold() -- equivalent call inferred; original call site unknown
		UnbindActions() -- equivalent call inferred; original call site unknown
	end

	local function ApplyBindings()
		UnbindActions() -- equivalent call inferred; original call site unknown

		if v8 then
			ContextActionService:BindAction("QuickDeleteThroughC", SendDelete, false, Enum.KeyCode.C)
			ContextActionService:BindActionAtPriority("HoldDeleteThroughB", HoldDelete, false, v, Enum.KeyCode.ButtonB)
		else
			if not v5 then
				ContextActionService:BindAction("QuickDeleteThroughC", SendDelete, false, Enum.KeyCode.C)
				return
			end

			ContextActionService:BindAction(
				"QuickDeleteThroughC",
				SendDelete,
				false,
				Enum.KeyCode.C,
				Enum.KeyCode.ButtonB
			)
		end

		ContextActionService:BindAction("QuickUnequipThroughL2", UnequipTool, false, Enum.KeyCode.ButtonL2)
	end

	local function EquipTool()
		local parent = instance.Parent
		local playerFromCharacter = Players:GetPlayerFromCharacter(parent)

		if playerFromCharacter == nil or playerFromCharacter ~= Players.LocalPlayer or v10 == true and v11 == parent then
			return
		end

		v10 = true
		v11 = parent
		ApplyBindings()
	end

	self._Janitor:Add(instance.Equipped:Connect(EquipTool))

	if instance.Parent ~= nil and Players:GetPlayerFromCharacter(instance.Parent) ~= nil then
		local parent = instance.Parent
		local playerFromCharacter = Players:GetPlayerFromCharacter(parent)

		if playerFromCharacter ~= nil and playerFromCharacter == Players.LocalPlayer and (v10 ~= true or v11 ~= parent) then
			v10 = true
			v11 = parent
			ApplyBindings()
		end
	end

	self._Janitor:Add(instance.Unequipped:Connect(MarkUnequipped))
	self._Janitor:Add(instance.AncestryChanged:Connect(function(_, parent)
		if parent == nil then
			MarkUnequipped() -- equivalent call inferred; original call site unknown
		end
	end))
	self._Janitor:Add(MarkUnequipped)
end

function v2:Stop()
	self._Janitor:Destroy()
end

return v2