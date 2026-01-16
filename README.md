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
### Technische Stack
- **Frontend Framework**: Flutter (Dart)
- **Backend/Database**: Firebase (Firestore, Authentication, Storage)
- **Kaartfunctionaliteit**: MapBox Maps SDK
- **Development Environment**: Android Studio (ook geschikt voor iOS development dankzij Flutter)

### Projectstructuur
```
├── .env                               # Environment variabelen (API keys)
├── pubspec.yaml                       # Flutter project configuratie en dependencies
├── lib/
│   ├── main.dart                          # Entry point van de applicatie
│   ├── firebase_options.dart              # Firebase configuratie
│   ├── models/                            # Data modellen
│   │   └── melding_model.dart            # Model voor verkeersmeldingen
│   ├── screens/                           # UI schermen
│   │   ├── start_screen.dart             # Startscherm van de app
│   │   ├── loading_screen.dart           # Laadscherm
│   │   ├── home_screen.dart              # Hoofdscherm met kaart
│   │   ├── home_screen_tutorial.dart     # Tutorial voor nieuwe gebruikers
│   │   ├── account_aanmaken_screen.dart  # Account aanmaak scherm
│   │   ├── account_gemaakt_screen.dart   # Bevestiging na account aanmaken
│   │   ├── profiel_screen.dart           # Gebruikersprofiel
│   │   ├── inbox_screen.dart             # Inbox voor berichten/notificaties
│   │   ├── pinned_locations_screen.dart  # Overzicht van gepinde locaties
│   │   ├── over_ons_screen.dart          # Informatie over de app/organisatie
│   │   ├── privacy_screen.dart           # Privacy beleid
│   │   └── meldingen/                    # Meldingen-specifieke schermen
│   │       ├── melding_maken_screen.dart # Scherm voor nieuwe melding
│   │       └── mijn_meldingen_screen.dart # Overzicht eigen meldingen
│   ├── widgets/                           # Herbruikbare UI componenten
│   │   └── meldingen/                    # Melding-specifieke widgets
│   │       ├── melding_card.dart         # Kaart voor meldingweergave
│   │       ├── category_selector.dart    # Widget voor categorie selectie
│   │       └── photo_picker_widget.dart  # Widget voor foto's toevoegen
│   ├── services/                          # Business logic & externe services
│   │   ├── firebase_service.dart         # Firebase operaties
│   │   ├── melding_service.dart          # Service voor meldingen beheer
│   │   ├── storage_service.dart          # Service voor afbeeldingen opslag
│   │   └── pin_service.dart              # Service voor gepinde locaties
│   └── listeners/                         # Event listeners
│       └── melding_click_listener.dart   # Luistert naar melding interacties
└── assets/
    ├── images/                            # Afbeeldingen en iconen
    └── fonts/                             # Custom fonts (indien gebruikt)
```

### Firebase Database Structuur
```
Firestore Collections:
├── meldingen/
│   └── {meldingId}
│       ├── title: string
│       ├── description: string
│       ├── location: geopoint
│       ├── category: string
│       ├── timestamp: timestamp
│       ├── userId: string
│       ├── imageUrls: array
│       └── status: string
└── users/ (optioneel)
    └── {userId}
        ├── name: string
        ├── email: string
        └── meldingenCount: number

Storage:
└── melding_images/
    └── {meldingId}/
        ├── image1.jpg
        └── image2.jpg
```

### Security & Permissions
#### Android (`AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.CAMERA"/>
```

#### iOS (`Info.plist`)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Deze app heeft toegang tot je locatie nodig om meldingen te plaatsen</string>
<key>NSCameraUsageDescription</key>
<string>Deze app heeft toegang tot je camera nodig om foto's van verkeerssituaties te maken</string>
```
