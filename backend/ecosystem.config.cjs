// pm2 ecosystem for Travenor backend
// Usage:
//   pm2 start ecosystem.config.cjs          # start all
//   pm2 restart ecosystem.config.cjs        # restart all
//   pm2 stop ecosystem.config.cjs           # stop all
//   pm2 logs celery-worker                  # tail logs

const BACKEND = "/home/thatsayon/Desktop/travenor/backend";
const PYTHON  = `${BACKEND}/venv/bin/python`;

module.exports = {
  apps: [
    // ── Django / Gunicorn ──────────────────────────────────────────────
    {
      name: "django",
      cwd: BACKEND,
      interpreter: "none",
      script: `${BACKEND}/venv/bin/gunicorn`,
      args: "config.wsgi:application --bind 0.0.0.0:8000 --workers 3",
      env: {
        DJANGO_SETTINGS_MODULE: "config.settings.prod",
      },
      autorestart: true,
      watch: false,
    },

    // ── Celery Worker ──────────────────────────────────────────────────
    {
      name: "celery-worker",
      cwd: BACKEND,
      interpreter: PYTHON,
      script: "-m",
      args: "celery -A config worker --loglevel=info --concurrency=2 -Q celery",
      env: {
        DJANGO_SETTINGS_MODULE: "config.settings.prod",
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
