Setup

python -m venv RoboCallerVenv
source RoboCallerVenv/bin/activate  
pip install -r requirements.txt

Start the app

To start the app, run the following command:

```bash
uvicorn app.main:app --reload
```

Look at documentation by visiting http://127.0.0.1:8000/docs
