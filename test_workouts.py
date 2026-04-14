from fastapi.testclient import TestClient
from main import app
from database import SessionLocal
from auth.utils import create_access_token
from models.user import User
from models.workout import Workout

db = SessionLocal()
user = db.query(User).first()
if not user:
    user = User(email="test@test.com", full_name="Test", hashed_password="pw")
    db.add(user)
    db.commit()
    db.refresh(user)

workout = db.query(Workout).first()
if not workout:
    workout = Workout(user_id=user.id, date="2026-03-18", duration_seconds=3600, name="Test Workout")
    db.add(workout)
    db.commit()

client = TestClient(app)
token = create_access_token({"sub": str(user.id)})
resp = client.get("/workouts/", headers={"Authorization": f"Bearer {token}"})
print(resp.json())
