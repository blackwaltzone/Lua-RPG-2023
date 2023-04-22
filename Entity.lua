--[[

	Entity.lua

	Entity class

	Dustin Heyden
	Feb 13, 2023

]]

Entity = {}
Entity.__index = Entity


function Entity:Create(def)

	local this =
	{
		Sprite = Sprite.Create(),
		Texture = Texture.Find(def.texture),
		Height = def.height,
		Width = def.width,
		TileX = def.tileX,
		TileY = def.tileY,
		Layer = def.layer,
		StartFrame = def.startFrame,
	}

	this.Sprite:SetTexture(this.Texture)
	this.UVs = GenerateUVs(this.Width, this.Height, this.Texture)

	setmetatable(this, self)

	this:SetFrame(this.StartFrame)

	return this
end


function Entity:SetFrame(frame)
    self.Sprite:SetUVs(unpack(self.UVs[frame]))
end


-- map tracks location of entities
-- this function keeps map and entity location in sync
function Entity:SetTilePos(x, y, layer, map)

	-- remove from current tile
	if map:GetEntity(self.TileX, self.TileY, self.Layer) == self then
		map:RemoveEntity(self)
	end

	-- check target tile
	if map:GetEntity(x, y, layer, map) ~= nil then
		assert(false)	-- something in the target position
	end

	self.TileX = x or self.TileX
	self.TileY = y or self.TileY
	self.Layer = layer or self.Layer

	map:AddEntity(self)
	local x, y = map:GetTileFoot(self.TileX, self.TileY)
	self.Sprite:SetPosition(x, y+self.Height/2)
end