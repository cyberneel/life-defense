# life-defense
A game made with Godot based on the mechanics of Conway's Game of Life!

## How To Play?
Currently, the game is simple. You start off with 10 Life Points (LP) which you can spend by placing live player cells (red cells) on the grid. Every simulation step, which happens either when the recurring timer runs out or when you hit SPACE, these Conway's rules apply to the grid:
1. Any live cell with fewer than two live neighbours dies (referred to as underpopulation).
2. Any live cell with more than three live neighbours dies (referred to as overpopulation).
3. Any live cell with two or three live neighbours lives, unchanged, to the next generation.
4. Any dead cell with exactly three live neighbours comes to life.

To gain Life Points (LP), remove alive player cells on the grid by clicking them. It's like harvesting them! You can also quickly "Harvest All" with "C"

Periodically, enemy cells (green cells) spawn. To kill enemies, you can click on them if you have enough Life Points (LP) to spare (3 LP). You can even "Kill All" if you have enough Life Points (LP) with "x"
