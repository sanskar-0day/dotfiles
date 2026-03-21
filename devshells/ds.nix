# =============================================================================
#  ds.nix — IITM BS Data Science | MAD 1 (Modern Application Development I)
#  Course: BSCS2003 | Stack: Python · Flask · SQLite · Jinja2 · JS · Vue · REST
# =============================================================================

{ pkgs ? import <nixpkgs> { } }:

let

  # ---------------------------------------------------------------------------
  #  Python environment — pip-managed packages pulled into Nix cleanly
  # ---------------------------------------------------------------------------
  pythonEnv = pkgs.python3.withPackages (ps: with ps; [

    # ── Core Web Framework ────────────────────────────────────────────────────
    flask                   # The backbone of every MAD 1 project
    flask-sqlalchemy        # ORM integration (Week 11-13)
    flask-restful           # REST API building (Week 16)
    flask-login             # Session-based authentication
    flask-wtf               # Web forms + CSRF protection
    flask-migrate           # DB migrations via Alembic (Week 25)
    flask-cors              # CORS headers for Vue ↔ Flask API
    flask-caching           # Response caching layer

    # ── Security & Auth ───────────────────────────────────────────────────────
    flask-security          # RBAC, roles, token auth (Week 23)
    werkzeug                # WSGI utilities, password hashing
    pyjwt                   # JSON Web Tokens for stateless auth
    cryptography            # Underlying crypto primitives
    passlib                 # Password hashing helpers (bcrypt, argon2)
    bcrypt                  # bcrypt hashing backend

    # ── Database & ORM ────────────────────────────────────────────────────────
    sqlalchemy              # Core ORM + query engine
    alembic                 # Schema migrations (used by flask-migrate)
    marshmallow             # Serialization / deserialization / validation
    marshmallow-sqlalchemy  # Auto-generate schemas from SQLAlchemy models

    # ── Async Jobs & Message Queue ────────────────────────────────────────────
    celery                  # Distributed task queue (MAD 1 project use)
    redis                   # Redis client for Celery broker + caching

    # ── API Development & Testing ─────────────────────────────────────────────
    requests                # HTTP client for external API calls
    httpx                   # Modern async HTTP client
    openapi-spec-validator  # Validate your OpenAPI / Swagger specs

    # ── Templating & Frontend Helpers ─────────────────────────────────────────
    jinja2                  # Template engine (built into Flask, explicit here)
    markupsafe              # Safe HTML escaping used by Jinja2
    bleach                  # Sanitize user-submitted HTML

    # ── Testing Suite ─────────────────────────────────────────────────────────
    pytest                  # Unit + functional testing framework (Week 24)
    pytest-flask            # Flask-specific pytest fixtures
    coverage                # Code coverage measurement
    factory-boy             # Test data factories / fixtures

    # ── Data Handling & Utilities ─────────────────────────────────────────────
    pydantic                # Data validation with type hints
    python-dotenv           # Load .env files into os.environ
    click                   # CLI tooling (Flask uses this internally)
    rich                    # Beautiful terminal output / logging
    tabulate                # Pretty-print tables in terminal
    python-dateutil         # Date parsing utilities
    pytz                    # Timezone handling

    # ── Reporting & Export (MAD 1 Project) ───────────────────────────────────
    reportlab               # Generate PDF reports
    weasyprint              # HTML → PDF conversion
    openpyxl                # Read/write Excel files

    # ── Dev & Code Quality Tools ──────────────────────────────────────────────
    black                   # Opinionated Python code formatter
    ruff                    # Blazing-fast linter (replaces flake8 + isort)
    mypy                    # Static type checker
    ipython                 # Enhanced interactive Python REPL
    ipdb                    # IPython-based debugger

    # ── Production / Deployment ───────────────────────────────────────────────
    gunicorn                # WSGI HTTP server for production serving

  ]);

in

pkgs.mkShell {

  # ---------------------------------------------------------------------------
  #  All packages available on $PATH inside nix-shell
  # ---------------------------------------------------------------------------
  packages = [

    # ── Python (full env above) ───────────────────────────────────────────────
    pythonEnv

    # ── SQLite & DB Tools ─────────────────────────────────────────────────────
    pkgs.sqlite              # sqlite3 CLI — inspect your DB directly
    pkgs.litecli             # Feature-rich SQLite CLI with autocomplete
    pkgs.sqldiff             # Compare SQLite database schemas

    # ── Redis (Celery broker + caching backend) ───────────────────────────────
    pkgs.redis               # redis-server + redis-cli

    # ── Node.js Ecosystem (Vue 3 + Vite frontend) ─────────────────────────────
    pkgs.nodejs_22           # Node.js LTS runtime

    # ── API Testing & Debugging ───────────────────────────────────────────────
    pkgs.curl                # Classic HTTP client for quick API calls
    pkgs.httpie              # Human-friendly HTTP client (`http GET ...`)
    pkgs.jq                  # Parse + filter JSON on the command line
    pkgs.websocat            # WebSocket testing from CLI

    # ── Version Control ───────────────────────────────────────────────────────
    pkgs.git                 # Version control (required for submissions)
    pkgs.gh                  # GitHub CLI for PRs, issues, auth

    # ── Dev Utilities ─────────────────────────────────────────────────────────
    pkgs.just                # `just` task runner (Makefile replacement)
    pkgs.watchexec           # Auto-restart Flask on file changes
    pkgs.entr                # Re-run commands when files change
    pkgs.tree                # Directory structure visualization
    pkgs.ripgrep             # Fast grep — search through your codebase
    pkgs.fd                  # Fast `find` replacement
    pkgs.bat                 # `cat` with syntax highlighting
    pkgs.tldr                # Simplified man pages for quick reference

    # ── Network & Port Tools ──────────────────────────────────────────────────
    pkgs.netcat-gnu          # Check if Redis / Flask port is listening
    pkgs.lsof                # List open ports (`lsof -i :5000`)

  ];

  # ---------------------------------------------------------------------------
  #  Shell environment variables set automatically on `nix-shell`
  # ---------------------------------------------------------------------------
  shellHook = ''
    echo ""
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║   🎓  IITM BS DS — MAD 1 Dev Shell  Ready               ║"
    echo "║   Flask · SQLite · Jinja2 · Vue · Celery · Redis        ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo ""

    # Python path
    export PYTHONDONTWRITEBYTECODE=1
    export PYTHONUNBUFFERED=1

    # Flask defaults — override per project in .env
    export FLASK_ENV=development
    export FLASK_DEBUG=1
    export FLASK_APP=app.py

    # SQLite default DB path (override in your app config)
    export DATABASE_URL="sqlite:///dev.db"

    # Redis URL for Celery broker + result backend
    export CELERY_BROKER_URL="redis://localhost:6379/0"
    export CELERY_RESULT_BACKEND="redis://localhost:6379/0"

    # Secrets (replace with real values in production .env)
    export SECRET_KEY="dev-insecure-key-change-in-prod"
    export JWT_SECRET_KEY="dev-jwt-secret-change-in-prod"

    # Convenience aliases
    alias flask-run="flask run --host=0.0.0.0 --port=5000"
    alias redis-start="redis-server --daemonize yes && echo 'Redis started on :6379'"
    alias redis-stop="redis-cli shutdown"
    alias db-shell="litecli \$DATABASE_URL"
    alias pytest-cov="pytest --cov=. --cov-report=term-missing"
    alias celery-worker="celery -A app.celery worker --loglevel=info"
    alias celery-beat="celery -A app.celery beat --loglevel=info"

    echo "  Aliases loaded:"
    echo "    flask-run     → flask run on 0.0.0.0:5000"
    echo "    redis-start   → start Redis daemon"
    echo "    db-shell      → litecli interactive DB shell"
    echo "    pytest-cov    → pytest with coverage report"
    echo "    celery-worker → start Celery worker"
    echo ""
    echo "  Python: $(python --version)"
    echo "  Node:   $(node --version)"
    echo "  SQLite: $(sqlite3 --version | cut -d' ' -f1-2)"
    echo ""
  '';
}
