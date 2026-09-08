class_name GridInventory
extends Node2D

@export var width: int = 8; 
@export var height: int = 6;

@export var gridVSeparation: int = 4; 
@export var gridHSeparation: int = 4; 

var inventorySlots = []; 
var inventorySlotNodes = [];
var occupiedSlots = []; 

const inventorySlotPrefab = preload("res://scenes/inventorySlot.tscn");

@onready var gridContainer = $grid_Container; 

# Create a grid of squares that can
# be occupied by grid items. 
func _ready() -> void:
	print("Grid Inventory Ready!");
	createGrid(); 

func setGridContainerFields(): 
	if !gridContainer:
		pass;
		
	gridContainer.columns = height; 
	
	gridContainer.add_theme_constant_override("h_separation", gridHSeparation);
	gridContainer.add_theme_constant_override("v_separation", gridVSeparation);
	
# Create a grid based on width and height
func createGrid():
	setGridContainerFields();
	
	#clearGrid(); 
	for y in range(0, height):
		for x in range(0, width):
			var newSlot = inventorySlotPrefab.instantiate(); 
			newSlot.setFields(x, y);
			
			inventorySlotNodes.append(newSlot);
			inventorySlots[x][y] = newSlot.slotId; 
			
			gridContainer.add_child(newSlot);
	pass; 
	
func clearGrid(): 
	
	#for y in range(0, height):
	#	for x in range(0, width):
	#		inventorySlots[x][y] = null;
	#		occupiedSlots[x][y] = null;
	#print("Grid cleared!");
	pass; 
	
func getHoveredSlot():
	pass; 
	
# Check whether an item's shape overlaps
# with another
# Returns true if overlapping, false if not
func checkOverlap(itemPosition, itemWidth, itemHeight):
	
	#Starting with the item position (top-left)
	for y in range(itemPosition.y, itemPosition.y + itemHeight):
		for x in range(itemPosition.y, itemPosition.y + itemHeight):
			print(str(x) + ", " + str(y));	
			if (occupiedSlots[x][y] != null):
				print("Slot occupied at: " + str(x) + ", " + str(y) )
				return true; 
	return false; 
	
# Place an item into the grid
func placeItem(item: InventoryItem):
	if (checkOverlap(item.movePosition, item.width, item.height)):
		print("Cannot place item.")
	else :
		pass;
		

func deleteItem(item):
	pass; 
