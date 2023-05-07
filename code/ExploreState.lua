--[[

	ExploreState.lua

	Code related to exploring the map
	Displays a map and lets us wander around it
	Requires:
		Enter
		Exit
		Render
		Update
		HandleInput

	For use with a state stack to restrict input


	Dustin Heyden

	03 May, 2023

]]

ExploreState = {}
ExploreState.__index = ExploreState

function ExploreState:Create(stack, mapDef, startPos)

	local this =
	{
		Stack = stack,
		MapDef = mapDef,
	}

	this.Map = Map:Create(this.MapDef)
	this.Hero = Character:Create(Characters.hero, this.Map)
	this.Hero.Entity:SetTilePos(
		startPos:X(),
		startPos:Y(),
		startPos:Z(),
		this.Map)
	this.Map:GoToTile(startPos:X(), startPos:Y())

	setmetatable(this, self)

	return this
end


function ExploreState:Enter() end

function ExploreState:Exit() end


-- update
function ExploreState:Update(dt)

	local hero = self.Hero
	local map = self.Map

	-- update the camera according to player position
	local playerPos = hero.Entity.Sprite:GetPosition()
	map.CamX = math.floor(playerPos:X())
	map.CamY = math.floor(playerPos:Y())

	-- handle keyboard input for camera movement
	hero.Controller:Update(dt)

	-- update NPCs
	for k, v in ipairs(map.NPCs) do
		v.Controller:Update(dt)
	end
end


-- render
function ExploreState:Render(renderer)

	local hero = self.Hero
	local map = self.Map

	-- translate map according to key press
	renderer:Translate(-map.CamX, -map.CamY)

	-- get the number of layers in the map
	local layerCount = map:LayerCount()

	-- draw map with all layers and player
	for i = 1, layerCount do

		local heroEntity = nil
		if i == hero.Entity.Layer then
			heroEntity = hero.Entity
		end

		-- draw map layer
		map:RenderLayer(renderer, i, heroEntity)
	end

	-- reset renderer's translation to zero
	-- stops the map's offset affecting UI's position
	renderer:Translate(0, 0)
end


-- handle input
function ExploreState:HandleInput()

	-- check if spacebar pressed, handle triggers
	if Keyboard.JustPressed(KEY_SPACE) then
		-- which way is the player facing
		local x, y = self.Hero:GetFacingTileCoods()
		local layer = self.Hero.Entity.Layer
		local trigger = self.Map:GetTrigger(layer, x, y)

		if trigger then
			trigger:OnUse(self.Hero)
		end
	end

	-- open menu
	if Keyboard.JustPressed(KEY_LALT) then
		local menu = InGameMenuState:Create(self.Stack)
		return self.Stack:Push(menu)
	end
end