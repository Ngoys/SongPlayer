# SongPlayer, by [Shawn Ngo Yen Sern](https://www.linkedin.com/in/ngo-yensern/?originalSubdomain=my)

<img width="450" alt="Screenshot 2023-05-08 at 10 05 15 PM" src="https://user-images.githubusercontent.com/6831096/236845248-b7e8fdeb-625f-4d66-8db6-7cbe2e9e74d6.png">

### UML Class Diagram, generated by [PlantText UML](https://www.planttext.com/)
![PlantUMLDiagram](https://github.com/Ngoys/SongPlayer/assets/6831096/344958b5-c9f4-406e-9a5c-636dc2866497)

### Installation

1. Clone the repo 
2. Open `SongPlayer.xcodeproj` using `Xcode`, with minimum iOS version of 13.0
3. You should be on `main` branch

### Feature 

1. Can download songs and play simultaneously
2. Song info and downloaded audio file will persistent even if user kill the app.
3. The app will prompt alert dialog if user try to download in offline. [screenshot](https://github.com/Ngoys/SongPlayer/assets/6831096/40fdf565-736e-48e1-a566-0a35ccb12660)
4. SongView’s state are **never lost** when the list is scrolled up and down
5. If the audio is finished, the play button will play the same song from the start 
6. SongView's play/pause button will be automatically updated if there is any new downloads triggered by other view models. [screenshot](https://github.com/Ngoys/SongPlayer/assets/6831096/1472be1a-6335-4268-9c5e-5f416f8ff193)
7. For unit test, start the testing with `CMD+U`
