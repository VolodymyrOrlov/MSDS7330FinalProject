import flask
from flask import request, jsonify

app = flask.Flask(__name__)
app.config['DEBUG'] = True


@app.route('/', methods=['GET'])
def home():
    return '''<h1>MSDS7330. Final Project</h1>'''


@app.route('/api/v1/test-endpoint', methods=['POST'])
def api_all():

    try:

        user_id = 0

        if 'id' in request.args:
                user_id = request.args['id']
        else:
            return 'Error: No user ID is provided. Please send it along with your request.'

        result_json = {
            'user-id': user_id
        }
        return jsonify(result_json)

    except:
        return 'We are experiencing temporary issue. Please try again later.', 500

app.run(host='192.168.1.68')