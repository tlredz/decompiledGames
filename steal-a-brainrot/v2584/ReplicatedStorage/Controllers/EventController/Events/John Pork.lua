local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
game:GetService("Lighting")
game:GetService("Debris")
require(ReplicatedStorage.Shared.EventTypes)
local JohnPork = {}
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
local JumpLTMWeather = require(ReplicatedStorage.Controllers.EventController.JumpLTMWeather)
require(ReplicatedStorage.Controllers.TsunamiEventController)
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
require(ReplicatedStorage.Controllers.AnimalController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
require(ReplicatedStorage.Packages.CreateTween)
local Observers = require(ReplicatedStorage.Packages.Observers)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
require(ReplicatedStorage.Packages.Timer)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
require(ReplicatedStorage.Shared.VFX)
local name = script.Name
local remoteEvent = Net:RemoteEvent("EventService/John Pork/Burst")
local maid = Trove.new()

function JohnPork.OnStart(_)
	assert((EventController:GetActiveEventData(name)))
	ReplicatedStorage:SetAttribute("JohnPorkEvent", true)
	maid:Add(function()
		ReplicatedStorage:SetAttribute("JohnPorkEvent", nil)
	end)
	EffectController:Activate("Blink")
	maid:Add(function()
		EffectController:Activate("Blink")
	end)

	if ServerData.IsJumpLTMServer() then
		local model = Instance.new("Model")
		model.Name = "JohnPorkSky"
		local clone_2 = script.JohnPorkMap.strawberrybeamsbg:Clone()
		clone_2.Parent = model
		local clone_3 = script.JohnPorkMap.strawberrybg:Clone()
		clone_3.Parent = model
		maid:Add(JumpLTMWeather.Cover(model))
		model:Destroy()
	else
		local clone = maid:Clone(script.JohnPorkMap)
		clone.Parent = workspace
		local johnPorkPhone = ReplicatedStorage:GetAttribute("1YearEvent") and clone:FindFirstChild("JohnPorkPhone")

		if johnPorkPhone then
			johnPorkPhone:PivotTo(johnPorkPhone:GetPivot() + createVector(0, 0, -25))
		end

		maid:Add(task.spawn(function()
			local PhoneFrontEnd = require(clone.JohnPorkPhone.PhoneFrontEnd)
			maid:Add(task.spawn(function()
				PhoneFrontEnd.Start()
			end))
			maid:Add(task.delay(3, function()
				while true do
					PhoneFrontEnd.Ring()
					task.wait(3)
				end
			end))
			maid:Add(function()
				PhoneFrontEnd.Stop()
			end)
		end))
	end

	SoundController:UpdateOST()
	SoundController:UpdateAmbience()
	maid:Add(function()
		SoundController:UpdateOST()
		SoundController:UpdateAmbience()
	end)
	maid:Add(Observers.observeTag("HideInJohnPork", function(p)
		local parent = p.Parent
		p.Parent = script
		return function()
			pcall(function()
				p.Parent = parent
			end)
		end
	end, { workspace, script }))
end

function JohnPork.OnStop(_)
	maid:Destroy()
end

function JohnPork.OnLoad(_)
	remoteEvent.OnClientEvent:Connect(function(p)
		ClientEventUtils.playBurst(script.Burst, p, { ReplicatedStorage.Sounds.Events["John Pork"].BrainrotHit })
	end)
end

return JohnPork