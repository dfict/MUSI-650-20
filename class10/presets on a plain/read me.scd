A few notes on the presets on a plain:

To try this out:
Load the program and then press the Load Presets button.
Double click on one of the files display.  It will load both.
The .xy.json file holds coordinates on the 2D slider, presets.json holds the settings.
Once finished, you will see "point-0" in the popup menu at the to.

You can now select presets from that menu. Or you can select them from the keyboard
They are assigned to the alphabetic keys following the spatial order on the keyboard from
left to right and top to bottom as in  "qwertyuiopasdfghjklzxcvbnm"

But preset names are in lexicographic order so point-10 precedes point-9.

To use interpolation, press the Load nn button and select the file with the same base name as the presets you selected.  Once loaded, you can press the  Not interpolating button to get to Interpolating,  Or you can use the shift key.

Presets
1. the patch starts running as soon as you load it.
2. changing the horizontal sliders will change the sound.
3. pressing Add Preset @ XY will save the current slider settings as a preset associated with
the position of the 2D slider above it.
4. pressing the control key does the same thing.
5. Once stored, you can recall a preset from the menu above the Add Preset button.
6. You can also do that by pressing alphabetic keys on the keyboard - they select in
keyboard order  qwertyuiopasdfghjklzxcvbnm

Neural net interpolation
1. Once you have made or loaded a set of presets, you can tune a neural network to
to interpolate between those presets as you change the 2d slider.
2. The train button defines the interpolation. Pressing the train button will cause an error value to be displayed. The smaller the error, the more accurately the interpolation will play the presets. You can press the train button repeatedly to improve the results.
3. You can create distinct interpolators for the same presets - these can sound meaningfully different.
