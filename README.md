# meld-veilig-mobile

Laagdrempelig mobiele applicatie voor het melden van onveilige verkeerssituaties.

- **Framework**: Flutter
- **Database**: Firebase
- **Kaartfunctionaliteit**: MapBox

## Project opstellen vanuit source code (in Android Studio)
1. Indien Android Studio nog niet geinstalleerd is, installeer deze.
2. Zorg ervoor dat de plug-ins "Dart" en "Flutter" voor Android Studio geinstalleerd zijn.
3. Clone deze repository in een nieuw mapje.
4. Open de root directory in Android Studio. Maak gebruik van de Android/iOS simulators om de functionaliteit van de app te testen.
5. Voeg alle API keys handmatig toe! Dit wordt in de volgende onderdeel uitgelegd.

## API keys toevoegen
Zowel Firebase als MapBox hebben geldige API keys nodig om te functioneren. Deze horen handmatig toegevoegd te worden na het clonen van de repository indien je via Android Studio of een andere IDE gebruik wilt maken van de source code.
Om dit te doen in Android Studio:
1. Zorg ervoor dat je de Flutter en Dart plugins heb geinstalleerd. (Android Studio > Preferences > Plugins)
2. Voor Hart Voor Verkeer: zet het apart geleverde .env (Environment Variables) bestand in hetzelfde map als main.dart. Stuur een van de contributors van deze repo een bericht  Mits je gebruik wilt maken van je eigen API keys, maak een bestand genaamd ".env" in het projectmap aan en plak het volgende er in:
    ```
    MAPBOX_ACCESS_TOKEN =
    FIREBASE_WEB_TOKEN =
    FIREBASE_ANDROID_TOKEN =
    FIREBASE_IOS_TOKEN =
    FIREBASE_MACOS_TOKEN =
    FIREBASE_WINDOWS_TOKEN =
    ```
    Voeg bij elke regel een geldige API-key toe die daarbij hoort (bijv. MapBox API key bij MAPBOX_ACCESS_TOKEN)
3. 

## Projectarchitectuur
# 
