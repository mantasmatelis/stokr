from flask import Flask
from flask import request
import subprocess
 
app = Flask(__name__)
 
@app.route("/start", methods=['GET', 'POST'])
def start():
    user = request.form['SteamUser']
    password = request.form['SteamPassword']
 
    uf = open("user.txt", "w")
    uf.write(user)
    uf.close()
 
    pf = open("pass.txt", "w")
    pf.write(password)
    pf.close()
 
    subprocess.call(['C:\\Program Files\\AutoHotkey\\AutoHotkey.exe', 'Steam.ahk'])
 
    return "OK"
 
   
 
if __name__ == "__main__":
    app.run(host='0.0.0.0', port=80)
