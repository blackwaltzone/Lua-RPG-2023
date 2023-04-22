--[[

	Lua 2D RPG
	How to Make an RPG

	main.lua

	Dustin Heyden
	Feb 9, 2023


]]

LoadLibrary("Asset")
LoadLibrary("Keyboard")
LoadLibrary("Renderer")
LoadLibrary("Sprite")
LoadLibrary("System")
LoadLibrary("Texture")
LoadLibrary("Vector")

Asset.Run("Actions.lua")
Asset.Run("Animation.lua")
Asset.Run("Character.lua")
Asset.Run("Entity.lua")
Asset.Run("small_room.lua")
Asset.Run("Map.lua")
Asset.Run("MoveState.lua")
Asset.Run("NPCStandState.lua")
Asset.Run("PlanStrollState.lua")
Asset.Run("StateMachine.lua")
Asset.Run("Tween.lua")
Asset.Run("Trigger.lua")
Asset.Run("Util.lua")
Asset.Run("WaitState.lua")

Asset.Run("EntityDefs.lua")


local mapDef = CreateMap()
mapDef.on_wake =
{
	{
		id = "AddNPC",
		params = {{ def = "strolling_npc", x = 11, y = 5}}
	},
	{
		id = "AddNPC",
		params = {{ def = "standing_npc", x = 4, y = 5}}
	},
}
-- separate trigger definitions from placement
-- this way wide doors can utilize same trigger
-- and not create new trigger for each tile
mapDef.actions = 
{
	tele_south = { id = "Teleport", params = {11,3} },
	tele_north = { id = "Teleport", params = {10,11} }
}
mapDef.trigger_types =
{
	north_door_trigger = { OnEnter = "tele_north" },
	south_door_trigger = { OnEnter = "tele_south" }
}
mapDef.triggers =
{
	{ trigger = "north_door_trigger", x = 11, y = 2 },
	{ trigger = "south_door_trigger", x = 10, y = 12 },
}

local Map = Map:Create(mapDef)
Renderer = Renderer:Create()
Map:GoToTile(5, 5)
Hero = Character:Create(Characters.hero, Map)
Hero.Entity:SetTilePos(11, 3, 1, Map)


-- get the coordinates of the tile the player is facing
function GetFacingTileCoords(character)

	-- change the facing information into a tile offset
	local xInc = 0
	local yInc = 0

	if character.Facing == "left" then
		xInc = -1
	elseif character.Facing == "right" then
		xInc = 1
	elseif character.Facing == "up" then
		yInc = -1
	elseif character.Facing == "down" then
		yInc = 1
	end

	local x = character.Entity.TileX + xInc
	local y = character.Entity.TileY + yInc

	return x, y
end


function update()

	local dt = GetDeltaTime()

	-- camera tracking
	local playerPos = Hero.Entity.Sprite:GetPosition()
	Map.CamX = math.floor(playerPos:X())
	Map.CamY = math.floor(playerPos:Y())

	-- Translate map according to key press
	Renderer:Translate(-Map.CamX, -Map.CamY)

	-- get number of layers in the map
	local layerCount = Map:LayerCount()

	-- draw map with all layers and player
	for i = 1, layerCount do

		local heroEntity = nil
		if i == Hero.Entity.Layer then
			heroEntity = Hero.Entity
		end

		-- draw map layer
		Map:RenderLayer(Renderer, i, heroEntity)
	end

	-- Handle keyboard input for camera movement
	Hero.Controller:Update(dt)

	-- update NPCs
	for k, v in ipairs(Map.NPCs) do
		v.Controller:Update(dt)
	end

	-- check if spacebar is pressed, handle triggers
	if Keyboard.JustPressed(KEY_SPACE) then

		-- which way is the player facing?
		local x, y = GetFacingTileCoords(Hero)
		local trigger = Map:GetTrigger(Hero.Entity.Layer, x, y)

		if trigger then
			trigger:OnUse(Hero)
		end
	end

end
