--[[

	Trigger.lua

	Calls an action when an event happens
		- interact with levers
		- read signs
		- talk to people
		- interact with the world


	Dustin Heyden

	03 Mar 2023

]]


Trigger = {}
Trigger.__index = Trigger

function Trigger:Create(def)
	local EmptyFunc = function() end

	local this =
	{
		OnEnter = def.OnEnter or EmptyFunc,
		OnExit = def.OnExit or EmptyFunc,
		OnUse = def.OnUse or EmptyFunc,
	}

	setmetatable(this,self)
	return this
end