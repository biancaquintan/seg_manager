# seg_manager

API desenvolvida em **Ruby on Rails (API-only)** com **PostgreSQL** focada em gerenciar apólices de seguro e seus endossos.

---

## 🚀 Tecnologias utilizadas

- Ruby 3.2.2
- Rails 7.1.3 (API-only)
- PostgreSQL
- JWT (autenticação)
- Kaminari (paginação)
- RSpec, FactoryBot, Faker, Shoulda Matchers (testes)
- Dotenv (variáveis de ambiente)
- RuboCop & Brakeman (análise de código e segurança)

---

## ⚙️ Como rodar o projeto

```bash
# Clone o repositório
git clone https://github.com/biancaquintan/seg_manager.git
cd seg_manager

# Instale as dependências
bundle install

# Configure as variáveis de ambiente
Faça uma cópia do arquivo ´.env.example´ (encontrado na pasta raiz do projeto) e renomeie para `.env`, preenchendo os valores das variáveis com os dados correspondentes.
Mantenha o novo arquivo (`.env`) na pasta raiz do projeto.

# Configure o banco de dados
rails db:create
rails db:migrate

# Popule o banco de dados com o usuário padrão para geração de token JWT
rails db:seed

# Rode o servidor
rails server

```

Caso opte por usar DOCKER:

```bash
# Clone o repositório
git clone https://github.com/biancaquintan/seg_manager.git
cd seg_manager

# Suba os containers em background
docker compose up --build -d

# Crie o banco, rode migrations e seeds
docker compose run web bin/rails db:create db:migrate db:seed
```

Acesse `http://localhost:3000` para usar a API.

Credenciais de usuário padrão -> email: user@segmanager.com  |  password: 123456

---

## 📚 Endpoints principais

As requisições possuem paginação disponível via parâmetros `page` e `per_page`.

### Criar apólice

- **Método:** `POST`
- **Rota:** `/api/v1/policies`

### Listar apólices

- **Método:** `GET`
- **Rota:** `/api/v1/policies`
- **Paginação:** `/api/v1/policies?page=1&per_page=10`

### Detalhes de uma apólice

- **Método:** `GET`
- **Rota:** `/api/v1/policies/:id`

### Criar endosso

- **Método:** `POST`
- **Rota:** `/api/v1/policies/:policy_id/endorsements`

### Listar endossos

- **Método:** `GET`
- **Rota:** `/api/v1/policies/:policy_id/endorsements`
- **Paginação:** `/api/v1/policies/:policy_id/endorsements?page=1&per_page=10`
  `

### Detalhes de um endosso

- **Método:** `GET`
- **Rota:** `/api/v1/policies/:policy_id/endorsements/:id`

---

## 🧪 Testes

Este projeto utiliza **RSpec** para testes automatizados.

### Rodar Testes 

```bash
bundle exec rspec
```
### Rodar Testes via Docker

```bash
docker compose exec web bash -c "RAILS_ENV=test bundle exec rspec"
```

### Testes manuais via Postman

Há uma collection do **Postman** disponível na pasta raiz do projeto (`SegManager.postman_collection.json`) para facilitar a execução e validação manual dos endpoints.
