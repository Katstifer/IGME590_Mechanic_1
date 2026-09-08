class_name InventoryItem
extends Node2D

@export var height: int; 
@export var width: int; 
@export var isRectangle: bool; 
@export var angle: int; 

var previousPosition; # Top-left-most location in grid
var movePosition; 

# Picks up the item and attaches it to mouse
func pickUpItem():
	pass; 
	
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
