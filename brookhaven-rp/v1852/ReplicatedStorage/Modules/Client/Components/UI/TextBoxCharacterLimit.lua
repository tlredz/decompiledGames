local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "TextBoxCharacterLimit"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local instance = self.Instance

	-- equivalent calls inferred from this helper; original call sites unknown
	local function enforce()
		local characterLimit = instance:GetAttribute("CharacterLimit")

		if not characterLimit then
			return
		end

		local text = instance.Text

		if characterLimit < #text then
			instance.Text = string.sub(text, 1, characterLimit)
		end
	end

	enforce() -- equivalent call inferred; original call site unknown
	self._Janitor:Add(instance:GetPropertyChangedSignal("Text"):Connect(enforce))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v