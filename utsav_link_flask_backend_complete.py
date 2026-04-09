# UtsavLink Complete Flask Backend (Starter Production Ready)

from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime, timedelta
import random

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///utsavlink.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

# ==========================
# MODELS
# ==========================

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    phone = db.Column(db.String(15), unique=True, nullable=False)
    name = db.Column(db.String(100))
    role = db.Column(db.String(20), default='customer')
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

class OTP(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    phone = db.Column(db.String(15))
    otp = db.Column(db.String(6))
    expires_at = db.Column(db.DateTime)

class Vendor(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'))
    business_name = db.Column(db.String(150))
    category = db.Column(db.String(100))
    base_price = db.Column(db.Float)

class Service(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    vendor_id = db.Column(db.Integer, db.ForeignKey('vendor.id'))
    title = db.Column(db.String(150))
    price = db.Column(db.Float)

class Booking(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer)
    vendor_id = db.Column(db.Integer)
    service_id = db.Column(db.Integer)
    event_date = db.Column(db.Date)
    status = db.Column(db.String(20), default='pending')

class Payment(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    booking_id = db.Column(db.Integer)
    amount = db.Column(db.Float)
    status = db.Column(db.String(20))

class Notification(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer)
    message = db.Column(db.String(255))
    is_read = db.Column(db.Boolean, default=False)

# ==========================
# AUTH APIs
# ==========================

@app.route('/auth/send-otp', methods=['POST'])
def send_otp():
    phone = request.json['phone']
    otp = str(random.randint(100000, 999999))
    expires = datetime.utcnow() + timedelta(minutes=5)

    db.session.add(OTP(phone=phone, otp=otp, expires_at=expires))
    db.session.commit()

    return jsonify({'message': 'OTP sent', 'otp': otp})  # remove otp in prod

@app.route('/auth/verify-otp', methods=['POST'])
def verify_otp():
    phone = request.json['phone']
    otp = request.json['otp']

    record = OTP.query.filter_by(phone=phone, otp=otp).first()

    if not record or record.expires_at < datetime.utcnow():
        return jsonify({'error': 'Invalid OTP'}), 400

    user = User.query.filter_by(phone=phone).first()

    if not user:
        user = User(phone=phone)
        db.session.add(user)
        db.session.commit()

    return jsonify({'message': 'Login successful', 'user_id': user.id})

# ==========================
# VENDOR APIs
# ==========================

@app.route('/vendors', methods=['GET'])
def get_vendors():
    vendors = Vendor.query.all()
    return jsonify([{
        'id': v.id,
        'name': v.business_name
    } for v in vendors])

@app.route('/vendors', methods=['POST'])
def create_vendor():
    data = request.json
    vendor = Vendor(**data)
    db.session.add(vendor)
    db.session.commit()
    return jsonify({'message': 'Vendor created'})

# ==========================
# BOOKING APIs
# ==========================

@app.route('/bookings', methods=['POST'])
def create_booking():
    data = request.json
    booking = Booking(**data)
    db.session.add(booking)

    # Notification trigger
    db.session.add(Notification(
        user_id=data['user_id'],
        message='Your booking is created'
    ))

    db.session.commit()
    return jsonify({'message': 'Booking created'})

@app.route('/bookings/<int:user_id>', methods=['GET'])
def get_bookings(user_id):
    bookings = Booking.query.filter_by(user_id=user_id).all()
    return jsonify([b.id for b in bookings])

# ==========================
# PAYMENT API
# ==========================

@app.route('/payments', methods=['POST'])
def make_payment():
    data = request.json

    payment = Payment(**data)
    db.session.add(payment)

    booking = Booking.query.get(data['booking_id'])
    booking.status = 'confirmed'

    db.session.add(Notification(
        user_id=booking.user_id,
        message='Payment successful & booking confirmed'
    ))

    db.session.commit()
    return jsonify({'message': 'Payment success'})

# ==========================
# NOTIFICATIONS
# ==========================

@app.route('/notifications/<int:user_id>', methods=['GET'])
def get_notifications(user_id):
    notes = Notification.query.filter_by(user_id=user_id).all()
    return jsonify([n.message for n in notes])

# ==========================
# RUN
# ==========================

if __name__ == '__main__':
    db.create_all()
    app.run(debug=True)

# ==========================
# REAL-TIME (IMPORTANT)
# ==========================
# Install: pip install flask-socketio

# from flask_socketio import SocketIO, emit
# socketio = SocketIO(app, cors_allowed_origins="*")

# @socketio.on('connect')
# def connect():
#     print('User connected')

# def send_realtime_notification(user_id, message):
#     socketio.emit('notification', {
#         'user_id': user_id,
#         'message': message
#     })

# Then call this function after booking/payment
