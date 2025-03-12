# Flutter File Transfer App with FastAPI Backend

## 📌 Overview

A mobile app that allows users to upload, download, and manage files between their mobile device and laptop using Flutter for the mobile client and FastAPI for the backend server.

With this app, users can:

- Upload files from their mobile device to a server.
- Download files from the server back to their device.
- Delete files from the server.
- List all the files currently stored on the server.

## 🚀 Features

- **Upload Files**: Upload files from your mobile device to the server.
- **Download Files**: Download previously uploaded files from the server to your device.
- **Delete Files**: Delete specific files from the server.
- **List Files**: View all the files that are stored on the server.

## 🏗️ Tech Stack

- **Flutter**: For building the mobile app (Android & iOS).
- **FastAPI**: A fast and modern web framework for building APIs with Python.

## 📱 Prerequisites

Before getting started, ensure you have the following installed:

- Flutter SDK (for mobile app development)
- Python 3.7+ (for running the FastAPI server)
- A mobile device or emulator for testing the Flutter app

## 🛠️ Setup

### Backend (FastAPI)

1. Clone this repository:

```sh
   git clone https://github.com/OmarAtef0/Flutter-File-Transfer-App-with-FastAPI-Backend.git
   cd Flutter-File-Transfer-App-with-FastAPI-Backend
```

2. Create a virtual environment and activate it:

```sh
   python3 -m venv env
   source env/bin/activate # On Windows use `env\Scripts\activate`
```

3. Install the required dependencies:

```sh
   pip install -r requirements.txt
```

4. Run the FastAPI server:

```sh
   uvicorn main:app --reload
```

By default, the server will run on `http://127.0.0.1:8000`.

### Mobile App (Flutter)

1. Install Flutter dependencies:

```sh
   flutter pub get
```

2. Set up the backend API URL in the Flutter app. Edit the `lib/constants.dart` file and replace `http://127.0.0.1:8000` with your FastAPI server URL if necessary.

3. Run the Flutter app on an emulator or physical device:

```sh
   flutter run
```

## API Endpoints

The FastAPI server provides the following endpoints:

- **POST /upload**: Upload a file to the server.
- **GET /list-files**: Get a list of all files stored on the server.
- **GET /download/{filename}**: Download a specific file.
- **DELETE /delete/{filename}**: Delete a specific file from the server.

## 📜 License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

