--[[

	NPCStandState

	State class for NPC standing


	Dustin Heyden

	06 April, 2023

]]

NPCStandState = { Name = "npc_stand" }
NPCStandState.__index = NPCStandState

function NPCStandState:Create(character, map)
	local this =
	{
		Character = character,
		Map = map,
		Entity = character.Entity,
		Controller = character.Controller,
	}

	setmetatable(this, self)
	return this
end

function NPCStandState:Enter() end
function NPCStandState:Exit() end
function NPCStandState:Update(dt) end
function NPCStandState:Render(renderer) end