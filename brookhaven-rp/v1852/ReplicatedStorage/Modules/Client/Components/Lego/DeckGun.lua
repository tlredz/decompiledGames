local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MobileUIControlController = require(ReplicatedStorage.Modules.Client.Input.MobileUIControlController)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local DeckGunUI = require(ReplicatedStorage.Modules.Client.Components.UI.Lego.DeckGunUI)
local v = Component.new({
	Tag = "DeckGun"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._activeJanitor = self._Janitor:Add(Janitor.new())
	self._active = false
end

function v:Start()
	local controlSeat = self.Instance:WaitForChild("ControlArm"):WaitForChild("ControlSeat")
	self._Janitor:Add(controlSeat.ChildAdded:Connect(function(weld)
		if weld:IsA("Weld") and weld.Name == "SeatWeld" then
			if not weld.Part1:IsDescendantOf(Players.LocalPlayer.Character) then
				return
			end

			self:StartUsing()
		end
	end))
	self._Janitor:Add(controlSeat.ChildRemoved:Connect(function(weld)
		if weld:IsA("Weld") and weld.Name == "SeatWeld" then
			self:StopUsing()
		end
	end))
end

function v:StartUsing()
	if self._active then
		return
	end

	self._active = true
	local v2 = self._activeJanitor:Add(MobileUIControlController.NewContext("DeckGun"))
	self._activeJanitor:Add(v2.MoveVectorUpdated:Connect(function(p)
		Remotes.fireServerComponent(self.Instance, "MoveVectorUpdated", p)
	end))
	self._activeJanitor:Add(v2.OnJumpStarted:Connect(function()
		local character = Players.LocalPlayer.Character

		if not character then
			return
		end

		local humanoid = character:FindFirstChild("Humanoid", true)

		if not humanoid then
			return
		end

		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end))
	PanelController.OpenPanelByContext("DeckGun", "DeckGunUI")
	local v3 = PanelController.WaitForPanel("DeckGun", "DeckGunUI")

	if not v3 then
		return
	end

	local expect = DeckGunUI:WaitForInstance(v3.Instance):expect()
	self._activeJanitor:Add(expect.Activated:Connect(function(p)
		expect:SetWaterType((Remotes.invokeServerComponent(self.Instance, "ChangeWaterType", p)))
	end))
	expect:SetWaterType((Remotes.invokeServerComponent(self.Instance, "GetWaterType")))
end

function v:StopUsing()
	if not self._active then
		return
	end

	self._active = false
	self._activeJanitor:Cleanup()
	Remotes.fireServerComponent(self.Instance, "MoveVectorUpdated", createVector(0, 0, 0))
	PanelController.Close("DeckGun", "DeckGunUI")
end

function v:Stop()
	if self._active then
		PanelController.Close("DeckGun", "DeckGunUI")
	end

	self._Janitor:Destroy()
end

return v