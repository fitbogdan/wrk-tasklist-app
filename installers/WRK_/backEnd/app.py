from flask import Flask, jsonify, request
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)

app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///database.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

class Counter(db.Model):
    id = db.Column(db.Integer, primary_key = True)
    value = db.Column(db.Integer, nullable = False, default = 0)




@app.route('/', methods = ['GET'])
def greetings():
    return jsonify({'greetings' : 'Hi this is python'})


@app.route('/data', methods = ['POST'])
def save():
    global counter_value
    data = request.get_json()
    counter_value = data.get("counter", 0)

    return jsonify({'message': 'Counter Saved!', 'counter': counter_value})


if __name__ == "__main__":
    app.run(debug = True)