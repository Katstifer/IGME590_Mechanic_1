class_name InventoryGrid
extends GridContainer

@export var slotSize: int = 32; 
@export var slotBorderWidth: int = 2; 

@export var width: int = 3; 
@export var height: int = 3; 

@export var vertSeparation: int = 0;
@export var horSeparation: int = 0; 

@export var slotData: Array[Node] = []; 

@export var currentSlot: Node; 
var previousSlot: Node; 

@export var currentHeldItem: Node = null; 

var alreadyHighlighted = false; 
var highlightedSlots: = [];

@export var inventoryItemPrefabs: Array[PackedScene] = [];

const GlobalEnums = preload("res://scripts/globalEnums.gd");

@export var slotPrefab: PackedScene; 

func _ready() -> void:
	add_theme_constant_override("h_separation", horSeparation);
	add_theme_constant_override("v_separation", vertSeparation);
	
	setupInventory(); 
		
func _process(delta: float) -> void:
	if (!get_global_rect().has_point((get_global_mouse_position()))):
		if (currentSlot != null):
			currentSlot = null
		if (highlightedSlots.size() && highlightedSlots != null):
			unhighlightSlots(highlightedSlots);
	if (currentHeldItem != null && currentSlot != null):
		#If an item is being held and it is being hovered over a grid
		if (currentSlot != previousSlot):
		#If a new slot is being hovered over
			var newSlots = getPotentialSpace(currentSlot, currentHeldItem);
			if highlightedSlots != null && highlightedSlots.size() > 0:
				#Check if highlighted slots exists
				var resultsToUnhighlight = highlightedSlots.filter(
					func(slot): return not newSlots.has(slot)
				)
				unhighlightSlots(resultsToUnhighlight);

			print("Highlighting grid!"); 
			highlightedSlots = newSlots; 
			
			var highlightColor; 
			
			if (checkForFit(currentHeldItem.itemGrid, highlightedSlots)):
				highlightColor = GlobalEnums.SlotState.EMPTY;
			else:
				highlightColor = GlobalEnums.SlotState.TAKEN; 
				
			highlightSlots(highlightedSlots, highlightColor);
			previousSlot = currentSlot; 
				
		if Input.is_action_just_pressed("LMB"):
			attemptItemPlace(currentSlot, currentHeldItem);
			
	elif (currentSlot != null):
		if (currentSlot != previousSlot):
			var newSlots = []; 
			newSlots.append(currentSlot);
			if (highlightedSlots != null && highlightedSlots.size() > 0):
				unhighlightSlots(highlightedSlots);
				highlightedSlots = newSlots; 
			highlightSlots(highlightedSlots, GlobalEnums.SlotState.HOVERED);
			
	if (currentHeldItem != null):
		if Input.is_action_just_pressed("Rotate"):
			currentHeldItem.rotateItem(); 
			var newSlots = getPotentialSpace(currentSlot, currentHeldItem);
			if (highlightedSlots != null && highlightedSlots.size() > 0):
				var resultsToUnhighlight = highlightedSlots.filter(
					func(slot): return not newSlots.has(slot)
				)
				unhighlightSlots(resultsToUnhighlight);

			print("Rotating highlights on grid!"); 
			highlightedSlots = newSlots; 
			
	
# Setup inventory by filling the grid container with slots
func setupInventory(): 
	self.columns = width; 
	for y in height:
		for x in width:
			createSlot(); 

func createSlot(): 
	var inventorySlot = slotPrefab.instantiate();
	inventorySlot.rectSize = slotSize; 
	inventorySlot.borderWidth = slotBorderWidth; 
	
	inventorySlot.mouseEnteredSlot.connect(onSlotMouseEnter)
	inventorySlot.mouseExitedSlot.connect(onSlotMouseExit)
	inventorySlot.attemptItemPickup.connect(onAttemptPickup)
			
	add_child(inventorySlot);
	slotData.append(inventorySlot);
	#print(slotData);
	
func createEmptySlotData():
	var totalElements = width * height;  
	slotData = []; 
	slotData.resize(totalElements);
	
# Called whenever the mouse enters the area of a slot. 
func onSlotMouseEnter(slot: Node):
	previousSlot = currentSlot; 
	currentSlot = slot; 
	print("Previous Slot: " + str(previousSlot));
	print("Current Slot: " + str(currentSlot));
	
	#var slotVector = getSlotCoords(slot);
	#var slotRef = getSlotFromCoords(slotVector.y, slotVector.x);
	#currentSlot.updateSlotColor(GlobalEnums.SlotState.EMPTY);

# Called whenever the mouse leaves the area of a slot
func onSlotMouseExit(slot: Node):
	#print("On mouse exit in InventoryGrid")
	#slot.updateSlotColor(GlobalEnums.SlotState.DEFAULT);
	pass;
	
#Gets the X and Y coords (representing column, and row)
#from a slot node
func getSlotCoords(slot: Node):
	var index = slotData.find(slot);
	if (index == -1):
		print("Slot not found.")
	else :
		var row = index / width
		var column = index % width

		return Vector2i(column, row);
	
#Gets a reference to an inventory slot using its row and column
func getSlotFromCoords(row: int, column: int):
	if (row < 0 || row >= height):
		return null; 
		
	if (column < 0 || column >= width):
		return null; 
		
	var index = getIndexFromCoords(row, column);
	
	if (index >= 0 && index < slotData.size()):
		return slotData[index];
		
	return null;

#Gets the index of an inventory slot using its row and column
func getIndexFromCoords(row: int, column: int):
	#print("Column (X): " + str(column) + " Row (Y): " + str(row))
	var index = row * width + column;  
	#print("Index: " + str(index))
	return index; 

#Attempts to place an item at a specified slot
#It will attempt to place an item using the top left-most
#tile in the item's structure. 
func placeItem(item: Node, anchorSlot: Node, fitSlots : Array):
	for s in fitSlots: 
		s.addItem(item);
	if (anchorSlot != null):
		print("Anchor Slot Index: " + str(getSlotCoords(anchorSlot)));
		print("Anchor Slot Location: " + str(anchorSlot.get_global_position()));

		item.placeItem(anchorSlot);
	currentHeldItem = null; 

func onAttemptPickup(slot: Node):
	if (currentHeldItem != null):
		slot.containedItem.pickupItem(); 
	else:
		pass;

func attemptItemPlace(slot: Node, item: Node):
	var fitSpaces = getPotentialSpace(slot, item);
	var allSpaces = getFullItemRect(slot, item);
	if (checkForFit(item.itemGrid, fitSpaces)):
		placeItem(item, slot, fitSpaces);
	
#Spawns a new item in from the prefabs list (NOT IMPLEMENTED YET)
func onSpawnButtonPress() -> void:
	if (inventoryItemPrefabs.size() <= 0):
		return; 
	var newItem = inventoryItemPrefabs[0].instantiate(); 
	self.get_parent().add_child(newItem);
	newItem.isSelected = true; 
	currentHeldItem = newItem; 

#Gets the potential spaces on the grid that an item will occupy
func getPotentialSpace(slot: Node, item: Node):
	var itemShape = item.itemGrid; 
	var mouseCoord = getSlotCoords(slot)
	print("Anchor: " + str(item.anchor));
	print("Mouse: " + str(mouseCoord));
	var startCoord = mouseCoord - item.anchor
	print("Start: " + str(startCoord));
	if startCoord == null:
		return [];
	#How many columns/how long along X item is
	var shapeWidth = itemShape[0].size();
	#How many rows/how long along Y item is
	var shapeHeight = itemShape.size(); 
	var slotList = [];

	for y in range(startCoord.y, startCoord.y + shapeHeight):
		for x in range(startCoord.x, startCoord.x + shapeWidth):
			
			var itemTile = itemShape[y - startCoord.y][x - startCoord.x];
			if (itemTile != 1):
				continue;
				
			if (y >= height || y < 0):
				continue;
				
			if (x >= width || x < 0):
				continue;		
					
			var checkSlot = getSlotFromCoords(y, x);
			if (checkSlot != null):
				slotList.append(checkSlot);
	return slotList; 

#Gets the full rectangle (border box of space item will occupy) for rendering purposes
func getFullItemRect(slot: Node, item: Node):
	var itemShape = item.itemGrid; 
	var mouseCoord = getSlotCoords(slot)
	var startCoord = mouseCoord - item.anchor
	if startCoord == null:
		return [];
	#How many columns/how long along X item is
	var shapeWidth = itemShape[0].size();
	#How many rows/how long along Y item is
	var shapeHeight = itemShape.size(); 
	var slotList = [];
	
	for y in range(startCoord.y, startCoord.y + shapeHeight):
		for x in range(startCoord.x, startCoord.x + shapeWidth):
			
			if (y >= height || y < 0):
				continue;
				
			if (x >= width || x < 0):
				continue;		
					
			var checkSlot = getSlotFromCoords(y, x);
			if (checkSlot != null):
				slotList.append(checkSlot);
	return slotList;
	
# Checks if the shape is able to fit in the slots on the
# grid it would go into. Returns true if it can fit, false if not
func checkForFit(itemShape: Array, potentialSlots: Array):
	# If the itemshape and potentialslots exist/have content
	if (itemShape == null 
	|| itemShape.size() == 0 
	|| potentialSlots == null 
	|| potentialSlots.size() == 0) : 
		print("Item does not fit");
		return false; 
	else:		
		var itemShapeSum = 0; 
		
		for y in itemShape.size():
			for x in itemShape[y].size(): 
				if (itemShape[y][x] == 1):
					itemShapeSum += 1; 
		
		if (itemShapeSum != potentialSlots.size()):
			return false; 
			
		# Check if all of thse slots that the object
		# would go into are empty. If they are, return true.
		for slot in potentialSlots: 
			if slot.containedItem != null: 
				print("Slot contains item");
				return false; 
		return true

#Returns highlighted slots to their original color
func unhighlightSlots(slots): 
	for slot in slots: 
		slot.updateSlotColor(GlobalEnums.SlotState.DEFAULT) 
	
func highlightSlots(slots, slotState: GlobalEnums.SlotState):
	if slots == null || slots.size() <0:
		return; 
	for slot in slots: 
		slot.updateSlotColor(slotState);

func updateSlotHighlights(): 
	pass;
