# daftacademy-todo-backend

Repozytorium zawiera kod źródłowy API, które zostało wydzielone z repozytorium [DevOps-4-Beginners-2022](https://github.com/DevOps4Beginners2022/DevOps-4-Beginners-2022), żeby ułatwić proces wdrożenia na [heroku](https://heroku.com).


## Lista kroków do wykonania

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