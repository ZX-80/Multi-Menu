<div align="center">

# Multi-Menu

![badge](https://badgen.net/badge/version/v0.2.1/orange?style=flat-square)
![badge](https://badgen.net/badge/platform/F8/green?style=flat-square)

The main navigation screen of the Flashcart-Pi for the Channel F. 
  
<p align = "center">
  <img width="33%" src="https://user-images.githubusercontent.com/44975876/191892413-80af2ac4-c619-4bf3-8344-1c2e0a246e52.png">
</p>
  
[Protocol & Commands](#protocol--commands) •
[Text Encoding](#text-encoding)
  
</div>

## Navigating :world_map: 

Navigation can be done with either controller, or the console buttons:

| Action               | Controller | Button
|----------------------|------------|-------
|Previous file         | Right/Up   | 1
|Next file             | Left/Down  | 2
|Select file/directory | Press      | 3/4

## Protocol & Commands :mega:
The menu communicates with the Pico through port `$FF` and memory address `$2800`. It supports the following commands: 

- Next `($1 -> Port $FF)` = Place the next filename (null terminated) in `$2802`. The filename can be up to 255 characters long
- Select `($2 -> Port $FF)` = Reset the Channel F, and load the currently selected file
- Previous `($4 -> Port $FF)` = Place the previous filename (null terminated) in `$2802`. The filename can be up to 255 characters long
- None `($8 -> Port $FF)` = Must be sent before another Next/Previous will register. This prevents the menu changing more than once per input
	
## Text Encoding :speech_balloon:

<p align = "center">
  <img width="80%" src="https://user-images.githubusercontent.com/44975876/191890960-b8cc494c-5bce-481d-8825-5e7a8c0c16a6.png">
</p>

The menu currently supports [code page 437](https://en.wikipedia.org/wiki/Code_page_437), not UTF-8. This can cause unexpected encoding errors for non-ascii characters, depending on your operating system. I may change this in future, so only rely on the ASCII subset for now.
