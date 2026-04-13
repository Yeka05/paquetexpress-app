from fastapi import FastAPI, UploadFile, File, Form, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from pydantic import BaseModel
from datetime import datetime, timedelta
from typing import List
from sqlalchemy import create_engine, Column, Integer, String, DateTime, Boolean, ForeignKey, DECIMAL
from sqlalchemy.orm import sessionmaker, declarative_base
from jose import jwt
from passlib.context import CryptContext
import shutil
import os

# =========================
# CONFIGURACIÓN
# =========================

DATABASE_URL = "mysql+mysqlconnector://root:31052004@localhost/paquetexpress_db"

SECRET_KEY = "mi_clave_secreta"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(bind=engine)
Base = declarative_base()

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
security = HTTPBearer()

os.makedirs("uploads", exist_ok=True)

# =========================
# APP
# =========================

app = FastAPI(title="API PAQUETEXPRESS")

app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# =========================
# SEGURIDAD
# =========================

def hash_password(password: str):
    return pwd_context.hash(password)

def verify_password(plain, hashed):
    return pwd_context.verify(plain, hashed)

def crear_token(data: dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

def obtener_usuario_actual(credentials: HTTPAuthorizationCredentials = Depends(security)):
    token = credentials.credentials
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id = int(payload.get("sub"))
    except:
        raise HTTPException(status_code=401, detail="Token inválido")

    db = SessionLocal()
    user = db.query(Agentes).filter(Agentes.id_agente == user_id).first()
    db.close()

    if not user:
        raise HTTPException(status_code=401, detail="Usuario no válido")

    return user

# =========================
# MODELOS
# =========================

class Agentes(Base):
    __tablename__ = "agentes"
    id_agente = Column(Integer, primary_key=True, index=True)
    nombre = Column(String(100))
    email = Column(String(100), unique=True)
    password = Column(String(255))
    telefono = Column(String(20))
    activo = Column(Boolean, default=True)
    fecha_de_alta = Column(DateTime, default=datetime.now)

class Paquetes(Base):
    __tablename__ = "paquetes"
    id_paquete = Column(Integer, primary_key=True, index=True)
    codigo = Column(String(50), unique=True)
    direccion = Column(String(255))
    ciudad = Column(String(100))
    estado = Column(String(100))
    codigo_postal = Column(String(10))
    destinatario = Column(String(100))
    telefono_destinatario = Column(String(20))
    estatus = Column(String(50), default="pendiente")
    fecha_de_alta = Column(DateTime, default=datetime.utcnow)

class Entregas(Base):
    __tablename__ = "entregas"
    id_entrega = Column(Integer, primary_key=True, index=True)
    id_paquete = Column(Integer, ForeignKey("paquetes.id_paquete"))
    id_agente = Column(Integer, ForeignKey("agentes.id_agente"))
    fecha_de_entrega = Column(DateTime, default=datetime.utcnow)
    foto_url = Column(String(255))
    latitud = Column(DECIMAL(10,8))
    longitud = Column(DECIMAL(11,8))
    estado = Column(String(50))
    comentario = Column(String(255))

Base.metadata.create_all(bind=engine)


# =========================
# SCHEMAS
# =========================

class AgenteSchema(BaseModel):
    nombre: str
    email: str
    password: str
    telefono: str
    activo: bool = True

class AgenteOut(BaseModel):
    id_agente: int
    nombre: str
    email: str
    telefono: str
    activo: bool
    class Config:
        from_attributes = True

class LoginSchema(BaseModel):
    email: str
    password: str

class PaqueteSchema(BaseModel):
    codigo: str
    direccion: str
    ciudad: str
    estado: str
    codigo_postal: str
    destinatario: str
    telefono_destinatario: str

class PaqueteOut(PaqueteSchema):
    id_paquete: int
    estatus: str
    class Config:
        from_attributes = True

class EntregaOut(BaseModel):
    id_entrega: int
    id_paquete: int
    id_agente: int
    foto_url: str
    latitud: float
    longitud: float
    estado: str
    class Config:
        from_attributes = True

# =========================
# AGENTES
# =========================

@app.post("/agentes/", response_model=AgenteOut, tags=["Agentes"])
def crear_agente(datos: AgenteSchema):
    db = SessionLocal()

    datos.password = hash_password(datos.password)

    data = datos.dict()
    data["activo"] = 1 if data["activo"] else 0

    nuevo = Agentes(**datos.dict())
    db.add(nuevo)
    db.commit()
    db.refresh(nuevo)
    db.close()
    return nuevo

@app.get("/agentes/", response_model=List[AgenteOut], tags=["Agentes"])
def listar_agentes():
    db = SessionLocal()
    datos = db.query(Agentes).all()
    db.close()
    return datos

# =========================
# LOGIN
# =========================

@app.post("/login", tags=["Login"])
def login(datos: LoginSchema):
    db = SessionLocal()
    try:
        user = db.query(Agentes).filter(Agentes.email == datos.email).first()

        if not user or not verify_password(datos.password, user.password):
            raise HTTPException(status_code=401, detail="Credenciales incorrectas")

        token = crear_token({"sub": str(user.id_agente)})

        return {
            "access_token": token,
            "token_type": "bearer",
            "id_agente": user.id_agente,
            "nombre": user.nombre
        }
    finally:
        db.close()

# =========================
# PAQUETES
# =========================

@app.post("/paquetes/", response_model=PaqueteOut, tags=["Paquetes"])
def crear_paquete(datos: PaqueteSchema):
    db = SessionLocal()
    nuevo = Paquetes(**datos.dict())
    db.add(nuevo)
    db.commit()
    db.refresh(nuevo)
    db.close()
    return nuevo

@app.get("/paquetes/", response_model=List[PaqueteOut], tags=["Paquetes"])
def listar_paquetes(usuario=Depends(obtener_usuario_actual)):
    db = SessionLocal()
    datos = db.query(Paquetes).all()
    db.close()
    return datos

@app.get("/paquetes/{id}", response_model=PaqueteOut, tags=["Paquetes"])
def obtener_paquete(id: int, usuario=Depends(obtener_usuario_actual)):
    db = SessionLocal()
    paquete = db.query(Paquetes).filter(Paquetes.id_paquete == id).first()
    db.close()
    if not paquete:
        raise HTTPException(status_code=404, detail="Paquete no encontrado")
    return paquete

# =========================
# ENTREGAS
# =========================

@app.post("/entregas/", tags=["Entregas"])
async def nueva_entrega(
    usuario = Depends(obtener_usuario_actual),
    id_paquete: int = Form(...),
    latitud: float = Form(...),
    longitud: float = Form(...),
    estado: str = Form(...),
    comentario: str = Form(None),
    imagen: UploadFile = File(...)
):
    db = SessionLocal()

    try:
        # validar paquete
        paquete = db.query(Paquetes).filter(Paquetes.id_paquete == id_paquete).first()
        if not paquete:
            raise HTTPException(status_code=404, detail="Paquete no existe")

        # validar entrega duplicada
        existe = db.query(Entregas).filter(Entregas.id_paquete == id_paquete).first()
        if existe:
            raise HTTPException(status_code=400, detail="Este paquete ya fue entregado")

        # guardar imagen con nombre único
        nombre_archivo = f"{datetime.now().timestamp()}_{imagen.filename}"
        ruta = f"uploads/{nombre_archivo}"

        with open(ruta, "wb") as buffer:
            shutil.copyfileobj(imagen.file, buffer)

        nueva = Entregas(
            id_paquete=id_paquete,
            id_agente=usuario.id_agente,
            foto_url=ruta,
            latitud=latitud,
            longitud=longitud,
            estado=estado,
            comentario=comentario
        )

        db.add(nueva)

        # actualizar estado paquete
        paquete.estatus = estado

        db.commit()
        db.refresh(nueva)

        return {
            "msg": "Entrega registrada correctamente",
            "id_entrega": nueva.id_entrega
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

    finally:
        db.close()

@app.get("/entregas/", response_model=List[EntregaOut], tags=["Entregas"])
def listar_entregas(usuario=Depends(obtener_usuario_actual)):
    db = SessionLocal()
    datos = db.query(Entregas).all()
    db.close()
    return datos

@app.get("/entregas/{id}/ubicacion")
def obtener_ubicacion_del_paquete(id: int):
    db = SessionLocal()
    entrega = db.query(Entregas).filter(Entregas.id_entrega == id).first()
    db.close()

    if not entrega:
        raise HTTPException(status_code=404, detail="Entrega no encontrada")

    return {
        "latitud": entrega.latitud,
        "longitud": entrega.longitud
    }