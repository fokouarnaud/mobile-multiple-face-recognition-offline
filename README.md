# FlutterFace

Une application de démonstration de base pour exécuter la reconnaissance faciale localement sur votre téléphone en utilisant [Flutter](https://flutter.dev), [TensorFlow Lite](https://www.tensorflow.org/lite) et [ONNX Runtime](https://onnxruntime.ai).
Ceci est possible grâce à l'utilisation des plugins [tflite_flutter](https://pub.dev/packages/tflite_flutter) et [onnxruntime](https://pub.dev/packages/onnxruntime).

Nous utilisons [YOLOv5Face](https://arxiv.org/abs/2105.12931) pour la détection des visages et [MobileFaceNet](https://arxiv.org/abs/1804.07573) pour la création d'embeddings.

Traduit avec DeepL.com (version gratuite)


# mise a jour:

1. ANCIEN CODE  - Analyse d'images statiques :
- Objectif : Traitement d'images statiques pour la détection et l'alignement des visages
- Fonctionnalités principales :
    - Sélection d'images depuis la galerie ou d'images de stock
    - Détection des visages dans l'image
    - Alignement des visages détectés (bilinéaire et bicubique)
    - Génération d'embeddings (vecteurs caractéristiques) des visages
    - Affichage des résultats visuels avec des overlays

2. NOUVEAU CODE - Traitement vidéo en temps réel :
- Objectif : Détection et suivi des visages en temps réel via la caméra
- Fonctionnalités principales :
    - Initialisation et gestion du flux vidéo de la caméra
    - Détection continue des visages dans le flux vidéo
    - Suivi des visages détectés (face tracking)
    - Affichage en temps réel avec des overlays

## Principales différences :

1. Source des données :
```dart
// Code 1 - Image statique
final ImagePicker picker = ImagePicker();
Image? imageOriginal;

// Code 2 - Flux vidéo
CameraController? _cameraController;
```

2. Gestion des états :
```dart
// Code 1 - États pour image statique
bool isAnalyzed = false;
bool isAligned = false;
bool isEmbedded = false;

// Code 2 - États pour traitement en temps réel
bool _isProcessing = false;
bool _isCameraInitialized = false;
```

3. Traitement des visages :
```dart
// Code 1 - Traitement complet avec alignement et embedding
void alignFaceCustomInterpolation() async {
  // Alignement du visage
}

void embedFace() async {
  // Génération d'embedding
}

// Code 2 - Suivi des visages en temps réel
void _updateFaceTracking(List<FaceDetectionRelative> newDetections) {
  // Mise à jour du suivi des visages
}
```

4. Interface utilisateur :
```dart
// Code 1 - Interface avec boutons d'action
ElevatedButton.icon(
  icon: const Icon(Icons.people_alt_outlined),
  label: const Text('Detect faces'),
  onPressed: detectFaces,
)

// Code 2 - Interface en temps réel avec overlay
Stack(
  children: [
    CameraPreview(_cameraController!),
    CustomPaint(
      painter: FaceTrackingPainter(...)
    ),
  ]
)
```

## Caractéristiques uniques :

1. Ancien code :
- Gestion de différentes interpolations (bilinéaire et bicubique)
- Calcul d'embeddings pour la reconnaissance faciale
- Stockage et manipulation d'images statiques

2. Nouveau code :
- Système de suivi des visages avec IDs uniques
- Gestion de la persistance des détections
- Calcul de l'IOU (Intersection Over Union) pour le suivi
- Gestion du flux vidéo en temps réel

En résumé, bien que les deux codes traitent de la détection de visages, ils ont des cas d'utilisation très différents :
- L'ancien est optimisé pour une analyse approfondie d'images statiques avec des fonctionnalités avancées d'alignement et de reconnaissance.
- Le nouveau est conçu pour le traitement en temps réel avec un focus sur le suivi des visages dans un flux vidéo continu.

## detail nouveau code
la méthode `_convertCameraImage` qui permet de convertir l'image de la caméra dans un format utilisable par le service de détection faciale.

```dart
import 'dart:async';
import 'dart:developer' as devtools show log;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

// ... (reste du code précédent) ...

Future<Uint8List> _convertCameraImage(CameraImage image) async {
  try {
    // Pour le format BGRA8888
    if (image.format.group == ImageFormatGroup.bgra8888) {
      return _convertBGRA8888(image);
    }
    
    // Pour le format YUV420
    else if (image.format.group == ImageFormatGroup.yuv420) {
      return _convertYUV420(image);
    }
    
    throw UnimplementedError(
      'Image format ${image.format.group} not supported',
    );
  } catch (e) {
    devtools.log('Error converting camera image: $e');
    rethrow;
  }
}

Uint8List _convertBGRA8888(CameraImage image) {
  return image.planes[0].bytes;
}

Uint8List _convertYUV420(CameraImage image) {
  final imageWidth = image.width;
  final imageHeight = image.height;
  
  // Extraire les plans YUV
  final yPlane = image.planes[0].bytes;
  final uPlane = image.planes[1].bytes;
  final vPlane = image.planes[2].bytes;
  
  final yStride = image.planes[0].bytesPerRow;
  final uStride = image.planes[1].bytesPerRow;
  final vStride = image.planes[2].bytesPerRow;
  
  final yPixelStride = image.planes[0].bytesPerPixel!;
  final uPixelStride = image.planes[1].bytesPerPixel!;
  final vPixelStride = image.planes[2].bytesPerPixel!;
  
  // Créer l'image RGB résultante
  final img.Image rgbImage = img.Image(
    width: imageWidth,
    height: imageHeight,
  );
  
  // Convertir YUV en RGB
  for (int y = 0; y < imageHeight; y++) {
    for (int x = 0; x < imageWidth; x++) {
      final int yIndex = y * yStride + x * yPixelStride;
      final int uIndex = (y ~/ 2) * uStride + (x ~/ 2) * uPixelStride;
      final int vIndex = (y ~/ 2) * vStride + (x ~/ 2) * vPixelStride;
      
      int Y = yPlane[yIndex];
      int U = uPlane[uIndex];
      int V = vPlane[vIndex];
      
      // Conversion YUV vers RGB
      int R = (Y + 1.13983 * (V - 128)).round();
      int G = (Y - 0.39465 * (U - 128) - 0.58060 * (V - 128)).round();
      int B = (Y + 2.03211 * (U - 128)).round();
      
      // Limiter les valeurs entre 0 et 255
      R = math.min(math.max(R, 0), 255);
      G = math.min(math.max(G, 0), 255);
      B = math.min(math.max(B, 0), 255);
      
      // Définir la couleur du pixel
      rgbImage.setPixelRgb(x, y, R, G, B);
    }
  }
  
  // Convertir l'image en bytes
  return Uint8List.fromList(img.encodePng(rgbImage));
}

// imports et dépendances dans pubspec.yaml :
// dependencies:
//   image: ^4.0.15
//   camera: ^0.10.5

```

J'ai ajouté :

1. La méthode principale `_convertCameraImage` qui gère la conversion selon le format d'image
2. Deux méthodes de conversion spécifiques :
    - `_convertBGRA8888` pour le format BGRA8888 (plus simple)
    - `_convertYUV420` pour le format YUV420 (plus complexe mais plus courant)

3. Les dépendances nécessaires :
   ```yaml
   dependencies:
     image: ^4.0.15
     camera: ^0.10.5
   ```

4. Les imports requis en haut du fichier

Pour utiliser ce code, il faut :

1. Ajouter les dépendances dans `pubspec.yaml`
2. Exécuter `flutter pub get`
3. S'assurer que les permissions de la caméra sont configurées :

Pour Android (`android/app/src/main/AndroidManifest.xml`) :
```xml
<uses-permission android:name="android.permission.CAMERA" />
```

Pour iOS (`ios/Runner/Info.plist`) :
```xml
<key>NSCameraUsageDescription</key>
<string>Cette application nécessite l'accès à la caméra pour la détection faciale</string>
```

Vous devrez également gérer les permissions à l'exécution. Voulez-vous que j'ajoute la gestion des permissions au code ?