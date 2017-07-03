# Features

## Stage selection

- Press SELECT during Stage Select screen to toggle which route you are using (Top first, Magnet first, Gemini first).

- When selecting a stage, you will automatically recieve the correct weapons for that stage.

- Press A to go to the corresponding Robot Master stage.

- Press A in the middle (on the Mega Man graphic) to go to Break Man.

- Press START in a corner to go to the corresponding Doc Robot stage.

- Press B to go to Wily stages. First slot (top left) goes to Wily 1, second slot to Wily 2 etc. Slot 7-9 goes to imminent death.

- If you beat a Wily stage (or Break Man), you should automatically go to the next one.

- If you beat any Robot Master/Doc Robot stage, you're sent back to a Stage Select screen with all stages available.

## Frame counter

- First number is seconds (0-99), second number is frames (0-59).

- Should show frames including lag frames (aka real time frames). I don't know the game engine by heart so it will have to be verified by testing more.

- Due to limitations in the game, the counter is only shown "briefly" (1 second) and not all the time.

- I've not taken the (long) time to make sure a normal gameplay frame has correct cycle count, but I doubt it should affect lag.

## Go to Stage Select

- You can go to Stage Select anytime by opening up the pause menu (pressing START during gameplay) and then pressing SELECT once.

# TODO (if the stars align)

- Clear counter after each boss in refights.

- Skip cutscenes (can end the stage soon after he jumps into the air in Robot Master's for example).

- Teleport within stages, similar to lttphack.

# Contribute

The asm code compiles with xkas-plus 0.14 or something like that. You also need ips.pl or similar. Check the Makefile.
