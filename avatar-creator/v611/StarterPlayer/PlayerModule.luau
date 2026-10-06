local RunService = game:GetService("RunService")
local CommonUtils = require(script:WaitForChild("CommonUtils"))
local characterUtil = CommonUtils.get("CharacterUtil")
local connectionUtil = CommonUtils.get("ConnectionUtil")
local eventBus = CommonUtils.get("EventBus")
local CameraModule = require(script:WaitForChild("CameraModule"))
local ControlModule = require(script:WaitForChild("ControlModule"))
local ServerAuthority = require(script:WaitForChild("ServerAuthority"))
local _ = {
	BIND_TO_SIMULATION = "BIND_TO_SIMULATION",
	RENDERSTEPPED_INPUT = "PLAYERMODULE_RENDERSTEPPED_INPUT",
	RENDERSTEPPED_CAMERA = "PLAYERMODULE_RENDERSTEPPED_CAMERA",
	ONLOCALPLAYER = "ONLOCALPLAYER"
}
local class = {}
class.__index = class

function class.new()
	return (setmetatable({
		data = {
			playerData = {},
			connectionUtil = connectionUtil.new(),
			eventBus = eventBus.new(),
			isServerAuthority = false
		}
	}, class))
end

function class:start()
	self.data.connectionUtil:trackConnection("ONLOCALPLAYER", characterUtil.onLocalPlayer(function(player)
		self.data.playerData[player] = {
			isJumping = false,
			moveVector = Vector2.new(),
			actions = {},
			player = player,
			character = nil
		}
		ServerAuthority.initialize(self.data)
		ControlModule:initialize(self.data, self.data.playerData[player])
		RunService:BindToRenderStep("PLAYERMODULE_RENDERSTEPPED_INPUT", Enum.RenderPriority.Input.Value, function(p3)
			for _, v in pairs(self.data.playerData) do
				v.character = characterUtil.getCharacter()

				if not v.character then
					break
				end

				ControlModule:Update(self.data, v, p3)
			end
		end)
		self.data.connectionUtil:trackBoundFunction("PLAYERMODULE_RENDERSTEPPED_INPUT", function()
			RunService:UnbindFromRenderStep("PLAYERMODULE_RENDERSTEPPED_INPUT")
		end)
		RunService:BindToRenderStep("PLAYERMODULE_RENDERSTEPPED_CAMERA", Enum.RenderPriority.Camera.Value, function(p3)
			for _, v in pairs(self.data.playerData) do
				CameraModule:Update(v, p3)
			end
		end)
		self.data.connectionUtil:trackBoundFunction("PLAYERMODULE_RENDERSTEPPED_CAMERA", function()
			RunService:UnbindFromRenderStep("PLAYERMODULE_RENDERSTEPPED_CAMERA")
		end)
	end))
end

function class.stop(p)
	p.data.connectionUtil:disconnectAll()
end

class.new():start()
return {}