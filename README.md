# FlutterFace

Une application de démonstration de base pour exécuter la reconnaissance faciale localement sur votre téléphone en utilisant [Flutter](https://flutter.dev), [TensorFlow Lite](https://www.tensorflow.org/lite) et [ONNX Runtime](https://onnxruntime.ai).
Ceci est possible grâce à l'utilisation des plugins [tflite_flutter](https://pub.dev/packages/tflite_flutter) et [onnxruntime](https://pub.dev/packages/onnxruntime).

Nous utilisons [YOLOv5Face](https://arxiv.org/abs/2105.12931) pour la détection des visages et [MobileFaceNet](https://arxiv.org/abs/1804.07573) pour la création d'embeddings.

