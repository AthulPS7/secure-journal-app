from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_bcrypt import Bcrypt
from functools import wraps
import jwt
import datetime
import os

app = Flask(__name__)
app.config["SECRET_KEY"] = "supersecretkey"

DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")
DB_NAME = os.getenv("DB_NAME")

app.config["SQLALCHEMY_DATABASE_URI"] = (
    f"mysql+pymysql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
)
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

db = SQLAlchemy(app)
bcrypt = Bcrypt(app)


class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(100), unique=True, nullable=False)
    password = db.Column(db.String(255), nullable=False)


class JournalEntry(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(200), nullable=False)
    content = db.Column(db.Text, nullable=False)
    user_id = db.Column(db.Integer, db.ForeignKey("user.id"), nullable=False)


def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = None

        if "Authorization" in request.headers:
            token = request.headers["Authorization"]

        if not token:
            return {"error": "Token is missing"}, 401

        try:
            data = jwt.decode(
                token,
                app.config["SECRET_KEY"],
                algorithms=["HS256"]
            )

            current_user = User.query.filter_by(
                username=data["user"]
            ).first()

            if not current_user:
                return {"error": "User not found"}, 401

        except Exception:
            return {"error": "Invalid token"}, 401

        return f(current_user, *args, **kwargs)

    return decorated


@app.route("/")
def home():
    return "Secure Journal App Running Successfully!"


@app.route("/health")
def health():
    return {"status": "healthy"}


@app.route("/init-db")
def init_db():
    try:
        db.create_all()
        return {"message": "Database tables created successfully"}
    except Exception as e:
        return {"error": str(e)}


@app.route("/register", methods=["POST"])
def register():
    data = request.json

    existing_user = User.query.filter_by(username=data["username"]).first()
    if existing_user:
        return {"error": "Username already exists"}, 409

    hashed_password = bcrypt.generate_password_hash(
        data["password"]
    ).decode("utf-8")

    user = User(
        username=data["username"],
        password=hashed_password
    )

    db.session.add(user)
    db.session.commit()

    return {"message": "User registered successfully"}


@app.route("/login", methods=["POST"])
def login():
    data = request.json

    user = User.query.filter_by(
        username=data["username"]
    ).first()

    if not user:
        return {"error": "Invalid username"}, 401

    if not bcrypt.check_password_hash(user.password, data["password"]):
        return {"error": "Invalid password"}, 401

    token = jwt.encode(
        {
            "user": user.username,
            "exp": datetime.datetime.utcnow() + datetime.timedelta(hours=1)
        },
        app.config["SECRET_KEY"],
        algorithm="HS256"
    )

    return {"token": token}


@app.route("/entries", methods=["POST"])
@token_required
def create_entry(current_user):
    data = request.json

    entry = JournalEntry(
        title=data["title"],
        content=data["content"],
        user_id=current_user.id
    )

    db.session.add(entry)
    db.session.commit()

    return {"message": "Journal entry created"}


@app.route("/entries", methods=["GET"])
@token_required
def get_entries(current_user):
    entries = JournalEntry.query.filter_by(
        user_id=current_user.id
    ).all()

    output = []

    for entry in entries:
        output.append({
            "id": entry.id,
            "title": entry.title,
            "content": entry.content
        })

    return jsonify(output)


@app.route("/entries/<int:id>", methods=["PUT"])
@token_required
def update_entry(current_user, id):
    entry = JournalEntry.query.filter_by(
        id=id,
        user_id=current_user.id
    ).first()

    if not entry:
        return {"error": "Entry not found"}, 404

    data = request.json

    entry.title = data["title"]
    entry.content = data["content"]

    db.session.commit()

    return {"message": "Entry updated successfully"}


@app.route("/entries/<int:id>", methods=["DELETE"])
@token_required
def delete_entry(current_user, id):
    entry = JournalEntry.query.filter_by(
        id=id,
        user_id=current_user.id
    ).first()

    if not entry:
        return {"error": "Entry not found"}, 404

    db.session.delete(entry)
    db.session.commit()

    return {"message": "Entry deleted successfully"}


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
