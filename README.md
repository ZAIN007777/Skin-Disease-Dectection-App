# 🛡️ SkinGuardian – AI-Powered Skin Disease Detection & Skincare App

**SkinGuardian** is an intelligent Android mobile application that uses AI to detect skin conditions, track treatment progress, and provide personalized skincare recommendations. It combines image analysis, chatbot support, and progress tracking into one user-friendly platform.


## 📲 Features

- 🔬 **AI-Powered Skin Disease Detection**  
  Upload an image and get an instant prediction using a deep learning model.

- 💬 **Skincare Chatbot**  
  Built using Retrieval-Augmented Generation (RAG) with SentenceTransformers and FAISS, trained on 1500+ skincare QA pairs.

- 📈 **Treatment Progress Tracking**  
  Visualize and log your recovery journey with time-stamped photo records.

- ⏰ **Medication Reminders**  
  Set reminders to stay on track with your skincare routine.

- 💡 **Proactive Skincare Insights**  
  Daily personalized tips and recommendations based on your skin profile.

- 🔐 **Admin Panel**  
  Secure access for administrators to manage users and app data.


## 🛠️ Tech Stack

- **Frontend:** Flutter (Dart)
- **Backend:** Flask (Python)
- **AI Model:** Convolutional Neural Network (CNN)
- **Chatbot:** SentenceTransformers + FAISS
- **Database:** Firebase Firestore
- **Authentication & Storage:** Firebase Auth & Firebase Storage
- **IDE Tools:** Android Studio, PyCharm


## 📁 Project Structure

```

SkinGuardian/
│
├── lib/                     # Flutter frontend
│   ├── screens/             # UI pages
│   ├── services/            # API integration
│   └── main.dart            # App entry point
│
├── backend/                 # Flask backend
│   ├── app.py               # Flask routes
│   ├── model/               # AI model files
│   └── chatbot/             # RAG chatbot code and data
│
├── assets/                  # Images and icons
├── android/                 # Android-specific project files
├── requirements.txt         # Python dependencies
└── README.md                # Project documentation

````


## 🚀 Getting Started

### Prerequisites

- Flutter SDK
- Android Studio
- Python 3.8+
- Firebase account and project

### Flutter App Setup

```bash
git clone https://github.com/yourusername/SkinGuardian.git
cd SkinGuardian
flutter pub get
flutter run
````

### Flask Backend Setup

```bash
cd backend
pip install -r requirements.txt
python app.py
```

> Make sure to update your API base URL in the Flutter code (`lib/services/api_service.dart`) if needed.


## 🧠 AI & Chatbot Details

* **Skin Detection Model**: Trained CNN model capable of identifying various skin conditions like acne, eczema, etc.
* **Chatbot**: RAG-based chatbot using SentenceTransformers and FAISS, capable of handling in-distribution and out-of-distribution queries.
* **Evaluation Metrics**: BERTScore and ROUGE used to evaluate chatbot quality.


## 📄 License

This project is licensed under the **MIT License**.


