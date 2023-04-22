--[[

	map.lua

	Map class for 2D RPG

	Dustin Heyden
	Feb 9, 2023

]]

Map = {}
Map.__index = Map

-- Create the map from a file
function Map:Create(mapDef)
    local layer = mapDef.layers[1]
    local this =
    {

        X = 0,
        Y = 0,

        MapDef = mapDef,
        TextureAtlas = Texture.Find(mapDef.tilesets[1].image),

        TileSprite = Sprite.Create(),
        Layer = layer,
        Width = layer.width,
        Height = layer.height,

        Tiles = layer.data,
        TileWidth = mapDef.tilesets[1].tilewidth,
        TileHeight = mapDef.tilesets[1].tileheight,

        Triggers = {},
        Entities = {},
        NPCs = {},

    }
    this.TileSprite:SetTexture(this.TextureAtlas)

    -- Top left corner of the map
    this.X = -System.ScreenWidth() / 2 + this.TileWidth / 2
    this.Y = System.ScreenHeight() / 2 - this.TileHeight / 2

    -- To track camera position
    this.CamX = 0
    this.CamY = 0

	-- Additional fields
    this.WidthPixel = this.Width * this.TileWidth
    this.HeightPixel = this.Height * this.TileHeight
    this.UVs = GenerateUVs(mapDef.tilesets[1].tilewidth,
                            mapDef.tilesets[1].tileheight,
                            this.TextureAtlas)

	-- Assign blocking tile ID
    for k, v in ipairs(mapDef.tilesets) do
        if v.name == "collision_graphic" then
            this.BlockingTile = v.firstgid
        end
    end

	assert(this.BlockingTile)
	--print('blocking tile is', this.BlockingTile)

	--
	-- create actions from the definition
	--
	-- mapDef.actions table has format:
	--		tele_south = { id = "Teleport", params = {11,3}}
	--
	-- tele_south = action name
	-- id 		  = action type
	-- action obj = params
	this.MapActions = {}
	for name, def in pairs(mapDef.actions or {}) do

		-- look up the action and create the action-function
		-- the action takes in the map as the first param
		assert(Actions[def.id])
		local action = Actions[def.id](this, unpack(def.params))

		-- add action to actions table
		-- tele_south = key
		this.MapActions[name] = action
	end

	--
	-- create the trigger types from the def
	--
	-- format:	(string key pointing to table of callbacks)
	-- 		north_door_trigger = { OnEnter = "tele_north" }
	this.TriggerTypes = {}
	for k, v in pairs(mapDef.trigger_types or {}) do
		local triggerParams = {}
		for callback, action in pairs(v) do
			print(callback, action)
			triggerParams[callback] = this.MapActions[action]
			assert(triggerParams[callback])
		end
		this.TriggerTypes[k] = Trigger:Create(triggerParams)
	end


	setmetatable(this, self)

	--
	-- Place any triggers on the map
	--
	this.Triggers = {}
	for k, v in ipairs(mapDef.triggers) do
		local x = v.x
		local y = v.y
		local layer = v.layer or 1

		if not this.Triggers[layer] then
			this.Triggers[layer] = {}
		end

		local targetLayer = this.Triggers[layer]
		local trigger = this.TriggerTypes[v.trigger]
		assert(trigger)
		targetLayer[this:CoordToIndex(x, y)] = trigger
	end


	-- populate Entities and NPCs tables during on_wake
	-- have to process AFTER setmetatable because action 
	-- constructor takes map as parameter and the actions
	-- expect to be able to use map's functions
	--   --> links up functions
	for k, v in ipairs(mapDef.on_wake or {}) do
        local action = Actions[v.id]
        action(this, unpack(v.params))()
    end

	return this
end


-- Take a point and return a tile position
function Map:PointToTile(x, y)

	-- Tiles are rendered from the center, so adjust
	x = x + self.TileWidth / 2
	y = y - self.TileHeight / 2

	-- Clamp the point to the bounds of the map
	x = math.max(self.X, x)
	y = math.min(self.Y, y)
	x = math.min(self.X + (self.WidthPixel) - 1, x)
	y = math.max(self.Y - (self.HeightPixel) + 1, y)

	-- Map from the bounded point to a tile
	local tileX = math.floor((x - self.X) / self.TileWidth)
	local tileY = math.floor((self.Y - y) / self.TileHeight)

	return tileX, tileY
end


-- Move the camera to specified pixel position
function Map:GoTo(x, y)
	self.CamX = x - System.ScreenWidth() / 2
	self.CamY = -y + System.ScreenHeight() / 2
end


-- Move the camera to specified tile position
function Map:GoToTile(x, y)
	self:GoTo((x * self.TileWidth) + self.TileWidth / 2,
		(y * self.TileHeight) + self.TileHeight / 2)
end


-- Return the tile from the specified coordinate
function Map:GetTile(x, y, layer)
	local layer = layer or 1
	local tiles = self.MapDef.layers[layer].data

	return tiles[self:CoordToIndex(x, y)]
end


-- return index of coordinates
function Map:CoordToIndex(x, y)
	x = x + 1	-- change from 1 -> rowsize
				-- to          0 -> rowsize -1
	--return self.Tiles[x + y * self.Width]
	return x + y * self.Width
end


-- check if a trigger at (x, y) exists and return trigger
function Map:GetTrigger(layer, x, y)
	-- Get the triggers on the same layer as the entity
	local triggers = self.Triggers[layer]

	if not triggers then
		return
	end

	local index = self:CoordToIndex(x, y)
	return triggers[index]
end


-- Check if tile is a collision tile
function Map:IsBlocked(layer, tileX, tileY)
	-- Collision layer should always be 2 above the official layer
	local tile = self:GetTile(tileX, tileY, layer + 2)
	local entity = self:GetEntity(tileX, tileY, layer)

	return tile == self.BlockingTile or entity ~= nil
end


-- Get the bottom center of a tile for character positioning
function Map:GetTileFoot(x, y)
	return self.X + (x * self.TileWidth),
		self.Y - (y * self.TileHeight) - self.TileHeight / 2
end


-- return entity from list
function Map:GetEntity(x, y, layer)
	if not self.Entities[layer] then
		return nil
	end

	local index = self:CoordToIndex(x, y)
	return self.Entities[layer][index]
end


-- add entity to map's list
function Map:AddEntity(entity)	
	-- add the layer if it doesn't exist
	if not self.Entities[entity.Layer] then
		self.Entities[entity.Layer] = {}
	end

	local layer = self.Entities[entity.Layer]
	local index = self:CoordToIndex(entity.TileX, entity.TileY)

	assert(layer[index] == enitity or layer[index] == nil)
	layer[index] = entity
end


-- remove entity from map's list
function Map:RemoveEntity(entity)
	-- layer should exist
	assert(self.Entities[entity.Layer])
	local layer = self.Entities[entity.Layer]
	local index = self:CoordToIndex(entity.TileX, entity.TileY)

	-- entity should be at the position
	assert(entity == layer[index])
	layer[index] = nil
end


-- get the number of layers in a map
function Map:LayerCount()
	-- number of layers should always be a factor of 3
	assert(#self.MapDef.layers % 3 == 0)
	return #self.MapDef.layers / 3
end


-- Render the map
function Map:Render(renderer)
	self:RenderLayer(renderer, 1)
end


-- each layer includes:
-- 		- base layer
--		- decoration layer
-- 		- collision layer
-- supports being able to have multiple layers
-- 
-- example: player can walk on upper walkway over lower layer
-- 
function Map:RenderLayer(renderer, layer)

	-- map is made of 3 sections
	-- want index to point to base section of a given layer
	local layerIndex = (layer * 3) - 2

	-- Get the topLeft and bottomRight pixel of the camera
	-- and use to get the tile
	local tileLeft, tileBottom =
		self:PointToTile(self.CamX - System.ScreenWidth() / 2,
						 self.CamY - System.ScreenHeight() / 2)

	local tileRight, tileTop =
		self:PointToTile(self.CamX + System.ScreenWidth() / 2,
						 self.CamY + System.ScreenHeight() / 2)

	for j = tileTop, tileBottom do
		for i = tileLeft, tileRight do

			local tile = self:GetTile(i, j, layerIndex)
			local uvs = {}

			self.TileSprite:SetPosition(self.X + i * self.TileWidth,
										self.Y - j * self.TileHeight)

			-- base layer
			if tile > 0 then
				uvs = self.UVs[tile]
				self.TileSprite:SetUVs(unpack(uvs))
				renderer:DrawSprite(self.TileSprite)
			end

			-- decoration layer
			tile = self:GetTile(i, j, layerIndex + 1)

			-- if the decoration tile exists
			if tile > 0 then
				uvs = self.UVs[tile]
				self.TileSprite:SetUVs(unpack(uvs))
				renderer:DrawSprite(self.TileSprite)
			end
		end

		-- draw entities sorted by vertical position
		local entityLayer = self.Entities[layer] or {}
		local drawList = {hero}

		for k, j in pairs(entityLayer) do
			table.insert(drawList, j)
		end

		table.sort(drawList, function(a,b) return a.TileY < b.TileY end)

		for k, j in ipairs(drawList) do
			renderer:DrawSprite(j.Sprite)
		end
	end
end