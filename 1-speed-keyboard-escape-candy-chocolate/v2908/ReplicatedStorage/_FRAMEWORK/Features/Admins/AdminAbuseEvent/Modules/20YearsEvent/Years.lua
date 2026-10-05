require(script.Parent.Types)
local v = {}
local Year2006 = require(script.Year2006)
v[2006] = Year2006
local Year2007 = require(script.Year2007)
v[2007] = Year2007
local Year2008 = require(script.Year2008)
v[2008] = Year2008
local Year2009 = require(script.Year2009)
v[2009] = Year2009
local Year2010 = require(script.Year2010)
v[2010] = Year2010
local Year2011 = require(script.Year2011)
v[2011] = Year2011
local Year2012 = require(script.Year2012)
v[2012] = Year2012
local Year2013 = require(script.Year2013)
v[2013] = Year2013
local Year2014 = require(script.Year2014)
v[2014] = Year2014
local Year2015 = require(script.Year2015)
v[2015] = Year2015
local Year2016 = require(script.Year2016)
v[2016] = Year2016
local Year2017 = require(script.Year2017)
v[2017] = Year2017
local Year2018 = require(script.Year2018)
v[2018] = Year2018
local Year2019 = require(script.Year2019)
v[2019] = Year2019
local Year2020 = require(script.Year2020)
v[2020] = Year2020
local Year2021 = require(script.Year2021)
v[2021] = Year2021
local Year2022 = require(script.Year2022)
v[2022] = Year2022
local Year2023 = require(script.Year2023)
v[2023] = Year2023
local Year2024 = require(script.Year2024)
v[2024] = Year2024
local Year2025 = require(script.Year2025)
v[2025] = Year2025
local Year2026 = require(script.Year2026)
v[2026] = Year2026
return {
	getYearModule = function(p: number)
		return v[p]
	end
}