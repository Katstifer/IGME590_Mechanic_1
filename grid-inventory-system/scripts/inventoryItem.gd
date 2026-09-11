class_name InventoryItem
extends Control


@onready var inventorySprite : Node = $inventoryItem_Sprite; 

#Max width and height of the space an item takes up
var height: int; 
var width: int; 

var slotSize: int = 32; 
var lerpSpeed: int = 20; 

#Represents the size and shape of the tiles an item will occupy
#0 represents an empty tile and 1 represents an occupied one
@export var itemGrid: Array[Array] = [];
@export var anchor: Vector2i; 
@export var zeroOffset: Vector2; 

#Angle item is rotated to
@export var angle: int = 0; 

#Whether the item has been selected and is moving with the mouse
@export var isSelected : bool = false; 
#Whether the item is currently moving to its target location on the grid
@export var isMovingToGrid : bool = false; 

#The slot this item is contained in (top-left, to keep track of location)
var slotContainer = null; 
var previousContainer = null; 
 # Top-left-most location in grid
var targetPosition: Vector2; # Top left-most location in grid

func _ready() -> void:
	print("New Item:", self.name, "  ", get_instance_id())

	slotContainer = null;
	isSelected = false; 
	isMovingToGrid = false; 
	initItemGrid(); 
	zeroOffset = findZeroOffset();
	
func _process(delta: float) -> void:
	
	if (isSelected) : 
		global_position = lerp(get_global_position() - zeroOffset, get_global_mouse_position(), delta * lerpSpeed);
		
	if (isMovingToGrid) : 
		lerpToPosition(delta);

func initItemGrid():
	print("Init item grid");
	# If an item grid does not have a specified size
	# simply make a rectangle with the given dimensions
	if (height == 0 || height == null):
		if itemGrid.size() > 0 && itemGrid != null: 
			height = itemGrid.size(); 
		else:
			height = 2; 
			
	if (width == 0 || width == null):
		if (itemGrid[0].size() > 0 && itemGrid != null):
			width = itemGrid[0].size(); 
		else: 
			width = 2; 
	
	if itemGrid.size() <= 0 || itemGrid == null:
		itemGrid = []; 
		itemGrid.resize(height);
		
		for i in height:
			itemGrid[i].resize(width);
			itemGrid[i].fill(1);
	
	if anchor == null:
		anchor = Vector2i(0, 0);
		
func findZeroOffset(): 
	var anchorX = 0; 
	var anchorY = 0; 
	
	var centerPoint = inventorySprite.position; 

	var anchorOffset = Vector2(
	(anchor.x + 0.5) * slotSize - width * slotSize / 2.0,
	(anchor.y + 0.5) * slotSize - height * slotSize / 2.0
	)

	return anchorOffset; 
	
# Picks up the item and attaches it to mouse
func pickUpItem():
	if isSelected:
		return 
		
	print("Picking up item");
	previousContainer = slotContainer; 
	slotContainer = null; 
	
	isSelected = true;  
	isMovingToGrid = false; 
		
"""
func dropItem(): 
	print("Dropping item: " + str(self) + " " + str(get_instance_id()));
	isSelected = false; 
	if (previousContainer != null):
		placeItem(previousContainer);
	else:
		targetPosition = Vector2(0,0);
		isMovingToGrid = true; 
"""

# Places item down on grid
func placeItem(slot : Node): 
	slotContainer = slot; 
	previousContainer = null; 
	
	isSelected = false; 
	
	print("Anchor Slot Location: " + str(slot.get_global_position()));
	
	var centerOfAnchorSlot = slotContainer.get_global_position() + Vector2(slotSize, slotSize);
	
	targetPosition = centerOfAnchorSlot - zeroOffset; 
	isMovingToGrid = true; 
	
#Rotates an item 90 degrees counter clockwise
func rotateItem():
	print("Rotating item");
	angle += (90);

		#Resets angle to standard
	if (angle < 0):
		angle = 270; 
	if (angle >= 360):
		angle = 0;

	var newMatrix: Array[Array] = [];
	newMatrix.resize(width);
	
	for i in newMatrix.size(): 
		newMatrix[i].resize(height);
		newMatrix[i].fill(0);

	var newHeight = width; 
	var newWidth = height; 
	
	for y in newMatrix.size(): 
		for x in newMatrix[0].size(): 
			newMatrix[y][x] = itemGrid[x][y];
			
	for y in newMatrix.size(): 
		newMatrix[y].reverse();

	width = newWidth; 
	height = newHeight; 
	
	rotateSprite(); 
	itemGrid = newMatrix; 
	
	var newAnchor : Vector2i = Vector2i(anchor.y, anchor.x);
	anchor = newAnchor;
	
	zeroOffset = findZeroOffset(); 
	

func rotateSprite():
	if (inventorySprite == null):
		return; 
	inventorySprite.rotation_degrees = angle; 

#Lerps the item to a specified position. It moves the top-left of the item
#to the target position, which should be at the top-left of where you want the item to be
func lerpToPosition(delta): 
	#
	#print("TargetPos (AnchorSlot Center): " + str(targetPosition));
	#print("TargetPos (AnchorSlot w/ Offset): " + str(targetPosition + zeroOffset));
	#print("Zero Offset: " + str(zeroOffset));
	#print("GlobalPos: " + str(get_global_position()));
	
	global_position = lerp(get_global_position(), targetPosition - zeroOffset, lerpSpeed * delta);
	
	if ( Vector2i(get_global_position().round()) == Vector2i((targetPosition - zeroOffset).round()) ):
		print("Reached target pos");
		isMovingToGrid = false; 
