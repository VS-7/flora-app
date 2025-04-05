# Configuração do Supabase para o Flora App

Este diretório contém as migrações e configurações necessárias para o Supabase, que é usado para a sincronização de dados online do Flora App.

## Configuração inicial

1. Crie um projeto no [Supabase](https://supabase.com/).
2. Após a criação do projeto, você precisará dos seguintes dados:
   - URL do Supabase
   - Chave anônima (Anon Key)

3. Atualize o arquivo `lib/data/database/supabase_config.dart` com as informações do seu projeto:
   ```dart
   static const String supabaseUrl = 'SUA_URL_DO_SUPABASE';
   static const String supabaseAnonKey = 'SUA_CHAVE_ANONIMA_DO_SUPABASE';
   ```

## Execução das migrações

Há duas maneiras de aplicar as migrações ao seu projeto Supabase:

### Usando o Supabase CLI

1. Instale a [Supabase CLI](https://supabase.com/docs/guides/cli).
2. Configure a CLI com suas credenciais do Supabase.
3. Execute o comando de migração:

```bash
supabase db push
```

### Aplicando manualmente

1. Faça login no dashboard do Supabase.
2. Vá para "SQL Editor" (Editor SQL).
3. Copie e cole o conteúdo do arquivo `migrations/20240404_initial_setup.sql`.
4. Execute o script.

## Estrutura do banco de dados

O banco de dados do Supabase está estruturado com as seguintes tabelas:

1. **users**: Armazena informações dos usuários.
2. **activities**: Armazena informações sobre atividades agrícolas.
3. **collaborators**: Armazena informações sobre colaboradores.
4. **payments**: Armazena informações sobre pagamentos a colaboradores.

Cada tabela possui campos de `created_at` e `updated_at` que são atualizados automaticamente.

## Segurança de linha (RLS)

O banco de dados está configurado com RLS (Row Level Security) para permitir que apenas usuários autenticados acessem os dados. As políticas permitem acesso total para usuários autenticados.

## Sincronização

O aplicativo utiliza a seguinte estratégia de sincronização:

1. **Modo offline**: Os dados são armazenados localmente no dispositivo do usuário usando SQLite.
2. **Sincronização quando online**: Quando o dispositivo estiver conectado à internet, os dados são sincronizados com o Supabase automaticamente.

Os dados são marcados com status de sincronização no banco de dados local para rastrear quais informações precisam ser sincronizadas. 