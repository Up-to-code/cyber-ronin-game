# Lacquer mobile control atlas

Generated with the image-generation skill for this project,11November2026. Original raw.png retained. Nine equally gridded source cells are cropped by alpha bounds, nearest-resized to fit62×62, centered on64×64 canvases, and packed into game/art/pixel/controls-lacquer.png. No programmatic icon drawing is used in the runtime control faces.

Cell order: left,up,right,down,sword,kick,power,ranged,energy. Control code maps those cells to actions. Normal/pressed/disabled states tint the same art while the actual touch region stays fixed.
