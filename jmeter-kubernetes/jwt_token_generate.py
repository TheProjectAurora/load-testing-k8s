from flask import Flask
from flask_jwt_extended import create_access_token, decode_token, JWTManager
from jwt import ExpiredSignatureError, InvalidSignatureError
from datetime import timedelta
import os


def generate_token(jwt_secret):
    def validate_token(_token):
        try:
            tok = decode_token(encoded_token=_token, allow_expired=True)
        except (ExpiredSignatureError, InvalidSignatureError) as e:
            print("Saved token is invalid")
            return None
        return tok

    flask_app = Flask(__name__)
    flask_app.config['JWT_SECRET_KEY'] = jwt_secret
    jwt_manager = JWTManager(flask_app)

    with flask_app.app_context():
        token = create_access_token(identity="figure1-firebase",
                                    expires_delta=timedelta(seconds=3200))
        if validate_token(_token=token):
            print("Token validated")
            # This generates what swagger expects for validation
            # resp = jsonify({"token": token})
            # resp.headers.extend({'jwt-token': token})
            # return resp
            # This returns the expected header
            header = {"Authorization": "Bearer " + token}
            print(header)
            return token

jwt_secret = os.popen("""kubectl get secret figure1-app-secret -o yaml | grep -o "^  JWT_SECRET_KEY:.*" | cut -d " " -f 4 | base64 -d""").read()
token = generate_token(jwt_secret)
print(token)

## For Jmeter:
#vars.put("token", str(token))