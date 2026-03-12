// pm2 ecosystem for Travenor backend
// Usage:
//   pm2 start ecosystem.config.cjs          # start all
//   pm2 restart ecosystem.config.cjs        # restart all
//   pm2 stop ecosystem.config.cjs           # stop all
//   pm2 logs celery-worker                  # tail logs

const BACKEND = "/home/thatsayon/travenor/backend";
const PYTHON = `${BACKEND}/venv/bin/python`;

module.exports = {
    apps: [
        // ── Django / Gunicorn ──────────────────────────────────────────────
        {
            name: "django",
            cwd: BACKEND,
            interpreter: "none",
            script: `${BACKEND}/venv/bin/uvicorn`,
            args: "config.asgi:application --host 0.0.0.0 --port 8000 --workers 3",
            env: {
                DJANGO_SETTINGS_MODULE: "config.settings.prod",
                CELERY_BROKER_URL: "redis://127.0.0.1:6379/0",
                CELERY_RESULT_BACKEND: "redis://127.0.0.1:6379/0",
            },
            autorestart: true,
            watch: false,
        },

        // ── Celery Worker ──────────────────────────────────────────────────
        {
            name: "celery-worker",
            cwd: BACKEND,
            interpreter: PYTHON,
            script: `${BACKEND}/venv/bin/celery`,
            args: "-A config worker --loglevel=info --concurrency=2 -Q celery",
            env: {
                DJANGO_SETTINGS_MODULE: "config.settings.prod",
                CELERY_BROKER_URL: "redis://127.0.0.1:6379/0",
                CELERY_RESULT_BACKEND: "redis://127.0.0.1:6379/0",
            },
            autorestart: true,
            watch: false,
            max_memory_restart: "300M",
        },

        // ── Celery Beat (scheduled tasks – add if you need periodic tasks) ─
        // {
        //   name: "celery-beat",
        //   cwd: BACKEND,
        //   interpreter: PYTHON,
        //   script: "-m",
        //   args: "celery -A config beat --loglevel=info --scheduler django_celery_beat.schedulers:DatabaseScheduler",
        //   env: {
        //     DJANGO_SETTINGS_MODULE: "config.settings.prod",
        //   },
        //   autorestart: true,
        //   watch: false,
        // },
    ],
};
