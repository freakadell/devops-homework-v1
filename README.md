# DevOps kodutöö v1

Paigaldada lihtne konteineriseeritud rakendus Kubernetes pilveplatvormile koos korrektsete seadistuste ja automatiseeritud paigaldusvooga.

Ülesanne simuleerib tüüpilist töövoogu: kood GitHubis → image konteinerregistris → paigaldus Kubernetese klastrisse.

## Projekti struktuur

```text
.
├── .github/
│   └── workflows/
│       ├── ci.yml
│       └── cd.yml
├── k8s/
│   ├── dev/
│   │   ├── configmap.yaml
│   │   ├── deployment.yaml
│   │   ├── ingress.yaml
│   │   └── service.yaml
│   └── prod/
│       ├── configmap.yaml
│       ├── deployment.yaml
│       ├── ingress.yaml
│       └── service.yaml
├── index.html
├── Dockerfile
├── .dockerignore
└── README.md
```

---

## Arhitektuur ja turvalisus (Valikute põhjendused)

### 1. Konteinerbaas: Chainguard Nginx

Kuna `gcr.io/distroless/nginx-debian` veebiserverit ametlikult enam ei pakuta ning `nginx:latest` on välistatud ülesande püstituses on kasutusel **Chainguard Nginx** (`cgr.dev/chainguard/nginx`).

* **Minimalistlik ja turvaline:** Image sisaldab ainult veebiserveri käivitamiseks vajalikke minimaalseid komponente ning töötab isoleeritud kasutajana, tagades *secure-by-default* printsiibi.

### 2. Keskkondade eraldatus (Dev vs Prod)

Keskkonnad **dev** ja **prod** on eraldatud staatiliste manifesti kataloogide kaudu (`k8s/dev/` ja `k8s/prod/`).

* **Isolatsioon:** Keskkonnad on isoleeritud Kubernetese nimeruumide (*Namespaces*) tasemel.

---

## ⚙️ CI/CD Pipeline (GitHub Actions)

Projektis on seadistatud automaatne töövoog, mis on jagatud kaheks etapiks:

1. **CI (`ci.yml`):** Käivitub automaatselt iga kord, kui luuakse *Pull Request* `main` harusse. See teeb Docker image test-buildi, veendumaks, et koodis ja seadistustes pole vigu.

2. **CD (`cd.yml`):** Käivitub, kui kood liidetakse (*merge*) `main` harusse. See ehitab valmis image, sildistab selle unikaalse Git SHA ja `latest` tagiga ning lükkab  **GitHub Container Registry-sse (GHCR)**.

> **Märkus klastrisse laadimise kohta:** Automaatne klastrisse deployment (`kubectl apply`) on pipeline'is hetkel teadlikult **välja kommenteeritud**. Kuna koodi testin kohalikus  **K3s klastris**, mis ei asu avalikus pilves, puudub GitHub Actionsil klastrile otsene ligipääs. Tootmiskeskkonnas tuleks klastrisse paigaldada GitOps agent (nt ArgoCD) või ühendada klaster GitHubiga läbi VPN-tunneli.

---

## Mida teha tootmiskeskkonnas teisiti?

1. **Helm või Kustomize kasutuselevõtt:** Kaotada ära korduvad staatilised failid `dev/` ja `prod/` kataloogides.

2. **GitOps mudel (ArgoCD / Flux):** Asendada CI/CD push-põhine loogika pull-põhise GitOps mudeliga. Klastris jooksev ArgoCD jälgiks muudatusi ning tõmbaks muudatused K3s klastrisse automaatselt.

3. **Saladuste haldus:** ConfigMap-i asemel võtta tundlike andmete jaoks kasutusele *External Secrets Operator* näiteks HashiCorp Vault.

4. **Piirata ligipääs võrgu tasemel:** Kasutada (*Network policies*) millega seadistada piirangud ja lubada ühendused ainult nende komponentide vahel millel selleks vajadus (nt Web-app pod ja Database pod).
