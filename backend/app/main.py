from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from . import models, schemas, auth, database

# Crea las tablas en la base de datos (SQLite)
models.Base.metadata.create_all(bind=database.engine)

app = FastAPI(
    title="SMAT API - Sistema de Monitoreo Ambiental",
    description="Backend para el Laboratorio 5 - Conexión Flutter",
    version="1.1.0"
)

# CONFIGURACIÓN DE CORS (Habilita la comunicación con Flutter Web/Mobile)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/", tags=["General"])
def read_root():
    return {"message": "API SMAT conectada exitosamente", "status": "Ready"}

@app.post("/token", tags=["Seguridad"])
def login(datos: dict):
    # VALIDACIÓN REAL: Si no es admin/admin123, rebota la petición
    username = datos.get("username")
    password = datos.get("password")
    
    if username == "admin" and password == "admin123":
        token = auth.crear_token({"sub": username})
        return {"access_token": token, "token_type": "bearer"}
    else:
        # Si los datos están mal, lanza error 401
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, 
            detail="Usuario o contraseña incorrectos"
        )

@app.get("/estaciones/", response_model=list[schemas.Estacion], tags=["SMAT"])
def listar_estaciones(db: Session = Depends(database.get_db)):
    return db.query(models.EstacionDB).all()

@app.post("/estaciones/", response_model=schemas.Estacion, tags=["SMAT"], status_code=status.HTTP_201_CREATED)
def crear_estacion(
    estacion: schemas.EstacionCreate, 
    db: Session = Depends(database.get_db), 
    user=Depends(auth.validar_token)
):
    nueva = models.EstacionDB(**estacion.model_dump())
    db.add(nueva)
    db.commit()
    db.refresh(nueva) # Esto actualiza el objeto 'nueva' con el ID de la base de datos
    return nueva

@app.post("/lecturas/", tags=["Telemetría"], status_code=status.HTTP_201_CREATED)
def registrar_lectura(
    lectura: schemas.LecturaCreate, 
    db: Session = Depends(database.get_db), 
    user=Depends(auth.validar_token)
):
    # Validación de existencia de la estación
    estacion = db.query(models.EstacionDB).filter(models.EstacionDB.id == lectura.estacion_id).first()
    if not estacion:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, 
            detail=f"Error: La estación con ID {lectura.estacion_id} no existe."
        )
    
    nueva_lectura = models.LecturaDB(**lectura.model_dump())
    db.add(nueva_lectura)
    db.commit()
    return {"status": "Lectura registrada con éxito", "estacion": estacion.nombre}