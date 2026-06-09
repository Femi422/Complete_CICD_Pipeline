# Complete_CICD_Pipeline
Give me step-by-step to end-to-end CI/CD pipeline that integrates with Docker, deploys to
kubernetes and uses terraform for infrastructure includes proper monitoring with
prometheus and grafana for a simple html retail e-commerce application project

<img width="968" height="692" alt="image" src="https://github.com/user-attachments/assets/6843562d-e102-4e95-933f-7ea1cd97ef4b" />


Check available skills
Check available skills
Here's a complete Docker Compose local development setup for your retail e-commerce app — everything runs on localhost with one command.

Updated project structure
ecommerce-app/
├── src/
│   ├── index.html
│   ├── products.html
│   └── assets/
│       ├── style.css
│       └── app.js
├── Dockerfile
├── nginx.conf
├── docker-compose.yml
├── docker-compose.monitoring.yml   ← optional: local Prometheus + Grafana
└── prometheus/
    └── prometheus.yml
1. Sample HTML app (so you have something to see)
src/index.html

html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>ShopLocal</title>
  <link rel="stylesheet" href="assets/style.css"/>
</head>
<body>
  <header>
    <h1>ShopLocal</h1>
    <nav><a href="index.html">Home</a> <a href="products.html">Products</a></nav>
  </header>
  <main>
    <h2>Welcome to ShopLocal</h2>
    <p>Your neighbourhood e-commerce store.</p>
    <a href="products.html" class="btn">Shop Now</a>
  </main>
</body>
</html>
src/products.html

html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <title>Products – ShopLocal</title>
  <link rel="stylesheet" href="assets/style.css"/>
</head>
<body>
  <header>
    <h1>ShopLocal</h1>
    <nav><a href="index.html">Home</a> <a href="products.html">Products</a></nav>
  </header>
  <main>
    <h2>Products</h2>
    <div class="grid">
      <div class="card"><h3>Sneakers</h3><p>$49.99</p><button>Add to cart</button></div>
      <div class="card"><h3>Backpack</h3><p>$79.99</p><button>Add to cart</button></div>
      <div class="card"><h3>Watch</h3><p>$129.99</p><button>Add to cart</button></div>
      <div class="card"><h3>Sunglasses</h3><p>$34.99</p><button>Add to cart</button></div>
    </div>
  </main>
  <script src="assets/app.js"></script>
</body>
</html>
src/assets/style.css

css
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
body { font-family: system-ui, sans-serif; background: #f5f5f5; color: #222; }
header { background: #1a1a2e; color: #fff; padding: 1rem 2rem; display: flex; align-items: center; justify-content: space-between; }
header h1 { font-size: 1.4rem; }
nav a { color: #ccc; text-decoration: none; margin-left: 1rem; }
nav a:hover { color: #fff; }
main { max-width: 960px; margin: 2rem auto; padding: 0 1rem; }
main h2 { margin-bottom: 1rem; }
.btn { display: inline-block; margin-top: 1rem; padding: .75rem 1.5rem; background: #534AB7; color: #fff; border-radius: 8px; text-decoration: none; }
.grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1rem; margin-top: 1rem; }
.card { background: #fff; border-radius: 10px; padding: 1.25rem; border: 1px solid #e0e0e0; }
.card h3 { margin-bottom: .5rem; }
.card p { color: #555; margin-bottom: 1rem; }
button { padding: .5rem 1rem; background: #534AB7; color: #fff; border: none; border-radius: 6px; cursor: pointer; }
button:hover { background: #3C3489; }
src/assets/app.js

js
document.querySelectorAll('button').forEach(btn => {
  btn.addEventListener('click', () => {
    btn.textContent = 'Added!';
    btn.style.background = '#1D9E75';
    setTimeout(() => {
      btn.textContent = 'Add to cart';
      btn.style.background = '';
    }, 1500);
  });
});
2. Core docker-compose.yml
This is all you need to run the app locally:

yaml
version: "3.9"

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: ecommerce-app
    ports:
      - "80:80"       # visit http://localhost
    volumes:
      - ./src:/usr/share/nginx/html   # live reload: edit files, refresh browser
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "-qO-", "http://localhost/health"]
      interval: 30s
      timeout: 5s
      retries: 3
The volumes mount means you edit files in src/ and just refresh your browser — no rebuild needed.

3. Optional: docker-compose.monitoring.yml
Run this alongside the core compose to get local Prometheus + Grafana:

yaml
version: "3.9"

services:
  nginx-exporter:
    image: nginx/nginx-prometheus-exporter:1.1
    container_name: nginx-exporter
    command:
      - -nginx.scrape-uri=http://app/stub_status
    ports:
      - "9113:9113"
    depends_on:
      - app

  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
    command:
      - --config.file=/etc/prometheus/prometheus.yml

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    depends_on:
      - prometheus
prometheus/prometheus.yml

yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: ecommerce-nginx
    static_configs:
      - targets: ["nginx-exporter:9113"]
4. Commands — everything you need day to day
Start the app only:

bash
docker compose up --build
# open http://localhost
Start app + monitoring stack:

bash
docker compose -f docker-compose.yml -f docker-compose.monitoring.yml up --build
# app        → http://localhost
# Prometheus → http://localhost:9090
# Grafana    → http://localhost:3000  (admin / admin)
Rebuild after Dockerfile changes:

bash
docker compose up --build
Stop everything:

bash
docker compose down
View live logs:

bash
docker compose logs -f app
Shell into the running container:

bash
docker exec -it ecommerce-app sh
5. Local vs production at a glance
Local (Docker Compose)	Production (EKS)
URL	http://localhost	AWS load balancer / your domain
Live edit	Yes — via volume mount	No — requires a new git push
Replicas	1	2–10 (HPA)
Monitoring	Optional local stack	Prometheus + Grafana in cluster
TLS/HTTPS	No	Yes — via cert-manager + Ingress
Quick start right now
bash
# 1. Clone / enter your project
cd ecommerce-app

# 2. Start it
docker compose up --build

# 3. Open browser
open http://localhost



