class_name InventoryItem
extends Control


#Max width and height of the space an item takes up
@export var height: int; 
@export var width: int; 

var slotSize: int = 32; 
var lerpSpeed: int = 20; 

#Represents the size and shape of the tiles an item will occupy
#0 represents an empty tile and 1 represents an occupied one
@export var itemGrid: Array[Array] = [];
@export var anchor: Vector2i; 
@export var zeroOffset: Vector2; 

#Angle item is rotated to
@export var angle: int; 

#Whether the item has been selected and is moving with the mouse
@export var isSelected : bool = false; 
#Whether the item is currently moving to its target location on the grid
@export var isMovingToGrid : bool = false; 

#The slot this item is contained in (top-left, to keep track of location)
var slotContainer = null; 
	
var previousPosition: Vector2; # Top-left-most location in grid
var targetPosition: Vector2; # Top left-most location in grid

func _ready() -> void:
	slotContainer = null;
	isSelected = true; 
	initItemGrid(); 
	zeroOffset = findZeroOffset();
	print("Item ready, offset: " + str(zeroOffset));
	
func _process(delta: float) -> void:
	if (isSelected) : 
		global_position = lerp(get_global_position() - zeroOffset, get_global_mouse_position(), delta * lerpSpeed);
		
	if (isMovingToGrid) : 
		lerpToPosition(delta);

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
	
	if anchor == null:
		anchor = Vector2i(0, 0);
		
func findZeroOffset(): 
	print("Find zero offset");
	print("Slot size: " + str(slotSize));
	#For every row in the 
	var offsetX = 0;
	var offsetY = 0;
	
	for y in anchor.y + 1: 
		print("Y" + str(y));
		if y == anchor.y: 
			offsetY += (slotSize / 2);
		else : 
			offsetY += slotSize; 
		print("Updated Y: " + str(offsetY));

	for x in anchor.x + 1: 
			print("x" + str(x));
			if x == anchor.x: 
				offsetX += (slotSize / 2);
			else : 
				offsetX += slotSize; 
			print("Updated X: " + str(offsetX));
			
	print("Out of Loop: " + str(offsetX) + ", " + str(offsetY));
	var offset = Vector2(offsetX, offsetY);
	return offset; 
	
# Picks up the item and attaches it to mouse
func pickUpItem():
	if !isSelected: 
		isSelected = true;  
	
# Places item down on grid
func placeItem(slot : Node): 
	#slotContainer = slot; 
	isSelected = false; 
	print("Anchor Slot Location: " + str(slot.get_global_position()));
	var centerOfAnchorSlot = slot.get_global_position() + Vector2(slotSize, slotSize);
	targetPosition = centerOfAnchorSlot - zeroOffset; 
	isMovingToGrid = true; 

func moveToPrevious(): 
	targetPosition = previousPosition; 
	isMovingToGrid = true; 
	#Moves item back to previous position
	
#Rotates an item 90 degrees counter clockwise
func rotateItem():
	angle += (90);

		#Resets angle to standard
	if (angle < 0):
		angle = 270; 
	if (angle >= 360):
		angle = 0;
	
	var newMatrix = [];
	newMatrix.resize(width);
	for i in newMatrix.size(): 
		newMatrix[i].resize(height);
	
	var newHeight = width; 
	var newWidth = height; 
	
	for y in newMatrix.size(): 
		for x in newMatrix[0].size(): 
			newMatrix[x][y] = itemGrid[y][x];
	
	for y in newMatrix.size(): 
		newMatrix[y].reverse();

	width = newWidth; 
	height = newHeight; 
	
	rotateSprite(); 
	itemGrid = newMatrix; 

func rotateSprite():
	
	pass; 
#Lerps the item to a specified position. It moves the top-left of the item
#to the target position, which should be at the top-left of where you want the item to be
func lerpToPosition(delta): 
	global_position = lerp(targetPosition - zeroOffset, get_global_position(), lerpSpeed * delta);
	if (get_global_position() == (targetPosition - zeroOffset)):
		isMovingToGrid = false; 
