class_name InventoryItem
extends Control

#Max width and height of the space an item takes up
@export var height: int; 
@export var width: int; 

var slotSize: int; 
var lerpSpeed: int = 20; 

#Contains the size and shape of the item. 
#0 represents an empty tile and 1 represents an occupied one
@export var itemGrid: Array[Array] = [];

#Angle item is rotated to
@export var angle: int; 

@export var isSelected = false; 
	
var previousPosition: Vector2; # Top-left-most location in grid
var movePosition; 

func _ready() -> void:
	isSelected = true; 
	initItemGrid(); 
	
func _process(delta: float) -> void:
	if (isSelected) : 
		global_position = lerp(get_global_position(), get_global_mouse_position(), delta * lerpSpeed);

func initItemGrid():
	print("Init item grid");
	# If an item grid does not have a specified size
	# simply make a rectangle with the given dimensions
	if itemGrid.size() <= 0 || itemGrid == null:
		itemGrid = []; 
		itemGrid.resize(height);
		
		for i in height:
			itemGrid[i].resize(width);
			itemGrid[i].fill(1);
	
# Picks up the item and attaches it to mouse
func pickUpItem():
	if !isSelected: 
		isSelected = true;  
	
# Places item down on grid
func placeItem(): 
	#If the item cannot be placed : Handle error logic
	pass;

func moveToPrevious(): 
	#Moves item back to previous position
	pass; 
	
# Rotates the item a specified direction
# Direction represented by 1 (counter-clockwise) and -1 (clockwise)
func rotateItem(direction):
	angle += (90 * direction);
	
	pass; 
