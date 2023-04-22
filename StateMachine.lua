--[[

	state_machine.lua

	State Machine

	Dustin Heyden
	16 Feb 2023


	efficiently create states to reduce memory
	Init function should return a table with:
		- Render
		- Update
		- Enter
		- Exit

	
	StateMachine = StateMachine:Create
	{
		['MainMenu'] = function()
			return MainMenu:Create()
		end,
		['InnerGame'] = function()
			return InnerGame:Create()
		end,
		['GameOver'] = function()
			return GameOver:Create()
		end,
	}
	StateMachine:Change("MainGame")

	
	Arguments passed into the Change() function after the state name
	will be forwarded to the Enter() function of the state being
	changed to.

	State ID should have same name as state table

]]

StateMachine = {}
StateMachine.__index = StateMachine

function StateMachine:Create(states)
	local this =
	{
		empty =
		{
			Render = function() end,
			Update = function() end,
			Enter  = function() end,
			Exit   = function() end,
		},
		states = states or {},	-- [name] -> function that returns state
		current = nil,
	}

	this.current = this.empty

	setmetatable(this, self)

	return this
end


function StateMachine:Change(stateName, enterParams)
	assert(self.states[stateName])	-- state must exist!
	self.current:Exit()
	self.current = self.states[stateName]()
	self.current:Enter(enterParams)
end


function StateMachine:Update(dt)
	self.current:Update(dt)
end


function StateMachine:Render(renderer)
	self.current:Render(renderer)
end