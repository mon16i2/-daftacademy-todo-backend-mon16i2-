# daftacademy-todo-backend

Repozytorium zawiera kod źródłowy API, które zostało wydzielone z repozytorium [DevOps-4-Beginners-2022](https://github.com/DevOps4Beginners2022/DevOps-4-Beginners-2022), żeby ułatwić proces wdrożenia na [heroku](https://heroku.com).


## Lista kroków do wykonania  

### Deployment aplikacji na heroku
1. Utwórz konto na [heroku](https://heroku.com) oraz zainstaluj [heroku-cli](https://devcenter.heroku.com/articles/heroku-cli).
2. Zanim przejdziesz do kolejnych kroków pamiętaj, żeby zalogować się do heroku za pomocą polecenia: `heroku login`.
3. Utwórz plik heroku.yml z sekcją `setup` zawierającą konfiguracje postgresa, redisa oraz zmienne środowiskowe, które będą przekazane do naszej aplikacji.

```yaml
setup:
  addons:
    - plan: heroku-postgresql
    - plan: heroku-redis
  config:
    RAILS_LOG_TO_STDOUT: true
    CORS_DOMAINS: "*"
    RAILS_ENV: "production"
    #SECRET_KEY_BASE: # zmienna zostanie ustawiona z poziomu haroku dashboard w dalszym etapie
```
4. Do manifestu heroku.yml dodaj sekcje: `build`, która wskaże plik Dockerfile, na podstawie, którego obraz naszej aplikacji zostanie zbudowany.

```yaml
build:
  docker:
    web: Dockerfile
```
5. Następnie dodaj sekcje `release`, która defininuje zadania, które mają być wykonane przed kazdym wdrozeniem. W naszym przypadku będzie to uruchomienie migracji schemy bazy danych. Zwróc uwagę, ze w porównaniu z docker-compose usuneliśmy komende `db:create` ze względu na to, ze postgres jest dostarczany z utworzoną bazą danych, więc ten krok nie jest nam potrzebny.

```yaml
release:
  command:
    - rails db:migrate
  image: web

```
6. Ostatni etap w naszym manifeście zawiera blok `run`, który opisuje jakie serwisy będziemy uruchamiać wraz z informacją o obrazie bazowym i komendzie, która ma zostać uruchomiona podczas startu kontenerów. 

```yaml
run:
  web: bundle exec puma -C config/puma.rb
  worker:
    command:
      - bundle exec sidekiq -C config/sidekiq.yml
    image: web
```

8. Zanim przejdziemy do utworzenia i wdrozenia naszej aplikacji na heroku zainstalujmy plugin, który pozwoli nam na utworzenie aplikacji na podstawie wcześniej utworzonego manifestu.
```bash
heroku update beta
heroku plugins:install @heroku-cli/plugin-manifest
```

9. Utwórzmy aplikacje heroku na podstawie pliku heroku.yml `heroku create daftacademy-todo-backend-xyz --manifest --region eu`. Nazwa aplikacji musi być unikalna.

10. Z kwestii konfgiguracyjnych zostało nam jeszcze wygenerowanie losowego ciągu znaków np. za pomocą: `openssl rand -base64 24`. Skopiuj go i ustaw zmienną SECRET_KEY_BASE z poziomu panelu heroku ustawiając wygenerowaną przed chwilą wartość. 
11. Jesteśmy gotowi to naszego pierwszego wdrozenia. Dodajmy nasze zmiany do repozytorium: 
```bash
git add heroku.yml
git commit -m "Add heroku.yml
```
Następnie wrzućmy nasze zmiany na zdalne repozytorium heroku, zeby uruchomić proces budowania i wdrozenia naszej aplikacji:
```bash
git push heroku main
```

12. Po zakończonym budowaniu i wdrozeniu mozesz podejrzec logi naszej aplikacji za pomocą `heroku logs --tails`.

> **UWAGA:**
> Jeśli, któryś z etapów nie jest dla ciebie jasny rzuć okiem na [dokumentacje](https://devcenter.heroku.com/articles/build-docker-images-heroku-yml).

### Konfiguracja CI/CD za pomocą Github Actions

1. Skopiuj API KEY z [ustawień konta heroku](https://dashboard.heroku.com/account) i skonfiguruj sekret o nazwie  HEROKU_API_KEY w konfigiracji repozytorium na githubie.

2. Utwórz plik main.yml w katalogu .github/workflows/main.yml

`mkdir -p .github/workflows && touch .github/workflows/main.yml`

3. Dodaj konfigurację, która umozliwi deploy aplikacji na heroku. W tym celu skorzystamy z gotowej akcji z marketplace: https://github.com/marketplace/actions/deploy-to-heroku

```yaml
name: Test CI/CD

on:
  push:
    branches:
      - main

jobs:
  deploy-to-heroku:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: akhileshns/heroku-deploy@v3.12.12 
        with:
          heroku_api_key: ${{secrets.HEROKU_API_KEY}} # Skopiuj API KEY ze swojego konta heroku i dodaj je jako sekret w projekcie
          heroku_app_name: "xxxxx" # Wpisz nazwe swojej aplikacji
          heroku_email: "xxxxx" # Wpisz swój adres email

```
4. Wprowadź zmiany w projekcie, dzięki którym poznasz wersje aplikacji, zacommituj je, a następnie wypchnij commity do repozytorium githuba. 

5. Skonfiguruj workflow w ten sposób, zeby pipeline uruchamiał się tylko, jeśli tag zaczynający się na literę "v" zostanie dodany do repozytorium.

Zmień fragment:
```yaml
on:
  push:
    branches:
      - main

```
na:

```yaml
on:
  push:
    tags:        
      - v**
```

6. Dodaj kolejny job, dzięki któremy zbudujemy obraz i dodamy go do repozytrium githuba.

Dodaj dodatkowe zmienne środowiskowe:

```yaml
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}
```

Dodaj job:

```yaml
  build-and-push-image:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write

    steps:
      - name: Checkout repository
        uses: actions/checkout@v3

      - name: Log in to the Container registry
        uses: docker/login-action@f054a8b539a109f9f41c372932f1ae047eff08c9
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Extract metadata (tags, labels) for Docker
        id: meta
        uses: docker/metadata-action@98669ae865ea3cffbcbaa878cf57c20bbf1c6c38
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}

      - name: Build and push Docker image
        uses: docker/build-push-action@ad44023a93711e3deb337508980b4b5e9bcdc5dc
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
```

Dodatkowo zmieńmy konfiguracje joba do deployu, dzięki której job wykona się tylko jeśli build-and-push-image wykona się poprawnie.
Wystarczy dodać ponizszy klucz:
```yaml
  needs: [build-and-push-image]
```
> **UWAGA:**
> Jeśli, któryś z etapów nie jest dla ciebie jasny rzuć okiem na [dokumentacje](https://docs.github.com/en/actions).