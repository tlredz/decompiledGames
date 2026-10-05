local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local version = workspace:GetAttribute("Version")
local Server = require(ReplicatedStorage.Modules.Server)
local _ = Players.LocalPlayer

if RunService:IsStudio() then
	version = `Studio {version}`
elseif Server:IsTestServer() then
	version = `Test {version}`
elseif Server:IsAdultServer() then
	version = `18+ {version}`
end

local formatted = ([[

  _  _     _      _    _                
 | \| |___(_)__ _| |_ | |__  ___ _ _ ___
 | .` / -_) / _` | ' \| '_ \/ _ \ '_(_-<
 |_|\_\___|_\__, |_||_|_.__/\___/_| /__/
            |___/                              
 
%s
]]):format((`Version {version}`))
warn(formatted)