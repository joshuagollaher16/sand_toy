extends TileMap


@export var uiStopperPath: NodePath
@onready var uiStopper = get_node(uiStopperPath)


class Tile:
	
	var pos: Vector2i
	var type: TileType
	var was_updated_this_frame: bool
	
	func _init(p: Vector2i, type: TileType):
		self.pos = p
		self.type = type
		self.was_updated_this_frame = false
		


enum TileType {
	Nothing,
	Sand,
	Water,
	Stone,
	Oil
}

const ATLAS_SAND = Vector2(0, 0)
const ATLAS_WATER = Vector2(1, 0)
const ATLAS_STONE = Vector2(2, 0)
const ATLAS_OIL = Vector2(3, 0)

@onready var world_size = Vector2i(get_viewport().size.x / 8, get_viewport().size.y / 8)

var tiles = []

func outside_tile_bounds(grid_tile: Vector2i):
	
	var ret_val = grid_tile.x >= world_size.x || grid_tile.x < 0 || grid_tile.y < 0 || grid_tile.y >= world_size.y
	
	return ret_val

func tile_type_to_alias(type: TileType):
	if type == TileType.Sand:
		return ATLAS_SAND
	elif type == TileType.Water:
		return ATLAS_WATER
	elif type == TileType.Stone:
		return ATLAS_STONE
	elif type == TileType.Oil:
		return ATLAS_OIL

func set_tile(pos: Vector2i, type: TileType):
	if outside_tile_bounds(pos):
		return
	if type == TileType.Nothing:
		erase_cell(0, pos)	
		tiles[pos.x][pos.y].type = TileType.Nothing
		return
	set_cell(0, pos, 0, tile_type_to_alias(type))
	tiles[pos.x][pos.y].type = type

func able_to_move_to(pos: Vector2i):
	return !outside_tile_bounds(pos) && tiles[pos.x][pos.y].type == TileType.Nothing

func move_tile(from: Vector2i, to: Vector2i):
	var type = tiles[from.x][from.y].type
	set_tile(from, TileType.Nothing)
	set_tile(to, type)
	tiles[to.x][to.y].was_updated_this_frame = true

func _ready():
	for x in range(world_size.x):
		tiles.append([])
		for y in range(world_size.y):
			tiles[x].append(Tile.new(Vector2i(x, y), TileType.Nothing))

func update_cell(pos: Vector2i):
	if able_to_move_to(pos + Vector2i.DOWN):
		move_tile(pos, pos + Vector2i.DOWN)
	elif able_to_move_to(pos + Vector2i.DOWN + Vector2i.LEFT):
		move_tile(pos, pos + Vector2i.DOWN + Vector2i.LEFT)
	elif able_to_move_to(pos + Vector2i.DOWN + Vector2i.RIGHT):
		move_tile(pos, pos + Vector2i.DOWN + Vector2i.RIGHT)

func _physics_process(_delta):
	
	if Input.is_action_pressed("drop") and not uiStopper.currently_hovering:	
		var coords = get_global_mouse_position()
		var grid_tile = world_to_map(coords)
		set_tile(grid_tile, TileType.Sand)
	
	for x in range(world_size.x):
		for y in range(world_size.y):
			if tiles[x][y].type != TileType.Nothing && not tiles[x][y].was_updated_this_frame:
				update_cell(Vector2i(x, y))
	
	#when done
	for x in range(world_size.x):
		for y in range(world_size.y):
			tiles[x][y].was_updated_this_frame = false
	
