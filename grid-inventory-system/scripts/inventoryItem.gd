class_name InventoryItem
extends Control

# more specific typing please mama
@export var inventorySprite : Sprite2D; 

#Max width and height of the space an item takes up
@export var height: int; 
@export var width: int; 

#Change to alter the default size of the item if
#no size is given
var defaultHeight: int = 2; 
var defaultWidth: int = 2; 

#Change to alter the speed of lerping to 
#mouse or grid position
var lerpSpeed: int = 20; 

#Represents the size and shape of the tiles an item will occupy
#0 represents an empty tile and 1 represents an occupied one
@export var itemGrid: Array[Array] = [];
@export var anchor: Vector2i; 
var zeroOffset: Vector2; 
var slotSize: int = 32; 

#Angle item is rotated to
var angle: int = 0; 
var previousAngle: int = 0; 

#Whether the item has been selected and is moving with the mouse
var isSelected : bool = false; 
#Whether the item is currently moving to its target location on the grid
var isMovingToGrid : bool = false; 

#The slot this item is contained in (top-left, to keep track of location)
var slotContainer: InventorySlot = null; 
var previousContainer: InventorySlot = null; 

 # Top-left-most location in grid
var targetPosition: Vector2; # Top left-most location in grid

func _ready() -> void:
	if inventorySprite == null: 
		inventorySprite = $inventoryItem_Sprite; 
	
	slotContainer = null;
	isSelected = false; 
	isMovingToGrid = false; 
	zeroOffset = findZeroOffset();
	
func _process(delta: float) -> void:
	
	if (isSelected) : 
		global_position = lerp(get_global_position() - zeroOffset, get_global_mouse_position(), delta * lerpSpeed);
		
	if (isMovingToGrid) : 
		lerpToPosition(delta);

#Initializes the array containing the spaces an item will occupy
#if a prebuilt array is not added in the inspector. Calls setScale at end
func initItemGrid(slotSize : int):
	#Slot size is half the size of inventory slots
	#because of the different way size is handled in Sprite2d
	self.slotSize = int(slotSize/2); 
	
	if (itemGrid.size() > 0 && itemGrid != null):
		height = itemGrid.size(); 
		if (itemGrid[0].size() > 0):
			width = itemGrid[0].size(); 
		else: 
			print("Item row is empty, setting width");
			if (width == 0 || width == null):
				width = 2; 
	else: 
		print("Item Grid Size > 0")
		if (height == 0 || height == null):
			height = 2; 			
		if (width == 0 || width == null):
			width = 2; 
	
	# If an item grid does not have a specified size
	# simply make a rectangle with the given dimensions
	if itemGrid.size() <= 0 || itemGrid == null:
		itemGrid = []; 
		itemGrid.resize(height);
		
		for i in height:
			itemGrid[i].resize(width);
			itemGrid[i].fill(1);
		print(itemGrid);
	
	#If there are any rows in the inventory shape 
	#with no size, populate them based on width
	for i in itemGrid.size(): 
		if (itemGrid[i].size() <= 0):
			itemGrid[i].resize(width);
			itemGrid[i].fill(1);
			
	
	if anchor == null:
		anchor = Vector2i(0, 0);
	
	if anchor.x >= itemGrid[0].size():
		anchor.x = 0;
	
	if anchor.y >= itemGrid.size(): 
		anchor.y = 0; 
		
	setItemScale(); 
	
#If the item sprite does not scale properly to match the slot size, 
#scale it up appropriately. Ex. 32 x 32 texture on a 64 x 64 slot. 
func setItemScale(): 
	if (inventorySprite == null):
		inventorySprite = $inventoryItem_Sprite; 
		
	var spriteWidth = inventorySprite.texture.get_width(); 
	var spriteHeight = inventorySprite.texture.get_height(); 
	
	if ((spriteWidth * inventorySprite.scale.x/ slotSize) != width * 2):
		var xScale = float((float(slotSize) * width * 2)) / float(spriteWidth);
		inventorySprite.scale.x = xScale; 
		findZeroOffset();
		
	if ((spriteHeight * inventorySprite.scale.y/ slotSize) != height * 2): 
		var yScale = float((float(slotSize) * height * 2)) / float(spriteHeight);
		inventorySprite.scale.y = yScale; 
		findZeroOffset();
		
#Finds the offset from the zero of this object it needs to 
#move to the proper fitting space in the grid
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
	
	previousAngle = angle; 
	previousContainer = slotContainer; 
	slotContainer = null; 
	
	isSelected = true;  
	isMovingToGrid = false; 
		
# Places item down on grid
func placeItem(slot : InventorySlot): 
	slotContainer = slot; 
	previousContainer = null; 
	
	isSelected = false; 
	
	#print("Anchor Slot Location: " + str(slot.get_global_position()));
	
	var centerOfAnchorSlot = slotContainer.get_global_position() + Vector2(slotSize, slotSize);
	
	targetPosition = centerOfAnchorSlot - zeroOffset; 
	isMovingToGrid = true; 
	
#Rotates an item 90 degrees counter clockwise
func rotateItem():
	angle += (90);

		#Resets angle to standard
	if (angle < 0):
		angle = 270; 
	if (angle >= 360):
		angle = 0;

	var newMatrix: Array[Array] = [];
	newMatrix.resize(width);
	
	#Transforms the anchor
	var anchorTransform = []; 
	anchorTransform.resize(height);
	var currentAnchorIndex = 0; 
	
	for i in newMatrix.size(): 
		newMatrix[i].resize(height);
		newMatrix[i].fill(0);

	var newHeight = width; 
	var newWidth = height; 
	
	for y in newMatrix.size(): 
		for x in newMatrix[0].size(): 
			newMatrix[y][x] = itemGrid[x][y];
				
			if (y == anchor.x):
				if (x == anchor.y):
					currentAnchorIndex = x; 
				anchorTransform[x] = Vector2i(x, y);

	for y in newMatrix.size(): 
		newMatrix[y].reverse();
	anchorTransform.reverse(); 
	
	width = newWidth; 
	height = newHeight; 
	
	rotateSprite(); 
	itemGrid = newMatrix; 

	anchor = anchorTransform[currentAnchorIndex];
	
	zeroOffset = findZeroOffset(); 
	
#Rotates sprite in accordance with current angle. 
func rotateSprite():
	if (inventorySprite == null):
		return; 
	inventorySprite.rotation_degrees = angle; 

#Lerps the item to a specified position. The target should be 
#the position you want the ANCHOR to be at. 
func lerpToPosition(delta : float): 
	global_position = lerp(get_global_position(), targetPosition - zeroOffset, lerpSpeed * delta);
	
	if ( Vector2i(get_global_position().round()) == Vector2i((targetPosition - zeroOffset).round()) ):
		isMovingToGrid = false; 

#Rotates item to a specified angle. 
func rotateToAngle(targetAngle: int):
	while (angle != targetAngle):
		rotateItem(); 

func getNumberOfTakenSlots(): 
	var sum = 0; 
	for y in itemGrid.size(): 
		for x in itemGrid[0].size():
			if itemGrid[y][x] == 1: 
				sum += 1; 
	return sum;  
