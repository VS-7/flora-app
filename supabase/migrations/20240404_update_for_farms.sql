-- Criar tabela de fazendas
CREATE TABLE public.farms (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    location TEXT,
    user_id TEXT NOT NULL,
    description TEXT,
    total_area REAL,
    main_crop TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Adicionar campos farm_id nas tabelas existentes
ALTER TABLE public.activities ADD COLUMN farm_id TEXT;
ALTER TABLE public.collaborators ADD COLUMN farm_id TEXT;
ALTER TABLE public.payments ADD COLUMN farm_id TEXT;

-- Configurar RLS (Row Level Security) para tabela de fazendas
ALTER TABLE public.farms ENABLE ROW LEVEL SECURITY;

-- Criar políticas para permitir que usuários autenticados acessem suas próprias fazendas
CREATE POLICY "Usuários autenticados podem acessar suas próprias fazendas" ON public.farms
    USING (auth.uid()::text = user_id);

-- Atualizar triggers para tabela de fazendas
CREATE TRIGGER update_farms_updated_at
BEFORE UPDATE ON public.farms
FOR EACH ROW
EXECUTE PROCEDURE update_updated_at_column(); 