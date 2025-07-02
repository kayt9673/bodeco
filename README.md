# bodeco 

An application that helps users explore the sustainability of fashion products. Users can search for clothing items and receive sustainability scores based on the material composition. 

## Project Structure 

``` 
bodeco/
├── backend/
│   ├── main.py
│   ├── search.py
│   ├── scrape.py
│   ├── requirements.txt
│   └── .env
│
├── frontend/
│   ├── android/
│   ├── build/
│   ├── ios/
│   ├── lib/
│   │   ├── main.dart
│   │   └── api_service.dart
│   ├── linux/
│   ├── macos/
│   ├── test/
│   ├── web/
│   ├── windows/
│   ├── pubspec.yaml
│   ├── pubspec.lock
│   ├── .gitignore
│   └── analysis_options.yaml
│
├── README.md 
```

## Backend Setup

### 1. Clone the repository

```bash
git clone https://github.com/kayt9673/bodeco.git
cd bodeco/backend
```

### 2. Create and activate a virtual environment

**Mac/Linux:**

```bash
python3 -m venv venv
source venv/bin/activate
```

**Windows (PowerShell):**

```bash
python -m venv venv
venv\Scripts\activate
```

### 3. Install dependencies

```bash
pip install -r requirements.txt
```

### 4. Create a `.env` file

In the `backend/` folder, create a file called `.env` and add the API information. 

### 5. Run the backend server

```bash
uvicorn main:app --reload
```

You can now access the backend at:

```
http://127.0.0.1:8000/search?query=insert+query+here
```
