from fastapi import FastAPI, File, UploadFile
from fastapi.responses import FileResponse, JSONResponse
from fastapi.middleware.cors import CORSMiddleware
import os
import shutil
from contextlib import asynccontextmanager

# Directory to store uploaded files
UPLOAD_DIRECTORY = "./uploaded_files"
os.makedirs(UPLOAD_DIRECTORY, exist_ok=True)

# Define a lifespan context manager for the app
@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    This function will be called at startup and shutdown.
    It clears the upload directory at startup.
    """
    try:
        # Clear the upload directory at the start
        for filename in os.listdir(UPLOAD_DIRECTORY):
            file_path = os.path.join(UPLOAD_DIRECTORY, filename)
            if os.path.isfile(file_path):
                os.remove(file_path)
            elif os.path.isdir(file_path):
                shutil.rmtree(file_path)  # In case there are subdirectories
        print("Upload directory cleared.")
        yield
    except Exception as e:
        print(f"Error clearing the upload directory: {str(e)}")

# Create FastAPI app with lifespan event
app = FastAPI(lifespan=lifespan)

# Allow CORS for communication with the Flutter app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    return {"message": "Welcome to the FastAPI file transfer server!"}

@app.post("/upload/")
async def upload_file(file: UploadFile = File(...)):
    """
    Endpoint to upload a file.
    """
    try:
        file_path = os.path.join(UPLOAD_DIRECTORY, file.filename)
        with open(file_path, "wb") as buffer:
            buffer.write(await file.read())
        return {"filename": file.filename, "message": "File uploaded successfully"}
    except Exception as e:
        return JSONResponse(status_code=500, content={"error": str(e)})

@app.get("/download/{filename}")
async def download_file(filename: str):
    """
    Endpoint to download a file.
    """
    file_path = os.path.join(UPLOAD_DIRECTORY, filename)
    if os.path.exists(file_path):
        return FileResponse(file_path, media_type="application/octet-stream", filename=filename)
    return JSONResponse(status_code=404, content={"error": "File not found"})

@app.get("/list-files/")
async def list_files():
    """
    Endpoint to list all uploaded files.
    """
    files = []
    try:
        files = os.listdir(UPLOAD_DIRECTORY)
        if not files:  
            return {"message": "No files are on the server."}
        return {"files": files}
    except Exception as e:
        return JSONResponse(status_code=500, content={"error": str(e)})
