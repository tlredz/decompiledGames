local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local shared = script:WaitForChild("Shared")
local Util = require(shared:WaitForChild("Util"))

if RunService:IsClient() == false then
	error("Server scripts cannot require the client library. Please require the server library to use Cmdr in your own code.")
end

local v = {
	ReplicatedRoot = script,
	RemoteFunction = script:WaitForChild("CmdrFunction"),
	RemoteEvent = script:WaitForChild("CmdrEvent"),
	ActivationKeys = {
		[Enum.KeyCode.F2] = true
	},
	Enabled = true,
	MashToEnable = false,
	ActivationUnlocksMouse = false,
	HideOnLostFocus = true,
	PlaceName = "Cmdr",
	Util = Util,
	Events = {}
}
local object = setmetatable(v, {
	__index = function(p, p2)
		local v3 = p.Dispatcher[p2]

		if v3 and type(v3) == "function" then
			return function(_, ...)
				return v3(p.Dispatcher, ...)
			end
		end
	end
})
local Registry = require(shared.Registry)
object.Registry = Registry(object)
local Dispatcher = require(shared.Dispatcher)
object.Dispatcher = Dispatcher(object)

if StarterGui:WaitForChild("Cmdr") and wait() and localPlayer:WaitForChild("PlayerGui"):FindFirstChild("Cmdr") == nil then
	local clone = StarterGui.Cmdr:Clone()
	clone.Parent = localPlayer.PlayerGui
end

local CmdrInterface = require(script.CmdrInterface)
local cmdrInterface = CmdrInterface(object)

function object:SetActivationKeys(p2)
	self.ActivationKeys = Util.MakeDictionary(p2)
end

function object:SetPlaceName(placeName)
	self.PlaceName = placeName
	cmdrInterface.Window:UpdateLabel()
end

function object:SetEnabled(enabled)
	self.Enabled = enabled
end

function object:SetActivationUnlocksMouse(activationUnlocksMouse)
	self.ActivationUnlocksMouse = activationUnlocksMouse
end

function object:Show()
	if not self.Enabled then
		return
	end

	cmdrInterface.Window:Show()
end

function object:Hide()
	cmdrInterface.Window:Hide()
end

function object:Toggle()
	if not self.Enabled then
		return self:Hide()
	end

	cmdrInterface.Window:SetVisible(not cmdrInterface.Window:IsVisible())
end

function object:SetMashToEnable(mashToEnable)
	self.MashToEnable = mashToEnable

	if mashToEnable then
		self:SetEnabled(false)
	end
end

function object:SetHideOnLostFocus(hideOnLostFocus)
	self.HideOnLostFocus = hideOnLostFocus
end

function object.HandleEvent(p, p2, p3)
	p.Events[p2] = p3
end

if RunService:IsServer() == false then
	object.Registry:RegisterTypesIn(script:WaitForChild("Types"))
	object.Registry:RegisterCommandsIn(script:WaitForChild("Commands"))
end

object.RemoteEvent.OnClientEvent:Connect(function(p, ...)
	if object.Events[p] then
		object.Events[p](...)
	end
end)
local DefaultEventHandlers = require(script.DefaultEventHandlers)
DefaultEventHandlers(object)
return object