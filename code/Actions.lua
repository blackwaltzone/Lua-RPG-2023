--[[

	Actions.lua

	Stores all actions
	

	Dustin Heyden
	03 Mar 2023

]]


Actions =
{

	-- # param 1 = trigger that gave rise to action
	-- # param 2 = entity action is applied to

	-- Teleport an entity from the current positionj to the given position
	Teleport = function(map, tileX, tileY, layer)
		layer = layer or 1
		return function(trigger, entity)
			entity:SetTilePos(tileX, tileY, layer, map)
		end
	end,


	-- places an NPC on the map
	AddNPC = function(map, npc)
		return function(trigger, entity)

			local charDef = Characters[npc.def]
			assert(charDef)	-- character should always exist
			local char = Character:Create(charDef, map)

			-- use npc def location by default
			-- drop back to entities locations if missing
			local x = npc.x or char.Entity.TileX
			local y = npc.y or char.Entity.TileY
			local layer = npc.layer or char.Entity.Layer

			char.Entity:SetTilePos(x, y, layer, map)

			table.insert(map.NPCs, char)
		end
	end
}