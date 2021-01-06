# LemonCube

LemonCube is a framework for the game engine LÖVE.
<p align="center"><img src="https://raw.githubusercontent.com/kevinmaddox/lemoncube/master/images/mia-plat.gif" alt="LemonCube Preview"/></p>

Some of the features include:
- Basic gamestate system with automatic room cleanup
- Entity system, which is effectively an easy way to create objects that contain animations and colliders, as well as a number of useful functions (along with an entity manager you don't have to touch)
- Collision system (supports both rectangular and circular colliders)
- Input contorllers for handling player inputs
- Tile-based map system which auto-generates collision maps based on which tiles have been marked as "obstacles"

This framework is still heavily in development, and is honestly tailored to my own needs. Its focus is more on rapid prototyping and simple game development, and is not intended to be a robust solution for excessively-complex games.

Planned features:
- Bitmap fonts
- Joystick support for Input Controllers
- Camera system
- Basic menu/UI system
- External map editor
- External animation editor
- Full documentation