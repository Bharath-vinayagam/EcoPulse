import sys
import os

current_dir = os.path.dirname(os.path.abspath(__file__))
parent_dir = os.path.dirname(current_dir)
root_dir = os.path.dirname(parent_dir)
app_dir = os.path.join(parent_dir, 'app')

for d in [current_dir, parent_dir, root_dir, app_dir]:
    if os.path.exists(d) and d not in sys.path:
        sys.path.insert(0, d)

app = None
try:
    from app.main import app
except Exception:
    try:
        from backend.app.main import app
    except Exception:
        from main import app

try:
    from mangum import Mangum
    handler = Mangum(app)
except Exception:
    handler = app
